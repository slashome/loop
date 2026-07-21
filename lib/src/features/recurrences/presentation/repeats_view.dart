import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/theme/brand_fab.dart';
import '../../tasks/application/tasks_providers.dart';
import '../application/recurrences_providers.dart';
import '../domain/recurrence.dart';
import 'recurrence_edit_view.dart';

/// Tab 2 — Repeats. Manages recurrence definitions (not occurrences).
class RepeatsView extends ConsumerWidget {
  const RepeatsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(recurrencesProvider);
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.repeatsTitle), centerTitle: false),
      floatingActionButton: BrandFab(
        tooltip: l.newRecurrenceTooltip,
        onPressed: () => _openEditor(context),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l.repeatsError(e.toString()))),
        data: (recs) => recs.isEmpty
            ? Center(child: Text(l.repeatsEmpty))
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
                      subtitle: Text(cadenceSummary(l, r)),
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

/// Human-readable cadence summary, e.g. "Every mon, wed · 8h, 20h".
String cadenceSummary(AppLocalizations l, Recurrence r) {
  final labels = weekdayLabels(l);
  final hours = r.byHours.map((h) => l.hourShort(h)).join(', ');
  final when = switch (r.freq) {
    RecurrenceFreq.daily => l.cadenceDaily,
    RecurrenceFreq.weekly => l.cadenceWeekly(
        r.byWeekdays.map((d) => labels[d - 1].toLowerCase()).join(', '),
      ),
    RecurrenceFreq.monthly => l.cadenceMonthly(r.byMonthDays.join(', ')),
  };
  return l.cadenceSummary(when, hours);
}
