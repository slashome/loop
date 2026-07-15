import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/time/relative_time.dart';
import '../../tasks/application/tasks_providers.dart';
import '../../tasks/domain/task.dart';
import '../application/recurrences_providers.dart';
import '../domain/recurrence.dart';

/// Libellés courts des jours de semaine (index 0 = lundi = weekday 1).
const List<String> kWeekdayLabels = [
  'Lun',
  'Mar',
  'Mer',
  'Jeu',
  'Ven',
  'Sam',
  'Dim'
];

/// Éditeur de récurrence.
/// - [recurrence] non nul → édition d'une récurrence existante ;
/// - [convertFromTask] non nul → création pré-remplie depuis une tâche, qui
///   sera supprimée à l'enregistrement (conversion tâche → récurrence) ;
/// - les deux nuls → création vierge.
class RecurrenceEditView extends ConsumerStatefulWidget {
  const RecurrenceEditView({
    super.key,
    this.recurrence,
    this.convertFromTask,
  });
  final Recurrence? recurrence;
  final Task? convertFromTask;

  @override
  ConsumerState<RecurrenceEditView> createState() => _RecurrenceEditViewState();
}

class _RecurrenceEditViewState extends ConsumerState<RecurrenceEditView> {
  late final TextEditingController _title;
  late final TextEditingController _description;
  late RecurrenceFreq _freq;
  late Set<int> _weekdays; // 1..7
  late Set<int> _monthDays; // 1..31
  late Set<int> _hours; // 0..23
  late int _priority;
  late bool _active;
  late bool _autoCleanMissed;

  bool get _isNew => widget.recurrence == null;

  @override
  void initState() {
    super.initState();
    final r = widget.recurrence;
    final t = widget.convertFromTask;
    _title = TextEditingController(text: r?.title ?? t?.title ?? '');
    _description =
        TextEditingController(text: r?.description ?? t?.description ?? '');
    _freq = r?.freq ?? RecurrenceFreq.daily;
    _weekdays = {...?r?.byWeekdays};
    _monthDays = {...?r?.byMonthDays};
    _hours = {...?r?.byHours}.isEmpty ? {9} : {...?r?.byHours};
    _priority = r?.defPriority ?? t?.priority ?? 3;
    _active = r?.active ?? true;
    _autoCleanMissed = r?.autoCleanMissed ?? true;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  String? _validate() {
    if (_title.text.trim().isEmpty) return 'Le titre est obligatoire.';
    if (_hours.isEmpty) return 'Choisis au moins une heure.';
    if (_freq == RecurrenceFreq.weekly && _weekdays.isEmpty) {
      return 'Choisis au moins un jour de la semaine.';
    }
    if (_freq == RecurrenceFreq.monthly && _monthDays.isEmpty) {
      return 'Choisis au moins un jour du mois.';
    }
    return null;
  }

  Future<void> _save() async {
    final error = _validate();
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    final now = DateTime.now();
    final existing = widget.recurrence;
    final desc = _description.text.trim();
    final rec = Recurrence(
      id: existing?.id ?? const Uuid().v4(),
      ownerId: existing?.ownerId ?? 'local',
      title: _title.text.trim(),
      description: desc.isEmpty ? null : desc,
      freq: _freq,
      byWeekdays: (_sorted(_weekdays)),
      byMonthDays: _sorted(_monthDays),
      byHours: _sorted(_hours),
      defPriority: _priority,
      active: _active,
      autoCleanMissed: _autoCleanMissed,
      dtstart: existing?.dtstart ?? now,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    await ref.read(recurrenceRepositoryProvider).save(rec);
    // Conversion : la tâche ponctuelle d'origine est retirée.
    final convertId = widget.convertFromTask?.id;
    if (convertId != null) {
      await ref.read(taskRepositoryProvider).softDelete(convertId);
    }
    // Réaligne les occurrences du jour sur la nouvelle définition.
    await ref.read(taskRepositoryProvider).generateOccurrences(on: now);
    if (!mounted) return;
    if (convertId != null) {
      // Explique où la tâche est passée (elle n'apparaît dans Actions que les
      // jours où la récurrence tombe).
      final next = rec.nextOccurrenceFrom(now);
      final suffix =
          next == null ? '' : ' · prochaine : ${humanRelative(next, now)}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('« ${rec.title} » est maintenant récurrente$suffix'),
        ),
      );
    }
    Navigator.of(context).pop(convertId != null);
  }

