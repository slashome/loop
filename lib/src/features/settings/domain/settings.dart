/// User preferences (local to the device). Pure model.
library;

import '../../tasks/domain/compass.dart';

class Settings {
  const Settings({
    this.newestAtBottom = true,
    this.languageTag = 'system',
    this.compass = Compass.auto,
    this.impactFocus = ImpactFocus.both,
    this.currentProfileId = 'local',
    this.notificationsEnabled = false,
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

  /// Active local profile (owner) whose data is shown.
  final String currentProfileId;

  /// Opt-in for local reminders at each dated task's due time. Off by default
  /// (notifications are a permissioned, interruptive feature).
  final bool notificationsEnabled;

  Settings copyWith({
    bool? newestAtBottom,
    String? languageTag,
    Compass? compass,
    ImpactFocus? impactFocus,
    String? currentProfileId,
    bool? notificationsEnabled,
  }) =>
      Settings(
        newestAtBottom: newestAtBottom ?? this.newestAtBottom,
        languageTag: languageTag ?? this.languageTag,
        compass: compass ?? this.compass,
        impactFocus: impactFocus ?? this.impactFocus,
        currentProfileId: currentProfileId ?? this.currentProfileId,
        notificationsEnabled:
            notificationsEnabled ?? this.notificationsEnabled,
      );

  static const Settings defaults = Settings();
}
