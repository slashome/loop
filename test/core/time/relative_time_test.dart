import 'package:flutter_test/flutter_test.dart';
import 'package:loop/l10n/app_localizations_en.dart';
import 'package:loop/l10n/app_localizations_fr.dart';
import 'package:loop/src/core/time/relative_time.dart';

void main() {
  final fr = AppLocalizationsFr();
  final en = AppLocalizationsEn();
  final now = DateTime(2026, 7, 14, 12, 0);

  group('français', () {
    String rel(DateTime d) => humanRelative(fr, d, now);
    test('passé / futur proche', () {
      expect(rel(now.subtract(const Duration(minutes: 5))), 'Il y a 5 min');
      expect(rel(now.add(const Duration(minutes: 30))), 'Dans 30 min');
      expect(rel(now.subtract(const Duration(hours: 3))), 'Il y a 3 h');
    });
    test('jours nommés + mois', () {
      expect(rel(DateTime(2026, 7, 14, 15)), 'Aujourd\'hui à 15h00');
      expect(rel(DateTime(2026, 7, 15, 10)), 'Demain à 10h00');
      expect(rel(DateTime(2026, 7, 13, 18, 30)), 'Hier à 18h30');
      expect(rel(DateTime(2026, 7, 16, 9)), 'Dans 2 jours');
      expect(rel(DateTime(2026, 8, 15)), 'Dans 1 mois');
    });
  });

  group('anglais', () {
    String rel(DateTime d) => humanRelative(en, d, now);
    test('formes traduites + heure au format local', () {
      expect(rel(now.subtract(const Duration(minutes: 5))), '5 min ago');
      expect(rel(DateTime(2026, 7, 15, 10)), 'Tomorrow at 10:00');
      expect(rel(DateTime(2026, 7, 16, 9)), 'In 2 days');
      expect(rel(DateTime(2026, 8, 15)), 'In 1 month');
    });
  });
}
