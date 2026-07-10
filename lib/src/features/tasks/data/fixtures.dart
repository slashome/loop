/// Données d'amorçage (seed) — insérées en base au premier lancement.
///
/// ⚠️ CONTENU PUBLIC : ce fichier est versionné. N'y mets AUCUNE donnée
/// personnelle. Pour amorcer avec tes vraies données en local sans les pousser,
/// édite ce fichier puis protège-le :
///     git update-index --skip-worktree lib/src/features/tasks/data/fixtures.dart
/// (annuler : `--no-skip-worktree`).
library;

import '../../recurrences/domain/recurrence.dart';
import '../domain/task.dart';

/// Tâches ponctuelles. Démo conçue pour montrer l'anti-famine borné.
List<Task> seedTasks(DateTime now) {
  Task t(
    String id,
    String title,
    int priority,
    Duration age, {
    TaskStatus status = TaskStatus.open,
  }) {
    final created = now.subtract(age);
    return Task(
      id: id,
      title: title,
      priority: priority,
      status: status,
      createdAt: created,
      updatedAt: created,
    );
  }

  return [
    t('t1', 'Rappeler le comptable avant 17h', 5, const Duration(hours: 1)),
    t('t2', 'Payer la facture d\'électricité', 4, const Duration(days: 2)),
    t('t3', 'Trier les photos de vacances', 2, const Duration(days: 250)),
    t('t4', 'Refactorer le module d\'authentification', 2,
        const Duration(days: 90)),
    t('t5', 'Préparer l\'ordre du jour de la réunion', 3,
        const Duration(hours: 5)),
    t('t6', 'Répondre au mail de Léa', 3, const Duration(days: 1)),
    t('t7', 'Lire l\'article sur Riverpod', 1, const Duration(days: 3)),
    t('t8', 'Réserver le restaurant', 5, const Duration(hours: 3),
        status: TaskStatus.done),
  ];
}

/// Définitions de récurrence (démo).
List<Recurrence> seedRecurrences(DateTime now) {
  return [
    Recurrence(
      id: 'rec-demo-weekly',
      title: 'Revue hebdomadaire',
      freq: RecurrenceFreq.weekly,
      byWeekday: DateTime.monday,
      byHours: const [9],
      rrule: 'FREQ=WEEKLY;BYDAY=MO',
      dtstart: now,
      createdAt: now,
      updatedAt: now,
    ),
    Recurrence(
      id: 'rec-demo-daily',
      title: 'Boire un grand verre d\'eau',
      freq: RecurrenceFreq.daily,
      byHours: const [8, 20],
      rrule: 'FREQ=DAILY;BYHOUR=8,20',
      dtstart: now,
      createdAt: now,
      updatedAt: now,
    ),
  ];
}
