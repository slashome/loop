/// Algorithmic core of tab 1 — PURE Dart, testable without launching the app.
///
/// Two strictly separated layers (design decision):
///   1. SCORE   : permanent default ordering, determined by Loop.
///   2. FILTERS : reduce the visible subset, orthogonal to the score.
/// Enforced composition: sorted(filtered(items)) — the filter selects,
/// the score ranks, never the reverse. See [nextActions].
library;

import 'dart:math' as math;

import 'task.dart';

/// Scoring constants — configurable in the GLOBAL settings, never per task.
/// Eventually read from the `settings` feature; defined here to keep this
/// first slice self-contained and dependency-free.
class ScoringConfig {
  const ScoringConfig({
    this.k = 2.0,
    this.tauDays = 14.0,
    this.bandWidth = 1.0,
  })  : assert(k >= 0, 'k must be >= 0'),
        assert(tauDays > 0, 'tauDays must be > 0'),
        assert(bandWidth > 0, 'bandWidth must be > 0');

  /// Maximum gain from aging (bounded anti-starvation).
  ///
  /// The formula adds at most `k` to the score. With `k = 2`, an old task
  /// gains +2: an old P1 reaches ~3 and overtakes a neglected P2/P3, but never
  /// exceeds a fresh P4/P5 → no one starves, priority stays dominant. Set
  /// `k >= 4` for full anti-starvation (everything eventually rises to the top).
  final double k;

  /// Time constant of aging, in DAYS. After ~`tauDays`, the task has captured
  /// ~63% of its maximum gain `k`.
  final double tauDays;

  /// Width of a score BAND. Tasks within the same band (≈ one priority tier)
  /// are broken by desire/impact, never across bands → priority dominates by
  /// construction. See [compareByScore].
  final double bandWidth;

  static const ScoringConfig defaults = ScoringConfig();
}

/// Preference key (0..1): blend of desire/impact, `null` = neutral (0.5).
/// Used to break ties among tasks in the same score band. Desire counts double.
double preferenceBlend(Task t) {
  double v(double? x) => x ?? 0.5;
  return 0.5 * v(t.desire) + 0.25 * v(t.impactSelf) + 0.25 * v(t.impactOthers);
}

/// Score of a task: `priority + k · (1 − e^(−age/τ))`.
///
/// Age is measured in (fractional) days from [Task.createdAt] up to [now].
/// A negative age (a "future" task) is treated as 0: no bonus. The score is
/// never stored — it depends on time, so it is computed on read.
double taskScore(Task task, ScoringConfig config, {required DateTime now}) {
  final ageDays = now.difference(task.createdAt).inMicroseconds /
      Duration.microsecondsPerDay;
  final aging =
      ageDays <= 0 ? 0.0 : config.k * (1 - math.exp(-ageDays / config.tauDays));
  return task.priority + aging;
}

/// Default ordering comparator, by score BANDS.
///
/// The score (priority + aging) is quantized into bands of width
/// [ScoringConfig.bandWidth]: priority (and anti-starvation) decides the BAND,
/// never crossed by preferences → "priority dominates" is guaranteed by
/// construction. Within a band, deterministic tie-breaking:
///  1. by PREFERENCE (desire/impact) descending — this is where desire/impact
///     act, without ever crossing a tier;
///  2. by due-date URGENCY (nearest first, no date last);
///  3. by age; then priority; then id.
int compareByScore(Task a, Task b, ScoringConfig config, DateTime now) {
  final ba = (taskScore(a, config, now: now) / config.bandWidth).floor();
  final bb = (taskScore(b, config, now: now) / config.bandWidth).floor();
  if (ba != bb) return bb.compareTo(ba); // band descending

  final pa = preferenceBlend(a);
  final pb = preferenceBlend(b);
  if ((pa - pb).abs() > 1e-9) return pb.compareTo(pa); // preference desc

  final da = a.dueAt;
  final db = b.dueAt;
  if (da != null && db != null) {
    final byDue = da.compareTo(db); // nearest due date first
    if (byDue != 0) return byDue;
  } else if (da != null) {
    return -1; // a has a due date, b doesn't → a is more urgent
  } else if (db != null) {
    return 1;
  }

  final byAge = a.createdAt.compareTo(b.createdAt); // oldest first
  if (byAge != 0) return byAge;
  final byPriority = b.priority.compareTo(a.priority); // priority desc
  if (byPriority != 0) return byPriority;
  return a.id.compareTo(b.id);
}

/// Tab 1: `sorted(filtered(items))`.
///
/// 1. keeps only live tasks (not deleted, status `open`);
/// 2. applies the optional [filter] (orthogonal to the score);
/// 3. sorts by descending score.
///
/// Does not mutate [tasks]. A null [filter] = no filter (the whole live
/// subset).
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

/// Caps per priority tier — applied on WRITE to force real trade-offs
/// (anti-inflation of P0 labels). Impossible to express cleanly in `CHECK`
/// SQL (it requires counting rows of the same tier), so it's an application
/// rule.
class PriorityCaps {
  const PriorityCaps(this.maxPerBand);

  /// tier -> max simultaneous count. A missing tier = unlimited.
  /// E.g.: `{5: 3, 4: 5}`.
  final Map<int, int> maxPerBand;

  static const PriorityCaps defaults = PriorityCaps({5: 3, 4: 5});

  /// Can [priority] be assigned given the live tasks already present?
  ///
  /// [excludeId]: id of the task being edited, excluded from the count
  /// (otherwise a task already at P5 would count itself when changing other
  /// fields).
  bool canAssign(
    int priority,
    Iterable<Task> liveTasks, {
    String? excludeId,
  }) {
    return remainingSlots(priority, liveTasks, excludeId: excludeId) > 0;
  }

  /// Remaining slots in the [priority] tier. Returns a very large number if the
  /// tier is unlimited. Never negative.
  int remainingSlots(
    int priority,
    Iterable<Task> liveTasks, {
    String? excludeId,
  }) {
    final max = maxPerBand[priority];
    if (max == null) return 1 << 30; // unlimited
    final count = liveTasks
        .where((t) => t.isLive && t.priority == priority && t.id != excludeId)
        .length;
    final remaining = max - count;
    return remaining < 0 ? 0 : remaining;
  }
}
