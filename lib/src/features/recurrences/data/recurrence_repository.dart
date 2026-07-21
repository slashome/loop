import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../domain/recurrence.dart';

/// Source of truth for recurrence definitions (Repeats tab).
class RecurrenceRepository {
  RecurrenceRepository(this._db);

  final AppDatabase _db;

  Stream<List<Recurrence>> watchAll() => _db
      .watchRecurrences()
      .map((rows) => rows.map(recurrenceFromRow).toList());

  Future<void> save(Recurrence r) =>
      _db.upsertRecurrence(recurrenceToCompanion(r));

  Future<void> setActive(String id, bool active) async {
    await (_db.update(_db.recurrenceRows)..where((r) => r.id.equals(id))).write(
      RecurrenceRowsCompanion(
        active: Value(active),
        updatedAt: Value(DateTime.now()),
      ),
    );
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
      active: Value(r.active),
      autoCleanMissed: Value(r.autoCleanMissed),
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
      deletedAt: Value(r.deletedAt),
    );
