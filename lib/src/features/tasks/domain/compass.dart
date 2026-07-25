/// Compass (Étage 2) — Dart PUR, testable. Orthogonal to the score: it only
/// changes the WITHIN-BAND tie-break and, in Desire/Impact modes, folds the
/// low-metric tasks under a separator. Never crosses a priority band.
library;

import 'task.dart';

/// Lens the user tunes the list through.
enum Compass { auto, desire, impact }

/// For [Compass.impact]: which impact drives the ordering/fold.
enum ImpactFocus { self, others, both }

/// Metric (0..1) used to order and fold tasks under the active compass.
/// `null` fields are treated as neutral (0.5): never penalized nor boosted.
double compassMetric(Task t, Compass compass, ImpactFocus focus) {
  double v(double? x) => x ?? 0.5;
  return switch (compass) {
    // Auto = the blended preference (desire weighted double).
    Compass.auto =>
      0.5 * v(t.desire) + 0.25 * v(t.impactSelf) + 0.25 * v(t.impactOthers),
    Compass.desire => v(t.desire),
    Compass.impact => switch (focus) {
        ImpactFocus.self => v(t.impactSelf),
        ImpactFocus.others => v(t.impactOthers),
        ImpactFocus.both => 0.5 * v(t.impactSelf) + 0.5 * v(t.impactOthers),
      },
  };
}

/// Fold value (0..1) of the FOCUSED field(s). Unlike [compassMetric], an unset
/// field counts as 0 here: in a focused lens ("Others", "Desire"…), a task you
/// never rated on that axis doesn't belong in the main view.
double _foldValue(Task t, Compass compass, ImpactFocus focus) {
  double v(double? x) => x ?? 0;
  return switch (compass) {
    Compass.auto => 1, // never folds
    Compass.desire => v(t.desire),
    Compass.impact => switch (focus) {
        ImpactFocus.self => v(t.impactSelf),
        ImpactFocus.others => v(t.impactOthers),
        ImpactFocus.both => 0.5 * v(t.impactSelf) + 0.5 * v(t.impactOthers),
      },
  };
}

/// Below this fold value a task is tucked away (Desire/Impact modes only).
/// A slider at 6+/10 stays visible; 1–5/10 and unset fold away.
const double kCompassFoldThreshold = 0.5;

/// Whether [t] should be folded under the "needs energy / low impact"
/// separator for the active compass. Auto never folds; unset fields fold.
bool isFolded(Task t, Compass compass, ImpactFocus focus) {
  if (compass == Compass.auto) return false;
  return _foldValue(t, compass, focus) < kCompassFoldThreshold - 1e-9;
}
