import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/features/tasks/presentation/next_actions_view.dart';

void main() {
  runApp(const ProviderScope(child: LoopApp()));
}

/// Racine de l'application Loop.
///
/// Pour l'instant, l'app s'ouvre directement sur l'onglet 1 (Prochaines
/// actions). La navigation par onglets (Repeats, Calendrier) viendra ensuite.
class LoopApp extends StatelessWidget {
  const LoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Bleu de la marque (logo ∞ bleu→vert) comme graine du thème Material 3.
    final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF3B82C4));
    return MaterialApp(
      title: 'Loop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: const NextActionsView(),
    );
  }
}
