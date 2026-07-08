import 'package:flutter/material.dart';

void main() {
  runApp(const LoopApp());
}

/// Racine de l'application Loop.
///
/// Shell minimal pour l'instant : la vraie navigation (Prochaines actions /
/// Repeats / Calendrier) et l'onglet 1 arrivent dans les tranches suivantes.
class LoopApp extends StatelessWidget {
  const LoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loop',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const _HomePlaceholder(),
    );
  }
}

class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loop')),
      body: const Center(
        child: Text('Prochaines actions — à venir'),
      ),
    );
  }
}
