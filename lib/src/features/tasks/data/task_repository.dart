import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/db/app_database.dart';
import '../../recurrences/data/recurrence_repository.dart';
import '../domain/scoring.dart';
import '../domain/task.dart';
import 'fixtures.dart';

/// Thrown when a write would exceed the per-band priority cap.
class PriorityCapExceeded implements Exception {
  const PriorityCapExceeded(this.priority);
  final int priority;

  @override
  String toString() => 'PriorityCapExceeded(P$priority)';
}

/// Source of truth for tasks (data layer). Maps Drift <-> domain, exposes a
/// reactive stream for tab 1, and handles seeding + generation of recurrence
/// occurrences.
class TaskRepository {
  TaskRepository(
    this._db, {
    this.ownerId = AppDatabase.defaultProfileId,
    this.caps = PriorityCaps.defaults,
  });

  final AppDatabase _db;

  /// Current profile that owns the tasks read/written here (local multi-account).
  final String ownerId;

  /// Priority caps enforced on write (the UI also disables full bands, but the
  /// repository is the actual gate — stale lists or programmatic callers
  /// cannot silently exceed a cap).
  final PriorityCaps caps;

  /// Stream of the current profile's non-deleted tasks. Sorting by score and
  /// the "live" filter are done downstream (application layer).
  Stream<List<Task>> watchTasks() =>
      _db.watchTasks(ownerId).map((rows) => rows.map(_toTask).toList());

  Future<Task?> getById(String id) async {
    final row = await _db.taskById(id);
    return row == null ? null : _toTask(row);
  }

  Future<void> _enforceCap(int priority, {String? excludeId}) async {
    final live = (await _db.watchTasks(ownerId).first).map(_toTask);
    if (!caps.canAssign(priority, live, excludeId: excludeId)) {
      throw PriorityCapExceeded(priority);
    }
  }

  /// Creates a new one-off task. Returns its id.
  /// Throws [PriorityCapExceeded] if the priority band is full.
  Future<String> create({
    required String title,
    String? description,
    int priority = 3,
    double? desire,
    double? impactSelf,
    double? impactOthers,
    DateTime? dueAt,
  }) async {
    await _enforceCap(priority);
    final now = DateTime.now();
    final id = const Uuid().v7();
    await _db.upsertTask(
      TaskRowsCompanion.insert(
        id: id,
        ownerId: Value(ownerId),
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

  /// Soft-delete (sync-ready): removes the task from tab 1.
  Future<void> softDelete(String id) async {
    final now = DateTime.now();
    await (_db.update(_db.taskRows)..where((t) => t.id.equals(id))).write(
      TaskRowsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  /// Moves a task's due date (e.g. drag-and-drop onto a calendar day).
  Future<void> reschedule(String id, DateTime dueAt) async {
    final now = DateTime.now();
    await (_db.update(_db.taskRows)..where((t) => t.id.equals(id))).write(
      TaskRowsCompanion(dueAt: Value(dueAt), updatedAt: Value(now)),
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

  /// Applies an edit. `Value(null)` clears an optional field;
  /// `Value.absent()` leaves it unchanged.
  /// Throws [PriorityCapExceeded] if the priority band is full.
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
    await _enforceCap(priority, excludeId: id);
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

  /// On startup: ensures this profile exists, seeds demo data for the default
  /// profile only (once, when empty), then materializes/cleans the current
  /// profile's occurrences. Idempotent.
  Future<void> bootstrap({DateTime? clock}) async {
    final now = clock ?? DateTime.now();
    if (ownerId == AppDatabase.defaultProfileId) {
      // Default profile owns any pre-multi-account data; ensure its row exists.
      await _db.upsertProfile(
        ProfileRowsCompanion.insert(id: ownerId, name: '', createdAt: now),
      );
      // Per-entity independent seeding (demo). New profiles start empty.
      if (await _db.countTasks(ownerId) == 0) {
        for (final t in seedTasks(now)) {
          await _db.upsertTask(_toCompanion(t));
        }
      }
      if (await _db.countRecurrences(ownerId) == 0) {
        for (final r in seedRecurrences(now)) {
          await _db.insertRecurrence(recurrenceToCompanion(r));
        }
      }
    }
    await generateOccurrences(on: now);
    await cleanMissedOccurrences(on: now);
  }

  /// Soft-deletes missed occurrences of the current profile's auto-cleanup
  /// recurrences. Returns the number cleaned up.
  Future<int> cleanMissedOccurrences({required DateTime on}) {
    return _db.cleanMissedOccurrences(
        DateTime(on.year, on.month, on.day), ownerId);
  }

  /// Realigns the materialized occurrences of one recurrence with its current
  /// definition: purges its still-open FUTURE occurrences (stale cadence,
  /// title, priority…), then regenerates. Call after editing a recurrence —
  /// plain [generateOccurrences] only ADDS and would leave stale duplicates.
  Future<void> reconcileOccurrences({
    required String recurrenceId,
    required DateTime on,
    int horizonDays = 14,
  }) async {
    await _db.purgeOpenFutureOccurrences(recurrenceId, on);
    await generateOccurrences(on: on, horizonDays: horizonDays);
  }

  /// Materializes the occurrences of each active recurrence from [on] up to
  /// [on] + [horizonDays] (rolling). Re-runnable without duplicates
  /// (deterministic id + insertOrIgnore). Occurrences before the recurrence's
  /// `dtstart` are never materialized (a recurrence created at 18:00 must not
  /// spawn an already-overdue 9:00 occurrence for the same day). The Actions
  /// tab hides "upcoming" occurrences by default; they remain accessible via
  /// the "Upcoming" filter.
  Future<void> generateOccurrences({
    required DateTime on,
    int horizonDays = 14,
  }) async {
    final recs = await _db.activeRecurrences(ownerId);
    final today = DateTime(on.year, on.month, on.day);
    for (final row in recs) {
      final rec = recurrenceFromRow(row);
      for (var d = 0; d <= horizonDays; d++) {
        final day = DateTime(today.year, today.month, today.day + d);
        for (final occ in rec.occurrencesOn(day)) {
          if (occ.isBefore(rec.dtstart)) continue;
          final id = 'occ_${rec.id}_${occ.toIso8601String()}';
          await _db.insertOccurrenceIfAbsent(
            TaskRowsCompanion.insert(
              id: id,
              ownerId: Value(ownerId),
              title: rec.title,
              description: Value(rec.description),
              priority: Value(rec.defPriority),
              recurrenceId: Value(rec.id),
              occurrenceDate: Value(occ),
              dueAt: Value(occ),
              // Created NOW (fresh), due at the occurrence time.
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
