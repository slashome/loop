import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../domain/recurrence.dart';

/// Source of truth for recurrence definitions (Repeats tab).
class RecurrenceRepository {
  RecurrenceRepository(this._db, {this.ownerId = AppDatabase.defaultProfileId});

  final AppDatabase _db;

  /// Current profile that owns the recurrences read/written here.
  final String ownerId;

  Stream<List<Recurrence>> watchAll() => _db
      .watchRecurrences(ownerId)
      .map((rows) => rows.map(recurrenceFromRow).toList());

  /// Saves a recurrence, stamping it with the current profile's owner.
  Future<void> save(Recurrence r) => _db.upsertRecurrence(
        recurrenceToCompanion(_withOwner(r)),
      );

  Recurrence _withOwner(Recurrence r) => r.ownerId == ownerId
      ? r
      : Recurrence(
          id: r.id,
          ownerId: ownerId,
          title: r.title,
          description: r.description,
          freq: r.freq,
          byWeekdays: r.byWeekdays,
          byMonthDays: r.byMonthDays,
          byHours: r.byHours,
          byMinute: r.byMinute,
          rrule: r.rrule,
          dtstart: r.dtstart,
          timezone: r.timezone,
          nextOccurrence: r.nextOccurrence,
          defPriority: r.defPriority,
          categoryId: r.categoryId,
          active: r.active,
          autoCleanMissed: r.autoCleanMissed,
          createdAt: r.createdAt,
          updatedAt: r.updatedAt,
          deletedAt: r.deletedAt,
        );

  /// Toggles a recurrence. Deactivating also purges its still-open future
  /// occurrences (symmetric with [delete]) so they stop showing in Actions.
  /// [clock] is injectable for tests.
  Future<void> setActive(String id, bool active, {DateTime? clock}) async {
    final now = clock ?? DateTime.now();
    await (_db.update(_db.recurrenceRows)..where((r) => r.id.equals(id))).write(
      RecurrenceRowsCompanion(
        active: Value(active),
        updatedAt: Value(now),
      ),
    );
    if (!active) {
      await _db.purgeOpenFutureOccurrences(id, now);
    }
  }

  Future<void> delete(String id) => _db.deleteRecurrenceCascade(id);
}

// ── Drift <-> domain mapping (shared with TaskRepository) ──────────────────

List<int> _parseInts(String csv) =>
    csv.split(',').where((s) => s.isNotEmpty).map(int.parse).toList();

Recurrence recurrenceFromRow(RecurrenceRow r) => Recurrence(
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
      categoryId: r.categoryId,
      active: r.active,
      autoCleanMissed: r.autoCleanMissed,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
      deletedAt: r.deletedAt,
    );

RecurrenceRowsCompanion recurrenceToCompanion(Recurrence r) =>
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
      categoryId: Value(r.categoryId),
      active: Value(r.active),
      autoCleanMissed: Value(r.autoCleanMissed),
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
      deletedAt: Value(r.deletedAt),
    );
