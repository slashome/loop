/// Business model of a task.
///
/// Deliberately PURE: no dependency on Flutter or Drift. This expresses the
/// "portable schema" decision — this type must survive a storage change or the
/// future addition of a sync/federation layer. The Drift <-> Task mapping
/// lives in the `data/` layer, never here.
library;

/// Status of a task. `open` is the only "active" state visible in tab 1.
enum TaskStatus { open, done, archived, dropped }

class Task {
  const Task({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.ownerId = 'local',
    this.description,
    this.desire,
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
  })  : assert(priority >= 1 && priority <= 5, 'priority must be in 1..5'),
        assert(desire == null || (desire >= 0 && desire <= 1),
            'desire must be in 0..1'),
        assert(impactSelf == null || (impactSelf >= 0 && impactSelf <= 1),
            'impactSelf must be in 0..1'),
        assert(impactOthers == null || (impactOthers >= 0 && impactOthers <= 1),
            'impactOthers must be in 0..1');

  /// UUIDv7 — stable, sortable, generatable offline (ready for federation).
  final String id;

  /// Account owner. Defaults to `'local'` in v1; anchor for federation.
  final String ownerId;

  /// The only required field. Everything else has a sensible default.
  final String title;

  final String? description;

  /// Desire — stored as 0..1. The 1..10 slider lives only on the UI side.
  final double? desire;

  /// Impact on self — 0..1.
  final double? impactSelf;

  /// Impact on others — 0..1.
  final double? impactOthers;

  /// Priority 1..5. The per-tier caps are applied on write
  /// (see [PriorityCaps]), not here.
  final int priority;

  final String? categoryId;
  final TaskStatus status;

  /// Due date (calendar / "today" filter).
  final DateTime? dueAt;

  /// If non-null, this task is a materialized occurrence of a repeat.
  final String? recurrenceId;

  /// Occurrence date (null for a one-off task).
  final DateTime? occurrenceDate;

  /// Provenance — prepares the idea -> task gateway (e.g.: 'idea-app').
  final String? source;
  final String? sourceRef;

  /// Timestamps. [createdAt] drives the aging part of the score.
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  /// Soft-delete — ready for sync (a deletion is a fact to propagate).
  final DateTime? deletedAt;

  /// A task is "live" if not deleted and still open.
  bool get isLive => deletedAt == null && status == TaskStatus.open;

  Task copyWith({
    String? title,
    String? description,
    double? desire,
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
      desire: desire ?? this.desire,
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
