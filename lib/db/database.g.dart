// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TxType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TxType>($CategoriesTable.$convertertype);
  static const VerificationMeta _nameKeyMeta = const VerificationMeta(
    'nameKey',
  );
  @override
  late final GeneratedColumn<String> nameKey = GeneratedColumn<String>(
    'name_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customNameMeta = const VerificationMeta(
    'customName',
  );
  @override
  late final GeneratedColumn<String> customName = GeneratedColumn<String>(
    'custom_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isBuiltInMeta = const VerificationMeta(
    'isBuiltIn',
  );
  @override
  late final GeneratedColumn<bool> isBuiltIn = GeneratedColumn<bool>(
    'is_built_in',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_built_in" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isPinnedMeta = const VerificationMeta(
    'isPinned',
  );
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
    'is_pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
  List<GeneratedColumn> get $columns => [
    id,
    type,
    nameKey,
    customName,
    emoji,
    isBuiltIn,
    isPinned,
    isArchived,
    sortOrder,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name_key')) {
      context.handle(
        _nameKeyMeta,
        nameKey.isAcceptableOrUnknown(data['name_key']!, _nameKeyMeta),
      );
    }
    if (data.containsKey('custom_name')) {
      context.handle(
        _customNameMeta,
        customName.isAcceptableOrUnknown(data['custom_name']!, _customNameMeta),
      );
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    } else if (isInserting) {
      context.missing(_emojiMeta);
    }
    if (data.containsKey('is_built_in')) {
      context.handle(
        _isBuiltInMeta,
        isBuiltIn.isAcceptableOrUnknown(data['is_built_in']!, _isBuiltInMeta),
      );
    }
    if (data.containsKey('is_pinned')) {
      context.handle(
        _isPinnedMeta,
        isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: $CategoriesTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      nameKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_key'],
      ),
      customName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_name'],
      ),
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      )!,
      isBuiltIn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_built_in'],
      )!,
      isPinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pinned'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TxType, String, String> $convertertype =
      const EnumNameConverter<TxType>(TxType.values);
}

class Category extends DataClass implements Insertable<Category> {
  /// uuid; для вбудованих — детермінований v5 від nameKey, щоб імпорт
  /// у режимі «додати» не плодив дублікати між установками.
  final String id;
  final TxType type;

  /// 'cat.coffee' — для вбудованих, перекладається на льоту.
  final String? nameKey;

  /// Для створених користувачем; не перекладається ніколи.
  final String? customName;
  final String emoji;
  final bool isBuiltIn;

  /// Закріплена вручну, максимум 5.
  final bool isPinned;

