import 'package:flutter_test/flutter_test.dart';
import 'package:loop/src/features/tasks/domain/scoring.dart';
import 'package:loop/src/features/tasks/domain/task.dart';

/// Fixed `now` for deterministic tests.
final DateTime kNow = DateTime.utc(2026, 1, 1, 12);

Task makeTask({
  required String id,
  int priority = 3,
  Duration age = Duration.zero,
  TaskStatus status = TaskStatus.open,
  DateTime? deletedAt,
  String title = 'task',
}) {
  final created = kNow.subtract(age);
  return Task(
    id: id,
    title: title,
    priority: priority,
    status: status,
    deletedAt: deletedAt,
    createdAt: created,
    updatedAt: created,
  );
}

void main() {
  group('taskScore', () {
    test('at zero age, the score equals exactly the priority', () {
      final t = makeTask(id: 'a', priority: 4);
      expect(
          taskScore(t, ScoringConfig.defaults, now: kNow), closeTo(4.0, 1e-9));
    });

    test('a negative age gives no bonus', () {
      final t = makeTask(id: 'a', priority: 2, age: const Duration(days: -5));
      expect(
          taskScore(t, ScoringConfig.defaults, now: kNow), closeTo(2.0, 1e-9));
    });

    test('the score grows with age but stays bounded by k', () {
      const cfg = ScoringConfig(k: 2, tauDays: 14);
      final young =
          makeTask(id: 'y', priority: 2, age: const Duration(days: 1));
      final old = makeTask(id: 'o', priority: 2, age: const Duration(days: 60));
      final ancient =
          makeTask(id: 'x', priority: 2, age: const Duration(days: 3650));

      expect(taskScore(old, cfg, now: kNow),
          greaterThan(taskScore(young, cfg, now: kNow)));
      // capped gain: never above priority + k.
      expect(taskScore(ancient, cfg, now: kNow), lessThanOrEqualTo(2 + cfg.k));
      expect(taskScore(ancient, cfg, now: kNow), closeTo(4.0, 1e-3));
    });

    test('at ~tau, ~63% of the gain k is captured', () {
      const cfg = ScoringConfig(k: 2, tauDays: 14);
      final t = makeTask(id: 'a', priority: 1, age: const Duration(days: 14));
      // 1 - e^-1 ≈ 0.632 → 1 + 2*0.632 ≈ 2.264
      expect(taskScore(t, cfg, now: kNow), closeTo(1 + cfg.k * 0.6321, 1e-3));
    });
  });

  group('bounded anti-starvation (design decision)', () {
    const cfg = ScoringConfig(k: 2, tauDays: 14); // bounded

    test('a neglected old P2 eventually overtakes a fresh P3', () {
      final oldLow =
          makeTask(id: 'old', priority: 2, age: const Duration(days: 90));
      final freshMid = makeTask(id: 'fresh', priority: 3);
      final ordered = nextActions([freshMid, oldLow], config: cfg, now: kNow);
      expect(ordered.first.id, 'old'); // score ~4 > 3
    });

    test('but an old P1 NEVER overtakes a fresh P4 (priority dominates)', () {
      final ancientLow =
          makeTask(id: 'anc', priority: 1, age: const Duration(days: 3650));
      final freshHigh = makeTask(id: 'p4', priority: 4);
      final ordered =
          nextActions([ancientLow, freshHigh], config: cfg, now: kNow);
      expect(ordered.first.id, 'p4'); // ~3 < 4
    });

    test('total anti-starvation (k>=4) lets an old P1 rise back to the top',
        () {
      const total = ScoringConfig(k: 4, tauDays: 14);
      final ancientLow =
          makeTask(id: 'anc', priority: 1, age: const Duration(days: 3650));
      final freshHigh = makeTask(id: 'p4', priority: 4);
      final ordered =
          nextActions([freshHigh, ancientLow], config: total, now: kNow);
      expect(ordered.first.id, 'anc'); // ~5 > 4
    });
  });

  group('nextActions — composition sorted(filtered(items))', () {
    test('excludes deleted and non-open tasks', () {
      final tasks = [
        makeTask(id: 'open', priority: 5),
        makeTask(id: 'done', priority: 5, status: TaskStatus.done),
        makeTask(id: 'archived', priority: 5, status: TaskStatus.archived),
        makeTask(id: 'deleted', priority: 5, deletedAt: kNow),
      ];
      final result = nextActions(tasks, now: kNow);
      expect(result.map((t) => t.id), ['open']);
    });

    test('applies the orthogonal filter BEFORE sorting', () {
      final tasks = [
        makeTask(id: 'p5', priority: 5),
        makeTask(id: 'p4', priority: 4),
        makeTask(id: 'p2', priority: 2),
      ];
      // filter: priority >= 4
      final result = nextActions(
        tasks,
        now: kNow,
        filter: (t) => t.priority >= 4,
      );
      expect(
          result.map((t) => t.id), ['p5', 'p4']); // filtered then sorted desc
    });

    test('sort by descending score, tie-broken by age', () {
      final tasks = [
        makeTask(id: 'b', priority: 3),
        makeTask(id: 'a', priority: 3, age: const Duration(minutes: 1)),
        makeTask(id: 'top', priority: 5),
      ];
      final result = nextActions(tasks, now: kNow);
      // top first; then the two P3s tie-broken by age (a is older)
      expect(result.map((t) => t.id), ['top', 'a', 'b']);
    });

    test('at equal score, tie-broken by urgency: near due > far > no date', () {
      Task dated(String id, Duration inFuture) => Task(
            id: id,
            title: id,
            priority: 3,
            createdAt: kNow,
            updatedAt: kNow,
            dueAt: kNow.add(inFuture),
          );
      final soon = dated('soon', const Duration(hours: 1));
      final later = dated('later', const Duration(days: 3));
      final noDate = makeTask(id: 'noDate', priority: 3);
      final ordered = nextActions([noDate, later, soon], now: kNow);
      expect(ordered.map((t) => t.id), ['soon', 'later', 'noDate']);
    });

    test('does not mutate the source list', () {
      final tasks = [
        makeTask(id: 'p2', priority: 2),
        makeTask(id: 'p5', priority: 5),
      ];
      final before = tasks.map((t) => t.id).toList();
      nextActions(tasks, now: kNow);
      expect(tasks.map((t) => t.id).toList(), before);
    });
  });

  group('desire/impact preference (bands, Tier 1)', () {
    Task pref(
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

    test('at equal band, higher desire comes first', () {
      final ordered = nextActions([
        pref('low', desire: 0),
        pref('neutral'),
        pref('high', desire: 1),
      ], now: kNow);
      expect(ordered.map((t) => t.id), ['high', 'neutral', 'low']);
    });

    test('impact (self + others) also breaks ties', () {
      final ordered = nextActions([
        pref('faible', impactSelf: 0, impactOthers: 0),
        pref('fort', impactSelf: 1, impactOthers: 1),
      ], now: kNow);
      expect(ordered.first.id, 'fort');
    });

    test('preference NEVER crosses a priority tier', () {
      // Max-preference P2 vs neutral P3: the P3 stays ahead (higher band).
      final ordered = nextActions([
        pref('p2max', priority: 2, desire: 1, impactSelf: 1, impactOthers: 1),
        pref('p3neutre', priority: 3),
      ], now: kNow);
      expect(ordered.first.id, 'p3neutre');
    });
  });

  group('PriorityCaps — arbitration at write time', () {
    const caps = PriorityCaps({5: 3, 4: 5});

    test('an unlisted tier is unlimited', () {
      final many =
          List.generate(100, (i) => makeTask(id: 'p1-$i', priority: 1));
      expect(caps.canAssign(1, many), isTrue);
    });

    test('refuses when the tier is full', () {
      final full = List.generate(3, (i) => makeTask(id: 'p5-$i', priority: 5));
      expect(caps.canAssign(5, full), isFalse);
      expect(caps.remainingSlots(5, full), 0);
    });

    test('allows as long as a slot remains', () {
      final two = List.generate(2, (i) => makeTask(id: 'p5-$i', priority: 5));
      expect(caps.canAssign(5, two), isTrue);
      expect(caps.remainingSlots(5, two), 1);
    });

    test('non-live tasks do not count toward the tier', () {
      final tasks = [
        makeTask(id: 'a', priority: 5),
        makeTask(id: 'b', priority: 5, status: TaskStatus.done),
        makeTask(id: 'c', priority: 5, deletedAt: kNow),
      ];
      expect(caps.remainingSlots(5, tasks), 2); // only 'a' counts
    });

    test('excludes the task being edited from the count', () {
      final full = [
        makeTask(id: 'x', priority: 5),
        makeTask(id: 'y', priority: 5),
        makeTask(id: 'z', priority: 5),
      ];
      // without exclusion: full; when editing 'z' (already P5): one virtual slot.
      expect(caps.canAssign(5, full), isFalse);
      expect(caps.canAssign(5, full, excludeId: 'z'), isTrue);
    });
  });
}
