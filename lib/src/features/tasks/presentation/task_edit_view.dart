import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../recurrences/application/recurrences_providers.dart';
import '../../recurrences/domain/recurrence.dart';
import '../../recurrences/presentation/recurrence_edit_view.dart';
import '../application/tasks_providers.dart';
import '../data/task_repository.dart' show PriorityCapExceeded;
import '../domain/scoring.dart';
import '../domain/task.dart';

/// Slider conversion 1..10 (UI) <-> 0..1 storage. 1 → 0.0, 10 → 1.0.
double? _fromUi(double? ui) => ui == null ? null : (ui - 1) / 9;
double _toUi(double v01) => v01 * 9 + 1;

/// Editing (or creating, if [task] is null) a task.
class TaskEditView extends ConsumerStatefulWidget {
  const TaskEditView({super.key, this.task});
  final Task? task;

  @override
  ConsumerState<TaskEditView> createState() => _TaskEditViewState();
}

class _TaskEditViewState extends ConsumerState<TaskEditView> {
  late final TextEditingController _title;
  late final TextEditingController _description;
  late int _priority;
  double? _desire; // 0..1
  double? _impactSelf;
  double? _impactOthers;
  DateTime? _dueAt;

  bool get _isNew => widget.task == null;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _title = TextEditingController(text: task?.title ?? '');
    _description = TextEditingController(text: task?.description ?? '');
    _priority = task?.priority ?? 3;
    _desire = task?.desire;
    _impactSelf = task?.impactSelf;
    _impactOthers = task?.impactOthers;
    _dueAt = task?.dueAt;
  }

  Future<void> _pickDueAt() async {
    final now = DateTime.now();
    final base = _dueAt ?? now;
    final firstDate = DateTime(now.year - 1);
    final lastDate = DateTime(now.year + 5);
    // Clamp: an out-of-range initialDate (e.g. a task overdue for more than a
    // year) would trip showDatePicker's assertion.
    final initial = base.isBefore(firstDate)
        ? firstDate
        : (base.isAfter(lastDate) ? lastDate : base);
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (!mounted) return;
    setState(() {
      _dueAt = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? 0,
        time?.minute ?? 0,
      );
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final title = _title.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.titleRequired)),
      );
      return;
    }
    final desc = _description.text.trim();
    final repo = ref.read(taskRepositoryProvider);
    final task = widget.task;
    try {
      if (task == null) {
        await repo.create(
          title: title,
          description: desc.isEmpty ? null : desc,
          priority: _priority,
          desire: _desire,
          impactSelf: _impactSelf,
          impactOthers: _impactOthers,
          dueAt: _dueAt,
        );
      } else {
        await repo.applyEdit(
          task.id,
          title: title,
          description: desc.isEmpty ? null : desc,
          priority: _priority,
          desire: _desire,
          impactSelf: _impactSelf,
          impactOthers: _impactOthers,
          dueAt: _dueAt,
        );
      }
    } on PriorityCapExceeded catch (e) {
      // Backstop: the UI disables full bands, but the repository is the gate.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.priorityFull(e.priority))),
        );
      }
      return;
    }
    if (mounted) Navigator.of(context).pop();
  }

  /// Turns the one-off task into a recurrence (opens the pre-filled editor).
  /// If the conversion succeeds, the original task was deleted: we close.
  Future<void> _convertToRecurrence() async {
    final converted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RecurrenceEditView(convertFromTask: widget.task),
      ),
    );
    if (converted == true && mounted) Navigator.of(context).pop();
  }

  Recurrence? _recurrenceFor(String? id) {
    if (id == null) return null;
    final recs = ref.watch(recurrencesProvider).value ?? const [];
    for (final r in recs) {
      if (r.id == id) return r;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final tasks = ref.watch(tasksProvider).value ?? const <Task>[];
    final caps = ref.watch(priorityCapsProvider);

    // Source recurrence, if this task is an occurrence (final -> promotion
    // OK even when captured in the onTap closure).
    final recurrence = _recurrenceFor(widget.task?.recurrenceId);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? l.taskEditNewTitle : l.taskEditEditTitle),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(l.commonSave),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (recurrence != null) ...[
            Card(
              color: theme.colorScheme.secondaryContainer,
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                leading: const Icon(Icons.repeat),
                title: Text(l.taskOccurrenceOf(recurrence.title)),
                subtitle: Text(l.taskEditRecurrence),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => RecurrenceEditView(recurrence: recurrence),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
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
            minLines: 2,
            maxLines: 6,
            decoration: InputDecoration(
              labelText: l.commonDescriptionOptional,
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          _DueAtTile(
            dueAt: _dueAt,
            onPick: _pickDueAt,
            onClear: () => setState(() => _dueAt = null),
          ),
          const SizedBox(height: 24),
          Text(l.commonPriority, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          _PrioritySelector(
            selected: _priority,
            caps: caps,
            tasks: tasks,
            taskId: widget.task?.id ?? '',
            onChanged: (p) => setState(() => _priority = p),
          ),
          const SizedBox(height: 24),
          _TenPointSlider(
            label: l.taskDesire,
            value01: _desire,
            onChanged: (v) => setState(() => _desire = v),
          ),
          const SizedBox(height: 8),
          _TenPointSlider(
            label: l.taskImpactSelf,
            value01: _impactSelf,
            onChanged: (v) => setState(() => _impactSelf = v),
          ),
          const SizedBox(height: 8),
          _TenPointSlider(
            label: l.taskImpactOthers,
            value01: _impactOthers,
            onChanged: (v) => setState(() => _impactOthers = v),
          ),
          if (!_isNew && widget.task!.recurrenceId == null) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _convertToRecurrence,
              icon: const Icon(Icons.repeat),
              label: Text(l.taskRepeatThis),
            ),
          ],
        ],
      ),
    );
  }
}

