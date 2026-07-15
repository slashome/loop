/// Préférences utilisateur (locales à l'appareil). Modèle pur.
library;

class Settings {
  const Settings({
    this.newestAtBottom = true,
    this.languageTag = 'system',
  });

  /// Si vrai, la liste Actions est ancrée en bas (meilleur score près du
  /// pouce). Sinon, ancrée en haut (convention classique).
  final bool newestAtBottom;

  /// Langue de l'interface : 'system' (langue de l'appareil), 'fr' ou 'en'.
  final String languageTag;

  Settings copyWith({bool? newestAtBottom, String? languageTag}) => Settings(
        newestAtBottom: newestAtBottom ?? this.newestAtBottom,
        languageTag: languageTag ?? this.languageTag,
      );

  static const Settings defaults = Settings();
}
