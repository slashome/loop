import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../profiles/application/profiles_providers.dart';
import '../../profiles/domain/profile.dart';
import '../../tasks/application/tasks_providers.dart';
import '../application/settings_providers.dart';

/// User settings screen. Will also host the score's k/τ/caps.
class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final profiles = ref.watch(profilesProvider).value ?? const <Profile>[];

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        children: [
          _SectionTitle(l.settingsProfiles),
          for (final p in profiles)
            ListTile(
              leading: Icon(
                p.id == settings.currentProfileId
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: p.id == settings.currentProfileId
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              title: Text(p.name.isEmpty ? l.profileDefaultName : p.name),
              trailing: IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: l.profileRenameTitle,
                onPressed: () => _renameDialog(context, ref, p),
              ),
              onTap: () => _switchProfile(ref, p.id),
            ),
          ListTile(
            leading: const Icon(Icons.add),
            title: Text(l.profileAdd),
            onTap: () => _addDialog(context, ref),
          ),
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

  Future<void> _switchProfile(WidgetRef ref, String id) async {
    ref.read(settingsProvider.notifier).setCurrentProfileId(id);
    // Materialize/clean the newly active profile's occurrences.
    await ref.read(taskRepositoryProvider).bootstrap();
  }

  Future<void> _addDialog(BuildContext context, WidgetRef ref) async {
    final name = await _nameDialog(
      context,
      AppLocalizations.of(context).profileNewTitle,
    );
    if (name == null || name.trim().isEmpty) return;
    final id = await ref.read(profileRepositoryProvider).create(name);
    await _switchProfile(ref, id);
  }

  Future<void> _renameDialog(
    BuildContext context,
    WidgetRef ref,
    Profile p,
  ) async {
    final name = await _nameDialog(
      context,
      AppLocalizations.of(context).profileRenameTitle,
      initial: p.name,
    );
    if (name == null || name.trim().isEmpty) return;
    await ref.read(profileRepositoryProvider).rename(p.id, name);
  }

  Future<String?> _nameDialog(
    BuildContext context,
    String title, {
    String initial = '',
  }) {
    final l = AppLocalizations.of(context);
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l.profileNameHint),
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (v) => Navigator.of(ctx).pop(v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: Text(l.commonOk),
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
