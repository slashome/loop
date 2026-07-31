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
  TextColumn get categoryId => text().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  BoolColumn get autoCleanMissed =>
      boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Local profiles (multi-account on the same device, no server). A profile's
/// id is the `ownerId` stamped on that profile's tasks and recurrences.
class ProfileRows extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Task categories (per profile). The badge shows [iconKey]'s icon tinted with
/// the task's priority color — categories carry a shape, not a color.
class CategoryRows extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text().withDefault(const Constant('local'))();
  TextColumn get name => text()();
  TextColumn get iconKey => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [TaskRows, RecurrenceRows, ProfileRows, CategoryRows])
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
  int get schemaVersion => 7;

  /// Reserved id of the first, default profile (owns pre-multi-account data).
  static const defaultProfileId = 'local';

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
          // Only for from == 2: the v2 block above recreates the recurrences
          // table with the CURRENT schema (which already has the column) —
          // adding it again would fail with "duplicate column".
          if (from >= 2 && from < 3) {
            await m.addColumn(recurrenceRows, recurrenceRows.autoCleanMissed);
          }
          // v4: rename the `envie` column to `desire` (English identifiers).
          if (from < 4) {
            await m.renameColumn(taskRows, 'envie', taskRows.desire);
          }
          // v5: local profiles. Existing data has ownerId 'local' → seed the
          // matching default profile so it stays visible.
          if (from < 5) {
            await m.createTable(profileRows);
          }
          // v6: task categories.
          if (from < 6) {
            await m.createTable(categoryRows);
          }
          // v7: recurrences carry a category, inherited by their occurrences.
          if (from < 7) {
            await m.addColumn(recurrenceRows, recurrenceRows.categoryId);
          }
        },
      );

  // ── Profiles ─────────────────────────────────────────────────────────────

  Stream<List<ProfileRow>> watchProfiles() => (select(profileRows)
        ..orderBy([(p) => OrderingTerm(expression: p.createdAt)]))
      .watch();

  Future<List<ProfileRow>> allProfiles() => select(profileRows).get();

  Future<void> upsertProfile(ProfileRowsCompanion row) =>
      into(profileRows).insertOnConflictUpdate(row);

  Future<void> renameProfile(String id, String name) =>
      (update(profileRows)..where((p) => p.id.equals(id)))
          .write(ProfileRowsCompanion(name: Value(name)));

  // ── Categories (scoped to a profile via [ownerId]) ────────────────────────

  Stream<List<CategoryRow>> watchCategories(String ownerId) =>
      (select(categoryRows)
            ..where((c) => c.ownerId.equals(ownerId))
            ..orderBy([(c) => OrderingTerm(expression: c.createdAt)]))
          .watch();

  Future<void> upsertCategory(CategoryRowsCompanion row) =>
      into(categoryRows).insertOnConflictUpdate(row);

  /// Deletes a category; tasks pointing to it fall back to "uncategorized".
  Future<void> deleteCategory(String id) async {
    await (update(taskRows)..where((t) => t.categoryId.equals(id)))
        .write(const TaskRowsCompanion(categoryId: Value(null)));
    await (delete(categoryRows)..where((c) => c.id.equals(id))).go();
  }

  Future<void> setTaskCategory(String taskId, String? categoryId) =>
      (update(taskRows)..where((t) => t.id.equals(taskId))).write(
        TaskRowsCompanion(
          categoryId: Value(categoryId),
          updatedAt: Value(DateTime.now()),
        ),
      );

  // ── Tasks / recurrences (scoped to a profile via [ownerId]) ───────────────

  Stream<List<TaskRow>> watchTasks(String ownerId) {
    return (select(taskRows)
          ..where((t) => t.deletedAt.isNull() & t.ownerId.equals(ownerId)))
        .watch();
  }

  Future<List<TaskRow>> allTasks() => select(taskRows).get();

  Future<TaskRow?> taskById(String id) =>
      (select(taskRows)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<RecurrenceRow>> activeRecurrences(String ownerId) {
    return (select(recurrenceRows)
          ..where((r) =>
              r.active.equals(true) &
              r.deletedAt.isNull() &
              r.ownerId.equals(ownerId)))
        .get();
  }

  Stream<List<RecurrenceRow>> watchRecurrences(String ownerId) {
    return (select(recurrenceRows)
          ..where((r) => r.deletedAt.isNull() & r.ownerId.equals(ownerId))
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

  Future<int> countTasks(String ownerId) async {
    final c = countAll();
    final q = selectOnly(taskRows)
      ..addColumns([c])
      ..where(taskRows.ownerId.equals(ownerId));
    final row = await q.getSingle();
    return row.read(c) ?? 0;
  }

  Future<int> countRecurrences(String ownerId) async {
    final c = countAll();
    final q = selectOnly(recurrenceRows)
      ..addColumns([c])
      ..where(recurrenceRows.ownerId.equals(ownerId));
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

  /// Hard-deletes the still-open FUTURE occurrences (due on/after [from]) of a
  /// recurrence. Occurrences are derived, regenerable artifacts — a hard
  /// delete (not soft) is required so that a later regeneration with the same
  /// deterministic id is not swallowed by insertOrIgnore. Edited or past
  /// occurrences are left untouched.
  Future<int> purgeOpenFutureOccurrences(String recurrenceId, DateTime from) {
    return (delete(taskRows)
          ..where((t) =>
              t.recurrenceId.equals(recurrenceId) &
              t.status.equals('open') &
              t.deletedAt.isNull() &
              t.dueAt.isBiggerOrEqualValue(from)))
        .go();
  }

  /// Syncs the category onto all still-open occurrences of a recurrence, so an
  /// edit to the recurrence's category is reflected on occurrences already
  /// materialized (including today's / overdue ones that regeneration leaves
  /// in place). Done occurrences keep the category they were finished with.
  Future<void> syncOccurrenceCategory(String recurrenceId, String? categoryId) {
    return (update(taskRows)
          ..where((t) =>
              t.recurrenceId.equals(recurrenceId) & t.status.equals('open')))
        .write(TaskRowsCompanion(categoryId: Value(categoryId)));
  }

  /// Soft-deletes MISSED open occurrences (due before [dayStart]) of
  /// recurrences whose `autoCleanMissed` is true. Returns the count cleaned.
  Future<int> cleanMissedOccurrences(DateTime dayStart, String ownerId) async {
    final autoIds = (await (select(recurrenceRows)
              ..where((r) =>
                  r.autoCleanMissed.equals(true) &
                  r.deletedAt.isNull() &
                  r.ownerId.equals(ownerId)))
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
