import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../tasks/domain/compass.dart';
import '../domain/settings.dart';

/// SharedPreferences instance, overridden in `main()` (already loaded).
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) =>
      throw UnimplementedError('sharedPreferencesProvider must be overridden'),
);

const _kNewestAtBottom = 'newestAtBottom';
const _kLanguageTag = 'languageTag';
const _kCompass = 'compass';
const _kImpactFocus = 'impactFocus';

T _enumByName<T extends Enum>(List<T> values, String? name, T fallback) {
  for (final v in values) {
    if (v.name == name) return v;
  }
  return fallback;
}

/// User preferences, persisted via SharedPreferences.
class SettingsNotifier extends Notifier<Settings> {
  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  Settings build() => Settings(
        newestAtBottom: _prefs.getBool(_kNewestAtBottom) ??
            Settings.defaults.newestAtBottom,
        languageTag:
            _prefs.getString(_kLanguageTag) ?? Settings.defaults.languageTag,
        compass: _enumByName(
            Compass.values, _prefs.getString(_kCompass), Compass.auto),
        impactFocus: _enumByName(ImpactFocus.values,
            _prefs.getString(_kImpactFocus), ImpactFocus.both),
      );

  void setNewestAtBottom(bool value) {
    _prefs.setBool(_kNewestAtBottom, value);
    state = state.copyWith(newestAtBottom: value);
  }

  void setLanguageTag(String tag) {
    _prefs.setString(_kLanguageTag, tag);
    state = state.copyWith(languageTag: tag);
  }

  void setCompass(Compass compass) {
    _prefs.setString(_kCompass, compass.name);
    state = state.copyWith(compass: compass);
  }

  void setImpactFocus(ImpactFocus focus) {
    _prefs.setString(_kImpactFocus, focus.name);
    state = state.copyWith(impactFocus: focus);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, Settings>(
  SettingsNotifier.new,
);
