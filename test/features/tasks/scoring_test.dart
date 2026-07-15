import 'package:flutter_test/flutter_test.dart';
import 'package:loop/src/features/tasks/domain/scoring.dart';
import 'package:loop/src/features/tasks/domain/task.dart';

/// `now` fixe pour des tests déterministes.
final DateTime kNow = DateTime.utc(2026, 1, 1, 12);

Task makeTask({
  required String id,
  int priority = 3,
  Duration age = Duration.zero,
  TaskStatus status = TaskStatus.open,
  DateTime? deletedAt,
  String title = 'tâche',
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
    test('à âge nul, le score vaut exactement la priorité', () {
      final t = makeTask(id: 'a', priority: 4);
      expect(
          taskScore(t, ScoringConfig.defaults, now: kNow), closeTo(4.0, 1e-9));
    });

    test('un âge négatif ne donne aucun bonus', () {
      final t = makeTask(id: 'a', priority: 2, age: const Duration(days: -5));
      expect(
          taskScore(t, ScoringConfig.defaults, now: kNow), closeTo(2.0, 1e-9));
    });

    test('le score croît avec l\'ancienneté mais reste borné par k', () {
      const cfg = ScoringConfig(k: 2, tauDays: 14);
      final young =
          makeTask(id: 'y', priority: 2, age: const Duration(days: 1));
      final old = makeTask(id: 'o', priority: 2, age: const Duration(days: 60));
      final ancient =
          makeTask(id: 'x', priority: 2, age: const Duration(days: 3650));

      expect(taskScore(old, cfg, now: kNow),
          greaterThan(taskScore(young, cfg, now: kNow)));
      // gain plafonné : jamais au-dessus de priorité + k.
      expect(taskScore(ancient, cfg, now: kNow), lessThanOrEqualTo(2 + cfg.k));
      expect(taskScore(ancient, cfg, now: kNow), closeTo(4.0, 1e-3));
    });

    test('à ~tau, ~63 % du gain k est capté', () {
      const cfg = ScoringConfig(k: 2, tauDays: 14);
      final t = makeTask(id: 'a', priority: 1, age: const Duration(days: 14));
      // 1 - e^-1 ≈ 0.632 → 1 + 2*0.632 ≈ 2.264
      expect(taskScore(t, cfg, now: kNow), closeTo(1 + cfg.k * 0.6321, 1e-3));
    });
  });

  group('anti-famine borné (décision de design)', () {
    const cfg = ScoringConfig(k: 2, tauDays: 14); // borné

    test('une vieille P2 négligée finit par dépasser une P3 fraîche', () {
      final oldLow =
          makeTask(id: 'old', priority: 2, age: const Duration(days: 90));
      final freshMid = makeTask(id: 'fresh', priority: 3);
      final ordered = nextActions([freshMid, oldLow], config: cfg, now: kNow);
      expect(ordered.first.id, 'old'); // score ~4 > 3
    });

    test(
        'mais une vieille P1 ne dépasse JAMAIS une P4 fraîche (priorité domine)',
        () {
      final ancientLow =
          makeTask(id: 'anc', priority: 1, age: const Duration(days: 3650));
      final freshHigh = makeTask(id: 'p4', priority: 4);
      final ordered =
          nextActions([ancientLow, freshHigh], config: cfg, now: kNow);
      expect(ordered.first.id, 'p4'); // ~3 < 4
    });

    test('anti-famine total (k>=4) laisse une vieille P1 remonter au sommet',
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
    test('exclut les tâches supprimées et non ouvertes', () {
      final tasks = [
        makeTask(id: 'open', priority: 5),
        makeTask(id: 'done', priority: 5, status: TaskStatus.done),
        makeTask(id: 'archived', priority: 5, status: TaskStatus.archived),
        makeTask(id: 'deleted', priority: 5, deletedAt: kNow),
      ];
      final result = nextActions(tasks, now: kNow);
      expect(result.map((t) => t.id), ['open']);
    });

    test('applique le filtre orthogonal AVANT le tri', () {
      final tasks = [
        makeTask(id: 'p5', priority: 5),
        makeTask(id: 'p4', priority: 4),
        makeTask(id: 'p2', priority: 2),
      ];
      // filtre : priorité >= 4
      final result = nextActions(
        tasks,
        now: kNow,
        filter: (t) => t.priority >= 4,
      );
      expect(result.map((t) => t.id), ['p5', 'p4']); // filtré puis trié desc
    });

    test('tri par score décroissant, départage par ancienneté', () {
      final tasks = [
        makeTask(id: 'b', priority: 3),
        makeTask(id: 'a', priority: 3, age: const Duration(minutes: 1)),
        makeTask(id: 'top', priority: 5),
      ];
      final result = nextActions(tasks, now: kNow);
      // top d'abord ; puis les deux P3 départagées par ancienneté (a plus vieille)
      expect(result.map((t) => t.id), ['top', 'a', 'b']);
    });

    test(
        'à score égal, départage par urgence : échéance proche > lointaine > sans date',
        () {
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

    test('ne mute pas la liste source', () {
      final tasks = [
        makeTask(id: 'p2', priority: 2),
        makeTask(id: 'p5', priority: 5),
      ];
      final before = tasks.map((t) => t.id).toList();
      nextActions(tasks, now: kNow);
      expect(tasks.map((t) => t.id).toList(), before);
    });
  });

  group('préférence envie/impact (bandes, Étage 1)', () {
    Task pref(
      String id, {
      int priority = 3,
      double? envie,
      double? impactSelf,
      double? impactOthers,
    }) =>
        Task(
          id: id,
          title: id,
          priority: priority,
          envie: envie,
          impactSelf: impactSelf,
          impactOthers: impactOthers,
          createdAt: kNow,
          updatedAt: kNow,
        );

    test('à bande égale, envie plus forte passe devant', () {
      final ordered = nextActions([
        pref('low', envie: 0),
        pref('neutral'),
        pref('high', envie: 1),
      ], now: kNow);
      expect(ordered.map((t) => t.id), ['high', 'neutral', 'low']);
    });

    test('l\'impact (moi + autres) départage aussi', () {
      final ordered = nextActions([
        pref('faible', impactSelf: 0, impactOthers: 0),
        pref('fort', impactSelf: 1, impactOthers: 1),
      ], now: kNow);
      expect(ordered.first.id, 'fort');
    });

    test('la préférence ne franchit JAMAIS un palier de priorité', () {
      // P2 à préférence maximale vs P3 neutre : le P3 reste devant (bande sup.).
      final ordered = nextActions([
        pref('p2max', priority: 2, envie: 1, impactSelf: 1, impactOthers: 1),
        pref('p3neutre', priority: 3),
      ], now: kNow);
      expect(ordered.first.id, 'p3neutre');
    });
  });

  group('PriorityCaps — arbitrage à l\'écriture', () {
    const caps = PriorityCaps({5: 3, 4: 5});

    test('un palier non listé est illimité', () {
      final many =
          List.generate(100, (i) => makeTask(id: 'p1-$i', priority: 1));
      expect(caps.canAssign(1, many), isTrue);
    });

    test('refuse quand le palier est plein', () {
      final full = List.generate(3, (i) => makeTask(id: 'p5-$i', priority: 5));
      expect(caps.canAssign(5, full), isFalse);
      expect(caps.remainingSlots(5, full), 0);
    });

    test('autorise tant qu\'il reste une place', () {
      final two = List.generate(2, (i) => makeTask(id: 'p5-$i', priority: 5));
      expect(caps.canAssign(5, two), isTrue);
      expect(caps.remainingSlots(5, two), 1);
    });

    test('les tâches non vivantes ne comptent pas dans le palier', () {
      final tasks = [
        makeTask(id: 'a', priority: 5),
        makeTask(id: 'b', priority: 5, status: TaskStatus.done),
        makeTask(id: 'c', priority: 5, deletedAt: kNow),
      ];
      expect(caps.remainingSlots(5, tasks), 2); // seule 'a' compte
    });

    test('exclut la tâche en cours d\'édition du décompte', () {
      final full = [
        makeTask(id: 'x', priority: 5),
        makeTask(id: 'y', priority: 5),
        makeTask(id: 'z', priority: 5),
      ];
      // sans exclusion : plein ; en éditant 'z' (déjà P5) : une place virtuelle.
      expect(caps.canAssign(5, full), isFalse);
      expect(caps.canAssign(5, full, excludeId: 'z'), isTrue);
    });
  });
}
