import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../application/settings_providers.dart';

/// User settings screen. Will also host the score's k/τ/caps.
class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        children: [
          _SectionTitle(l.settingsDisplay),
          SwitchListTile(
            title: Text(l.newestAtBottomTitle),
            subtitle: Text(l.newestAtBottomSubtitle),
            value: settings.newestAtBottom,
            onChanged: notifier.setNewestAtBottom,
          ),
          _SectionTitle(l.settingsLanguage),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'system', label: Text(l.languageSystem)),
                ButtonSegment(value: 'fr', label: Text(l.languageFrench)),
                ButtonSegment(value: 'en', label: Text(l.languageEnglish)),
              ],
              selected: {settings.languageTag},
              onSelectionChanged: (s) => notifier.setLanguageTag(s.first),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
