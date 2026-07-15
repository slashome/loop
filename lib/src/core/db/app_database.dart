import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Tâches. Miroir du modèle domaine `Task` (mapping dans la couche data).
class TaskRows extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text().withDefault(const Constant('local'))();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  RealColumn get envie => real().nullable()();
  RealColumn get impactSelf => real().nullable()();
  RealColumn get impactOthers => real().nullable()();
  IntColumn get priority => integer().withDefault(const Constant(3))();
  TextColumn get categoryId => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('open'))();
  DateTimeColumn get dueAt => dateTime().nullable()();
  TextColumn get recurrenceId => text().nullable()();
  DateTimeColumn get occurrenceDate => dateTime().nullable()();
  TextColumn get source => text().nullable()();
  TextColumn get sourceRef => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Définitions de récurrence (modèles). L'onglet 2 « Repeats » les gère ;
/// leurs occurrences du jour sont matérialisées en lignes `TaskRows`.
///
/// Cadence stockée en champs structurés (« rrule ou équivalent », cf. design) :
/// [freq] + [byWeekday] + [byHours]. Le champ [rrule] garde la chaîne
/// équivalente pour usage futur (parseur RRULE complet à l'onglet Repeats).
class RecurrenceRows extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text().withDefault(const Constant('local'))();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get freq => text()(); // daily | weekly | monthly
  TextColumn get byWeekdays =>
      text().withDefault(const Constant(''))(); // "1,3,5" (lun..dim)
  TextColumn get byMonthDays =>
      text().withDefault(const Constant(''))(); // "1,15"
  TextColumn get byHours =>
      text().withDefault(const Constant('9'))(); // "10,22"
  IntColumn get byMinute => integer().withDefault(const Constant(0))();
  TextColumn get rrule => text().nullable()();
  DateTimeColumn get dtstart => dateTime()();
  TextColumn get timezone =>
      text().withDefault(const Constant('Europe/Paris'))();
  DateTimeColumn get nextOccurrence => dateTime().nullable()();
  IntColumn get defPriority => integer().withDefault(const Constant(3))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  BoolColumn get autoCleanMissed =>
      boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [TaskRows, RecurrenceRows])
class AppDatabase extends _$AppDatabase {
  AppDatabase()
      : super(
          driftDatabase(
            name: 'loop',
            // Requis sur le web : assets servis à la racine (web/).
            web: DriftWebOptions(
              sqlite3Wasm: Uri.parse('sqlite3.wasm'),
              driftWorker: Uri.parse('drift_worker.js'),
            ),
          ),
        );

  /// Base en mémoire pour les tests.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // v2 : cadence de récurrence multi-valuée (byWeekdays/byMonthDays).
          // La table des récurrences est recréée (données re-seedées au
          // bootstrap) ; les tâches et leurs éditions sont préservées.
          if (from < 2) {
            await m.deleteTable(recurrenceRows.actualTableName);
            await m.createTable(recurrenceRows);
          }
          // v3 : nettoyage des occurrences manquées, paramétrable par récurrence.
          if (from < 3) {
            await m.addColumn(recurrenceRows, recurrenceRows.autoCleanMissed);
          }
        },
      );

  Stream<List<TaskRow>> watchTasks() {
    return (select(taskRows)..where((t) => t.deletedAt.isNull())).watch();
  }

  Future<List<TaskRow>> allTasks() => select(taskRows).get();

  Future<List<RecurrenceRow>> activeRecurrences() {
    return (select(recurrenceRows)
          ..where((r) => r.active.equals(true) & r.deletedAt.isNull()))
        .get();
  }

  Stream<List<RecurrenceRow>> watchRecurrences() {
    return (select(recurrenceRows)
          ..where((r) => r.deletedAt.isNull())
          ..orderBy([(r) => OrderingTerm(expression: r.title)]))
        .watch();
  }

  Future<void> upsertRecurrence(RecurrenceRowsCompanion row) =>
      into(recurrenceRows).insertOnConflictUpdate(row);

  /// Supprime une récurrence et ses occurrences encore ouvertes (les tâches
  /// terminées issues de cette récurrence sont conservées comme historique).
  Future<void> deleteRecurrenceCascade(String id) async {
    await (delete(taskRows)
          ..where((t) => t.recurrenceId.equals(id) & t.status.equals('open')))
        .go();
    await (delete(recurrenceRows)..where((r) => r.id.equals(id))).go();
  }

  Future<int> countTasks() async {
    final c = countAll();
    final q = selectOnly(taskRows)..addColumns([c]);
    final row = await q.getSingle();
    return row.read(c) ?? 0;
  }

  Future<int> countRecurrences() async {
    final c = countAll();
    final q = selectOnly(recurrenceRows)..addColumns([c]);
    final row = await q.getSingle();
    return row.read(c) ?? 0;
  }

  Future<void> upsertTask(TaskRowsCompanion row) =>
      into(taskRows).insertOnConflictUpdate(row);

  Future<void> insertRecurrence(RecurrenceRowsCompanion row) =>
      into(recurrenceRows).insert(row);

  /// Insère une occurrence si elle n'existe pas déjà (dédup par
  /// recurrenceId + occurrenceDate).
  Future<void> insertOccurrenceIfAbsent(TaskRowsCompanion row) {
    return into(taskRows).insert(row, mode: InsertMode.insertOrIgnore);
  }

  /// Soft-delete les occurrences ouvertes MANQUÉES (échéance avant [dayStart])
  /// des récurrences dont `autoCleanMissed` est vrai. Renvoie le nombre nettoyé.
  Future<int> cleanMissedOccurrences(DateTime dayStart) async {
    final autoIds = (await (select(recurrenceRows)
              ..where((r) => r.autoCleanMissed.equals(true)))
            .get())
        .map((r) => r.id)
        .toList();
    if (autoIds.isEmpty) return 0;
    return (update(taskRows)
          ..where((t) =>
              t.recurrenceId.isIn(autoIds) &
              t.status.equals('open') &
              t.deletedAt.isNull() &
              t.dueAt.isSmallerThanValue(dayStart)))
        .write(
      TaskRowsCompanion(
        deletedAt: Value(dayStart),
        updatedAt: Value(dayStart),
      ),
    );
  }
}
