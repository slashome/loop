import 'package:flutter_test/flutter_test.dart';
import 'package:loop/src/features/recurrences/domain/recurrence.dart';

void main() {
  final anchor = DateTime(2026, 7, 6); // Monday

  Recurrence rec({
    required RecurrenceFreq freq,
    List<int> weekdays = const [],
    List<int> monthDays = const [],
    List<int> hours = const [9],
    DateTime? dtstart,
  }) =>
      Recurrence(
        id: 'r',
        title: 't',
        freq: freq,
        byWeekdays: weekdays,
        byMonthDays: monthDays,
        byHours: hours,
        dtstart: dtstart ?? anchor,
        createdAt: anchor,
        updatedAt: anchor,
      );

  test('daily: one occurrence per hour, any day', () {
    final r = rec(freq: RecurrenceFreq.daily, hours: [10, 22]);
    final occ = r.occurrencesOn(DateTime(2026, 7, 8, 15));
    expect(occ.map((d) => d.hour), [10, 22]);
    expect(occ.every((d) => d.day == 8), isTrue);
  });

  test('weekly: several weekdays', () {
    final r = rec(
      freq: RecurrenceFreq.weekly,
      weekdays: const [DateTime.monday, DateTime.wednesday, DateTime.friday],
    );
    expect(r.occurrencesOn(DateTime(2026, 7, 6)), hasLength(1)); // Monday ✓
    expect(r.occurrencesOn(DateTime(2026, 7, 8)), hasLength(1)); // Wednesday ✓
    expect(r.occurrencesOn(DateTime(2026, 7, 9)), isEmpty); // Thursday ✗
  });

  test('monthly: several days of the month', () {
    final r = rec(freq: RecurrenceFreq.monthly, monthDays: const [1, 15]);
    expect(r.occurrencesOn(DateTime(2026, 8, 1)), hasLength(1));
    expect(r.occurrencesOn(DateTime(2026, 8, 15)), hasLength(1));
    expect(r.occurrencesOn(DateTime(2026, 8, 9)), isEmpty);
  });

  test('nextOccurrenceFrom: same day if the hour is still upcoming', () {
    final r = rec(freq: RecurrenceFreq.daily, hours: const [22]);
    expect(
      r.nextOccurrenceFrom(DateTime(2026, 7, 11, 12)),
      DateTime(2026, 7, 11, 22),
    );
  });

  test('nextOccurrenceFrom: next matching weekday', () {
    // Saturday 2026-07-11 -> next Thursday = 2026-07-16 21:00
    final r = rec(
      freq: RecurrenceFreq.weekly,
      weekdays: const [DateTime.thursday],
      hours: const [21],
    );
    expect(
      r.nextOccurrenceFrom(DateTime(2026, 7, 11, 12)),
      DateTime(2026, 7, 16, 21),
    );
  });

  test('combines several days AND several hours', () {
    final r = rec(
      freq: RecurrenceFreq.weekly,
      weekdays: const [DateTime.monday, DateTime.thursday],
      hours: const [8, 12, 20],
    );
    // Monday: 3 hours; Tuesday: nothing.
    expect(r.occurrencesOn(DateTime(2026, 7, 6)), hasLength(3));
    expect(r.occurrencesOn(DateTime(2026, 7, 7)), isEmpty);
  });
}
