// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $FaYuanTable extends FaYuan with TableInfo<$FaYuanTable, FaYuanData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FaYuanTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _createDateTimeMeta = const VerificationMeta(
    'createDateTime',
  );
  @override
  late final GeneratedColumn<DateTime> createDateTime =
      GeneratedColumn<DateTime>(
        'create_date_time',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _modifyDateTimeMeta = const VerificationMeta(
    'modifyDateTime',
  );
  @override
  late final GeneratedColumn<DateTime> modifyDateTime =
      GeneratedColumn<DateTime>(
        'modify_date_time',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _remarksMeta = const VerificationMeta(
    'remarks',
  );
  @override
  late final GeneratedColumn<String> remarks = GeneratedColumn<String>(
    'remarks',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bk1Meta = const VerificationMeta('bk1');
  @override
  late final GeneratedColumn<String> bk1 = GeneratedColumn<String>(
    'bk1',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bk2Meta = const VerificationMeta('bk2');
  @override
  late final GeneratedColumn<String> bk2 = GeneratedColumn<String>(
    'bk2',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _fodizinameMeta = const VerificationMeta(
    'fodiziname',
  );
  @override
  late final GeneratedColumn<String> fodiziname = GeneratedColumn<String>(
    'fodiziname',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yuanwangMeta = const VerificationMeta(
    'yuanwang',
  );
  @override
  late final GeneratedColumn<String> yuanwang = GeneratedColumn<String>(
    'yuanwang',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCompleteMeta = const VerificationMeta(
    'isComplete',
  );
  @override
  late final GeneratedColumn<bool> isComplete = GeneratedColumn<bool>(
    'is_complete',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_complete" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _fayuanwenMeta = const VerificationMeta(
    'fayuanwen',
  );
  @override
  late final GeneratedColumn<String> fayuanwen = GeneratedColumn<String>(
    'fayuanwen',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stsMeta = const VerificationMeta('sts');
  @override
  late final GeneratedColumn<String> sts = GeneratedColumn<String>(
    'sts',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('A'),
  );
  static const VerificationMeta _percentValueMeta = const VerificationMeta(
    'percentValue',
  );
  @override
  late final GeneratedColumn<double> percentValue = GeneratedColumn<double>(
    'percent_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createDateTime,
    modifyDateTime,
    remarks,
    bk1,
    bk2,
    name,
    fodiziname,
    startDate,
    endDate,
    yuanwang,
    isComplete,
    fayuanwen,
    sts,
    percentValue,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fa_yuan';
  @override
  VerificationContext validateIntegrity(
    Insertable<FaYuanData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('create_date_time')) {
      context.handle(
        _createDateTimeMeta,
        createDateTime.isAcceptableOrUnknown(
          data['create_date_time']!,
          _createDateTimeMeta,
        ),
      );
    }
    if (data.containsKey('modify_date_time')) {
      context.handle(
        _modifyDateTimeMeta,
        modifyDateTime.isAcceptableOrUnknown(
          data['modify_date_time']!,
          _modifyDateTimeMeta,
        ),
      );
    }
    if (data.containsKey('remarks')) {
      context.handle(
        _remarksMeta,
        remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta),
      );
    }
    if (data.containsKey('bk1')) {
      context.handle(
        _bk1Meta,
        bk1.isAcceptableOrUnknown(data['bk1']!, _bk1Meta),
      );
    }
    if (data.containsKey('bk2')) {
      context.handle(
        _bk2Meta,
        bk2.isAcceptableOrUnknown(data['bk2']!, _bk2Meta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('fodiziname')) {
      context.handle(
        _fodizinameMeta,
        fodiziname.isAcceptableOrUnknown(data['fodiziname']!, _fodizinameMeta),
      );
    } else if (isInserting) {
      context.missing(_fodizinameMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    if (data.containsKey('yuanwang')) {
      context.handle(
        _yuanwangMeta,
        yuanwang.isAcceptableOrUnknown(data['yuanwang']!, _yuanwangMeta),
      );
    } else if (isInserting) {
      context.missing(_yuanwangMeta);
    }
    if (data.containsKey('is_complete')) {
      context.handle(
        _isCompleteMeta,
        isComplete.isAcceptableOrUnknown(data['is_complete']!, _isCompleteMeta),
      );
    }
    if (data.containsKey('fayuanwen')) {
      context.handle(
        _fayuanwenMeta,
        fayuanwen.isAcceptableOrUnknown(data['fayuanwen']!, _fayuanwenMeta),
      );
    } else if (isInserting) {
      context.missing(_fayuanwenMeta);
    }
    if (data.containsKey('sts')) {
      context.handle(
        _stsMeta,
        sts.isAcceptableOrUnknown(data['sts']!, _stsMeta),
      );
    }
    if (data.containsKey('percent_value')) {
      context.handle(
        _percentValueMeta,
        percentValue.isAcceptableOrUnknown(
          data['percent_value']!,
          _percentValueMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FaYuanData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FaYuanData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createDateTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}create_date_time'],
      )!,
      modifyDateTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}modify_date_time'],
      )!,
      remarks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remarks'],
      ),
      bk1: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bk1'],
      ),
      bk2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bk2'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      fodiziname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fodiziname'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      )!,
      yuanwang: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}yuanwang'],
      )!,
      isComplete: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_complete'],
      )!,
      fayuanwen: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fayuanwen'],
      )!,
      sts: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sts'],
      )!,
      percentValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}percent_value'],
      )!,
    );
  }

  @override
  $FaYuanTable createAlias(String alias) {
    return $FaYuanTable(attachedDatabase, alias);
  }
}

