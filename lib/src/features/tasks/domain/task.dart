/// Modèle métier d'une tâche.
///
/// Volontairement PUR : aucune dépendance à Flutter ni à Drift. C'est
/// l'expression de la décision « schéma portable » — ce type doit survivre à
/// un changement de stockage ou à l'ajout futur d'une couche de sync/fédération.
/// Le mapping Drift <-> Task vit dans la couche `data/`, jamais ici.
library;

/// Statut d'une tâche. `open` est le seul état « actif » visible dans l'onglet 1.
enum TaskStatus { open, done, archived, dropped }

class Task {
  const Task({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.ownerId = 'local',
    this.description,
    this.envie,
    this.impactSelf,
    this.impactOthers,
    this.priority = 3,
    this.categoryId,
    this.status = TaskStatus.open,
    this.dueAt,
    this.recurrenceId,
    this.occurrenceDate,
    this.source,
    this.sourceRef,
    this.completedAt,
    this.deletedAt,
  })  : assert(priority >= 1 && priority <= 5, 'priority doit être dans 1..5'),
        assert(envie == null || (envie >= 0 && envie <= 1),
            'envie doit être dans 0..1'),
        assert(impactSelf == null || (impactSelf >= 0 && impactSelf <= 1),
            'impactSelf doit être dans 0..1'),
        assert(impactOthers == null || (impactOthers >= 0 && impactOthers <= 1),
            'impactOthers doit être dans 0..1');

  /// UUIDv7 — stable, triable, générable offline (prêt pour la fédération).
  final String id;

  /// Propriétaire du compte. Défaut `'local'` en v1 ; ancre pour la fédération.
  final String ownerId;

  /// Seul champ obligatoire. Tout le reste a un défaut sensé.
  final String title;

  final String? description;

  /// Envie — stockée en 0..1. Le slider 1..10 vit uniquement côté UI.
  final double? envie;

  /// Impact sur soi — 0..1.
  final double? impactSelf;

  /// Impact sur les autres — 0..1.
  final double? impactOthers;

  /// Priorité 1..5. Les caps par palier sont appliqués à l'écriture
  /// (voir [PriorityCaps]), pas ici.
  final int priority;

  final String? categoryId;
  final TaskStatus status;

  /// Échéance (calendrier / filtre « aujourd'hui »).
  final DateTime? dueAt;

  /// Si non nul, cette tâche est une occurrence matérialisée d'un repeat.
  final String? recurrenceId;

  /// Date de l'occurrence (nul pour une tâche ponctuelle).
  final DateTime? occurrenceDate;

  /// Provenance — prépare la passerelle idée -> tâche (ex: 'idea-app').
  final String? source;
  final String? sourceRef;

  /// Horodatage. [createdAt] pilote l'ancienneté du score.
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  /// Soft-delete — prêt pour la sync (une suppression est un fait à propager).
  final DateTime? deletedAt;

  /// Une tâche est « vivante » si non supprimée et encore ouverte.
  bool get isLive => deletedAt == null && status == TaskStatus.open;

  Task copyWith({
    String? title,
    String? description,
    double? envie,
    double? impactSelf,
    double? impactOthers,
    int? priority,
    String? categoryId,
    TaskStatus? status,
    DateTime? dueAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    DateTime? deletedAt,
  }) {
    return Task(
      id: id,
      ownerId: ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      envie: envie ?? this.envie,
      impactSelf: impactSelf ?? this.impactSelf,
      impactOthers: impactOthers ?? this.impactOthers,
      priority: priority ?? this.priority,
      categoryId: categoryId ?? this.categoryId,
      status: status ?? this.status,
      dueAt: dueAt ?? this.dueAt,
      recurrenceId: recurrenceId,
      occurrenceDate: occurrenceDate,
      source: source,
      sourceRef: sourceRef,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  bool operator ==(Object other) => other is Task && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
