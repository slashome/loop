import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../features/recurrences/presentation/repeats_view.dart';
import '../features/tasks/presentation/next_actions_view.dart';

/// Coquille de l'app : navigation par onglets (ordre identique mobile/PC).
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
    _CalendarPlaceholder(),
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

class _CalendarPlaceholder extends StatelessWidget {
  const _CalendarPlaceholder();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.navCalendar)),
      body: Center(child: Text(l.calendarComingSoon)),
    );
  }
}
