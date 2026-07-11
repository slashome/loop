import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../recurrences/application/recurrences_providers.dart';
import '../../recurrences/domain/recurrence.dart';
import '../../recurrences/presentation/recurrence_edit_view.dart';
import '../application/tasks_providers.dart';
import '../domain/scoring.dart';
import '../domain/task.dart';

/// Palette priorité — cohérente avec la pastille de la carte.
const Map<int, Color> kPriorityColors = {
  5: Color(0xFFE5484D),
  4: Color(0xFFF76B15),
  3: Color(0xFF3B82C4),
  2: Color(0xFF46A758),
  1: Color(0xFF8B8D98),
};

/// Conversion slider 1..10 (UI) <-> stockage 0..1. 1 → 0.0, 10 → 1.0.
double? _fromUi(double? ui) => ui == null ? null : (ui - 1) / 9;
double _toUi(double v01) => v01 * 9 + 1;

/// Écran d'édition d'une tâche : priorité (avec caps) + envie + impacts.
class TaskEditView extends ConsumerStatefulWidget {
  const TaskEditView({super.key, required this.task});
  final Task task;

  @override
  ConsumerState<TaskEditView> createState() => _TaskEditViewState();
}

class _TaskEditViewState extends ConsumerState<TaskEditView> {
  late final TextEditingController _title;
  late final TextEditingController _description;
  late int _priority;
  double? _envie; // 0..1
  double? _impactSelf;
  double? _impactOthers;
  DateTime? _dueAt;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _title = TextEditingController(text: task.title);
    _description = TextEditingController(text: task.description ?? '');
    _priority = task.priority;
    _envie = task.envie;
    _impactSelf = task.impactSelf;
    _impactOthers = task.impactOthers;
    _dueAt = task.dueAt;
  }

  Future<void> _pickDueAt() async {
    final now = DateTime.now();
    final base = _dueAt ?? now;
    final date = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
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

  void _save() {
    final title = _title.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le titre est obligatoire.')),
      );
      return;
    }
    final desc = _description.text.trim();
    ref.read(taskRepositoryProvider).applyEdit(
          widget.task.id,
          title: title,
          description: desc.isEmpty ? null : desc,
          priority: _priority,
          envie: _envie,
          impactSelf: _impactSelf,
          impactOthers: _impactOthers,
          dueAt: _dueAt,
        );
    Navigator.of(context).pop();
  }

  /// Transforme la tâche ponctuelle en récurrence (ouvre l'éditeur pré-rempli).
  /// Si la conversion aboutit, la tâche d'origine a été supprimée : on ferme.
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
    final recs = ref.watch(recurrencesProvider).valueOrNull ?? const [];
    for (final r in recs) {
      if (r.id == id) return r;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tasks = ref.watch(tasksProvider).valueOrNull ?? const <Task>[];
    final caps = ref.watch(priorityCapsProvider);

    // Récurrence source, si cette tâche est une occurrence (final -> promotion
    // OK même capturée dans la closure onTap).
    final recurrence = _recurrenceFor(widget.task.recurrenceId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier la tâche'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Enregistrer'),
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
                title: Text('Occurrence de « ${recurrence.title} »'),
                subtitle: const Text('Modifier la récurrence'),
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
            decoration: const InputDecoration(
              labelText: 'Titre',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _description,
            minLines: 2,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Description (optionnel)',
              border: OutlineInputBorder(),
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
          Text('Priorité', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          _PrioritySelector(
            selected: _priority,
            caps: caps,
            tasks: tasks,
            taskId: widget.task.id,
            onChanged: (p) => setState(() => _priority = p),
          ),
          const SizedBox(height: 24),
          _TenPointSlider(
            label: 'Envie',
            value01: _envie,
            onChanged: (v) => setState(() => _envie = v),
          ),
          const SizedBox(height: 8),
          _TenPointSlider(
            label: 'Impact sur moi',
            value01: _impactSelf,
            onChanged: (v) => setState(() => _impactSelf = v),
          ),
          const SizedBox(height: 8),
          _TenPointSlider(
            label: 'Impact sur les autres',
            value01: _impactOthers,
            onChanged: (v) => setState(() => _impactOthers = v),
          ),
          if (widget.task.recurrenceId == null) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _convertToRecurrence,
              icon: const Icon(Icons.repeat),
              label: const Text('Répéter cette tâche…'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Sélecteur de priorité P1..P5. Un palier plein (cap atteint) est désactivé,
/// sauf s'il s'agit du palier courant de la tâche.
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
    final color = kPriorityColors[p]!;
    final isSelected = p == selected;
    // Place dispo pour CETTE tâche (elle-même exclue du décompte).
    final canSelect = caps.canAssign(p, tasks, excludeId: taskId);
    final enabled = isSelected || canSelect;

    return ChoiceChip(
      label: Text(enabled ? 'P$p' : 'P$p (complet)'),
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

/// Ligne « Échéance » : affiche la date/heure ou « aucune », permet de la
/// choisir ou de l'effacer.
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
                  ? 'Échéance : aucune'
                  : 'Échéance : ${_fmt(dueAt!)}',
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

  static String _fmt(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }
}

/// Slider 1..10 nullable. Bouton pour effacer (repasser à « non défini »).
class _TenPointSlider extends StatelessWidget {
  const _TenPointSlider({
    required this.label,
    required this.value01,
    required this.onChanged,
  });

  final String label;
  final double? value01; // 0..1 ou null
  final ValueChanged<double?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
              isSet ? '${uiValue.round()}/10' : 'non défini',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (isSet)
              IconButton(
                tooltip: 'Effacer',
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
