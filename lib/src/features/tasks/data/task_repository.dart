import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/db/app_database.dart';
import '../../recurrences/data/recurrence_repository.dart';
import '../domain/task.dart';
import 'fixtures.dart';

/// Source de vérité des tâches (couche data). Mappe Drift <-> domaine, expose
/// un flux réactif pour l'onglet 1, et gère le seed + la génération des
/// occurrences de récurrence.
class TaskRepository {
  TaskRepository(this._db);

  final AppDatabase _db;

  /// Flux des tâches non supprimées. Le tri par score et le filtre « vivant »
  /// se font en aval (couche application).
  Stream<List<Task>> watchTasks() =>
      _db.watchTasks().map((rows) => rows.map(_toTask).toList());

  Future<Task?> getById(String id) async {
    final rows = await _db.allTasks();
    for (final r in rows) {
      if (r.id == id) return _toTask(r);
    }
    return null;
  }

  /// Crée une nouvelle tâche ponctuelle. Renvoie son id.
  Future<String> create({
    required String title,
    String? description,
    int priority = 3,
    double? desire,
    double? impactSelf,
    double? impactOthers,
    DateTime? dueAt,
  }) async {
    final now = DateTime.now();
    final id = const Uuid().v4();
    await _db.upsertTask(
      TaskRowsCompanion.insert(
        id: id,
        title: title,
        description: Value(description),
        priority: Value(priority),
        desire: Value(desire),
        impactSelf: Value(impactSelf),
        impactOthers: Value(impactOthers),
        dueAt: Value(dueAt),
        source: const Value('manual'),
        createdAt: now,
        updatedAt: now,
      ),
    );
    return id;
  }

  /// Soft-delete (sync-ready) : retire la tâche de l'onglet 1.
  Future<void> softDelete(String id) async {
    final now = DateTime.now();
    await (_db.update(_db.taskRows)..where((t) => t.id.equals(id))).write(
      TaskRowsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> complete(String id) async {
    final now = DateTime.now();
    await (_db.update(_db.taskRows)..where((t) => t.id.equals(id))).write(
      TaskRowsCompanion(
        status: const Value('done'),
        completedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  /// Applique une édition. `Value(null)` efface un champ optionnel ;
  /// `Value.absent()` le laisse inchangé.
  Future<void> applyEdit(
    String id, {
    required String title,
    String? description,
    required int priority,
    double? desire,
    double? impactSelf,
    double? impactOthers,
    DateTime? dueAt,
  }) async {
    await (_db.update(_db.taskRows)..where((t) => t.id.equals(id))).write(
      TaskRowsCompanion(
        title: Value(title),
        description: Value(description),
        priority: Value(priority),
        desire: Value(desire),
        impactSelf: Value(impactSelf),
        impactOthers: Value(impactOthers),
        dueAt: Value(dueAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Au démarrage : seed la base si vide, puis matérialise les occurrences
  /// du jour. Idempotent (occurrences dédupliquées par id déterministe).
  Future<void> bootstrap({DateTime? clock}) async {
    final now = clock ?? DateTime.now();
    // Seed indépendant par entité : après une migration qui recrée la table
    // des récurrences, celles-ci se re-seedent sans toucher aux tâches.
    if (await _db.countTasks() == 0) {
      for (final t in seedTasks(now)) {
        await _db.upsertTask(_toCompanion(t));
      }
    }
    if (await _db.countRecurrences() == 0) {
      for (final r in seedRecurrences(now)) {
        await _db.insertRecurrence(recurrenceToCompanion(r));
      }
    }
    await generateOccurrences(on: now);
    await cleanMissedOccurrences(on: now);
  }

  /// Retire (soft-delete) les occurrences manquées des récurrences réglées sur
  /// auto-nettoyage. Renvoie le nombre nettoyé.
  Future<int> cleanMissedOccurrences({required DateTime on}) {
    return _db.cleanMissedOccurrences(DateTime(on.year, on.month, on.day));
  }

  /// Matérialise les occurrences de chaque récurrence active de [on] jusqu'à
  /// [on] + [horizonDays] (roulant). Réexécutable sans doublon (id déterministe
  /// + insertOrIgnore). L'onglet Actions masque les occurrences « à venir » par
  /// défaut ; elles restent accessibles via le filtre « À venir ».
  Future<void> generateOccurrences({
    required DateTime on,
    int horizonDays = 14,
  }) async {
    final recs = await _db.activeRecurrences();
    final today = DateTime(on.year, on.month, on.day);
    for (final row in recs) {
      final rec = recurrenceFromRow(row);
      for (var d = 0; d <= horizonDays; d++) {
        final day = today.add(Duration(days: d));
        for (final occ in rec.occurrencesOn(day)) {
          final id = 'occ_${rec.id}_${occ.toIso8601String()}';
          await _db.insertOccurrenceIfAbsent(
            TaskRowsCompanion.insert(
              id: id,
              title: rec.title,
              description: Value(rec.description),
              priority: Value(rec.defPriority),
              recurrenceId: Value(rec.id),
              occurrenceDate: Value(occ),
              dueAt: Value(occ),
              // Créée MAINTENANT (fraîche), due à l'heure de l'occurrence.
              createdAt: on,
              updatedAt: on,
            ),
          );
        }
      }
    }
  }

  // ── Mapping ────────────────────────────────────────────────────────────

  Task _toTask(TaskRow r) => Task(
        id: r.id,
        ownerId: r.ownerId,
        title: r.title,
        description: r.description,
        desire: r.desire,
        impactSelf: r.impactSelf,
        impactOthers: r.impactOthers,
        priority: r.priority,
        categoryId: r.categoryId,
        status: TaskStatus.values.byName(r.status),
        dueAt: r.dueAt,
        recurrenceId: r.recurrenceId,
        occurrenceDate: r.occurrenceDate,
        source: r.source,
        sourceRef: r.sourceRef,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
        completedAt: r.completedAt,
        deletedAt: r.deletedAt,
      );

  TaskRowsCompanion _toCompanion(Task t) => TaskRowsCompanion.insert(
        id: t.id,
        ownerId: Value(t.ownerId),
        title: t.title,
        description: Value(t.description),
        desire: Value(t.desire),
        impactSelf: Value(t.impactSelf),
        impactOthers: Value(t.impactOthers),
        priority: Value(t.priority),
        categoryId: Value(t.categoryId),
        status: Value(t.status.name),
        dueAt: Value(t.dueAt),
        recurrenceId: Value(t.recurrenceId),
        occurrenceDate: Value(t.occurrenceDate),
        source: Value(t.source),
        sourceRef: Value(t.sourceRef),
        createdAt: t.createdAt,
        updatedAt: t.updatedAt,
        completedAt: Value(t.completedAt),
        deletedAt: Value(t.deletedAt),
      );
}
