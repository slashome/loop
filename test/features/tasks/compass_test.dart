import 'package:flutter_test/flutter_test.dart';
import 'package:loop/src/features/tasks/domain/compass.dart';
import 'package:loop/src/features/tasks/domain/scoring.dart';
import 'package:loop/src/features/tasks/domain/task.dart';

final kNow = DateTime(2026, 1, 1, 12);

Task t(
  String id, {
  int priority = 3,
  double? desire,
  double? impactSelf,
  double? impactOthers,
}) =>
    Task(
      id: id,
      title: id,
      priority: priority,
      desire: desire,
      impactSelf: impactSelf,
      impactOthers: impactOthers,
      createdAt: kNow,
      updatedAt: kNow,
    );

void main() {
  group('compassMetric', () {
    test('unset fields are neutral (0.5)', () {
      expect(compassMetric(t('a'), Compass.auto, ImpactFocus.both), 0.5);
      expect(compassMetric(t('a'), Compass.desire, ImpactFocus.both), 0.5);
    });

    test('desire mode uses desire only', () {
      final task = t('a', desire: 0.9, impactSelf: 0.1);
      expect(compassMetric(task, Compass.desire, ImpactFocus.both), 0.9);
    });

    test('impact focus selects the right field', () {
      final task = t('a', impactSelf: 0.2, impactOthers: 0.8);
      expect(compassMetric(task, Compass.impact, ImpactFocus.self), 0.2);
      expect(compassMetric(task, Compass.impact, ImpactFocus.others), 0.8);
      expect(compassMetric(task, Compass.impact, ImpactFocus.both), 0.5);
    });
  });

  group('isFolded', () {
    test('auto never folds', () {
      expect(
          isFolded(t('a', desire: 0), Compass.auto, ImpactFocus.both), isFalse);
    });
    test('desire below threshold folds; neutral/unset stays', () {
      expect(isFolded(t('a', desire: 0.2), Compass.desire, ImpactFocus.both),
          isTrue);
      expect(isFolded(t('a'), Compass.desire, ImpactFocus.both), isFalse);
      expect(isFolded(t('a', desire: 0.8), Compass.desire, ImpactFocus.both),
          isFalse);
    });
    test('impact mode folds by the focused impact', () {
      final task = t('a', impactSelf: 0.9, impactOthers: 0.1);
      expect(isFolded(task, Compass.impact, ImpactFocus.others), isTrue);
      expect(isFolded(task, Compass.impact, ImpactFocus.self), isFalse);
    });
  });

  group('compareByScore honors the active compass (same band)', () {
    test('desire mode ranks high desire first', () {
      final low = t('low', desire: 0.1);
      final high = t('high', desire: 0.9);
      final r = [low, high]..sort((a, b) => compareByScore(
          a, b, ScoringConfig.defaults, kNow,
          compass: Compass.desire));
      expect(r.first.id, 'high');
    });

    test('priority still dominates the compass', () {
      // A neglected desire P2 vs a fresh P3: P3 is in a higher band.
      final p2 = t('p2', priority: 2, desire: 1);
      final p3 = t('p3', priority: 3, desire: 0);
      final r = [p2, p3]..sort((a, b) => compareByScore(
          a, b, ScoringConfig.defaults, kNow,
          compass: Compass.desire));
      expect(r.first.id, 'p3');
    });
  });
}
