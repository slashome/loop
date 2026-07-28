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

/// Tab 3 — Calendar. Month grid with dots on days that have dated tasks; the
/// selected day's tasks are listed below.
class CalendarView extends ConsumerStatefulWidget {
  const CalendarView({super.key});

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
  late DateTime _month; // first of the visible month
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = monthStart(now);
    _selected = DateTime(now.year, now.month, now.day);
  }

  void _shiftMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
  }

  void _goToday() {
    final now = DateTime.now();
    setState(() {
      _month = monthStart(now);
      _selected = DateTime(now.year, now.month, now.day);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tasks = ref.watch(tasksProvider).value ?? const <Task>[];
    final today = DateTime.now();

    final marked = daysWithTasks(tasks, _month);
    final dayTasks = tasksOnDay(tasks, _selected);

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
          _MonthHeader(
            month: _month,
            locale: l.localeName,
            onPrev: () => _shiftMonth(-1),
            onNext: () => _shiftMonth(1),
          ),
          _WeekdayRow(locale: l.localeName),
          _MonthGrid(
            month: _month,
            selected: _selected,
            today: today,
            marked: marked,
            onSelect: (d) => setState(() => _selected = d),
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
                        TaskCard(
                          task: t,
                          score: 0,
                          showScore: false,
                          onComplete: () =>
                              ref.read(taskRepositoryProvider).complete(t.id),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => TaskEditView(task: t),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.month,
    required this.locale,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime month;
  final String locale;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final title = toBeginningOfSentenceCase(
      DateFormat.yMMMM(locale).format(month),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrev,
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onNext,
          ),
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
    // Monday-first short weekday names, localized.
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

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.selected,
    required this.today,
    required this.marked,
    required this.onSelect,
  });

  final DateTime month;
  final DateTime selected;
  final DateTime today;
  final Set<int> marked;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cells = monthGrid(month);
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
              inMonth: day.month == month.month,
              isToday: isSameDay(day, today),
              isSelected: isSameDay(day, selected),
              hasTasks: day.month == month.month && marked.contains(day.day),
              onTap: () => onSelect(day),
              theme: theme,
            ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.inMonth,
    required this.isToday,
    required this.isSelected,
    required this.hasTasks,
    required this.onTap,
    required this.theme,
  });

  final DateTime day;
  final bool inMonth;
  final bool isToday;
  final bool isSelected;
  final bool hasTasks;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final Color fg;
    if (!inMonth) {
      fg = theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4);
    } else if (isSelected) {
      fg = Colors.white;
    } else if (isToday) {
      fg = AppColors.blue;
    } else {
      fg = theme.colorScheme.onSurface;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.blue
                    : (isToday
                        ? AppColors.blue.withValues(alpha: 0.12)
                        : Colors.transparent),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${day.day}',
                style: TextStyle(
                  color: fg,
                  fontWeight:
                      isToday || isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: hasTasks && !isSelected
                    ? AppColors.green
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
