import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/theme/brand_fab.dart';
import '../../settings/application/settings_providers.dart';
import '../../settings/presentation/settings_view.dart';
import '../application/tasks_providers.dart';
import '../domain/compass.dart';
import '../domain/task.dart';
import '../domain/task_filters.dart';
import 'task_edit_view.dart';
import 'widgets/task_card.dart';

String _viewLabel(AppLocalizations l, TaskView v) => switch (v) {
      TaskView.todo => l.viewTodo,
      TaskView.overdue => l.viewOverdue,
      TaskView.upcoming => l.viewUpcoming,
      TaskView.undated => l.viewUndated,
    };

/// Tab 1 — Next actions. Heart of the app: the list sorted by score.
class NextActionsView extends ConsumerWidget {
  const NextActionsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(nextActionsProvider);
    final newestAtBottom = ref.watch(
      settingsProvider.select((s) => s.newestAtBottom),
    );

    return Scaffold(
      appBar: AppBar(
        title: const _BrandTitle(),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: l.settingsTooltip,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsView()),
            ),
          ),
        ],
      ),
      floatingActionButton: BrandFab(
        tooltip: l.newTaskTooltip,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const TaskEditView()),
        ),
      ),
      // View selector placed AT THE BOTTOM: reachable with the thumb one-handed.
      bottomNavigationBar: const _ViewBar(),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l.commonError(e.toString()))),
        data: (list) {
          if (list.visible.isEmpty && list.folded.isEmpty) {
            return _EmptyState(message: l.emptyList);
          }
          final compass = ref.watch(settingsProvider.select((s) => s.compass));
          Widget card(ScoredTask s) => TaskCard(
                key: ValueKey(s.task.id),
                task: s.task,
                score: s.score,
                onComplete: () =>
                    ref.read(taskRepositoryProvider).complete(s.task.id),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => TaskEditView(task: s.task),
                  ),
                ),
              );
          final children = <Widget>[
            for (final s in list.visible) card(s),
            if (list.folded.isNotEmpty)
              _FoldedSection(
                compass: compass,
                folded: list.folded,
                cardBuilder: card,
              ),
          ];
          return Column(
            children: [
              const _CompassBar(),
              Expanded(
                child: ListView(
                  // Bottom anchoring (best score near the thumb) or top
                  // (classic). The folded section, appended last, ends up at
                  // the far end from the thumb in both cases.
                  reverse: newestAtBottom,
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  children: children,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: 0.9,
            child: Image.asset('assets/branding/logo_tight.png', width: 140),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

/// Compass selector (Étage 2): Auto / Desire / Impact, plus a Me/Others/Both
/// sub-toggle in Impact mode. Persisted via settings.
class _CompassBar extends ConsumerWidget {
  const _CompassBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final compass = ref.watch(settingsProvider.select((s) => s.compass));
    final focus = ref.watch(settingsProvider.select((s) => s.impactFocus));
    final notifier = ref.read(settingsProvider.notifier);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Column(
        children: [
          SegmentedButton<Compass>(
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
            segments: [
              ButtonSegment(value: Compass.auto, label: Text(l.compassAuto)),
              ButtonSegment(
                  value: Compass.desire, label: Text(l.compassDesire)),
              ButtonSegment(
                  value: Compass.impact, label: Text(l.compassImpact)),
            ],
            selected: {compass},
            showSelectedIcon: false,
            onSelectionChanged: (s) => notifier.setCompass(s.first),
          ),
          if (compass == Compass.impact) ...[
            const SizedBox(height: 6),
            SegmentedButton<ImpactFocus>(
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
              segments: [
                ButtonSegment(
                    value: ImpactFocus.self, label: Text(l.impactFocusSelf)),
                ButtonSegment(
                    value: ImpactFocus.others,
                    label: Text(l.impactFocusOthers)),
                ButtonSegment(
                    value: ImpactFocus.both, label: Text(l.impactFocusBoth)),
              ],
              selected: {focus},
              showSelectedIcon: false,
              onSelectionChanged: (s) => notifier.setImpactFocus(s.first),
            ),
          ],
        ],
      ),
    );
  }
}

/// Collapsible section for the low-desire / low-impact tasks tucked away by
/// the active compass. Collapsed by default; a tap reveals them.
class _FoldedSection extends StatefulWidget {
  const _FoldedSection({
    required this.compass,
    required this.folded,
    required this.cardBuilder,
  });

  final Compass compass;
  final List<ScoredTask> folded;
  final Widget Function(ScoredTask) cardBuilder;

  @override
  State<_FoldedSection> createState() => _FoldedSectionState();
}

class _FoldedSectionState extends State<_FoldedSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final label = widget.compass == Compass.impact
        ? l.foldedLowImpact(widget.folded.length)
        : l.foldedNeedsEnergy(widget.folded.length);

    return Column(
      children: [
        const SizedBox(height: 4),
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          for (final s in widget.folded)
            Opacity(opacity: 0.7, child: widget.cardBuilder(s)),
      ],
    );
  }
}

/// Brand title: the ∞ symbol from the logo, centered (no text).
class _BrandTitle extends StatelessWidget {
  const _BrandTitle();

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/branding/logo_mark.png', height: 30);
  }
}

/// View selector (Smart Lists) at the bottom of the screen: single-select chips
/// with counters, reachable with the thumb.
class _ViewBar extends ConsumerWidget {
  const _ViewBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final view = ref.watch(viewProvider);
    final tasks = ref.watch(tasksProvider).value ?? const <Task>[];
    // Same instant as the sorted list: counters can never contradict it.
    final now = ref.watch(nowProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: 1, color: theme.colorScheme.outlineVariant),
        if (view == TaskView.todo)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            child: Text(
              l.todoHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            // right margin so it does not slip under the FAB.
            padding: const EdgeInsets.fromLTRB(16, 8, 88, 8),
            children: [
              for (final v in TaskView.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      '${_viewLabel(l, v)} (${tasksForView(tasks, v, now).length})',
                    ),
                    selected: view == v,
                    showCheckmark: false,
                    onSelected: (_) =>
                        ref.read(viewProvider.notifier).select(v),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