  Future<void> _delete() async {
    final r = widget.recurrence;
    if (r == null) return;
    await ref.read(recurrenceRepositoryProvider).delete(r.id);
    if (mounted) Navigator.of(context).pop();
  }

  List<int> _sorted(Set<int> s) => s.toList()..sort();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'Nouvelle récurrence' : 'Modifier la récurrence'),
        actions: [
          if (!_isNew)
            IconButton(
              tooltip: 'Supprimer',
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
          TextButton(onPressed: _save, child: const Text('Enregistrer')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _title,
            decoration: const InputDecoration(
              labelText: 'Titre',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _description,
            minLines: 1,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Description (optionnel)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Text('Fréquence', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<RecurrenceFreq>(
            segments: const [
              ButtonSegment(
                  value: RecurrenceFreq.daily, label: Text('Chaque jour')),
              ButtonSegment(
                  value: RecurrenceFreq.weekly, label: Text('Semaine')),
              ButtonSegment(value: RecurrenceFreq.monthly, label: Text('Mois')),
            ],
            selected: {_freq},
            onSelectionChanged: (s) => setState(() => _freq = s.first),
          ),
          if (_freq == RecurrenceFreq.weekly) ...[
            const SizedBox(height: 24),
            Text('Jours de la semaine', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            _ChipMultiSelect(
              values: {for (var i = 1; i <= 7; i++) i: kWeekdayLabels[i - 1]},
              selected: _weekdays,
              onToggle: (v) => setState(() => _toggle(_weekdays, v)),
            ),
          ],
          if (_freq == RecurrenceFreq.monthly) ...[
            const SizedBox(height: 24),
            Text('Jours du mois', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            _ChipMultiSelect(
              values: {for (var i = 1; i <= 31; i++) i: '$i'},
              selected: _monthDays,
              onToggle: (v) => setState(() => _toggle(_monthDays, v)),
            ),
          ],
          const SizedBox(height: 24),
          Text('Heures', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          _ChipMultiSelect(
            values: {for (var h = 0; h < 24; h++) h: '${h}h'},
            selected: _hours,
            onToggle: (v) => setState(() => _toggle(_hours, v)),
          ),
          const SizedBox(height: 24),
          Text('Priorité par défaut', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          _ChipMultiSelect(
            values: {for (var p = 1; p <= 5; p++) p: 'P$p'},
            selected: {_priority},
            onToggle: (v) => setState(() => _priority = v),
            single: true,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Active'),
            subtitle: const Text('Génère des occurrences dans Actions'),
            value: _active,
            onChanged: (v) => setState(() => _active = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Nettoyer les occurrences manquées'),
            subtitle: const Text(
              'Les occurrences non faites d\'avant aujourd\'hui sont retirées. '
              'Désactive pour les garder « en retard ».',
            ),
            value: _autoCleanMissed,
            onChanged: (v) => setState(() => _autoCleanMissed = v),
          ),
        ],
      ),
    );
  }

  void _toggle(Set<int> set, int v) {
    if (set.contains(v)) {
      set.remove(v);
    } else {
      set.add(v);
    }
  }
}

/// Grille de chips multi- (ou mono-) sélection.
class _ChipMultiSelect extends StatelessWidget {
  const _ChipMultiSelect({
    required this.values,
    required this.selected,
    required this.onToggle,
    this.single = false,
  });

  final Map<int, String> values;
  final Set<int> selected;
  final ValueChanged<int> onToggle;
  final bool single;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final e in values.entries)
          FilterChip(
            label: Text(e.value),
            selected: selected.contains(e.key),
            onSelected: (_) => onToggle(e.key),
            showCheckmark: !single,
          ),
      ],
    );
  }
}
