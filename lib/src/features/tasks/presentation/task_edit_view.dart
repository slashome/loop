import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  const TaskEditView({super.key, required this.taskId});
  final String taskId;

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

  @override
  void initState() {
    super.initState();
    final task =
        ref.read(tasksProvider).firstWhere((t) => t.id == widget.taskId);
    _title = TextEditingController(text: task.title);
    _description = TextEditingController(text: task.description ?? '');
    _priority = task.priority;
    _envie = task.envie;
    _impactSelf = task.impactSelf;
    _impactOthers = task.impactOthers;
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
    ref.read(tasksProvider.notifier).applyEdit(
          widget.taskId,
          title: title,
          description: desc.isEmpty ? null : desc,
          priority: _priority,
          envie: _envie,
          impactSelf: _impactSelf,
          impactOthers: _impactOthers,
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tasks = ref.watch(tasksProvider);
    final caps = ref.watch(priorityCapsProvider);

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
          const SizedBox(height: 24),
          Text('Priorité', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          _PrioritySelector(
            selected: _priority,
            caps: caps,
            tasks: tasks,
            taskId: widget.taskId,
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
