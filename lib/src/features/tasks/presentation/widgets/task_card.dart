import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/time/relative_time.dart';
import '../../domain/task.dart';

/// Card for a task in tab 1. Cosmetic layer: reflects the score
/// (via its position in the list), does not determine it.
///
/// On completion, plays an animation (check turns green + strikethrough drawn
/// left→right, then the card slides out to the left) BEFORE calling
/// [onComplete] — so the row isn't yanked from the stream mid-animation.
class TaskCard extends StatefulWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.score,
    this.showScore = true,
    this.onComplete,
    this.onTap,
  });

  final Task task;
  final double score;

  /// The score pill helps tune k/τ on the Actions tab; hidden elsewhere
  /// (e.g. the calendar day list).
  final bool showScore;
  final VoidCallback? onComplete;
  final VoidCallback? onTap;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) widget.onComplete?.call();
      });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _startComplete() {
    if (!_c.isAnimating && !_c.isCompleted) _c.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = _subtitle(AppLocalizations.of(context), widget.task);
    final task = widget.task;

    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = _c.value;
        // Phase 1 (0..0.55 ≈ 0.5 s): check greens + strikethrough draws.
        final greenT = (t / 0.55).clamp(0.0, 1.0);
        final strike = (t / 0.55).clamp(0.0, 1.0);
        // Phase 2 (0.55..1): slide out to the left + fade.
        final exit = ((t - 0.55) / 0.45).clamp(0.0, 1.0);
        final width = MediaQuery.sizeOf(context).width;

        return Opacity(
          opacity: 1 - exit,
          child: Transform.translate(
            offset: Offset(-exit * width * 1.1, 0),
            child: _cardBody(theme, subtitle, task, greenT, strike),
          ),
        );
      },
    );
  }

  Widget _cardBody(
    ThemeData theme,
    ({String text, bool isLate}) subtitle,
    Task task,
    double greenT,
    double strike,
  ) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _c.isAnimating ? null : widget.onTap,
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
                    _Strikeable(
                      progress: strike,
                      child: Text(
                        task.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.15,
                        ),
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
              if (widget.showScore) _ScorePill(score: widget.score),
              IconButton(
                tooltip: AppLocalizations.of(context).taskComplete,
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  greenT > 0.5
                      ? Icons.check_circle
                      : Icons.check_circle_outline,
                ),
                color: Color.lerp(
                  theme.colorScheme.onSurfaceVariant,
                  AppColors.green,
                  greenT,
                ),
                onPressed: _startComplete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Draws a strikethrough over [child], growing left→right with [progress].
class _Strikeable extends StatelessWidget {
  const _Strikeable({required this.progress, required this.child});
  final double progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (progress <= 0) return child;
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress,
              child: Center(
                child: Container(height: 2, color: AppColors.green),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Subtitle: due date if set, + desire if set. Nothing for a task
/// without a date (creation age stays internal to the score). `isLate` = overdue.
({String text, bool isLate}) _subtitle(AppLocalizations l, Task task) {
  final parts = <String>[];
  var isLate = false;
  final due = task.dueAt;
  if (due != null) {
    // Single instant for both the label and the overdue flag.
    final now = DateTime.now();
    parts.add(humanRelative(l, due, now));
    isLate = due.isBefore(now);
  }
  if (task.desire != null) {
    parts.add(l.desireShort((task.desire! * 9 + 1).round()));
  }
  return (text: parts.join(' · '), isLate: isLate);
}

/// Priority badge: tinted rounded square + number in the color.
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

/// Small discreet score display — helps with tuning k/τ.
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
