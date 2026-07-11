import 'package:flutter/material.dart';

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
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist),
            label: 'Actions',
          ),
          NavigationDestination(
            icon: Icon(Icons.repeat_outlined),
            selectedIcon: Icon(Icons.repeat),
            label: 'Repeats',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Calendrier',
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
    return Scaffold(
      appBar: AppBar(title: const Text('Calendrier')),
      body: const Center(child: Text('Vue calendrier — à venir.')),
    );
  }
}
