import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/time/relative_time.dart';
import '../../tasks/application/tasks_providers.dart';
import '../../tasks/domain/task.dart';
import '../application/recurrences_providers.dart';
import '../domain/recurrence.dart';

/// Short weekday labels, localized (index 0 = Monday = weekday 1).
List<String> weekdayLabels(AppLocalizations l) => [
      l.weekdayMon,
      l.weekdayTue,
      l.weekdayWed,
      l.weekdayThu,
      l.weekdayFri,
      l.weekdaySat,
      l.weekdaySun,
    ];

/// Recurrence editor.
/// - non-null [recurrence] → editing an existing recurrence;
/// - non-null [convertFromTask] → pre-filled creation from a task, which will
///   be deleted on save (task → recurrence conversion);
/// - both null → blank creation.
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

  String? _validate(AppLocalizations l) {
    if (_title.text.trim().isEmpty) return l.titleRequired;
    if (_hours.isEmpty) return l.recurrencePickHour;
    if (_freq == RecurrenceFreq.weekly && _weekdays.isEmpty) {
      return l.recurrencePickWeekday;
    }
    if (_freq == RecurrenceFreq.monthly && _monthDays.isEmpty) {
      return l.recurrencePickMonthDay;
    }
    return null;
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final error = _validate(l);
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
    // Conversion: the original one-off task is removed.
    final convertId = widget.convertFromTask?.id;
    if (convertId != null) {
      await ref.read(taskRepositoryProvider).softDelete(convertId);
    }
    // Realign today's occurrences with the new definition.
    await ref.read(taskRepositoryProvider).generateOccurrences(on: now);
    if (!mounted) return;
    if (convertId != null) {
      // Explain where the task went (it only shows up in Actions on the days
      // the recurrence falls on).
      final next = rec.nextOccurrenceFrom(now);
      final suffix = next == null
          ? ''
          : l.recurrenceNextSuffix(humanRelative(l, next, now));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.recurrenceNowRecurring(rec.title, suffix)),
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
    final l = AppLocalizations.of(context);
    final weekdays = weekdayLabels(l);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? l.recurrenceNewTitle : l.recurrenceEditTitle),
        actions: [
          if (!_isNew)
            IconButton(
              tooltip: l.commonDelete,
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
          TextButton(onPressed: _save, child: Text(l.commonSave)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _title,
            decoration: InputDecoration(
              labelText: l.commonTitle,
              border: const OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _description,
            minLines: 1,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: l.commonDescriptionOptional,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Text(l.recurrenceFrequency, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<RecurrenceFreq>(
            segments: [
              ButtonSegment(
                  value: RecurrenceFreq.daily,
                  label: Text(l.recurrenceFreqDaily)),
              ButtonSegment(
                  value: RecurrenceFreq.weekly,
                  label: Text(l.recurrenceFreqWeekly)),
              ButtonSegment(
                  value: RecurrenceFreq.monthly,
                  label: Text(l.recurrenceFreqMonthly)),
            ],
            selected: {_freq},
            onSelectionChanged: (s) => setState(() => _freq = s.first),
          ),
          if (_freq == RecurrenceFreq.weekly) ...[
            const SizedBox(height: 24),
            Text(l.recurrenceWeekdays, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            _ChipMultiSelect(
              values: {for (var i = 1; i <= 7; i++) i: weekdays[i - 1]},
              selected: _weekdays,
              onToggle: (v) => setState(() => _toggle(_weekdays, v)),
            ),
          ],
          if (_freq == RecurrenceFreq.monthly) ...[
            const SizedBox(height: 24),
            Text(l.recurrenceMonthDays, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            _ChipMultiSelect(
              values: {for (var i = 1; i <= 31; i++) i: '$i'},
              selected: _monthDays,
              onToggle: (v) => setState(() => _toggle(_monthDays, v)),
            ),
          ],
          const SizedBox(height: 24),
          Text(l.recurrenceHours, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          _ChipMultiSelect(
            values: {for (var h = 0; h < 24; h++) h: l.hourShort(h)},
            selected: _hours,
            onToggle: (v) => setState(() => _toggle(_hours, v)),
          ),
          const SizedBox(height: 24),
          Text(l.recurrenceDefaultPriority, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          _ChipMultiSelect(
            values: {for (var p = 1; p <= 5; p++) p: l.priorityLabel(p)},
            selected: {_priority},
            onToggle: (v) => setState(() => _priority = v),
            single: true,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.recurrenceActive),
            subtitle: Text(l.recurrenceActiveSubtitle),
            value: _active,
            onChanged: (v) => setState(() => _active = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.recurrenceAutoClean),
            subtitle: Text(l.recurrenceAutoCleanSubtitle),
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

/// Multi- (or single-) select chip grid.
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
