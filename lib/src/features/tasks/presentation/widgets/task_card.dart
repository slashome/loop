import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/time/relative_time.dart';
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
    final subtitle = _subtitle(task);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
          child: Row(
            children: [
              _PriorityBadge(priority: task.priority),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.15,
                      ),
                    ),
                    if (subtitle.text.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle.text,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: subtitle.isLate
                              ? theme.colorScheme.error
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: subtitle.isLate ? FontWeight.w600 : null,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _ScorePill(score: score),
              IconButton(
                tooltip: 'Terminer',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.check_circle_outline),
                color: theme.colorScheme.onSurfaceVariant,
                onPressed: onComplete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sous-titre : échéance si définie, + envie si réglée. Rien pour une tâche
/// sans date (l'âge de création reste interne au score). `isLate` = en retard.
({String text, bool isLate}) _subtitle(Task task) {
  final parts = <String>[];
  var isLate = false;
  final due = task.dueAt;
  if (due != null) {
    parts.add(humanRelative(due, DateTime.now()));
    isLate = due.isBefore(DateTime.now());
  }
  if (task.envie != null) {
    parts.add('envie ${(task.envie! * 9 + 1).round()}/10');
  }
  return (text: parts.join(' · '), isLate: isLate);
}

/// Pastille de priorité : carré arrondi teinté + numéro dans la couleur.
class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});
  final int priority;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.priority[priority] ?? AppColors.priority[3]!;
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'P$priority',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
  }
}

/// Petit affichage discret du score — aide au réglage de k/τ.
class _ScorePill extends StatelessWidget {
  const _ScorePill({required this.score});
  final double score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      score.toStringAsFixed(2),
      style: theme.textTheme.labelSmall?.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
