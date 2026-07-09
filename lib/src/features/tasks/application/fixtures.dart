/// Données d'amorçage de la feature `tasks` (temporaire — sera remplacé par le
/// TaskRepository/Drift).
///
/// ⚠️ CONTENU PUBLIC : ce fichier est versionné. N'y mets AUCUNE donnée
/// personnelle. Pour amorcer l'app avec tes vraies tâches en local sans les
/// pousser, édite ce fichier puis protège-le :
///     git update-index --skip-worktree lib/src/features/tasks/application/fixtures.dart
/// (annuler : `--no-skip-worktree`). Tes modifications resteront locales.
///
/// La démo ci-dessous est conçue pour montrer l'anti-famine BORNÉ : les deux
/// vieilles P2 remontent au-dessus des P3 fraîches, mais restent SOUS la P4
/// fraîche — la priorité domine, personne ne meurt de faim.
library;

import '../domain/task.dart';

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
    // Terminée : prouve que le filtre « vivant » l'exclut de l'onglet 1.
    t('t8', 'Réserver le restaurant', 5, const Duration(hours: 3),
        status: TaskStatus.done),
  ];
}
