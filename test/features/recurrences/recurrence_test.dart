import 'package:flutter_test/flutter_test.dart';
import 'package:loop/src/features/recurrences/domain/recurrence.dart';

void main() {
  final anchor = DateTime(2026, 7, 6); // lundi

  Recurrence rec({
    required RecurrenceFreq freq,
    int? weekday,
    List<int> hours = const [9],
    DateTime? dtstart,
  }) =>
      Recurrence(
        id: 'r',
        title: 't',
        freq: freq,
        byWeekday: weekday,
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

  test('weekly : seulement le bon jour de semaine', () {
    final r = rec(freq: RecurrenceFreq.weekly, weekday: DateTime.thursday);
    expect(r.occurrencesOn(DateTime(2026, 7, 9)), hasLength(1)); // jeudi
    expect(r.occurrencesOn(DateTime(2026, 7, 10)), isEmpty); // vendredi
  });

  test('monthly : seulement le jour du mois de dtstart', () {
    final r = rec(freq: RecurrenceFreq.monthly, dtstart: DateTime(2026, 7, 9));
    expect(r.occurrencesOn(DateTime(2026, 8, 9)), hasLength(1));
    expect(r.occurrencesOn(DateTime(2026, 8, 10)), isEmpty);
  });
}