class FaYuanData extends DataClass implements Insertable<FaYuanData> {
  final int id;
  final DateTime createDateTime;
  final DateTime modifyDateTime;
  final String? remarks;
  final String? bk1;
  final String? bk2;
  final String name;
  final String fodiziname;
  final DateTime startDate;
  final DateTime endDate;
  final String yuanwang;
  final bool isComplete;
  final String fayuanwen;
  final String sts;
  final double percentValue;
  const FaYuanData({
    required this.id,
    required this.createDateTime,
    required this.modifyDateTime,
    this.remarks,
    this.bk1,
    this.bk2,
    required this.name,
    required this.fodiziname,
    required this.startDate,
    required this.endDate,
    required this.yuanwang,
    required this.isComplete,
    required this.fayuanwen,
    required this.sts,
    required this.percentValue,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['create_date_time'] = Variable<DateTime>(createDateTime);
    map['modify_date_time'] = Variable<DateTime>(modifyDateTime);
    if (!nullToAbsent || remarks != null) {
      map['remarks'] = Variable<String>(remarks);
    }
    if (!nullToAbsent || bk1 != null) {
      map['bk1'] = Variable<String>(bk1);
    }
    if (!nullToAbsent || bk2 != null) {
      map['bk2'] = Variable<String>(bk2);
    }
    map['name'] = Variable<String>(name);
    map['fodiziname'] = Variable<String>(fodiziname);
    map['start_date'] = Variable<DateTime>(startDate);
    map['end_date'] = Variable<DateTime>(endDate);
    map['yuanwang'] = Variable<String>(yuanwang);
    map['is_complete'] = Variable<bool>(isComplete);
    map['fayuanwen'] = Variable<String>(fayuanwen);
    map['sts'] = Variable<String>(sts);
    map['percent_value'] = Variable<double>(percentValue);
    return map;
  }

  FaYuanCompanion toCompanion(bool nullToAbsent) {
    return FaYuanCompanion(
      id: Value(id),
      createDateTime: Value(createDateTime),
      modifyDateTime: Value(modifyDateTime),
      remarks: remarks == null && nullToAbsent
          ? const Value.absent()
          : Value(remarks),
      bk1: bk1 == null && nullToAbsent ? const Value.absent() : Value(bk1),
      bk2: bk2 == null && nullToAbsent ? const Value.absent() : Value(bk2),
      name: Value(name),
      fodiziname: Value(fodiziname),
      startDate: Value(startDate),
      endDate: Value(endDate),
      yuanwang: Value(yuanwang),
      isComplete: Value(isComplete),
      fayuanwen: Value(fayuanwen),
      sts: Value(sts),
      percentValue: Value(percentValue),
    );
  }

  factory FaYuanData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FaYuanData(
      id: serializer.fromJson<int>(json['id']),
      createDateTime: serializer.fromJson<DateTime>(json['createDateTime']),
      modifyDateTime: serializer.fromJson<DateTime>(json['modifyDateTime']),
      remarks: serializer.fromJson<String?>(json['remarks']),
      bk1: serializer.fromJson<String?>(json['bk1']),
      bk2: serializer.fromJson<String?>(json['bk2']),
      name: serializer.fromJson<String>(json['name']),
      fodiziname: serializer.fromJson<String>(json['fodiziname']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
      yuanwang: serializer.fromJson<String>(json['yuanwang']),
      isComplete: serializer.fromJson<bool>(json['isComplete']),
      fayuanwen: serializer.fromJson<String>(json['fayuanwen']),
      sts: serializer.fromJson<String>(json['sts']),
      percentValue: serializer.fromJson<double>(json['percentValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createDateTime': serializer.toJson<DateTime>(createDateTime),
      'modifyDateTime': serializer.toJson<DateTime>(modifyDateTime),
      'remarks': serializer.toJson<String?>(remarks),
      'bk1': serializer.toJson<String?>(bk1),
      'bk2': serializer.toJson<String?>(bk2),
      'name': serializer.toJson<String>(name),
      'fodiziname': serializer.toJson<String>(fodiziname),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime>(endDate),
      'yuanwang': serializer.toJson<String>(yuanwang),
      'isComplete': serializer.toJson<bool>(isComplete),
      'fayuanwen': serializer.toJson<String>(fayuanwen),
      'sts': serializer.toJson<String>(sts),
      'percentValue': serializer.toJson<double>(percentValue),
    };
  }

  FaYuanData copyWith({
    int? id,
    DateTime? createDateTime,
    DateTime? modifyDateTime,
    Value<String?> remarks = const Value.absent(),
    Value<String?> bk1 = const Value.absent(),
    Value<String?> bk2 = const Value.absent(),
    String? name,
    String? fodiziname,
    DateTime? startDate,
    DateTime? endDate,
    String? yuanwang,
    bool? isComplete,
    String? fayuanwen,
    String? sts,
    double? percentValue,
  }) => FaYuanData(
    id: id ?? this.id,
    createDateTime: createDateTime ?? this.createDateTime,
    modifyDateTime: modifyDateTime ?? this.modifyDateTime,
    remarks: remarks.present ? remarks.value : this.remarks,
    bk1: bk1.present ? bk1.value : this.bk1,
    bk2: bk2.present ? bk2.value : this.bk2,
    name: name ?? this.name,
    fodiziname: fodiziname ?? this.fodiziname,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    yuanwang: yuanwang ?? this.yuanwang,
    isComplete: isComplete ?? this.isComplete,
    fayuanwen: fayuanwen ?? this.fayuanwen,
    sts: sts ?? this.sts,
    percentValue: percentValue ?? this.percentValue,
  );
  FaYuanData copyWithCompanion(FaYuanCompanion data) {
    return FaYuanData(
      id: data.id.present ? data.id.value : this.id,
      createDateTime: data.createDateTime.present
          ? data.createDateTime.value
          : this.createDateTime,
      modifyDateTime: data.modifyDateTime.present
          ? data.modifyDateTime.value
          : this.modifyDateTime,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
      bk1: data.bk1.present ? data.bk1.value : this.bk1,
      bk2: data.bk2.present ? data.bk2.value : this.bk2,
      name: data.name.present ? data.name.value : this.name,
      fodiziname: data.fodiziname.present
          ? data.fodiziname.value
          : this.fodiziname,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      yuanwang: data.yuanwang.present ? data.yuanwang.value : this.yuanwang,
      isComplete: data.isComplete.present
          ? data.isComplete.value
          : this.isComplete,
      fayuanwen: data.fayuanwen.present ? data.fayuanwen.value : this.fayuanwen,
      sts: data.sts.present ? data.sts.value : this.sts,
      percentValue: data.percentValue.present
          ? data.percentValue.value
          : this.percentValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FaYuanData(')
          ..write('id: $id, ')
          ..write('createDateTime: $createDateTime, ')
          ..write('modifyDateTime: $modifyDateTime, ')
          ..write('remarks: $remarks, ')
          ..write('bk1: $bk1, ')
          ..write('bk2: $bk2, ')
          ..write('name: $name, ')
          ..write('fodiziname: $fodiziname, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('yuanwang: $yuanwang, ')
          ..write('isComplete: $isComplete, ')
          ..write('fayuanwen: $fayuanwen, ')
          ..write('sts: $sts, ')
          ..write('percentValue: $percentValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createDateTime,
    modifyDateTime,
    remarks,
    bk1,
    bk2,
    name,
    fodiziname,
    startDate,
    endDate,
    yuanwang,
    isComplete,
    fayuanwen,
    sts,
    percentValue,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FaYuanData &&
          other.id == this.id &&
          other.createDateTime == this.createDateTime &&
          other.modifyDateTime == this.modifyDateTime &&
          other.remarks == this.remarks &&
          other.bk1 == this.bk1 &&
          other.bk2 == this.bk2 &&
          other.name == this.name &&
          other.fodiziname == this.fodiziname &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.yuanwang == this.yuanwang &&
          other.isComplete == this.isComplete &&
          other.fayuanwen == this.fayuanwen &&
          other.sts == this.sts &&
          other.percentValue == this.percentValue);
}

class FaYuanCompanion extends UpdateCompanion<FaYuanData> {
  final Value<int> id;
  final Value<DateTime> createDateTime;
  final Value<DateTime> modifyDateTime;
  final Value<String?> remarks;
  final Value<String?> bk1;
  final Value<String?> bk2;
  final Value<String> name;
  final Value<String> fodiziname;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  final Value<String> yuanwang;
  final Value<bool> isComplete;
  final Value<String> fayuanwen;
  final Value<String> sts;
  final Value<double> percentValue;
  const FaYuanCompanion({
    this.id = const Value.absent(),
    this.createDateTime = const Value.absent(),
    this.modifyDateTime = const Value.absent(),
    this.remarks = const Value.absent(),
    this.bk1 = const Value.absent(),
    this.bk2 = const Value.absent(),
    this.name = const Value.absent(),
    this.fodiziname = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.yuanwang = const Value.absent(),
    this.isComplete = const Value.absent(),
    this.fayuanwen = const Value.absent(),
    this.sts = const Value.absent(),
    this.percentValue = const Value.absent(),
  });
  FaYuanCompanion.insert({
    this.id = const Value.absent(),
    this.createDateTime = const Value.absent(),
    this.modifyDateTime = const Value.absent(),
    this.remarks = const Value.absent(),
    this.bk1 = const Value.absent(),
    this.bk2 = const Value.absent(),
    required String name,
    required String fodiziname,
    required DateTime startDate,
    required DateTime endDate,
    required String yuanwang,
    this.isComplete = const Value.absent(),
    required String fayuanwen,
    this.sts = const Value.absent(),
    this.percentValue = const Value.absent(),
  }) : name = Value(name),
       fodiziname = Value(fodiziname),
       startDate = Value(startDate),
       endDate = Value(endDate),
       yuanwang = Value(yuanwang),
       fayuanwen = Value(fayuanwen);
  static Insertable<FaYuanData> custom({
    Expression<int>? id,
    Expression<DateTime>? createDateTime,
    Expression<DateTime>? modifyDateTime,
    Expression<String>? remarks,
    Expression<String>? bk1,
    Expression<String>? bk2,
    Expression<String>? name,
    Expression<String>? fodiziname,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? yuanwang,
    Expression<bool>? isComplete,
    Expression<String>? fayuanwen,
    Expression<String>? sts,
    Expression<double>? percentValue,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createDateTime != null) 'create_date_time': createDateTime,
      if (modifyDateTime != null) 'modify_date_time': modifyDateTime,
      if (remarks != null) 'remarks': remarks,
      if (bk1 != null) 'bk1': bk1,
      if (bk2 != null) 'bk2': bk2,
      if (name != null) 'name': name,
      if (fodiziname != null) 'fodiziname': fodiziname,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (yuanwang != null) 'yuanwang': yuanwang,
      if (isComplete != null) 'is_complete': isComplete,
      if (fayuanwen != null) 'fayuanwen': fayuanwen,
      if (sts != null) 'sts': sts,
      if (percentValue != null) 'percent_value': percentValue,
    });
  }

  FaYuanCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createDateTime,
    Value<DateTime>? modifyDateTime,
    Value<String?>? remarks,
    Value<String?>? bk1,
    Value<String?>? bk2,
    Value<String>? name,
    Value<String>? fodiziname,
    Value<DateTime>? startDate,
    Value<DateTime>? endDate,
    Value<String>? yuanwang,
    Value<bool>? isComplete,
    Value<String>? fayuanwen,
    Value<String>? sts,
    Value<double>? percentValue,
  }) {
    return FaYuanCompanion(
      id: id ?? this.id,
      createDateTime: createDateTime ?? this.createDateTime,
      modifyDateTime: modifyDateTime ?? this.modifyDateTime,
      remarks: remarks ?? this.remarks,
      bk1: bk1 ?? this.bk1,
      bk2: bk2 ?? this.bk2,
      name: name ?? this.name,
      fodiziname: fodiziname ?? this.fodiziname,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      yuanwang: yuanwang ?? this.yuanwang,
      isComplete: isComplete ?? this.isComplete,
      fayuanwen: fayuanwen ?? this.fayuanwen,
      sts: sts ?? this.sts,
      percentValue: percentValue ?? this.percentValue,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createDateTime.present) {
      map['create_date_time'] = Variable<DateTime>(createDateTime.value);
    }
    if (modifyDateTime.present) {
      map['modify_date_time'] = Variable<DateTime>(modifyDateTime.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    if (bk1.present) {
      map['bk1'] = Variable<String>(bk1.value);
    }
    if (bk2.present) {
      map['bk2'] = Variable<String>(bk2.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (fodiziname.present) {
      map['fodiziname'] = Variable<String>(fodiziname.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (yuanwang.present) {
      map['yuanwang'] = Variable<String>(yuanwang.value);
    }
    if (isComplete.present) {
      map['is_complete'] = Variable<bool>(isComplete.value);
    }
    if (fayuanwen.present) {
      map['fayuanwen'] = Variable<String>(fayuanwen.value);
    }
    if (sts.present) {
      map['sts'] = Variable<String>(sts.value);
    }
    if (percentValue.present) {
      map['percent_value'] = Variable<double>(percentValue.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FaYuanCompanion(')
          ..write('id: $id, ')
          ..write('createDateTime: $createDateTime, ')
          ..write('modifyDateTime: $modifyDateTime, ')
          ..write('remarks: $remarks, ')
          ..write('bk1: $bk1, ')
          ..write('bk2: $bk2, ')
          ..write('name: $name, ')
          ..write('fodiziname: $fodiziname, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('yuanwang: $yuanwang, ')
          ..write('isComplete: $isComplete, ')
          ..write('fayuanwen: $fayuanwen, ')
          ..write('sts: $sts, ')
          ..write('percentValue: $percentValue')
          ..write(')'))
        .toString();
  }
}

class $GongKeItemsOneDayTable extends GongKeItemsOneDay
    with TableInfo<$GongKeItemsOneDayTable, GongKeItemsOneDayData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GongKeItemsOneDayTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _fayuanIdMeta = const VerificationMeta(
    'fayuanId',
  );
  @override
  late final GeneratedColumn<int> fayuanId = GeneratedColumn<int>(
    'fayuan_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gongketypeMeta = const VerificationMeta(
    'gongketype',
  );
  @override
  late final GeneratedColumn<String> gongketype = GeneratedColumn<String>(
    'gongketype',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('songjing'),
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
  static const VerificationMeta _cntMeta = const VerificationMeta('cnt');
  @override
  late final GeneratedColumn<int> cnt = GeneratedColumn<int>(
    'cnt',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _idxMeta = const VerificationMeta('idx');
  @override
  late final GeneratedColumn<int> idx = GeneratedColumn<int>(
    'idx',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fayuanId,
    gongketype,
    name,
    cnt,
    idx,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gong_ke_items_one_day';
  @override
  VerificationContext validateIntegrity(
    Insertable<GongKeItemsOneDayData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('fayuan_id')) {
      context.handle(
        _fayuanIdMeta,
        fayuanId.isAcceptableOrUnknown(data['fayuan_id']!, _fayuanIdMeta),
      );
    } else if (isInserting) {
      context.missing(_fayuanIdMeta);
    }
    if (data.containsKey('gongketype')) {
      context.handle(
        _gongketypeMeta,
        gongketype.isAcceptableOrUnknown(data['gongketype']!, _gongketypeMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('cnt')) {
      context.handle(
        _cntMeta,
        cnt.isAcceptableOrUnknown(data['cnt']!, _cntMeta),
      );
    }
    if (data.containsKey('idx')) {
      context.handle(
        _idxMeta,
        idx.isAcceptableOrUnknown(data['idx']!, _idxMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GongKeItemsOneDayData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GongKeItemsOneDayData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      fayuanId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fayuan_id'],
      )!,
      gongketype: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gongketype'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      cnt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cnt'],
      )!,
      idx: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}idx'],
      )!,
    );
  }

  @override
  $GongKeItemsOneDayTable createAlias(String alias) {
    return $GongKeItemsOneDayTable(attachedDatabase, alias);
  }
}

class GongKeItemsOneDayData extends DataClass
    implements Insertable<GongKeItemsOneDayData> {
  final int id;
  final int fayuanId;
  final String gongketype;
  final String name;
  final int cnt;
  final int idx;
  const GongKeItemsOneDayData({
    required this.id,
    required this.fayuanId,
    required this.gongketype,
    required this.name,
    required this.cnt,
    required this.idx,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['fayuan_id'] = Variable<int>(fayuanId);
    map['gongketype'] = Variable<String>(gongketype);
    map['name'] = Variable<String>(name);
    map['cnt'] = Variable<int>(cnt);
    map['idx'] = Variable<int>(idx);
    return map;
  }

  GongKeItemsOneDayCompanion toCompanion(bool nullToAbsent) {
    return GongKeItemsOneDayCompanion(
      id: Value(id),
      fayuanId: Value(fayuanId),
      gongketype: Value(gongketype),
      name: Value(name),
      cnt: Value(cnt),
      idx: Value(idx),
    );
  }

  factory GongKeItemsOneDayData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GongKeItemsOneDayData(
      id: serializer.fromJson<int>(json['id']),
      fayuanId: serializer.fromJson<int>(json['fayuanId']),
      gongketype: serializer.fromJson<String>(json['gongketype']),
      name: serializer.fromJson<String>(json['name']),
      cnt: serializer.fromJson<int>(json['cnt']),
      idx: serializer.fromJson<int>(json['idx']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fayuanId': serializer.toJson<int>(fayuanId),
      'gongketype': serializer.toJson<String>(gongketype),
      'name': serializer.toJson<String>(name),
      'cnt': serializer.toJson<int>(cnt),
      'idx': serializer.toJson<int>(idx),
    };
  }

  GongKeItemsOneDayData copyWith({
    int? id,
    int? fayuanId,
    String? gongketype,
    String? name,
    int? cnt,
    int? idx,
  }) => GongKeItemsOneDayData(
    id: id ?? this.id,
    fayuanId: fayuanId ?? this.fayuanId,
    gongketype: gongketype ?? this.gongketype,
    name: name ?? this.name,
    cnt: cnt ?? this.cnt,
    idx: idx ?? this.idx,
  );
  GongKeItemsOneDayData copyWithCompanion(GongKeItemsOneDayCompanion data) {
    return GongKeItemsOneDayData(
      id: data.id.present ? data.id.value : this.id,
      fayuanId: data.fayuanId.present ? data.fayuanId.value : this.fayuanId,
      gongketype: data.gongketype.present
          ? data.gongketype.value
          : this.gongketype,
      name: data.name.present ? data.name.value : this.name,
      cnt: data.cnt.present ? data.cnt.value : this.cnt,
      idx: data.idx.present ? data.idx.value : this.idx,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GongKeItemsOneDayData(')
          ..write('id: $id, ')
          ..write('fayuanId: $fayuanId, ')
          ..write('gongketype: $gongketype, ')
          ..write('name: $name, ')
          ..write('cnt: $cnt, ')
          ..write('idx: $idx')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, fayuanId, gongketype, name, cnt, idx);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GongKeItemsOneDayData &&
          other.id == this.id &&
          other.fayuanId == this.fayuanId &&
          other.gongketype == this.gongketype &&
          other.name == this.name &&
          other.cnt == this.cnt &&
          other.idx == this.idx);
}

class GongKeItemsOneDayCompanion
    extends UpdateCompanion<GongKeItemsOneDayData> {
  final Value<int> id;
  final Value<int> fayuanId;
  final Value<String> gongketype;
  final Value<String> name;
  final Value<int> cnt;
  final Value<int> idx;
  const GongKeItemsOneDayCompanion({
    this.id = const Value.absent(),
    this.fayuanId = const Value.absent(),
    this.gongketype = const Value.absent(),
    this.name = const Value.absent(),
    this.cnt = const Value.absent(),
    this.idx = const Value.absent(),
  });
  GongKeItemsOneDayCompanion.insert({
    this.id = const Value.absent(),
    required int fayuanId,
    this.gongketype = const Value.absent(),
    required String name,
    this.cnt = const Value.absent(),
    this.idx = const Value.absent(),
  }) : fayuanId = Value(fayuanId),
       name = Value(name);
  static Insertable<GongKeItemsOneDayData> custom({
    Expression<int>? id,
    Expression<int>? fayuanId,
    Expression<String>? gongketype,
    Expression<String>? name,
    Expression<int>? cnt,
    Expression<int>? idx,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fayuanId != null) 'fayuan_id': fayuanId,
      if (gongketype != null) 'gongketype': gongketype,
      if (name != null) 'name': name,
      if (cnt != null) 'cnt': cnt,
      if (idx != null) 'idx': idx,
    });
  }

  GongKeItemsOneDayCompanion copyWith({
    Value<int>? id,
    Value<int>? fayuanId,
    Value<String>? gongketype,
    Value<String>? name,
    Value<int>? cnt,
    Value<int>? idx,
  }) {
    return GongKeItemsOneDayCompanion(
      id: id ?? this.id,
      fayuanId: fayuanId ?? this.fayuanId,
      gongketype: gongketype ?? this.gongketype,
      name: name ?? this.name,
      cnt: cnt ?? this.cnt,
      idx: idx ?? this.idx,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fayuanId.present) {
      map['fayuan_id'] = Variable<int>(fayuanId.value);
    }
    if (gongketype.present) {
      map['gongketype'] = Variable<String>(gongketype.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (cnt.present) {
      map['cnt'] = Variable<int>(cnt.value);
    }
    if (idx.present) {
      map['idx'] = Variable<int>(idx.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GongKeItemsOneDayCompanion(')
          ..write('id: $id, ')
          ..write('fayuanId: $fayuanId, ')
          ..write('gongketype: $gongketype, ')
          ..write('name: $name, ')
          ..write('cnt: $cnt, ')
          ..write('idx: $idx')
          ..write(')'))
        .toString();
  }
}

class $GongKeItemTable extends GongKeItem
    with TableInfo<$GongKeItemTable, GongKeItemData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GongKeItemTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _createDateTimeMeta = const VerificationMeta(
    'createDateTime',
  );
  @override
  late final GeneratedColumn<DateTime> createDateTime =
      GeneratedColumn<DateTime>(
        'create_date_time',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _remarksMeta = const VerificationMeta(
    'remarks',
  );
  @override
  late final GeneratedColumn<String> remarks = GeneratedColumn<String>(
    'remarks',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bk1Meta = const VerificationMeta('bk1');
  @override
  late final GeneratedColumn<String> bk1 = GeneratedColumn<String>(
    'bk1',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bk2Meta = const VerificationMeta('bk2');
  @override
  late final GeneratedColumn<String> bk2 = GeneratedColumn<String>(
    'bk2',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _fayuanIdMeta = const VerificationMeta(
    'fayuanId',
  );
  @override
  late final GeneratedColumn<int> fayuanId = GeneratedColumn<int>(
    'fayuan_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gongketypeMeta = const VerificationMeta(
    'gongketype',
  );
  @override
  late final GeneratedColumn<String> gongketype = GeneratedColumn<String>(
    'gongketype',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cntMeta = const VerificationMeta('cnt');
  @override
  late final GeneratedColumn<int> cnt = GeneratedColumn<int>(
    'cnt',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _gongKeDayMeta = const VerificationMeta(
    'gongKeDay',
  );
  @override
  late final GeneratedColumn<String> gongKeDay = GeneratedColumn<String>(
    'gong_ke_day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCompleteMeta = const VerificationMeta(
    'isComplete',
  );
  @override
  late final GeneratedColumn<bool> isComplete = GeneratedColumn<bool>(
    'is_complete',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_complete" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _idxMeta = const VerificationMeta('idx');
  @override
  late final GeneratedColumn<int> idx = GeneratedColumn<int>(
    'idx',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _curCntMeta = const VerificationMeta('curCnt');
  @override
  late final GeneratedColumn<int> curCnt = GeneratedColumn<int>(
    'cur_cnt',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createDateTime,
    remarks,
    bk1,
    bk2,
    name,
    fayuanId,
    gongketype,
    cnt,
    gongKeDay,
    isComplete,
    idx,
    curCnt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gong_ke_item';
  @override
  VerificationContext validateIntegrity(
    Insertable<GongKeItemData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('create_date_time')) {
      context.handle(
        _createDateTimeMeta,
        createDateTime.isAcceptableOrUnknown(
          data['create_date_time']!,
          _createDateTimeMeta,
        ),
      );
    }
    if (data.containsKey('remarks')) {
      context.handle(
        _remarksMeta,
        remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta),
      );
    }
    if (data.containsKey('bk1')) {
      context.handle(
        _bk1Meta,
        bk1.isAcceptableOrUnknown(data['bk1']!, _bk1Meta),
      );
    }
    if (data.containsKey('bk2')) {
      context.handle(
        _bk2Meta,
        bk2.isAcceptableOrUnknown(data['bk2']!, _bk2Meta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('fayuan_id')) {
      context.handle(
        _fayuanIdMeta,
        fayuanId.isAcceptableOrUnknown(data['fayuan_id']!, _fayuanIdMeta),
      );
    } else if (isInserting) {
      context.missing(_fayuanIdMeta);
    }
    if (data.containsKey('gongketype')) {
      context.handle(
        _gongketypeMeta,
        gongketype.isAcceptableOrUnknown(data['gongketype']!, _gongketypeMeta),
      );
    } else if (isInserting) {
      context.missing(_gongketypeMeta);
    }
    if (data.containsKey('cnt')) {
      context.handle(
        _cntMeta,
        cnt.isAcceptableOrUnknown(data['cnt']!, _cntMeta),
      );
    }
    if (data.containsKey('gong_ke_day')) {
      context.handle(
        _gongKeDayMeta,
        gongKeDay.isAcceptableOrUnknown(data['gong_ke_day']!, _gongKeDayMeta),
      );
    } else if (isInserting) {
      context.missing(_gongKeDayMeta);
    }
    if (data.containsKey('is_complete')) {
      context.handle(
        _isCompleteMeta,
        isComplete.isAcceptableOrUnknown(data['is_complete']!, _isCompleteMeta),
      );
    }
    if (data.containsKey('idx')) {
      context.handle(
        _idxMeta,
        idx.isAcceptableOrUnknown(data['idx']!, _idxMeta),
      );
    }
    if (data.containsKey('cur_cnt')) {
      context.handle(
        _curCntMeta,
        curCnt.isAcceptableOrUnknown(data['cur_cnt']!, _curCntMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GongKeItemData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GongKeItemData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createDateTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}create_date_time'],
      )!,
      remarks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remarks'],
      ),
      bk1: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bk1'],
      ),
      bk2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bk2'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      fayuanId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fayuan_id'],
      )!,
      gongketype: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gongketype'],
      )!,
      cnt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cnt'],
      )!,
      gongKeDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gong_ke_day'],
      )!,
      isComplete: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_complete'],
      )!,
      idx: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}idx'],
      )!,
      curCnt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cur_cnt'],
      )!,
    );
  }

  @override
  $GongKeItemTable createAlias(String alias) {
    return $GongKeItemTable(attachedDatabase, alias);
  }
}

class GongKeItemData extends DataClass implements Insertable<GongKeItemData> {
  final int id;
  final DateTime createDateTime;
  final String? remarks;
  final String? bk1;
  final String? bk2;
  final String name;
  final int fayuanId;
  final String gongketype;
  final int cnt;
  final String gongKeDay;
  final bool isComplete;
  final int idx;
  final int curCnt;
  const GongKeItemData({
    required this.id,
    required this.createDateTime,
    this.remarks,
    this.bk1,
    this.bk2,
    required this.name,
    required this.fayuanId,
    required this.gongketype,
    required this.cnt,
    required this.gongKeDay,
    required this.isComplete,
    required this.idx,
    required this.curCnt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['create_date_time'] = Variable<DateTime>(createDateTime);
    if (!nullToAbsent || remarks != null) {
      map['remarks'] = Variable<String>(remarks);
    }
    if (!nullToAbsent || bk1 != null) {
      map['bk1'] = Variable<String>(bk1);
    }
    if (!nullToAbsent || bk2 != null) {
      map['bk2'] = Variable<String>(bk2);
    }
    map['name'] = Variable<String>(name);
    map['fayuan_id'] = Variable<int>(fayuanId);
    map['gongketype'] = Variable<String>(gongketype);
    map['cnt'] = Variable<int>(cnt);
    map['gong_ke_day'] = Variable<String>(gongKeDay);
    map['is_complete'] = Variable<bool>(isComplete);
    map['idx'] = Variable<int>(idx);
    map['cur_cnt'] = Variable<int>(curCnt);
    return map;
  }

  GongKeItemCompanion toCompanion(bool nullToAbsent) {
    return GongKeItemCompanion(
      id: Value(id),
      createDateTime: Value(createDateTime),
      remarks: remarks == null && nullToAbsent
          ? const Value.absent()
          : Value(remarks),
      bk1: bk1 == null && nullToAbsent ? const Value.absent() : Value(bk1),
      bk2: bk2 == null && nullToAbsent ? const Value.absent() : Value(bk2),
      name: Value(name),
      fayuanId: Value(fayuanId),
      gongketype: Value(gongketype),
      cnt: Value(cnt),
      gongKeDay: Value(gongKeDay),
      isComplete: Value(isComplete),
      idx: Value(idx),
      curCnt: Value(curCnt),
    );
  }

  factory GongKeItemData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GongKeItemData(
      id: serializer.fromJson<int>(json['id']),
      createDateTime: serializer.fromJson<DateTime>(json['createDateTime']),
      remarks: serializer.fromJson<String?>(json['remarks']),
      bk1: serializer.fromJson<String?>(json['bk1']),
      bk2: serializer.fromJson<String?>(json['bk2']),
      name: serializer.fromJson<String>(json['name']),
      fayuanId: serializer.fromJson<int>(json['fayuanId']),
      gongketype: serializer.fromJson<String>(json['gongketype']),
      cnt: serializer.fromJson<int>(json['cnt']),
      gongKeDay: serializer.fromJson<String>(json['gongKeDay']),
      isComplete: serializer.fromJson<bool>(json['isComplete']),
      idx: serializer.fromJson<int>(json['idx']),
      curCnt: serializer.fromJson<int>(json['curCnt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createDateTime': serializer.toJson<DateTime>(createDateTime),
      'remarks': serializer.toJson<String?>(remarks),
      'bk1': serializer.toJson<String?>(bk1),
      'bk2': serializer.toJson<String?>(bk2),
      'name': serializer.toJson<String>(name),
      'fayuanId': serializer.toJson<int>(fayuanId),
      'gongketype': serializer.toJson<String>(gongketype),
      'cnt': serializer.toJson<int>(cnt),
      'gongKeDay': serializer.toJson<String>(gongKeDay),
      'isComplete': serializer.toJson<bool>(isComplete),
      'idx': serializer.toJson<int>(idx),
      'curCnt': serializer.toJson<int>(curCnt),
    };
  }

  GongKeItemData copyWith({
    int? id,
    DateTime? createDateTime,
    Value<String?> remarks = const Value.absent(),
    Value<String?> bk1 = const Value.absent(),
    Value<String?> bk2 = const Value.absent(),
    String? name,
    int? fayuanId,
    String? gongketype,
    int? cnt,
    String? gongKeDay,
    bool? isComplete,
    int? idx,
    int? curCnt,
  }) => GongKeItemData(
    id: id ?? this.id,
    createDateTime: createDateTime ?? this.createDateTime,
    remarks: remarks.present ? remarks.value : this.remarks,
    bk1: bk1.present ? bk1.value : this.bk1,
    bk2: bk2.present ? bk2.value : this.bk2,
    name: name ?? this.name,
    fayuanId: fayuanId ?? this.fayuanId,
    gongketype: gongketype ?? this.gongketype,
    cnt: cnt ?? this.cnt,
    gongKeDay: gongKeDay ?? this.gongKeDay,
    isComplete: isComplete ?? this.isComplete,
    idx: idx ?? this.idx,
    curCnt: curCnt ?? this.curCnt,
  );
  GongKeItemData copyWithCompanion(GongKeItemCompanion data) {
    return GongKeItemData(
      id: data.id.present ? data.id.value : this.id,
      createDateTime: data.createDateTime.present
          ? data.createDateTime.value
          : this.createDateTime,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
      bk1: data.bk1.present ? data.bk1.value : this.bk1,
      bk2: data.bk2.present ? data.bk2.value : this.bk2,
      name: data.name.present ? data.name.value : this.name,
      fayuanId: data.fayuanId.present ? data.fayuanId.value : this.fayuanId,
      gongketype: data.gongketype.present
          ? data.gongketype.value
          : this.gongketype,
      cnt: data.cnt.present ? data.cnt.value : this.cnt,
      gongKeDay: data.gongKeDay.present ? data.gongKeDay.value : this.gongKeDay,
      isComplete: data.isComplete.present
          ? data.isComplete.value
          : this.isComplete,
      idx: data.idx.present ? data.idx.value : this.idx,
      curCnt: data.curCnt.present ? data.curCnt.value : this.curCnt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GongKeItemData(')
          ..write('id: $id, ')
          ..write('createDateTime: $createDateTime, ')
          ..write('remarks: $remarks, ')
          ..write('bk1: $bk1, ')
          ..write('bk2: $bk2, ')
          ..write('name: $name, ')
          ..write('fayuanId: $fayuanId, ')
          ..write('gongketype: $gongketype, ')
          ..write('cnt: $cnt, ')
          ..write('gongKeDay: $gongKeDay, ')
          ..write('isComplete: $isComplete, ')
          ..write('idx: $idx, ')
          ..write('curCnt: $curCnt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createDateTime,
    remarks,
    bk1,
    bk2,
    name,
    fayuanId,
    gongketype,
    cnt,
    gongKeDay,
    isComplete,
    idx,
    curCnt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GongKeItemData &&
          other.id == this.id &&
          other.createDateTime == this.createDateTime &&
          other.remarks == this.remarks &&
          other.bk1 == this.bk1 &&
          other.bk2 == this.bk2 &&
          other.name == this.name &&
          other.fayuanId == this.fayuanId &&
          other.gongketype == this.gongketype &&
          other.cnt == this.cnt &&
          other.gongKeDay == this.gongKeDay &&
          other.isComplete == this.isComplete &&
          other.idx == this.idx &&
          other.curCnt == this.curCnt);
}

class GongKeItemCompanion extends UpdateCompanion<GongKeItemData> {
  final Value<int> id;
  final Value<DateTime> createDateTime;
  final Value<String?> remarks;
  final Value<String?> bk1;
  final Value<String?> bk2;
  final Value<String> name;
  final Value<int> fayuanId;
  final Value<String> gongketype;
  final Value<int> cnt;
  final Value<String> gongKeDay;
  final Value<bool> isComplete;
  final Value<int> idx;
  final Value<int> curCnt;
  const GongKeItemCompanion({
    this.id = const Value.absent(),
    this.createDateTime = const Value.absent(),
    this.remarks = const Value.absent(),
    this.bk1 = const Value.absent(),
    this.bk2 = const Value.absent(),
    this.name = const Value.absent(),
    this.fayuanId = const Value.absent(),
    this.gongketype = const Value.absent(),
    this.cnt = const Value.absent(),
    this.gongKeDay = const Value.absent(),
    this.isComplete = const Value.absent(),
    this.idx = const Value.absent(),
    this.curCnt = const Value.absent(),
  });
  GongKeItemCompanion.insert({
    this.id = const Value.absent(),
    this.createDateTime = const Value.absent(),
    this.remarks = const Value.absent(),
    this.bk1 = const Value.absent(),
    this.bk2 = const Value.absent(),
    required String name,
    required int fayuanId,
    required String gongketype,
    this.cnt = const Value.absent(),
    required String gongKeDay,
    this.isComplete = const Value.absent(),
    this.idx = const Value.absent(),
    this.curCnt = const Value.absent(),
  }) : name = Value(name),
       fayuanId = Value(fayuanId),
       gongketype = Value(gongketype),
       gongKeDay = Value(gongKeDay);
  static Insertable<GongKeItemData> custom({
    Expression<int>? id,
    Expression<DateTime>? createDateTime,
    Expression<String>? remarks,
    Expression<String>? bk1,
    Expression<String>? bk2,
    Expression<String>? name,
    Expression<int>? fayuanId,
    Expression<String>? gongketype,
    Expression<int>? cnt,
    Expression<String>? gongKeDay,
    Expression<bool>? isComplete,
    Expression<int>? idx,
    Expression<int>? curCnt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createDateTime != null) 'create_date_time': createDateTime,
      if (remarks != null) 'remarks': remarks,
      if (bk1 != null) 'bk1': bk1,
      if (bk2 != null) 'bk2': bk2,
      if (name != null) 'name': name,
      if (fayuanId != null) 'fayuan_id': fayuanId,
      if (gongketype != null) 'gongketype': gongketype,
      if (cnt != null) 'cnt': cnt,
      if (gongKeDay != null) 'gong_ke_day': gongKeDay,
      if (isComplete != null) 'is_complete': isComplete,
      if (idx != null) 'idx': idx,
      if (curCnt != null) 'cur_cnt': curCnt,
    });
  }

  GongKeItemCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createDateTime,
    Value<String?>? remarks,
    Value<String?>? bk1,
    Value<String?>? bk2,
    Value<String>? name,
    Value<int>? fayuanId,
    Value<String>? gongketype,
    Value<int>? cnt,
    Value<String>? gongKeDay,
    Value<bool>? isComplete,
    Value<int>? idx,
    Value<int>? curCnt,
  }) {
    return GongKeItemCompanion(
      id: id ?? this.id,
      createDateTime: createDateTime ?? this.createDateTime,
      remarks: remarks ?? this.remarks,
      bk1: bk1 ?? this.bk1,
      bk2: bk2 ?? this.bk2,
      name: name ?? this.name,
      fayuanId: fayuanId ?? this.fayuanId,
      gongketype: gongketype ?? this.gongketype,
      cnt: cnt ?? this.cnt,
      gongKeDay: gongKeDay ?? this.gongKeDay,
      isComplete: isComplete ?? this.isComplete,
      idx: idx ?? this.idx,
      curCnt: curCnt ?? this.curCnt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createDateTime.present) {
      map['create_date_time'] = Variable<DateTime>(createDateTime.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    if (bk1.present) {
      map['bk1'] = Variable<String>(bk1.value);
    }
    if (bk2.present) {
      map['bk2'] = Variable<String>(bk2.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (fayuanId.present) {
      map['fayuan_id'] = Variable<int>(fayuanId.value);
    }
    if (gongketype.present) {
      map['gongketype'] = Variable<String>(gongketype.value);
    }
    if (cnt.present) {
      map['cnt'] = Variable<int>(cnt.value);
    }
    if (gongKeDay.present) {
      map['gong_ke_day'] = Variable<String>(gongKeDay.value);
    }
    if (isComplete.present) {
      map['is_complete'] = Variable<bool>(isComplete.value);
    }
    if (idx.present) {
      map['idx'] = Variable<int>(idx.value);
    }
    if (curCnt.present) {
      map['cur_cnt'] = Variable<int>(curCnt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GongKeItemCompanion(')
          ..write('id: $id, ')
          ..write('createDateTime: $createDateTime, ')
          ..write('remarks: $remarks, ')
          ..write('bk1: $bk1, ')
          ..write('bk2: $bk2, ')
          ..write('name: $name, ')
          ..write('fayuanId: $fayuanId, ')
          ..write('gongketype: $gongketype, ')
          ..write('cnt: $cnt, ')
          ..write('gongKeDay: $gongKeDay, ')
          ..write('isComplete: $isComplete, ')
          ..write('idx: $idx, ')
          ..write('curCnt: $curCnt')
          ..write(')'))
        .toString();
  }
}

class $JingShuTable extends JingShu with TableInfo<$JingShuTable, JingShuData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JingShuTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _createDateTimeMeta = const VerificationMeta(
    'createDateTime',
  );
  @override
  late final GeneratedColumn<DateTime> createDateTime =
      GeneratedColumn<DateTime>(
        'create_date_time',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _favoriteDateTimeMeta = const VerificationMeta(
    'favoriteDateTime',
  );
  @override
  late final GeneratedColumn<DateTime> favoriteDateTime =
      GeneratedColumn<DateTime>(
        'favorite_date_time',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _remarksMeta = const VerificationMeta(
    'remarks',
  );
  @override
  late final GeneratedColumn<String> remarks = GeneratedColumn<String>(
    'remarks',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bk1Meta = const VerificationMeta('bk1');
  @override
  late final GeneratedColumn<String> bk1 = GeneratedColumn<String>(
    'bk1',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bk2Meta = const VerificationMeta('bk2');
  @override
  late final GeneratedColumn<String> bk2 = GeneratedColumn<String>(
    'bk2',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageMeta = const VerificationMeta('image');
  @override
  late final GeneratedColumn<String> image = GeneratedColumn<String>(
    'image',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileUrlMeta = const VerificationMeta(
    'fileUrl',
  );
  @override
  late final GeneratedColumn<String> fileUrl = GeneratedColumn<String>(
    'file_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileTypeMeta = const VerificationMeta(
    'fileType',
  );
  @override
  late final GeneratedColumn<String> fileType = GeneratedColumn<String>(
    'file_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _muyuMeta = const VerificationMeta('muyu');
  @override
  late final GeneratedColumn<bool> muyu = GeneratedColumn<bool>(
    'muyu',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("muyu" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _bkMusicMeta = const VerificationMeta(
    'bkMusic',
  );
  @override
  late final GeneratedColumn<bool> bkMusic = GeneratedColumn<bool>(
    'bk_music',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("bk_music" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _bkMusicnameMeta = const VerificationMeta(
    'bkMusicname',
  );
  @override
  late final GeneratedColumn<String> bkMusicname = GeneratedColumn<String>(
    'bk_musicname',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _muyuNameMeta = const VerificationMeta(
    'muyuName',
  );
  @override
  late final GeneratedColumn<String> muyuName = GeneratedColumn<String>(
    'muyu_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _muyuImageMeta = const VerificationMeta(
    'muyuImage',
  );
  @override
  late final GeneratedColumn<String> muyuImage = GeneratedColumn<String>(
    'muyu_image',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _muyuTypeMeta = const VerificationMeta(
    'muyuType',
  );
  @override
  late final GeneratedColumn<String> muyuType = GeneratedColumn<String>(
    'muyu_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _muyuCountMeta = const VerificationMeta(
    'muyuCount',
  );
  @override
  late final GeneratedColumn<int> muyuCount = GeneratedColumn<int>(
    'muyu_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _muyuIntervalMeta = const VerificationMeta(
    'muyuInterval',
  );
  @override
  late final GeneratedColumn<double> muyuInterval = GeneratedColumn<double>(
    'muyu_interval',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _muyuDurationMeta = const VerificationMeta(
    'muyuDuration',
  );
  @override
  late final GeneratedColumn<double> muyuDuration = GeneratedColumn<double>(
    'muyu_duration',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _curPageNumMeta = const VerificationMeta(
    'curPageNum',
  );
  @override
  late final GeneratedColumn<int> curPageNum = GeneratedColumn<int>(
    'cur_page_num',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createDateTime,
    favoriteDateTime,
    remarks,
    bk1,
    bk2,
    name,
    type,
    image,
    fileUrl,
    fileType,
    muyu,
    bkMusic,
    bkMusicname,
    muyuName,
    muyuImage,
    muyuType,
    muyuCount,
    muyuInterval,
    muyuDuration,
    curPageNum,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'jing_shu';
  @override
  VerificationContext validateIntegrity(
    Insertable<JingShuData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('create_date_time')) {
      context.handle(
        _createDateTimeMeta,
        createDateTime.isAcceptableOrUnknown(
          data['create_date_time']!,
          _createDateTimeMeta,
        ),
      );
    }
    if (data.containsKey('favorite_date_time')) {
      context.handle(
        _favoriteDateTimeMeta,
        favoriteDateTime.isAcceptableOrUnknown(
          data['favorite_date_time']!,
          _favoriteDateTimeMeta,
        ),
      );
    }
    if (data.containsKey('remarks')) {
      context.handle(
        _remarksMeta,
        remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta),
      );
    }
    if (data.containsKey('bk1')) {
      context.handle(
        _bk1Meta,
        bk1.isAcceptableOrUnknown(data['bk1']!, _bk1Meta),
      );
    }
    if (data.containsKey('bk2')) {
      context.handle(
        _bk2Meta,
        bk2.isAcceptableOrUnknown(data['bk2']!, _bk2Meta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('image')) {
      context.handle(
        _imageMeta,
        image.isAcceptableOrUnknown(data['image']!, _imageMeta),
      );
    } else if (isInserting) {
      context.missing(_imageMeta);
    }
    if (data.containsKey('file_url')) {
      context.handle(
        _fileUrlMeta,
        fileUrl.isAcceptableOrUnknown(data['file_url']!, _fileUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_fileUrlMeta);
    }
    if (data.containsKey('file_type')) {
      context.handle(
        _fileTypeMeta,
        fileType.isAcceptableOrUnknown(data['file_type']!, _fileTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_fileTypeMeta);
    }
    if (data.containsKey('muyu')) {
      context.handle(
        _muyuMeta,
        muyu.isAcceptableOrUnknown(data['muyu']!, _muyuMeta),
      );
    }
    if (data.containsKey('bk_music')) {
      context.handle(
        _bkMusicMeta,
        bkMusic.isAcceptableOrUnknown(data['bk_music']!, _bkMusicMeta),
      );
    }
    if (data.containsKey('bk_musicname')) {
      context.handle(
        _bkMusicnameMeta,
        bkMusicname.isAcceptableOrUnknown(
          data['bk_musicname']!,
          _bkMusicnameMeta,
        ),
      );
    }
    if (data.containsKey('muyu_name')) {
      context.handle(
        _muyuNameMeta,
        muyuName.isAcceptableOrUnknown(data['muyu_name']!, _muyuNameMeta),
      );
    }
    if (data.containsKey('muyu_image')) {
      context.handle(
        _muyuImageMeta,
        muyuImage.isAcceptableOrUnknown(data['muyu_image']!, _muyuImageMeta),
      );
    }
    if (data.containsKey('muyu_type')) {
      context.handle(
        _muyuTypeMeta,
        muyuType.isAcceptableOrUnknown(data['muyu_type']!, _muyuTypeMeta),
      );
    }
    if (data.containsKey('muyu_count')) {
      context.handle(
        _muyuCountMeta,
        muyuCount.isAcceptableOrUnknown(data['muyu_count']!, _muyuCountMeta),
      );
    }
    if (data.containsKey('muyu_interval')) {
      context.handle(
        _muyuIntervalMeta,
        muyuInterval.isAcceptableOrUnknown(
          data['muyu_interval']!,
          _muyuIntervalMeta,
        ),
      );
    }
    if (data.containsKey('muyu_duration')) {
      context.handle(
        _muyuDurationMeta,
        muyuDuration.isAcceptableOrUnknown(
          data['muyu_duration']!,
          _muyuDurationMeta,
        ),
      );
    }
    if (data.containsKey('cur_page_num')) {
      context.handle(
        _curPageNumMeta,
        curPageNum.isAcceptableOrUnknown(
          data['cur_page_num']!,
          _curPageNumMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JingShuData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JingShuData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createDateTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}create_date_time'],
      )!,
      favoriteDateTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}favorite_date_time'],
      ),
      remarks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remarks'],
      ),
      bk1: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bk1'],
      ),
      bk2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bk2'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      image: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image'],
      )!,
      fileUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_url'],
      )!,
      fileType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_type'],
      )!,
      muyu: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}muyu'],
      )!,
      bkMusic: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}bk_music'],
      )!,
      bkMusicname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bk_musicname'],
      ),
      muyuName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}muyu_name'],
      ),
      muyuImage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}muyu_image'],
      ),
      muyuType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}muyu_type'],
      ),
      muyuCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}muyu_count'],
      ),
      muyuInterval: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}muyu_interval'],
      ),
      muyuDuration: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}muyu_duration'],
      ),
      curPageNum: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cur_page_num'],
      ),
    );
  }

  @override
  $JingShuTable createAlias(String alias) {
    return $JingShuTable(attachedDatabase, alias);
  }
}

class JingShuData extends DataClass implements Insertable<JingShuData> {
  final int id;
  final DateTime createDateTime;
  final DateTime? favoriteDateTime;
  final String? remarks;
  final String? bk1;
  final String? bk2;
  final String name;
  final String type;
  final String image;
  final String fileUrl;
  final String fileType;
  final bool muyu;
  final bool bkMusic;
  final String? bkMusicname;
  final String? muyuName;
  final String? muyuImage;
  final String? muyuType;
  final int? muyuCount;
  final double? muyuInterval;
  final double? muyuDuration;
  final int? curPageNum;
  const JingShuData({
    required this.id,
    required this.createDateTime,
    this.favoriteDateTime,
    this.remarks,
    this.bk1,
    this.bk2,
    required this.name,
    required this.type,
    required this.image,
    required this.fileUrl,
    required this.fileType,
    required this.muyu,
    required this.bkMusic,
    this.bkMusicname,
    this.muyuName,
    this.muyuImage,
    this.muyuType,
    this.muyuCount,
    this.muyuInterval,
    this.muyuDuration,
    this.curPageNum,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['create_date_time'] = Variable<DateTime>(createDateTime);
    if (!nullToAbsent || favoriteDateTime != null) {
      map['favorite_date_time'] = Variable<DateTime>(favoriteDateTime);
    }
    if (!nullToAbsent || remarks != null) {
      map['remarks'] = Variable<String>(remarks);
    }
    if (!nullToAbsent || bk1 != null) {
      map['bk1'] = Variable<String>(bk1);
    }
    if (!nullToAbsent || bk2 != null) {
      map['bk2'] = Variable<String>(bk2);
    }
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['image'] = Variable<String>(image);
    map['file_url'] = Variable<String>(fileUrl);
    map['file_type'] = Variable<String>(fileType);
    map['muyu'] = Variable<bool>(muyu);
    map['bk_music'] = Variable<bool>(bkMusic);
    if (!nullToAbsent || bkMusicname != null) {
      map['bk_musicname'] = Variable<String>(bkMusicname);
    }
    if (!nullToAbsent || muyuName != null) {
      map['muyu_name'] = Variable<String>(muyuName);
    }
    if (!nullToAbsent || muyuImage != null) {
      map['muyu_image'] = Variable<String>(muyuImage);
    }
    if (!nullToAbsent || muyuType != null) {
      map['muyu_type'] = Variable<String>(muyuType);
    }
    if (!nullToAbsent || muyuCount != null) {
      map['muyu_count'] = Variable<int>(muyuCount);
    }
    if (!nullToAbsent || muyuInterval != null) {
      map['muyu_interval'] = Variable<double>(muyuInterval);
    }
    if (!nullToAbsent || muyuDuration != null) {
      map['muyu_duration'] = Variable<double>(muyuDuration);
    }
    if (!nullToAbsent || curPageNum != null) {
      map['cur_page_num'] = Variable<int>(curPageNum);
    }
    return map;
  }

  JingShuCompanion toCompanion(bool nullToAbsent) {
    return JingShuCompanion(
      id: Value(id),
      createDateTime: Value(createDateTime),
      favoriteDateTime: favoriteDateTime == null && nullToAbsent
          ? const Value.absent()
          : Value(favoriteDateTime),
      remarks: remarks == null && nullToAbsent
          ? const Value.absent()
          : Value(remarks),
      bk1: bk1 == null && nullToAbsent ? const Value.absent() : Value(bk1),
      bk2: bk2 == null && nullToAbsent ? const Value.absent() : Value(bk2),
      name: Value(name),
      type: Value(type),
      image: Value(image),
      fileUrl: Value(fileUrl),
      fileType: Value(fileType),
      muyu: Value(muyu),
      bkMusic: Value(bkMusic),
      bkMusicname: bkMusicname == null && nullToAbsent
          ? const Value.absent()
          : Value(bkMusicname),
      muyuName: muyuName == null && nullToAbsent
          ? const Value.absent()
          : Value(muyuName),
      muyuImage: muyuImage == null && nullToAbsent
          ? const Value.absent()
          : Value(muyuImage),
      muyuType: muyuType == null && nullToAbsent
          ? const Value.absent()
          : Value(muyuType),
      muyuCount: muyuCount == null && nullToAbsent
          ? const Value.absent()
          : Value(muyuCount),
      muyuInterval: muyuInterval == null && nullToAbsent
          ? const Value.absent()
          : Value(muyuInterval),
      muyuDuration: muyuDuration == null && nullToAbsent
          ? const Value.absent()
          : Value(muyuDuration),
      curPageNum: curPageNum == null && nullToAbsent
          ? const Value.absent()
          : Value(curPageNum),
    );
  }

  factory JingShuData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JingShuData(
      id: serializer.fromJson<int>(json['id']),
      createDateTime: serializer.fromJson<DateTime>(json['createDateTime']),
      favoriteDateTime: serializer.fromJson<DateTime?>(
        json['favoriteDateTime'],
      ),
      remarks: serializer.fromJson<String?>(json['remarks']),
      bk1: serializer.fromJson<String?>(json['bk1']),
      bk2: serializer.fromJson<String?>(json['bk2']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      image: serializer.fromJson<String>(json['image']),
      fileUrl: serializer.fromJson<String>(json['fileUrl']),
      fileType: serializer.fromJson<String>(json['fileType']),
      muyu: serializer.fromJson<bool>(json['muyu']),
      bkMusic: serializer.fromJson<bool>(json['bkMusic']),
      bkMusicname: serializer.fromJson<String?>(json['bkMusicname']),
      muyuName: serializer.fromJson<String?>(json['muyuName']),
      muyuImage: serializer.fromJson<String?>(json['muyuImage']),
      muyuType: serializer.fromJson<String?>(json['muyuType']),
      muyuCount: serializer.fromJson<int?>(json['muyuCount']),
      muyuInterval: serializer.fromJson<double?>(json['muyuInterval']),
      muyuDuration: serializer.fromJson<double?>(json['muyuDuration']),
      curPageNum: serializer.fromJson<int?>(json['curPageNum']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createDateTime': serializer.toJson<DateTime>(createDateTime),
      'favoriteDateTime': serializer.toJson<DateTime?>(favoriteDateTime),
      'remarks': serializer.toJson<String?>(remarks),
      'bk1': serializer.toJson<String?>(bk1),
      'bk2': serializer.toJson<String?>(bk2),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'image': serializer.toJson<String>(image),
      'fileUrl': serializer.toJson<String>(fileUrl),
      'fileType': serializer.toJson<String>(fileType),
      'muyu': serializer.toJson<bool>(muyu),
      'bkMusic': serializer.toJson<bool>(bkMusic),
      'bkMusicname': serializer.toJson<String?>(bkMusicname),
      'muyuName': serializer.toJson<String?>(muyuName),
      'muyuImage': serializer.toJson<String?>(muyuImage),
      'muyuType': serializer.toJson<String?>(muyuType),
      'muyuCount': serializer.toJson<int?>(muyuCount),
      'muyuInterval': serializer.toJson<double?>(muyuInterval),
      'muyuDuration': serializer.toJson<double?>(muyuDuration),
      'curPageNum': serializer.toJson<int?>(curPageNum),
    };
  }

  JingShuData copyWith({
    int? id,
    DateTime? createDateTime,
    Value<DateTime?> favoriteDateTime = const Value.absent(),
    Value<String?> remarks = const Value.absent(),
    Value<String?> bk1 = const Value.absent(),
    Value<String?> bk2 = const Value.absent(),
    String? name,
    String? type,
    String? image,
    String? fileUrl,
    String? fileType,
    bool? muyu,
    bool? bkMusic,
    Value<String?> bkMusicname = const Value.absent(),
    Value<String?> muyuName = const Value.absent(),
    Value<String?> muyuImage = const Value.absent(),
    Value<String?> muyuType = const Value.absent(),
    Value<int?> muyuCount = const Value.absent(),
    Value<double?> muyuInterval = const Value.absent(),
    Value<double?> muyuDuration = const Value.absent(),
    Value<int?> curPageNum = const Value.absent(),
  }) => JingShuData(
    id: id ?? this.id,
    createDateTime: createDateTime ?? this.createDateTime,
    favoriteDateTime: favoriteDateTime.present
        ? favoriteDateTime.value
        : this.favoriteDateTime,
    remarks: remarks.present ? remarks.value : this.remarks,
    bk1: bk1.present ? bk1.value : this.bk1,
    bk2: bk2.present ? bk2.value : this.bk2,
    name: name ?? this.name,
    type: type ?? this.type,
    image: image ?? this.image,
    fileUrl: fileUrl ?? this.fileUrl,
    fileType: fileType ?? this.fileType,
    muyu: muyu ?? this.muyu,
    bkMusic: bkMusic ?? this.bkMusic,
    bkMusicname: bkMusicname.present ? bkMusicname.value : this.bkMusicname,
    muyuName: muyuName.present ? muyuName.value : this.muyuName,
    muyuImage: muyuImage.present ? muyuImage.value : this.muyuImage,
    muyuType: muyuType.present ? muyuType.value : this.muyuType,
    muyuCount: muyuCount.present ? muyuCount.value : this.muyuCount,
    muyuInterval: muyuInterval.present ? muyuInterval.value : this.muyuInterval,
    muyuDuration: muyuDuration.present ? muyuDuration.value : this.muyuDuration,
    curPageNum: curPageNum.present ? curPageNum.value : this.curPageNum,
  );
  JingShuData copyWithCompanion(JingShuCompanion data) {
    return JingShuData(
      id: data.id.present ? data.id.value : this.id,
      createDateTime: data.createDateTime.present
          ? data.createDateTime.value
          : this.createDateTime,
      favoriteDateTime: data.favoriteDateTime.present
          ? data.favoriteDateTime.value
          : this.favoriteDateTime,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
      bk1: data.bk1.present ? data.bk1.value : this.bk1,
      bk2: data.bk2.present ? data.bk2.value : this.bk2,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      image: data.image.present ? data.image.value : this.image,
      fileUrl: data.fileUrl.present ? data.fileUrl.value : this.fileUrl,
      fileType: data.fileType.present ? data.fileType.value : this.fileType,
      muyu: data.muyu.present ? data.muyu.value : this.muyu,
      bkMusic: data.bkMusic.present ? data.bkMusic.value : this.bkMusic,
      bkMusicname: data.bkMusicname.present
          ? data.bkMusicname.value
          : this.bkMusicname,
      muyuName: data.muyuName.present ? data.muyuName.value : this.muyuName,
      muyuImage: data.muyuImage.present ? data.muyuImage.value : this.muyuImage,
      muyuType: data.muyuType.present ? data.muyuType.value : this.muyuType,
      muyuCount: data.muyuCount.present ? data.muyuCount.value : this.muyuCount,
      muyuInterval: data.muyuInterval.present
          ? data.muyuInterval.value
          : this.muyuInterval,
      muyuDuration: data.muyuDuration.present
          ? data.muyuDuration.value
          : this.muyuDuration,
      curPageNum: data.curPageNum.present
          ? data.curPageNum.value
          : this.curPageNum,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JingShuData(')
          ..write('id: $id, ')
          ..write('createDateTime: $createDateTime, ')
          ..write('favoriteDateTime: $favoriteDateTime, ')
          ..write('remarks: $remarks, ')
          ..write('bk1: $bk1, ')
          ..write('bk2: $bk2, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('image: $image, ')
          ..write('fileUrl: $fileUrl, ')
          ..write('fileType: $fileType, ')
          ..write('muyu: $muyu, ')
          ..write('bkMusic: $bkMusic, ')
          ..write('bkMusicname: $bkMusicname, ')
          ..write('muyuName: $muyuName, ')
          ..write('muyuImage: $muyuImage, ')
          ..write('muyuType: $muyuType, ')
          ..write('muyuCount: $muyuCount, ')
          ..write('muyuInterval: $muyuInterval, ')
          ..write('muyuDuration: $muyuDuration, ')
          ..write('curPageNum: $curPageNum')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    createDateTime,
    favoriteDateTime,
    remarks,
    bk1,
    bk2,
    name,
    type,
    image,
    fileUrl,
    fileType,
    muyu,
    bkMusic,
    bkMusicname,
    muyuName,
    muyuImage,
    muyuType,
    muyuCount,
    muyuInterval,
    muyuDuration,
    curPageNum,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JingShuData &&
          other.id == this.id &&
          other.createDateTime == this.createDateTime &&
          other.favoriteDateTime == this.favoriteDateTime &&
          other.remarks == this.remarks &&
          other.bk1 == this.bk1 &&
          other.bk2 == this.bk2 &&
          other.name == this.name &&
          other.type == this.type &&
          other.image == this.image &&
          other.fileUrl == this.fileUrl &&
          other.fileType == this.fileType &&
          other.muyu == this.muyu &&
          other.bkMusic == this.bkMusic &&
          other.bkMusicname == this.bkMusicname &&
          other.muyuName == this.muyuName &&
          other.muyuImage == this.muyuImage &&
          other.muyuType == this.muyuType &&
          other.muyuCount == this.muyuCount &&
          other.muyuInterval == this.muyuInterval &&
          other.muyuDuration == this.muyuDuration &&
          other.curPageNum == this.curPageNum);
}

class JingShuCompanion extends UpdateCompanion<JingShuData> {
  final Value<int> id;
  final Value<DateTime> createDateTime;
  final Value<DateTime?> favoriteDateTime;
  final Value<String?> remarks;
  final Value<String?> bk1;
  final Value<String?> bk2;
  final Value<String> name;
  final Value<String> type;
  final Value<String> image;
  final Value<String> fileUrl;
  final Value<String> fileType;
  final Value<bool> muyu;
  final Value<bool> bkMusic;
  final Value<String?> bkMusicname;
  final Value<String?> muyuName;
  final Value<String?> muyuImage;
  final Value<String?> muyuType;
  final Value<int?> muyuCount;
  final Value<double?> muyuInterval;
  final Value<double?> muyuDuration;
  final Value<int?> curPageNum;
  const JingShuCompanion({
    this.id = const Value.absent(),
    this.createDateTime = const Value.absent(),
    this.favoriteDateTime = const Value.absent(),
    this.remarks = const Value.absent(),
    this.bk1 = const Value.absent(),
    this.bk2 = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.image = const Value.absent(),
    this.fileUrl = const Value.absent(),
    this.fileType = const Value.absent(),
    this.muyu = const Value.absent(),
    this.bkMusic = const Value.absent(),
    this.bkMusicname = const Value.absent(),
    this.muyuName = const Value.absent(),
    this.muyuImage = const Value.absent(),
    this.muyuType = const Value.absent(),
    this.muyuCount = const Value.absent(),
    this.muyuInterval = const Value.absent(),
    this.muyuDuration = const Value.absent(),
    this.curPageNum = const Value.absent(),
  });
  JingShuCompanion.insert({
    this.id = const Value.absent(),
    this.createDateTime = const Value.absent(),
    this.favoriteDateTime = const Value.absent(),
    this.remarks = const Value.absent(),
    this.bk1 = const Value.absent(),
    this.bk2 = const Value.absent(),
    required String name,
    required String type,
    required String image,
    required String fileUrl,
    required String fileType,
    this.muyu = const Value.absent(),
    this.bkMusic = const Value.absent(),
    this.bkMusicname = const Value.absent(),
    this.muyuName = const Value.absent(),
    this.muyuImage = const Value.absent(),
    this.muyuType = const Value.absent(),
    this.muyuCount = const Value.absent(),
    this.muyuInterval = const Value.absent(),
    this.muyuDuration = const Value.absent(),
    this.curPageNum = const Value.absent(),
  }) : name = Value(name),
       type = Value(type),
       image = Value(image),
       fileUrl = Value(fileUrl),
       fileType = Value(fileType);
  static Insertable<JingShuData> custom({
    Expression<int>? id,
    Expression<DateTime>? createDateTime,
    Expression<DateTime>? favoriteDateTime,
    Expression<String>? remarks,
    Expression<String>? bk1,
    Expression<String>? bk2,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? image,
    Expression<String>? fileUrl,
    Expression<String>? fileType,
    Expression<bool>? muyu,
    Expression<bool>? bkMusic,
    Expression<String>? bkMusicname,
    Expression<String>? muyuName,
    Expression<String>? muyuImage,
    Expression<String>? muyuType,
    Expression<int>? muyuCount,
    Expression<double>? muyuInterval,
    Expression<double>? muyuDuration,
    Expression<int>? curPageNum,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createDateTime != null) 'create_date_time': createDateTime,
      if (favoriteDateTime != null) 'favorite_date_time': favoriteDateTime,
      if (remarks != null) 'remarks': remarks,
      if (bk1 != null) 'bk1': bk1,
      if (bk2 != null) 'bk2': bk2,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (image != null) 'image': image,
      if (fileUrl != null) 'file_url': fileUrl,
      if (fileType != null) 'file_type': fileType,
      if (muyu != null) 'muyu': muyu,
      if (bkMusic != null) 'bk_music': bkMusic,
      if (bkMusicname != null) 'bk_musicname': bkMusicname,
      if (muyuName != null) 'muyu_name': muyuName,
      if (muyuImage != null) 'muyu_image': muyuImage,
      if (muyuType != null) 'muyu_type': muyuType,
      if (muyuCount != null) 'muyu_count': muyuCount,
      if (muyuInterval != null) 'muyu_interval': muyuInterval,
      if (muyuDuration != null) 'muyu_duration': muyuDuration,
      if (curPageNum != null) 'cur_page_num': curPageNum,
    });
  }

  JingShuCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createDateTime,
    Value<DateTime?>? favoriteDateTime,
    Value<String?>? remarks,
    Value<String?>? bk1,
    Value<String?>? bk2,
    Value<String>? name,
    Value<String>? type,
    Value<String>? image,
    Value<String>? fileUrl,
    Value<String>? fileType,
    Value<bool>? muyu,
    Value<bool>? bkMusic,
    Value<String?>? bkMusicname,
    Value<String?>? muyuName,
    Value<String?>? muyuImage,
    Value<String?>? muyuType,
    Value<int?>? muyuCount,
    Value<double?>? muyuInterval,
    Value<double?>? muyuDuration,
    Value<int?>? curPageNum,
  }) {
    return JingShuCompanion(
      id: id ?? this.id,
      createDateTime: createDateTime ?? this.createDateTime,
      favoriteDateTime: favoriteDateTime ?? this.favoriteDateTime,
      remarks: remarks ?? this.remarks,
      bk1: bk1 ?? this.bk1,
      bk2: bk2 ?? this.bk2,
      name: name ?? this.name,
      type: type ?? this.type,
      image: image ?? this.image,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
      muyu: muyu ?? this.muyu,
      bkMusic: bkMusic ?? this.bkMusic,
      bkMusicname: bkMusicname ?? this.bkMusicname,
      muyuName: muyuName ?? this.muyuName,
      muyuImage: muyuImage ?? this.muyuImage,
      muyuType: muyuType ?? this.muyuType,
      muyuCount: muyuCount ?? this.muyuCount,
      muyuInterval: muyuInterval ?? this.muyuInterval,
      muyuDuration: muyuDuration ?? this.muyuDuration,
      curPageNum: curPageNum ?? this.curPageNum,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createDateTime.present) {
      map['create_date_time'] = Variable<DateTime>(createDateTime.value);
    }
    if (favoriteDateTime.present) {
      map['favorite_date_time'] = Variable<DateTime>(favoriteDateTime.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    if (bk1.present) {
      map['bk1'] = Variable<String>(bk1.value);
    }
    if (bk2.present) {
      map['bk2'] = Variable<String>(bk2.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (image.present) {
      map['image'] = Variable<String>(image.value);
    }
    if (fileUrl.present) {
      map['file_url'] = Variable<String>(fileUrl.value);
    }
    if (fileType.present) {
      map['file_type'] = Variable<String>(fileType.value);
    }
    if (muyu.present) {
      map['muyu'] = Variable<bool>(muyu.value);
    }
    if (bkMusic.present) {
      map['bk_music'] = Variable<bool>(bkMusic.value);
    }
    if (bkMusicname.present) {
      map['bk_musicname'] = Variable<String>(bkMusicname.value);
    }
    if (muyuName.present) {
      map['muyu_name'] = Variable<String>(muyuName.value);
    }
    if (muyuImage.present) {
      map['muyu_image'] = Variable<String>(muyuImage.value);
    }
    if (muyuType.present) {
      map['muyu_type'] = Variable<String>(muyuType.value);
    }
    if (muyuCount.present) {
      map['muyu_count'] = Variable<int>(muyuCount.value);
    }
    if (muyuInterval.present) {
      map['muyu_interval'] = Variable<double>(muyuInterval.value);
    }
    if (muyuDuration.present) {
      map['muyu_duration'] = Variable<double>(muyuDuration.value);
    }
    if (curPageNum.present) {
      map['cur_page_num'] = Variable<int>(curPageNum.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JingShuCompanion(')
          ..write('id: $id, ')
          ..write('createDateTime: $createDateTime, ')
          ..write('favoriteDateTime: $favoriteDateTime, ')
          ..write('remarks: $remarks, ')
          ..write('bk1: $bk1, ')
          ..write('bk2: $bk2, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('image: $image, ')
          ..write('fileUrl: $fileUrl, ')
          ..write('fileType: $fileType, ')
          ..write('muyu: $muyu, ')
          ..write('bkMusic: $bkMusic, ')
          ..write('bkMusicname: $bkMusicname, ')
          ..write('muyuName: $muyuName, ')
          ..write('muyuImage: $muyuImage, ')
          ..write('muyuType: $muyuType, ')
          ..write('muyuCount: $muyuCount, ')
          ..write('muyuInterval: $muyuInterval, ')
          ..write('muyuDuration: $muyuDuration, ')
          ..write('curPageNum: $curPageNum')
          ..write(')'))
        .toString();
  }
}

class $TipBookTable extends TipBook with TableInfo<$TipBookTable, TipBookData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TipBookTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _createDateTimeMeta = const VerificationMeta(
    'createDateTime',
  );
  @override
  late final GeneratedColumn<DateTime> createDateTime =
      GeneratedColumn<DateTime>(
        'create_date_time',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _favoriteDateTimeMeta = const VerificationMeta(
    'favoriteDateTime',
  );
  @override
  late final GeneratedColumn<DateTime> favoriteDateTime =
      GeneratedColumn<DateTime>(
        'favorite_date_time',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _remarksMeta = const VerificationMeta(
    'remarks',
  );
  @override
  late final GeneratedColumn<String> remarks = GeneratedColumn<String>(
    'remarks',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bk1Meta = const VerificationMeta('bk1');
  @override
  late final GeneratedColumn<String> bk1 = GeneratedColumn<String>(
    'bk1',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bk2Meta = const VerificationMeta('bk2');
  @override
  late final GeneratedColumn<String> bk2 = GeneratedColumn<String>(
    'bk2',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _imageMeta = const VerificationMeta('image');
  @override
  late final GeneratedColumn<String> image = GeneratedColumn<String>(
    'image',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createDateTime,
    favoriteDateTime,
    remarks,
    bk1,
    bk2,
    name,
    image,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tip_book';
  @override
  VerificationContext validateIntegrity(
    Insertable<TipBookData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('create_date_time')) {
      context.handle(
        _createDateTimeMeta,
        createDateTime.isAcceptableOrUnknown(
          data['create_date_time']!,
          _createDateTimeMeta,
        ),
      );
    }
    if (data.containsKey('favorite_date_time')) {
      context.handle(
        _favoriteDateTimeMeta,
        favoriteDateTime.isAcceptableOrUnknown(
          data['favorite_date_time']!,
          _favoriteDateTimeMeta,
        ),
      );
    }
    if (data.containsKey('remarks')) {
      context.handle(
        _remarksMeta,
        remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta),
      );
    }
    if (data.containsKey('bk1')) {
      context.handle(
        _bk1Meta,
        bk1.isAcceptableOrUnknown(data['bk1']!, _bk1Meta),
      );
    }
    if (data.containsKey('bk2')) {
      context.handle(
        _bk2Meta,
        bk2.isAcceptableOrUnknown(data['bk2']!, _bk2Meta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('image')) {
      context.handle(
        _imageMeta,
        image.isAcceptableOrUnknown(data['image']!, _imageMeta),
      );
    } else if (isInserting) {
      context.missing(_imageMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TipBookData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TipBookData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createDateTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}create_date_time'],
      )!,
      favoriteDateTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}favorite_date_time'],
      ),
      remarks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remarks'],
      ),
      bk1: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bk1'],
      ),
      bk2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bk2'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      image: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image'],
      )!,
    );
  }

  @override
  $TipBookTable createAlias(String alias) {
    return $TipBookTable(attachedDatabase, alias);
  }
}

class TipBookData extends DataClass implements Insertable<TipBookData> {
  final int id;
  final DateTime createDateTime;
  final DateTime? favoriteDateTime;
  final String? remarks;
  final String? bk1;
  final String? bk2;
  final String name;
  final String image;
  const TipBookData({
    required this.id,
    required this.createDateTime,
    this.favoriteDateTime,
    this.remarks,
    this.bk1,
    this.bk2,
    required this.name,
    required this.image,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['create_date_time'] = Variable<DateTime>(createDateTime);
    if (!nullToAbsent || favoriteDateTime != null) {
      map['favorite_date_time'] = Variable<DateTime>(favoriteDateTime);
    }
    if (!nullToAbsent || remarks != null) {
      map['remarks'] = Variable<String>(remarks);
    }
    if (!nullToAbsent || bk1 != null) {
      map['bk1'] = Variable<String>(bk1);
    }
    if (!nullToAbsent || bk2 != null) {
      map['bk2'] = Variable<String>(bk2);
    }
    map['name'] = Variable<String>(name);
    map['image'] = Variable<String>(image);
    return map;
  }

  TipBookCompanion toCompanion(bool nullToAbsent) {
    return TipBookCompanion(
      id: Value(id),
      createDateTime: Value(createDateTime),
      favoriteDateTime: favoriteDateTime == null && nullToAbsent
          ? const Value.absent()
          : Value(favoriteDateTime),
      remarks: remarks == null && nullToAbsent
          ? const Value.absent()
          : Value(remarks),
      bk1: bk1 == null && nullToAbsent ? const Value.absent() : Value(bk1),
      bk2: bk2 == null && nullToAbsent ? const Value.absent() : Value(bk2),
      name: Value(name),
      image: Value(image),
    );
  }

  factory TipBookData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TipBookData(
      id: serializer.fromJson<int>(json['id']),
      createDateTime: serializer.fromJson<DateTime>(json['createDateTime']),
      favoriteDateTime: serializer.fromJson<DateTime?>(
        json['favoriteDateTime'],
      ),
      remarks: serializer.fromJson<String?>(json['remarks']),
      bk1: serializer.fromJson<String?>(json['bk1']),
      bk2: serializer.fromJson<String?>(json['bk2']),
      name: serializer.fromJson<String>(json['name']),
      image: serializer.fromJson<String>(json['image']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createDateTime': serializer.toJson<DateTime>(createDateTime),
      'favoriteDateTime': serializer.toJson<DateTime?>(favoriteDateTime),
      'remarks': serializer.toJson<String?>(remarks),
      'bk1': serializer.toJson<String?>(bk1),
      'bk2': serializer.toJson<String?>(bk2),
      'name': serializer.toJson<String>(name),
      'image': serializer.toJson<String>(image),
    };
  }

  TipBookData copyWith({
    int? id,
    DateTime? createDateTime,
    Value<DateTime?> favoriteDateTime = const Value.absent(),
    Value<String?> remarks = const Value.absent(),
    Value<String?> bk1 = const Value.absent(),
    Value<String?> bk2 = const Value.absent(),
    String? name,
    String? image,
  }) => TipBookData(
    id: id ?? this.id,
    createDateTime: createDateTime ?? this.createDateTime,
    favoriteDateTime: favoriteDateTime.present
        ? favoriteDateTime.value
        : this.favoriteDateTime,
    remarks: remarks.present ? remarks.value : this.remarks,
    bk1: bk1.present ? bk1.value : this.bk1,
    bk2: bk2.present ? bk2.value : this.bk2,
    name: name ?? this.name,
    image: image ?? this.image,
  );
  TipBookData copyWithCompanion(TipBookCompanion data) {
    return TipBookData(
      id: data.id.present ? data.id.value : this.id,
      createDateTime: data.createDateTime.present
          ? data.createDateTime.value
          : this.createDateTime,
      favoriteDateTime: data.favoriteDateTime.present
          ? data.favoriteDateTime.value
          : this.favoriteDateTime,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
      bk1: data.bk1.present ? data.bk1.value : this.bk1,
      bk2: data.bk2.present ? data.bk2.value : this.bk2,
      name: data.name.present ? data.name.value : this.name,
      image: data.image.present ? data.image.value : this.image,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TipBookData(')
          ..write('id: $id, ')
          ..write('createDateTime: $createDateTime, ')
          ..write('favoriteDateTime: $favoriteDateTime, ')
          ..write('remarks: $remarks, ')
          ..write('bk1: $bk1, ')
          ..write('bk2: $bk2, ')
          ..write('name: $name, ')
          ..write('image: $image')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createDateTime,
    favoriteDateTime,
    remarks,
    bk1,
    bk2,
    name,
    image,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TipBookData &&
          other.id == this.id &&
          other.createDateTime == this.createDateTime &&
          other.favoriteDateTime == this.favoriteDateTime &&
          other.remarks == this.remarks &&
          other.bk1 == this.bk1 &&
          other.bk2 == this.bk2 &&
          other.name == this.name &&
          other.image == this.image);
}

class TipBookCompanion extends UpdateCompanion<TipBookData> {
  final Value<int> id;
  final Value<DateTime> createDateTime;
  final Value<DateTime?> favoriteDateTime;
  final Value<String?> remarks;
  final Value<String?> bk1;
  final Value<String?> bk2;
  final Value<String> name;
  final Value<String> image;
  const TipBookCompanion({
    this.id = const Value.absent(),
    this.createDateTime = const Value.absent(),
    this.favoriteDateTime = const Value.absent(),
    this.remarks = const Value.absent(),
    this.bk1 = const Value.absent(),
    this.bk2 = const Value.absent(),
    this.name = const Value.absent(),
    this.image = const Value.absent(),
  });
  TipBookCompanion.insert({
    this.id = const Value.absent(),
    this.createDateTime = const Value.absent(),
    this.favoriteDateTime = const Value.absent(),
    this.remarks = const Value.absent(),
    this.bk1 = const Value.absent(),
    this.bk2 = const Value.absent(),
    required String name,
    required String image,
  }) : name = Value(name),
       image = Value(image);
  static Insertable<TipBookData> custom({
    Expression<int>? id,
    Expression<DateTime>? createDateTime,
    Expression<DateTime>? favoriteDateTime,
    Expression<String>? remarks,
    Expression<String>? bk1,
    Expression<String>? bk2,
    Expression<String>? name,
    Expression<String>? image,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createDateTime != null) 'create_date_time': createDateTime,
      if (favoriteDateTime != null) 'favorite_date_time': favoriteDateTime,
      if (remarks != null) 'remarks': remarks,
      if (bk1 != null) 'bk1': bk1,
      if (bk2 != null) 'bk2': bk2,
      if (name != null) 'name': name,
      if (image != null) 'image': image,
    });
  }

  TipBookCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createDateTime,
    Value<DateTime?>? favoriteDateTime,
    Value<String?>? remarks,
    Value<String?>? bk1,
    Value<String?>? bk2,
    Value<String>? name,
    Value<String>? image,
  }) {
    return TipBookCompanion(
      id: id ?? this.id,
      createDateTime: createDateTime ?? this.createDateTime,
      favoriteDateTime: favoriteDateTime ?? this.favoriteDateTime,
      remarks: remarks ?? this.remarks,
      bk1: bk1 ?? this.bk1,
      bk2: bk2 ?? this.bk2,
      name: name ?? this.name,
      image: image ?? this.image,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createDateTime.present) {
      map['create_date_time'] = Variable<DateTime>(createDateTime.value);
    }
    if (favoriteDateTime.present) {
      map['favorite_date_time'] = Variable<DateTime>(favoriteDateTime.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    if (bk1.present) {
      map['bk1'] = Variable<String>(bk1.value);
    }
    if (bk2.present) {
      map['bk2'] = Variable<String>(bk2.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (image.present) {
      map['image'] = Variable<String>(image.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TipBookCompanion(')
          ..write('id: $id, ')
          ..write('createDateTime: $createDateTime, ')
          ..write('favoriteDateTime: $favoriteDateTime, ')
          ..write('remarks: $remarks, ')
          ..write('bk1: $bk1, ')
          ..write('bk2: $bk2, ')
          ..write('name: $name, ')
          ..write('image: $image')
          ..write(')'))
        .toString();
  }
}

class $TipRecordTable extends TipRecord
    with TableInfo<$TipRecordTable, TipRecordData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TipRecordTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _createDateTimeMeta = const VerificationMeta(
    'createDateTime',
  );
  @override
  late final GeneratedColumn<DateTime> createDateTime =
      GeneratedColumn<DateTime>(
        'create_date_time',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _remarksMeta = const VerificationMeta(
    'remarks',
  );
  @override
  late final GeneratedColumn<String> remarks = GeneratedColumn<String>(
    'remarks',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bk1Meta = const VerificationMeta('bk1');
  @override
  late final GeneratedColumn<String> bk1 = GeneratedColumn<String>(
    'bk1',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bk2Meta = const VerificationMeta('bk2');
  @override
  late final GeneratedColumn<String> bk2 = GeneratedColumn<String>(
    'bk2',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createDateTime,
    remarks,
    bk1,
    bk2,
    content,
    bookId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tip_record';
  @override
  VerificationContext validateIntegrity(
    Insertable<TipRecordData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('create_date_time')) {
      context.handle(
        _createDateTimeMeta,
        createDateTime.isAcceptableOrUnknown(
          data['create_date_time']!,
          _createDateTimeMeta,
        ),
      );
    }
    if (data.containsKey('remarks')) {
      context.handle(
        _remarksMeta,
        remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta),
      );
    }
    if (data.containsKey('bk1')) {
      context.handle(
        _bk1Meta,
        bk1.isAcceptableOrUnknown(data['bk1']!, _bk1Meta),
      );
    }
    if (data.containsKey('bk2')) {
      context.handle(
        _bk2Meta,
        bk2.isAcceptableOrUnknown(data['bk2']!, _bk2Meta),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TipRecordData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TipRecordData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createDateTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}create_date_time'],
      )!,
      remarks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remarks'],
      ),
      bk1: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bk1'],
      ),
      bk2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bk2'],
      ),
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
    );
  }

  @override
  $TipRecordTable createAlias(String alias) {
    return $TipRecordTable(attachedDatabase, alias);
  }
}

class TipRecordData extends DataClass implements Insertable<TipRecordData> {
  final int id;
  final DateTime createDateTime;
  final String? remarks;
  final String? bk1;
  final String? bk2;
  final String content;
  final int bookId;
  const TipRecordData({
    required this.id,
    required this.createDateTime,
    this.remarks,
    this.bk1,
    this.bk2,
    required this.content,
    required this.bookId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['create_date_time'] = Variable<DateTime>(createDateTime);
    if (!nullToAbsent || remarks != null) {
      map['remarks'] = Variable<String>(remarks);
    }
    if (!nullToAbsent || bk1 != null) {
      map['bk1'] = Variable<String>(bk1);
    }
    if (!nullToAbsent || bk2 != null) {
      map['bk2'] = Variable<String>(bk2);
    }
    map['content'] = Variable<String>(content);
    map['book_id'] = Variable<int>(bookId);
    return map;
  }

  TipRecordCompanion toCompanion(bool nullToAbsent) {
    return TipRecordCompanion(
      id: Value(id),
      createDateTime: Value(createDateTime),
      remarks: remarks == null && nullToAbsent
          ? const Value.absent()
          : Value(remarks),
      bk1: bk1 == null && nullToAbsent ? const Value.absent() : Value(bk1),
      bk2: bk2 == null && nullToAbsent ? const Value.absent() : Value(bk2),
      content: Value(content),
      bookId: Value(bookId),
    );
  }

  factory TipRecordData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TipRecordData(
      id: serializer.fromJson<int>(json['id']),
      createDateTime: serializer.fromJson<DateTime>(json['createDateTime']),
      remarks: serializer.fromJson<String?>(json['remarks']),
      bk1: serializer.fromJson<String?>(json['bk1']),
      bk2: serializer.fromJson<String?>(json['bk2']),
      content: serializer.fromJson<String>(json['content']),
      bookId: serializer.fromJson<int>(json['bookId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createDateTime': serializer.toJson<DateTime>(createDateTime),
      'remarks': serializer.toJson<String?>(remarks),
      'bk1': serializer.toJson<String?>(bk1),
      'bk2': serializer.toJson<String?>(bk2),
      'content': serializer.toJson<String>(content),
      'bookId': serializer.toJson<int>(bookId),
    };
  }

  TipRecordData copyWith({
    int? id,
    DateTime? createDateTime,
    Value<String?> remarks = const Value.absent(),
    Value<String?> bk1 = const Value.absent(),
    Value<String?> bk2 = const Value.absent(),
    String? content,
    int? bookId,
  }) => TipRecordData(
    id: id ?? this.id,
    createDateTime: createDateTime ?? this.createDateTime,
    remarks: remarks.present ? remarks.value : this.remarks,
    bk1: bk1.present ? bk1.value : this.bk1,
    bk2: bk2.present ? bk2.value : this.bk2,
    content: content ?? this.content,
    bookId: bookId ?? this.bookId,
  );
  TipRecordData copyWithCompanion(TipRecordCompanion data) {
    return TipRecordData(
      id: data.id.present ? data.id.value : this.id,
      createDateTime: data.createDateTime.present
          ? data.createDateTime.value
          : this.createDateTime,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
      bk1: data.bk1.present ? data.bk1.value : this.bk1,
      bk2: data.bk2.present ? data.bk2.value : this.bk2,
      content: data.content.present ? data.content.value : this.content,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TipRecordData(')
          ..write('id: $id, ')
          ..write('createDateTime: $createDateTime, ')
          ..write('remarks: $remarks, ')
          ..write('bk1: $bk1, ')
          ..write('bk2: $bk2, ')
          ..write('content: $content, ')
          ..write('bookId: $bookId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createDateTime, remarks, bk1, bk2, content, bookId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TipRecordData &&
          other.id == this.id &&
          other.createDateTime == this.createDateTime &&
          other.remarks == this.remarks &&
          other.bk1 == this.bk1 &&
          other.bk2 == this.bk2 &&
          other.content == this.content &&
          other.bookId == this.bookId);
}

class TipRecordCompanion extends UpdateCompanion<TipRecordData> {
  final Value<int> id;
  final Value<DateTime> createDateTime;
  final Value<String?> remarks;
  final Value<String?> bk1;
  final Value<String?> bk2;
  final Value<String> content;
  final Value<int> bookId;
  const TipRecordCompanion({
    this.id = const Value.absent(),
    this.createDateTime = const Value.absent(),
    this.remarks = const Value.absent(),
    this.bk1 = const Value.absent(),
    this.bk2 = const Value.absent(),
    this.content = const Value.absent(),
    this.bookId = const Value.absent(),
  });
  TipRecordCompanion.insert({
    this.id = const Value.absent(),
    this.createDateTime = const Value.absent(),
    this.remarks = const Value.absent(),
    this.bk1 = const Value.absent(),
    this.bk2 = const Value.absent(),
    required String content,
    required int bookId,
  }) : content = Value(content),
       bookId = Value(bookId);
  static Insertable<TipRecordData> custom({
    Expression<int>? id,
    Expression<DateTime>? createDateTime,
    Expression<String>? remarks,
    Expression<String>? bk1,
    Expression<String>? bk2,
    Expression<String>? content,
    Expression<int>? bookId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createDateTime != null) 'create_date_time': createDateTime,
      if (remarks != null) 'remarks': remarks,
      if (bk1 != null) 'bk1': bk1,
      if (bk2 != null) 'bk2': bk2,
      if (content != null) 'content': content,
      if (bookId != null) 'book_id': bookId,
    });
  }

  TipRecordCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createDateTime,
    Value<String?>? remarks,
    Value<String?>? bk1,
    Value<String?>? bk2,
    Value<String>? content,
    Value<int>? bookId,
  }) {
    return TipRecordCompanion(
      id: id ?? this.id,
      createDateTime: createDateTime ?? this.createDateTime,
      remarks: remarks ?? this.remarks,
      bk1: bk1 ?? this.bk1,
      bk2: bk2 ?? this.bk2,
      content: content ?? this.content,
      bookId: bookId ?? this.bookId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createDateTime.present) {
      map['create_date_time'] = Variable<DateTime>(createDateTime.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    if (bk1.present) {
      map['bk1'] = Variable<String>(bk1.value);
    }
    if (bk2.present) {
      map['bk2'] = Variable<String>(bk2.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TipRecordCompanion(')
          ..write('id: $id, ')
          ..write('createDateTime: $createDateTime, ')
          ..write('remarks: $remarks, ')
          ..write('bk1: $bk1, ')
          ..write('bk2: $bk2, ')
          ..write('content: $content, ')
          ..write('bookId: $bookId')
          ..write(')'))
        .toString();
  }
}

class $BaiChanTable extends BaiChan with TableInfo<$BaiChanTable, BaiChanData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BaiChanTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _createDateTimeMeta = const VerificationMeta(
    'createDateTime',
  );
  @override
  late final GeneratedColumn<DateTime> createDateTime =
      GeneratedColumn<DateTime>(
        'create_date_time',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _favoriteDateTimeMeta = const VerificationMeta(
    'favoriteDateTime',
  );
  @override
  late final GeneratedColumn<DateTime> favoriteDateTime =
      GeneratedColumn<DateTime>(
        'favorite_date_time',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _remarksMeta = const VerificationMeta(
    'remarks',
  );
  @override
  late final GeneratedColumn<String> remarks = GeneratedColumn<String>(
    'remarks',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bk1Meta = const VerificationMeta('bk1');
  @override
  late final GeneratedColumn<String> bk1 = GeneratedColumn<String>(
    'bk1',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bk2Meta = const VerificationMeta('bk2');
  @override
  late final GeneratedColumn<String> bk2 = GeneratedColumn<String>(
    'bk2',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _imageMeta = const VerificationMeta('image');
  @override
  late final GeneratedColumn<String> image = GeneratedColumn<String>(
    'image',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chanhuiWenStartMeta = const VerificationMeta(
    'chanhuiWenStart',
  );
  @override
  late final GeneratedColumn<String> chanhuiWenStart = GeneratedColumn<String>(
    'chanhui_wen_start',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chanhuiWenEndMeta = const VerificationMeta(
    'chanhuiWenEnd',
  );
  @override
  late final GeneratedColumn<String> chanhuiWenEnd = GeneratedColumn<String>(
    'chanhui_wen_end',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baichanTimesMeta = const VerificationMeta(
    'baichanTimes',
  );
  @override
  late final GeneratedColumn<int> baichanTimes = GeneratedColumn<int>(
    'baichan_times',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(88),
  );
  static const VerificationMeta _baichanInterval1Meta = const VerificationMeta(
    'baichanInterval1',
  );
  @override
  late final GeneratedColumn<int> baichanInterval1 = GeneratedColumn<int>(
    'baichan_interval1',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(7),
  );
  static const VerificationMeta _baichanInterval2Meta = const VerificationMeta(
    'baichanInterval2',
  );
  @override
  late final GeneratedColumn<int> baichanInterval2 = GeneratedColumn<int>(
    'baichan_interval2',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _flagOrderNumberMeta = const VerificationMeta(
    'flagOrderNumber',
  );
  @override
  late final GeneratedColumn<bool> flagOrderNumber = GeneratedColumn<bool>(
    'flag_order_number',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("flag_order_number" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _flagQiShenMeta = const VerificationMeta(
    'flagQiShen',
  );
  @override
  late final GeneratedColumn<bool> flagQiShen = GeneratedColumn<bool>(
    'flag_qi_shen',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("flag_qi_shen" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _detailMeta = const VerificationMeta('detail');
  @override
  late final GeneratedColumn<String> detail = GeneratedColumn<String>(
    'detail',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createDateTime,
    favoriteDateTime,
    remarks,
    bk1,
    bk2,
    name,
    image,
    chanhuiWenStart,
    chanhuiWenEnd,
    baichanTimes,
    baichanInterval1,
    baichanInterval2,
    flagOrderNumber,
    flagQiShen,
    detail,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bai_chan';
  @override
  VerificationContext validateIntegrity(
    Insertable<BaiChanData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('create_date_time')) {
      context.handle(
        _createDateTimeMeta,
        createDateTime.isAcceptableOrUnknown(
          data['create_date_time']!,
          _createDateTimeMeta,
        ),
      );
    }
    if (data.containsKey('favorite_date_time')) {
      context.handle(
        _favoriteDateTimeMeta,
        favoriteDateTime.isAcceptableOrUnknown(
          data['favorite_date_time']!,
          _favoriteDateTimeMeta,
        ),
      );
    }
    if (data.containsKey('remarks')) {
      context.handle(
        _remarksMeta,
        remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta),
      );
    }
    if (data.containsKey('bk1')) {
      context.handle(
        _bk1Meta,
        bk1.isAcceptableOrUnknown(data['bk1']!, _bk1Meta),
      );
    }
    if (data.containsKey('bk2')) {
      context.handle(
        _bk2Meta,
        bk2.isAcceptableOrUnknown(data['bk2']!, _bk2Meta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('image')) {
      context.handle(
        _imageMeta,
        image.isAcceptableOrUnknown(data['image']!, _imageMeta),
      );
    } else if (isInserting) {
      context.missing(_imageMeta);
    }
    if (data.containsKey('chanhui_wen_start')) {
      context.handle(
        _chanhuiWenStartMeta,
        chanhuiWenStart.isAcceptableOrUnknown(
          data['chanhui_wen_start']!,
          _chanhuiWenStartMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chanhuiWenStartMeta);
    }
    if (data.containsKey('chanhui_wen_end')) {
      context.handle(
        _chanhuiWenEndMeta,
        chanhuiWenEnd.isAcceptableOrUnknown(
          data['chanhui_wen_end']!,
          _chanhuiWenEndMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chanhuiWenEndMeta);
    }
    if (data.containsKey('baichan_times')) {
      context.handle(
        _baichanTimesMeta,
        baichanTimes.isAcceptableOrUnknown(
          data['baichan_times']!,
          _baichanTimesMeta,
        ),
      );
    }
    if (data.containsKey('baichan_interval1')) {
      context.handle(
        _baichanInterval1Meta,
        baichanInterval1.isAcceptableOrUnknown(
          data['baichan_interval1']!,
          _baichanInterval1Meta,
        ),
      );
    }
    if (data.containsKey('baichan_interval2')) {
      context.handle(
        _baichanInterval2Meta,
        baichanInterval2.isAcceptableOrUnknown(
          data['baichan_interval2']!,
          _baichanInterval2Meta,
        ),
      );
    }
    if (data.containsKey('flag_order_number')) {
      context.handle(
        _flagOrderNumberMeta,
        flagOrderNumber.isAcceptableOrUnknown(
          data['flag_order_number']!,
          _flagOrderNumberMeta,
        ),
      );
    }
    if (data.containsKey('flag_qi_shen')) {
      context.handle(
        _flagQiShenMeta,
        flagQiShen.isAcceptableOrUnknown(
          data['flag_qi_shen']!,
          _flagQiShenMeta,
        ),
      );
    }
    if (data.containsKey('detail')) {
      context.handle(
        _detailMeta,
        detail.isAcceptableOrUnknown(data['detail']!, _detailMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BaiChanData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BaiChanData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createDateTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}create_date_time'],
      )!,
      favoriteDateTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}favorite_date_time'],
      ),
      remarks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remarks'],
      ),
      bk1: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bk1'],
      ),
      bk2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bk2'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      image: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image'],
      )!,
      chanhuiWenStart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chanhui_wen_start'],
      )!,
      chanhuiWenEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chanhui_wen_end'],
      )!,
      baichanTimes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}baichan_times'],
      )!,
      baichanInterval1: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}baichan_interval1'],
      )!,
      baichanInterval2: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}baichan_interval2'],
      )!,
      flagOrderNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}flag_order_number'],
      )!,
      flagQiShen: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}flag_qi_shen'],
      )!,
      detail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detail'],
      ),
    );
  }

  @override
  $BaiChanTable createAlias(String alias) {
    return $BaiChanTable(attachedDatabase, alias);
  }
}

class BaiChanData extends DataClass implements Insertable<BaiChanData> {
  final int id;
  final DateTime createDateTime;
  final DateTime? favoriteDateTime;
  final String? remarks;
  final String? bk1;
  final String? bk2;
  final String name;
  final String image;
  final String chanhuiWenStart;
  final String chanhuiWenEnd;
  final int baichanTimes;
  final int baichanInterval1;
  final int baichanInterval2;
  final bool flagOrderNumber;
  final bool flagQiShen;
  final String? detail;
  const BaiChanData({
    required this.id,
    required this.createDateTime,
    this.favoriteDateTime,
    this.remarks,
    this.bk1,
    this.bk2,
    required this.name,
    required this.image,
    required this.chanhuiWenStart,
    required this.chanhuiWenEnd,
    required this.baichanTimes,
    required this.baichanInterval1,
    required this.baichanInterval2,
    required this.flagOrderNumber,
    required this.flagQiShen,
    this.detail,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['create_date_time'] = Variable<DateTime>(createDateTime);
    if (!nullToAbsent || favoriteDateTime != null) {
      map['favorite_date_time'] = Variable<DateTime>(favoriteDateTime);
    }
    if (!nullToAbsent || remarks != null) {
      map['remarks'] = Variable<String>(remarks);
    }
    if (!nullToAbsent || bk1 != null) {
      map['bk1'] = Variable<String>(bk1);
    }
    if (!nullToAbsent || bk2 != null) {
      map['bk2'] = Variable<String>(bk2);
    }
    map['name'] = Variable<String>(name);
    map['image'] = Variable<String>(image);
    map['chanhui_wen_start'] = Variable<String>(chanhuiWenStart);
    map['chanhui_wen_end'] = Variable<String>(chanhuiWenEnd);
    map['baichan_times'] = Variable<int>(baichanTimes);
    map['baichan_interval1'] = Variable<int>(baichanInterval1);
    map['baichan_interval2'] = Variable<int>(baichanInterval2);
    map['flag_order_number'] = Variable<bool>(flagOrderNumber);
    map['flag_qi_shen'] = Variable<bool>(flagQiShen);
    if (!nullToAbsent || detail != null) {
      map['detail'] = Variable<String>(detail);
    }
    return map;
  }

  BaiChanCompanion toCompanion(bool nullToAbsent) {
    return BaiChanCompanion(
      id: Value(id),
      createDateTime: Value(createDateTime),
      favoriteDateTime: favoriteDateTime == null && nullToAbsent
          ? const Value.absent()
          : Value(favoriteDateTime),
      remarks: remarks == null && nullToAbsent
          ? const Value.absent()
          : Value(remarks),
      bk1: bk1 == null && nullToAbsent ? const Value.absent() : Value(bk1),
      bk2: bk2 == null && nullToAbsent ? const Value.absent() : Value(bk2),
      name: Value(name),
      image: Value(image),
      chanhuiWenStart: Value(chanhuiWenStart),
      chanhuiWenEnd: Value(chanhuiWenEnd),
      baichanTimes: Value(baichanTimes),
      baichanInterval1: Value(baichanInterval1),
      baichanInterval2: Value(baichanInterval2),
      flagOrderNumber: Value(flagOrderNumber),
      flagQiShen: Value(flagQiShen),
      detail: detail == null && nullToAbsent
          ? const Value.absent()
          : Value(detail),
    );
  }

  factory BaiChanData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BaiChanData(
      id: serializer.fromJson<int>(json['id']),
      createDateTime: serializer.fromJson<DateTime>(json['createDateTime']),
      favoriteDateTime: serializer.fromJson<DateTime?>(
        json['favoriteDateTime'],
      ),
      remarks: serializer.fromJson<String?>(json['remarks']),
      bk1: serializer.fromJson<String?>(json['bk1']),
      bk2: serializer.fromJson<String?>(json['bk2']),
      name: serializer.fromJson<String>(json['name']),
      image: serializer.fromJson<String>(json['image']),
      chanhuiWenStart: serializer.fromJson<String>(json['chanhuiWenStart']),
      chanhuiWenEnd: serializer.fromJson<String>(json['chanhuiWenEnd']),
      baichanTimes: serializer.fromJson<int>(json['baichanTimes']),
      baichanInterval1: serializer.fromJson<int>(json['baichanInterval1']),
      baichanInterval2: serializer.fromJson<int>(json['baichanInterval2']),
      flagOrderNumber: serializer.fromJson<bool>(json['flagOrderNumber']),
      flagQiShen: serializer.fromJson<bool>(json['flagQiShen']),
      detail: serializer.fromJson<String?>(json['detail']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createDateTime': serializer.toJson<DateTime>(createDateTime),
      'favoriteDateTime': serializer.toJson<DateTime?>(favoriteDateTime),
      'remarks': serializer.toJson<String?>(remarks),
      'bk1': serializer.toJson<String?>(bk1),
      'bk2': serializer.toJson<String?>(bk2),
      'name': serializer.toJson<String>(name),
      'image': serializer.toJson<String>(image),
      'chanhuiWenStart': serializer.toJson<String>(chanhuiWenStart),
      'chanhuiWenEnd': serializer.toJson<String>(chanhuiWenEnd),
      'baichanTimes': serializer.toJson<int>(baichanTimes),
      'baichanInterval1': serializer.toJson<int>(baichanInterval1),
      'baichanInterval2': serializer.toJson<int>(baichanInterval2),
      'flagOrderNumber': serializer.toJson<bool>(flagOrderNumber),
      'flagQiShen': serializer.toJson<bool>(flagQiShen),
      'detail': serializer.toJson<String?>(detail),
    };
  }

  BaiChanData copyWith({
    int? id,
    DateTime? createDateTime,
    Value<DateTime?> favoriteDateTime = const Value.absent(),
    Value<String?> remarks = const Value.absent(),
    Value<String?> bk1 = const Value.absent(),
    Value<String?> bk2 = const Value.absent(),
    String? name,
    String? image,
    String? chanhuiWenStart,
    String? chanhuiWenEnd,
    int? baichanTimes,
    int? baichanInterval1,
    int? baichanInterval2,
    bool? flagOrderNumber,
    bool? flagQiShen,
    Value<String?> detail = const Value.absent(),
  }) => BaiChanData(
    id: id ?? this.id,
    createDateTime: createDateTime ?? this.createDateTime,
    favoriteDateTime: favoriteDateTime.present
        ? favoriteDateTime.value
        : this.favoriteDateTime,
    remarks: remarks.present ? remarks.value : this.remarks,
    bk1: bk1.present ? bk1.value : this.bk1,
    bk2: bk2.present ? bk2.value : this.bk2,
    name: name ?? this.name,
    image: image ?? this.image,
    chanhuiWenStart: chanhuiWenStart ?? this.chanhuiWenStart,
    chanhuiWenEnd: chanhuiWenEnd ?? this.chanhuiWenEnd,
    baichanTimes: baichanTimes ?? this.baichanTimes,
    baichanInterval1: baichanInterval1 ?? this.baichanInterval1,
    baichanInterval2: baichanInterval2 ?? this.baichanInterval2,
    flagOrderNumber: flagOrderNumber ?? this.flagOrderNumber,
    flagQiShen: flagQiShen ?? this.flagQiShen,
    detail: detail.present ? detail.value : this.detail,
  );
  BaiChanData copyWithCompanion(BaiChanCompanion data) {
    return BaiChanData(
      id: data.id.present ? data.id.value : this.id,
      createDateTime: data.createDateTime.present
          ? data.createDateTime.value
          : this.createDateTime,
      favoriteDateTime: data.favoriteDateTime.present
          ? data.favoriteDateTime.value
          : this.favoriteDateTime,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
      bk1: data.bk1.present ? data.bk1.value : this.bk1,
      bk2: data.bk2.present ? data.bk2.value : this.bk2,
      name: data.name.present ? data.name.value : this.name,
      image: data.image.present ? data.image.value : this.image,
      chanhuiWenStart: data.chanhuiWenStart.present
          ? data.chanhuiWenStart.value
          : this.chanhuiWenStart,
      chanhuiWenEnd: data.chanhuiWenEnd.present
          ? data.chanhuiWenEnd.value
          : this.chanhuiWenEnd,
      baichanTimes: data.baichanTimes.present
          ? data.baichanTimes.value
          : this.baichanTimes,
      baichanInterval1: data.baichanInterval1.present
          ? data.baichanInterval1.value
          : this.baichanInterval1,
      baichanInterval2: data.baichanInterval2.present
          ? data.baichanInterval2.value
          : this.baichanInterval2,
      flagOrderNumber: data.flagOrderNumber.present
          ? data.flagOrderNumber.value
          : this.flagOrderNumber,
      flagQiShen: data.flagQiShen.present
          ? data.flagQiShen.value
          : this.flagQiShen,
      detail: data.detail.present ? data.detail.value : this.detail,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BaiChanData(')
          ..write('id: $id, ')
          ..write('createDateTime: $createDateTime, ')
          ..write('favoriteDateTime: $favoriteDateTime, ')
          ..write('remarks: $remarks, ')
          ..write('bk1: $bk1, ')
          ..write('bk2: $bk2, ')
          ..write('name: $name, ')
          ..write('image: $image, ')
          ..write('chanhuiWenStart: $chanhuiWenStart, ')
          ..write('chanhuiWenEnd: $chanhuiWenEnd, ')
          ..write('baichanTimes: $baichanTimes, ')
          ..write('baichanInterval1: $baichanInterval1, ')
          ..write('baichanInterval2: $baichanInterval2, ')
          ..write('flagOrderNumber: $flagOrderNumber, ')
          ..write('flagQiShen: $flagQiShen, ')
          ..write('detail: $detail')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createDateTime,
    favoriteDateTime,
    remarks,
    bk1,
    bk2,
    name,
    image,
    chanhuiWenStart,
    chanhuiWenEnd,
    baichanTimes,
    baichanInterval1,
    baichanInterval2,
    flagOrderNumber,
    flagQiShen,
    detail,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BaiChanData &&
          other.id == this.id &&
          other.createDateTime == this.createDateTime &&
          other.favoriteDateTime == this.favoriteDateTime &&
          other.remarks == this.remarks &&
          other.bk1 == this.bk1 &&
          other.bk2 == this.bk2 &&
          other.name == this.name &&
          other.image == this.image &&
          other.chanhuiWenStart == this.chanhuiWenStart &&
          other.chanhuiWenEnd == this.chanhuiWenEnd &&
          other.baichanTimes == this.baichanTimes &&
          other.baichanInterval1 == this.baichanInterval1 &&
          other.baichanInterval2 == this.baichanInterval2 &&
          other.flagOrderNumber == this.flagOrderNumber &&
          other.flagQiShen == this.flagQiShen &&
          other.detail == this.detail);
}

class BaiChanCompanion extends UpdateCompanion<BaiChanData> {
  final Value<int> id;
  final Value<DateTime> createDateTime;
  final Value<DateTime?> favoriteDateTime;
  final Value<String?> remarks;
  final Value<String?> bk1;
  final Value<String?> bk2;
  final Value<String> name;
  final Value<String> image;
  final Value<String> chanhuiWenStart;
  final Value<String> chanhuiWenEnd;
  final Value<int> baichanTimes;
  final Value<int> baichanInterval1;
  final Value<int> baichanInterval2;
  final Value<bool> flagOrderNumber;
  final Value<bool> flagQiShen;
  final Value<String?> detail;
  const BaiChanCompanion({
    this.id = const Value.absent(),
    this.createDateTime = const Value.absent(),
    this.favoriteDateTime = const Value.absent(),
    this.remarks = const Value.absent(),
    this.bk1 = const Value.absent(),
    this.bk2 = const Value.absent(),
    this.name = const Value.absent(),
    this.image = const Value.absent(),
    this.chanhuiWenStart = const Value.absent(),
    this.chanhuiWenEnd = const Value.absent(),
    this.baichanTimes = const Value.absent(),
    this.baichanInterval1 = const Value.absent(),
    this.baichanInterval2 = const Value.absent(),
    this.flagOrderNumber = const Value.absent(),
    this.flagQiShen = const Value.absent(),
    this.detail = const Value.absent(),
  });
  BaiChanCompanion.insert({
    this.id = const Value.absent(),
    this.createDateTime = const Value.absent(),
    this.favoriteDateTime = const Value.absent(),
    this.remarks = const Value.absent(),
    this.bk1 = const Value.absent(),
    this.bk2 = const Value.absent(),
    required String name,
    required String image,
    required String chanhuiWenStart,
    required String chanhuiWenEnd,
    this.baichanTimes = const Value.absent(),
    this.baichanInterval1 = const Value.absent(),
    this.baichanInterval2 = const Value.absent(),
    this.flagOrderNumber = const Value.absent(),
    this.flagQiShen = const Value.absent(),
    this.detail = const Value.absent(),
  }) : name = Value(name),
       image = Value(image),
       chanhuiWenStart = Value(chanhuiWenStart),
       chanhuiWenEnd = Value(chanhuiWenEnd);
  static Insertable<BaiChanData> custom({
    Expression<int>? id,
    Expression<DateTime>? createDateTime,
    Expression<DateTime>? favoriteDateTime,
    Expression<String>? remarks,
    Expression<String>? bk1,
    Expression<String>? bk2,
    Expression<String>? name,
    Expression<String>? image,
    Expression<String>? chanhuiWenStart,
    Expression<String>? chanhuiWenEnd,
    Expression<int>? baichanTimes,
    Expression<int>? baichanInterval1,
    Expression<int>? baichanInterval2,
    Expression<bool>? flagOrderNumber,
    Expression<bool>? flagQiShen,
    Expression<String>? detail,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createDateTime != null) 'create_date_time': createDateTime,
      if (favoriteDateTime != null) 'favorite_date_time': favoriteDateTime,
      if (remarks != null) 'remarks': remarks,
      if (bk1 != null) 'bk1': bk1,
      if (bk2 != null) 'bk2': bk2,
      if (name != null) 'name': name,
      if (image != null) 'image': image,
      if (chanhuiWenStart != null) 'chanhui_wen_start': chanhuiWenStart,
      if (chanhuiWenEnd != null) 'chanhui_wen_end': chanhuiWenEnd,
      if (baichanTimes != null) 'baichan_times': baichanTimes,
      if (baichanInterval1 != null) 'baichan_interval1': baichanInterval1,
      if (baichanInterval2 != null) 'baichan_interval2': baichanInterval2,
      if (flagOrderNumber != null) 'flag_order_number': flagOrderNumber,
      if (flagQiShen != null) 'flag_qi_shen': flagQiShen,
      if (detail != null) 'detail': detail,
    });
  }

  BaiChanCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createDateTime,
    Value<DateTime?>? favoriteDateTime,
    Value<String?>? remarks,
    Value<String?>? bk1,
    Value<String?>? bk2,
    Value<String>? name,
    Value<String>? image,
    Value<String>? chanhuiWenStart,
    Value<String>? chanhuiWenEnd,
    Value<int>? baichanTimes,
    Value<int>? baichanInterval1,
    Value<int>? baichanInterval2,
    Value<bool>? flagOrderNumber,
    Value<bool>? flagQiShen,
    Value<String?>? detail,
  }) {
    return BaiChanCompanion(
      id: id ?? this.id,
      createDateTime: createDateTime ?? this.createDateTime,
      favoriteDateTime: favoriteDateTime ?? this.favoriteDateTime,
      remarks: remarks ?? this.remarks,
      bk1: bk1 ?? this.bk1,
      bk2: bk2 ?? this.bk2,
      name: name ?? this.name,
      image: image ?? this.image,
      chanhuiWenStart: chanhuiWenStart ?? this.chanhuiWenStart,
      chanhuiWenEnd: chanhuiWenEnd ?? this.chanhuiWenEnd,
      baichanTimes: baichanTimes ?? this.baichanTimes,
      baichanInterval1: baichanInterval1 ?? this.baichanInterval1,
      baichanInterval2: baichanInterval2 ?? this.baichanInterval2,
      flagOrderNumber: flagOrderNumber ?? this.flagOrderNumber,
      flagQiShen: flagQiShen ?? this.flagQiShen,
      detail: detail ?? this.detail,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createDateTime.present) {
      map['create_date_time'] = Variable<DateTime>(createDateTime.value);
    }
    if (favoriteDateTime.present) {
      map['favorite_date_time'] = Variable<DateTime>(favoriteDateTime.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    if (bk1.present) {
      map['bk1'] = Variable<String>(bk1.value);
    }
    if (bk2.present) {
      map['bk2'] = Variable<String>(bk2.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (image.present) {
      map['image'] = Variable<String>(image.value);
    }
    if (chanhuiWenStart.present) {
      map['chanhui_wen_start'] = Variable<String>(chanhuiWenStart.value);
    }
    if (chanhuiWenEnd.present) {
      map['chanhui_wen_end'] = Variable<String>(chanhuiWenEnd.value);
    }
    if (baichanTimes.present) {
      map['baichan_times'] = Variable<int>(baichanTimes.value);
    }
    if (baichanInterval1.present) {
      map['baichan_interval1'] = Variable<int>(baichanInterval1.value);
    }
    if (baichanInterval2.present) {
      map['baichan_interval2'] = Variable<int>(baichanInterval2.value);
    }
    if (flagOrderNumber.present) {
      map['flag_order_number'] = Variable<bool>(flagOrderNumber.value);
    }
    if (flagQiShen.present) {
      map['flag_qi_shen'] = Variable<bool>(flagQiShen.value);
    }
    if (detail.present) {
      map['detail'] = Variable<String>(detail.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BaiChanCompanion(')
          ..write('id: $id, ')
          ..write('createDateTime: $createDateTime, ')
          ..write('favoriteDateTime: $favoriteDateTime, ')
          ..write('remarks: $remarks, ')
          ..write('bk1: $bk1, ')
          ..write('bk2: $bk2, ')
          ..write('name: $name, ')
          ..write('image: $image, ')
          ..write('chanhuiWenStart: $chanhuiWenStart, ')
          ..write('chanhuiWenEnd: $chanhuiWenEnd, ')
          ..write('baichanTimes: $baichanTimes, ')
          ..write('baichanInterval1: $baichanInterval1, ')
          ..write('baichanInterval2: $baichanInterval2, ')
          ..write('flagOrderNumber: $flagOrderNumber, ')
          ..write('flagQiShen: $flagQiShen, ')
          ..write('detail: $detail')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FaYuanTable faYuan = $FaYuanTable(this);
  late final $GongKeItemsOneDayTable gongKeItemsOneDay =
      $GongKeItemsOneDayTable(this);
  late final $GongKeItemTable gongKeItem = $GongKeItemTable(this);
  late final $JingShuTable jingShu = $JingShuTable(this);
  late final $TipBookTable tipBook = $TipBookTable(this);
  late final $TipRecordTable tipRecord = $TipRecordTable(this);
  late final $BaiChanTable baiChan = $BaiChanTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    faYuan,
    gongKeItemsOneDay,
    gongKeItem,
    jingShu,
    tipBook,
    tipRecord,
    baiChan,
  ];
}

typedef $$FaYuanTableCreateCompanionBuilder =
    FaYuanCompanion Function({
      Value<int> id,
      Value<DateTime> createDateTime,
      Value<DateTime> modifyDateTime,
      Value<String?> remarks,
      Value<String?> bk1,
      Value<String?> bk2,
      required String name,
      required String fodiziname,
      required DateTime startDate,
      required DateTime endDate,
      required String yuanwang,
      Value<bool> isComplete,
      required String fayuanwen,
      Value<String> sts,
      Value<double> percentValue,
    });
typedef $$FaYuanTableUpdateCompanionBuilder =
    FaYuanCompanion Function({
      Value<int> id,
      Value<DateTime> createDateTime,
      Value<DateTime> modifyDateTime,
      Value<String?> remarks,
      Value<String?> bk1,
      Value<String?> bk2,
      Value<String> name,
      Value<String> fodiziname,
      Value<DateTime> startDate,
      Value<DateTime> endDate,
      Value<String> yuanwang,
      Value<bool> isComplete,
      Value<String> fayuanwen,
      Value<String> sts,
      Value<double> percentValue,
    });

class $$FaYuanTableFilterComposer
    extends Composer<_$AppDatabase, $FaYuanTable> {
  $$FaYuanTableFilterComposer({
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

  ColumnFilters<DateTime> get createDateTime => $composableBuilder(
    column: $table.createDateTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get modifyDateTime => $composableBuilder(
    column: $table.modifyDateTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bk1 => $composableBuilder(
    column: $table.bk1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bk2 => $composableBuilder(
    column: $table.bk2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fodiziname => $composableBuilder(
    column: $table.fodiziname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get yuanwang => $composableBuilder(
    column: $table.yuanwang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isComplete => $composableBuilder(
    column: $table.isComplete,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fayuanwen => $composableBuilder(
    column: $table.fayuanwen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sts => $composableBuilder(
    column: $table.sts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get percentValue => $composableBuilder(
    column: $table.percentValue,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FaYuanTableOrderingComposer
    extends Composer<_$AppDatabase, $FaYuanTable> {
  $$FaYuanTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createDateTime => $composableBuilder(
    column: $table.createDateTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get modifyDateTime => $composableBuilder(
    column: $table.modifyDateTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bk1 => $composableBuilder(
    column: $table.bk1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bk2 => $composableBuilder(
    column: $table.bk2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fodiziname => $composableBuilder(
    column: $table.fodiziname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get yuanwang => $composableBuilder(
    column: $table.yuanwang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isComplete => $composableBuilder(
    column: $table.isComplete,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fayuanwen => $composableBuilder(
    column: $table.fayuanwen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sts => $composableBuilder(
    column: $table.sts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get percentValue => $composableBuilder(
    column: $table.percentValue,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FaYuanTableAnnotationComposer
    extends Composer<_$AppDatabase, $FaYuanTable> {
  $$FaYuanTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createDateTime => $composableBuilder(
    column: $table.createDateTime,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get modifyDateTime => $composableBuilder(
    column: $table.modifyDateTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  GeneratedColumn<String> get bk1 =>
      $composableBuilder(column: $table.bk1, builder: (column) => column);

  GeneratedColumn<String> get bk2 =>
      $composableBuilder(column: $table.bk2, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get fodiziname => $composableBuilder(
    column: $table.fodiziname,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get yuanwang =>
      $composableBuilder(column: $table.yuanwang, builder: (column) => column);

  GeneratedColumn<bool> get isComplete => $composableBuilder(
    column: $table.isComplete,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fayuanwen =>
      $composableBuilder(column: $table.fayuanwen, builder: (column) => column);

  GeneratedColumn<String> get sts =>
      $composableBuilder(column: $table.sts, builder: (column) => column);

  GeneratedColumn<double> get percentValue => $composableBuilder(
    column: $table.percentValue,
    builder: (column) => column,
  );
}

class $$FaYuanTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FaYuanTable,
          FaYuanData,
          $$FaYuanTableFilterComposer,
          $$FaYuanTableOrderingComposer,
          $$FaYuanTableAnnotationComposer,
          $$FaYuanTableCreateCompanionBuilder,
          $$FaYuanTableUpdateCompanionBuilder,
          (FaYuanData, BaseReferences<_$AppDatabase, $FaYuanTable, FaYuanData>),
          FaYuanData,
          PrefetchHooks Function()
        > {
  $$FaYuanTableTableManager(_$AppDatabase db, $FaYuanTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FaYuanTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FaYuanTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FaYuanTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createDateTime = const Value.absent(),
                Value<DateTime> modifyDateTime = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<String?> bk1 = const Value.absent(),
                Value<String?> bk2 = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> fodiziname = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime> endDate = const Value.absent(),
                Value<String> yuanwang = const Value.absent(),
                Value<bool> isComplete = const Value.absent(),
                Value<String> fayuanwen = const Value.absent(),
                Value<String> sts = const Value.absent(),
                Value<double> percentValue = const Value.absent(),
              }) => FaYuanCompanion(
                id: id,
                createDateTime: createDateTime,
                modifyDateTime: modifyDateTime,
                remarks: remarks,
                bk1: bk1,
                bk2: bk2,
                name: name,
                fodiziname: fodiziname,
                startDate: startDate,
                endDate: endDate,
                yuanwang: yuanwang,
                isComplete: isComplete,
                fayuanwen: fayuanwen,
                sts: sts,
                percentValue: percentValue,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createDateTime = const Value.absent(),
                Value<DateTime> modifyDateTime = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<String?> bk1 = const Value.absent(),
                Value<String?> bk2 = const Value.absent(),
                required String name,
                required String fodiziname,
                required DateTime startDate,
                required DateTime endDate,
                required String yuanwang,
                Value<bool> isComplete = const Value.absent(),
                required String fayuanwen,
                Value<String> sts = const Value.absent(),
                Value<double> percentValue = const Value.absent(),
              }) => FaYuanCompanion.insert(
                id: id,
                createDateTime: createDateTime,
                modifyDateTime: modifyDateTime,
                remarks: remarks,
                bk1: bk1,
                bk2: bk2,
                name: name,
                fodiziname: fodiziname,
                startDate: startDate,
                endDate: endDate,
                yuanwang: yuanwang,
                isComplete: isComplete,
                fayuanwen: fayuanwen,
                sts: sts,
                percentValue: percentValue,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FaYuanTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FaYuanTable,
      FaYuanData,
      $$FaYuanTableFilterComposer,
      $$FaYuanTableOrderingComposer,
      $$FaYuanTableAnnotationComposer,
      $$FaYuanTableCreateCompanionBuilder,
      $$FaYuanTableUpdateCompanionBuilder,
      (FaYuanData, BaseReferences<_$AppDatabase, $FaYuanTable, FaYuanData>),
      FaYuanData,
      PrefetchHooks Function()
    >;
typedef $$GongKeItemsOneDayTableCreateCompanionBuilder =
    GongKeItemsOneDayCompanion Function({
      Value<int> id,
      required int fayuanId,
      Value<String> gongketype,
      required String name,
      Value<int> cnt,
      Value<int> idx,
    });
typedef $$GongKeItemsOneDayTableUpdateCompanionBuilder =
    GongKeItemsOneDayCompanion Function({
      Value<int> id,
      Value<int> fayuanId,
      Value<String> gongketype,
      Value<String> name,
      Value<int> cnt,
      Value<int> idx,
    });

class $$GongKeItemsOneDayTableFilterComposer
    extends Composer<_$AppDatabase, $GongKeItemsOneDayTable> {
  $$GongKeItemsOneDayTableFilterComposer({
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

  ColumnFilters<int> get fayuanId => $composableBuilder(
    column: $table.fayuanId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gongketype => $composableBuilder(
    column: $table.gongketype,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cnt => $composableBuilder(
    column: $table.cnt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get idx => $composableBuilder(
    column: $table.idx,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GongKeItemsOneDayTableOrderingComposer
    extends Composer<_$AppDatabase, $GongKeItemsOneDayTable> {
  $$GongKeItemsOneDayTableOrderingComposer({
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

  ColumnOrderings<int> get fayuanId => $composableBuilder(
    column: $table.fayuanId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gongketype => $composableBuilder(
    column: $table.gongketype,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cnt => $composableBuilder(
    column: $table.cnt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get idx => $composableBuilder(
    column: $table.idx,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GongKeItemsOneDayTableAnnotationComposer
    extends Composer<_$AppDatabase, $GongKeItemsOneDayTable> {
  $$GongKeItemsOneDayTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get fayuanId =>
      $composableBuilder(column: $table.fayuanId, builder: (column) => column);

  GeneratedColumn<String> get gongketype => $composableBuilder(
    column: $table.gongketype,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get cnt =>
      $composableBuilder(column: $table.cnt, builder: (column) => column);

  GeneratedColumn<int> get idx =>
      $composableBuilder(column: $table.idx, builder: (column) => column);
}

class $$GongKeItemsOneDayTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GongKeItemsOneDayTable,
          GongKeItemsOneDayData,
          $$GongKeItemsOneDayTableFilterComposer,
          $$GongKeItemsOneDayTableOrderingComposer,
          $$GongKeItemsOneDayTableAnnotationComposer,
          $$GongKeItemsOneDayTableCreateCompanionBuilder,
          $$GongKeItemsOneDayTableUpdateCompanionBuilder,
          (
            GongKeItemsOneDayData,
            BaseReferences<
              _$AppDatabase,
              $GongKeItemsOneDayTable,
              GongKeItemsOneDayData
            >,
          ),
          GongKeItemsOneDayData,
          PrefetchHooks Function()
        > {
  $$GongKeItemsOneDayTableTableManager(
    _$AppDatabase db,
    $GongKeItemsOneDayTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GongKeItemsOneDayTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GongKeItemsOneDayTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GongKeItemsOneDayTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> fayuanId = const Value.absent(),
                Value<String> gongketype = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> cnt = const Value.absent(),
                Value<int> idx = const Value.absent(),
              }) => GongKeItemsOneDayCompanion(
                id: id,
                fayuanId: fayuanId,
                gongketype: gongketype,
                name: name,
                cnt: cnt,
                idx: idx,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int fayuanId,
                Value<String> gongketype = const Value.absent(),
                required String name,
                Value<int> cnt = const Value.absent(),
                Value<int> idx = const Value.absent(),
              }) => GongKeItemsOneDayCompanion.insert(
                id: id,
                fayuanId: fayuanId,
                gongketype: gongketype,
                name: name,
                cnt: cnt,
                idx: idx,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GongKeItemsOneDayTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GongKeItemsOneDayTable,
      GongKeItemsOneDayData,
      $$GongKeItemsOneDayTableFilterComposer,
      $$GongKeItemsOneDayTableOrderingComposer,
      $$GongKeItemsOneDayTableAnnotationComposer,
      $$GongKeItemsOneDayTableCreateCompanionBuilder,
      $$GongKeItemsOneDayTableUpdateCompanionBuilder,
      (
        GongKeItemsOneDayData,
        BaseReferences<
          _$AppDatabase,
          $GongKeItemsOneDayTable,
          GongKeItemsOneDayData
        >,
      ),
      GongKeItemsOneDayData,
      PrefetchHooks Function()
    >;
typedef $$GongKeItemTableCreateCompanionBuilder =
    GongKeItemCompanion Function({
      Value<int> id,
      Value<DateTime> createDateTime,
      Value<String?> remarks,
      Value<String?> bk1,
      Value<String?> bk2,
      required String name,
      required int fayuanId,
      required String gongketype,
      Value<int> cnt,
      required String gongKeDay,
      Value<bool> isComplete,
      Value<int> idx,
      Value<int> curCnt,
    });
typedef $$GongKeItemTableUpdateCompanionBuilder =
    GongKeItemCompanion Function({
      Value<int> id,
      Value<DateTime> createDateTime,
      Value<String?> remarks,
      Value<String?> bk1,
      Value<String?> bk2,
      Value<String> name,
      Value<int> fayuanId,
      Value<String> gongketype,
      Value<int> cnt,
      Value<String> gongKeDay,
      Value<bool> isComplete,
      Value<int> idx,
      Value<int> curCnt,
    });

class $$GongKeItemTableFilterComposer
    extends Composer<_$AppDatabase, $GongKeItemTable> {
  $$GongKeItemTableFilterComposer({
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

  ColumnFilters<DateTime> get createDateTime => $composableBuilder(
    column: $table.createDateTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bk1 => $composableBuilder(
    column: $table.bk1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bk2 => $composableBuilder(
    column: $table.bk2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fayuanId => $composableBuilder(
    column: $table.fayuanId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gongketype => $composableBuilder(
    column: $table.gongketype,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cnt => $composableBuilder(
    column: $table.cnt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gongKeDay => $composableBuilder(
    column: $table.gongKeDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isComplete => $composableBuilder(
    column: $table.isComplete,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get idx => $composableBuilder(
    column: $table.idx,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get curCnt => $composableBuilder(
    column: $table.curCnt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GongKeItemTableOrderingComposer
    extends Composer<_$AppDatabase, $GongKeItemTable> {
  $$GongKeItemTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createDateTime => $composableBuilder(
    column: $table.createDateTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bk1 => $composableBuilder(
    column: $table.bk1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bk2 => $composableBuilder(
    column: $table.bk2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fayuanId => $composableBuilder(
    column: $table.fayuanId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gongketype => $composableBuilder(
    column: $table.gongketype,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cnt => $composableBuilder(
    column: $table.cnt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gongKeDay => $composableBuilder(
    column: $table.gongKeDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isComplete => $composableBuilder(
    column: $table.isComplete,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get idx => $composableBuilder(
    column: $table.idx,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get curCnt => $composableBuilder(
    column: $table.curCnt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GongKeItemTableAnnotationComposer
    extends Composer<_$AppDatabase, $GongKeItemTable> {
  $$GongKeItemTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createDateTime => $composableBuilder(
    column: $table.createDateTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  GeneratedColumn<String> get bk1 =>
      $composableBuilder(column: $table.bk1, builder: (column) => column);

  GeneratedColumn<String> get bk2 =>
      $composableBuilder(column: $table.bk2, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get fayuanId =>
      $composableBuilder(column: $table.fayuanId, builder: (column) => column);

  GeneratedColumn<String> get gongketype => $composableBuilder(
    column: $table.gongketype,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cnt =>
      $composableBuilder(column: $table.cnt, builder: (column) => column);

  GeneratedColumn<String> get gongKeDay =>
      $composableBuilder(column: $table.gongKeDay, builder: (column) => column);

  GeneratedColumn<bool> get isComplete => $composableBuilder(
    column: $table.isComplete,
    builder: (column) => column,
  );

  GeneratedColumn<int> get idx =>
      $composableBuilder(column: $table.idx, builder: (column) => column);

  GeneratedColumn<int> get curCnt =>
      $composableBuilder(column: $table.curCnt, builder: (column) => column);
}

class $$GongKeItemTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GongKeItemTable,
          GongKeItemData,
          $$GongKeItemTableFilterComposer,
          $$GongKeItemTableOrderingComposer,
          $$GongKeItemTableAnnotationComposer,
          $$GongKeItemTableCreateCompanionBuilder,
          $$GongKeItemTableUpdateCompanionBuilder,
          (
            GongKeItemData,
            BaseReferences<_$AppDatabase, $GongKeItemTable, GongKeItemData>,
          ),
          GongKeItemData,
          PrefetchHooks Function()
        > {
  $$GongKeItemTableTableManager(_$AppDatabase db, $GongKeItemTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GongKeItemTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GongKeItemTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GongKeItemTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createDateTime = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<String?> bk1 = const Value.absent(),
                Value<String?> bk2 = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> fayuanId = const Value.absent(),
                Value<String> gongketype = const Value.absent(),
                Value<int> cnt = const Value.absent(),
                Value<String> gongKeDay = const Value.absent(),
                Value<bool> isComplete = const Value.absent(),
                Value<int> idx = const Value.absent(),
                Value<int> curCnt = const Value.absent(),
              }) => GongKeItemCompanion(
                id: id,
                createDateTime: createDateTime,
                remarks: remarks,
                bk1: bk1,
                bk2: bk2,
                name: name,
                fayuanId: fayuanId,
                gongketype: gongketype,
                cnt: cnt,
                gongKeDay: gongKeDay,
                isComplete: isComplete,
                idx: idx,
                curCnt: curCnt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createDateTime = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<String?> bk1 = const Value.absent(),
                Value<String?> bk2 = const Value.absent(),
                required String name,
                required int fayuanId,
                required String gongketype,
                Value<int> cnt = const Value.absent(),
                required String gongKeDay,
                Value<bool> isComplete = const Value.absent(),
                Value<int> idx = const Value.absent(),
                Value<int> curCnt = const Value.absent(),
              }) => GongKeItemCompanion.insert(
                id: id,
                createDateTime: createDateTime,
                remarks: remarks,
                bk1: bk1,
                bk2: bk2,
                name: name,
                fayuanId: fayuanId,
                gongketype: gongketype,
                cnt: cnt,
                gongKeDay: gongKeDay,
                isComplete: isComplete,
                idx: idx,
                curCnt: curCnt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GongKeItemTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GongKeItemTable,
      GongKeItemData,
      $$GongKeItemTableFilterComposer,
      $$GongKeItemTableOrderingComposer,
      $$GongKeItemTableAnnotationComposer,
      $$GongKeItemTableCreateCompanionBuilder,
      $$GongKeItemTableUpdateCompanionBuilder,
      (
        GongKeItemData,
        BaseReferences<_$AppDatabase, $GongKeItemTable, GongKeItemData>,
      ),
      GongKeItemData,
      PrefetchHooks Function()
    >;
typedef $$JingShuTableCreateCompanionBuilder =
    JingShuCompanion Function({
      Value<int> id,
      Value<DateTime> createDateTime,
      Value<DateTime?> favoriteDateTime,
      Value<String?> remarks,
      Value<String?> bk1,
      Value<String?> bk2,
      required String name,
      required String type,
      required String image,
      required String fileUrl,
      required String fileType,
      Value<bool> muyu,
      Value<bool> bkMusic,
      Value<String?> bkMusicname,
      Value<String?> muyuName,
      Value<String?> muyuImage,
      Value<String?> muyuType,
      Value<int?> muyuCount,
      Value<double?> muyuInterval,
      Value<double?> muyuDuration,
      Value<int?> curPageNum,
    });
typedef $$JingShuTableUpdateCompanionBuilder =
    JingShuCompanion Function({
      Value<int> id,
      Value<DateTime> createDateTime,
      Value<DateTime?> favoriteDateTime,
      Value<String?> remarks,
      Value<String?> bk1,
      Value<String?> bk2,
      Value<String> name,
      Value<String> type,
      Value<String> image,
      Value<String> fileUrl,
      Value<String> fileType,
      Value<bool> muyu,
      Value<bool> bkMusic,
      Value<String?> bkMusicname,
      Value<String?> muyuName,
      Value<String?> muyuImage,
      Value<String?> muyuType,
      Value<int?> muyuCount,
      Value<double?> muyuInterval,
      Value<double?> muyuDuration,
      Value<int?> curPageNum,
    });

class $$JingShuTableFilterComposer
    extends Composer<_$AppDatabase, $JingShuTable> {
  $$JingShuTableFilterComposer({
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

  ColumnFilters<DateTime> get createDateTime => $composableBuilder(
    column: $table.createDateTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get favoriteDateTime => $composableBuilder(
    column: $table.favoriteDateTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bk1 => $composableBuilder(
    column: $table.bk1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bk2 => $composableBuilder(
    column: $table.bk2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get image => $composableBuilder(
    column: $table.image,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileUrl => $composableBuilder(
    column: $table.fileUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileType => $composableBuilder(
    column: $table.fileType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get muyu => $composableBuilder(
    column: $table.muyu,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get bkMusic => $composableBuilder(
    column: $table.bkMusic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bkMusicname => $composableBuilder(
    column: $table.bkMusicname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get muyuName => $composableBuilder(
    column: $table.muyuName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get muyuImage => $composableBuilder(
    column: $table.muyuImage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get muyuType => $composableBuilder(
    column: $table.muyuType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get muyuCount => $composableBuilder(
    column: $table.muyuCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get muyuInterval => $composableBuilder(
    column: $table.muyuInterval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get muyuDuration => $composableBuilder(
    column: $table.muyuDuration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get curPageNum => $composableBuilder(
    column: $table.curPageNum,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JingShuTableOrderingComposer
    extends Composer<_$AppDatabase, $JingShuTable> {
  $$JingShuTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createDateTime => $composableBuilder(
    column: $table.createDateTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get favoriteDateTime => $composableBuilder(
    column: $table.favoriteDateTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bk1 => $composableBuilder(
    column: $table.bk1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bk2 => $composableBuilder(
    column: $table.bk2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get image => $composableBuilder(
    column: $table.image,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileUrl => $composableBuilder(
    column: $table.fileUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileType => $composableBuilder(
    column: $table.fileType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get muyu => $composableBuilder(
    column: $table.muyu,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get bkMusic => $composableBuilder(
    column: $table.bkMusic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bkMusicname => $composableBuilder(
    column: $table.bkMusicname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get muyuName => $composableBuilder(
    column: $table.muyuName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get muyuImage => $composableBuilder(
    column: $table.muyuImage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get muyuType => $composableBuilder(
    column: $table.muyuType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get muyuCount => $composableBuilder(
    column: $table.muyuCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get muyuInterval => $composableBuilder(
    column: $table.muyuInterval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get muyuDuration => $composableBuilder(
    column: $table.muyuDuration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get curPageNum => $composableBuilder(
    column: $table.curPageNum,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JingShuTableAnnotationComposer
    extends Composer<_$AppDatabase, $JingShuTable> {
  $$JingShuTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createDateTime => $composableBuilder(
    column: $table.createDateTime,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get favoriteDateTime => $composableBuilder(
    column: $table.favoriteDateTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  GeneratedColumn<String> get bk1 =>
      $composableBuilder(column: $table.bk1, builder: (column) => column);

  GeneratedColumn<String> get bk2 =>
      $composableBuilder(column: $table.bk2, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get image =>
      $composableBuilder(column: $table.image, builder: (column) => column);

  GeneratedColumn<String> get fileUrl =>
      $composableBuilder(column: $table.fileUrl, builder: (column) => column);

  GeneratedColumn<String> get fileType =>
      $composableBuilder(column: $table.fileType, builder: (column) => column);

  GeneratedColumn<bool> get muyu =>
      $composableBuilder(column: $table.muyu, builder: (column) => column);

  GeneratedColumn<bool> get bkMusic =>
      $composableBuilder(column: $table.bkMusic, builder: (column) => column);

  GeneratedColumn<String> get bkMusicname => $composableBuilder(
    column: $table.bkMusicname,
    builder: (column) => column,
  );

  GeneratedColumn<String> get muyuName =>
      $composableBuilder(column: $table.muyuName, builder: (column) => column);

  GeneratedColumn<String> get muyuImage =>
      $composableBuilder(column: $table.muyuImage, builder: (column) => column);

  GeneratedColumn<String> get muyuType =>
      $composableBuilder(column: $table.muyuType, builder: (column) => column);

  GeneratedColumn<int> get muyuCount =>
      $composableBuilder(column: $table.muyuCount, builder: (column) => column);

  GeneratedColumn<double> get muyuInterval => $composableBuilder(
    column: $table.muyuInterval,
    builder: (column) => column,
  );

  GeneratedColumn<double> get muyuDuration => $composableBuilder(
    column: $table.muyuDuration,
    builder: (column) => column,
  );

  GeneratedColumn<int> get curPageNum => $composableBuilder(
    column: $table.curPageNum,
    builder: (column) => column,
  );
}

class $$JingShuTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JingShuTable,
          JingShuData,
          $$JingShuTableFilterComposer,
          $$JingShuTableOrderingComposer,
          $$JingShuTableAnnotationComposer,
          $$JingShuTableCreateCompanionBuilder,
          $$JingShuTableUpdateCompanionBuilder,
          (
            JingShuData,
            BaseReferences<_$AppDatabase, $JingShuTable, JingShuData>,
          ),
          JingShuData,
          PrefetchHooks Function()
        > {
  $$JingShuTableTableManager(_$AppDatabase db, $JingShuTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JingShuTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JingShuTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JingShuTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createDateTime = const Value.absent(),
                Value<DateTime?> favoriteDateTime = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<String?> bk1 = const Value.absent(),
                Value<String?> bk2 = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> image = const Value.absent(),
                Value<String> fileUrl = const Value.absent(),
                Value<String> fileType = const Value.absent(),
                Value<bool> muyu = const Value.absent(),
                Value<bool> bkMusic = const Value.absent(),
                Value<String?> bkMusicname = const Value.absent(),
                Value<String?> muyuName = const Value.absent(),
                Value<String?> muyuImage = const Value.absent(),
                Value<String?> muyuType = const Value.absent(),
                Value<int?> muyuCount = const Value.absent(),
                Value<double?> muyuInterval = const Value.absent(),
                Value<double?> muyuDuration = const Value.absent(),
                Value<int?> curPageNum = const Value.absent(),
              }) => JingShuCompanion(
                id: id,
                createDateTime: createDateTime,
                favoriteDateTime: favoriteDateTime,
                remarks: remarks,
                bk1: bk1,
                bk2: bk2,
                name: name,
                type: type,
                image: image,
                fileUrl: fileUrl,
                fileType: fileType,
                muyu: muyu,
                bkMusic: bkMusic,
                bkMusicname: bkMusicname,
                muyuName: muyuName,
                muyuImage: muyuImage,
                muyuType: muyuType,
                muyuCount: muyuCount,
                muyuInterval: muyuInterval,
                muyuDuration: muyuDuration,
                curPageNum: curPageNum,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createDateTime = const Value.absent(),
                Value<DateTime?> favoriteDateTime = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<String?> bk1 = const Value.absent(),
                Value<String?> bk2 = const Value.absent(),
                required String name,
                required String type,
                required String image,
                required String fileUrl,
                required String fileType,
                Value<bool> muyu = const Value.absent(),
                Value<bool> bkMusic = const Value.absent(),
                Value<String?> bkMusicname = const Value.absent(),
                Value<String?> muyuName = const Value.absent(),
                Value<String?> muyuImage = const Value.absent(),
                Value<String?> muyuType = const Value.absent(),
                Value<int?> muyuCount = const Value.absent(),
                Value<double?> muyuInterval = const Value.absent(),
                Value<double?> muyuDuration = const Value.absent(),
                Value<int?> curPageNum = const Value.absent(),
              }) => JingShuCompanion.insert(
                id: id,
                createDateTime: createDateTime,
                favoriteDateTime: favoriteDateTime,
                remarks: remarks,
                bk1: bk1,
                bk2: bk2,
                name: name,
                type: type,
                image: image,
                fileUrl: fileUrl,
                fileType: fileType,
                muyu: muyu,
                bkMusic: bkMusic,
                bkMusicname: bkMusicname,
                muyuName: muyuName,
                muyuImage: muyuImage,
                muyuType: muyuType,
                muyuCount: muyuCount,
                muyuInterval: muyuInterval,
                muyuDuration: muyuDuration,
                curPageNum: curPageNum,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JingShuTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JingShuTable,
      JingShuData,
      $$JingShuTableFilterComposer,
      $$JingShuTableOrderingComposer,
      $$JingShuTableAnnotationComposer,
      $$JingShuTableCreateCompanionBuilder,
      $$JingShuTableUpdateCompanionBuilder,
      (JingShuData, BaseReferences<_$AppDatabase, $JingShuTable, JingShuData>),
      JingShuData,
      PrefetchHooks Function()
    >;
typedef $$TipBookTableCreateCompanionBuilder =
    TipBookCompanion Function({
      Value<int> id,
      Value<DateTime> createDateTime,
      Value<DateTime?> favoriteDateTime,
      Value<String?> remarks,
      Value<String?> bk1,
      Value<String?> bk2,
      required String name,
      required String image,
    });
typedef $$TipBookTableUpdateCompanionBuilder =
    TipBookCompanion Function({
      Value<int> id,
      Value<DateTime> createDateTime,
      Value<DateTime?> favoriteDateTime,
      Value<String?> remarks,
      Value<String?> bk1,
      Value<String?> bk2,
      Value<String> name,
      Value<String> image,
    });

class $$TipBookTableFilterComposer
    extends Composer<_$AppDatabase, $TipBookTable> {
  $$TipBookTableFilterComposer({
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

  ColumnFilters<DateTime> get createDateTime => $composableBuilder(
    column: $table.createDateTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get favoriteDateTime => $composableBuilder(
    column: $table.favoriteDateTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bk1 => $composableBuilder(
    column: $table.bk1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bk2 => $composableBuilder(
    column: $table.bk2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get image => $composableBuilder(
    column: $table.image,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TipBookTableOrderingComposer
    extends Composer<_$AppDatabase, $TipBookTable> {
  $$TipBookTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createDateTime => $composableBuilder(
    column: $table.createDateTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get favoriteDateTime => $composableBuilder(
    column: $table.favoriteDateTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bk1 => $composableBuilder(
    column: $table.bk1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bk2 => $composableBuilder(
    column: $table.bk2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get image => $composableBuilder(
    column: $table.image,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TipBookTableAnnotationComposer
    extends Composer<_$AppDatabase, $TipBookTable> {
  $$TipBookTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createDateTime => $composableBuilder(
    column: $table.createDateTime,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get favoriteDateTime => $composableBuilder(
    column: $table.favoriteDateTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  GeneratedColumn<String> get bk1 =>
      $composableBuilder(column: $table.bk1, builder: (column) => column);

  GeneratedColumn<String> get bk2 =>
      $composableBuilder(column: $table.bk2, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get image =>
      $composableBuilder(column: $table.image, builder: (column) => column);
}

class $$TipBookTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TipBookTable,
          TipBookData,
          $$TipBookTableFilterComposer,
          $$TipBookTableOrderingComposer,
          $$TipBookTableAnnotationComposer,
          $$TipBookTableCreateCompanionBuilder,
          $$TipBookTableUpdateCompanionBuilder,
          (
            TipBookData,
            BaseReferences<_$AppDatabase, $TipBookTable, TipBookData>,
          ),
          TipBookData,
          PrefetchHooks Function()
        > {
  $$TipBookTableTableManager(_$AppDatabase db, $TipBookTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TipBookTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TipBookTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TipBookTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createDateTime = const Value.absent(),
                Value<DateTime?> favoriteDateTime = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<String?> bk1 = const Value.absent(),
                Value<String?> bk2 = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> image = const Value.absent(),
              }) => TipBookCompanion(
                id: id,
                createDateTime: createDateTime,
                favoriteDateTime: favoriteDateTime,
                remarks: remarks,
                bk1: bk1,
                bk2: bk2,
                name: name,
                image: image,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createDateTime = const Value.absent(),
                Value<DateTime?> favoriteDateTime = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<String?> bk1 = const Value.absent(),
                Value<String?> bk2 = const Value.absent(),
                required String name,
                required String image,
              }) => TipBookCompanion.insert(
                id: id,
                createDateTime: createDateTime,
                favoriteDateTime: favoriteDateTime,
                remarks: remarks,
                bk1: bk1,
                bk2: bk2,
                name: name,
                image: image,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TipBookTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TipBookTable,
      TipBookData,
      $$TipBookTableFilterComposer,
      $$TipBookTableOrderingComposer,
      $$TipBookTableAnnotationComposer,
      $$TipBookTableCreateCompanionBuilder,
      $$TipBookTableUpdateCompanionBuilder,
      (TipBookData, BaseReferences<_$AppDatabase, $TipBookTable, TipBookData>),
      TipBookData,
      PrefetchHooks Function()
    >;
typedef $$TipRecordTableCreateCompanionBuilder =
    TipRecordCompanion Function({
      Value<int> id,
      Value<DateTime> createDateTime,
      Value<String?> remarks,
      Value<String?> bk1,
      Value<String?> bk2,
      required String content,
      required int bookId,
    });
typedef $$TipRecordTableUpdateCompanionBuilder =
    TipRecordCompanion Function({
      Value<int> id,
      Value<DateTime> createDateTime,
      Value<String?> remarks,
      Value<String?> bk1,
      Value<String?> bk2,
      Value<String> content,
      Value<int> bookId,
    });

class $$TipRecordTableFilterComposer
    extends Composer<_$AppDatabase, $TipRecordTable> {
  $$TipRecordTableFilterComposer({
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

  ColumnFilters<DateTime> get createDateTime => $composableBuilder(
    column: $table.createDateTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bk1 => $composableBuilder(
    column: $table.bk1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bk2 => $composableBuilder(
    column: $table.bk2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TipRecordTableOrderingComposer
    extends Composer<_$AppDatabase, $TipRecordTable> {
  $$TipRecordTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createDateTime => $composableBuilder(
    column: $table.createDateTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bk1 => $composableBuilder(
    column: $table.bk1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bk2 => $composableBuilder(
    column: $table.bk2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TipRecordTableAnnotationComposer
    extends Composer<_$AppDatabase, $TipRecordTable> {
  $$TipRecordTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createDateTime => $composableBuilder(
    column: $table.createDateTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  GeneratedColumn<String> get bk1 =>
      $composableBuilder(column: $table.bk1, builder: (column) => column);

  GeneratedColumn<String> get bk2 =>
      $composableBuilder(column: $table.bk2, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);
}

class $$TipRecordTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TipRecordTable,
          TipRecordData,
          $$TipRecordTableFilterComposer,
          $$TipRecordTableOrderingComposer,
          $$TipRecordTableAnnotationComposer,
          $$TipRecordTableCreateCompanionBuilder,
          $$TipRecordTableUpdateCompanionBuilder,
          (
            TipRecordData,
            BaseReferences<_$AppDatabase, $TipRecordTable, TipRecordData>,
          ),
          TipRecordData,
          PrefetchHooks Function()
        > {
  $$TipRecordTableTableManager(_$AppDatabase db, $TipRecordTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TipRecordTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TipRecordTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TipRecordTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createDateTime = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<String?> bk1 = const Value.absent(),
                Value<String?> bk2 = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> bookId = const Value.absent(),
              }) => TipRecordCompanion(
                id: id,
                createDateTime: createDateTime,
                remarks: remarks,
                bk1: bk1,
                bk2: bk2,
                content: content,
                bookId: bookId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createDateTime = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<String?> bk1 = const Value.absent(),
                Value<String?> bk2 = const Value.absent(),
                required String content,
                required int bookId,
              }) => TipRecordCompanion.insert(
                id: id,
                createDateTime: createDateTime,
                remarks: remarks,
                bk1: bk1,
                bk2: bk2,
                content: content,
                bookId: bookId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TipRecordTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TipRecordTable,
      TipRecordData,
      $$TipRecordTableFilterComposer,
      $$TipRecordTableOrderingComposer,
      $$TipRecordTableAnnotationComposer,
      $$TipRecordTableCreateCompanionBuilder,
      $$TipRecordTableUpdateCompanionBuilder,
      (
        TipRecordData,
        BaseReferences<_$AppDatabase, $TipRecordTable, TipRecordData>,
      ),
      TipRecordData,
      PrefetchHooks Function()
    >;
typedef $$BaiChanTableCreateCompanionBuilder =
    BaiChanCompanion Function({
      Value<int> id,
      Value<DateTime> createDateTime,
      Value<DateTime?> favoriteDateTime,
      Value<String?> remarks,
      Value<String?> bk1,
      Value<String?> bk2,
      required String name,
      required String image,
      required String chanhuiWenStart,
      required String chanhuiWenEnd,
      Value<int> baichanTimes,
      Value<int> baichanInterval1,
      Value<int> baichanInterval2,
      Value<bool> flagOrderNumber,
      Value<bool> flagQiShen,
      Value<String?> detail,
    });
typedef $$BaiChanTableUpdateCompanionBuilder =
    BaiChanCompanion Function({
      Value<int> id,
      Value<DateTime> createDateTime,
      Value<DateTime?> favoriteDateTime,
      Value<String?> remarks,
      Value<String?> bk1,
      Value<String?> bk2,
      Value<String> name,
      Value<String> image,
      Value<String> chanhuiWenStart,
      Value<String> chanhuiWenEnd,
      Value<int> baichanTimes,
      Value<int> baichanInterval1,
      Value<int> baichanInterval2,
      Value<bool> flagOrderNumber,
      Value<bool> flagQiShen,
      Value<String?> detail,
    });

class $$BaiChanTableFilterComposer
    extends Composer<_$AppDatabase, $BaiChanTable> {
  $$BaiChanTableFilterComposer({
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

  ColumnFilters<DateTime> get createDateTime => $composableBuilder(
    column: $table.createDateTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get favoriteDateTime => $composableBuilder(
    column: $table.favoriteDateTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bk1 => $composableBuilder(
    column: $table.bk1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bk2 => $composableBuilder(
    column: $table.bk2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get image => $composableBuilder(
    column: $table.image,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chanhuiWenStart => $composableBuilder(
    column: $table.chanhuiWenStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chanhuiWenEnd => $composableBuilder(
    column: $table.chanhuiWenEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baichanTimes => $composableBuilder(
    column: $table.baichanTimes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baichanInterval1 => $composableBuilder(
    column: $table.baichanInterval1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baichanInterval2 => $composableBuilder(
    column: $table.baichanInterval2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get flagOrderNumber => $composableBuilder(
    column: $table.flagOrderNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get flagQiShen => $composableBuilder(
    column: $table.flagQiShen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BaiChanTableOrderingComposer
    extends Composer<_$AppDatabase, $BaiChanTable> {
  $$BaiChanTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createDateTime => $composableBuilder(
    column: $table.createDateTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get favoriteDateTime => $composableBuilder(
    column: $table.favoriteDateTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bk1 => $composableBuilder(
    column: $table.bk1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bk2 => $composableBuilder(
    column: $table.bk2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get image => $composableBuilder(
    column: $table.image,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chanhuiWenStart => $composableBuilder(
    column: $table.chanhuiWenStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chanhuiWenEnd => $composableBuilder(
    column: $table.chanhuiWenEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baichanTimes => $composableBuilder(
    column: $table.baichanTimes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baichanInterval1 => $composableBuilder(
    column: $table.baichanInterval1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baichanInterval2 => $composableBuilder(
    column: $table.baichanInterval2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get flagOrderNumber => $composableBuilder(
    column: $table.flagOrderNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get flagQiShen => $composableBuilder(
    column: $table.flagQiShen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BaiChanTableAnnotationComposer
    extends Composer<_$AppDatabase, $BaiChanTable> {
  $$BaiChanTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createDateTime => $composableBuilder(
    column: $table.createDateTime,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get favoriteDateTime => $composableBuilder(
    column: $table.favoriteDateTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  GeneratedColumn<String> get bk1 =>
      $composableBuilder(column: $table.bk1, builder: (column) => column);

  GeneratedColumn<String> get bk2 =>
      $composableBuilder(column: $table.bk2, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get image =>
      $composableBuilder(column: $table.image, builder: (column) => column);

  GeneratedColumn<String> get chanhuiWenStart => $composableBuilder(
    column: $table.chanhuiWenStart,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chanhuiWenEnd => $composableBuilder(
    column: $table.chanhuiWenEnd,
    builder: (column) => column,
  );

  GeneratedColumn<int> get baichanTimes => $composableBuilder(
    column: $table.baichanTimes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get baichanInterval1 => $composableBuilder(
    column: $table.baichanInterval1,
    builder: (column) => column,
  );

  GeneratedColumn<int> get baichanInterval2 => $composableBuilder(
    column: $table.baichanInterval2,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get flagOrderNumber => $composableBuilder(
    column: $table.flagOrderNumber,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get flagQiShen => $composableBuilder(
    column: $table.flagQiShen,
    builder: (column) => column,
  );

  GeneratedColumn<String> get detail =>
      $composableBuilder(column: $table.detail, builder: (column) => column);
}

class $$BaiChanTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BaiChanTable,
          BaiChanData,
          $$BaiChanTableFilterComposer,
          $$BaiChanTableOrderingComposer,
          $$BaiChanTableAnnotationComposer,
          $$BaiChanTableCreateCompanionBuilder,
          $$BaiChanTableUpdateCompanionBuilder,
          (
            BaiChanData,
            BaseReferences<_$AppDatabase, $BaiChanTable, BaiChanData>,
          ),
          BaiChanData,
          PrefetchHooks Function()
        > {
  $$BaiChanTableTableManager(_$AppDatabase db, $BaiChanTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BaiChanTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BaiChanTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BaiChanTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createDateTime = const Value.absent(),
                Value<DateTime?> favoriteDateTime = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<String?> bk1 = const Value.absent(),
                Value<String?> bk2 = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> image = const Value.absent(),
                Value<String> chanhuiWenStart = const Value.absent(),
                Value<String> chanhuiWenEnd = const Value.absent(),
                Value<int> baichanTimes = const Value.absent(),
                Value<int> baichanInterval1 = const Value.absent(),
                Value<int> baichanInterval2 = const Value.absent(),
                Value<bool> flagOrderNumber = const Value.absent(),
                Value<bool> flagQiShen = const Value.absent(),
                Value<String?> detail = const Value.absent(),
              }) => BaiChanCompanion(
                id: id,
                createDateTime: createDateTime,
                favoriteDateTime: favoriteDateTime,
                remarks: remarks,
                bk1: bk1,
                bk2: bk2,
                name: name,
                image: image,
                chanhuiWenStart: chanhuiWenStart,
                chanhuiWenEnd: chanhuiWenEnd,
                baichanTimes: baichanTimes,
                baichanInterval1: baichanInterval1,
                baichanInterval2: baichanInterval2,
                flagOrderNumber: flagOrderNumber,
                flagQiShen: flagQiShen,
                detail: detail,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createDateTime = const Value.absent(),
                Value<DateTime?> favoriteDateTime = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<String?> bk1 = const Value.absent(),
                Value<String?> bk2 = const Value.absent(),
                required String name,
                required String image,
                required String chanhuiWenStart,
                required String chanhuiWenEnd,
                Value<int> baichanTimes = const Value.absent(),
                Value<int> baichanInterval1 = const Value.absent(),
                Value<int> baichanInterval2 = const Value.absent(),
                Value<bool> flagOrderNumber = const Value.absent(),
                Value<bool> flagQiShen = const Value.absent(),
                Value<String?> detail = const Value.absent(),
              }) => BaiChanCompanion.insert(
                id: id,
                createDateTime: createDateTime,
                favoriteDateTime: favoriteDateTime,
                remarks: remarks,
                bk1: bk1,
                bk2: bk2,
                name: name,
                image: image,
                chanhuiWenStart: chanhuiWenStart,
                chanhuiWenEnd: chanhuiWenEnd,
                baichanTimes: baichanTimes,
                baichanInterval1: baichanInterval1,
                baichanInterval2: baichanInterval2,
                flagOrderNumber: flagOrderNumber,
                flagQiShen: flagQiShen,
                detail: detail,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BaiChanTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BaiChanTable,
      BaiChanData,
      $$BaiChanTableFilterComposer,
      $$BaiChanTableOrderingComposer,
      $$BaiChanTableAnnotationComposer,
      $$BaiChanTableCreateCompanionBuilder,
      $$BaiChanTableUpdateCompanionBuilder,
      (BaiChanData, BaseReferences<_$AppDatabase, $BaiChanTable, BaiChanData>),
      BaiChanData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FaYuanTableTableManager get faYuan =>
      $$FaYuanTableTableManager(_db, _db.faYuan);
  $$GongKeItemsOneDayTableTableManager get gongKeItemsOneDay =>
      $$GongKeItemsOneDayTableTableManager(_db, _db.gongKeItemsOneDay);
  $$GongKeItemTableTableManager get gongKeItem =>
      $$GongKeItemTableTableManager(_db, _db.gongKeItem);
  $$JingShuTableTableManager get jingShu =>
      $$JingShuTableTableManager(_db, _db.jingShu);
  $$TipBookTableTableManager get tipBook =>
      $$TipBookTableTableManager(_db, _db.tipBook);
  $$TipRecordTableTableManager get tipRecord =>
      $$TipRecordTableTableManager(_db, _db.tipRecord);
  $$BaiChanTableTableManager get baiChan =>
      $$BaiChanTableTableManager(_db, _db.baiChan);
}
