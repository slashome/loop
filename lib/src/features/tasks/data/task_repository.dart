import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../recurrences/domain/recurrence.dart';
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
    double? envie,
    double? impactSelf,
    double? impactOthers,
    DateTime? dueAt,
  }) async {
    await (_db.update(_db.taskRows)..where((t) => t.id.equals(id))).write(
      TaskRowsCompanion(
        title: Value(title),
        description: Value(description),
        priority: Value(priority),
        envie: Value(envie),
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
        await _db.insertRecurrence(_toRecCompanion(r));
      }
    }
    await generateOccurrences(on: now);
  }

  /// Crée les lignes-tâches des occurrences du jour pour chaque récurrence
  /// active. Réexécutable sans doublon (id déterministe + insertOrIgnore).
  Future<void> generateOccurrences({required DateTime on}) async {
    final recs = await _db.activeRecurrences();
    for (final row in recs) {
      final rec = _toRecurrence(row);
      for (final occ in rec.occurrencesOn(on)) {
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
            createdAt: occ,
            updatedAt: occ,
          ),
        );
      }
    }
  }

  // ── Mapping ────────────────────────────────────────────────────────────

  Task _toTask(TaskRow r) => Task(
        id: r.id,
        ownerId: r.ownerId,
        title: r.title,
        description: r.description,
        envie: r.envie,
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
        envie: Value(t.envie),
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

  Recurrence _toRecurrence(RecurrenceRow r) => Recurrence(
        id: r.id,
        ownerId: r.ownerId,
        title: r.title,
        description: r.description,
        freq: RecurrenceFreq.values.byName(r.freq),
        byWeekdays: _parseInts(r.byWeekdays),
        byMonthDays: _parseInts(r.byMonthDays),
        byHours: _parseInts(r.byHours),
        byMinute: r.byMinute,
        rrule: r.rrule,
        dtstart: r.dtstart,
        timezone: r.timezone,
        nextOccurrence: r.nextOccurrence,
        defPriority: r.defPriority,
        active: r.active,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
        deletedAt: r.deletedAt,
      );

  RecurrenceRowsCompanion _toRecCompanion(Recurrence r) =>
      RecurrenceRowsCompanion.insert(
        id: r.id,
        ownerId: Value(r.ownerId),
        title: r.title,
        description: Value(r.description),
        freq: r.freq.name,
        byWeekdays: Value(r.byWeekdays.join(',')),
        byMonthDays: Value(r.byMonthDays.join(',')),
        byHours: Value(r.byHours.join(',')),
        byMinute: Value(r.byMinute),
        rrule: Value(r.rrule),
        dtstart: r.dtstart,
        timezone: Value(r.timezone),
        nextOccurrence: Value(r.nextOccurrence),
        defPriority: Value(r.defPriority),
        active: Value(r.active),
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
        deletedAt: Value(r.deletedAt),
      );
}

/// Parse une liste d'entiers stockée en CSV ("1,3,5" -> [1,3,5]). Vide -> [].
List<int> _parseInts(String csv) =>
    csv.split(',').where((s) => s.isNotEmpty).map(int.parse).toList();
