/// Cœur algorithmique de l'onglet 1 — Dart PUR, testable sans lancer l'app.
///
/// Deux couches strictement séparées (décision de design) :
///   1. SCORE   : ordre par défaut permanent, déterminé par Loop.
///   2. FILTRES : réduisent le sous-ensemble visible, orthogonaux au score.
/// Composition imposée : sorted(filtered(items)) — le filtre sélectionne,
/// le score classe, jamais l'inverse. Voir [nextActions].
library;

import 'dart:math' as math;

import 'task.dart';

/// Constantes de scoring — réglables dans les paramètres GLOBAUX, jamais par
/// tâche. Lues depuis la feature `settings` à terme ; définies ici pour garder
/// cette première tranche autoportante et sans dépendance.
class ScoringConfig {
  const ScoringConfig({
    this.k = 2.0,
    this.tauDays = 14.0,
  })  : assert(k >= 0, 'k doit être >= 0'),
        assert(tauDays > 0, 'tauDays doit être > 0');

  /// Gain maximal de l'ancienneté (anti-famine borné).
  ///
  /// La formule ajoute au plus `k` au score. Avec `k = 2`, une vieille tâche
  /// gagne +2 : un vieux P1 atteint ~3 et double un P2/P3 négligé, mais ne
  /// dépasse jamais un P4/P5 frais → personne ne meurt de faim, la priorité
  /// reste dominante. Mettre `k >= 4` pour un anti-famine total (tout finit par
  /// remonter au sommet).
  final double k;

  /// Constante de temps de l'ancienneté, en JOURS. Au bout de ~`tauDays`, la
  /// tâche a capté ~63 % de son gain maximal `k`.
  final double tauDays;

  static const ScoringConfig defaults = ScoringConfig();
}

/// Score d'une tâche : `priorité + k · (1 − e^(−âge/τ))`.
///
/// L'âge est mesuré en jours (fractionnaires) depuis [Task.createdAt] jusqu'à
/// [now]. Un âge négatif (tâche « du futur ») est traité comme 0 : pas de bonus.
/// Le score n'est jamais stocké — il dépend du temps, donc se calcule à la
/// lecture.
double taskScore(Task task, ScoringConfig config, {required DateTime now}) {
  final ageDays = now.difference(task.createdAt).inMicroseconds /
      Duration.microsecondsPerDay;
  final aging =
      ageDays <= 0 ? 0.0 : config.k * (1 - math.exp(-ageDays / config.tauDays));
  return task.priority + aging;
}

/// Comparateur d'ordre par défaut : score décroissant.
///
/// Départage déterministe (évite tout scintillement d'ordre entre rendus).
/// À score quasi égal :
///  1. par URGENCE d'échéance : la plus proche d'abord (les échéances passées
///     avant, celles sans date après) — la priorité domine toujours entre
///     paliers, l'échéance ne tranche qu'à score égal ;
///  2. puis la plus ancienne (anti-famine) ; puis priorité ; puis id.
int compareByScore(Task a, Task b, ScoringConfig config, DateTime now) {
  final sa = taskScore(a, config, now: now);
  final sb = taskScore(b, config, now: now);
  if ((sa - sb).abs() > 1e-9) return sb.compareTo(sa); // score desc

  final da = a.dueAt;
  final db = b.dueAt;
  if (da != null && db != null) {
    final byDue = da.compareTo(db); // échéance la plus proche d'abord
    if (byDue != 0) return byDue;
  } else if (da != null) {
    return -1; // a a une échéance, b non → a est plus urgente
  } else if (db != null) {
    return 1;
  }

  final byAge = a.createdAt.compareTo(b.createdAt); // plus ancienne d'abord
  if (byAge != 0) return byAge;
  final byPriority = b.priority.compareTo(a.priority); // priorité desc
  if (byPriority != 0) return byPriority;
  return a.id.compareTo(b.id);
}

/// L'onglet 1 : `sorted(filtered(items))`.
///
/// 1. ne garde que les tâches vivantes (non supprimées, statut `open`) ;
/// 2. applique le [filter] optionnel (orthogonal au score) ;
/// 3. trie par score décroissant.
///
/// Ne mute pas [tasks]. [filter] nul = aucun filtre (tout le sous-ensemble
/// vivant).
List<Task> nextActions(
  Iterable<Task> tasks, {
  ScoringConfig config = ScoringConfig.defaults,
  required DateTime now,
  bool Function(Task task)? filter,
}) {
  final selected = tasks
      .where((t) => t.isLive)
      .where((t) => filter == null || filter(t))
      .toList();
  selected.sort((a, b) => compareByScore(a, b, config, now));
  return selected;
}

/// Caps par palier de priorité — appliqués à l'ÉCRITURE pour forcer
/// l'arbitrage réel (façon anti-inflation des labels P0). Impossible à exprimer
/// proprement en `CHECK` SQL (il faut compter les lignes du même palier), donc
/// c'est une règle applicative.
class PriorityCaps {
  const PriorityCaps(this.maxPerBand);

  /// palier -> nombre max simultané. Un palier absent = illimité.
  /// Ex : `{5: 3, 4: 5}`.
  final Map<int, int> maxPerBand;

  static const PriorityCaps defaults = PriorityCaps({5: 3, 4: 5});

  /// Peut-on assigner [priority] sachant les tâches vivantes déjà présentes ?
  ///
  /// [excludeId] : id de la tâche en cours d'édition, exclue du décompte (sinon
  /// une tâche déjà P5 se compterait elle-même en changeant d'autres champs).
  bool canAssign(
    int priority,
    Iterable<Task> liveTasks, {
    String? excludeId,
  }) {
    return remainingSlots(priority, liveTasks, excludeId: excludeId) > 0;
  }

  /// Places restantes dans le palier [priority]. Renvoie un très grand nombre
  /// si le palier est illimité. Jamais négatif.
  int remainingSlots(
    int priority,
    Iterable<Task> liveTasks, {
    String? excludeId,
  }) {
    final max = maxPerBand[priority];
    if (max == null) return 1 << 30; // illimité
    final count = liveTasks
        .where((t) => t.isLive && t.priority == priority && t.id != excludeId)
        .length;
    final remaining = max - count;
    return remaining < 0 ? 0 : remaining;
  }
}
