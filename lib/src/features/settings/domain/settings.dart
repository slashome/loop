/// User preferences (local to the device). Pure model.
library;

class Settings {
  const Settings({
    this.newestAtBottom = true,
    this.languageTag = 'system',
  });

  /// If true, the Actions list is anchored at the bottom (highest score near
  /// the thumb). Otherwise, anchored at the top (classic convention).
  final bool newestAtBottom;

  /// UI language: 'system' (device language), 'fr' or 'en'.
  final String languageTag;

  Settings copyWith({bool? newestAtBottom, String? languageTag}) => Settings(
        newestAtBottom: newestAtBottom ?? this.newestAtBottom,
        languageTag: languageTag ?? this.languageTag,
      );

  static const Settings defaults = Settings();
}
