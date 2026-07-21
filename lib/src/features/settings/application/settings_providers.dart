import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/settings.dart';

/// SharedPreferences instance, overridden in `main()` (already loaded).
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) =>
      throw UnimplementedError('sharedPreferencesProvider must be overridden'),
);

const _kNewestAtBottom = 'newestAtBottom';
const _kLanguageTag = 'languageTag';

/// User preferences, persisted via SharedPreferences.
class SettingsNotifier extends Notifier<Settings> {
  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  Settings build() => Settings(
        newestAtBottom: _prefs.getBool(_kNewestAtBottom) ??
            Settings.defaults.newestAtBottom,
        languageTag:
            _prefs.getString(_kLanguageTag) ?? Settings.defaults.languageTag,
      );

  void setNewestAtBottom(bool value) {
    _prefs.setBool(_kNewestAtBottom, value);
    state = state.copyWith(newestAtBottom: value);
  }

  void setLanguageTag(String tag) {
    _prefs.setString(_kLanguageTag, tag);
    state = state.copyWith(languageTag: tag);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, Settings>(
  SettingsNotifier.new,
);
