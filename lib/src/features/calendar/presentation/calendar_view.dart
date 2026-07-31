import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../tasks/application/tasks_providers.dart';
import '../../tasks/domain/task.dart';
import '../../tasks/presentation/task_edit_view.dart';
import '../../tasks/presentation/widgets/task_card.dart';
import '../domain/calendar.dart';

enum _CalMode { month, week }

/// Tab 3 — Calendar. Month or week grid with dots on days that have dated
/// tasks; the selected day's tasks are listed below and can be dragged onto
/// another day to reschedule.
class CalendarView extends ConsumerStatefulWidget {
  const CalendarView({super.key});

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
  _CalMode _mode = _CalMode.month;
  late DateTime _month; // first of the visible month
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = monthStart(now);
    _selected = DateTime(now.year, now.month, now.day);
  }

  void _shift(int delta) {
    setState(() {
      if (_mode == _CalMode.month) {
        _month = DateTime(_month.year, _month.month + delta);
      } else {
        _selected = DateTime(
            _selected.year, _selected.month, _selected.day + 7 * delta);
        _month = monthStart(_selected);
      }
    });
  }

  void _goToday() {
    final now = DateTime.now();
    setState(() {
      _month = monthStart(now);
      _selected = DateTime(now.year, now.month, now.day);
    });
  }

  void _select(DateTime d) {
    setState(() {
      _selected = DateTime(d.year, d.month, d.day);
      _month = monthStart(_selected);
    });
  }

  Future<void> _drop(Task task, DateTime day) async {
    await ref
        .read(taskRepositoryProvider)
        .reschedule(task.id, rescheduledDueAt(task.dueAt, day));
    if (mounted) _select(day);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tasks = ref.watch(tasksProvider).value ?? const <Task>[];
    final today = DateTime.now();

    // Normalized due-dates that carry at least one live task (cross-month safe
    // for the week view, which can span two months).
    final marked = <DateTime>{
      for (final t in tasks)
        if (t.isLive && t.dueAt != null)
          DateTime(t.dueAt!.year, t.dueAt!.month, t.dueAt!.day),
    };
    final dayTasks = tasksOnDay(tasks, _selected);
    final cells =
        _mode == _CalMode.month ? monthGrid(_month) : weekOf(_selected);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.navCalendar),
        centerTitle: false,
        actions: [
          TextButton(onPressed: _goToday, child: Text(l.calendarToday)),
        ],
      ),
      body: Column(
        children: [
          _ModeToggle(
            mode: _mode,
            onChanged: (m) => setState(() => _mode = m),
          ),
          _Header(
            label: _mode == _CalMode.month
                ? _monthLabel(l.localeName, _month)
                : _weekLabel(l.localeName, _selected),
            onPrev: () => _shift(-1),
            onNext: () => _shift(1),
          ),
          _WeekdayRow(locale: l.localeName),
          _Grid(
            cells: cells,
            month: _month,
            selected: _selected,
            today: today,
            marked: marked,
            singleRow: _mode == _CalMode.week,
            onSelect: _select,
            onDropTask: _drop,
          ),
          const Divider(height: 1),
          Expanded(
            child: dayTasks.isEmpty
                ? Center(
                    child: Text(
                      l.calendarNoTasks,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      for (final t in dayTasks)
                        _DraggableTask(key: ValueKey(t.id), task: t),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

String _monthLabel(String locale, DateTime month) =>
    toBeginningOfSentenceCase(DateFormat.yMMMM(locale).format(month)) ?? '';

String _weekLabel(String locale, DateTime day) {
  final week = weekOf(day);
  final fmt = DateFormat.MMMd(locale);
  return '${fmt.format(week.first)} – ${fmt.format(week.last)}';
}

/// A task tile that can be long-press-dragged onto a calendar day.
class _DraggableTask extends ConsumerWidget {
  const _DraggableTask({super.key, required this.task});
  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final card = TaskCard(
      task: task,
      score: 0,
      showScore: false,
      onComplete: () => ref.read(taskRepositoryProvider).complete(task.id),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => TaskEditView(task: task)),
      ),
    );
    return LongPressDraggable<Task>(
      data: task,
      feedback: _DragChip(title: task.title),
      childWhenDragging: Opacity(opacity: 0.35, child: card),
      child: card,
    );
  }
}

class _DragChip extends StatelessWidget {
  const _DragChip({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: AppColors.brand,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.blue.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onChanged});
  final _CalMode mode;
  final ValueChanged<_CalMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: SegmentedButton<_CalMode>(
        style: const ButtonStyle(visualDensity: VisualDensity.compact),
        segments: [
          ButtonSegment(value: _CalMode.month, label: Text(l.calendarMonth)),
          ButtonSegment(value: _CalMode.week, label: Text(l.calendarWeek)),
        ],
        selected: {mode},
        showSelectedIcon: false,
        onSelectionChanged: (s) => onChanged(s.first),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.label,
    required this.onPrev,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: onPrev),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: onNext),
        ],
      ),
    );
  }
}