  /// Замість видалення — щоб не ламати історію.
  final bool isArchived;
  final int sortOrder;
  final DateTime createdAt;
  const Category({
    required this.id,
    required this.type,
    this.nameKey,
    this.customName,
    required this.emoji,
    required this.isBuiltIn,
    required this.isPinned,
    required this.isArchived,
    required this.sortOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['type'] = Variable<String>(
        $CategoriesTable.$convertertype.toSql(type),
      );
    }
    if (!nullToAbsent || nameKey != null) {
      map['name_key'] = Variable<String>(nameKey);
    }
    if (!nullToAbsent || customName != null) {
      map['custom_name'] = Variable<String>(customName);
    }
    map['emoji'] = Variable<String>(emoji);
    map['is_built_in'] = Variable<bool>(isBuiltIn);
    map['is_pinned'] = Variable<bool>(isPinned);
    map['is_archived'] = Variable<bool>(isArchived);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      type: Value(type),
      nameKey: nameKey == null && nullToAbsent
          ? const Value.absent()
          : Value(nameKey),
      customName: customName == null && nullToAbsent
          ? const Value.absent()
          : Value(customName),
      emoji: Value(emoji),
      isBuiltIn: Value(isBuiltIn),
      isPinned: Value(isPinned),
      isArchived: Value(isArchived),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<String>(json['id']),
      type: $CategoriesTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      nameKey: serializer.fromJson<String?>(json['nameKey']),
      customName: serializer.fromJson<String?>(json['customName']),
      emoji: serializer.fromJson<String>(json['emoji']),
      isBuiltIn: serializer.fromJson<bool>(json['isBuiltIn']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(
        $CategoriesTable.$convertertype.toJson(type),
      ),
      'nameKey': serializer.toJson<String?>(nameKey),
      'customName': serializer.toJson<String?>(customName),
      'emoji': serializer.toJson<String>(emoji),
      'isBuiltIn': serializer.toJson<bool>(isBuiltIn),
      'isPinned': serializer.toJson<bool>(isPinned),
      'isArchived': serializer.toJson<bool>(isArchived),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Category copyWith({
    String? id,
    TxType? type,
    Value<String?> nameKey = const Value.absent(),
    Value<String?> customName = const Value.absent(),
    String? emoji,
    bool? isBuiltIn,
    bool? isPinned,
    bool? isArchived,
    int? sortOrder,
    DateTime? createdAt,
  }) => Category(
    id: id ?? this.id,
    type: type ?? this.type,
    nameKey: nameKey.present ? nameKey.value : this.nameKey,
    customName: customName.present ? customName.value : this.customName,
    emoji: emoji ?? this.emoji,
    isBuiltIn: isBuiltIn ?? this.isBuiltIn,
    isPinned: isPinned ?? this.isPinned,
    isArchived: isArchived ?? this.isArchived,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      nameKey: data.nameKey.present ? data.nameKey.value : this.nameKey,
      customName: data.customName.present
          ? data.customName.value
          : this.customName,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      isBuiltIn: data.isBuiltIn.present ? data.isBuiltIn.value : this.isBuiltIn,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('nameKey: $nameKey, ')
          ..write('customName: $customName, ')
          ..write('emoji: $emoji, ')
          ..write('isBuiltIn: $isBuiltIn, ')
          ..write('isPinned: $isPinned, ')
          ..write('isArchived: $isArchived, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    nameKey,
    customName,
    emoji,
    isBuiltIn,
    isPinned,
    isArchived,
    sortOrder,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.type == this.type &&
          other.nameKey == this.nameKey &&
          other.customName == this.customName &&
          other.emoji == this.emoji &&
          other.isBuiltIn == this.isBuiltIn &&
          other.isPinned == this.isPinned &&
          other.isArchived == this.isArchived &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> id;
  final Value<TxType> type;
  final Value<String?> nameKey;
  final Value<String?> customName;
  final Value<String> emoji;
  final Value<bool> isBuiltIn;
  final Value<bool> isPinned;
  final Value<bool> isArchived;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.nameKey = const Value.absent(),
    this.customName = const Value.absent(),
    this.emoji = const Value.absent(),
    this.isBuiltIn = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required TxType type,
    this.nameKey = const Value.absent(),
    this.customName = const Value.absent(),
    required String emoji,
    this.isBuiltIn = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       emoji = Value(emoji),
       createdAt = Value(createdAt);
  static Insertable<Category> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? nameKey,
    Expression<String>? customName,
    Expression<String>? emoji,
    Expression<bool>? isBuiltIn,
    Expression<bool>? isPinned,
    Expression<bool>? isArchived,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (nameKey != null) 'name_key': nameKey,
      if (customName != null) 'custom_name': customName,
      if (emoji != null) 'emoji': emoji,
      if (isBuiltIn != null) 'is_built_in': isBuiltIn,
      if (isPinned != null) 'is_pinned': isPinned,
      if (isArchived != null) 'is_archived': isArchived,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<TxType>? type,
    Value<String?>? nameKey,
    Value<String?>? customName,
    Value<String>? emoji,
    Value<bool>? isBuiltIn,
    Value<bool>? isPinned,
    Value<bool>? isArchived,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      nameKey: nameKey ?? this.nameKey,
      customName: customName ?? this.customName,
      emoji: emoji ?? this.emoji,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $CategoriesTable.$convertertype.toSql(type.value),
      );
    }
    if (nameKey.present) {
      map['name_key'] = Variable<String>(nameKey.value);
    }
    if (customName.present) {
      map['custom_name'] = Variable<String>(customName.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (isBuiltIn.present) {
      map['is_built_in'] = Variable<bool>(isBuiltIn.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
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
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('nameKey: $nameKey, ')
          ..write('customName: $customName, ')
          ..write('emoji: $emoji, ')
          ..write('isBuiltIn: $isBuiltIn, ')
          ..write('isPinned: $isPinned, ')
          ..write('isArchived: $isArchived, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TxType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TxType>($TransactionsTable.$convertertype);
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localDateKeyMeta = const VerificationMeta(
    'localDateKey',
  );
  @override
  late final GeneratedColumn<String> localDateKey = GeneratedColumn<String>(
    'local_date_key',
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
    true,
    type: DriftSqlType.string,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    amountMinor,
    categoryId,
    currencyCode,
    createdAtUtc,
    localDateKey,
    note,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('local_date_key')) {
      context.handle(
        _localDateKeyMeta,
        localDateKey.isAcceptableOrUnknown(
          data['local_date_key']!,
          _localDateKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localDateKeyMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: $TransactionsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_utc'],
      )!,
      localDateKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date_key'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TxType, String, String> $convertertype =
      const EnumNameConverter<TxType>(TxType.values);
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final String id;
  final TxType type;

  /// Мінорні одиниці: 8500 == 85 ₴. Завжди кратне 100 (пад без крапки).
  final int amountMinor;
  final String categoryId;

  /// Завжди дорівнює валюті з налаштувань (рішення 57): зміна валюти
  /// переписує колонку в усіх записах. Колонка лишається, щоб експорт
  /// і CSV були самоописовими.
  final String currencyCode;

  /// Точний момент у UTC. Використовується виключно для сортування
  /// всередині дня — користувачу не показується ніде (рішення 29).
  final DateTime createdAtUtc;

  /// 'yyyy-MM-dd' з локального часу в момент запису (тех. спека п.2.3).
  final String localDateKey;

  /// До 60 символів.
  final String? note;

  /// М'яке видалення заради Undo; фізичне очищення — фоном через 30 днів.
  final DateTime? deletedAt;
  const Transaction({
    required this.id,
    required this.type,
    required this.amountMinor,
    required this.categoryId,
    required this.currencyCode,
    required this.createdAtUtc,
    required this.localDateKey,
    this.note,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['type'] = Variable<String>(
        $TransactionsTable.$convertertype.toSql(type),
      );
    }
    map['amount_minor'] = Variable<int>(amountMinor);
    map['category_id'] = Variable<String>(categoryId);
    map['currency_code'] = Variable<String>(currencyCode);
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    map['local_date_key'] = Variable<String>(localDateKey);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      type: Value(type),
      amountMinor: Value(amountMinor),
      categoryId: Value(categoryId),
      currencyCode: Value(currencyCode),
      createdAtUtc: Value(createdAtUtc),
      localDateKey: Value(localDateKey),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Transaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<String>(json['id']),
      type: $TransactionsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
      localDateKey: serializer.fromJson<String>(json['localDateKey']),
      note: serializer.fromJson<String?>(json['note']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(
        $TransactionsTable.$convertertype.toJson(type),
      ),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'categoryId': serializer.toJson<String>(categoryId),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
      'localDateKey': serializer.toJson<String>(localDateKey),
      'note': serializer.toJson<String?>(note),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Transaction copyWith({
    String? id,
    TxType? type,
    int? amountMinor,
    String? categoryId,
    String? currencyCode,
    DateTime? createdAtUtc,
    String? localDateKey,
    Value<String?> note = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Transaction(
    id: id ?? this.id,
    type: type ?? this.type,
    amountMinor: amountMinor ?? this.amountMinor,
    categoryId: categoryId ?? this.categoryId,
    currencyCode: currencyCode ?? this.currencyCode,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    localDateKey: localDateKey ?? this.localDateKey,
    note: note.present ? note.value : this.note,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      localDateKey: data.localDateKey.present
          ? data.localDateKey.value
          : this.localDateKey,
      note: data.note.present ? data.note.value : this.note,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('categoryId: $categoryId, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('localDateKey: $localDateKey, ')
          ..write('note: $note, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    amountMinor,
    categoryId,
    currencyCode,
    createdAtUtc,
    localDateKey,
    note,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.type == this.type &&
          other.amountMinor == this.amountMinor &&
          other.categoryId == this.categoryId &&
          other.currencyCode == this.currencyCode &&
          other.createdAtUtc == this.createdAtUtc &&
          other.localDateKey == this.localDateKey &&
          other.note == this.note &&
          other.deletedAt == this.deletedAt);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<String> id;
  final Value<TxType> type;
  final Value<int> amountMinor;
  final Value<String> categoryId;
  final Value<String> currencyCode;
  final Value<DateTime> createdAtUtc;
  final Value<String> localDateKey;
  final Value<String?> note;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.localDateKey = const Value.absent(),
    this.note = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required TxType type,
    required int amountMinor,
    required String categoryId,
    required String currencyCode,
    required DateTime createdAtUtc,
    required String localDateKey,
    this.note = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       amountMinor = Value(amountMinor),
       categoryId = Value(categoryId),
       currencyCode = Value(currencyCode),
       createdAtUtc = Value(createdAtUtc),
       localDateKey = Value(localDateKey);
  static Insertable<Transaction> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<int>? amountMinor,
    Expression<String>? categoryId,
    Expression<String>? currencyCode,
    Expression<DateTime>? createdAtUtc,
    Expression<String>? localDateKey,
    Expression<String>? note,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (categoryId != null) 'category_id': categoryId,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (localDateKey != null) 'local_date_key': localDateKey,
      if (note != null) 'note': note,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith({
    Value<String>? id,
    Value<TxType>? type,
    Value<int>? amountMinor,
    Value<String>? categoryId,
    Value<String>? currencyCode,
    Value<DateTime>? createdAtUtc,
    Value<String>? localDateKey,
    Value<String?>? note,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      amountMinor: amountMinor ?? this.amountMinor,
      categoryId: categoryId ?? this.categoryId,
      currencyCode: currencyCode ?? this.currencyCode,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      localDateKey: localDateKey ?? this.localDateKey,
      note: note ?? this.note,
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
    if (type.present) {
      map['type'] = Variable<String>(
        $TransactionsTable.$convertertype.toSql(type.value),
      );
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    if (localDateKey.present) {
      map['local_date_key'] = Variable<String>(localDateKey.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
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
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('categoryId: $categoryId, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('localDateKey: $localDateKey, ')
          ..write('note: $note, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localeOverrideMeta = const VerificationMeta(
    'localeOverride',
  );
  @override
  late final GeneratedColumn<String> localeOverride = GeneratedColumn<String>(
    'locale_override',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _onboardingDoneMeta = const VerificationMeta(
    'onboardingDone',
  );
  @override
  late final GeneratedColumn<bool> onboardingDone = GeneratedColumn<bool>(
    'onboarding_done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarding_done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _firstLaunchAtMeta = const VerificationMeta(
    'firstLaunchAt',
  );
  @override
  late final GeneratedColumn<DateTime> firstLaunchAt =
      GeneratedColumn<DateTime>(
        'first_launch_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _lastBackupAtMeta = const VerificationMeta(
    'lastBackupAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastBackupAt = GeneratedColumn<DateTime>(
    'last_backup_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _backupBannerDismissedMeta =
      const VerificationMeta('backupBannerDismissed');
  @override
  late final GeneratedColumn<bool> backupBannerDismissed =
      GeneratedColumn<bool>(
        'backup_banner_dismissed',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("backup_banner_dismissed" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _hapticsEnabledMeta = const VerificationMeta(
    'hapticsEnabled',
  );
  @override
  late final GeneratedColumn<bool> hapticsEnabled = GeneratedColumn<bool>(
    'haptics_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("haptics_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _hintsShownMeta = const VerificationMeta(
    'hintsShown',
  );
  @override
  late final GeneratedColumn<int> hintsShown = GeneratedColumn<int>(
    'hints_shown',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    currencyCode,
    localeOverride,
    onboardingDone,
    firstLaunchAt,
    lastBackupAt,
    backupBannerDismissed,
    hapticsEnabled,
    hintsShown,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('locale_override')) {
      context.handle(
        _localeOverrideMeta,
        localeOverride.isAcceptableOrUnknown(
          data['locale_override']!,
          _localeOverrideMeta,
        ),
      );
    }
    if (data.containsKey('onboarding_done')) {
      context.handle(
        _onboardingDoneMeta,
        onboardingDone.isAcceptableOrUnknown(
          data['onboarding_done']!,
          _onboardingDoneMeta,
        ),
      );
    }
    if (data.containsKey('first_launch_at')) {
      context.handle(
        _firstLaunchAtMeta,
        firstLaunchAt.isAcceptableOrUnknown(
          data['first_launch_at']!,
          _firstLaunchAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstLaunchAtMeta);
    }
    if (data.containsKey('last_backup_at')) {
      context.handle(
        _lastBackupAtMeta,
        lastBackupAt.isAcceptableOrUnknown(
          data['last_backup_at']!,
          _lastBackupAtMeta,
        ),
      );
    }
    if (data.containsKey('backup_banner_dismissed')) {
      context.handle(
        _backupBannerDismissedMeta,
        backupBannerDismissed.isAcceptableOrUnknown(
          data['backup_banner_dismissed']!,
          _backupBannerDismissedMeta,
        ),
      );
    }
    if (data.containsKey('haptics_enabled')) {
      context.handle(
        _hapticsEnabledMeta,
        hapticsEnabled.isAcceptableOrUnknown(
          data['haptics_enabled']!,
          _hapticsEnabledMeta,
        ),
      );
    }
    if (data.containsKey('hints_shown')) {
      context.handle(
        _hintsShownMeta,
        hintsShown.isAcceptableOrUnknown(data['hints_shown']!, _hintsShownMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      localeOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale_override'],
      ),
      onboardingDone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarding_done'],
      )!,
      firstLaunchAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_launch_at'],
      )!,
      lastBackupAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_backup_at'],
      ),
      backupBannerDismissed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}backup_banner_dismissed'],
      )!,
      hapticsEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}haptics_enabled'],
      )!,
      hintsShown: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hints_shown'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final int id;

  /// Валюта всього застосунку (рішення 57) — і показу, і всіх записів.
  final String currencyCode;

  /// null = брати системну.
  final String? localeOverride;
  final bool onboardingDone;

  /// Ставиться один раз при першому запуску; від неї рахуються
  /// 72 години тріалу (тех. спека п.13).
  final DateTime firstLaunchAt;

  /// Коли востаннє робили JSON-бекап — для банера-нагадування
  /// (Функціонал п.7.3). null — жодного разу.
  final DateTime? lastBackupAt;

  /// Банер нагадування закривається назавжди одним тапом.
  final bool backupBannerDismissed;

  /// Перемикач «Хаптика» — вимикає обидва місця вібрації (п.2.6).
  final bool hapticsEnabled;

  /// Бітова маска показаних підказок (рішення 89).
  ///
  /// Одна колонка на всі підказки, а не колонка на кожну: їх максимум
  /// три за все життя застосунку, і кожна нова інакше означала б ще
  /// одну міграцію схеми на встановленій базі.
  final int hintsShown;
  const AppSetting({
    required this.id,
    required this.currencyCode,
    this.localeOverride,
    required this.onboardingDone,
    required this.firstLaunchAt,
    this.lastBackupAt,
    required this.backupBannerDismissed,
    required this.hapticsEnabled,
    required this.hintsShown,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['currency_code'] = Variable<String>(currencyCode);
    if (!nullToAbsent || localeOverride != null) {
      map['locale_override'] = Variable<String>(localeOverride);
    }
    map['onboarding_done'] = Variable<bool>(onboardingDone);
    map['first_launch_at'] = Variable<DateTime>(firstLaunchAt);
    if (!nullToAbsent || lastBackupAt != null) {
      map['last_backup_at'] = Variable<DateTime>(lastBackupAt);
    }
    map['backup_banner_dismissed'] = Variable<bool>(backupBannerDismissed);
    map['haptics_enabled'] = Variable<bool>(hapticsEnabled);
    map['hints_shown'] = Variable<int>(hintsShown);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      currencyCode: Value(currencyCode),
      localeOverride: localeOverride == null && nullToAbsent
          ? const Value.absent()
          : Value(localeOverride),
      onboardingDone: Value(onboardingDone),
      firstLaunchAt: Value(firstLaunchAt),
      lastBackupAt: lastBackupAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastBackupAt),
      backupBannerDismissed: Value(backupBannerDismissed),
      hapticsEnabled: Value(hapticsEnabled),
      hintsShown: Value(hintsShown),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      id: serializer.fromJson<int>(json['id']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      localeOverride: serializer.fromJson<String?>(json['localeOverride']),
      onboardingDone: serializer.fromJson<bool>(json['onboardingDone']),
      firstLaunchAt: serializer.fromJson<DateTime>(json['firstLaunchAt']),
      lastBackupAt: serializer.fromJson<DateTime?>(json['lastBackupAt']),
      backupBannerDismissed: serializer.fromJson<bool>(
        json['backupBannerDismissed'],
      ),
      hapticsEnabled: serializer.fromJson<bool>(json['hapticsEnabled']),
      hintsShown: serializer.fromJson<int>(json['hintsShown']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'localeOverride': serializer.toJson<String?>(localeOverride),
      'onboardingDone': serializer.toJson<bool>(onboardingDone),
      'firstLaunchAt': serializer.toJson<DateTime>(firstLaunchAt),
      'lastBackupAt': serializer.toJson<DateTime?>(lastBackupAt),
      'backupBannerDismissed': serializer.toJson<bool>(backupBannerDismissed),
      'hapticsEnabled': serializer.toJson<bool>(hapticsEnabled),
      'hintsShown': serializer.toJson<int>(hintsShown),
    };
  }

  AppSetting copyWith({
    int? id,
    String? currencyCode,
    Value<String?> localeOverride = const Value.absent(),
    bool? onboardingDone,
    DateTime? firstLaunchAt,
    Value<DateTime?> lastBackupAt = const Value.absent(),
    bool? backupBannerDismissed,
    bool? hapticsEnabled,
    int? hintsShown,
  }) => AppSetting(
    id: id ?? this.id,
    currencyCode: currencyCode ?? this.currencyCode,
    localeOverride: localeOverride.present
        ? localeOverride.value
        : this.localeOverride,
    onboardingDone: onboardingDone ?? this.onboardingDone,
    firstLaunchAt: firstLaunchAt ?? this.firstLaunchAt,
    lastBackupAt: lastBackupAt.present ? lastBackupAt.value : this.lastBackupAt,
    backupBannerDismissed: backupBannerDismissed ?? this.backupBannerDismissed,
    hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    hintsShown: hintsShown ?? this.hintsShown,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      id: data.id.present ? data.id.value : this.id,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      localeOverride: data.localeOverride.present
          ? data.localeOverride.value
          : this.localeOverride,
      onboardingDone: data.onboardingDone.present
          ? data.onboardingDone.value
          : this.onboardingDone,
      firstLaunchAt: data.firstLaunchAt.present
          ? data.firstLaunchAt.value
          : this.firstLaunchAt,
      lastBackupAt: data.lastBackupAt.present
          ? data.lastBackupAt.value
          : this.lastBackupAt,
      backupBannerDismissed: data.backupBannerDismissed.present
          ? data.backupBannerDismissed.value
          : this.backupBannerDismissed,
      hapticsEnabled: data.hapticsEnabled.present
          ? data.hapticsEnabled.value
          : this.hapticsEnabled,
      hintsShown: data.hintsShown.present
          ? data.hintsShown.value
          : this.hintsShown,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('id: $id, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('localeOverride: $localeOverride, ')
          ..write('onboardingDone: $onboardingDone, ')
          ..write('firstLaunchAt: $firstLaunchAt, ')
          ..write('lastBackupAt: $lastBackupAt, ')
          ..write('backupBannerDismissed: $backupBannerDismissed, ')
          ..write('hapticsEnabled: $hapticsEnabled, ')
          ..write('hintsShown: $hintsShown')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    currencyCode,
    localeOverride,
    onboardingDone,
    firstLaunchAt,
    lastBackupAt,
    backupBannerDismissed,
    hapticsEnabled,
    hintsShown,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.id == this.id &&
          other.currencyCode == this.currencyCode &&
          other.localeOverride == this.localeOverride &&
          other.onboardingDone == this.onboardingDone &&
          other.firstLaunchAt == this.firstLaunchAt &&
          other.lastBackupAt == this.lastBackupAt &&
          other.backupBannerDismissed == this.backupBannerDismissed &&
          other.hapticsEnabled == this.hapticsEnabled &&
          other.hintsShown == this.hintsShown);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<int> id;
  final Value<String> currencyCode;
  final Value<String?> localeOverride;
  final Value<bool> onboardingDone;
  final Value<DateTime> firstLaunchAt;
  final Value<DateTime?> lastBackupAt;
  final Value<bool> backupBannerDismissed;
  final Value<bool> hapticsEnabled;
  final Value<int> hintsShown;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.localeOverride = const Value.absent(),
    this.onboardingDone = const Value.absent(),
    this.firstLaunchAt = const Value.absent(),
    this.lastBackupAt = const Value.absent(),
    this.backupBannerDismissed = const Value.absent(),
    this.hapticsEnabled = const Value.absent(),
    this.hintsShown = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    required String currencyCode,
    this.localeOverride = const Value.absent(),
    this.onboardingDone = const Value.absent(),
    required DateTime firstLaunchAt,
    this.lastBackupAt = const Value.absent(),
    this.backupBannerDismissed = const Value.absent(),
    this.hapticsEnabled = const Value.absent(),
    this.hintsShown = const Value.absent(),
  }) : currencyCode = Value(currencyCode),
       firstLaunchAt = Value(firstLaunchAt);
  static Insertable<AppSetting> custom({
    Expression<int>? id,
    Expression<String>? currencyCode,
    Expression<String>? localeOverride,
    Expression<bool>? onboardingDone,
    Expression<DateTime>? firstLaunchAt,
    Expression<DateTime>? lastBackupAt,
    Expression<bool>? backupBannerDismissed,
    Expression<bool>? hapticsEnabled,
    Expression<int>? hintsShown,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (localeOverride != null) 'locale_override': localeOverride,
      if (onboardingDone != null) 'onboarding_done': onboardingDone,
      if (firstLaunchAt != null) 'first_launch_at': firstLaunchAt,
      if (lastBackupAt != null) 'last_backup_at': lastBackupAt,
      if (backupBannerDismissed != null)
        'backup_banner_dismissed': backupBannerDismissed,
      if (hapticsEnabled != null) 'haptics_enabled': hapticsEnabled,
      if (hintsShown != null) 'hints_shown': hintsShown,
    });
  }

  AppSettingsCompanion copyWith({
    Value<int>? id,
    Value<String>? currencyCode,
    Value<String?>? localeOverride,
    Value<bool>? onboardingDone,
    Value<DateTime>? firstLaunchAt,
    Value<DateTime?>? lastBackupAt,
    Value<bool>? backupBannerDismissed,
    Value<bool>? hapticsEnabled,
    Value<int>? hintsShown,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      currencyCode: currencyCode ?? this.currencyCode,
      localeOverride: localeOverride ?? this.localeOverride,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      firstLaunchAt: firstLaunchAt ?? this.firstLaunchAt,
      lastBackupAt: lastBackupAt ?? this.lastBackupAt,
      backupBannerDismissed:
          backupBannerDismissed ?? this.backupBannerDismissed,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      hintsShown: hintsShown ?? this.hintsShown,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (localeOverride.present) {
      map['locale_override'] = Variable<String>(localeOverride.value);
    }
    if (onboardingDone.present) {
      map['onboarding_done'] = Variable<bool>(onboardingDone.value);
    }
    if (firstLaunchAt.present) {
      map['first_launch_at'] = Variable<DateTime>(firstLaunchAt.value);
    }
    if (lastBackupAt.present) {
      map['last_backup_at'] = Variable<DateTime>(lastBackupAt.value);
    }
    if (backupBannerDismissed.present) {
      map['backup_banner_dismissed'] = Variable<bool>(
        backupBannerDismissed.value,
      );
    }
    if (hapticsEnabled.present) {
      map['haptics_enabled'] = Variable<bool>(hapticsEnabled.value);
    }
    if (hintsShown.present) {
      map['hints_shown'] = Variable<int>(hintsShown.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('localeOverride: $localeOverride, ')
          ..write('onboardingDone: $onboardingDone, ')
          ..write('firstLaunchAt: $firstLaunchAt, ')
          ..write('lastBackupAt: $lastBackupAt, ')
          ..write('backupBannerDismissed: $backupBannerDismissed, ')
          ..write('hapticsEnabled: $hapticsEnabled, ')
          ..write('hintsShown: $hintsShown')
          ..write(')'))
        .toString();
  }
}

class $CategoryRankingCacheTable extends CategoryRankingCache
    with TableInfo<$CategoryRankingCacheTable, CategoryRankingCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryRankingCacheTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<TxType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TxType>($CategoryRankingCacheTable.$convertertype);
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rankMeta = const VerificationMeta('rank');
  @override
  late final GeneratedColumn<int> rank = GeneratedColumn<int>(
    'rank',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _computedOnMeta = const VerificationMeta(
    'computedOn',
  );
  @override
  late final GeneratedColumn<String> computedOn = GeneratedColumn<String>(
    'computed_on',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    type,
    position,
    categoryId,
    rank,
    computedOn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category_ranking_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRankingCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('rank')) {
      context.handle(
        _rankMeta,
        rank.isAcceptableOrUnknown(data['rank']!, _rankMeta),
      );
    } else if (isInserting) {
      context.missing(_rankMeta);
    }
    if (data.containsKey('computed_on')) {
      context.handle(
        _computedOnMeta,
        computedOn.isAcceptableOrUnknown(data['computed_on']!, _computedOnMeta),
      );
    } else if (isInserting) {
      context.missing(_computedOnMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {type, position};
  @override
  CategoryRankingCacheData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRankingCacheData(
      type: $CategoryRankingCacheTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      rank: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rank'],
      )!,
      computedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}computed_on'],
      )!,
    );
  }

  @override
  $CategoryRankingCacheTable createAlias(String alias) {
    return $CategoryRankingCacheTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TxType, String, String> $convertertype =
      const EnumNameConverter<TxType>(TxType.values);
}

class CategoryRankingCacheData extends DataClass
    implements Insertable<CategoryRankingCacheData> {
  final TxType type;

  /// Позиція слота 0..4.
  final int position;
  final String categoryId;

  /// Ранг на момент обчислення — потрібен гістерезису при перерахунку.
  final int rank;

  /// localDateKey дня, для якого обчислено.
  final String computedOn;
  const CategoryRankingCacheData({
    required this.type,
    required this.position,
    required this.categoryId,
    required this.rank,
    required this.computedOn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['type'] = Variable<String>(
        $CategoryRankingCacheTable.$convertertype.toSql(type),
      );
    }
    map['position'] = Variable<int>(position);
    map['category_id'] = Variable<String>(categoryId);
    map['rank'] = Variable<int>(rank);
    map['computed_on'] = Variable<String>(computedOn);
    return map;
  }

  CategoryRankingCacheCompanion toCompanion(bool nullToAbsent) {
    return CategoryRankingCacheCompanion(
      type: Value(type),
      position: Value(position),
      categoryId: Value(categoryId),
      rank: Value(rank),
      computedOn: Value(computedOn),
    );
  }

  factory CategoryRankingCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRankingCacheData(
      type: $CategoryRankingCacheTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      position: serializer.fromJson<int>(json['position']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      rank: serializer.fromJson<int>(json['rank']),
      computedOn: serializer.fromJson<String>(json['computedOn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'type': serializer.toJson<String>(
        $CategoryRankingCacheTable.$convertertype.toJson(type),
      ),
      'position': serializer.toJson<int>(position),
      'categoryId': serializer.toJson<String>(categoryId),
      'rank': serializer.toJson<int>(rank),
      'computedOn': serializer.toJson<String>(computedOn),
    };
  }

  CategoryRankingCacheData copyWith({
    TxType? type,
    int? position,
    String? categoryId,
    int? rank,
    String? computedOn,
  }) => CategoryRankingCacheData(
    type: type ?? this.type,
    position: position ?? this.position,
    categoryId: categoryId ?? this.categoryId,
    rank: rank ?? this.rank,
    computedOn: computedOn ?? this.computedOn,
  );
  CategoryRankingCacheData copyWithCompanion(
    CategoryRankingCacheCompanion data,
  ) {
    return CategoryRankingCacheData(
      type: data.type.present ? data.type.value : this.type,
      position: data.position.present ? data.position.value : this.position,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      rank: data.rank.present ? data.rank.value : this.rank,
      computedOn: data.computedOn.present
          ? data.computedOn.value
          : this.computedOn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRankingCacheData(')
          ..write('type: $type, ')
          ..write('position: $position, ')
          ..write('categoryId: $categoryId, ')
          ..write('rank: $rank, ')
          ..write('computedOn: $computedOn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(type, position, categoryId, rank, computedOn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRankingCacheData &&
          other.type == this.type &&
          other.position == this.position &&
          other.categoryId == this.categoryId &&
          other.rank == this.rank &&
          other.computedOn == this.computedOn);
}

class CategoryRankingCacheCompanion
    extends UpdateCompanion<CategoryRankingCacheData> {
  final Value<TxType> type;
  final Value<int> position;
  final Value<String> categoryId;
  final Value<int> rank;
  final Value<String> computedOn;
  final Value<int> rowid;
  const CategoryRankingCacheCompanion({
    this.type = const Value.absent(),
    this.position = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.rank = const Value.absent(),
    this.computedOn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoryRankingCacheCompanion.insert({
    required TxType type,
    required int position,
    required String categoryId,
    required int rank,
    required String computedOn,
    this.rowid = const Value.absent(),
  }) : type = Value(type),
       position = Value(position),
       categoryId = Value(categoryId),
       rank = Value(rank),
       computedOn = Value(computedOn);
  static Insertable<CategoryRankingCacheData> custom({
    Expression<String>? type,
    Expression<int>? position,
    Expression<String>? categoryId,
    Expression<int>? rank,
    Expression<String>? computedOn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (type != null) 'type': type,
      if (position != null) 'position': position,
      if (categoryId != null) 'category_id': categoryId,
      if (rank != null) 'rank': rank,
      if (computedOn != null) 'computed_on': computedOn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoryRankingCacheCompanion copyWith({
    Value<TxType>? type,
    Value<int>? position,
    Value<String>? categoryId,
    Value<int>? rank,
    Value<String>? computedOn,
    Value<int>? rowid,
  }) {
    return CategoryRankingCacheCompanion(
      type: type ?? this.type,
      position: position ?? this.position,
      categoryId: categoryId ?? this.categoryId,
      rank: rank ?? this.rank,
      computedOn: computedOn ?? this.computedOn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (type.present) {
      map['type'] = Variable<String>(
        $CategoryRankingCacheTable.$convertertype.toSql(type.value),
      );
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (rank.present) {
      map['rank'] = Variable<int>(rank.value);
    }
    if (computedOn.present) {
      map['computed_on'] = Variable<String>(computedOn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRankingCacheCompanion(')
          ..write('type: $type, ')
          ..write('position: $position, ')
          ..write('categoryId: $categoryId, ')
          ..write('rank: $rank, ')
          ..write('computedOn: $computedOn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $CategoryRankingCacheTable categoryRankingCache =
      $CategoryRankingCacheTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    transactions,
    appSettings,
    categoryRankingCache,
  ];
}

typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  required String id,
  required TxType type,
  Value<String?> nameKey,
  Value<String?> customName,
  required String emoji,
  Value<bool> isBuiltIn,
  Value<bool> isPinned,
  Value<bool> isArchived,
  Value<int> sortOrder,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<String> id,
  Value<TxType> type,
  Value<String?> nameKey,
  Value<String?> customName,
  Value<String> emoji,
  Value<bool> isBuiltIn,
  Value<bool> isPinned,
  Value<bool> isArchived,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: 'categories__id__transactions__category_id',
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TxType, TxType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get nameKey => $composableBuilder(
    column: $table.nameKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameKey => $composableBuilder(
    column: $table.nameKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TxType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get nameKey =>
      $composableBuilder(column: $table.nameKey, builder: (column) => column);

  GeneratedColumn<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<bool> get isBuiltIn =>
      $composableBuilder(column: $table.isBuiltIn, builder: (column) => column);

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, $$CategoriesTableReferences),
          Category,
          PrefetchHooks Function({bool transactionsRefs})
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<TxType> type = const Value.absent(),
                Value<String?> nameKey = const Value.absent(),
                Value<String?> customName = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<bool> isBuiltIn = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                type: type,
                nameKey: nameKey,
                customName: customName,
                emoji: emoji,
                isBuiltIn: isBuiltIn,
                isPinned: isPinned,
                isArchived: isArchived,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required TxType type,
                Value<String?> nameKey = const Value.absent(),
                Value<String?> customName = const Value.absent(),
                required String emoji,
                Value<bool> isBuiltIn = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                type: type,
                nameKey: nameKey,
                customName: customName,
                emoji: emoji,
                isBuiltIn: isBuiltIn,
                isPinned: isPinned,
                isArchived: isArchived,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({transactionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (transactionsRefs) db.transactions],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transactionsRefs)
                    await $_getPrefetchedData<
                      Category,
                      $CategoriesTable,
                      Transaction
                    >(
                      currentTable: table,
                      referencedTable: $$CategoriesTableReferences
                          ._transactionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).transactionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, $$CategoriesTableReferences),
      Category,
      PrefetchHooks Function({bool transactionsRefs})
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      required String id,
      required TxType type,
      required int amountMinor,
      required String categoryId,
      required String currencyCode,
      required DateTime createdAtUtc,
      required String localDateKey,
      Value<String?> note,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<String> id,
      Value<TxType> type,
      Value<int> amountMinor,
      Value<String> categoryId,
      Value<String> currencyCode,
      Value<DateTime> createdAtUtc,
      Value<String> localDateKey,
      Value<String?> note,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$TransactionsTableReferences
    extends BaseReferences<_$AppDatabase, $TransactionsTable, Transaction> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('transactions__category_id__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TxType, TxType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDateKey => $composableBuilder(
    column: $table.localDateKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDateKey => $composableBuilder(
    column: $table.localDateKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TxType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localDateKey => $composableBuilder(
    column: $table.localDateKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          Transaction,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (Transaction, $$TransactionsTableReferences),
          Transaction,
          PrefetchHooks Function({bool categoryId})
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<TxType> type = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
                Value<String> localDateKey = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                type: type,
                amountMinor: amountMinor,
                categoryId: categoryId,
                currencyCode: currencyCode,
                createdAtUtc: createdAtUtc,
                localDateKey: localDateKey,
                note: note,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required TxType type,
                required int amountMinor,
                required String categoryId,
                required String currencyCode,
                required DateTime createdAtUtc,
                required String localDateKey,
                Value<String?> note = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                type: type,
                amountMinor: amountMinor,
                categoryId: categoryId,
                currencyCode: currencyCode,
                createdAtUtc: createdAtUtc,
                localDateKey: localDateKey,
                note: note,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (categoryId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.categoryId,
                        referencedTable: $$TransactionsTableReferences
                            ._categoryIdTable(db),
                        referencedColumn: $$TransactionsTableReferences
                            ._categoryIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      Transaction,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (Transaction, $$TransactionsTableReferences),
      Transaction,
      PrefetchHooks Function({bool categoryId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      required String currencyCode,
      Value<String?> localeOverride,
      Value<bool> onboardingDone,
      required DateTime firstLaunchAt,
      Value<DateTime?> lastBackupAt,
      Value<bool> backupBannerDismissed,
      Value<bool> hapticsEnabled,
      Value<int> hintsShown,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<String> currencyCode,
      Value<String?> localeOverride,
      Value<bool> onboardingDone,
      Value<DateTime> firstLaunchAt,
      Value<DateTime?> lastBackupAt,
      Value<bool> backupBannerDismissed,
      Value<bool> hapticsEnabled,
      Value<int> hintsShown,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
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

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localeOverride => $composableBuilder(
    column: $table.localeOverride,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get onboardingDone => $composableBuilder(
    column: $table.onboardingDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstLaunchAt => $composableBuilder(
    column: $table.firstLaunchAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastBackupAt => $composableBuilder(
    column: $table.lastBackupAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get backupBannerDismissed => $composableBuilder(
    column: $table.backupBannerDismissed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hapticsEnabled => $composableBuilder(
    column: $table.hapticsEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hintsShown => $composableBuilder(
    column: $table.hintsShown,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
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

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localeOverride => $composableBuilder(
    column: $table.localeOverride,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onboardingDone => $composableBuilder(
    column: $table.onboardingDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstLaunchAt => $composableBuilder(
    column: $table.firstLaunchAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastBackupAt => $composableBuilder(
    column: $table.lastBackupAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get backupBannerDismissed => $composableBuilder(
    column: $table.backupBannerDismissed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hapticsEnabled => $composableBuilder(
    column: $table.hapticsEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hintsShown => $composableBuilder(
    column: $table.hintsShown,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localeOverride => $composableBuilder(
    column: $table.localeOverride,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get onboardingDone => $composableBuilder(
    column: $table.onboardingDone,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get firstLaunchAt => $composableBuilder(
    column: $table.firstLaunchAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastBackupAt => $composableBuilder(
    column: $table.lastBackupAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get backupBannerDismissed => $composableBuilder(
    column: $table.backupBannerDismissed,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hapticsEnabled => $composableBuilder(
    column: $table.hapticsEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hintsShown => $composableBuilder(
    column: $table.hintsShown,
    builder: (column) => column,
  );
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String?> localeOverride = const Value.absent(),
                Value<bool> onboardingDone = const Value.absent(),
                Value<DateTime> firstLaunchAt = const Value.absent(),
                Value<DateTime?> lastBackupAt = const Value.absent(),
                Value<bool> backupBannerDismissed = const Value.absent(),
                Value<bool> hapticsEnabled = const Value.absent(),
                Value<int> hintsShown = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                currencyCode: currencyCode,
                localeOverride: localeOverride,
                onboardingDone: onboardingDone,
                firstLaunchAt: firstLaunchAt,
                lastBackupAt: lastBackupAt,
                backupBannerDismissed: backupBannerDismissed,
                hapticsEnabled: hapticsEnabled,
                hintsShown: hintsShown,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String currencyCode,
                Value<String?> localeOverride = const Value.absent(),
                Value<bool> onboardingDone = const Value.absent(),
                required DateTime firstLaunchAt,
                Value<DateTime?> lastBackupAt = const Value.absent(),
                Value<bool> backupBannerDismissed = const Value.absent(),
                Value<bool> hapticsEnabled = const Value.absent(),
                Value<int> hintsShown = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                currencyCode: currencyCode,
                localeOverride: localeOverride,
                onboardingDone: onboardingDone,
                firstLaunchAt: firstLaunchAt,
                lastBackupAt: lastBackupAt,
                backupBannerDismissed: backupBannerDismissed,
                hapticsEnabled: hapticsEnabled,
                hintsShown: hintsShown,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$CategoryRankingCacheTableCreateCompanionBuilder =
    CategoryRankingCacheCompanion Function({
      required TxType type,
      required int position,
      required String categoryId,
      required int rank,
      required String computedOn,
      Value<int> rowid,
    });
typedef $$CategoryRankingCacheTableUpdateCompanionBuilder =
    CategoryRankingCacheCompanion Function({
      Value<TxType> type,
      Value<int> position,
      Value<String> categoryId,
      Value<int> rank,
      Value<String> computedOn,
      Value<int> rowid,
    });

class $$CategoryRankingCacheTableFilterComposer
    extends Composer<_$AppDatabase, $CategoryRankingCacheTable> {
  $$CategoryRankingCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<TxType, TxType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rank => $composableBuilder(
    column: $table.rank,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get computedOn => $composableBuilder(
    column: $table.computedOn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoryRankingCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoryRankingCacheTable> {
  $$CategoryRankingCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rank => $composableBuilder(
    column: $table.rank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get computedOn => $composableBuilder(
    column: $table.computedOn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoryRankingCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoryRankingCacheTable> {
  $$CategoryRankingCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<TxType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rank =>
      $composableBuilder(column: $table.rank, builder: (column) => column);

  GeneratedColumn<String> get computedOn => $composableBuilder(
    column: $table.computedOn,
    builder: (column) => column,
  );
}

class $$CategoryRankingCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoryRankingCacheTable,
          CategoryRankingCacheData,
          $$CategoryRankingCacheTableFilterComposer,
          $$CategoryRankingCacheTableOrderingComposer,
          $$CategoryRankingCacheTableAnnotationComposer,
          $$CategoryRankingCacheTableCreateCompanionBuilder,
          $$CategoryRankingCacheTableUpdateCompanionBuilder,
          (
            CategoryRankingCacheData,
            BaseReferences<
              _$AppDatabase,
              $CategoryRankingCacheTable,
              CategoryRankingCacheData
            >,
          ),
          CategoryRankingCacheData,
          PrefetchHooks Function()
        > {
  $$CategoryRankingCacheTableTableManager(
    _$AppDatabase db,
    $CategoryRankingCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryRankingCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoryRankingCacheTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CategoryRankingCacheTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<TxType> type = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<int> rank = const Value.absent(),
                Value<String> computedOn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoryRankingCacheCompanion(
                type: type,
                position: position,
                categoryId: categoryId,
                rank: rank,
                computedOn: computedOn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required TxType type,
                required int position,
                required String categoryId,
                required int rank,
                required String computedOn,
                Value<int> rowid = const Value.absent(),
              }) => CategoryRankingCacheCompanion.insert(
                type: type,
                position: position,
                categoryId: categoryId,
                rank: rank,
                computedOn: computedOn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoryRankingCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoryRankingCacheTable,
      CategoryRankingCacheData,
      $$CategoryRankingCacheTableFilterComposer,
      $$CategoryRankingCacheTableOrderingComposer,
      $$CategoryRankingCacheTableAnnotationComposer,
      $$CategoryRankingCacheTableCreateCompanionBuilder,
      $$CategoryRankingCacheTableUpdateCompanionBuilder,
      (
        CategoryRankingCacheData,
        BaseReferences<
          _$AppDatabase,
          $CategoryRankingCacheTable,
          CategoryRankingCacheData
        >,
      ),
      CategoryRankingCacheData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$CategoryRankingCacheTableTableManager get categoryRankingCache =>
      $$CategoryRankingCacheTableTableManager(_db, _db.categoryRankingCache);
}
