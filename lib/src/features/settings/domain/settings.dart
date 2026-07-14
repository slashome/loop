/// Préférences utilisateur (locales à l'appareil). Modèle pur.
library;

class Settings {
  const Settings({this.newestAtBottom = true});

  /// Si vrai, la liste Actions est ancrée en bas (meilleur score près du
  /// pouce). Sinon, ancrée en haut (convention classique).
  final bool newestAtBottom;

  Settings copyWith({bool? newestAtBottom}) =>
      Settings(newestAtBottom: newestAtBottom ?? this.newestAtBottom);

  static const Settings defaults = Settings();
}
