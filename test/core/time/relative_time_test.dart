import 'package:flutter_test/flutter_test.dart';
import 'package:loop/src/core/time/relative_time.dart';

void main() {
  final now = DateTime(2026, 7, 14, 12, 0);
  String rel(DateTime d) => humanRelative(d, now);

  test('passé proche', () {
    expect(rel(now.subtract(const Duration(seconds: 30))), 'À l\'instant');
    expect(rel(now.subtract(const Duration(minutes: 5))), 'Il y a 5 min');
    expect(rel(now.subtract(const Duration(hours: 3))), 'Il y a 3 h');
  });

  test('futur proche', () {
    expect(rel(now.add(const Duration(seconds: 30))), 'Maintenant');
    expect(rel(now.add(const Duration(minutes: 30))), 'Dans 30 min');
  });

  test('aujourd\'hui / demain / hier avec heure', () {
    expect(rel(DateTime(2026, 7, 14, 15, 0)), 'Aujourd\'hui à 15h00');
    expect(rel(DateTime(2026, 7, 15, 10, 0)), 'Demain à 10h00');
    expect(rel(DateTime(2026, 7, 13, 18, 30)), 'Hier à 18h30');
  });

  test('jours et mois', () {
    expect(rel(DateTime(2026, 7, 16, 9, 0)), 'Dans 2 jours');
    expect(rel(DateTime(2026, 7, 11, 12, 0)), 'Il y a 3 jours');
    expect(rel(DateTime(2026, 8, 15)), 'Dans 1 mois');
    expect(rel(DateTime(2026, 5, 14)), 'Il y a 2 mois');
  });
}
