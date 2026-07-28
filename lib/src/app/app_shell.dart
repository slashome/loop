import 'package:flutter/material.dart';

import '../features/calendar/presentation/calendar_view.dart';
import '../features/recurrences/presentation/repeats_view.dart';
import '../features/tasks/presentation/next_actions_view.dart';
import '../../l10n/app_localizations.dart';

/// App shell: tab navigation (same order on mobile and desktop).
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _pages = [
    NextActionsView(),
    RepeatsView(),
    CalendarView(),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.checklist_outlined),
            selectedIcon: const Icon(Icons.checklist),
            label: l.navActions,
          ),
          NavigationDestination(
            icon: const Icon(Icons.repeat_outlined),
            selectedIcon: const Icon(Icons.repeat),
            label: l.navRepeats,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            label: l.navCalendar,
          ),
        ],
      ),
    );
  }
}
