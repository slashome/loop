import 'package:flutter_test/flutter_test.dart';
import 'package:loop/src/features/recurrences/domain/recurrence.dart';

void main() {
  final anchor = DateTime(2026, 7, 6); // lundi

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

  test('daily : une occurrence par heure, n\'importe quel jour', () {
    final r = rec(freq: RecurrenceFreq.daily, hours: [10, 22]);
    final occ = r.occurrencesOn(DateTime(2026, 7, 8, 15));
    expect(occ.map((d) => d.hour), [10, 22]);
    expect(occ.every((d) => d.day == 8), isTrue);
  });

  test('weekly : plusieurs jours de semaine', () {
    final r = rec(
      freq: RecurrenceFreq.weekly,
      weekdays: const [DateTime.monday, DateTime.wednesday, DateTime.friday],
    );
    expect(r.occurrencesOn(DateTime(2026, 7, 6)), hasLength(1)); // lundi ✓
    expect(r.occurrencesOn(DateTime(2026, 7, 8)), hasLength(1)); // mercredi ✓
    expect(r.occurrencesOn(DateTime(2026, 7, 9)), isEmpty); // jeudi ✗
  });

  test('monthly : plusieurs jours du mois', () {
    final r = rec(freq: RecurrenceFreq.monthly, monthDays: const [1, 15]);
    expect(r.occurrencesOn(DateTime(2026, 8, 1)), hasLength(1));
    expect(r.occurrencesOn(DateTime(2026, 8, 15)), hasLength(1));
    expect(r.occurrencesOn(DateTime(2026, 8, 9)), isEmpty);
  });

  test('combine plusieurs jours ET plusieurs heures', () {
    final r = rec(
      freq: RecurrenceFreq.weekly,
      weekdays: const [DateTime.monday, DateTime.thursday],
      hours: const [8, 12, 20],
    );
    // lundi : 3 heures ; mardi : rien.
    expect(r.occurrencesOn(DateTime(2026, 7, 6)), hasLength(3));
    expect(r.occurrencesOn(DateTime(2026, 7, 7)), isEmpty);
  });
}
