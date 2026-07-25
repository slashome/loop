/// User preferences (local to the device). Pure model.
library;

import '../../tasks/domain/compass.dart';

class Settings {
  const Settings({
    this.newestAtBottom = true,
    this.languageTag = 'system',
    this.compass = Compass.auto,
    this.impactFocus = ImpactFocus.both,
  });

  /// If true, the Actions list is anchored at the bottom (highest score near
  /// the thumb). Otherwise, anchored at the top (classic convention).
  final bool newestAtBottom;

  /// UI language: 'system' (device language), 'fr' or 'en'.
  final String languageTag;

  /// Active lens on the Actions list (Étage 2). Persisted: "low energy" and
  /// "impact mode" are durable intentions.
  final Compass compass;

  /// Which impact drives the Impact compass.
  final ImpactFocus impactFocus;

  Settings copyWith({
    bool? newestAtBottom,
    String? languageTag,
    Compass? compass,
    ImpactFocus? impactFocus,
  }) =>
      Settings(
        newestAtBottom: newestAtBottom ?? this.newestAtBottom,
        languageTag: languageTag ?? this.languageTag,
        compass: compass ?? this.compass,
        impactFocus: impactFocus ?? this.impactFocus,
      );

  static const Settings defaults = Settings();
}
