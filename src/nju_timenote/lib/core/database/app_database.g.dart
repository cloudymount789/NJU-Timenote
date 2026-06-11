// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CourseRowsTable extends CourseRows
    with TableInfo<$CourseRowsTable, CourseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CourseRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('localOnly'),
  );
  static const VerificationMeta _localRevisionMeta = const VerificationMeta(
    'localRevision',
  );
  @override
  late final GeneratedColumn<int> localRevision = GeneratedColumn<int>(
    'local_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _serverRevisionMeta = const VerificationMeta(
    'serverRevision',
  );
  @override
  late final GeneratedColumn<int> serverRevision = GeneratedColumn<int>(
    'server_revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _teacherMeta = const VerificationMeta(
    'teacher',
  );
  @override
  late final GeneratedColumn<String> teacher = GeneratedColumn<String>(
    'teacher',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayOfWeekMeta = const VerificationMeta(
    'dayOfWeek',
  );
  @override
  late final GeneratedColumn<int> dayOfWeek = GeneratedColumn<int>(
    'day_of_week',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startPeriodMeta = const VerificationMeta(
    'startPeriod',
  );
  @override
  late final GeneratedColumn<int> startPeriod = GeneratedColumn<int>(
    'start_period',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endPeriodMeta = const VerificationMeta(
    'endPeriod',
  );
  @override
  late final GeneratedColumn<int> endPeriod = GeneratedColumn<int>(
    'end_period',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekRuleMeta = const VerificationMeta(
    'weekRule',
  );
  @override
  late final GeneratedColumn<String> weekRule = GeneratedColumn<String>(
    'week_rule',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startWeekMeta = const VerificationMeta(
    'startWeek',
  );
  @override
  late final GeneratedColumn<int> startWeek = GeneratedColumn<int>(
    'start_week',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endWeekMeta = const VerificationMeta(
    'endWeek',
  );
  @override
  late final GeneratedColumn<int> endWeek = GeneratedColumn<int>(
    'end_week',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorKeyMeta = const VerificationMeta(
    'colorKey',
  );
  @override
  late final GeneratedColumn<String> colorKey = GeneratedColumn<String>(
    'color_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    syncStatus,
    localRevision,
    serverRevision,
    lastSyncedAt,
    deletedAt,
    id,
    name,
    teacher,
    location,
    note,
    dayOfWeek,
    startPeriod,
    endPeriod,
    weekRule,
    startWeek,
    endWeek,
    colorKey,
    source,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'course_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<CourseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('local_revision')) {
      context.handle(
        _localRevisionMeta,
        localRevision.isAcceptableOrUnknown(
          data['local_revision']!,
          _localRevisionMeta,
        ),
      );
    }
    if (data.containsKey('server_revision')) {
      context.handle(
        _serverRevisionMeta,
        serverRevision.isAcceptableOrUnknown(
          data['server_revision']!,
          _serverRevisionMeta,
        ),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('teacher')) {
      context.handle(
        _teacherMeta,
        teacher.isAcceptableOrUnknown(data['teacher']!, _teacherMeta),
      );
    } else if (isInserting) {
      context.missing(_teacherMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('day_of_week')) {
      context.handle(
        _dayOfWeekMeta,
        dayOfWeek.isAcceptableOrUnknown(data['day_of_week']!, _dayOfWeekMeta),
      );
    } else if (isInserting) {
      context.missing(_dayOfWeekMeta);
    }
    if (data.containsKey('start_period')) {
      context.handle(
        _startPeriodMeta,
        startPeriod.isAcceptableOrUnknown(
          data['start_period']!,
          _startPeriodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startPeriodMeta);
    }
    if (data.containsKey('end_period')) {
      context.handle(
        _endPeriodMeta,
        endPeriod.isAcceptableOrUnknown(data['end_period']!, _endPeriodMeta),
      );
    } else if (isInserting) {
      context.missing(_endPeriodMeta);
    }
    if (data.containsKey('week_rule')) {
      context.handle(
        _weekRuleMeta,
        weekRule.isAcceptableOrUnknown(data['week_rule']!, _weekRuleMeta),
      );
    } else if (isInserting) {
      context.missing(_weekRuleMeta);
    }
    if (data.containsKey('start_week')) {
      context.handle(
        _startWeekMeta,
        startWeek.isAcceptableOrUnknown(data['start_week']!, _startWeekMeta),
      );
    } else if (isInserting) {
      context.missing(_startWeekMeta);
    }
    if (data.containsKey('end_week')) {
      context.handle(
        _endWeekMeta,
        endWeek.isAcceptableOrUnknown(data['end_week']!, _endWeekMeta),
      );
    } else if (isInserting) {
      context.missing(_endWeekMeta);
    }
    if (data.containsKey('color_key')) {
      context.handle(
        _colorKeyMeta,
        colorKey.isAcceptableOrUnknown(data['color_key']!, _colorKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_colorKeyMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CourseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CourseRow(
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      localRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_revision'],
      )!,
      serverRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_revision'],
      ),
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      teacher: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}teacher'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      dayOfWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_of_week'],
      )!,
      startPeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_period'],
      )!,
      endPeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_period'],
      )!,
      weekRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}week_rule'],
      )!,
      startWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_week'],
      )!,
      endWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_week'],
      )!,
      colorKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_key'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CourseRowsTable createAlias(String alias) {
    return $CourseRowsTable(attachedDatabase, alias);
  }
}

class CourseRow extends DataClass implements Insertable<CourseRow> {
  final String syncStatus;
  final int localRevision;
  final int? serverRevision;
  final DateTime? lastSyncedAt;
  final DateTime? deletedAt;
  final String id;
  final String name;
  final String teacher;
  final String location;
  final String note;
  final int dayOfWeek;
  final int startPeriod;
  final int endPeriod;
  final String weekRule;
  final int startWeek;
  final int endWeek;
  final String colorKey;
  final String source;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CourseRow({
    required this.syncStatus,
    required this.localRevision,
    this.serverRevision,
    this.lastSyncedAt,
    this.deletedAt,
    required this.id,
    required this.name,
    required this.teacher,
    required this.location,
    required this.note,
    required this.dayOfWeek,
    required this.startPeriod,
    required this.endPeriod,
    required this.weekRule,
    required this.startWeek,
    required this.endWeek,
    required this.colorKey,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sync_status'] = Variable<String>(syncStatus);
    map['local_revision'] = Variable<int>(localRevision);
    if (!nullToAbsent || serverRevision != null) {
      map['server_revision'] = Variable<int>(serverRevision);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['teacher'] = Variable<String>(teacher);
    map['location'] = Variable<String>(location);
    map['note'] = Variable<String>(note);
    map['day_of_week'] = Variable<int>(dayOfWeek);
    map['start_period'] = Variable<int>(startPeriod);
    map['end_period'] = Variable<int>(endPeriod);
    map['week_rule'] = Variable<String>(weekRule);
    map['start_week'] = Variable<int>(startWeek);
    map['end_week'] = Variable<int>(endWeek);
    map['color_key'] = Variable<String>(colorKey);
    map['source'] = Variable<String>(source);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CourseRowsCompanion toCompanion(bool nullToAbsent) {
    return CourseRowsCompanion(
      syncStatus: Value(syncStatus),
      localRevision: Value(localRevision),
      serverRevision: serverRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(serverRevision),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      name: Value(name),
      teacher: Value(teacher),
      location: Value(location),
      note: Value(note),
      dayOfWeek: Value(dayOfWeek),
      startPeriod: Value(startPeriod),
      endPeriod: Value(endPeriod),
      weekRule: Value(weekRule),
      startWeek: Value(startWeek),
      endWeek: Value(endWeek),
      colorKey: Value(colorKey),
      source: Value(source),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CourseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CourseRow(
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      localRevision: serializer.fromJson<int>(json['localRevision']),
      serverRevision: serializer.fromJson<int?>(json['serverRevision']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      teacher: serializer.fromJson<String>(json['teacher']),
      location: serializer.fromJson<String>(json['location']),
      note: serializer.fromJson<String>(json['note']),
      dayOfWeek: serializer.fromJson<int>(json['dayOfWeek']),
      startPeriod: serializer.fromJson<int>(json['startPeriod']),
      endPeriod: serializer.fromJson<int>(json['endPeriod']),
      weekRule: serializer.fromJson<String>(json['weekRule']),
      startWeek: serializer.fromJson<int>(json['startWeek']),
      endWeek: serializer.fromJson<int>(json['endWeek']),
      colorKey: serializer.fromJson<String>(json['colorKey']),
      source: serializer.fromJson<String>(json['source']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncStatus': serializer.toJson<String>(syncStatus),
      'localRevision': serializer.toJson<int>(localRevision),
      'serverRevision': serializer.toJson<int?>(serverRevision),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'teacher': serializer.toJson<String>(teacher),
      'location': serializer.toJson<String>(location),
      'note': serializer.toJson<String>(note),
      'dayOfWeek': serializer.toJson<int>(dayOfWeek),
      'startPeriod': serializer.toJson<int>(startPeriod),
      'endPeriod': serializer.toJson<int>(endPeriod),
      'weekRule': serializer.toJson<String>(weekRule),
      'startWeek': serializer.toJson<int>(startWeek),
      'endWeek': serializer.toJson<int>(endWeek),
      'colorKey': serializer.toJson<String>(colorKey),
      'source': serializer.toJson<String>(source),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CourseRow copyWith({
    String? syncStatus,
    int? localRevision,
    Value<int?> serverRevision = const Value.absent(),
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    String? name,
    String? teacher,
    String? location,
    String? note,
    int? dayOfWeek,
    int? startPeriod,
    int? endPeriod,
    String? weekRule,
    int? startWeek,
    int? endWeek,
    String? colorKey,
    String? source,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CourseRow(
    syncStatus: syncStatus ?? this.syncStatus,
    localRevision: localRevision ?? this.localRevision,
    serverRevision: serverRevision.present
        ? serverRevision.value
        : this.serverRevision,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    name: name ?? this.name,
    teacher: teacher ?? this.teacher,
    location: location ?? this.location,
    note: note ?? this.note,
    dayOfWeek: dayOfWeek ?? this.dayOfWeek,
    startPeriod: startPeriod ?? this.startPeriod,
    endPeriod: endPeriod ?? this.endPeriod,
    weekRule: weekRule ?? this.weekRule,
    startWeek: startWeek ?? this.startWeek,
    endWeek: endWeek ?? this.endWeek,
    colorKey: colorKey ?? this.colorKey,
    source: source ?? this.source,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CourseRow copyWithCompanion(CourseRowsCompanion data) {
    return CourseRow(
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      localRevision: data.localRevision.present
          ? data.localRevision.value
          : this.localRevision,
      serverRevision: data.serverRevision.present
          ? data.serverRevision.value
          : this.serverRevision,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      teacher: data.teacher.present ? data.teacher.value : this.teacher,
      location: data.location.present ? data.location.value : this.location,
      note: data.note.present ? data.note.value : this.note,
      dayOfWeek: data.dayOfWeek.present ? data.dayOfWeek.value : this.dayOfWeek,
      startPeriod: data.startPeriod.present
          ? data.startPeriod.value
          : this.startPeriod,
      endPeriod: data.endPeriod.present ? data.endPeriod.value : this.endPeriod,
      weekRule: data.weekRule.present ? data.weekRule.value : this.weekRule,
      startWeek: data.startWeek.present ? data.startWeek.value : this.startWeek,
      endWeek: data.endWeek.present ? data.endWeek.value : this.endWeek,
      colorKey: data.colorKey.present ? data.colorKey.value : this.colorKey,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CourseRow(')
          ..write('syncStatus: $syncStatus, ')
          ..write('localRevision: $localRevision, ')
          ..write('serverRevision: $serverRevision, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('teacher: $teacher, ')
          ..write('location: $location, ')
          ..write('note: $note, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('startPeriod: $startPeriod, ')
          ..write('endPeriod: $endPeriod, ')
          ..write('weekRule: $weekRule, ')
          ..write('startWeek: $startWeek, ')
          ..write('endWeek: $endWeek, ')
          ..write('colorKey: $colorKey, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    syncStatus,
    localRevision,
    serverRevision,
    lastSyncedAt,
    deletedAt,
    id,
    name,
    teacher,
    location,
    note,
    dayOfWeek,
    startPeriod,
    endPeriod,
    weekRule,
    startWeek,
    endWeek,
    colorKey,
    source,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CourseRow &&
          other.syncStatus == this.syncStatus &&
          other.localRevision == this.localRevision &&
          other.serverRevision == this.serverRevision &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.name == this.name &&
          other.teacher == this.teacher &&
          other.location == this.location &&
          other.note == this.note &&
          other.dayOfWeek == this.dayOfWeek &&
          other.startPeriod == this.startPeriod &&
          other.endPeriod == this.endPeriod &&
          other.weekRule == this.weekRule &&
          other.startWeek == this.startWeek &&
          other.endWeek == this.endWeek &&
          other.colorKey == this.colorKey &&
          other.source == this.source &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CourseRowsCompanion extends UpdateCompanion<CourseRow> {
  final Value<String> syncStatus;
  final Value<int> localRevision;
  final Value<int?> serverRevision;
  final Value<DateTime?> lastSyncedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String> name;
  final Value<String> teacher;
  final Value<String> location;
  final Value<String> note;
  final Value<int> dayOfWeek;
  final Value<int> startPeriod;
  final Value<int> endPeriod;
  final Value<String> weekRule;
  final Value<int> startWeek;
  final Value<int> endWeek;
  final Value<String> colorKey;
  final Value<String> source;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CourseRowsCompanion({
    this.syncStatus = const Value.absent(),
    this.localRevision = const Value.absent(),
    this.serverRevision = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.teacher = const Value.absent(),
    this.location = const Value.absent(),
    this.note = const Value.absent(),
    this.dayOfWeek = const Value.absent(),
    this.startPeriod = const Value.absent(),
    this.endPeriod = const Value.absent(),
    this.weekRule = const Value.absent(),
    this.startWeek = const Value.absent(),
    this.endWeek = const Value.absent(),
    this.colorKey = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CourseRowsCompanion.insert({
    this.syncStatus = const Value.absent(),
    this.localRevision = const Value.absent(),
    this.serverRevision = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String id,
    required String name,
    required String teacher,
    required String location,
    required String note,
    required int dayOfWeek,
    required int startPeriod,
    required int endPeriod,
    required String weekRule,
    required int startWeek,
    required int endWeek,
    required String colorKey,
    required String source,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       teacher = Value(teacher),
       location = Value(location),
       note = Value(note),
       dayOfWeek = Value(dayOfWeek),
       startPeriod = Value(startPeriod),
       endPeriod = Value(endPeriod),
       weekRule = Value(weekRule),
       startWeek = Value(startWeek),
       endWeek = Value(endWeek),
       colorKey = Value(colorKey),
       source = Value(source),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CourseRow> custom({
    Expression<String>? syncStatus,
    Expression<int>? localRevision,
    Expression<int>? serverRevision,
    Expression<DateTime>? lastSyncedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? teacher,
    Expression<String>? location,
    Expression<String>? note,
    Expression<int>? dayOfWeek,
    Expression<int>? startPeriod,
    Expression<int>? endPeriod,
    Expression<String>? weekRule,
    Expression<int>? startWeek,
    Expression<int>? endWeek,
    Expression<String>? colorKey,
    Expression<String>? source,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncStatus != null) 'sync_status': syncStatus,
      if (localRevision != null) 'local_revision': localRevision,
      if (serverRevision != null) 'server_revision': serverRevision,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (teacher != null) 'teacher': teacher,
      if (location != null) 'location': location,
      if (note != null) 'note': note,
      if (dayOfWeek != null) 'day_of_week': dayOfWeek,
      if (startPeriod != null) 'start_period': startPeriod,
      if (endPeriod != null) 'end_period': endPeriod,
      if (weekRule != null) 'week_rule': weekRule,
      if (startWeek != null) 'start_week': startWeek,
      if (endWeek != null) 'end_week': endWeek,
      if (colorKey != null) 'color_key': colorKey,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CourseRowsCompanion copyWith({
    Value<String>? syncStatus,
    Value<int>? localRevision,
    Value<int?>? serverRevision,
    Value<DateTime?>? lastSyncedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String>? name,
    Value<String>? teacher,
    Value<String>? location,
    Value<String>? note,
    Value<int>? dayOfWeek,
    Value<int>? startPeriod,
    Value<int>? endPeriod,
    Value<String>? weekRule,
    Value<int>? startWeek,
    Value<int>? endWeek,
    Value<String>? colorKey,
    Value<String>? source,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CourseRowsCompanion(
      syncStatus: syncStatus ?? this.syncStatus,
      localRevision: localRevision ?? this.localRevision,
      serverRevision: serverRevision ?? this.serverRevision,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      name: name ?? this.name,
      teacher: teacher ?? this.teacher,
      location: location ?? this.location,
      note: note ?? this.note,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startPeriod: startPeriod ?? this.startPeriod,
      endPeriod: endPeriod ?? this.endPeriod,
      weekRule: weekRule ?? this.weekRule,
      startWeek: startWeek ?? this.startWeek,
      endWeek: endWeek ?? this.endWeek,
      colorKey: colorKey ?? this.colorKey,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (localRevision.present) {
      map['local_revision'] = Variable<int>(localRevision.value);
    }
    if (serverRevision.present) {
      map['server_revision'] = Variable<int>(serverRevision.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (teacher.present) {
      map['teacher'] = Variable<String>(teacher.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (dayOfWeek.present) {
      map['day_of_week'] = Variable<int>(dayOfWeek.value);
    }
    if (startPeriod.present) {
      map['start_period'] = Variable<int>(startPeriod.value);
    }
    if (endPeriod.present) {
      map['end_period'] = Variable<int>(endPeriod.value);
    }
    if (weekRule.present) {
      map['week_rule'] = Variable<String>(weekRule.value);
    }
    if (startWeek.present) {
      map['start_week'] = Variable<int>(startWeek.value);
    }
    if (endWeek.present) {
      map['end_week'] = Variable<int>(endWeek.value);
    }
    if (colorKey.present) {
      map['color_key'] = Variable<String>(colorKey.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CourseRowsCompanion(')
          ..write('syncStatus: $syncStatus, ')
          ..write('localRevision: $localRevision, ')
          ..write('serverRevision: $serverRevision, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('teacher: $teacher, ')
          ..write('location: $location, ')
          ..write('note: $note, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('startPeriod: $startPeriod, ')
          ..write('endPeriod: $endPeriod, ')
          ..write('weekRule: $weekRule, ')
          ..write('startWeek: $startWeek, ')
          ..write('endWeek: $endWeek, ')
          ..write('colorKey: $colorKey, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TodoRowsTable extends TodoRows with TableInfo<$TodoRowsTable, TodoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TodoRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('localOnly'),
  );
  static const VerificationMeta _localRevisionMeta = const VerificationMeta(
    'localRevision',
  );
  @override
  late final GeneratedColumn<int> localRevision = GeneratedColumn<int>(
    'local_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _serverRevisionMeta = const VerificationMeta(
    'serverRevision',
  );
  @override
  late final GeneratedColumn<int> serverRevision = GeneratedColumn<int>(
    'server_revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startAtMeta = const VerificationMeta(
    'startAt',
  );
  @override
  late final GeneratedColumn<DateTime> startAt = GeneratedColumn<DateTime>(
    'start_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endAtMeta = const VerificationMeta('endAt');
  @override
  late final GeneratedColumn<DateTime> endAt = GeneratedColumn<DateTime>(
    'end_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deadlineAtMeta = const VerificationMeta(
    'deadlineAt',
  );
  @override
  late final GeneratedColumn<DateTime> deadlineAt = GeneratedColumn<DateTime>(
    'deadline_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<double> priority = GeneratedColumn<double>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repeatRuleMeta = const VerificationMeta(
    'repeatRule',
  );
  @override
  late final GeneratedColumn<String> repeatRule = GeneratedColumn<String>(
    'repeat_rule',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('once'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('open'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    syncStatus,
    localRevision,
    serverRevision,
    lastSyncedAt,
    deletedAt,
    id,
    title,
    content,
    location,
    kind,
    startAt,
    endAt,
    deadlineAt,
    priority,
    repeatRule,
    status,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'todo_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<TodoRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('local_revision')) {
      context.handle(
        _localRevisionMeta,
        localRevision.isAcceptableOrUnknown(
          data['local_revision']!,
          _localRevisionMeta,
        ),
      );
    }
    if (data.containsKey('server_revision')) {
      context.handle(
        _serverRevisionMeta,
        serverRevision.isAcceptableOrUnknown(
          data['server_revision']!,
          _serverRevisionMeta,
        ),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('start_at')) {
      context.handle(
        _startAtMeta,
        startAt.isAcceptableOrUnknown(data['start_at']!, _startAtMeta),
      );
    }
    if (data.containsKey('end_at')) {
      context.handle(
        _endAtMeta,
        endAt.isAcceptableOrUnknown(data['end_at']!, _endAtMeta),
      );
    }
    if (data.containsKey('deadline_at')) {
      context.handle(
        _deadlineAtMeta,
        deadlineAt.isAcceptableOrUnknown(data['deadline_at']!, _deadlineAtMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('repeat_rule')) {
      context.handle(
        _repeatRuleMeta,
        repeatRule.isAcceptableOrUnknown(data['repeat_rule']!, _repeatRuleMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TodoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TodoRow(
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      localRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_revision'],
      )!,
      serverRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_revision'],
      ),
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      startAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_at'],
      ),
      endAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_at'],
      ),
      deadlineAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deadline_at'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}priority'],
      )!,
      repeatRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat_rule'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TodoRowsTable createAlias(String alias) {
    return $TodoRowsTable(attachedDatabase, alias);
  }
}

class TodoRow extends DataClass implements Insertable<TodoRow> {
  final String syncStatus;
  final int localRevision;
  final int? serverRevision;
  final DateTime? lastSyncedAt;
  final DateTime? deletedAt;
  final String id;
  final String title;
  final String content;
  final String location;
  final String kind;
  final DateTime? startAt;
  final DateTime? endAt;
  final DateTime? deadlineAt;
  final double priority;
  final String repeatRule;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TodoRow({
    required this.syncStatus,
    required this.localRevision,
    this.serverRevision,
    this.lastSyncedAt,
    this.deletedAt,
    required this.id,
    required this.title,
    required this.content,
    required this.location,
    required this.kind,
    this.startAt,
    this.endAt,
    this.deadlineAt,
    required this.priority,
    required this.repeatRule,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sync_status'] = Variable<String>(syncStatus);
    map['local_revision'] = Variable<int>(localRevision);
    if (!nullToAbsent || serverRevision != null) {
      map['server_revision'] = Variable<int>(serverRevision);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['content'] = Variable<String>(content);
    map['location'] = Variable<String>(location);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || startAt != null) {
      map['start_at'] = Variable<DateTime>(startAt);
    }
    if (!nullToAbsent || endAt != null) {
      map['end_at'] = Variable<DateTime>(endAt);
    }
    if (!nullToAbsent || deadlineAt != null) {
      map['deadline_at'] = Variable<DateTime>(deadlineAt);
    }
    map['priority'] = Variable<double>(priority);
    map['repeat_rule'] = Variable<String>(repeatRule);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TodoRowsCompanion toCompanion(bool nullToAbsent) {
    return TodoRowsCompanion(
      syncStatus: Value(syncStatus),
      localRevision: Value(localRevision),
      serverRevision: serverRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(serverRevision),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      title: Value(title),
      content: Value(content),
      location: Value(location),
      kind: Value(kind),
      startAt: startAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startAt),
      endAt: endAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endAt),
      deadlineAt: deadlineAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deadlineAt),
      priority: Value(priority),
      repeatRule: Value(repeatRule),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TodoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TodoRow(
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      localRevision: serializer.fromJson<int>(json['localRevision']),
      serverRevision: serializer.fromJson<int?>(json['serverRevision']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<String>(json['content']),
      location: serializer.fromJson<String>(json['location']),
      kind: serializer.fromJson<String>(json['kind']),
      startAt: serializer.fromJson<DateTime?>(json['startAt']),
      endAt: serializer.fromJson<DateTime?>(json['endAt']),
      deadlineAt: serializer.fromJson<DateTime?>(json['deadlineAt']),
      priority: serializer.fromJson<double>(json['priority']),
      repeatRule: serializer.fromJson<String>(json['repeatRule']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncStatus': serializer.toJson<String>(syncStatus),
      'localRevision': serializer.toJson<int>(localRevision),
      'serverRevision': serializer.toJson<int?>(serverRevision),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<String>(content),
      'location': serializer.toJson<String>(location),
      'kind': serializer.toJson<String>(kind),
      'startAt': serializer.toJson<DateTime?>(startAt),
      'endAt': serializer.toJson<DateTime?>(endAt),
      'deadlineAt': serializer.toJson<DateTime?>(deadlineAt),
      'priority': serializer.toJson<double>(priority),
      'repeatRule': serializer.toJson<String>(repeatRule),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TodoRow copyWith({
    String? syncStatus,
    int? localRevision,
    Value<int?> serverRevision = const Value.absent(),
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    String? title,
    String? content,
    String? location,
    String? kind,
    Value<DateTime?> startAt = const Value.absent(),
    Value<DateTime?> endAt = const Value.absent(),
    Value<DateTime?> deadlineAt = const Value.absent(),
    double? priority,
    String? repeatRule,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => TodoRow(
    syncStatus: syncStatus ?? this.syncStatus,
    localRevision: localRevision ?? this.localRevision,
    serverRevision: serverRevision.present
        ? serverRevision.value
        : this.serverRevision,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    title: title ?? this.title,
    content: content ?? this.content,
    location: location ?? this.location,
    kind: kind ?? this.kind,
    startAt: startAt.present ? startAt.value : this.startAt,
    endAt: endAt.present ? endAt.value : this.endAt,
    deadlineAt: deadlineAt.present ? deadlineAt.value : this.deadlineAt,
    priority: priority ?? this.priority,
    repeatRule: repeatRule ?? this.repeatRule,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TodoRow copyWithCompanion(TodoRowsCompanion data) {
    return TodoRow(
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      localRevision: data.localRevision.present
          ? data.localRevision.value
          : this.localRevision,
      serverRevision: data.serverRevision.present
          ? data.serverRevision.value
          : this.serverRevision,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
      location: data.location.present ? data.location.value : this.location,
      kind: data.kind.present ? data.kind.value : this.kind,
      startAt: data.startAt.present ? data.startAt.value : this.startAt,
      endAt: data.endAt.present ? data.endAt.value : this.endAt,
      deadlineAt: data.deadlineAt.present
          ? data.deadlineAt.value
          : this.deadlineAt,
      priority: data.priority.present ? data.priority.value : this.priority,
      repeatRule: data.repeatRule.present
          ? data.repeatRule.value
          : this.repeatRule,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TodoRow(')
          ..write('syncStatus: $syncStatus, ')
          ..write('localRevision: $localRevision, ')
          ..write('serverRevision: $serverRevision, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('location: $location, ')
          ..write('kind: $kind, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('deadlineAt: $deadlineAt, ')
          ..write('priority: $priority, ')
          ..write('repeatRule: $repeatRule, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    syncStatus,
    localRevision,
    serverRevision,
    lastSyncedAt,
    deletedAt,
    id,
    title,
    content,
    location,
    kind,
    startAt,
    endAt,
    deadlineAt,
    priority,
    repeatRule,
    status,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TodoRow &&
          other.syncStatus == this.syncStatus &&
          other.localRevision == this.localRevision &&
          other.serverRevision == this.serverRevision &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.title == this.title &&
          other.content == this.content &&
          other.location == this.location &&
          other.kind == this.kind &&
          other.startAt == this.startAt &&
          other.endAt == this.endAt &&
          other.deadlineAt == this.deadlineAt &&
          other.priority == this.priority &&
          other.repeatRule == this.repeatRule &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TodoRowsCompanion extends UpdateCompanion<TodoRow> {
  final Value<String> syncStatus;
  final Value<int> localRevision;
  final Value<int?> serverRevision;
  final Value<DateTime?> lastSyncedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String> title;
  final Value<String> content;
  final Value<String> location;
  final Value<String> kind;
  final Value<DateTime?> startAt;
  final Value<DateTime?> endAt;
  final Value<DateTime?> deadlineAt;
  final Value<double> priority;
  final Value<String> repeatRule;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TodoRowsCompanion({
    this.syncStatus = const Value.absent(),
    this.localRevision = const Value.absent(),
    this.serverRevision = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.location = const Value.absent(),
    this.kind = const Value.absent(),
    this.startAt = const Value.absent(),
    this.endAt = const Value.absent(),
    this.deadlineAt = const Value.absent(),
    this.priority = const Value.absent(),
    this.repeatRule = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TodoRowsCompanion.insert({
    this.syncStatus = const Value.absent(),
    this.localRevision = const Value.absent(),
    this.serverRevision = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String id,
    required String title,
    this.content = const Value.absent(),
    this.location = const Value.absent(),
    required String kind,
    this.startAt = const Value.absent(),
    this.endAt = const Value.absent(),
    this.deadlineAt = const Value.absent(),
    required double priority,
    this.repeatRule = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       kind = Value(kind),
       priority = Value(priority),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TodoRow> custom({
    Expression<String>? syncStatus,
    Expression<int>? localRevision,
    Expression<int>? serverRevision,
    Expression<DateTime>? lastSyncedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? content,
    Expression<String>? location,
    Expression<String>? kind,
    Expression<DateTime>? startAt,
    Expression<DateTime>? endAt,
    Expression<DateTime>? deadlineAt,
    Expression<double>? priority,
    Expression<String>? repeatRule,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncStatus != null) 'sync_status': syncStatus,
      if (localRevision != null) 'local_revision': localRevision,
      if (serverRevision != null) 'server_revision': serverRevision,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (location != null) 'location': location,
      if (kind != null) 'kind': kind,
      if (startAt != null) 'start_at': startAt,
      if (endAt != null) 'end_at': endAt,
      if (deadlineAt != null) 'deadline_at': deadlineAt,
      if (priority != null) 'priority': priority,
      if (repeatRule != null) 'repeat_rule': repeatRule,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TodoRowsCompanion copyWith({
    Value<String>? syncStatus,
    Value<int>? localRevision,
    Value<int?>? serverRevision,
    Value<DateTime?>? lastSyncedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String>? title,
    Value<String>? content,
    Value<String>? location,
    Value<String>? kind,
    Value<DateTime?>? startAt,
    Value<DateTime?>? endAt,
    Value<DateTime?>? deadlineAt,
    Value<double>? priority,
    Value<String>? repeatRule,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return TodoRowsCompanion(
      syncStatus: syncStatus ?? this.syncStatus,
      localRevision: localRevision ?? this.localRevision,
      serverRevision: serverRevision ?? this.serverRevision,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      location: location ?? this.location,
      kind: kind ?? this.kind,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      deadlineAt: deadlineAt ?? this.deadlineAt,
      priority: priority ?? this.priority,
      repeatRule: repeatRule ?? this.repeatRule,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (localRevision.present) {
      map['local_revision'] = Variable<int>(localRevision.value);
    }
    if (serverRevision.present) {
      map['server_revision'] = Variable<int>(serverRevision.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (startAt.present) {
      map['start_at'] = Variable<DateTime>(startAt.value);
    }
    if (endAt.present) {
      map['end_at'] = Variable<DateTime>(endAt.value);
    }
    if (deadlineAt.present) {
      map['deadline_at'] = Variable<DateTime>(deadlineAt.value);
    }
    if (priority.present) {
      map['priority'] = Variable<double>(priority.value);
    }
    if (repeatRule.present) {
      map['repeat_rule'] = Variable<String>(repeatRule.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TodoRowsCompanion(')
          ..write('syncStatus: $syncStatus, ')
          ..write('localRevision: $localRevision, ')
          ..write('serverRevision: $serverRevision, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('location: $location, ')
          ..write('kind: $kind, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('deadlineAt: $deadlineAt, ')
          ..write('priority: $priority, ')
          ..write('repeatRule: $repeatRule, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagRowsTable extends TagRows with TableInfo<$TagRowsTable, TagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tag_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<TagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  TagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagRow(
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TagRowsTable createAlias(String alias) {
    return $TagRowsTable(attachedDatabase, alias);
  }
}

class TagRow extends DataClass implements Insertable<TagRow> {
  final String name;
  final DateTime createdAt;
  const TagRow({required this.name, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TagRowsCompanion toCompanion(bool nullToAbsent) {
    return TagRowsCompanion(name: Value(name), createdAt: Value(createdAt));
  }

  factory TagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagRow(
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TagRow copyWith({String? name, DateTime? createdAt}) =>
      TagRow(name: name ?? this.name, createdAt: createdAt ?? this.createdAt);
  TagRow copyWithCompanion(TagRowsCompanion data) {
    return TagRow(
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagRow(')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagRow &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class TagRowsCompanion extends UpdateCompanion<TagRow> {
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TagRowsCompanion({
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagRowsCompanion.insert({
    required String name,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<TagRow> custom({
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagRowsCompanion copyWith({
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TagRowsCompanion(
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagRowsCompanion(')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TodoTagRowsTable extends TodoTagRows
    with TableInfo<$TodoTagRowsTable, TodoTagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TodoTagRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _todoIdMeta = const VerificationMeta('todoId');
  @override
  late final GeneratedColumn<String> todoId = GeneratedColumn<String>(
    'todo_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagNameMeta = const VerificationMeta(
    'tagName',
  );
  @override
  late final GeneratedColumn<String> tagName = GeneratedColumn<String>(
    'tag_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [todoId, tagName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'todo_tag_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<TodoTagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('todo_id')) {
      context.handle(
        _todoIdMeta,
        todoId.isAcceptableOrUnknown(data['todo_id']!, _todoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_todoIdMeta);
    }
    if (data.containsKey('tag_name')) {
      context.handle(
        _tagNameMeta,
        tagName.isAcceptableOrUnknown(data['tag_name']!, _tagNameMeta),
      );
    } else if (isInserting) {
      context.missing(_tagNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {todoId, tagName};
  @override
  TodoTagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TodoTagRow(
      todoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}todo_id'],
      )!,
      tagName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_name'],
      )!,
    );
  }

  @override
  $TodoTagRowsTable createAlias(String alias) {
    return $TodoTagRowsTable(attachedDatabase, alias);
  }
}

class TodoTagRow extends DataClass implements Insertable<TodoTagRow> {
  final String todoId;
  final String tagName;
  const TodoTagRow({required this.todoId, required this.tagName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['todo_id'] = Variable<String>(todoId);
    map['tag_name'] = Variable<String>(tagName);
    return map;
  }

  TodoTagRowsCompanion toCompanion(bool nullToAbsent) {
    return TodoTagRowsCompanion(todoId: Value(todoId), tagName: Value(tagName));
  }

  factory TodoTagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TodoTagRow(
      todoId: serializer.fromJson<String>(json['todoId']),
      tagName: serializer.fromJson<String>(json['tagName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'todoId': serializer.toJson<String>(todoId),
      'tagName': serializer.toJson<String>(tagName),
    };
  }

  TodoTagRow copyWith({String? todoId, String? tagName}) => TodoTagRow(
    todoId: todoId ?? this.todoId,
    tagName: tagName ?? this.tagName,
  );
  TodoTagRow copyWithCompanion(TodoTagRowsCompanion data) {
    return TodoTagRow(
      todoId: data.todoId.present ? data.todoId.value : this.todoId,
      tagName: data.tagName.present ? data.tagName.value : this.tagName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TodoTagRow(')
          ..write('todoId: $todoId, ')
          ..write('tagName: $tagName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(todoId, tagName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TodoTagRow &&
          other.todoId == this.todoId &&
          other.tagName == this.tagName);
}

class TodoTagRowsCompanion extends UpdateCompanion<TodoTagRow> {
  final Value<String> todoId;
  final Value<String> tagName;
  final Value<int> rowid;
  const TodoTagRowsCompanion({
    this.todoId = const Value.absent(),
    this.tagName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TodoTagRowsCompanion.insert({
    required String todoId,
    required String tagName,
    this.rowid = const Value.absent(),
  }) : todoId = Value(todoId),
       tagName = Value(tagName);
  static Insertable<TodoTagRow> custom({
    Expression<String>? todoId,
    Expression<String>? tagName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (todoId != null) 'todo_id': todoId,
      if (tagName != null) 'tag_name': tagName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TodoTagRowsCompanion copyWith({
    Value<String>? todoId,
    Value<String>? tagName,
    Value<int>? rowid,
  }) {
    return TodoTagRowsCompanion(
      todoId: todoId ?? this.todoId,
      tagName: tagName ?? this.tagName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (todoId.present) {
      map['todo_id'] = Variable<String>(todoId.value);
    }
    if (tagName.present) {
      map['tag_name'] = Variable<String>(tagName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TodoTagRowsCompanion(')
          ..write('todoId: $todoId, ')
          ..write('tagName: $tagName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SemesterSettingsRowsTable extends SemesterSettingsRows
    with TableInfo<$SemesterSettingsRowsTable, SemesterSettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SemesterSettingsRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _semesterStartDateMeta = const VerificationMeta(
    'semesterStartDate',
  );
  @override
  late final GeneratedColumn<DateTime> semesterStartDate =
      GeneratedColumn<DateTime>(
        'semester_start_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, semesterStartDate, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'semester_settings_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<SemesterSettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('semester_start_date')) {
      context.handle(
        _semesterStartDateMeta,
        semesterStartDate.isAcceptableOrUnknown(
          data['semester_start_date']!,
          _semesterStartDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_semesterStartDateMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SemesterSettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SemesterSettingsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      semesterStartDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}semester_start_date'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SemesterSettingsRowsTable createAlias(String alias) {
    return $SemesterSettingsRowsTable(attachedDatabase, alias);
  }
}

class SemesterSettingsRow extends DataClass
    implements Insertable<SemesterSettingsRow> {
  final int id;
  final DateTime semesterStartDate;
  final DateTime updatedAt;
  const SemesterSettingsRow({
    required this.id,
    required this.semesterStartDate,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['semester_start_date'] = Variable<DateTime>(semesterStartDate);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SemesterSettingsRowsCompanion toCompanion(bool nullToAbsent) {
    return SemesterSettingsRowsCompanion(
      id: Value(id),
      semesterStartDate: Value(semesterStartDate),
      updatedAt: Value(updatedAt),
    );
  }

  factory SemesterSettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SemesterSettingsRow(
      id: serializer.fromJson<int>(json['id']),
      semesterStartDate: serializer.fromJson<DateTime>(
        json['semesterStartDate'],
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'semesterStartDate': serializer.toJson<DateTime>(semesterStartDate),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SemesterSettingsRow copyWith({
    int? id,
    DateTime? semesterStartDate,
    DateTime? updatedAt,
  }) => SemesterSettingsRow(
    id: id ?? this.id,
    semesterStartDate: semesterStartDate ?? this.semesterStartDate,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SemesterSettingsRow copyWithCompanion(SemesterSettingsRowsCompanion data) {
    return SemesterSettingsRow(
      id: data.id.present ? data.id.value : this.id,
      semesterStartDate: data.semesterStartDate.present
          ? data.semesterStartDate.value
          : this.semesterStartDate,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SemesterSettingsRow(')
          ..write('id: $id, ')
          ..write('semesterStartDate: $semesterStartDate, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, semesterStartDate, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SemesterSettingsRow &&
          other.id == this.id &&
          other.semesterStartDate == this.semesterStartDate &&
          other.updatedAt == this.updatedAt);
}

class SemesterSettingsRowsCompanion
    extends UpdateCompanion<SemesterSettingsRow> {
  final Value<int> id;
  final Value<DateTime> semesterStartDate;
  final Value<DateTime> updatedAt;
  const SemesterSettingsRowsCompanion({
    this.id = const Value.absent(),
    this.semesterStartDate = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SemesterSettingsRowsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime semesterStartDate,
    required DateTime updatedAt,
  }) : semesterStartDate = Value(semesterStartDate),
       updatedAt = Value(updatedAt);
  static Insertable<SemesterSettingsRow> custom({
    Expression<int>? id,
    Expression<DateTime>? semesterStartDate,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (semesterStartDate != null) 'semester_start_date': semesterStartDate,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SemesterSettingsRowsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? semesterStartDate,
    Value<DateTime>? updatedAt,
  }) {
    return SemesterSettingsRowsCompanion(
      id: id ?? this.id,
      semesterStartDate: semesterStartDate ?? this.semesterStartDate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (semesterStartDate.present) {
      map['semester_start_date'] = Variable<DateTime>(semesterStartDate.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SemesterSettingsRowsCompanion(')
          ..write('id: $id, ')
          ..write('semesterStartDate: $semesterStartDate, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PeriodTimeRowsTable extends PeriodTimeRows
    with TableInfo<$PeriodTimeRowsTable, PeriodTimeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PeriodTimeRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<int> period = GeneratedColumn<int>(
    'period',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startMeta = const VerificationMeta('start');
  @override
  late final GeneratedColumn<String> start = GeneratedColumn<String>(
    'start',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMeta = const VerificationMeta('end');
  @override
  late final GeneratedColumn<String> end = GeneratedColumn<String>(
    'end',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [period, start, end];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'period_time_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<PeriodTimeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('period')) {
      context.handle(
        _periodMeta,
        period.isAcceptableOrUnknown(data['period']!, _periodMeta),
      );
    }
    if (data.containsKey('start')) {
      context.handle(
        _startMeta,
        start.isAcceptableOrUnknown(data['start']!, _startMeta),
      );
    } else if (isInserting) {
      context.missing(_startMeta);
    }
    if (data.containsKey('end')) {
      context.handle(
        _endMeta,
        end.isAcceptableOrUnknown(data['end']!, _endMeta),
      );
    } else if (isInserting) {
      context.missing(_endMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {period};
  @override
  PeriodTimeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PeriodTimeRow(
      period: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}period'],
      )!,
      start: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start'],
      )!,
      end: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end'],
      )!,
    );
  }

  @override
  $PeriodTimeRowsTable createAlias(String alias) {
    return $PeriodTimeRowsTable(attachedDatabase, alias);
  }
}

class PeriodTimeRow extends DataClass implements Insertable<PeriodTimeRow> {
  final int period;
  final String start;
  final String end;
  const PeriodTimeRow({
    required this.period,
    required this.start,
    required this.end,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['period'] = Variable<int>(period);
    map['start'] = Variable<String>(start);
    map['end'] = Variable<String>(end);
    return map;
  }

  PeriodTimeRowsCompanion toCompanion(bool nullToAbsent) {
    return PeriodTimeRowsCompanion(
      period: Value(period),
      start: Value(start),
      end: Value(end),
    );
  }

  factory PeriodTimeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PeriodTimeRow(
      period: serializer.fromJson<int>(json['period']),
      start: serializer.fromJson<String>(json['start']),
      end: serializer.fromJson<String>(json['end']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'period': serializer.toJson<int>(period),
      'start': serializer.toJson<String>(start),
      'end': serializer.toJson<String>(end),
    };
  }

  PeriodTimeRow copyWith({int? period, String? start, String? end}) =>
      PeriodTimeRow(
        period: period ?? this.period,
        start: start ?? this.start,
        end: end ?? this.end,
      );
  PeriodTimeRow copyWithCompanion(PeriodTimeRowsCompanion data) {
    return PeriodTimeRow(
      period: data.period.present ? data.period.value : this.period,
      start: data.start.present ? data.start.value : this.start,
      end: data.end.present ? data.end.value : this.end,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PeriodTimeRow(')
          ..write('period: $period, ')
          ..write('start: $start, ')
          ..write('end: $end')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(period, start, end);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PeriodTimeRow &&
          other.period == this.period &&
          other.start == this.start &&
          other.end == this.end);
}

class PeriodTimeRowsCompanion extends UpdateCompanion<PeriodTimeRow> {
  final Value<int> period;
  final Value<String> start;
  final Value<String> end;
  const PeriodTimeRowsCompanion({
    this.period = const Value.absent(),
    this.start = const Value.absent(),
    this.end = const Value.absent(),
  });
  PeriodTimeRowsCompanion.insert({
    this.period = const Value.absent(),
    required String start,
    required String end,
  }) : start = Value(start),
       end = Value(end);
  static Insertable<PeriodTimeRow> custom({
    Expression<int>? period,
    Expression<String>? start,
    Expression<String>? end,
  }) {
    return RawValuesInsertable({
      if (period != null) 'period': period,
      if (start != null) 'start': start,
      if (end != null) 'end': end,
    });
  }

  PeriodTimeRowsCompanion copyWith({
    Value<int>? period,
    Value<String>? start,
    Value<String>? end,
  }) {
    return PeriodTimeRowsCompanion(
      period: period ?? this.period,
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (period.present) {
      map['period'] = Variable<int>(period.value);
    }
    if (start.present) {
      map['start'] = Variable<String>(start.value);
    }
    if (end.present) {
      map['end'] = Variable<String>(end.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PeriodTimeRowsCompanion(')
          ..write('period: $period, ')
          ..write('start: $start, ')
          ..write('end: $end')
          ..write(')'))
        .toString();
  }
}

class $SearchHistoryRowsTable extends SearchHistoryRows
    with TableInfo<$SearchHistoryRowsTable, SearchHistoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SearchHistoryRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _queryMeta = const VerificationMeta('query');
  @override
  late final GeneratedColumn<String> query = GeneratedColumn<String>(
    'query',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _searchedAtMeta = const VerificationMeta(
    'searchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> searchedAt = GeneratedColumn<DateTime>(
    'searched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, query, searchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'search_history_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<SearchHistoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('query')) {
      context.handle(
        _queryMeta,
        query.isAcceptableOrUnknown(data['query']!, _queryMeta),
      );
    } else if (isInserting) {
      context.missing(_queryMeta);
    }
    if (data.containsKey('searched_at')) {
      context.handle(
        _searchedAtMeta,
        searchedAt.isAcceptableOrUnknown(data['searched_at']!, _searchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_searchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SearchHistoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SearchHistoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      query: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}query'],
      )!,
      searchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}searched_at'],
      )!,
    );
  }

  @override
  $SearchHistoryRowsTable createAlias(String alias) {
    return $SearchHistoryRowsTable(attachedDatabase, alias);
  }
}

class SearchHistoryRow extends DataClass
    implements Insertable<SearchHistoryRow> {
  final int id;
  final String query;
  final DateTime searchedAt;
  const SearchHistoryRow({
    required this.id,
    required this.query,
    required this.searchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['query'] = Variable<String>(query);
    map['searched_at'] = Variable<DateTime>(searchedAt);
    return map;
  }

  SearchHistoryRowsCompanion toCompanion(bool nullToAbsent) {
    return SearchHistoryRowsCompanion(
      id: Value(id),
      query: Value(query),
      searchedAt: Value(searchedAt),
    );
  }

  factory SearchHistoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SearchHistoryRow(
      id: serializer.fromJson<int>(json['id']),
      query: serializer.fromJson<String>(json['query']),
      searchedAt: serializer.fromJson<DateTime>(json['searchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'query': serializer.toJson<String>(query),
      'searchedAt': serializer.toJson<DateTime>(searchedAt),
    };
  }

  SearchHistoryRow copyWith({int? id, String? query, DateTime? searchedAt}) =>
      SearchHistoryRow(
        id: id ?? this.id,
        query: query ?? this.query,
        searchedAt: searchedAt ?? this.searchedAt,
      );
  SearchHistoryRow copyWithCompanion(SearchHistoryRowsCompanion data) {
    return SearchHistoryRow(
      id: data.id.present ? data.id.value : this.id,
      query: data.query.present ? data.query.value : this.query,
      searchedAt: data.searchedAt.present
          ? data.searchedAt.value
          : this.searchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SearchHistoryRow(')
          ..write('id: $id, ')
          ..write('query: $query, ')
          ..write('searchedAt: $searchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, query, searchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SearchHistoryRow &&
          other.id == this.id &&
          other.query == this.query &&
          other.searchedAt == this.searchedAt);
}

class SearchHistoryRowsCompanion extends UpdateCompanion<SearchHistoryRow> {
  final Value<int> id;
  final Value<String> query;
  final Value<DateTime> searchedAt;
  const SearchHistoryRowsCompanion({
    this.id = const Value.absent(),
    this.query = const Value.absent(),
    this.searchedAt = const Value.absent(),
  });
  SearchHistoryRowsCompanion.insert({
    this.id = const Value.absent(),
    required String query,
    required DateTime searchedAt,
  }) : query = Value(query),
       searchedAt = Value(searchedAt);
  static Insertable<SearchHistoryRow> custom({
    Expression<int>? id,
    Expression<String>? query,
    Expression<DateTime>? searchedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (query != null) 'query': query,
      if (searchedAt != null) 'searched_at': searchedAt,
    });
  }

  SearchHistoryRowsCompanion copyWith({
    Value<int>? id,
    Value<String>? query,
    Value<DateTime>? searchedAt,
  }) {
    return SearchHistoryRowsCompanion(
      id: id ?? this.id,
      query: query ?? this.query,
      searchedAt: searchedAt ?? this.searchedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (query.present) {
      map['query'] = Variable<String>(query.value);
    }
    if (searchedAt.present) {
      map['searched_at'] = Variable<DateTime>(searchedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SearchHistoryRowsCompanion(')
          ..write('id: $id, ')
          ..write('query: $query, ')
          ..write('searchedAt: $searchedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CourseRowsTable courseRows = $CourseRowsTable(this);
  late final $TodoRowsTable todoRows = $TodoRowsTable(this);
  late final $TagRowsTable tagRows = $TagRowsTable(this);
  late final $TodoTagRowsTable todoTagRows = $TodoTagRowsTable(this);
  late final $SemesterSettingsRowsTable semesterSettingsRows =
      $SemesterSettingsRowsTable(this);
  late final $PeriodTimeRowsTable periodTimeRows = $PeriodTimeRowsTable(this);
  late final $SearchHistoryRowsTable searchHistoryRows =
      $SearchHistoryRowsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    courseRows,
    todoRows,
    tagRows,
    todoTagRows,
    semesterSettingsRows,
    periodTimeRows,
    searchHistoryRows,
  ];
}

typedef $$CourseRowsTableCreateCompanionBuilder =
    CourseRowsCompanion Function({
      Value<String> syncStatus,
      Value<int> localRevision,
      Value<int?> serverRevision,
      Value<DateTime?> lastSyncedAt,
      Value<DateTime?> deletedAt,
      required String id,
      required String name,
      required String teacher,
      required String location,
      required String note,
      required int dayOfWeek,
      required int startPeriod,
      required int endPeriod,
      required String weekRule,
      required int startWeek,
      required int endWeek,
      required String colorKey,
      required String source,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CourseRowsTableUpdateCompanionBuilder =
    CourseRowsCompanion Function({
      Value<String> syncStatus,
      Value<int> localRevision,
      Value<int?> serverRevision,
      Value<DateTime?> lastSyncedAt,
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<String> name,
      Value<String> teacher,
      Value<String> location,
      Value<String> note,
      Value<int> dayOfWeek,
      Value<int> startPeriod,
      Value<int> endPeriod,
      Value<String> weekRule,
      Value<int> startWeek,
      Value<int> endWeek,
      Value<String> colorKey,
      Value<String> source,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CourseRowsTableFilterComposer
    extends Composer<_$AppDatabase, $CourseRowsTable> {
  $$CourseRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverRevision => $composableBuilder(
    column: $table.serverRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teacher => $composableBuilder(
    column: $table.teacher,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayOfWeek => $composableBuilder(
    column: $table.dayOfWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startPeriod => $composableBuilder(
    column: $table.startPeriod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endPeriod => $composableBuilder(
    column: $table.endPeriod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weekRule => $composableBuilder(
    column: $table.weekRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startWeek => $composableBuilder(
    column: $table.startWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endWeek => $composableBuilder(
    column: $table.endWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorKey => $composableBuilder(
    column: $table.colorKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CourseRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $CourseRowsTable> {
  $$CourseRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverRevision => $composableBuilder(
    column: $table.serverRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teacher => $composableBuilder(
    column: $table.teacher,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayOfWeek => $composableBuilder(
    column: $table.dayOfWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startPeriod => $composableBuilder(
    column: $table.startPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endPeriod => $composableBuilder(
    column: $table.endPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weekRule => $composableBuilder(
    column: $table.weekRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startWeek => $composableBuilder(
    column: $table.startWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endWeek => $composableBuilder(
    column: $table.endWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorKey => $composableBuilder(
    column: $table.colorKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CourseRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CourseRowsTable> {
  $$CourseRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverRevision => $composableBuilder(
    column: $table.serverRevision,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get teacher =>
      $composableBuilder(column: $table.teacher, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get dayOfWeek =>
      $composableBuilder(column: $table.dayOfWeek, builder: (column) => column);

  GeneratedColumn<int> get startPeriod => $composableBuilder(
    column: $table.startPeriod,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endPeriod =>
      $composableBuilder(column: $table.endPeriod, builder: (column) => column);

  GeneratedColumn<String> get weekRule =>
      $composableBuilder(column: $table.weekRule, builder: (column) => column);

  GeneratedColumn<int> get startWeek =>
      $composableBuilder(column: $table.startWeek, builder: (column) => column);

  GeneratedColumn<int> get endWeek =>
      $composableBuilder(column: $table.endWeek, builder: (column) => column);

  GeneratedColumn<String> get colorKey =>
      $composableBuilder(column: $table.colorKey, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CourseRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CourseRowsTable,
          CourseRow,
          $$CourseRowsTableFilterComposer,
          $$CourseRowsTableOrderingComposer,
          $$CourseRowsTableAnnotationComposer,
          $$CourseRowsTableCreateCompanionBuilder,
          $$CourseRowsTableUpdateCompanionBuilder,
          (
            CourseRow,
            BaseReferences<_$AppDatabase, $CourseRowsTable, CourseRow>,
          ),
          CourseRow,
          PrefetchHooks Function()
        > {
  $$CourseRowsTableTableManager(_$AppDatabase db, $CourseRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CourseRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CourseRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CourseRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> syncStatus = const Value.absent(),
                Value<int> localRevision = const Value.absent(),
                Value<int?> serverRevision = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> teacher = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> dayOfWeek = const Value.absent(),
                Value<int> startPeriod = const Value.absent(),
                Value<int> endPeriod = const Value.absent(),
                Value<String> weekRule = const Value.absent(),
                Value<int> startWeek = const Value.absent(),
                Value<int> endWeek = const Value.absent(),
                Value<String> colorKey = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CourseRowsCompanion(
                syncStatus: syncStatus,
                localRevision: localRevision,
                serverRevision: serverRevision,
                lastSyncedAt: lastSyncedAt,
                deletedAt: deletedAt,
                id: id,
                name: name,
                teacher: teacher,
                location: location,
                note: note,
                dayOfWeek: dayOfWeek,
                startPeriod: startPeriod,
                endPeriod: endPeriod,
                weekRule: weekRule,
                startWeek: startWeek,
                endWeek: endWeek,
                colorKey: colorKey,
                source: source,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> syncStatus = const Value.absent(),
                Value<int> localRevision = const Value.absent(),
                Value<int?> serverRevision = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                required String name,
                required String teacher,
                required String location,
                required String note,
                required int dayOfWeek,
                required int startPeriod,
                required int endPeriod,
                required String weekRule,
                required int startWeek,
                required int endWeek,
                required String colorKey,
                required String source,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CourseRowsCompanion.insert(
                syncStatus: syncStatus,
                localRevision: localRevision,
                serverRevision: serverRevision,
                lastSyncedAt: lastSyncedAt,
                deletedAt: deletedAt,
                id: id,
                name: name,
                teacher: teacher,
                location: location,
                note: note,
                dayOfWeek: dayOfWeek,
                startPeriod: startPeriod,
                endPeriod: endPeriod,
                weekRule: weekRule,
                startWeek: startWeek,
                endWeek: endWeek,
                colorKey: colorKey,
                source: source,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CourseRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CourseRowsTable,
      CourseRow,
      $$CourseRowsTableFilterComposer,
      $$CourseRowsTableOrderingComposer,
      $$CourseRowsTableAnnotationComposer,
      $$CourseRowsTableCreateCompanionBuilder,
      $$CourseRowsTableUpdateCompanionBuilder,
      (CourseRow, BaseReferences<_$AppDatabase, $CourseRowsTable, CourseRow>),
      CourseRow,
      PrefetchHooks Function()
    >;
typedef $$TodoRowsTableCreateCompanionBuilder =
    TodoRowsCompanion Function({
      Value<String> syncStatus,
      Value<int> localRevision,
      Value<int?> serverRevision,
      Value<DateTime?> lastSyncedAt,
      Value<DateTime?> deletedAt,
      required String id,
      required String title,
      Value<String> content,
      Value<String> location,
      required String kind,
      Value<DateTime?> startAt,
      Value<DateTime?> endAt,
      Value<DateTime?> deadlineAt,
      required double priority,
      Value<String> repeatRule,
      Value<String> status,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$TodoRowsTableUpdateCompanionBuilder =
    TodoRowsCompanion Function({
      Value<String> syncStatus,
      Value<int> localRevision,
      Value<int?> serverRevision,
      Value<DateTime?> lastSyncedAt,
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<String> title,
      Value<String> content,
      Value<String> location,
      Value<String> kind,
      Value<DateTime?> startAt,
      Value<DateTime?> endAt,
      Value<DateTime?> deadlineAt,
      Value<double> priority,
      Value<String> repeatRule,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$TodoRowsTableFilterComposer
    extends Composer<_$AppDatabase, $TodoRowsTable> {
  $$TodoRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverRevision => $composableBuilder(
    column: $table.serverRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startAt => $composableBuilder(
    column: $table.startAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endAt => $composableBuilder(
    column: $table.endAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deadlineAt => $composableBuilder(
    column: $table.deadlineAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeatRule => $composableBuilder(
    column: $table.repeatRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TodoRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $TodoRowsTable> {
  $$TodoRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverRevision => $composableBuilder(
    column: $table.serverRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startAt => $composableBuilder(
    column: $table.startAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endAt => $composableBuilder(
    column: $table.endAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deadlineAt => $composableBuilder(
    column: $table.deadlineAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeatRule => $composableBuilder(
    column: $table.repeatRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TodoRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TodoRowsTable> {
  $$TodoRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverRevision => $composableBuilder(
    column: $table.serverRevision,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<DateTime> get startAt =>
      $composableBuilder(column: $table.startAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endAt =>
      $composableBuilder(column: $table.endAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deadlineAt => $composableBuilder(
    column: $table.deadlineAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get repeatRule => $composableBuilder(
    column: $table.repeatRule,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TodoRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TodoRowsTable,
          TodoRow,
          $$TodoRowsTableFilterComposer,
          $$TodoRowsTableOrderingComposer,
          $$TodoRowsTableAnnotationComposer,
          $$TodoRowsTableCreateCompanionBuilder,
          $$TodoRowsTableUpdateCompanionBuilder,
          (TodoRow, BaseReferences<_$AppDatabase, $TodoRowsTable, TodoRow>),
          TodoRow,
          PrefetchHooks Function()
        > {
  $$TodoRowsTableTableManager(_$AppDatabase db, $TodoRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TodoRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TodoRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TodoRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> syncStatus = const Value.absent(),
                Value<int> localRevision = const Value.absent(),
                Value<int?> serverRevision = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<DateTime?> startAt = const Value.absent(),
                Value<DateTime?> endAt = const Value.absent(),
                Value<DateTime?> deadlineAt = const Value.absent(),
                Value<double> priority = const Value.absent(),
                Value<String> repeatRule = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TodoRowsCompanion(
                syncStatus: syncStatus,
                localRevision: localRevision,
                serverRevision: serverRevision,
                lastSyncedAt: lastSyncedAt,
                deletedAt: deletedAt,
                id: id,
                title: title,
                content: content,
                location: location,
                kind: kind,
                startAt: startAt,
                endAt: endAt,
                deadlineAt: deadlineAt,
                priority: priority,
                repeatRule: repeatRule,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> syncStatus = const Value.absent(),
                Value<int> localRevision = const Value.absent(),
                Value<int?> serverRevision = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                required String title,
                Value<String> content = const Value.absent(),
                Value<String> location = const Value.absent(),
                required String kind,
                Value<DateTime?> startAt = const Value.absent(),
                Value<DateTime?> endAt = const Value.absent(),
                Value<DateTime?> deadlineAt = const Value.absent(),
                required double priority,
                Value<String> repeatRule = const Value.absent(),
                Value<String> status = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TodoRowsCompanion.insert(
                syncStatus: syncStatus,
                localRevision: localRevision,
                serverRevision: serverRevision,
                lastSyncedAt: lastSyncedAt,
                deletedAt: deletedAt,
                id: id,
                title: title,
                content: content,
                location: location,
                kind: kind,
                startAt: startAt,
                endAt: endAt,
                deadlineAt: deadlineAt,
                priority: priority,
                repeatRule: repeatRule,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TodoRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TodoRowsTable,
      TodoRow,
      $$TodoRowsTableFilterComposer,
      $$TodoRowsTableOrderingComposer,
      $$TodoRowsTableAnnotationComposer,
      $$TodoRowsTableCreateCompanionBuilder,
      $$TodoRowsTableUpdateCompanionBuilder,
      (TodoRow, BaseReferences<_$AppDatabase, $TodoRowsTable, TodoRow>),
      TodoRow,
      PrefetchHooks Function()
    >;
typedef $$TagRowsTableCreateCompanionBuilder =
    TagRowsCompanion Function({
      required String name,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$TagRowsTableUpdateCompanionBuilder =
    TagRowsCompanion Function({
      Value<String> name,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$TagRowsTableFilterComposer
    extends Composer<_$AppDatabase, $TagRowsTable> {
  $$TagRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TagRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $TagRowsTable> {
  $$TagRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagRowsTable> {
  $$TagRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TagRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagRowsTable,
          TagRow,
          $$TagRowsTableFilterComposer,
          $$TagRowsTableOrderingComposer,
          $$TagRowsTableAnnotationComposer,
          $$TagRowsTableCreateCompanionBuilder,
          $$TagRowsTableUpdateCompanionBuilder,
          (TagRow, BaseReferences<_$AppDatabase, $TagRowsTable, TagRow>),
          TagRow,
          PrefetchHooks Function()
        > {
  $$TagRowsTableTableManager(_$AppDatabase db, $TagRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagRowsCompanion(
                name: name,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String name,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => TagRowsCompanion.insert(
                name: name,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TagRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagRowsTable,
      TagRow,
      $$TagRowsTableFilterComposer,
      $$TagRowsTableOrderingComposer,
      $$TagRowsTableAnnotationComposer,
      $$TagRowsTableCreateCompanionBuilder,
      $$TagRowsTableUpdateCompanionBuilder,
      (TagRow, BaseReferences<_$AppDatabase, $TagRowsTable, TagRow>),
      TagRow,
      PrefetchHooks Function()
    >;
typedef $$TodoTagRowsTableCreateCompanionBuilder =
    TodoTagRowsCompanion Function({
      required String todoId,
      required String tagName,
      Value<int> rowid,
    });
typedef $$TodoTagRowsTableUpdateCompanionBuilder =
    TodoTagRowsCompanion Function({
      Value<String> todoId,
      Value<String> tagName,
      Value<int> rowid,
    });

class $$TodoTagRowsTableFilterComposer
    extends Composer<_$AppDatabase, $TodoTagRowsTable> {
  $$TodoTagRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get todoId => $composableBuilder(
    column: $table.todoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagName => $composableBuilder(
    column: $table.tagName,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TodoTagRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $TodoTagRowsTable> {
  $$TodoTagRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get todoId => $composableBuilder(
    column: $table.todoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagName => $composableBuilder(
    column: $table.tagName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TodoTagRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TodoTagRowsTable> {
  $$TodoTagRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get todoId =>
      $composableBuilder(column: $table.todoId, builder: (column) => column);

  GeneratedColumn<String> get tagName =>
      $composableBuilder(column: $table.tagName, builder: (column) => column);
}

class $$TodoTagRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TodoTagRowsTable,
          TodoTagRow,
          $$TodoTagRowsTableFilterComposer,
          $$TodoTagRowsTableOrderingComposer,
          $$TodoTagRowsTableAnnotationComposer,
          $$TodoTagRowsTableCreateCompanionBuilder,
          $$TodoTagRowsTableUpdateCompanionBuilder,
          (
            TodoTagRow,
            BaseReferences<_$AppDatabase, $TodoTagRowsTable, TodoTagRow>,
          ),
          TodoTagRow,
          PrefetchHooks Function()
        > {
  $$TodoTagRowsTableTableManager(_$AppDatabase db, $TodoTagRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TodoTagRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TodoTagRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TodoTagRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> todoId = const Value.absent(),
                Value<String> tagName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TodoTagRowsCompanion(
                todoId: todoId,
                tagName: tagName,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String todoId,
                required String tagName,
                Value<int> rowid = const Value.absent(),
              }) => TodoTagRowsCompanion.insert(
                todoId: todoId,
                tagName: tagName,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TodoTagRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TodoTagRowsTable,
      TodoTagRow,
      $$TodoTagRowsTableFilterComposer,
      $$TodoTagRowsTableOrderingComposer,
      $$TodoTagRowsTableAnnotationComposer,
      $$TodoTagRowsTableCreateCompanionBuilder,
      $$TodoTagRowsTableUpdateCompanionBuilder,
      (
        TodoTagRow,
        BaseReferences<_$AppDatabase, $TodoTagRowsTable, TodoTagRow>,
      ),
      TodoTagRow,
      PrefetchHooks Function()
    >;
typedef $$SemesterSettingsRowsTableCreateCompanionBuilder =
    SemesterSettingsRowsCompanion Function({
      Value<int> id,
      required DateTime semesterStartDate,
      required DateTime updatedAt,
    });
typedef $$SemesterSettingsRowsTableUpdateCompanionBuilder =
    SemesterSettingsRowsCompanion Function({
      Value<int> id,
      Value<DateTime> semesterStartDate,
      Value<DateTime> updatedAt,
    });

class $$SemesterSettingsRowsTableFilterComposer
    extends Composer<_$AppDatabase, $SemesterSettingsRowsTable> {
  $$SemesterSettingsRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get semesterStartDate => $composableBuilder(
    column: $table.semesterStartDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SemesterSettingsRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $SemesterSettingsRowsTable> {
  $$SemesterSettingsRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get semesterStartDate => $composableBuilder(
    column: $table.semesterStartDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SemesterSettingsRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SemesterSettingsRowsTable> {
  $$SemesterSettingsRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get semesterStartDate => $composableBuilder(
    column: $table.semesterStartDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SemesterSettingsRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SemesterSettingsRowsTable,
          SemesterSettingsRow,
          $$SemesterSettingsRowsTableFilterComposer,
          $$SemesterSettingsRowsTableOrderingComposer,
          $$SemesterSettingsRowsTableAnnotationComposer,
          $$SemesterSettingsRowsTableCreateCompanionBuilder,
          $$SemesterSettingsRowsTableUpdateCompanionBuilder,
          (
            SemesterSettingsRow,
            BaseReferences<
              _$AppDatabase,
              $SemesterSettingsRowsTable,
              SemesterSettingsRow
            >,
          ),
          SemesterSettingsRow,
          PrefetchHooks Function()
        > {
  $$SemesterSettingsRowsTableTableManager(
    _$AppDatabase db,
    $SemesterSettingsRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SemesterSettingsRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SemesterSettingsRowsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SemesterSettingsRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> semesterStartDate = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => SemesterSettingsRowsCompanion(
                id: id,
                semesterStartDate: semesterStartDate,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime semesterStartDate,
                required DateTime updatedAt,
              }) => SemesterSettingsRowsCompanion.insert(
                id: id,
                semesterStartDate: semesterStartDate,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SemesterSettingsRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SemesterSettingsRowsTable,
      SemesterSettingsRow,
      $$SemesterSettingsRowsTableFilterComposer,
      $$SemesterSettingsRowsTableOrderingComposer,
      $$SemesterSettingsRowsTableAnnotationComposer,
      $$SemesterSettingsRowsTableCreateCompanionBuilder,
      $$SemesterSettingsRowsTableUpdateCompanionBuilder,
      (
        SemesterSettingsRow,
        BaseReferences<
          _$AppDatabase,
          $SemesterSettingsRowsTable,
          SemesterSettingsRow
        >,
      ),
      SemesterSettingsRow,
      PrefetchHooks Function()
    >;
typedef $$PeriodTimeRowsTableCreateCompanionBuilder =
    PeriodTimeRowsCompanion Function({
      Value<int> period,
      required String start,
      required String end,
    });
typedef $$PeriodTimeRowsTableUpdateCompanionBuilder =
    PeriodTimeRowsCompanion Function({
      Value<int> period,
      Value<String> start,
      Value<String> end,
    });

class $$PeriodTimeRowsTableFilterComposer
    extends Composer<_$AppDatabase, $PeriodTimeRowsTable> {
  $$PeriodTimeRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get start => $composableBuilder(
    column: $table.start,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get end => $composableBuilder(
    column: $table.end,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PeriodTimeRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $PeriodTimeRowsTable> {
  $$PeriodTimeRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get start => $composableBuilder(
    column: $table.start,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get end => $composableBuilder(
    column: $table.end,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PeriodTimeRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PeriodTimeRowsTable> {
  $$PeriodTimeRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);

  GeneratedColumn<String> get start =>
      $composableBuilder(column: $table.start, builder: (column) => column);

  GeneratedColumn<String> get end =>
      $composableBuilder(column: $table.end, builder: (column) => column);
}

class $$PeriodTimeRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PeriodTimeRowsTable,
          PeriodTimeRow,
          $$PeriodTimeRowsTableFilterComposer,
          $$PeriodTimeRowsTableOrderingComposer,
          $$PeriodTimeRowsTableAnnotationComposer,
          $$PeriodTimeRowsTableCreateCompanionBuilder,
          $$PeriodTimeRowsTableUpdateCompanionBuilder,
          (
            PeriodTimeRow,
            BaseReferences<_$AppDatabase, $PeriodTimeRowsTable, PeriodTimeRow>,
          ),
          PeriodTimeRow,
          PrefetchHooks Function()
        > {
  $$PeriodTimeRowsTableTableManager(
    _$AppDatabase db,
    $PeriodTimeRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PeriodTimeRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PeriodTimeRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PeriodTimeRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> period = const Value.absent(),
                Value<String> start = const Value.absent(),
                Value<String> end = const Value.absent(),
              }) => PeriodTimeRowsCompanion(
                period: period,
                start: start,
                end: end,
              ),
          createCompanionCallback:
              ({
                Value<int> period = const Value.absent(),
                required String start,
                required String end,
              }) => PeriodTimeRowsCompanion.insert(
                period: period,
                start: start,
                end: end,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PeriodTimeRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PeriodTimeRowsTable,
      PeriodTimeRow,
      $$PeriodTimeRowsTableFilterComposer,
      $$PeriodTimeRowsTableOrderingComposer,
      $$PeriodTimeRowsTableAnnotationComposer,
      $$PeriodTimeRowsTableCreateCompanionBuilder,
      $$PeriodTimeRowsTableUpdateCompanionBuilder,
      (
        PeriodTimeRow,
        BaseReferences<_$AppDatabase, $PeriodTimeRowsTable, PeriodTimeRow>,
      ),
      PeriodTimeRow,
      PrefetchHooks Function()
    >;
typedef $$SearchHistoryRowsTableCreateCompanionBuilder =
    SearchHistoryRowsCompanion Function({
      Value<int> id,
      required String query,
      required DateTime searchedAt,
    });
typedef $$SearchHistoryRowsTableUpdateCompanionBuilder =
    SearchHistoryRowsCompanion Function({
      Value<int> id,
      Value<String> query,
      Value<DateTime> searchedAt,
    });

class $$SearchHistoryRowsTableFilterComposer
    extends Composer<_$AppDatabase, $SearchHistoryRowsTable> {
  $$SearchHistoryRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SearchHistoryRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $SearchHistoryRowsTable> {
  $$SearchHistoryRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SearchHistoryRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SearchHistoryRowsTable> {
  $$SearchHistoryRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get query =>
      $composableBuilder(column: $table.query, builder: (column) => column);

  GeneratedColumn<DateTime> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => column,
  );
}

class $$SearchHistoryRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SearchHistoryRowsTable,
          SearchHistoryRow,
          $$SearchHistoryRowsTableFilterComposer,
          $$SearchHistoryRowsTableOrderingComposer,
          $$SearchHistoryRowsTableAnnotationComposer,
          $$SearchHistoryRowsTableCreateCompanionBuilder,
          $$SearchHistoryRowsTableUpdateCompanionBuilder,
          (
            SearchHistoryRow,
            BaseReferences<
              _$AppDatabase,
              $SearchHistoryRowsTable,
              SearchHistoryRow
            >,
          ),
          SearchHistoryRow,
          PrefetchHooks Function()
        > {
  $$SearchHistoryRowsTableTableManager(
    _$AppDatabase db,
    $SearchHistoryRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SearchHistoryRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SearchHistoryRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SearchHistoryRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> query = const Value.absent(),
                Value<DateTime> searchedAt = const Value.absent(),
              }) => SearchHistoryRowsCompanion(
                id: id,
                query: query,
                searchedAt: searchedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String query,
                required DateTime searchedAt,
              }) => SearchHistoryRowsCompanion.insert(
                id: id,
                query: query,
                searchedAt: searchedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SearchHistoryRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SearchHistoryRowsTable,
      SearchHistoryRow,
      $$SearchHistoryRowsTableFilterComposer,
      $$SearchHistoryRowsTableOrderingComposer,
      $$SearchHistoryRowsTableAnnotationComposer,
      $$SearchHistoryRowsTableCreateCompanionBuilder,
      $$SearchHistoryRowsTableUpdateCompanionBuilder,
      (
        SearchHistoryRow,
        BaseReferences<
          _$AppDatabase,
          $SearchHistoryRowsTable,
          SearchHistoryRow
        >,
      ),
      SearchHistoryRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CourseRowsTableTableManager get courseRows =>
      $$CourseRowsTableTableManager(_db, _db.courseRows);
  $$TodoRowsTableTableManager get todoRows =>
      $$TodoRowsTableTableManager(_db, _db.todoRows);
  $$TagRowsTableTableManager get tagRows =>
      $$TagRowsTableTableManager(_db, _db.tagRows);
  $$TodoTagRowsTableTableManager get todoTagRows =>
      $$TodoTagRowsTableTableManager(_db, _db.todoTagRows);
  $$SemesterSettingsRowsTableTableManager get semesterSettingsRows =>
      $$SemesterSettingsRowsTableTableManager(_db, _db.semesterSettingsRows);
  $$PeriodTimeRowsTableTableManager get periodTimeRows =>
      $$PeriodTimeRowsTableTableManager(_db, _db.periodTimeRows);
  $$SearchHistoryRowsTableTableManager get searchHistoryRows =>
      $$SearchHistoryRowsTableTableManager(_db, _db.searchHistoryRows);
}
