import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/settings.dart';

/// Instance SharedPreferences, surchargée dans `main()` (déjà chargée).
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) =>
      throw UnimplementedError('sharedPreferencesProvider must be overridden'),
);

const _kNewestAtBottom = 'newestAtBottom';

/// Préférences utilisateur, persistées via SharedPreferences.
class SettingsNotifier extends Notifier<Settings> {
  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  Settings build() => Settings(
        newestAtBottom: _prefs.getBool(_kNewestAtBottom) ??
            Settings.defaults.newestAtBottom,
      );

  void setNewestAtBottom(bool value) {
    _prefs.setBool(_kNewestAtBottom, value);
    state = state.copyWith(newestAtBottom: value);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, Settings>(
  SettingsNotifier.new,
);