class _WeekdayRow extends StatelessWidget {
  const _WeekdayRow({required this.locale});
  final String locale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final symbols = DateFormat.E(locale);
    final labels = [
      for (var i = 0; i < 7; i++)
        symbols.format(DateTime(2026, 1, 5).add(Duration(days: i))), // Mon 5th
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          for (final d in labels)
            Expanded(
              child: Text(
                d,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({
    required this.cells,
    required this.month,
    required this.selected,
    required this.today,
    required this.marked,
    required this.singleRow,
    required this.onSelect,
    required this.onDropTask,
  });

  final List<DateTime> cells;
  final DateTime month;
  final DateTime selected;
  final DateTime today;
  final Set<DateTime> marked;
  final bool singleRow;
  final ValueChanged<DateTime> onSelect;
  final void Function(Task, DateTime) onDropTask;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (final day in cells)
            _DayCell(
              day: day,
              inMonth: singleRow || day.month == month.month,
              isToday: isSameDay(day, today),
              isSelected: isSameDay(day, selected),
              hasTasks: marked.contains(DateTime(day.year, day.month, day.day)),
              onTap: () => onSelect(day),
              onDrop: (task) => onDropTask(task, day),
            ),
        ],
      ),
    );
  }
}

class _DayCell extends StatefulWidget {
  const _DayCell({
    required this.day,
    required this.inMonth,
    required this.isToday,
    required this.isSelected,
    required this.hasTasks,
    required this.onTap,
    required this.onDrop,
  });

  final DateTime day;
  final bool inMonth;
  final bool isToday;
  final bool isSelected;
  final bool hasTasks;
  final VoidCallback onTap;
  final ValueChanged<Task> onDrop;

  @override
  State<_DayCell> createState() => _DayCellState();
}

class _DayCellState extends State<_DayCell> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color fg;
    if (!widget.inMonth) {
      fg = theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4);
    } else if (widget.isSelected) {
      fg = Colors.white;
    } else if (widget.isToday) {
      fg = AppColors.blue;
    } else {
      fg = theme.colorScheme.onSurface;
    }

    return DragTarget<Task>(
      onWillAcceptWithDetails: (_) {
        setState(() => _hover = true);
        return true;
      },
      onLeave: (_) => setState(() => _hover = false),
      onAcceptWithDetails: (d) {
        setState(() => _hover = false);
        widget.onDrop(d.data);
      },
      builder: (context, candidate, rejected) {
        return InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              color: _hover
                  ? AppColors.green.withValues(alpha: 0.18)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: _hover
                  ? Border.all(color: AppColors.green, width: 1.5)
                  : null,
            ),
            padding: const EdgeInsets.all(4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? AppColors.blue
                        : (widget.isToday
                            ? AppColors.blue.withValues(alpha: 0.12)
                            : Colors.transparent),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${widget.day.day}',
                    style: TextStyle(
                      color: fg,
                      fontWeight: widget.isToday || widget.isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: widget.hasTasks && !widget.isSelected
                        ? AppColors.green
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