/// Priority selector P1..P5. A full tier (cap reached) is disabled, unless it
/// is the task's current tier.
class _PrioritySelector extends StatelessWidget {
  const _PrioritySelector({
    required this.selected,
    required this.caps,
    required this.tasks,
    required this.taskId,
    required this.onChanged,
  });

  final int selected;
  final PriorityCaps caps;
  final List<Task> tasks;
  final String taskId;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        for (var p = 1; p <= 5; p++) _priorityChip(context, p),
      ],
    );
  }

  Widget _priorityChip(BuildContext context, int p) {
    final l = AppLocalizations.of(context);
    final color = AppColors.priority[p]!;
    final isSelected = p == selected;
    // Room available for THIS task (itself excluded from the count).
    final canSelect = caps.canAssign(p, tasks, excludeId: taskId);
    final enabled = isSelected || canSelect;

    return ChoiceChip(
      label: Text(enabled ? l.priorityLabel(p) : l.priorityFull(p)),
      selected: isSelected,
      onSelected: enabled ? (_) => onChanged(p) : null,
      selectedColor: color.withValues(alpha: 0.18),
      labelStyle: TextStyle(
        color: enabled ? color : Theme.of(context).disabledColor,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      side: BorderSide(
        color:
            isSelected ? color : Theme.of(context).colorScheme.outlineVariant,
      ),
    );
  }
}

/// "Due" row: shows the date/time or "none", lets the user pick or clear it.
class _DueAtTile extends StatelessWidget {
  const _DueAtTile({
    required this.dueAt,
    required this.onPick,
    required this.onClear,
  });

  final DateTime? dueAt;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    return OutlinedButton.icon(
      onPressed: onPick,
      icon: const Icon(Icons.event_outlined),
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      label: Row(
        children: [
          Expanded(
            child: Text(
              dueAt == null
                  ? l.taskDueNone
                  : l.taskDueOn(
                      DateFormat.yMd(l.localeName).add_Hm().format(dueAt!),
                    ),
            ),
          ),
          if (dueAt != null)
            GestureDetector(
              onTap: onClear,
              child: const Icon(Icons.close, size: 18),
            ),
        ],
      ),
    );
  }
}

/// Nullable 1..10 slider. Button to clear (back to "not set").
class _TenPointSlider extends StatelessWidget {
  const _TenPointSlider({
    required this.label,
    required this.value01,
    required this.onChanged,
  });

  final String label;
  final double? value01; // 0..1 or null
  final ValueChanged<double?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final isSet = value01 != null;
    final uiValue = isSet ? _toUi(value01!) : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: theme.textTheme.titleSmall),
            const Spacer(),
            Text(
              isSet ? '${uiValue.round()}/10' : l.commonNotSet,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (isSet)
              IconButton(
                tooltip: l.commonClear,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => onChanged(null),
              ),
          ],
        ),
        Slider(
          value: uiValue,
          min: 1,
          max: 10,
          divisions: 9,
          label: uiValue.round().toString(),
          onChanged: (v) => onChanged(_fromUi(v)),
        ),
      ],
    );
  }
}
