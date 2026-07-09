import 'package:flutter/material.dart';

import '../../domain/task.dart';

/// Carte d'une tâche dans l'onglet 1. Couche cosmétique : reflète le score
/// (via sa position dans la liste), ne le détermine pas.
class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.score,
    this.onComplete,
    this.onTap,
  });

  final Task task;
  final double score;
  final VoidCallback? onComplete;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _PriorityBadge(priority: task.priority),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      _subtitle(task),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _ScorePill(score: score),
              IconButton(
                tooltip: 'Terminer',
                icon: const Icon(Icons.check_circle_outline),
                onPressed: onComplete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sous-titre : âge, et l'envie si elle est réglée (envie stockée 0..1,
/// affichée sur 10).
String _subtitle(Task task) {
  final age = _ageLabel(task.createdAt);
  if (task.envie == null) return age;
  final envie10 = (task.envie! * 9 + 1).round();
  return '$age · envie $envie10/10';
}

/// Pastille ronde avec le numéro de priorité. Bleu/vert (marque) pour le bas,
/// tons chauds pour l'urgence haute.
class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});
  final int priority;

  static const Map<int, Color> _colors = {
    5: Color(0xFFE5484D), // rouge — urgent
    4: Color(0xFFF76B15), // orange
    3: Color(0xFF3B82C4), // bleu (marque)
    2: Color(0xFF46A758), // vert (marque)
    1: Color(0xFF8B8D98), // ardoise clair
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[priority] ?? _colors[3]!;
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        shape: BoxShape.circle,
      ),
      child: Text(
        'P$priority',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Petit affichage du score — utile pour régler k/τ pendant qu'on itère.
class _ScorePill extends StatelessWidget {
  const _ScorePill({required this.score});
  final double score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        score.toStringAsFixed(2),
        style: theme.textTheme.labelMedium?.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

String _ageLabel(DateTime createdAt) {
  final d = DateTime.now().difference(createdAt);
  if (d.inMinutes < 60) return 'il y a ${d.inMinutes} min';
  if (d.inHours < 24) return 'il y a ${d.inHours} h';
  if (d.inDays < 30) return 'il y a ${d.inDays} j';
  final months = d.inDays ~/ 30;
  return 'il y a $months mois';
}
