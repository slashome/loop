// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TaskRowsTable extends TaskRows with TableInfo<$TaskRowsTable, TaskRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ownerIdMeta =
      const VerificationMeta('ownerId');
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
      'owner_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('local'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _envieMeta = const VerificationMeta('envie');
  @override
  late final GeneratedColumn<double> envie = GeneratedColumn<double>(
      'envie', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _impactSelfMeta =
      const VerificationMeta('impactSelf');
  @override
  late final GeneratedColumn<double> impactSelf = GeneratedColumn<double>(
      'impact_self', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _impactOthersMeta =
      const VerificationMeta('impactOthers');
  @override
  late final GeneratedColumn<double> impactOthers = GeneratedColumn<double>(
      'impact_others', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
      'priority', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(3));
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('open'));
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
      'due_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _recurrenceIdMeta =
      const VerificationMeta('recurrenceId');
  @override
  late final GeneratedColumn<String> recurrenceId = GeneratedColumn<String>(
      'recurrence_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _occurrenceDateMeta =
      const VerificationMeta('occurrenceDate');
  @override
  late final GeneratedColumn<DateTime> occurrenceDate =
      GeneratedColumn<DateTime>('occurrence_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceRefMeta =
      const VerificationMeta('sourceRef');
  @override
  late final GeneratedColumn<String> sourceRef = GeneratedColumn<String>(
      'source_ref', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        ownerId,
        title,
        description,
        envie,
        impactSelf,
        impactOthers,
        priority,
        categoryId,
        status,
        dueAt,
        recurrenceId,
        occurrenceDate,
        source,
        sourceRef,
        createdAt,
        updatedAt,
        completedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_rows';
  @override
  VerificationContext validateIntegrity(Insertable<TaskRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(_ownerIdMeta,
          ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('envie')) {
      context.handle(
          _envieMeta, envie.isAcceptableOrUnknown(data['envie']!, _envieMeta));
    }
    if (data.containsKey('impact_self')) {
      context.handle(
          _impactSelfMeta,
          impactSelf.isAcceptableOrUnknown(
              data['impact_self']!, _impactSelfMeta));
    }
    if (data.containsKey('impact_others')) {
      context.handle(
          _impactOthersMeta,
          impactOthers.isAcceptableOrUnknown(
              data['impact_others']!, _impactOthersMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('due_at')) {
      context.handle(
          _dueAtMeta, dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta));
    }
    if (data.containsKey('recurrence_id')) {
      context.handle(
          _recurrenceIdMeta,
          recurrenceId.isAcceptableOrUnknown(
              data['recurrence_id']!, _recurrenceIdMeta));
    }
    if (data.containsKey('occurrence_date')) {
      context.handle(
          _occurrenceDateMeta,
          occurrenceDate.isAcceptableOrUnknown(
              data['occurrence_date']!, _occurrenceDateMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('source_ref')) {
      context.handle(_sourceRefMeta,
          sourceRef.isAcceptableOrUnknown(data['source_ref']!, _sourceRefMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      ownerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      envie: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}envie']),
      impactSelf: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}impact_self']),
      impactOthers: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}impact_others']),
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      dueAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_at']),
      recurrenceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recurrence_id']),
      occurrenceDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}occurrence_date']),
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source']),
      sourceRef: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_ref']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $TaskRowsTable createAlias(String alias) {
    return $TaskRowsTable(attachedDatabase, alias);
  }
}

class TaskRow extends DataClass implements Insertable<TaskRow> {
  final String id;
  final String ownerId;
  final String title;
  final String? description;
  final double? envie;
  final double? impactSelf;
  final double? impactOthers;
  final int priority;
  final String? categoryId;
  final String status;
  final DateTime? dueAt;
  final String? recurrenceId;
  final DateTime? occurrenceDate;
  final String? source;
  final String? sourceRef;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final DateTime? deletedAt;
  const TaskRow(
      {required this.id,
      required this.ownerId,
      required this.title,
      this.description,
      this.envie,
      this.impactSelf,
      this.impactOthers,
      required this.priority,
      this.categoryId,
      required this.status,
      this.dueAt,
      this.recurrenceId,
      this.occurrenceDate,
      this.source,
      this.sourceRef,
      required this.createdAt,
      required this.updatedAt,
      this.completedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || envie != null) {
      map['envie'] = Variable<double>(envie);
    }
    if (!nullToAbsent || impactSelf != null) {
      map['impact_self'] = Variable<double>(impactSelf);
    }
    if (!nullToAbsent || impactOthers != null) {
      map['impact_others'] = Variable<double>(impactOthers);
    }
    map['priority'] = Variable<int>(priority);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<DateTime>(dueAt);
    }
    if (!nullToAbsent || recurrenceId != null) {
      map['recurrence_id'] = Variable<String>(recurrenceId);
    }
    if (!nullToAbsent || occurrenceDate != null) {
      map['occurrence_date'] = Variable<DateTime>(occurrenceDate);
    }
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    if (!nullToAbsent || sourceRef != null) {
      map['source_ref'] = Variable<String>(sourceRef);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  TaskRowsCompanion toCompanion(bool nullToAbsent) {
    return TaskRowsCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      envie:
          envie == null && nullToAbsent ? const Value.absent() : Value(envie),
      impactSelf: impactSelf == null && nullToAbsent
          ? const Value.absent()
          : Value(impactSelf),
      impactOthers: impactOthers == null && nullToAbsent
          ? const Value.absent()
          : Value(impactOthers),
      priority: Value(priority),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      status: Value(status),
      dueAt:
          dueAt == null && nullToAbsent ? const Value.absent() : Value(dueAt),
      recurrenceId: recurrenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceId),
      occurrenceDate: occurrenceDate == null && nullToAbsent
          ? const Value.absent()
          : Value(occurrenceDate),
      source:
          source == null && nullToAbsent ? const Value.absent() : Value(source),
      sourceRef: sourceRef == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceRef),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory TaskRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskRow(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      envie: serializer.fromJson<double?>(json['envie']),
      impactSelf: serializer.fromJson<double?>(json['impactSelf']),
      impactOthers: serializer.fromJson<double?>(json['impactOthers']),
      priority: serializer.fromJson<int>(json['priority']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      status: serializer.fromJson<String>(json['status']),
      dueAt: serializer.fromJson<DateTime?>(json['dueAt']),
      recurrenceId: serializer.fromJson<String?>(json['recurrenceId']),
      occurrenceDate: serializer.fromJson<DateTime?>(json['occurrenceDate']),
      source: serializer.fromJson<String?>(json['source']),
      sourceRef: serializer.fromJson<String?>(json['sourceRef']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'envie': serializer.toJson<double?>(envie),
      'impactSelf': serializer.toJson<double?>(impactSelf),
      'impactOthers': serializer.toJson<double?>(impactOthers),
      'priority': serializer.toJson<int>(priority),
      'categoryId': serializer.toJson<String?>(categoryId),
      'status': serializer.toJson<String>(status),
      'dueAt': serializer.toJson<DateTime?>(dueAt),
      'recurrenceId': serializer.toJson<String?>(recurrenceId),
      'occurrenceDate': serializer.toJson<DateTime?>(occurrenceDate),
      'source': serializer.toJson<String?>(source),
      'sourceRef': serializer.toJson<String?>(sourceRef),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  TaskRow copyWith(
          {String? id,
          String? ownerId,
          String? title,
          Value<String?> description = const Value.absent(),
          Value<double?> envie = const Value.absent(),
          Value<double?> impactSelf = const Value.absent(),
          Value<double?> impactOthers = const Value.absent(),
          int? priority,
          Value<String?> categoryId = const Value.absent(),
          String? status,
          Value<DateTime?> dueAt = const Value.absent(),
          Value<String?> recurrenceId = const Value.absent(),
          Value<DateTime?> occurrenceDate = const Value.absent(),
          Value<String?> source = const Value.absent(),
          Value<String?> sourceRef = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> completedAt = const Value.absent(),
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      TaskRow(
        id: id ?? this.id,
        ownerId: ownerId ?? this.ownerId,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        envie: envie.present ? envie.value : this.envie,
        impactSelf: impactSelf.present ? impactSelf.value : this.impactSelf,
        impactOthers:
            impactOthers.present ? impactOthers.value : this.impactOthers,
        priority: priority ?? this.priority,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        status: status ?? this.status,
        dueAt: dueAt.present ? dueAt.value : this.dueAt,
        recurrenceId:
            recurrenceId.present ? recurrenceId.value : this.recurrenceId,
        occurrenceDate:
            occurrenceDate.present ? occurrenceDate.value : this.occurrenceDate,
        source: source.present ? source.value : this.source,
        sourceRef: sourceRef.present ? sourceRef.value : this.sourceRef,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  TaskRow copyWithCompanion(TaskRowsCompanion data) {
    return TaskRow(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      envie: data.envie.present ? data.envie.value : this.envie,
      impactSelf:
          data.impactSelf.present ? data.impactSelf.value : this.impactSelf,
      impactOthers: data.impactOthers.present
          ? data.impactOthers.value
          : this.impactOthers,
      priority: data.priority.present ? data.priority.value : this.priority,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      status: data.status.present ? data.status.value : this.status,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      recurrenceId: data.recurrenceId.present
          ? data.recurrenceId.value
          : this.recurrenceId,
      occurrenceDate: data.occurrenceDate.present
          ? data.occurrenceDate.value
          : this.occurrenceDate,
      source: data.source.present ? data.source.value : this.source,
      sourceRef: data.sourceRef.present ? data.sourceRef.value : this.sourceRef,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskRow(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('envie: $envie, ')
          ..write('impactSelf: $impactSelf, ')
          ..write('impactOthers: $impactOthers, ')
          ..write('priority: $priority, ')
          ..write('categoryId: $categoryId, ')
          ..write('status: $status, ')
          ..write('dueAt: $dueAt, ')
          ..write('recurrenceId: $recurrenceId, ')
          ..write('occurrenceDate: $occurrenceDate, ')
          ..write('source: $source, ')
          ..write('sourceRef: $sourceRef, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      ownerId,
      title,
      description,
      envie,
      impactSelf,
      impactOthers,
      priority,
      categoryId,
      status,
      dueAt,
      recurrenceId,
      occurrenceDate,
      source,
      sourceRef,
      createdAt,
      updatedAt,
      completedAt,
      deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskRow &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.title == this.title &&
          other.description == this.description &&
          other.envie == this.envie &&
          other.impactSelf == this.impactSelf &&
          other.impactOthers == this.impactOthers &&
          other.priority == this.priority &&
          other.categoryId == this.categoryId &&
          other.status == this.status &&
          other.dueAt == this.dueAt &&
          other.recurrenceId == this.recurrenceId &&
          other.occurrenceDate == this.occurrenceDate &&
          other.source == this.source &&
          other.sourceRef == this.sourceRef &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.completedAt == this.completedAt &&
          other.deletedAt == this.deletedAt);
}

class TaskRowsCompanion extends UpdateCompanion<TaskRow> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> title;
  final Value<String?> description;
  final Value<double?> envie;
  final Value<double?> impactSelf;
  final Value<double?> impactOthers;
  final Value<int> priority;
  final Value<String?> categoryId;
  final Value<String> status;
  final Value<DateTime?> dueAt;
  final Value<String?> recurrenceId;
  final Value<DateTime?> occurrenceDate;
  final Value<String?> source;
  final Value<String?> sourceRef;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> completedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const TaskRowsCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.envie = const Value.absent(),
    this.impactSelf = const Value.absent(),
    this.impactOthers = const Value.absent(),
    this.priority = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.status = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.recurrenceId = const Value.absent(),
    this.occurrenceDate = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceRef = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskRowsCompanion.insert({
    required String id,
    this.ownerId = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.envie = const Value.absent(),
    this.impactSelf = const Value.absent(),
    this.impactOthers = const Value.absent(),
    this.priority = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.status = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.recurrenceId = const Value.absent(),
    this.occurrenceDate = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceRef = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.completedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<TaskRow> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<double>? envie,
    Expression<double>? impactSelf,
    Expression<double>? impactOthers,
    Expression<int>? priority,
    Expression<String>? categoryId,
    Expression<String>? status,
    Expression<DateTime>? dueAt,
    Expression<String>? recurrenceId,
    Expression<DateTime>? occurrenceDate,
    Expression<String>? source,
    Expression<String>? sourceRef,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (envie != null) 'envie': envie,
      if (impactSelf != null) 'impact_self': impactSelf,
      if (impactOthers != null) 'impact_others': impactOthers,
      if (priority != null) 'priority': priority,
      if (categoryId != null) 'category_id': categoryId,
      if (status != null) 'status': status,
      if (dueAt != null) 'due_at': dueAt,
      if (recurrenceId != null) 'recurrence_id': recurrenceId,
      if (occurrenceDate != null) 'occurrence_date': occurrenceDate,
      if (source != null) 'source': source,
      if (sourceRef != null) 'source_ref': sourceRef,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskRowsCompanion copyWith(
      {Value<String>? id,
      Value<String>? ownerId,
      Value<String>? title,
      Value<String?>? description,
      Value<double?>? envie,
      Value<double?>? impactSelf,
      Value<double?>? impactOthers,
      Value<int>? priority,
      Value<String?>? categoryId,
      Value<String>? status,
      Value<DateTime?>? dueAt,
      Value<String?>? recurrenceId,
      Value<DateTime?>? occurrenceDate,
      Value<String?>? source,
      Value<String?>? sourceRef,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? completedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? rowid}) {
    return TaskRowsCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      envie: envie ?? this.envie,
      impactSelf: impactSelf ?? this.impactSelf,
      impactOthers: impactOthers ?? this.impactOthers,
      priority: priority ?? this.priority,
      categoryId: categoryId ?? this.categoryId,
      status: status ?? this.status,
      dueAt: dueAt ?? this.dueAt,
      recurrenceId: recurrenceId ?? this.recurrenceId,
      occurrenceDate: occurrenceDate ?? this.occurrenceDate,
      source: source ?? this.source,
      sourceRef: sourceRef ?? this.sourceRef,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (envie.present) {
      map['envie'] = Variable<double>(envie.value);
    }
    if (impactSelf.present) {
      map['impact_self'] = Variable<double>(impactSelf.value);
    }
    if (impactOthers.present) {
      map['impact_others'] = Variable<double>(impactOthers.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (recurrenceId.present) {
      map['recurrence_id'] = Variable<String>(recurrenceId.value);
    }
    if (occurrenceDate.present) {
      map['occurrence_date'] = Variable<DateTime>(occurrenceDate.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (sourceRef.present) {
      map['source_ref'] = Variable<String>(sourceRef.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskRowsCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('envie: $envie, ')
          ..write('impactSelf: $impactSelf, ')
          ..write('impactOthers: $impactOthers, ')
          ..write('priority: $priority, ')
          ..write('categoryId: $categoryId, ')
          ..write('status: $status, ')
          ..write('dueAt: $dueAt, ')
          ..write('recurrenceId: $recurrenceId, ')
          ..write('occurrenceDate: $occurrenceDate, ')
          ..write('source: $source, ')
          ..write('sourceRef: $sourceRef, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurrenceRowsTable extends RecurrenceRows
    with TableInfo<$RecurrenceRowsTable, RecurrenceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurrenceRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ownerIdMeta =
      const VerificationMeta('ownerId');
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
      'owner_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('local'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _freqMeta = const VerificationMeta('freq');
  @override
  late final GeneratedColumn<String> freq = GeneratedColumn<String>(
      'freq', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _byWeekdaysMeta =
      const VerificationMeta('byWeekdays');
  @override
  late final GeneratedColumn<String> byWeekdays = GeneratedColumn<String>(
      'by_weekdays', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _byMonthDaysMeta =
      const VerificationMeta('byMonthDays');
  @override
  late final GeneratedColumn<String> byMonthDays = GeneratedColumn<String>(
      'by_month_days', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _byHoursMeta =
      const VerificationMeta('byHours');
  @override
  late final GeneratedColumn<String> byHours = GeneratedColumn<String>(
      'by_hours', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('9'));
  static const VerificationMeta _byMinuteMeta =
      const VerificationMeta('byMinute');
  @override
  late final GeneratedColumn<int> byMinute = GeneratedColumn<int>(
      'by_minute', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _rruleMeta = const VerificationMeta('rrule');
  @override
  late final GeneratedColumn<String> rrule = GeneratedColumn<String>(
      'rrule', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dtstartMeta =
      const VerificationMeta('dtstart');
  @override
  late final GeneratedColumn<DateTime> dtstart = GeneratedColumn<DateTime>(
      'dtstart', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _timezoneMeta =
      const VerificationMeta('timezone');
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
      'timezone', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Europe/Paris'));
  static const VerificationMeta _nextOccurrenceMeta =
      const VerificationMeta('nextOccurrence');
  @override
  late final GeneratedColumn<DateTime> nextOccurrence =
      GeneratedColumn<DateTime>('next_occurrence', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _defPriorityMeta =
      const VerificationMeta('defPriority');
  @override
  late final GeneratedColumn<int> defPriority = GeneratedColumn<int>(
      'def_priority', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(3));
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
      'active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        ownerId,
        title,
        description,
        freq,
        byWeekdays,
        byMonthDays,
        byHours,
        byMinute,
        rrule,
        dtstart,
        timezone,
        nextOccurrence,
        defPriority,
        active,
        createdAt,
        updatedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurrence_rows';
  @override
  VerificationContext validateIntegrity(Insertable<RecurrenceRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(_ownerIdMeta,
          ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('freq')) {
      context.handle(
          _freqMeta, freq.isAcceptableOrUnknown(data['freq']!, _freqMeta));
    } else if (isInserting) {
      context.missing(_freqMeta);
    }
    if (data.containsKey('by_weekdays')) {
      context.handle(
          _byWeekdaysMeta,
          byWeekdays.isAcceptableOrUnknown(
              data['by_weekdays']!, _byWeekdaysMeta));
    }
    if (data.containsKey('by_month_days')) {
      context.handle(
          _byMonthDaysMeta,
          byMonthDays.isAcceptableOrUnknown(
              data['by_month_days']!, _byMonthDaysMeta));
    }
    if (data.containsKey('by_hours')) {
      context.handle(_byHoursMeta,
          byHours.isAcceptableOrUnknown(data['by_hours']!, _byHoursMeta));
    }
    if (data.containsKey('by_minute')) {
      context.handle(_byMinuteMeta,
          byMinute.isAcceptableOrUnknown(data['by_minute']!, _byMinuteMeta));
    }
    if (data.containsKey('rrule')) {
      context.handle(
          _rruleMeta, rrule.isAcceptableOrUnknown(data['rrule']!, _rruleMeta));
    }
    if (data.containsKey('dtstart')) {
      context.handle(_dtstartMeta,
          dtstart.isAcceptableOrUnknown(data['dtstart']!, _dtstartMeta));
    } else if (isInserting) {
      context.missing(_dtstartMeta);
    }
    if (data.containsKey('timezone')) {
      context.handle(_timezoneMeta,
          timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta));
    }
    if (data.containsKey('next_occurrence')) {
      context.handle(
          _nextOccurrenceMeta,
          nextOccurrence.isAcceptableOrUnknown(
              data['next_occurrence']!, _nextOccurrenceMeta));
    }
    if (data.containsKey('def_priority')) {
      context.handle(
          _defPriorityMeta,
          defPriority.isAcceptableOrUnknown(
              data['def_priority']!, _defPriorityMeta));
    }
    if (data.containsKey('active')) {
      context.handle(_activeMeta,
          active.isAcceptableOrUnknown(data['active']!, _activeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurrenceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurrenceRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      ownerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      freq: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}freq'])!,
      byWeekdays: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}by_weekdays'])!,
      byMonthDays: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}by_month_days'])!,
      byHours: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}by_hours'])!,
      byMinute: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}by_minute'])!,
      rrule: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rrule']),
      dtstart: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}dtstart'])!,
      timezone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}timezone'])!,
      nextOccurrence: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_occurrence']),
      defPriority: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}def_priority'])!,
      active: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $RecurrenceRowsTable createAlias(String alias) {
    return $RecurrenceRowsTable(attachedDatabase, alias);
  }
}

class RecurrenceRow extends DataClass implements Insertable<RecurrenceRow> {
  final String id;
  final String ownerId;
  final String title;
  final String? description;
  final String freq;
  final String byWeekdays;
  final String byMonthDays;
  final String byHours;
  final int byMinute;
  final String? rrule;
  final DateTime dtstart;
  final String timezone;
  final DateTime? nextOccurrence;
  final int defPriority;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const RecurrenceRow(
      {required this.id,
      required this.ownerId,
      required this.title,
      this.description,
      required this.freq,
      required this.byWeekdays,
      required this.byMonthDays,
      required this.byHours,
      required this.byMinute,
      this.rrule,
      required this.dtstart,
      required this.timezone,
      this.nextOccurrence,
      required this.defPriority,
      required this.active,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['freq'] = Variable<String>(freq);
    map['by_weekdays'] = Variable<String>(byWeekdays);
    map['by_month_days'] = Variable<String>(byMonthDays);
    map['by_hours'] = Variable<String>(byHours);
    map['by_minute'] = Variable<int>(byMinute);
    if (!nullToAbsent || rrule != null) {
      map['rrule'] = Variable<String>(rrule);
    }
    map['dtstart'] = Variable<DateTime>(dtstart);
    map['timezone'] = Variable<String>(timezone);
    if (!nullToAbsent || nextOccurrence != null) {
      map['next_occurrence'] = Variable<DateTime>(nextOccurrence);
    }
    map['def_priority'] = Variable<int>(defPriority);
    map['active'] = Variable<bool>(active);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  RecurrenceRowsCompanion toCompanion(bool nullToAbsent) {
    return RecurrenceRowsCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      freq: Value(freq),
      byWeekdays: Value(byWeekdays),
      byMonthDays: Value(byMonthDays),
      byHours: Value(byHours),
      byMinute: Value(byMinute),
      rrule:
          rrule == null && nullToAbsent ? const Value.absent() : Value(rrule),
      dtstart: Value(dtstart),
      timezone: Value(timezone),
      nextOccurrence: nextOccurrence == null && nullToAbsent
          ? const Value.absent()
          : Value(nextOccurrence),
      defPriority: Value(defPriority),
      active: Value(active),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory RecurrenceRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurrenceRow(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      freq: serializer.fromJson<String>(json['freq']),
      byWeekdays: serializer.fromJson<String>(json['byWeekdays']),
      byMonthDays: serializer.fromJson<String>(json['byMonthDays']),
      byHours: serializer.fromJson<String>(json['byHours']),
      byMinute: serializer.fromJson<int>(json['byMinute']),
      rrule: serializer.fromJson<String?>(json['rrule']),
      dtstart: serializer.fromJson<DateTime>(json['dtstart']),
      timezone: serializer.fromJson<String>(json['timezone']),
      nextOccurrence: serializer.fromJson<DateTime?>(json['nextOccurrence']),
      defPriority: serializer.fromJson<int>(json['defPriority']),
      active: serializer.fromJson<bool>(json['active']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'freq': serializer.toJson<String>(freq),
      'byWeekdays': serializer.toJson<String>(byWeekdays),
      'byMonthDays': serializer.toJson<String>(byMonthDays),
      'byHours': serializer.toJson<String>(byHours),
      'byMinute': serializer.toJson<int>(byMinute),
      'rrule': serializer.toJson<String?>(rrule),
      'dtstart': serializer.toJson<DateTime>(dtstart),
      'timezone': serializer.toJson<String>(timezone),
      'nextOccurrence': serializer.toJson<DateTime?>(nextOccurrence),
      'defPriority': serializer.toJson<int>(defPriority),
      'active': serializer.toJson<bool>(active),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  RecurrenceRow copyWith(
          {String? id,
          String? ownerId,
          String? title,
          Value<String?> description = const Value.absent(),
          String? freq,
          String? byWeekdays,
          String? byMonthDays,
          String? byHours,
          int? byMinute,
          Value<String?> rrule = const Value.absent(),
          DateTime? dtstart,
          String? timezone,
          Value<DateTime?> nextOccurrence = const Value.absent(),
          int? defPriority,
          bool? active,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      RecurrenceRow(
        id: id ?? this.id,
        ownerId: ownerId ?? this.ownerId,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        freq: freq ?? this.freq,
        byWeekdays: byWeekdays ?? this.byWeekdays,
        byMonthDays: byMonthDays ?? this.byMonthDays,
        byHours: byHours ?? this.byHours,
        byMinute: byMinute ?? this.byMinute,
        rrule: rrule.present ? rrule.value : this.rrule,
        dtstart: dtstart ?? this.dtstart,
        timezone: timezone ?? this.timezone,
        nextOccurrence:
            nextOccurrence.present ? nextOccurrence.value : this.nextOccurrence,
        defPriority: defPriority ?? this.defPriority,
        active: active ?? this.active,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  RecurrenceRow copyWithCompanion(RecurrenceRowsCompanion data) {
    return RecurrenceRow(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      freq: data.freq.present ? data.freq.value : this.freq,
      byWeekdays:
          data.byWeekdays.present ? data.byWeekdays.value : this.byWeekdays,
      byMonthDays:
          data.byMonthDays.present ? data.byMonthDays.value : this.byMonthDays,
      byHours: data.byHours.present ? data.byHours.value : this.byHours,
      byMinute: data.byMinute.present ? data.byMinute.value : this.byMinute,
      rrule: data.rrule.present ? data.rrule.value : this.rrule,
      dtstart: data.dtstart.present ? data.dtstart.value : this.dtstart,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      nextOccurrence: data.nextOccurrence.present
          ? data.nextOccurrence.value
          : this.nextOccurrence,
      defPriority:
          data.defPriority.present ? data.defPriority.value : this.defPriority,
      active: data.active.present ? data.active.value : this.active,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurrenceRow(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('freq: $freq, ')
          ..write('byWeekdays: $byWeekdays, ')
          ..write('byMonthDays: $byMonthDays, ')
          ..write('byHours: $byHours, ')
          ..write('byMinute: $byMinute, ')
          ..write('rrule: $rrule, ')
          ..write('dtstart: $dtstart, ')
          ..write('timezone: $timezone, ')
          ..write('nextOccurrence: $nextOccurrence, ')
          ..write('defPriority: $defPriority, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      ownerId,
      title,
      description,
      freq,
      byWeekdays,
      byMonthDays,
      byHours,
      byMinute,
      rrule,
      dtstart,
      timezone,
      nextOccurrence,
      defPriority,
      active,
      createdAt,
      updatedAt,
      deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurrenceRow &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.title == this.title &&
          other.description == this.description &&
          other.freq == this.freq &&
          other.byWeekdays == this.byWeekdays &&
          other.byMonthDays == this.byMonthDays &&
          other.byHours == this.byHours &&
          other.byMinute == this.byMinute &&
          other.rrule == this.rrule &&
          other.dtstart == this.dtstart &&
          other.timezone == this.timezone &&
          other.nextOccurrence == this.nextOccurrence &&
          other.defPriority == this.defPriority &&
          other.active == this.active &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class RecurrenceRowsCompanion extends UpdateCompanion<RecurrenceRow> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> title;
  final Value<String?> description;
  final Value<String> freq;
  final Value<String> byWeekdays;
  final Value<String> byMonthDays;
  final Value<String> byHours;
  final Value<int> byMinute;
  final Value<String?> rrule;
  final Value<DateTime> dtstart;
  final Value<String> timezone;
  final Value<DateTime?> nextOccurrence;
  final Value<int> defPriority;
  final Value<bool> active;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const RecurrenceRowsCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.freq = const Value.absent(),
    this.byWeekdays = const Value.absent(),
    this.byMonthDays = const Value.absent(),
    this.byHours = const Value.absent(),
    this.byMinute = const Value.absent(),
    this.rrule = const Value.absent(),
    this.dtstart = const Value.absent(),
    this.timezone = const Value.absent(),
    this.nextOccurrence = const Value.absent(),
    this.defPriority = const Value.absent(),
    this.active = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurrenceRowsCompanion.insert({
    required String id,
    this.ownerId = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    required String freq,
    this.byWeekdays = const Value.absent(),
    this.byMonthDays = const Value.absent(),
    this.byHours = const Value.absent(),
    this.byMinute = const Value.absent(),
    this.rrule = const Value.absent(),
    required DateTime dtstart,
    this.timezone = const Value.absent(),
    this.nextOccurrence = const Value.absent(),
    this.defPriority = const Value.absent(),
    this.active = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        freq = Value(freq),
        dtstart = Value(dtstart),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<RecurrenceRow> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? freq,
    Expression<String>? byWeekdays,
    Expression<String>? byMonthDays,
    Expression<String>? byHours,
    Expression<int>? byMinute,
    Expression<String>? rrule,
    Expression<DateTime>? dtstart,
    Expression<String>? timezone,
    Expression<DateTime>? nextOccurrence,
    Expression<int>? defPriority,
    Expression<bool>? active,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (freq != null) 'freq': freq,
      if (byWeekdays != null) 'by_weekdays': byWeekdays,
      if (byMonthDays != null) 'by_month_days': byMonthDays,
      if (byHours != null) 'by_hours': byHours,
      if (byMinute != null) 'by_minute': byMinute,
      if (rrule != null) 'rrule': rrule,
      if (dtstart != null) 'dtstart': dtstart,
      if (timezone != null) 'timezone': timezone,
      if (nextOccurrence != null) 'next_occurrence': nextOccurrence,
      if (defPriority != null) 'def_priority': defPriority,
      if (active != null) 'active': active,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurrenceRowsCompanion copyWith(
      {Value<String>? id,
      Value<String>? ownerId,
      Value<String>? title,
      Value<String?>? description,
      Value<String>? freq,
      Value<String>? byWeekdays,
      Value<String>? byMonthDays,
      Value<String>? byHours,
      Value<int>? byMinute,
      Value<String?>? rrule,
      Value<DateTime>? dtstart,
      Value<String>? timezone,
      Value<DateTime?>? nextOccurrence,
      Value<int>? defPriority,
      Value<bool>? active,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? rowid}) {
    return RecurrenceRowsCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      freq: freq ?? this.freq,
      byWeekdays: byWeekdays ?? this.byWeekdays,
      byMonthDays: byMonthDays ?? this.byMonthDays,
      byHours: byHours ?? this.byHours,
      byMinute: byMinute ?? this.byMinute,
      rrule: rrule ?? this.rrule,
      dtstart: dtstart ?? this.dtstart,
      timezone: timezone ?? this.timezone,
      nextOccurrence: nextOccurrence ?? this.nextOccurrence,
      defPriority: defPriority ?? this.defPriority,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (freq.present) {
      map['freq'] = Variable<String>(freq.value);
    }
    if (byWeekdays.present) {
      map['by_weekdays'] = Variable<String>(byWeekdays.value);
    }
    if (byMonthDays.present) {
      map['by_month_days'] = Variable<String>(byMonthDays.value);
    }
    if (byHours.present) {
      map['by_hours'] = Variable<String>(byHours.value);
    }
    if (byMinute.present) {
      map['by_minute'] = Variable<int>(byMinute.value);
    }
    if (rrule.present) {
      map['rrule'] = Variable<String>(rrule.value);
    }
    if (dtstart.present) {
      map['dtstart'] = Variable<DateTime>(dtstart.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (nextOccurrence.present) {
      map['next_occurrence'] = Variable<DateTime>(nextOccurrence.value);
    }
    if (defPriority.present) {
      map['def_priority'] = Variable<int>(defPriority.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurrenceRowsCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('freq: $freq, ')
          ..write('byWeekdays: $byWeekdays, ')
          ..write('byMonthDays: $byMonthDays, ')
          ..write('byHours: $byHours, ')
          ..write('byMinute: $byMinute, ')
          ..write('rrule: $rrule, ')
          ..write('dtstart: $dtstart, ')
          ..write('timezone: $timezone, ')
          ..write('nextOccurrence: $nextOccurrence, ')
          ..write('defPriority: $defPriority, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TaskRowsTable taskRows = $TaskRowsTable(this);
  late final $RecurrenceRowsTable recurrenceRows = $RecurrenceRowsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [taskRows, recurrenceRows];
}

typedef $$TaskRowsTableCreateCompanionBuilder = TaskRowsCompanion Function({
  required String id,
  Value<String> ownerId,
  required String title,
  Value<String?> description,
  Value<double?> envie,
  Value<double?> impactSelf,
  Value<double?> impactOthers,
  Value<int> priority,
  Value<String?> categoryId,
  Value<String> status,
  Value<DateTime?> dueAt,
  Value<String?> recurrenceId,
  Value<DateTime?> occurrenceDate,
  Value<String?> source,
  Value<String?> sourceRef,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> completedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$TaskRowsTableUpdateCompanionBuilder = TaskRowsCompanion Function({
  Value<String> id,
  Value<String> ownerId,
  Value<String> title,
  Value<String?> description,
  Value<double?> envie,
  Value<double?> impactSelf,
  Value<double?> impactOthers,
  Value<int> priority,
  Value<String?> categoryId,
  Value<String> status,
  Value<DateTime?> dueAt,
  Value<String?> recurrenceId,
  Value<DateTime?> occurrenceDate,
  Value<String?> source,
  Value<String?> sourceRef,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> completedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

class $$TaskRowsTableFilterComposer
    extends Composer<_$AppDatabase, $TaskRowsTable> {
  $$TaskRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get envie => $composableBuilder(
      column: $table.envie, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get impactSelf => $composableBuilder(
      column: $table.impactSelf, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get impactOthers => $composableBuilder(
      column: $table.impactOthers, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
      column: $table.dueAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recurrenceId => $composableBuilder(
      column: $table.recurrenceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get occurrenceDate => $composableBuilder(
      column: $table.occurrenceDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceRef => $composableBuilder(
      column: $table.sourceRef, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$TaskRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskRowsTable> {
  $$TaskRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get envie => $composableBuilder(
      column: $table.envie, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get impactSelf => $composableBuilder(
      column: $table.impactSelf, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get impactOthers => $composableBuilder(
      column: $table.impactOthers,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
      column: $table.dueAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recurrenceId => $composableBuilder(
      column: $table.recurrenceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get occurrenceDate => $composableBuilder(
      column: $table.occurrenceDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceRef => $composableBuilder(
      column: $table.sourceRef, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$TaskRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskRowsTable> {
  $$TaskRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<double> get envie =>
      $composableBuilder(column: $table.envie, builder: (column) => column);

  GeneratedColumn<double> get impactSelf => $composableBuilder(
      column: $table.impactSelf, builder: (column) => column);

  GeneratedColumn<double> get impactOthers => $composableBuilder(
      column: $table.impactOthers, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<String> get recurrenceId => $composableBuilder(
      column: $table.recurrenceId, builder: (column) => column);

  GeneratedColumn<DateTime> get occurrenceDate => $composableBuilder(
      column: $table.occurrenceDate, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get sourceRef =>
      $composableBuilder(column: $table.sourceRef, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$TaskRowsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TaskRowsTable,
    TaskRow,
    $$TaskRowsTableFilterComposer,
    $$TaskRowsTableOrderingComposer,
    $$TaskRowsTableAnnotationComposer,
    $$TaskRowsTableCreateCompanionBuilder,
    $$TaskRowsTableUpdateCompanionBuilder,
    (TaskRow, BaseReferences<_$AppDatabase, $TaskRowsTable, TaskRow>),
    TaskRow,
    PrefetchHooks Function()> {
  $$TaskRowsTableTableManager(_$AppDatabase db, $TaskRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> ownerId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<double?> envie = const Value.absent(),
            Value<double?> impactSelf = const Value.absent(),
            Value<double?> impactOthers = const Value.absent(),
            Value<int> priority = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime?> dueAt = const Value.absent(),
            Value<String?> recurrenceId = const Value.absent(),
            Value<DateTime?> occurrenceDate = const Value.absent(),
            Value<String?> source = const Value.absent(),
            Value<String?> sourceRef = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TaskRowsCompanion(
            id: id,
            ownerId: ownerId,
            title: title,
            description: description,
            envie: envie,
            impactSelf: impactSelf,
            impactOthers: impactOthers,
            priority: priority,
            categoryId: categoryId,
            status: status,
            dueAt: dueAt,
            recurrenceId: recurrenceId,
            occurrenceDate: occurrenceDate,
            source: source,
            sourceRef: sourceRef,
            createdAt: createdAt,
            updatedAt: updatedAt,
            completedAt: completedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String> ownerId = const Value.absent(),
            required String title,
            Value<String?> description = const Value.absent(),
            Value<double?> envie = const Value.absent(),
            Value<double?> impactSelf = const Value.absent(),
            Value<double?> impactOthers = const Value.absent(),
            Value<int> priority = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime?> dueAt = const Value.absent(),
            Value<String?> recurrenceId = const Value.absent(),
            Value<DateTime?> occurrenceDate = const Value.absent(),
            Value<String?> source = const Value.absent(),
            Value<String?> sourceRef = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> completedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TaskRowsCompanion.insert(
            id: id,
            ownerId: ownerId,
            title: title,
            description: description,
            envie: envie,
            impactSelf: impactSelf,
            impactOthers: impactOthers,
            priority: priority,
            categoryId: categoryId,
            status: status,
            dueAt: dueAt,
            recurrenceId: recurrenceId,
            occurrenceDate: occurrenceDate,
            source: source,
            sourceRef: sourceRef,
            createdAt: createdAt,
            updatedAt: updatedAt,
            completedAt: completedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TaskRowsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TaskRowsTable,
    TaskRow,
    $$TaskRowsTableFilterComposer,
    $$TaskRowsTableOrderingComposer,
    $$TaskRowsTableAnnotationComposer,
    $$TaskRowsTableCreateCompanionBuilder,
    $$TaskRowsTableUpdateCompanionBuilder,
    (TaskRow, BaseReferences<_$AppDatabase, $TaskRowsTable, TaskRow>),
    TaskRow,
    PrefetchHooks Function()>;
typedef $$RecurrenceRowsTableCreateCompanionBuilder = RecurrenceRowsCompanion
    Function({
  required String id,
  Value<String> ownerId,
  required String title,
  Value<String?> description,
  required String freq,
  Value<String> byWeekdays,
  Value<String> byMonthDays,
  Value<String> byHours,
  Value<int> byMinute,
  Value<String?> rrule,
  required DateTime dtstart,
  Value<String> timezone,
  Value<DateTime?> nextOccurrence,
  Value<int> defPriority,
  Value<bool> active,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$RecurrenceRowsTableUpdateCompanionBuilder = RecurrenceRowsCompanion
    Function({
  Value<String> id,
  Value<String> ownerId,
  Value<String> title,
  Value<String?> description,
  Value<String> freq,
  Value<String> byWeekdays,
  Value<String> byMonthDays,
  Value<String> byHours,
  Value<int> byMinute,
  Value<String?> rrule,
  Value<DateTime> dtstart,
  Value<String> timezone,
  Value<DateTime?> nextOccurrence,
  Value<int> defPriority,
  Value<bool> active,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

class $$RecurrenceRowsTableFilterComposer
    extends Composer<_$AppDatabase, $RecurrenceRowsTable> {
  $$RecurrenceRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get freq => $composableBuilder(
      column: $table.freq, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get byWeekdays => $composableBuilder(
      column: $table.byWeekdays, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get byMonthDays => $composableBuilder(
      column: $table.byMonthDays, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get byHours => $composableBuilder(
      column: $table.byHours, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get byMinute => $composableBuilder(
      column: $table.byMinute, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rrule => $composableBuilder(
      column: $table.rrule, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dtstart => $composableBuilder(
      column: $table.dtstart, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timezone => $composableBuilder(
      column: $table.timezone, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextOccurrence => $composableBuilder(
      column: $table.nextOccurrence,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get defPriority => $composableBuilder(
      column: $table.defPriority, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get active => $composableBuilder(
      column: $table.active, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$RecurrenceRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurrenceRowsTable> {
  $$RecurrenceRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get freq => $composableBuilder(
      column: $table.freq, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get byWeekdays => $composableBuilder(
      column: $table.byWeekdays, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get byMonthDays => $composableBuilder(
      column: $table.byMonthDays, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get byHours => $composableBuilder(
      column: $table.byHours, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get byMinute => $composableBuilder(
      column: $table.byMinute, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rrule => $composableBuilder(
      column: $table.rrule, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dtstart => $composableBuilder(
      column: $table.dtstart, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timezone => $composableBuilder(
      column: $table.timezone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextOccurrence => $composableBuilder(
      column: $table.nextOccurrence,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get defPriority => $composableBuilder(
      column: $table.defPriority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get active => $composableBuilder(
      column: $table.active, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$RecurrenceRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurrenceRowsTable> {
  $$RecurrenceRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get freq =>
      $composableBuilder(column: $table.freq, builder: (column) => column);

  GeneratedColumn<String> get byWeekdays => $composableBuilder(
      column: $table.byWeekdays, builder: (column) => column);

  GeneratedColumn<String> get byMonthDays => $composableBuilder(
      column: $table.byMonthDays, builder: (column) => column);

  GeneratedColumn<String> get byHours =>
      $composableBuilder(column: $table.byHours, builder: (column) => column);

  GeneratedColumn<int> get byMinute =>
      $composableBuilder(column: $table.byMinute, builder: (column) => column);

  GeneratedColumn<String> get rrule =>
      $composableBuilder(column: $table.rrule, builder: (column) => column);

  GeneratedColumn<DateTime> get dtstart =>
      $composableBuilder(column: $table.dtstart, builder: (column) => column);

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<DateTime> get nextOccurrence => $composableBuilder(
      column: $table.nextOccurrence, builder: (column) => column);

  GeneratedColumn<int> get defPriority => $composableBuilder(
      column: $table.defPriority, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$RecurrenceRowsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecurrenceRowsTable,
    RecurrenceRow,
    $$RecurrenceRowsTableFilterComposer,
    $$RecurrenceRowsTableOrderingComposer,
    $$RecurrenceRowsTableAnnotationComposer,
    $$RecurrenceRowsTableCreateCompanionBuilder,
    $$RecurrenceRowsTableUpdateCompanionBuilder,
    (
      RecurrenceRow,
      BaseReferences<_$AppDatabase, $RecurrenceRowsTable, RecurrenceRow>
    ),
    RecurrenceRow,
    PrefetchHooks Function()> {
  $$RecurrenceRowsTableTableManager(
      _$AppDatabase db, $RecurrenceRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurrenceRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurrenceRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurrenceRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> ownerId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> freq = const Value.absent(),
            Value<String> byWeekdays = const Value.absent(),
            Value<String> byMonthDays = const Value.absent(),
            Value<String> byHours = const Value.absent(),
            Value<int> byMinute = const Value.absent(),
            Value<String?> rrule = const Value.absent(),
            Value<DateTime> dtstart = const Value.absent(),
            Value<String> timezone = const Value.absent(),
            Value<DateTime?> nextOccurrence = const Value.absent(),
            Value<int> defPriority = const Value.absent(),
            Value<bool> active = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecurrenceRowsCompanion(
            id: id,
            ownerId: ownerId,
            title: title,
            description: description,
            freq: freq,
            byWeekdays: byWeekdays,
            byMonthDays: byMonthDays,
            byHours: byHours,
            byMinute: byMinute,
            rrule: rrule,
            dtstart: dtstart,
            timezone: timezone,
            nextOccurrence: nextOccurrence,
            defPriority: defPriority,
            active: active,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String> ownerId = const Value.absent(),
            required String title,
            Value<String?> description = const Value.absent(),
            required String freq,
            Value<String> byWeekdays = const Value.absent(),
            Value<String> byMonthDays = const Value.absent(),
            Value<String> byHours = const Value.absent(),
            Value<int> byMinute = const Value.absent(),
            Value<String?> rrule = const Value.absent(),
            required DateTime dtstart,
            Value<String> timezone = const Value.absent(),
            Value<DateTime?> nextOccurrence = const Value.absent(),
            Value<int> defPriority = const Value.absent(),
            Value<bool> active = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecurrenceRowsCompanion.insert(
            id: id,
            ownerId: ownerId,
            title: title,
            description: description,
            freq: freq,
            byWeekdays: byWeekdays,
            byMonthDays: byMonthDays,
            byHours: byHours,
            byMinute: byMinute,
            rrule: rrule,
            dtstart: dtstart,
            timezone: timezone,
            nextOccurrence: nextOccurrence,
            defPriority: defPriority,
            active: active,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RecurrenceRowsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RecurrenceRowsTable,
    RecurrenceRow,
    $$RecurrenceRowsTableFilterComposer,
    $$RecurrenceRowsTableOrderingComposer,
    $$RecurrenceRowsTableAnnotationComposer,
    $$RecurrenceRowsTableCreateCompanionBuilder,
    $$RecurrenceRowsTableUpdateCompanionBuilder,
    (
      RecurrenceRow,
      BaseReferences<_$AppDatabase, $RecurrenceRowsTable, RecurrenceRow>
    ),
    RecurrenceRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TaskRowsTableTableManager get taskRows =>
      $$TaskRowsTableTableManager(_db, _db.taskRows);
  $$RecurrenceRowsTableTableManager get recurrenceRows =>
      $$RecurrenceRowsTableTableManager(_db, _db.recurrenceRows);
}
