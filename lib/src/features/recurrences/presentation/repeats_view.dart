import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../tasks/application/tasks_providers.dart';
import '../application/recurrences_providers.dart';
import '../domain/recurrence.dart';
import 'recurrence_edit_view.dart';

/// Onglet 2 — Repeats. Gère les définitions de récurrence (pas les occurrences).
class RepeatsView extends ConsumerWidget {
  const RepeatsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(recurrencesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Repeats'), centerTitle: false),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(context),
        child: const Icon(Icons.add),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (recs) => recs.isEmpty
            ? const Center(child: Text('Aucune récurrence.'))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: recs.length,
                itemBuilder: (context, i) {
                  final r = recs[i];
                  return Card(
                    elevation: 0,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.repeat),
                      title: Text(r.title),
                      subtitle: Text(cadenceSummary(r)),
                      trailing: Switch(
                        value: r.active,
                        onChanged: (v) async {
                          await ref
                              .read(recurrenceRepositoryProvider)
                              .setActive(r.id, v);
                          if (v) {
                            await ref
                                .read(taskRepositoryProvider)
                                .generateOccurrences(on: DateTime.now());
                          }
                        },
                      ),
                      onTap: () => _openEditor(context, r),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _openEditor(BuildContext context, [Recurrence? r]) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RecurrenceEditView(recurrence: r),
      ),
    );
  }
}

/// Résumé lisible de la cadence, ex. « Chaque lun, mer · 8h, 20h ».
String cadenceSummary(Recurrence r) {
  final hours = r.byHours.map((h) => '${h}h').join(', ');
  final when = switch (r.freq) {
    RecurrenceFreq.daily => 'Chaque jour',
    RecurrenceFreq.weekly =>
      'Chaque ${r.byWeekdays.map((d) => kWeekdayLabels[d - 1].toLowerCase()).join(', ')}',
    RecurrenceFreq.monthly => 'Le ${r.byMonthDays.join(', ')} du mois',
  };
  return '$when · $hours';
}
