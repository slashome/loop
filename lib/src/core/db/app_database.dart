import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Tasks. Mirror of the `Task` domain model (mapping in the data layer).
class TaskRows extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text().withDefault(const Constant('local'))();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  RealColumn get desire => real().nullable()();
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

/// Recurrence definitions (templates). Tab 2 "Repeats" manages them;
/// their occurrences for the day are materialized as `TaskRows` rows.
///
/// Cadence stored in structured fields ("rrule or equivalent", see design):
/// [freq] + [byWeekday] + [byHours]. The [rrule] field keeps the equivalent
/// string for future use (full RRULE parser in the Repeats tab).
class RecurrenceRows extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text().withDefault(const Constant('local'))();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get freq => text()(); // daily | weekly | monthly
  TextColumn get byWeekdays =>
      text().withDefault(const Constant(''))(); // "1,3,5" (Mon..Sun)
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
            // Required on the web: assets served from the root (web/).
            web: DriftWebOptions(
              sqlite3Wasm: Uri.parse('sqlite3.wasm'),
              driftWorker: Uri.parse('drift_worker.js'),
            ),
          ),
        );

  /// In-memory database for tests.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // v2: multi-valued recurrence cadence (byWeekdays/byMonthDays).
          // The recurrences table is recreated (data re-seeded at bootstrap);
          // tasks and their edits are preserved.
          if (from < 2) {
            await m.deleteTable(recurrenceRows.actualTableName);
            await m.createTable(recurrenceRows);
          }
          // v3: per-recurrence cleanup of missed occurrences.
          if (from < 3) {
            await m.addColumn(recurrenceRows, recurrenceRows.autoCleanMissed);
          }
          // v4: rename the `envie` column to `desire` (English identifiers).
          if (from < 4) {
            await m.renameColumn(taskRows, 'envie', taskRows.desire);
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

  /// Deletes a recurrence and its still-open occurrences (completed tasks
  /// arising from this recurrence are kept as history).
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

  /// Inserts an occurrence if it does not already exist (dedup by
  /// recurrenceId + occurrenceDate).
  Future<void> insertOccurrenceIfAbsent(TaskRowsCompanion row) {
    return into(taskRows).insert(row, mode: InsertMode.insertOrIgnore);
  }

  /// Soft-deletes MISSED open occurrences (due before [dayStart]) of
  /// recurrences whose `autoCleanMissed` is true. Returns the count cleaned.
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
