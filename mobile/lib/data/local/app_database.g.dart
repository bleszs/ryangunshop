// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, UserRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeIdMeta = const VerificationMeta(
    'storeId',
  );
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
    'store_id',
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
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _passwordHashMeta = const VerificationMeta(
    'passwordHash',
  );
  @override
  late final GeneratedColumn<String> passwordHash = GeneratedColumn<String>(
    'password_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    storeId,
    name,
    email,
    passwordHash,
    role,
    active,
    updatedAt,
    syncState,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(
        _storeIdMeta,
        storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storeIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('password_hash')) {
      context.handle(
        _passwordHashMeta,
        passwordHash.isAcceptableOrUnknown(
          data['password_hash']!,
          _passwordHashMeta,
        ),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {storeId, email},
  ];
  @override
  UserRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      storeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      passwordHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password_hash'],
      ),
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class UserRow extends DataClass implements Insertable<UserRow> {
  final String id;
  final String storeId;
  final String name;
  final String email;
  final String? passwordHash;
  final String role;
  final bool active;
  final DateTime updatedAt;
  final String syncState;
  const UserRow({
    required this.id,
    required this.storeId,
    required this.name,
    required this.email,
    this.passwordHash,
    required this.role,
    required this.active,
    required this.updatedAt,
    required this.syncState,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['store_id'] = Variable<String>(storeId);
    map['name'] = Variable<String>(name);
    map['email'] = Variable<String>(email);
    if (!nullToAbsent || passwordHash != null) {
      map['password_hash'] = Variable<String>(passwordHash);
    }
    map['role'] = Variable<String>(role);
    map['active'] = Variable<bool>(active);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      storeId: Value(storeId),
      name: Value(name),
      email: Value(email),
      passwordHash: passwordHash == null && nullToAbsent
          ? const Value.absent()
          : Value(passwordHash),
      role: Value(role),
      active: Value(active),
      updatedAt: Value(updatedAt),
      syncState: Value(syncState),
    );
  }

  factory UserRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserRow(
      id: serializer.fromJson<String>(json['id']),
      storeId: serializer.fromJson<String>(json['storeId']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String>(json['email']),
      passwordHash: serializer.fromJson<String?>(json['passwordHash']),
      role: serializer.fromJson<String>(json['role']),
      active: serializer.fromJson<bool>(json['active']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'storeId': serializer.toJson<String>(storeId),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String>(email),
      'passwordHash': serializer.toJson<String?>(passwordHash),
      'role': serializer.toJson<String>(role),
      'active': serializer.toJson<bool>(active),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  UserRow copyWith({
    String? id,
    String? storeId,
    String? name,
    String? email,
    Value<String?> passwordHash = const Value.absent(),
    String? role,
    bool? active,
    DateTime? updatedAt,
    String? syncState,
  }) => UserRow(
    id: id ?? this.id,
    storeId: storeId ?? this.storeId,
    name: name ?? this.name,
    email: email ?? this.email,
    passwordHash: passwordHash.present ? passwordHash.value : this.passwordHash,
    role: role ?? this.role,
    active: active ?? this.active,
    updatedAt: updatedAt ?? this.updatedAt,
    syncState: syncState ?? this.syncState,
  );
  UserRow copyWithCompanion(UsersCompanion data) {
    return UserRow(
      id: data.id.present ? data.id.value : this.id,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
      role: data.role.present ? data.role.value : this.role,
      active: data.active.present ? data.active.value : this.active,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserRow(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('role: $role, ')
          ..write('active: $active, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    storeId,
    name,
    email,
    passwordHash,
    role,
    active,
    updatedAt,
    syncState,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserRow &&
          other.id == this.id &&
          other.storeId == this.storeId &&
          other.name == this.name &&
          other.email == this.email &&
          other.passwordHash == this.passwordHash &&
          other.role == this.role &&
          other.active == this.active &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState);
}

class UsersCompanion extends UpdateCompanion<UserRow> {
  final Value<String> id;
  final Value<String> storeId;
  final Value<String> name;
  final Value<String> email;
  final Value<String?> passwordHash;
  final Value<String> role;
  final Value<bool> active;
  final Value<DateTime> updatedAt;
  final Value<String> syncState;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.storeId = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.role = const Value.absent(),
    this.active = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String storeId,
    required String name,
    required String email,
    this.passwordHash = const Value.absent(),
    required String role,
    this.active = const Value.absent(),
    required DateTime updatedAt,
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       storeId = Value(storeId),
       name = Value(name),
       email = Value(email),
       role = Value(role),
       updatedAt = Value(updatedAt);
  static Insertable<UserRow> custom({
    Expression<String>? id,
    Expression<String>? storeId,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? passwordHash,
    Expression<String>? role,
    Expression<bool>? active,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storeId != null) 'store_id': storeId,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (role != null) 'role': role,
      if (active != null) 'active': active,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<String>? storeId,
    Value<String>? name,
    Value<String>? email,
    Value<String?>? passwordHash,
    Value<String>? role,
    Value<bool>? active,
    Value<DateTime>? updatedAt,
    Value<String>? syncState,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      role: role ?? this.role,
      active: active ?? this.active,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<String>(passwordHash.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('role: $role, ')
          ..write('active: $active, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductsTable extends Products
    with TableInfo<$ProductsTable, ProductRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeIdMeta = const VerificationMeta(
    'storeId',
  );
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
    'store_id',
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
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purchasePriceMeta = const VerificationMeta(
    'purchasePrice',
  );
  @override
  late final GeneratedColumn<int> purchasePrice = GeneratedColumn<int>(
    'purchase_price',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sellingPriceMeta = const VerificationMeta(
    'sellingPrice',
  );
  @override
  late final GeneratedColumn<int> sellingPrice = GeneratedColumn<int>(
    'selling_price',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stockMeta = const VerificationMeta('stock');
  @override
  late final GeneratedColumn<int> stock = GeneratedColumn<int>(
    'stock',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minimumStockMeta = const VerificationMeta(
    'minimumStock',
  );
  @override
  late final GeneratedColumn<int> minimumStock = GeneratedColumn<int>(
    'minimum_stock',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _leadTimeDaysMeta = const VerificationMeta(
    'leadTimeDays',
  );
  @override
  late final GeneratedColumn<int> leadTimeDays = GeneratedColumn<int>(
    'lead_time_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoUriMeta = const VerificationMeta(
    'photoUri',
  );
  @override
  late final GeneratedColumn<String> photoUri = GeneratedColumn<String>(
    'photo_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shelfLocationMeta = const VerificationMeta(
    'shelfLocation',
  );
  @override
  late final GeneratedColumn<String> shelfLocation = GeneratedColumn<String>(
    'shelf_location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aiLabelMeta = const VerificationMeta(
    'aiLabel',
  );
  @override
  late final GeneratedColumn<String> aiLabel = GeneratedColumn<String>(
    'ai_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    storeId,
    name,
    normalizedName,
    category,
    purchasePrice,
    sellingPrice,
    stock,
    minimumStock,
    leadTimeDays,
    barcode,
    photoUri,
    shelfLocation,
    aiLabel,
    active,
    updatedAt,
    deletedAt,
    syncState,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(
        _storeIdMeta,
        storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storeIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('purchase_price')) {
      context.handle(
        _purchasePriceMeta,
        purchasePrice.isAcceptableOrUnknown(
          data['purchase_price']!,
          _purchasePriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_purchasePriceMeta);
    }
    if (data.containsKey('selling_price')) {
      context.handle(
        _sellingPriceMeta,
        sellingPrice.isAcceptableOrUnknown(
          data['selling_price']!,
          _sellingPriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sellingPriceMeta);
    }
    if (data.containsKey('stock')) {
      context.handle(
        _stockMeta,
        stock.isAcceptableOrUnknown(data['stock']!, _stockMeta),
      );
    } else if (isInserting) {
      context.missing(_stockMeta);
    }
    if (data.containsKey('minimum_stock')) {
      context.handle(
        _minimumStockMeta,
        minimumStock.isAcceptableOrUnknown(
          data['minimum_stock']!,
          _minimumStockMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_minimumStockMeta);
    }
    if (data.containsKey('lead_time_days')) {
      context.handle(
        _leadTimeDaysMeta,
        leadTimeDays.isAcceptableOrUnknown(
          data['lead_time_days']!,
          _leadTimeDaysMeta,
        ),
      );
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('photo_uri')) {
      context.handle(
        _photoUriMeta,
        photoUri.isAcceptableOrUnknown(data['photo_uri']!, _photoUriMeta),
      );
    }
    if (data.containsKey('shelf_location')) {
      context.handle(
        _shelfLocationMeta,
        shelfLocation.isAcceptableOrUnknown(
          data['shelf_location']!,
          _shelfLocationMeta,
        ),
      );
    }
    if (data.containsKey('ai_label')) {
      context.handle(
        _aiLabelMeta,
        aiLabel.isAcceptableOrUnknown(data['ai_label']!, _aiLabelMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {storeId, barcode},
    {storeId, aiLabel},
  ];
  @override
  ProductRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      storeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      purchasePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}purchase_price'],
      )!,
      sellingPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}selling_price'],
      )!,
      stock: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stock'],
      )!,
      minimumStock: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minimum_stock'],
      )!,
      leadTimeDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lead_time_days'],
      )!,
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      photoUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_uri'],
      ),
      shelfLocation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shelf_location'],
      ),
      aiLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ai_label'],
      ),
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class ProductRow extends DataClass implements Insertable<ProductRow> {
  final String id;
  final String storeId;
  final String name;
  final String normalizedName;
  final String category;
  final int purchasePrice;
  final int sellingPrice;
  final int stock;
  final int minimumStock;
  final int leadTimeDays;
  final String? barcode;
  final String? photoUri;
  final String? shelfLocation;
  final String? aiLabel;
  final bool active;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String syncState;
  const ProductRow({
    required this.id,
    required this.storeId,
    required this.name,
    required this.normalizedName,
    required this.category,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.stock,
    required this.minimumStock,
    required this.leadTimeDays,
    this.barcode,
    this.photoUri,
    this.shelfLocation,
    this.aiLabel,
    required this.active,
    required this.updatedAt,
    this.deletedAt,
    required this.syncState,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['store_id'] = Variable<String>(storeId);
    map['name'] = Variable<String>(name);
    map['normalized_name'] = Variable<String>(normalizedName);
    map['category'] = Variable<String>(category);
    map['purchase_price'] = Variable<int>(purchasePrice);
    map['selling_price'] = Variable<int>(sellingPrice);
    map['stock'] = Variable<int>(stock);
    map['minimum_stock'] = Variable<int>(minimumStock);
    map['lead_time_days'] = Variable<int>(leadTimeDays);
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    if (!nullToAbsent || photoUri != null) {
      map['photo_uri'] = Variable<String>(photoUri);
    }
    if (!nullToAbsent || shelfLocation != null) {
      map['shelf_location'] = Variable<String>(shelfLocation);
    }
    if (!nullToAbsent || aiLabel != null) {
      map['ai_label'] = Variable<String>(aiLabel);
    }
    map['active'] = Variable<bool>(active);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      storeId: Value(storeId),
      name: Value(name),
      normalizedName: Value(normalizedName),
      category: Value(category),
      purchasePrice: Value(purchasePrice),
      sellingPrice: Value(sellingPrice),
      stock: Value(stock),
      minimumStock: Value(minimumStock),
      leadTimeDays: Value(leadTimeDays),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      photoUri: photoUri == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUri),
      shelfLocation: shelfLocation == null && nullToAbsent
          ? const Value.absent()
          : Value(shelfLocation),
      aiLabel: aiLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(aiLabel),
      active: Value(active),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
    );
  }

  factory ProductRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductRow(
      id: serializer.fromJson<String>(json['id']),
      storeId: serializer.fromJson<String>(json['storeId']),
      name: serializer.fromJson<String>(json['name']),
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      category: serializer.fromJson<String>(json['category']),
      purchasePrice: serializer.fromJson<int>(json['purchasePrice']),
      sellingPrice: serializer.fromJson<int>(json['sellingPrice']),
      stock: serializer.fromJson<int>(json['stock']),
      minimumStock: serializer.fromJson<int>(json['minimumStock']),
      leadTimeDays: serializer.fromJson<int>(json['leadTimeDays']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      photoUri: serializer.fromJson<String?>(json['photoUri']),
      shelfLocation: serializer.fromJson<String?>(json['shelfLocation']),
      aiLabel: serializer.fromJson<String?>(json['aiLabel']),
      active: serializer.fromJson<bool>(json['active']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'storeId': serializer.toJson<String>(storeId),
      'name': serializer.toJson<String>(name),
      'normalizedName': serializer.toJson<String>(normalizedName),
      'category': serializer.toJson<String>(category),
      'purchasePrice': serializer.toJson<int>(purchasePrice),
      'sellingPrice': serializer.toJson<int>(sellingPrice),
      'stock': serializer.toJson<int>(stock),
      'minimumStock': serializer.toJson<int>(minimumStock),
      'leadTimeDays': serializer.toJson<int>(leadTimeDays),
      'barcode': serializer.toJson<String?>(barcode),
      'photoUri': serializer.toJson<String?>(photoUri),
      'shelfLocation': serializer.toJson<String?>(shelfLocation),
      'aiLabel': serializer.toJson<String?>(aiLabel),
      'active': serializer.toJson<bool>(active),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  ProductRow copyWith({
    String? id,
    String? storeId,
    String? name,
    String? normalizedName,
    String? category,
    int? purchasePrice,
    int? sellingPrice,
    int? stock,
    int? minimumStock,
    int? leadTimeDays,
    Value<String?> barcode = const Value.absent(),
    Value<String?> photoUri = const Value.absent(),
    Value<String?> shelfLocation = const Value.absent(),
    Value<String?> aiLabel = const Value.absent(),
    bool? active,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? syncState,
  }) => ProductRow(
    id: id ?? this.id,
    storeId: storeId ?? this.storeId,
    name: name ?? this.name,
    normalizedName: normalizedName ?? this.normalizedName,
    category: category ?? this.category,
    purchasePrice: purchasePrice ?? this.purchasePrice,
    sellingPrice: sellingPrice ?? this.sellingPrice,
    stock: stock ?? this.stock,
    minimumStock: minimumStock ?? this.minimumStock,
    leadTimeDays: leadTimeDays ?? this.leadTimeDays,
    barcode: barcode.present ? barcode.value : this.barcode,
    photoUri: photoUri.present ? photoUri.value : this.photoUri,
    shelfLocation: shelfLocation.present
        ? shelfLocation.value
        : this.shelfLocation,
    aiLabel: aiLabel.present ? aiLabel.value : this.aiLabel,
    active: active ?? this.active,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncState: syncState ?? this.syncState,
  );
  ProductRow copyWithCompanion(ProductsCompanion data) {
    return ProductRow(
      id: data.id.present ? data.id.value : this.id,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      name: data.name.present ? data.name.value : this.name,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      category: data.category.present ? data.category.value : this.category,
      purchasePrice: data.purchasePrice.present
          ? data.purchasePrice.value
          : this.purchasePrice,
      sellingPrice: data.sellingPrice.present
          ? data.sellingPrice.value
          : this.sellingPrice,
      stock: data.stock.present ? data.stock.value : this.stock,
      minimumStock: data.minimumStock.present
          ? data.minimumStock.value
          : this.minimumStock,
      leadTimeDays: data.leadTimeDays.present
          ? data.leadTimeDays.value
          : this.leadTimeDays,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      photoUri: data.photoUri.present ? data.photoUri.value : this.photoUri,
      shelfLocation: data.shelfLocation.present
          ? data.shelfLocation.value
          : this.shelfLocation,
      aiLabel: data.aiLabel.present ? data.aiLabel.value : this.aiLabel,
      active: data.active.present ? data.active.value : this.active,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductRow(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('category: $category, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('sellingPrice: $sellingPrice, ')
          ..write('stock: $stock, ')
          ..write('minimumStock: $minimumStock, ')
          ..write('leadTimeDays: $leadTimeDays, ')
          ..write('barcode: $barcode, ')
          ..write('photoUri: $photoUri, ')
          ..write('shelfLocation: $shelfLocation, ')
          ..write('aiLabel: $aiLabel, ')
          ..write('active: $active, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    storeId,
    name,
    normalizedName,
    category,
    purchasePrice,
    sellingPrice,
    stock,
    minimumStock,
    leadTimeDays,
    barcode,
    photoUri,
    shelfLocation,
    aiLabel,
    active,
    updatedAt,
    deletedAt,
    syncState,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductRow &&
          other.id == this.id &&
          other.storeId == this.storeId &&
          other.name == this.name &&
          other.normalizedName == this.normalizedName &&
          other.category == this.category &&
          other.purchasePrice == this.purchasePrice &&
          other.sellingPrice == this.sellingPrice &&
          other.stock == this.stock &&
          other.minimumStock == this.minimumStock &&
          other.leadTimeDays == this.leadTimeDays &&
          other.barcode == this.barcode &&
          other.photoUri == this.photoUri &&
          other.shelfLocation == this.shelfLocation &&
          other.aiLabel == this.aiLabel &&
          other.active == this.active &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState);
}

class ProductsCompanion extends UpdateCompanion<ProductRow> {
  final Value<String> id;
  final Value<String> storeId;
  final Value<String> name;
  final Value<String> normalizedName;
  final Value<String> category;
  final Value<int> purchasePrice;
  final Value<int> sellingPrice;
  final Value<int> stock;
  final Value<int> minimumStock;
  final Value<int> leadTimeDays;
  final Value<String?> barcode;
  final Value<String?> photoUri;
  final Value<String?> shelfLocation;
  final Value<String?> aiLabel;
  final Value<bool> active;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> syncState;
  final Value<int> rowid;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.storeId = const Value.absent(),
    this.name = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.category = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.sellingPrice = const Value.absent(),
    this.stock = const Value.absent(),
    this.minimumStock = const Value.absent(),
    this.leadTimeDays = const Value.absent(),
    this.barcode = const Value.absent(),
    this.photoUri = const Value.absent(),
    this.shelfLocation = const Value.absent(),
    this.aiLabel = const Value.absent(),
    this.active = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsCompanion.insert({
    required String id,
    required String storeId,
    required String name,
    required String normalizedName,
    required String category,
    required int purchasePrice,
    required int sellingPrice,
    required int stock,
    required int minimumStock,
    this.leadTimeDays = const Value.absent(),
    this.barcode = const Value.absent(),
    this.photoUri = const Value.absent(),
    this.shelfLocation = const Value.absent(),
    this.aiLabel = const Value.absent(),
    this.active = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       storeId = Value(storeId),
       name = Value(name),
       normalizedName = Value(normalizedName),
       category = Value(category),
       purchasePrice = Value(purchasePrice),
       sellingPrice = Value(sellingPrice),
       stock = Value(stock),
       minimumStock = Value(minimumStock),
       updatedAt = Value(updatedAt);
  static Insertable<ProductRow> custom({
    Expression<String>? id,
    Expression<String>? storeId,
    Expression<String>? name,
    Expression<String>? normalizedName,
    Expression<String>? category,
    Expression<int>? purchasePrice,
    Expression<int>? sellingPrice,
    Expression<int>? stock,
    Expression<int>? minimumStock,
    Expression<int>? leadTimeDays,
    Expression<String>? barcode,
    Expression<String>? photoUri,
    Expression<String>? shelfLocation,
    Expression<String>? aiLabel,
    Expression<bool>? active,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storeId != null) 'store_id': storeId,
      if (name != null) 'name': name,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (category != null) 'category': category,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (sellingPrice != null) 'selling_price': sellingPrice,
      if (stock != null) 'stock': stock,
      if (minimumStock != null) 'minimum_stock': minimumStock,
      if (leadTimeDays != null) 'lead_time_days': leadTimeDays,
      if (barcode != null) 'barcode': barcode,
      if (photoUri != null) 'photo_uri': photoUri,
      if (shelfLocation != null) 'shelf_location': shelfLocation,
      if (aiLabel != null) 'ai_label': aiLabel,
      if (active != null) 'active': active,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsCompanion copyWith({
    Value<String>? id,
    Value<String>? storeId,
    Value<String>? name,
    Value<String>? normalizedName,
    Value<String>? category,
    Value<int>? purchasePrice,
    Value<int>? sellingPrice,
    Value<int>? stock,
    Value<int>? minimumStock,
    Value<int>? leadTimeDays,
    Value<String?>? barcode,
    Value<String?>? photoUri,
    Value<String?>? shelfLocation,
    Value<String?>? aiLabel,
    Value<bool>? active,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? syncState,
    Value<int>? rowid,
  }) {
    return ProductsCompanion(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      category: category ?? this.category,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stock: stock ?? this.stock,
      minimumStock: minimumStock ?? this.minimumStock,
      leadTimeDays: leadTimeDays ?? this.leadTimeDays,
      barcode: barcode ?? this.barcode,
      photoUri: photoUri ?? this.photoUri,
      shelfLocation: shelfLocation ?? this.shelfLocation,
      aiLabel: aiLabel ?? this.aiLabel,
      active: active ?? this.active,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (purchasePrice.present) {
      map['purchase_price'] = Variable<int>(purchasePrice.value);
    }
    if (sellingPrice.present) {
      map['selling_price'] = Variable<int>(sellingPrice.value);
    }
    if (stock.present) {
      map['stock'] = Variable<int>(stock.value);
    }
    if (minimumStock.present) {
      map['minimum_stock'] = Variable<int>(minimumStock.value);
    }
    if (leadTimeDays.present) {
      map['lead_time_days'] = Variable<int>(leadTimeDays.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (photoUri.present) {
      map['photo_uri'] = Variable<String>(photoUri.value);
    }
    if (shelfLocation.present) {
      map['shelf_location'] = Variable<String>(shelfLocation.value);
    }
    if (aiLabel.present) {
      map['ai_label'] = Variable<String>(aiLabel.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('category: $category, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('sellingPrice: $sellingPrice, ')
          ..write('stock: $stock, ')
          ..write('minimumStock: $minimumStock, ')
          ..write('leadTimeDays: $leadTimeDays, ')
          ..write('barcode: $barcode, ')
          ..write('photoUri: $photoUri, ')
          ..write('shelfLocation: $shelfLocation, ')
          ..write('aiLabel: $aiLabel, ')
          ..write('active: $active, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SalesTransactionsTable extends SalesTransactions
    with TableInfo<$SalesTransactionsTable, TransactionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalesTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeIdMeta = const VerificationMeta(
    'storeId',
  );
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
    'store_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientMutationIdMeta = const VerificationMeta(
    'clientMutationId',
  );
  @override
  late final GeneratedColumn<String> clientMutationId = GeneratedColumn<String>(
    'client_mutation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalAmountMeta = const VerificationMeta(
    'totalAmount',
  );
  @override
  late final GeneratedColumn<int> totalAmount = GeneratedColumn<int>(
    'total_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _grossProfitAmountMeta = const VerificationMeta(
    'grossProfitAmount',
  );
  @override
  late final GeneratedColumn<int> grossProfitAmount = GeneratedColumn<int>(
    'gross_profit_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receivedAmountMeta = const VerificationMeta(
    'receivedAmount',
  );
  @override
  late final GeneratedColumn<int> receivedAmount = GeneratedColumn<int>(
    'received_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _changeAmountMeta = const VerificationMeta(
    'changeAmount',
  );
  @override
  late final GeneratedColumn<int> changeAmount = GeneratedColumn<int>(
    'change_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cashierIdMeta = const VerificationMeta(
    'cashierId',
  );
  @override
  late final GeneratedColumn<String> cashierId = GeneratedColumn<String>(
    'cashier_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    storeId,
    clientMutationId,
    occurredAt,
    totalAmount,
    grossProfitAmount,
    paymentMethod,
    receivedAmount,
    changeAmount,
    cashierId,
    status,
    updatedAt,
    syncState,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sales_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(
        _storeIdMeta,
        storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storeIdMeta);
    }
    if (data.containsKey('client_mutation_id')) {
      context.handle(
        _clientMutationIdMeta,
        clientMutationId.isAcceptableOrUnknown(
          data['client_mutation_id']!,
          _clientMutationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clientMutationIdMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('total_amount')) {
      context.handle(
        _totalAmountMeta,
        totalAmount.isAcceptableOrUnknown(
          data['total_amount']!,
          _totalAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    if (data.containsKey('gross_profit_amount')) {
      context.handle(
        _grossProfitAmountMeta,
        grossProfitAmount.isAcceptableOrUnknown(
          data['gross_profit_amount']!,
          _grossProfitAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_grossProfitAmountMeta);
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentMethodMeta);
    }
    if (data.containsKey('received_amount')) {
      context.handle(
        _receivedAmountMeta,
        receivedAmount.isAcceptableOrUnknown(
          data['received_amount']!,
          _receivedAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_receivedAmountMeta);
    }
    if (data.containsKey('change_amount')) {
      context.handle(
        _changeAmountMeta,
        changeAmount.isAcceptableOrUnknown(
          data['change_amount']!,
          _changeAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_changeAmountMeta);
    }
    if (data.containsKey('cashier_id')) {
      context.handle(
        _cashierIdMeta,
        cashierId.isAcceptableOrUnknown(data['cashier_id']!, _cashierIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cashierIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {storeId, clientMutationId},
  ];
  @override
  TransactionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      storeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_id'],
      )!,
      clientMutationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_mutation_id'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      totalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_amount'],
      )!,
      grossProfitAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gross_profit_amount'],
      )!,
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      )!,
      receivedAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}received_amount'],
      )!,
      changeAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}change_amount'],
      )!,
      cashierId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cashier_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
    );
  }

  @override
  $SalesTransactionsTable createAlias(String alias) {
    return $SalesTransactionsTable(attachedDatabase, alias);
  }
}

class TransactionRow extends DataClass implements Insertable<TransactionRow> {
  final String id;
  final String storeId;
  final String clientMutationId;
  final DateTime occurredAt;
  final int totalAmount;
  final int grossProfitAmount;
  final String paymentMethod;
  final int receivedAmount;
  final int changeAmount;
  final String cashierId;
  final String status;
  final DateTime updatedAt;
  final String syncState;
  const TransactionRow({
    required this.id,
    required this.storeId,
    required this.clientMutationId,
    required this.occurredAt,
    required this.totalAmount,
    required this.grossProfitAmount,
    required this.paymentMethod,
    required this.receivedAmount,
    required this.changeAmount,
    required this.cashierId,
    required this.status,
    required this.updatedAt,
    required this.syncState,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['store_id'] = Variable<String>(storeId);
    map['client_mutation_id'] = Variable<String>(clientMutationId);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['total_amount'] = Variable<int>(totalAmount);
    map['gross_profit_amount'] = Variable<int>(grossProfitAmount);
    map['payment_method'] = Variable<String>(paymentMethod);
    map['received_amount'] = Variable<int>(receivedAmount);
    map['change_amount'] = Variable<int>(changeAmount);
    map['cashier_id'] = Variable<String>(cashierId);
    map['status'] = Variable<String>(status);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  SalesTransactionsCompanion toCompanion(bool nullToAbsent) {
    return SalesTransactionsCompanion(
      id: Value(id),
      storeId: Value(storeId),
      clientMutationId: Value(clientMutationId),
      occurredAt: Value(occurredAt),
      totalAmount: Value(totalAmount),
      grossProfitAmount: Value(grossProfitAmount),
      paymentMethod: Value(paymentMethod),
      receivedAmount: Value(receivedAmount),
      changeAmount: Value(changeAmount),
      cashierId: Value(cashierId),
      status: Value(status),
      updatedAt: Value(updatedAt),
      syncState: Value(syncState),
    );
  }

  factory TransactionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionRow(
      id: serializer.fromJson<String>(json['id']),
      storeId: serializer.fromJson<String>(json['storeId']),
      clientMutationId: serializer.fromJson<String>(json['clientMutationId']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      totalAmount: serializer.fromJson<int>(json['totalAmount']),
      grossProfitAmount: serializer.fromJson<int>(json['grossProfitAmount']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      receivedAmount: serializer.fromJson<int>(json['receivedAmount']),
      changeAmount: serializer.fromJson<int>(json['changeAmount']),
      cashierId: serializer.fromJson<String>(json['cashierId']),
      status: serializer.fromJson<String>(json['status']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'storeId': serializer.toJson<String>(storeId),
      'clientMutationId': serializer.toJson<String>(clientMutationId),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'totalAmount': serializer.toJson<int>(totalAmount),
      'grossProfitAmount': serializer.toJson<int>(grossProfitAmount),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'receivedAmount': serializer.toJson<int>(receivedAmount),
      'changeAmount': serializer.toJson<int>(changeAmount),
      'cashierId': serializer.toJson<String>(cashierId),
      'status': serializer.toJson<String>(status),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  TransactionRow copyWith({
    String? id,
    String? storeId,
    String? clientMutationId,
    DateTime? occurredAt,
    int? totalAmount,
    int? grossProfitAmount,
    String? paymentMethod,
    int? receivedAmount,
    int? changeAmount,
    String? cashierId,
    String? status,
    DateTime? updatedAt,
    String? syncState,
  }) => TransactionRow(
    id: id ?? this.id,
    storeId: storeId ?? this.storeId,
    clientMutationId: clientMutationId ?? this.clientMutationId,
    occurredAt: occurredAt ?? this.occurredAt,
    totalAmount: totalAmount ?? this.totalAmount,
    grossProfitAmount: grossProfitAmount ?? this.grossProfitAmount,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    receivedAmount: receivedAmount ?? this.receivedAmount,
    changeAmount: changeAmount ?? this.changeAmount,
    cashierId: cashierId ?? this.cashierId,
    status: status ?? this.status,
    updatedAt: updatedAt ?? this.updatedAt,
    syncState: syncState ?? this.syncState,
  );
  TransactionRow copyWithCompanion(SalesTransactionsCompanion data) {
    return TransactionRow(
      id: data.id.present ? data.id.value : this.id,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      clientMutationId: data.clientMutationId.present
          ? data.clientMutationId.value
          : this.clientMutationId,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      totalAmount: data.totalAmount.present
          ? data.totalAmount.value
          : this.totalAmount,
      grossProfitAmount: data.grossProfitAmount.present
          ? data.grossProfitAmount.value
          : this.grossProfitAmount,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      receivedAmount: data.receivedAmount.present
          ? data.receivedAmount.value
          : this.receivedAmount,
      changeAmount: data.changeAmount.present
          ? data.changeAmount.value
          : this.changeAmount,
      cashierId: data.cashierId.present ? data.cashierId.value : this.cashierId,
      status: data.status.present ? data.status.value : this.status,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionRow(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('clientMutationId: $clientMutationId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('grossProfitAmount: $grossProfitAmount, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('receivedAmount: $receivedAmount, ')
          ..write('changeAmount: $changeAmount, ')
          ..write('cashierId: $cashierId, ')
          ..write('status: $status, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    storeId,
    clientMutationId,
    occurredAt,
    totalAmount,
    grossProfitAmount,
    paymentMethod,
    receivedAmount,
    changeAmount,
    cashierId,
    status,
    updatedAt,
    syncState,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionRow &&
          other.id == this.id &&
          other.storeId == this.storeId &&
          other.clientMutationId == this.clientMutationId &&
          other.occurredAt == this.occurredAt &&
          other.totalAmount == this.totalAmount &&
          other.grossProfitAmount == this.grossProfitAmount &&
          other.paymentMethod == this.paymentMethod &&
          other.receivedAmount == this.receivedAmount &&
          other.changeAmount == this.changeAmount &&
          other.cashierId == this.cashierId &&
          other.status == this.status &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState);
}

class SalesTransactionsCompanion extends UpdateCompanion<TransactionRow> {
  final Value<String> id;
  final Value<String> storeId;
  final Value<String> clientMutationId;
  final Value<DateTime> occurredAt;
  final Value<int> totalAmount;
  final Value<int> grossProfitAmount;
  final Value<String> paymentMethod;
  final Value<int> receivedAmount;
  final Value<int> changeAmount;
  final Value<String> cashierId;
  final Value<String> status;
  final Value<DateTime> updatedAt;
  final Value<String> syncState;
  final Value<int> rowid;
  const SalesTransactionsCompanion({
    this.id = const Value.absent(),
    this.storeId = const Value.absent(),
    this.clientMutationId = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.grossProfitAmount = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.receivedAmount = const Value.absent(),
    this.changeAmount = const Value.absent(),
    this.cashierId = const Value.absent(),
    this.status = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SalesTransactionsCompanion.insert({
    required String id,
    required String storeId,
    required String clientMutationId,
    required DateTime occurredAt,
    required int totalAmount,
    required int grossProfitAmount,
    required String paymentMethod,
    required int receivedAmount,
    required int changeAmount,
    required String cashierId,
    required String status,
    required DateTime updatedAt,
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       storeId = Value(storeId),
       clientMutationId = Value(clientMutationId),
       occurredAt = Value(occurredAt),
       totalAmount = Value(totalAmount),
       grossProfitAmount = Value(grossProfitAmount),
       paymentMethod = Value(paymentMethod),
       receivedAmount = Value(receivedAmount),
       changeAmount = Value(changeAmount),
       cashierId = Value(cashierId),
       status = Value(status),
       updatedAt = Value(updatedAt);
  static Insertable<TransactionRow> custom({
    Expression<String>? id,
    Expression<String>? storeId,
    Expression<String>? clientMutationId,
    Expression<DateTime>? occurredAt,
    Expression<int>? totalAmount,
    Expression<int>? grossProfitAmount,
    Expression<String>? paymentMethod,
    Expression<int>? receivedAmount,
    Expression<int>? changeAmount,
    Expression<String>? cashierId,
    Expression<String>? status,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storeId != null) 'store_id': storeId,
      if (clientMutationId != null) 'client_mutation_id': clientMutationId,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (grossProfitAmount != null) 'gross_profit_amount': grossProfitAmount,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (receivedAmount != null) 'received_amount': receivedAmount,
      if (changeAmount != null) 'change_amount': changeAmount,
      if (cashierId != null) 'cashier_id': cashierId,
      if (status != null) 'status': status,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SalesTransactionsCompanion copyWith({
    Value<String>? id,
    Value<String>? storeId,
    Value<String>? clientMutationId,
    Value<DateTime>? occurredAt,
    Value<int>? totalAmount,
    Value<int>? grossProfitAmount,
    Value<String>? paymentMethod,
    Value<int>? receivedAmount,
    Value<int>? changeAmount,
    Value<String>? cashierId,
    Value<String>? status,
    Value<DateTime>? updatedAt,
    Value<String>? syncState,
    Value<int>? rowid,
  }) {
    return SalesTransactionsCompanion(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      clientMutationId: clientMutationId ?? this.clientMutationId,
      occurredAt: occurredAt ?? this.occurredAt,
      totalAmount: totalAmount ?? this.totalAmount,
      grossProfitAmount: grossProfitAmount ?? this.grossProfitAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      receivedAmount: receivedAmount ?? this.receivedAmount,
      changeAmount: changeAmount ?? this.changeAmount,
      cashierId: cashierId ?? this.cashierId,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (clientMutationId.present) {
      map['client_mutation_id'] = Variable<String>(clientMutationId.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<int>(totalAmount.value);
    }
    if (grossProfitAmount.present) {
      map['gross_profit_amount'] = Variable<int>(grossProfitAmount.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (receivedAmount.present) {
      map['received_amount'] = Variable<int>(receivedAmount.value);
    }
    if (changeAmount.present) {
      map['change_amount'] = Variable<int>(changeAmount.value);
    }
    if (cashierId.present) {
      map['cashier_id'] = Variable<String>(cashierId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalesTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('clientMutationId: $clientMutationId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('grossProfitAmount: $grossProfitAmount, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('receivedAmount: $receivedAmount, ')
          ..write('changeAmount: $changeAmount, ')
          ..write('cashierId: $cashierId, ')
          ..write('status: $status, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionItemsTable extends TransactionItems
    with TableInfo<$TransactionItemsTable, TransactionItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sales_transactions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productNameSnapshotMeta =
      const VerificationMeta('productNameSnapshot');
  @override
  late final GeneratedColumn<String> productNameSnapshot =
      GeneratedColumn<String>(
        'product_name_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purchasePriceSnapshotMeta =
      const VerificationMeta('purchasePriceSnapshot');
  @override
  late final GeneratedColumn<int> purchasePriceSnapshot = GeneratedColumn<int>(
    'purchase_price_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sellingPriceSnapshotMeta =
      const VerificationMeta('sellingPriceSnapshot');
  @override
  late final GeneratedColumn<int> sellingPriceSnapshot = GeneratedColumn<int>(
    'selling_price_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtotalAmountMeta = const VerificationMeta(
    'subtotalAmount',
  );
  @override
  late final GeneratedColumn<int> subtotalAmount = GeneratedColumn<int>(
    'subtotal_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _grossProfitAmountMeta = const VerificationMeta(
    'grossProfitAmount',
  );
  @override
  late final GeneratedColumn<int> grossProfitAmount = GeneratedColumn<int>(
    'gross_profit_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    transactionId,
    productId,
    productNameSnapshot,
    quantity,
    purchasePriceSnapshot,
    sellingPriceSnapshot,
    subtotalAmount,
    grossProfitAmount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('product_name_snapshot')) {
      context.handle(
        _productNameSnapshotMeta,
        productNameSnapshot.isAcceptableOrUnknown(
          data['product_name_snapshot']!,
          _productNameSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productNameSnapshotMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('purchase_price_snapshot')) {
      context.handle(
        _purchasePriceSnapshotMeta,
        purchasePriceSnapshot.isAcceptableOrUnknown(
          data['purchase_price_snapshot']!,
          _purchasePriceSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_purchasePriceSnapshotMeta);
    }
    if (data.containsKey('selling_price_snapshot')) {
      context.handle(
        _sellingPriceSnapshotMeta,
        sellingPriceSnapshot.isAcceptableOrUnknown(
          data['selling_price_snapshot']!,
          _sellingPriceSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sellingPriceSnapshotMeta);
    }
    if (data.containsKey('subtotal_amount')) {
      context.handle(
        _subtotalAmountMeta,
        subtotalAmount.isAcceptableOrUnknown(
          data['subtotal_amount']!,
          _subtotalAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subtotalAmountMeta);
    }
    if (data.containsKey('gross_profit_amount')) {
      context.handle(
        _grossProfitAmountMeta,
        grossProfitAmount.isAcceptableOrUnknown(
          data['gross_profit_amount']!,
          _grossProfitAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_grossProfitAmountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {transactionId, productId};
  @override
  TransactionItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionItemRow(
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      productNameSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name_snapshot'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      purchasePriceSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}purchase_price_snapshot'],
      )!,
      sellingPriceSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}selling_price_snapshot'],
      )!,
      subtotalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subtotal_amount'],
      )!,
      grossProfitAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gross_profit_amount'],
      )!,
    );
  }

  @override
  $TransactionItemsTable createAlias(String alias) {
    return $TransactionItemsTable(attachedDatabase, alias);
  }
}

class TransactionItemRow extends DataClass
    implements Insertable<TransactionItemRow> {
  final String transactionId;
  final String productId;
  final String productNameSnapshot;
  final int quantity;
  final int purchasePriceSnapshot;
  final int sellingPriceSnapshot;
  final int subtotalAmount;
  final int grossProfitAmount;
  const TransactionItemRow({
    required this.transactionId,
    required this.productId,
    required this.productNameSnapshot,
    required this.quantity,
    required this.purchasePriceSnapshot,
    required this.sellingPriceSnapshot,
    required this.subtotalAmount,
    required this.grossProfitAmount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['transaction_id'] = Variable<String>(transactionId);
    map['product_id'] = Variable<String>(productId);
    map['product_name_snapshot'] = Variable<String>(productNameSnapshot);
    map['quantity'] = Variable<int>(quantity);
    map['purchase_price_snapshot'] = Variable<int>(purchasePriceSnapshot);
    map['selling_price_snapshot'] = Variable<int>(sellingPriceSnapshot);
    map['subtotal_amount'] = Variable<int>(subtotalAmount);
    map['gross_profit_amount'] = Variable<int>(grossProfitAmount);
    return map;
  }

  TransactionItemsCompanion toCompanion(bool nullToAbsent) {
    return TransactionItemsCompanion(
      transactionId: Value(transactionId),
      productId: Value(productId),
      productNameSnapshot: Value(productNameSnapshot),
      quantity: Value(quantity),
      purchasePriceSnapshot: Value(purchasePriceSnapshot),
      sellingPriceSnapshot: Value(sellingPriceSnapshot),
      subtotalAmount: Value(subtotalAmount),
      grossProfitAmount: Value(grossProfitAmount),
    );
  }

  factory TransactionItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionItemRow(
      transactionId: serializer.fromJson<String>(json['transactionId']),
      productId: serializer.fromJson<String>(json['productId']),
      productNameSnapshot: serializer.fromJson<String>(
        json['productNameSnapshot'],
      ),
      quantity: serializer.fromJson<int>(json['quantity']),
      purchasePriceSnapshot: serializer.fromJson<int>(
        json['purchasePriceSnapshot'],
      ),
      sellingPriceSnapshot: serializer.fromJson<int>(
        json['sellingPriceSnapshot'],
      ),
      subtotalAmount: serializer.fromJson<int>(json['subtotalAmount']),
      grossProfitAmount: serializer.fromJson<int>(json['grossProfitAmount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'transactionId': serializer.toJson<String>(transactionId),
      'productId': serializer.toJson<String>(productId),
      'productNameSnapshot': serializer.toJson<String>(productNameSnapshot),
      'quantity': serializer.toJson<int>(quantity),
      'purchasePriceSnapshot': serializer.toJson<int>(purchasePriceSnapshot),
      'sellingPriceSnapshot': serializer.toJson<int>(sellingPriceSnapshot),
      'subtotalAmount': serializer.toJson<int>(subtotalAmount),
      'grossProfitAmount': serializer.toJson<int>(grossProfitAmount),
    };
  }

  TransactionItemRow copyWith({
    String? transactionId,
    String? productId,
    String? productNameSnapshot,
    int? quantity,
    int? purchasePriceSnapshot,
    int? sellingPriceSnapshot,
    int? subtotalAmount,
    int? grossProfitAmount,
  }) => TransactionItemRow(
    transactionId: transactionId ?? this.transactionId,
    productId: productId ?? this.productId,
    productNameSnapshot: productNameSnapshot ?? this.productNameSnapshot,
    quantity: quantity ?? this.quantity,
    purchasePriceSnapshot: purchasePriceSnapshot ?? this.purchasePriceSnapshot,
    sellingPriceSnapshot: sellingPriceSnapshot ?? this.sellingPriceSnapshot,
    subtotalAmount: subtotalAmount ?? this.subtotalAmount,
    grossProfitAmount: grossProfitAmount ?? this.grossProfitAmount,
  );
  TransactionItemRow copyWithCompanion(TransactionItemsCompanion data) {
    return TransactionItemRow(
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      productId: data.productId.present ? data.productId.value : this.productId,
      productNameSnapshot: data.productNameSnapshot.present
          ? data.productNameSnapshot.value
          : this.productNameSnapshot,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      purchasePriceSnapshot: data.purchasePriceSnapshot.present
          ? data.purchasePriceSnapshot.value
          : this.purchasePriceSnapshot,
      sellingPriceSnapshot: data.sellingPriceSnapshot.present
          ? data.sellingPriceSnapshot.value
          : this.sellingPriceSnapshot,
      subtotalAmount: data.subtotalAmount.present
          ? data.subtotalAmount.value
          : this.subtotalAmount,
      grossProfitAmount: data.grossProfitAmount.present
          ? data.grossProfitAmount.value
          : this.grossProfitAmount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionItemRow(')
          ..write('transactionId: $transactionId, ')
          ..write('productId: $productId, ')
          ..write('productNameSnapshot: $productNameSnapshot, ')
          ..write('quantity: $quantity, ')
          ..write('purchasePriceSnapshot: $purchasePriceSnapshot, ')
          ..write('sellingPriceSnapshot: $sellingPriceSnapshot, ')
          ..write('subtotalAmount: $subtotalAmount, ')
          ..write('grossProfitAmount: $grossProfitAmount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    transactionId,
    productId,
    productNameSnapshot,
    quantity,
    purchasePriceSnapshot,
    sellingPriceSnapshot,
    subtotalAmount,
    grossProfitAmount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionItemRow &&
          other.transactionId == this.transactionId &&
          other.productId == this.productId &&
          other.productNameSnapshot == this.productNameSnapshot &&
          other.quantity == this.quantity &&
          other.purchasePriceSnapshot == this.purchasePriceSnapshot &&
          other.sellingPriceSnapshot == this.sellingPriceSnapshot &&
          other.subtotalAmount == this.subtotalAmount &&
          other.grossProfitAmount == this.grossProfitAmount);
}

class TransactionItemsCompanion extends UpdateCompanion<TransactionItemRow> {
  final Value<String> transactionId;
  final Value<String> productId;
  final Value<String> productNameSnapshot;
  final Value<int> quantity;
  final Value<int> purchasePriceSnapshot;
  final Value<int> sellingPriceSnapshot;
  final Value<int> subtotalAmount;
  final Value<int> grossProfitAmount;
  final Value<int> rowid;
  const TransactionItemsCompanion({
    this.transactionId = const Value.absent(),
    this.productId = const Value.absent(),
    this.productNameSnapshot = const Value.absent(),
    this.quantity = const Value.absent(),
    this.purchasePriceSnapshot = const Value.absent(),
    this.sellingPriceSnapshot = const Value.absent(),
    this.subtotalAmount = const Value.absent(),
    this.grossProfitAmount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionItemsCompanion.insert({
    required String transactionId,
    required String productId,
    required String productNameSnapshot,
    required int quantity,
    required int purchasePriceSnapshot,
    required int sellingPriceSnapshot,
    required int subtotalAmount,
    required int grossProfitAmount,
    this.rowid = const Value.absent(),
  }) : transactionId = Value(transactionId),
       productId = Value(productId),
       productNameSnapshot = Value(productNameSnapshot),
       quantity = Value(quantity),
       purchasePriceSnapshot = Value(purchasePriceSnapshot),
       sellingPriceSnapshot = Value(sellingPriceSnapshot),
       subtotalAmount = Value(subtotalAmount),
       grossProfitAmount = Value(grossProfitAmount);
  static Insertable<TransactionItemRow> custom({
    Expression<String>? transactionId,
    Expression<String>? productId,
    Expression<String>? productNameSnapshot,
    Expression<int>? quantity,
    Expression<int>? purchasePriceSnapshot,
    Expression<int>? sellingPriceSnapshot,
    Expression<int>? subtotalAmount,
    Expression<int>? grossProfitAmount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (transactionId != null) 'transaction_id': transactionId,
      if (productId != null) 'product_id': productId,
      if (productNameSnapshot != null)
        'product_name_snapshot': productNameSnapshot,
      if (quantity != null) 'quantity': quantity,
      if (purchasePriceSnapshot != null)
        'purchase_price_snapshot': purchasePriceSnapshot,
      if (sellingPriceSnapshot != null)
        'selling_price_snapshot': sellingPriceSnapshot,
      if (subtotalAmount != null) 'subtotal_amount': subtotalAmount,
      if (grossProfitAmount != null) 'gross_profit_amount': grossProfitAmount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionItemsCompanion copyWith({
    Value<String>? transactionId,
    Value<String>? productId,
    Value<String>? productNameSnapshot,
    Value<int>? quantity,
    Value<int>? purchasePriceSnapshot,
    Value<int>? sellingPriceSnapshot,
    Value<int>? subtotalAmount,
    Value<int>? grossProfitAmount,
    Value<int>? rowid,
  }) {
    return TransactionItemsCompanion(
      transactionId: transactionId ?? this.transactionId,
      productId: productId ?? this.productId,
      productNameSnapshot: productNameSnapshot ?? this.productNameSnapshot,
      quantity: quantity ?? this.quantity,
      purchasePriceSnapshot:
          purchasePriceSnapshot ?? this.purchasePriceSnapshot,
      sellingPriceSnapshot: sellingPriceSnapshot ?? this.sellingPriceSnapshot,
      subtotalAmount: subtotalAmount ?? this.subtotalAmount,
      grossProfitAmount: grossProfitAmount ?? this.grossProfitAmount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (productNameSnapshot.present) {
      map['product_name_snapshot'] = Variable<String>(
        productNameSnapshot.value,
      );
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (purchasePriceSnapshot.present) {
      map['purchase_price_snapshot'] = Variable<int>(
        purchasePriceSnapshot.value,
      );
    }
    if (sellingPriceSnapshot.present) {
      map['selling_price_snapshot'] = Variable<int>(sellingPriceSnapshot.value);
    }
    if (subtotalAmount.present) {
      map['subtotal_amount'] = Variable<int>(subtotalAmount.value);
    }
    if (grossProfitAmount.present) {
      map['gross_profit_amount'] = Variable<int>(grossProfitAmount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionItemsCompanion(')
          ..write('transactionId: $transactionId, ')
          ..write('productId: $productId, ')
          ..write('productNameSnapshot: $productNameSnapshot, ')
          ..write('quantity: $quantity, ')
          ..write('purchasePriceSnapshot: $purchasePriceSnapshot, ')
          ..write('sellingPriceSnapshot: $sellingPriceSnapshot, ')
          ..write('subtotalAmount: $subtotalAmount, ')
          ..write('grossProfitAmount: $grossProfitAmount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PredictionsTable extends Predictions
    with TableInfo<$PredictionsTable, PredictionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PredictionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeIdMeta = const VerificationMeta(
    'storeId',
  );
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
    'store_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
    'captured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aiLabelMeta = const VerificationMeta(
    'aiLabel',
  );
  @override
  late final GeneratedColumn<String> aiLabel = GeneratedColumn<String>(
    'ai_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _selectedProductIdMeta = const VerificationMeta(
    'selectedProductId',
  );
  @override
  late final GeneratedColumn<String> selectedProductId =
      GeneratedColumn<String>(
        'selected_product_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _correctedMeta = const VerificationMeta(
    'corrected',
  );
  @override
  late final GeneratedColumn<bool> corrected = GeneratedColumn<bool>(
    'corrected',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("corrected" IN (0, 1))',
    ),
  );
  static const VerificationMeta _correctionPhotoUriMeta =
      const VerificationMeta('correctionPhotoUri');
  @override
  late final GeneratedColumn<String> correctionPhotoUri =
      GeneratedColumn<String>(
        'correction_photo_uri',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _correctionPhotoExpiresAtMeta =
      const VerificationMeta('correctionPhotoExpiresAt');
  @override
  late final GeneratedColumn<DateTime> correctionPhotoExpiresAt =
      GeneratedColumn<DateTime>(
        'correction_photo_expires_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _cashierIdMeta = const VerificationMeta(
    'cashierId',
  );
  @override
  late final GeneratedColumn<String> cashierId = GeneratedColumn<String>(
    'cashier_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelVersionMeta = const VerificationMeta(
    'modelVersion',
  );
  @override
  late final GeneratedColumn<String> modelVersion = GeneratedColumn<String>(
    'model_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _consentToTrainingMeta = const VerificationMeta(
    'consentToTraining',
  );
  @override
  late final GeneratedColumn<bool> consentToTraining = GeneratedColumn<bool>(
    'consent_to_training',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("consent_to_training" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    storeId,
    capturedAt,
    aiLabel,
    confidence,
    selectedProductId,
    corrected,
    correctionPhotoUri,
    correctionPhotoExpiresAt,
    cashierId,
    modelVersion,
    consentToTraining,
    updatedAt,
    syncState,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'predictions';
  @override
  VerificationContext validateIntegrity(
    Insertable<PredictionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(
        _storeIdMeta,
        storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storeIdMeta);
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    if (data.containsKey('ai_label')) {
      context.handle(
        _aiLabelMeta,
        aiLabel.isAcceptableOrUnknown(data['ai_label']!, _aiLabelMeta),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('selected_product_id')) {
      context.handle(
        _selectedProductIdMeta,
        selectedProductId.isAcceptableOrUnknown(
          data['selected_product_id']!,
          _selectedProductIdMeta,
        ),
      );
    }
    if (data.containsKey('corrected')) {
      context.handle(
        _correctedMeta,
        corrected.isAcceptableOrUnknown(data['corrected']!, _correctedMeta),
      );
    } else if (isInserting) {
      context.missing(_correctedMeta);
    }
    if (data.containsKey('correction_photo_uri')) {
      context.handle(
        _correctionPhotoUriMeta,
        correctionPhotoUri.isAcceptableOrUnknown(
          data['correction_photo_uri']!,
          _correctionPhotoUriMeta,
        ),
      );
    }
    if (data.containsKey('correction_photo_expires_at')) {
      context.handle(
        _correctionPhotoExpiresAtMeta,
        correctionPhotoExpiresAt.isAcceptableOrUnknown(
          data['correction_photo_expires_at']!,
          _correctionPhotoExpiresAtMeta,
        ),
      );
    }
    if (data.containsKey('cashier_id')) {
      context.handle(
        _cashierIdMeta,
        cashierId.isAcceptableOrUnknown(data['cashier_id']!, _cashierIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cashierIdMeta);
    }
    if (data.containsKey('model_version')) {
      context.handle(
        _modelVersionMeta,
        modelVersion.isAcceptableOrUnknown(
          data['model_version']!,
          _modelVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_modelVersionMeta);
    }
    if (data.containsKey('consent_to_training')) {
      context.handle(
        _consentToTrainingMeta,
        consentToTraining.isAcceptableOrUnknown(
          data['consent_to_training']!,
          _consentToTrainingMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PredictionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PredictionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      storeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_id'],
      )!,
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at'],
      )!,
      aiLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ai_label'],
      ),
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      ),
      selectedProductId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_product_id'],
      ),
      corrected: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}corrected'],
      )!,
      correctionPhotoUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}correction_photo_uri'],
      ),
      correctionPhotoExpiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}correction_photo_expires_at'],
      ),
      cashierId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cashier_id'],
      )!,
      modelVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_version'],
      )!,
      consentToTraining: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}consent_to_training'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
    );
  }

  @override
  $PredictionsTable createAlias(String alias) {
    return $PredictionsTable(attachedDatabase, alias);
  }
}

class PredictionRow extends DataClass implements Insertable<PredictionRow> {
  final String id;
  final String storeId;
  final DateTime capturedAt;
  final String? aiLabel;
  final double? confidence;
  final String? selectedProductId;
  final bool corrected;
  final String? correctionPhotoUri;
  final DateTime? correctionPhotoExpiresAt;
  final String cashierId;
  final String modelVersion;
  final bool consentToTraining;
  final DateTime updatedAt;
  final String syncState;
  const PredictionRow({
    required this.id,
    required this.storeId,
    required this.capturedAt,
    this.aiLabel,
    this.confidence,
    this.selectedProductId,
    required this.corrected,
    this.correctionPhotoUri,
    this.correctionPhotoExpiresAt,
    required this.cashierId,
    required this.modelVersion,
    required this.consentToTraining,
    required this.updatedAt,
    required this.syncState,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['store_id'] = Variable<String>(storeId);
    map['captured_at'] = Variable<DateTime>(capturedAt);
    if (!nullToAbsent || aiLabel != null) {
      map['ai_label'] = Variable<String>(aiLabel);
    }
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    if (!nullToAbsent || selectedProductId != null) {
      map['selected_product_id'] = Variable<String>(selectedProductId);
    }
    map['corrected'] = Variable<bool>(corrected);
    if (!nullToAbsent || correctionPhotoUri != null) {
      map['correction_photo_uri'] = Variable<String>(correctionPhotoUri);
    }
    if (!nullToAbsent || correctionPhotoExpiresAt != null) {
      map['correction_photo_expires_at'] = Variable<DateTime>(
        correctionPhotoExpiresAt,
      );
    }
    map['cashier_id'] = Variable<String>(cashierId);
    map['model_version'] = Variable<String>(modelVersion);
    map['consent_to_training'] = Variable<bool>(consentToTraining);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  PredictionsCompanion toCompanion(bool nullToAbsent) {
    return PredictionsCompanion(
      id: Value(id),
      storeId: Value(storeId),
      capturedAt: Value(capturedAt),
      aiLabel: aiLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(aiLabel),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      selectedProductId: selectedProductId == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedProductId),
      corrected: Value(corrected),
      correctionPhotoUri: correctionPhotoUri == null && nullToAbsent
          ? const Value.absent()
          : Value(correctionPhotoUri),
      correctionPhotoExpiresAt: correctionPhotoExpiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(correctionPhotoExpiresAt),
      cashierId: Value(cashierId),
      modelVersion: Value(modelVersion),
      consentToTraining: Value(consentToTraining),
      updatedAt: Value(updatedAt),
      syncState: Value(syncState),
    );
  }

  factory PredictionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PredictionRow(
      id: serializer.fromJson<String>(json['id']),
      storeId: serializer.fromJson<String>(json['storeId']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
      aiLabel: serializer.fromJson<String?>(json['aiLabel']),
      confidence: serializer.fromJson<double?>(json['confidence']),
      selectedProductId: serializer.fromJson<String?>(
        json['selectedProductId'],
      ),
      corrected: serializer.fromJson<bool>(json['corrected']),
      correctionPhotoUri: serializer.fromJson<String?>(
        json['correctionPhotoUri'],
      ),
      correctionPhotoExpiresAt: serializer.fromJson<DateTime?>(
        json['correctionPhotoExpiresAt'],
      ),
      cashierId: serializer.fromJson<String>(json['cashierId']),
      modelVersion: serializer.fromJson<String>(json['modelVersion']),
      consentToTraining: serializer.fromJson<bool>(json['consentToTraining']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'storeId': serializer.toJson<String>(storeId),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
      'aiLabel': serializer.toJson<String?>(aiLabel),
      'confidence': serializer.toJson<double?>(confidence),
      'selectedProductId': serializer.toJson<String?>(selectedProductId),
      'corrected': serializer.toJson<bool>(corrected),
      'correctionPhotoUri': serializer.toJson<String?>(correctionPhotoUri),
      'correctionPhotoExpiresAt': serializer.toJson<DateTime?>(
        correctionPhotoExpiresAt,
      ),
      'cashierId': serializer.toJson<String>(cashierId),
      'modelVersion': serializer.toJson<String>(modelVersion),
      'consentToTraining': serializer.toJson<bool>(consentToTraining),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  PredictionRow copyWith({
    String? id,
    String? storeId,
    DateTime? capturedAt,
    Value<String?> aiLabel = const Value.absent(),
    Value<double?> confidence = const Value.absent(),
    Value<String?> selectedProductId = const Value.absent(),
    bool? corrected,
    Value<String?> correctionPhotoUri = const Value.absent(),
    Value<DateTime?> correctionPhotoExpiresAt = const Value.absent(),
    String? cashierId,
    String? modelVersion,
    bool? consentToTraining,
    DateTime? updatedAt,
    String? syncState,
  }) => PredictionRow(
    id: id ?? this.id,
    storeId: storeId ?? this.storeId,
    capturedAt: capturedAt ?? this.capturedAt,
    aiLabel: aiLabel.present ? aiLabel.value : this.aiLabel,
    confidence: confidence.present ? confidence.value : this.confidence,
    selectedProductId: selectedProductId.present
        ? selectedProductId.value
        : this.selectedProductId,
    corrected: corrected ?? this.corrected,
    correctionPhotoUri: correctionPhotoUri.present
        ? correctionPhotoUri.value
        : this.correctionPhotoUri,
    correctionPhotoExpiresAt: correctionPhotoExpiresAt.present
        ? correctionPhotoExpiresAt.value
        : this.correctionPhotoExpiresAt,
    cashierId: cashierId ?? this.cashierId,
    modelVersion: modelVersion ?? this.modelVersion,
    consentToTraining: consentToTraining ?? this.consentToTraining,
    updatedAt: updatedAt ?? this.updatedAt,
    syncState: syncState ?? this.syncState,
  );
  PredictionRow copyWithCompanion(PredictionsCompanion data) {
    return PredictionRow(
      id: data.id.present ? data.id.value : this.id,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
      aiLabel: data.aiLabel.present ? data.aiLabel.value : this.aiLabel,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      selectedProductId: data.selectedProductId.present
          ? data.selectedProductId.value
          : this.selectedProductId,
      corrected: data.corrected.present ? data.corrected.value : this.corrected,
      correctionPhotoUri: data.correctionPhotoUri.present
          ? data.correctionPhotoUri.value
          : this.correctionPhotoUri,
      correctionPhotoExpiresAt: data.correctionPhotoExpiresAt.present
          ? data.correctionPhotoExpiresAt.value
          : this.correctionPhotoExpiresAt,
      cashierId: data.cashierId.present ? data.cashierId.value : this.cashierId,
      modelVersion: data.modelVersion.present
          ? data.modelVersion.value
          : this.modelVersion,
      consentToTraining: data.consentToTraining.present
          ? data.consentToTraining.value
          : this.consentToTraining,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PredictionRow(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('aiLabel: $aiLabel, ')
          ..write('confidence: $confidence, ')
          ..write('selectedProductId: $selectedProductId, ')
          ..write('corrected: $corrected, ')
          ..write('correctionPhotoUri: $correctionPhotoUri, ')
          ..write('correctionPhotoExpiresAt: $correctionPhotoExpiresAt, ')
          ..write('cashierId: $cashierId, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('consentToTraining: $consentToTraining, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    storeId,
    capturedAt,
    aiLabel,
    confidence,
    selectedProductId,
    corrected,
    correctionPhotoUri,
    correctionPhotoExpiresAt,
    cashierId,
    modelVersion,
    consentToTraining,
    updatedAt,
    syncState,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PredictionRow &&
          other.id == this.id &&
          other.storeId == this.storeId &&
          other.capturedAt == this.capturedAt &&
          other.aiLabel == this.aiLabel &&
          other.confidence == this.confidence &&
          other.selectedProductId == this.selectedProductId &&
          other.corrected == this.corrected &&
          other.correctionPhotoUri == this.correctionPhotoUri &&
          other.correctionPhotoExpiresAt == this.correctionPhotoExpiresAt &&
          other.cashierId == this.cashierId &&
          other.modelVersion == this.modelVersion &&
          other.consentToTraining == this.consentToTraining &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState);
}

class PredictionsCompanion extends UpdateCompanion<PredictionRow> {
  final Value<String> id;
  final Value<String> storeId;
  final Value<DateTime> capturedAt;
  final Value<String?> aiLabel;
  final Value<double?> confidence;
  final Value<String?> selectedProductId;
  final Value<bool> corrected;
  final Value<String?> correctionPhotoUri;
  final Value<DateTime?> correctionPhotoExpiresAt;
  final Value<String> cashierId;
  final Value<String> modelVersion;
  final Value<bool> consentToTraining;
  final Value<DateTime> updatedAt;
  final Value<String> syncState;
  final Value<int> rowid;
  const PredictionsCompanion({
    this.id = const Value.absent(),
    this.storeId = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.aiLabel = const Value.absent(),
    this.confidence = const Value.absent(),
    this.selectedProductId = const Value.absent(),
    this.corrected = const Value.absent(),
    this.correctionPhotoUri = const Value.absent(),
    this.correctionPhotoExpiresAt = const Value.absent(),
    this.cashierId = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.consentToTraining = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PredictionsCompanion.insert({
    required String id,
    required String storeId,
    required DateTime capturedAt,
    this.aiLabel = const Value.absent(),
    this.confidence = const Value.absent(),
    this.selectedProductId = const Value.absent(),
    required bool corrected,
    this.correctionPhotoUri = const Value.absent(),
    this.correctionPhotoExpiresAt = const Value.absent(),
    required String cashierId,
    required String modelVersion,
    this.consentToTraining = const Value.absent(),
    required DateTime updatedAt,
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       storeId = Value(storeId),
       capturedAt = Value(capturedAt),
       corrected = Value(corrected),
       cashierId = Value(cashierId),
       modelVersion = Value(modelVersion),
       updatedAt = Value(updatedAt);
  static Insertable<PredictionRow> custom({
    Expression<String>? id,
    Expression<String>? storeId,
    Expression<DateTime>? capturedAt,
    Expression<String>? aiLabel,
    Expression<double>? confidence,
    Expression<String>? selectedProductId,
    Expression<bool>? corrected,
    Expression<String>? correctionPhotoUri,
    Expression<DateTime>? correctionPhotoExpiresAt,
    Expression<String>? cashierId,
    Expression<String>? modelVersion,
    Expression<bool>? consentToTraining,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storeId != null) 'store_id': storeId,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (aiLabel != null) 'ai_label': aiLabel,
      if (confidence != null) 'confidence': confidence,
      if (selectedProductId != null) 'selected_product_id': selectedProductId,
      if (corrected != null) 'corrected': corrected,
      if (correctionPhotoUri != null)
        'correction_photo_uri': correctionPhotoUri,
      if (correctionPhotoExpiresAt != null)
        'correction_photo_expires_at': correctionPhotoExpiresAt,
      if (cashierId != null) 'cashier_id': cashierId,
      if (modelVersion != null) 'model_version': modelVersion,
      if (consentToTraining != null) 'consent_to_training': consentToTraining,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PredictionsCompanion copyWith({
    Value<String>? id,
    Value<String>? storeId,
    Value<DateTime>? capturedAt,
    Value<String?>? aiLabel,
    Value<double?>? confidence,
    Value<String?>? selectedProductId,
    Value<bool>? corrected,
    Value<String?>? correctionPhotoUri,
    Value<DateTime?>? correctionPhotoExpiresAt,
    Value<String>? cashierId,
    Value<String>? modelVersion,
    Value<bool>? consentToTraining,
    Value<DateTime>? updatedAt,
    Value<String>? syncState,
    Value<int>? rowid,
  }) {
    return PredictionsCompanion(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      capturedAt: capturedAt ?? this.capturedAt,
      aiLabel: aiLabel ?? this.aiLabel,
      confidence: confidence ?? this.confidence,
      selectedProductId: selectedProductId ?? this.selectedProductId,
      corrected: corrected ?? this.corrected,
      correctionPhotoUri: correctionPhotoUri ?? this.correctionPhotoUri,
      correctionPhotoExpiresAt:
          correctionPhotoExpiresAt ?? this.correctionPhotoExpiresAt,
      cashierId: cashierId ?? this.cashierId,
      modelVersion: modelVersion ?? this.modelVersion,
      consentToTraining: consentToTraining ?? this.consentToTraining,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (aiLabel.present) {
      map['ai_label'] = Variable<String>(aiLabel.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (selectedProductId.present) {
      map['selected_product_id'] = Variable<String>(selectedProductId.value);
    }
    if (corrected.present) {
      map['corrected'] = Variable<bool>(corrected.value);
    }
    if (correctionPhotoUri.present) {
      map['correction_photo_uri'] = Variable<String>(correctionPhotoUri.value);
    }
    if (correctionPhotoExpiresAt.present) {
      map['correction_photo_expires_at'] = Variable<DateTime>(
        correctionPhotoExpiresAt.value,
      );
    }
    if (cashierId.present) {
      map['cashier_id'] = Variable<String>(cashierId.value);
    }
    if (modelVersion.present) {
      map['model_version'] = Variable<String>(modelVersion.value);
    }
    if (consentToTraining.present) {
      map['consent_to_training'] = Variable<bool>(consentToTraining.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PredictionsCompanion(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('aiLabel: $aiLabel, ')
          ..write('confidence: $confidence, ')
          ..write('selectedProductId: $selectedProductId, ')
          ..write('corrected: $corrected, ')
          ..write('correctionPhotoUri: $correctionPhotoUri, ')
          ..write('correctionPhotoExpiresAt: $correctionPhotoExpiresAt, ')
          ..write('cashierId: $cashierId, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('consentToTraining: $consentToTraining, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StoreLayoutsTable extends StoreLayouts
    with TableInfo<$StoreLayoutsTable, StoreLayoutRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StoreLayoutsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeIdMeta = const VerificationMeta(
    'storeId',
  );
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
    'store_id',
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
  static const VerificationMeta _canvasAspectRatioMeta = const VerificationMeta(
    'canvasAspectRatio',
  );
  @override
  late final GeneratedColumn<double> canvasAspectRatio =
      GeneratedColumn<double>(
        'canvas_aspect_ratio',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _templateVersionMeta = const VerificationMeta(
    'templateVersion',
  );
  @override
  late final GeneratedColumn<int> templateVersion = GeneratedColumn<int>(
    'template_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
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
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    storeId,
    name,
    canvasAspectRatio,
    templateVersion,
    updatedAt,
    syncState,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'store_layouts';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoreLayoutRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(
        _storeIdMeta,
        storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storeIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('canvas_aspect_ratio')) {
      context.handle(
        _canvasAspectRatioMeta,
        canvasAspectRatio.isAcceptableOrUnknown(
          data['canvas_aspect_ratio']!,
          _canvasAspectRatioMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_canvasAspectRatioMeta);
    }
    if (data.containsKey('template_version')) {
      context.handle(
        _templateVersionMeta,
        templateVersion.isAcceptableOrUnknown(
          data['template_version']!,
          _templateVersionMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {storeId},
  ];
  @override
  StoreLayoutRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoreLayoutRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      storeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      canvasAspectRatio: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}canvas_aspect_ratio'],
      )!,
      templateVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}template_version'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
    );
  }

  @override
  $StoreLayoutsTable createAlias(String alias) {
    return $StoreLayoutsTable(attachedDatabase, alias);
  }
}

class StoreLayoutRow extends DataClass implements Insertable<StoreLayoutRow> {
  final String id;
  final String storeId;
  final String name;
  final double canvasAspectRatio;
  final int templateVersion;
  final DateTime updatedAt;
  final String syncState;
  const StoreLayoutRow({
    required this.id,
    required this.storeId,
    required this.name,
    required this.canvasAspectRatio,
    required this.templateVersion,
    required this.updatedAt,
    required this.syncState,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['store_id'] = Variable<String>(storeId);
    map['name'] = Variable<String>(name);
    map['canvas_aspect_ratio'] = Variable<double>(canvasAspectRatio);
    map['template_version'] = Variable<int>(templateVersion);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  StoreLayoutsCompanion toCompanion(bool nullToAbsent) {
    return StoreLayoutsCompanion(
      id: Value(id),
      storeId: Value(storeId),
      name: Value(name),
      canvasAspectRatio: Value(canvasAspectRatio),
      templateVersion: Value(templateVersion),
      updatedAt: Value(updatedAt),
      syncState: Value(syncState),
    );
  }

  factory StoreLayoutRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoreLayoutRow(
      id: serializer.fromJson<String>(json['id']),
      storeId: serializer.fromJson<String>(json['storeId']),
      name: serializer.fromJson<String>(json['name']),
      canvasAspectRatio: serializer.fromJson<double>(json['canvasAspectRatio']),
      templateVersion: serializer.fromJson<int>(json['templateVersion']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'storeId': serializer.toJson<String>(storeId),
      'name': serializer.toJson<String>(name),
      'canvasAspectRatio': serializer.toJson<double>(canvasAspectRatio),
      'templateVersion': serializer.toJson<int>(templateVersion),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  StoreLayoutRow copyWith({
    String? id,
    String? storeId,
    String? name,
    double? canvasAspectRatio,
    int? templateVersion,
    DateTime? updatedAt,
    String? syncState,
  }) => StoreLayoutRow(
    id: id ?? this.id,
    storeId: storeId ?? this.storeId,
    name: name ?? this.name,
    canvasAspectRatio: canvasAspectRatio ?? this.canvasAspectRatio,
    templateVersion: templateVersion ?? this.templateVersion,
    updatedAt: updatedAt ?? this.updatedAt,
    syncState: syncState ?? this.syncState,
  );
  StoreLayoutRow copyWithCompanion(StoreLayoutsCompanion data) {
    return StoreLayoutRow(
      id: data.id.present ? data.id.value : this.id,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      name: data.name.present ? data.name.value : this.name,
      canvasAspectRatio: data.canvasAspectRatio.present
          ? data.canvasAspectRatio.value
          : this.canvasAspectRatio,
      templateVersion: data.templateVersion.present
          ? data.templateVersion.value
          : this.templateVersion,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoreLayoutRow(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('name: $name, ')
          ..write('canvasAspectRatio: $canvasAspectRatio, ')
          ..write('templateVersion: $templateVersion, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    storeId,
    name,
    canvasAspectRatio,
    templateVersion,
    updatedAt,
    syncState,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoreLayoutRow &&
          other.id == this.id &&
          other.storeId == this.storeId &&
          other.name == this.name &&
          other.canvasAspectRatio == this.canvasAspectRatio &&
          other.templateVersion == this.templateVersion &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState);
}

class StoreLayoutsCompanion extends UpdateCompanion<StoreLayoutRow> {
  final Value<String> id;
  final Value<String> storeId;
  final Value<String> name;
  final Value<double> canvasAspectRatio;
  final Value<int> templateVersion;
  final Value<DateTime> updatedAt;
  final Value<String> syncState;
  final Value<int> rowid;
  const StoreLayoutsCompanion({
    this.id = const Value.absent(),
    this.storeId = const Value.absent(),
    this.name = const Value.absent(),
    this.canvasAspectRatio = const Value.absent(),
    this.templateVersion = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StoreLayoutsCompanion.insert({
    required String id,
    required String storeId,
    required String name,
    required double canvasAspectRatio,
    this.templateVersion = const Value.absent(),
    required DateTime updatedAt,
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       storeId = Value(storeId),
       name = Value(name),
       canvasAspectRatio = Value(canvasAspectRatio),
       updatedAt = Value(updatedAt);
  static Insertable<StoreLayoutRow> custom({
    Expression<String>? id,
    Expression<String>? storeId,
    Expression<String>? name,
    Expression<double>? canvasAspectRatio,
    Expression<int>? templateVersion,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storeId != null) 'store_id': storeId,
      if (name != null) 'name': name,
      if (canvasAspectRatio != null) 'canvas_aspect_ratio': canvasAspectRatio,
      if (templateVersion != null) 'template_version': templateVersion,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StoreLayoutsCompanion copyWith({
    Value<String>? id,
    Value<String>? storeId,
    Value<String>? name,
    Value<double>? canvasAspectRatio,
    Value<int>? templateVersion,
    Value<DateTime>? updatedAt,
    Value<String>? syncState,
    Value<int>? rowid,
  }) {
    return StoreLayoutsCompanion(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      canvasAspectRatio: canvasAspectRatio ?? this.canvasAspectRatio,
      templateVersion: templateVersion ?? this.templateVersion,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (canvasAspectRatio.present) {
      map['canvas_aspect_ratio'] = Variable<double>(canvasAspectRatio.value);
    }
    if (templateVersion.present) {
      map['template_version'] = Variable<int>(templateVersion.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StoreLayoutsCompanion(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('name: $name, ')
          ..write('canvasAspectRatio: $canvasAspectRatio, ')
          ..write('templateVersion: $templateVersion, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StoreFixturesTable extends StoreFixtures
    with TableInfo<$StoreFixturesTable, StoreFixtureRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StoreFixturesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _layoutIdMeta = const VerificationMeta(
    'layoutId',
  );
  @override
  late final GeneratedColumn<String> layoutId = GeneratedColumn<String>(
    'layout_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES store_layouts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _storeIdMeta = const VerificationMeta(
    'storeId',
  );
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
    'store_id',
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
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _xMeta = const VerificationMeta('x');
  @override
  late final GeneratedColumn<double> x = GeneratedColumn<double>(
    'x',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yMeta = const VerificationMeta('y');
  @override
  late final GeneratedColumn<double> y = GeneratedColumn<double>(
    'y',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fixtureWidthMeta = const VerificationMeta(
    'fixtureWidth',
  );
  @override
  late final GeneratedColumn<double> fixtureWidth = GeneratedColumn<double>(
    'fixture_width',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fixtureHeightMeta = const VerificationMeta(
    'fixtureHeight',
  );
  @override
  late final GeneratedColumn<double> fixtureHeight = GeneratedColumn<double>(
    'fixture_height',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rotationQuarterTurnsMeta =
      const VerificationMeta('rotationQuarterTurns');
  @override
  late final GeneratedColumn<int> rotationQuarterTurns = GeneratedColumn<int>(
    'rotation_quarter_turns',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _productIdsJsonMeta = const VerificationMeta(
    'productIdsJson',
  );
  @override
  late final GeneratedColumn<String> productIdsJson = GeneratedColumn<String>(
    'product_ids_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _panoramaZoneIdMeta = const VerificationMeta(
    'panoramaZoneId',
  );
  @override
  late final GeneratedColumn<String> panoramaZoneId = GeneratedColumn<String>(
    'panorama_zone_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    layoutId,
    storeId,
    type,
    label,
    x,
    y,
    fixtureWidth,
    fixtureHeight,
    rotationQuarterTurns,
    productIdsJson,
    panoramaZoneId,
    updatedAt,
    syncState,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'store_fixtures';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoreFixtureRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('layout_id')) {
      context.handle(
        _layoutIdMeta,
        layoutId.isAcceptableOrUnknown(data['layout_id']!, _layoutIdMeta),
      );
    } else if (isInserting) {
      context.missing(_layoutIdMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(
        _storeIdMeta,
        storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storeIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('x')) {
      context.handle(_xMeta, x.isAcceptableOrUnknown(data['x']!, _xMeta));
    } else if (isInserting) {
      context.missing(_xMeta);
    }
    if (data.containsKey('y')) {
      context.handle(_yMeta, y.isAcceptableOrUnknown(data['y']!, _yMeta));
    } else if (isInserting) {
      context.missing(_yMeta);
    }
    if (data.containsKey('fixture_width')) {
      context.handle(
        _fixtureWidthMeta,
        fixtureWidth.isAcceptableOrUnknown(
          data['fixture_width']!,
          _fixtureWidthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fixtureWidthMeta);
    }
    if (data.containsKey('fixture_height')) {
      context.handle(
        _fixtureHeightMeta,
        fixtureHeight.isAcceptableOrUnknown(
          data['fixture_height']!,
          _fixtureHeightMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fixtureHeightMeta);
    }
    if (data.containsKey('rotation_quarter_turns')) {
      context.handle(
        _rotationQuarterTurnsMeta,
        rotationQuarterTurns.isAcceptableOrUnknown(
          data['rotation_quarter_turns']!,
          _rotationQuarterTurnsMeta,
        ),
      );
    }
    if (data.containsKey('product_ids_json')) {
      context.handle(
        _productIdsJsonMeta,
        productIdsJson.isAcceptableOrUnknown(
          data['product_ids_json']!,
          _productIdsJsonMeta,
        ),
      );
    }
    if (data.containsKey('panorama_zone_id')) {
      context.handle(
        _panoramaZoneIdMeta,
        panoramaZoneId.isAcceptableOrUnknown(
          data['panorama_zone_id']!,
          _panoramaZoneIdMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StoreFixtureRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoreFixtureRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      layoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}layout_id'],
      )!,
      storeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      x: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}x'],
      )!,
      y: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}y'],
      )!,
      fixtureWidth: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fixture_width'],
      )!,
      fixtureHeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fixture_height'],
      )!,
      rotationQuarterTurns: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rotation_quarter_turns'],
      )!,
      productIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_ids_json'],
      )!,
      panoramaZoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}panorama_zone_id'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
    );
  }

  @override
  $StoreFixturesTable createAlias(String alias) {
    return $StoreFixturesTable(attachedDatabase, alias);
  }
}

class StoreFixtureRow extends DataClass implements Insertable<StoreFixtureRow> {
  final String id;
  final String layoutId;
  final String storeId;
  final String type;
  final String label;
  final double x;
  final double y;
  final double fixtureWidth;
  final double fixtureHeight;
  final int rotationQuarterTurns;
  final String productIdsJson;
  final String? panoramaZoneId;
  final DateTime updatedAt;
  final String syncState;
  const StoreFixtureRow({
    required this.id,
    required this.layoutId,
    required this.storeId,
    required this.type,
    required this.label,
    required this.x,
    required this.y,
    required this.fixtureWidth,
    required this.fixtureHeight,
    required this.rotationQuarterTurns,
    required this.productIdsJson,
    this.panoramaZoneId,
    required this.updatedAt,
    required this.syncState,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['layout_id'] = Variable<String>(layoutId);
    map['store_id'] = Variable<String>(storeId);
    map['type'] = Variable<String>(type);
    map['label'] = Variable<String>(label);
    map['x'] = Variable<double>(x);
    map['y'] = Variable<double>(y);
    map['fixture_width'] = Variable<double>(fixtureWidth);
    map['fixture_height'] = Variable<double>(fixtureHeight);
    map['rotation_quarter_turns'] = Variable<int>(rotationQuarterTurns);
    map['product_ids_json'] = Variable<String>(productIdsJson);
    if (!nullToAbsent || panoramaZoneId != null) {
      map['panorama_zone_id'] = Variable<String>(panoramaZoneId);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  StoreFixturesCompanion toCompanion(bool nullToAbsent) {
    return StoreFixturesCompanion(
      id: Value(id),
      layoutId: Value(layoutId),
      storeId: Value(storeId),
      type: Value(type),
      label: Value(label),
      x: Value(x),
      y: Value(y),
      fixtureWidth: Value(fixtureWidth),
      fixtureHeight: Value(fixtureHeight),
      rotationQuarterTurns: Value(rotationQuarterTurns),
      productIdsJson: Value(productIdsJson),
      panoramaZoneId: panoramaZoneId == null && nullToAbsent
          ? const Value.absent()
          : Value(panoramaZoneId),
      updatedAt: Value(updatedAt),
      syncState: Value(syncState),
    );
  }

  factory StoreFixtureRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoreFixtureRow(
      id: serializer.fromJson<String>(json['id']),
      layoutId: serializer.fromJson<String>(json['layoutId']),
      storeId: serializer.fromJson<String>(json['storeId']),
      type: serializer.fromJson<String>(json['type']),
      label: serializer.fromJson<String>(json['label']),
      x: serializer.fromJson<double>(json['x']),
      y: serializer.fromJson<double>(json['y']),
      fixtureWidth: serializer.fromJson<double>(json['fixtureWidth']),
      fixtureHeight: serializer.fromJson<double>(json['fixtureHeight']),
      rotationQuarterTurns: serializer.fromJson<int>(
        json['rotationQuarterTurns'],
      ),
      productIdsJson: serializer.fromJson<String>(json['productIdsJson']),
      panoramaZoneId: serializer.fromJson<String?>(json['panoramaZoneId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'layoutId': serializer.toJson<String>(layoutId),
      'storeId': serializer.toJson<String>(storeId),
      'type': serializer.toJson<String>(type),
      'label': serializer.toJson<String>(label),
      'x': serializer.toJson<double>(x),
      'y': serializer.toJson<double>(y),
      'fixtureWidth': serializer.toJson<double>(fixtureWidth),
      'fixtureHeight': serializer.toJson<double>(fixtureHeight),
      'rotationQuarterTurns': serializer.toJson<int>(rotationQuarterTurns),
      'productIdsJson': serializer.toJson<String>(productIdsJson),
      'panoramaZoneId': serializer.toJson<String?>(panoramaZoneId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  StoreFixtureRow copyWith({
    String? id,
    String? layoutId,
    String? storeId,
    String? type,
    String? label,
    double? x,
    double? y,
    double? fixtureWidth,
    double? fixtureHeight,
    int? rotationQuarterTurns,
    String? productIdsJson,
    Value<String?> panoramaZoneId = const Value.absent(),
    DateTime? updatedAt,
    String? syncState,
  }) => StoreFixtureRow(
    id: id ?? this.id,
    layoutId: layoutId ?? this.layoutId,
    storeId: storeId ?? this.storeId,
    type: type ?? this.type,
    label: label ?? this.label,
    x: x ?? this.x,
    y: y ?? this.y,
    fixtureWidth: fixtureWidth ?? this.fixtureWidth,
    fixtureHeight: fixtureHeight ?? this.fixtureHeight,
    rotationQuarterTurns: rotationQuarterTurns ?? this.rotationQuarterTurns,
    productIdsJson: productIdsJson ?? this.productIdsJson,
    panoramaZoneId: panoramaZoneId.present
        ? panoramaZoneId.value
        : this.panoramaZoneId,
    updatedAt: updatedAt ?? this.updatedAt,
    syncState: syncState ?? this.syncState,
  );
  StoreFixtureRow copyWithCompanion(StoreFixturesCompanion data) {
    return StoreFixtureRow(
      id: data.id.present ? data.id.value : this.id,
      layoutId: data.layoutId.present ? data.layoutId.value : this.layoutId,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      type: data.type.present ? data.type.value : this.type,
      label: data.label.present ? data.label.value : this.label,
      x: data.x.present ? data.x.value : this.x,
      y: data.y.present ? data.y.value : this.y,
      fixtureWidth: data.fixtureWidth.present
          ? data.fixtureWidth.value
          : this.fixtureWidth,
      fixtureHeight: data.fixtureHeight.present
          ? data.fixtureHeight.value
          : this.fixtureHeight,
      rotationQuarterTurns: data.rotationQuarterTurns.present
          ? data.rotationQuarterTurns.value
          : this.rotationQuarterTurns,
      productIdsJson: data.productIdsJson.present
          ? data.productIdsJson.value
          : this.productIdsJson,
      panoramaZoneId: data.panoramaZoneId.present
          ? data.panoramaZoneId.value
          : this.panoramaZoneId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoreFixtureRow(')
          ..write('id: $id, ')
          ..write('layoutId: $layoutId, ')
          ..write('storeId: $storeId, ')
          ..write('type: $type, ')
          ..write('label: $label, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('fixtureWidth: $fixtureWidth, ')
          ..write('fixtureHeight: $fixtureHeight, ')
          ..write('rotationQuarterTurns: $rotationQuarterTurns, ')
          ..write('productIdsJson: $productIdsJson, ')
          ..write('panoramaZoneId: $panoramaZoneId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    layoutId,
    storeId,
    type,
    label,
    x,
    y,
    fixtureWidth,
    fixtureHeight,
    rotationQuarterTurns,
    productIdsJson,
    panoramaZoneId,
    updatedAt,
    syncState,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoreFixtureRow &&
          other.id == this.id &&
          other.layoutId == this.layoutId &&
          other.storeId == this.storeId &&
          other.type == this.type &&
          other.label == this.label &&
          other.x == this.x &&
          other.y == this.y &&
          other.fixtureWidth == this.fixtureWidth &&
          other.fixtureHeight == this.fixtureHeight &&
          other.rotationQuarterTurns == this.rotationQuarterTurns &&
          other.productIdsJson == this.productIdsJson &&
          other.panoramaZoneId == this.panoramaZoneId &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState);
}

class StoreFixturesCompanion extends UpdateCompanion<StoreFixtureRow> {
  final Value<String> id;
  final Value<String> layoutId;
  final Value<String> storeId;
  final Value<String> type;
  final Value<String> label;
  final Value<double> x;
  final Value<double> y;
  final Value<double> fixtureWidth;
  final Value<double> fixtureHeight;
  final Value<int> rotationQuarterTurns;
  final Value<String> productIdsJson;
  final Value<String?> panoramaZoneId;
  final Value<DateTime> updatedAt;
  final Value<String> syncState;
  final Value<int> rowid;
  const StoreFixturesCompanion({
    this.id = const Value.absent(),
    this.layoutId = const Value.absent(),
    this.storeId = const Value.absent(),
    this.type = const Value.absent(),
    this.label = const Value.absent(),
    this.x = const Value.absent(),
    this.y = const Value.absent(),
    this.fixtureWidth = const Value.absent(),
    this.fixtureHeight = const Value.absent(),
    this.rotationQuarterTurns = const Value.absent(),
    this.productIdsJson = const Value.absent(),
    this.panoramaZoneId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StoreFixturesCompanion.insert({
    required String id,
    required String layoutId,
    required String storeId,
    required String type,
    required String label,
    required double x,
    required double y,
    required double fixtureWidth,
    required double fixtureHeight,
    this.rotationQuarterTurns = const Value.absent(),
    this.productIdsJson = const Value.absent(),
    this.panoramaZoneId = const Value.absent(),
    required DateTime updatedAt,
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       layoutId = Value(layoutId),
       storeId = Value(storeId),
       type = Value(type),
       label = Value(label),
       x = Value(x),
       y = Value(y),
       fixtureWidth = Value(fixtureWidth),
       fixtureHeight = Value(fixtureHeight),
       updatedAt = Value(updatedAt);
  static Insertable<StoreFixtureRow> custom({
    Expression<String>? id,
    Expression<String>? layoutId,
    Expression<String>? storeId,
    Expression<String>? type,
    Expression<String>? label,
    Expression<double>? x,
    Expression<double>? y,
    Expression<double>? fixtureWidth,
    Expression<double>? fixtureHeight,
    Expression<int>? rotationQuarterTurns,
    Expression<String>? productIdsJson,
    Expression<String>? panoramaZoneId,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (layoutId != null) 'layout_id': layoutId,
      if (storeId != null) 'store_id': storeId,
      if (type != null) 'type': type,
      if (label != null) 'label': label,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (fixtureWidth != null) 'fixture_width': fixtureWidth,
      if (fixtureHeight != null) 'fixture_height': fixtureHeight,
      if (rotationQuarterTurns != null)
        'rotation_quarter_turns': rotationQuarterTurns,
      if (productIdsJson != null) 'product_ids_json': productIdsJson,
      if (panoramaZoneId != null) 'panorama_zone_id': panoramaZoneId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StoreFixturesCompanion copyWith({
    Value<String>? id,
    Value<String>? layoutId,
    Value<String>? storeId,
    Value<String>? type,
    Value<String>? label,
    Value<double>? x,
    Value<double>? y,
    Value<double>? fixtureWidth,
    Value<double>? fixtureHeight,
    Value<int>? rotationQuarterTurns,
    Value<String>? productIdsJson,
    Value<String?>? panoramaZoneId,
    Value<DateTime>? updatedAt,
    Value<String>? syncState,
    Value<int>? rowid,
  }) {
    return StoreFixturesCompanion(
      id: id ?? this.id,
      layoutId: layoutId ?? this.layoutId,
      storeId: storeId ?? this.storeId,
      type: type ?? this.type,
      label: label ?? this.label,
      x: x ?? this.x,
      y: y ?? this.y,
      fixtureWidth: fixtureWidth ?? this.fixtureWidth,
      fixtureHeight: fixtureHeight ?? this.fixtureHeight,
      rotationQuarterTurns: rotationQuarterTurns ?? this.rotationQuarterTurns,
      productIdsJson: productIdsJson ?? this.productIdsJson,
      panoramaZoneId: panoramaZoneId ?? this.panoramaZoneId,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (layoutId.present) {
      map['layout_id'] = Variable<String>(layoutId.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (x.present) {
      map['x'] = Variable<double>(x.value);
    }
    if (y.present) {
      map['y'] = Variable<double>(y.value);
    }
    if (fixtureWidth.present) {
      map['fixture_width'] = Variable<double>(fixtureWidth.value);
    }
    if (fixtureHeight.present) {
      map['fixture_height'] = Variable<double>(fixtureHeight.value);
    }
    if (rotationQuarterTurns.present) {
      map['rotation_quarter_turns'] = Variable<int>(rotationQuarterTurns.value);
    }
    if (productIdsJson.present) {
      map['product_ids_json'] = Variable<String>(productIdsJson.value);
    }
    if (panoramaZoneId.present) {
      map['panorama_zone_id'] = Variable<String>(panoramaZoneId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StoreFixturesCompanion(')
          ..write('id: $id, ')
          ..write('layoutId: $layoutId, ')
          ..write('storeId: $storeId, ')
          ..write('type: $type, ')
          ..write('label: $label, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('fixtureWidth: $fixtureWidth, ')
          ..write('fixtureHeight: $fixtureHeight, ')
          ..write('rotationQuarterTurns: $rotationQuarterTurns, ')
          ..write('productIdsJson: $productIdsJson, ')
          ..write('panoramaZoneId: $panoramaZoneId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOutboxTable extends SyncOutbox
    with TableInfo<$SyncOutboxTable, SyncOutboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeIdMeta = const VerificationMeta(
    'storeId',
  );
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
    'store_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aggregateTypeMeta = const VerificationMeta(
    'aggregateType',
  );
  @override
  late final GeneratedColumn<String> aggregateType = GeneratedColumn<String>(
    'aggregate_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aggregateIdMeta = const VerificationMeta(
    'aggregateId',
  );
  @override
  late final GeneratedColumn<String> aggregateId = GeneratedColumn<String>(
    'aggregate_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
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
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>(
        'next_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    storeId,
    aggregateType,
    aggregateId,
    operation,
    payloadJson,
    createdAt,
    attemptCount,
    nextAttemptAt,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncOutboxRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(
        _storeIdMeta,
        storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storeIdMeta);
    }
    if (data.containsKey('aggregate_type')) {
      context.handle(
        _aggregateTypeMeta,
        aggregateType.isAcceptableOrUnknown(
          data['aggregate_type']!,
          _aggregateTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_aggregateTypeMeta);
    }
    if (data.containsKey('aggregate_id')) {
      context.handle(
        _aggregateIdMeta,
        aggregateId.isAcceptableOrUnknown(
          data['aggregate_id']!,
          _aggregateIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_aggregateIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncOutboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOutboxRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      storeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_id'],
      )!,
      aggregateType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aggregate_type'],
      )!,
      aggregateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aggregate_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_attempt_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $SyncOutboxTable createAlias(String alias) {
    return $SyncOutboxTable(attachedDatabase, alias);
  }
}

class SyncOutboxRow extends DataClass implements Insertable<SyncOutboxRow> {
  final String id;
  final String storeId;
  final String aggregateType;
  final String aggregateId;
  final String operation;
  final String payloadJson;
  final DateTime createdAt;
  final int attemptCount;
  final DateTime? nextAttemptAt;
  final String? lastError;
  const SyncOutboxRow({
    required this.id,
    required this.storeId,
    required this.aggregateType,
    required this.aggregateId,
    required this.operation,
    required this.payloadJson,
    required this.createdAt,
    required this.attemptCount,
    this.nextAttemptAt,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['store_id'] = Variable<String>(storeId);
    map['aggregate_type'] = Variable<String>(aggregateType);
    map['aggregate_id'] = Variable<String>(aggregateId);
    map['operation'] = Variable<String>(operation);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  SyncOutboxCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxCompanion(
      id: Value(id),
      storeId: Value(storeId),
      aggregateType: Value(aggregateType),
      aggregateId: Value(aggregateId),
      operation: Value(operation),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      attemptCount: Value(attemptCount),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory SyncOutboxRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOutboxRow(
      id: serializer.fromJson<String>(json['id']),
      storeId: serializer.fromJson<String>(json['storeId']),
      aggregateType: serializer.fromJson<String>(json['aggregateType']),
      aggregateId: serializer.fromJson<String>(json['aggregateId']),
      operation: serializer.fromJson<String>(json['operation']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['nextAttemptAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'storeId': serializer.toJson<String>(storeId),
      'aggregateType': serializer.toJson<String>(aggregateType),
      'aggregateId': serializer.toJson<String>(aggregateId),
      'operation': serializer.toJson<String>(operation),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'nextAttemptAt': serializer.toJson<DateTime?>(nextAttemptAt),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  SyncOutboxRow copyWith({
    String? id,
    String? storeId,
    String? aggregateType,
    String? aggregateId,
    String? operation,
    String? payloadJson,
    DateTime? createdAt,
    int? attemptCount,
    Value<DateTime?> nextAttemptAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
  }) => SyncOutboxRow(
    id: id ?? this.id,
    storeId: storeId ?? this.storeId,
    aggregateType: aggregateType ?? this.aggregateType,
    aggregateId: aggregateId ?? this.aggregateId,
    operation: operation ?? this.operation,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
    attemptCount: attemptCount ?? this.attemptCount,
    nextAttemptAt: nextAttemptAt.present
        ? nextAttemptAt.value
        : this.nextAttemptAt,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  SyncOutboxRow copyWithCompanion(SyncOutboxCompanion data) {
    return SyncOutboxRow(
      id: data.id.present ? data.id.value : this.id,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      aggregateType: data.aggregateType.present
          ? data.aggregateType.value
          : this.aggregateType,
      aggregateId: data.aggregateId.present
          ? data.aggregateId.value
          : this.aggregateId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxRow(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('aggregateType: $aggregateType, ')
          ..write('aggregateId: $aggregateId, ')
          ..write('operation: $operation, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    storeId,
    aggregateType,
    aggregateId,
    operation,
    payloadJson,
    createdAt,
    attemptCount,
    nextAttemptAt,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOutboxRow &&
          other.id == this.id &&
          other.storeId == this.storeId &&
          other.aggregateType == this.aggregateType &&
          other.aggregateId == this.aggregateId &&
          other.operation == this.operation &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.attemptCount == this.attemptCount &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.lastError == this.lastError);
}

class SyncOutboxCompanion extends UpdateCompanion<SyncOutboxRow> {
  final Value<String> id;
  final Value<String> storeId;
  final Value<String> aggregateType;
  final Value<String> aggregateId;
  final Value<String> operation;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<int> attemptCount;
  final Value<DateTime?> nextAttemptAt;
  final Value<String?> lastError;
  final Value<int> rowid;
  const SyncOutboxCompanion({
    this.id = const Value.absent(),
    this.storeId = const Value.absent(),
    this.aggregateType = const Value.absent(),
    this.aggregateId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncOutboxCompanion.insert({
    required String id,
    required String storeId,
    required String aggregateType,
    required String aggregateId,
    required String operation,
    required String payloadJson,
    required DateTime createdAt,
    this.attemptCount = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       storeId = Value(storeId),
       aggregateType = Value(aggregateType),
       aggregateId = Value(aggregateId),
       operation = Value(operation),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt);
  static Insertable<SyncOutboxRow> custom({
    Expression<String>? id,
    Expression<String>? storeId,
    Expression<String>? aggregateType,
    Expression<String>? aggregateId,
    Expression<String>? operation,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<int>? attemptCount,
    Expression<DateTime>? nextAttemptAt,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storeId != null) 'store_id': storeId,
      if (aggregateType != null) 'aggregate_type': aggregateType,
      if (aggregateId != null) 'aggregate_id': aggregateId,
      if (operation != null) 'operation': operation,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncOutboxCompanion copyWith({
    Value<String>? id,
    Value<String>? storeId,
    Value<String>? aggregateType,
    Value<String>? aggregateId,
    Value<String>? operation,
    Value<String>? payloadJson,
    Value<DateTime>? createdAt,
    Value<int>? attemptCount,
    Value<DateTime?>? nextAttemptAt,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return SyncOutboxCompanion(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      aggregateType: aggregateType ?? this.aggregateType,
      aggregateId: aggregateId ?? this.aggregateId,
      operation: operation ?? this.operation,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      attemptCount: attemptCount ?? this.attemptCount,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (aggregateType.present) {
      map['aggregate_type'] = Variable<String>(aggregateType.value);
    }
    if (aggregateId.present) {
      map['aggregate_id'] = Variable<String>(aggregateId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxCompanion(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('aggregateType: $aggregateType, ')
          ..write('aggregateId: $aggregateId, ')
          ..write('operation: $operation, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InventoryStockLedgerTable extends InventoryStockLedger
    with TableInfo<$InventoryStockLedgerTable, InventoryStockLedgerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryStockLedgerTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeIdMeta = const VerificationMeta(
    'storeId',
  );
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
    'store_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deltaMeta = const VerificationMeta('delta');
  @override
  late final GeneratedColumn<int> delta = GeneratedColumn<int>(
    'delta',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actorIdMeta = const VerificationMeta(
    'actorId',
  );
  @override
  late final GeneratedColumn<String> actorId = GeneratedColumn<String>(
    'actor_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    storeId,
    productId,
    transactionId,
    delta,
    action,
    actorId,
    reason,
    occurredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory_stock_ledger';
  @override
  VerificationContext validateIntegrity(
    Insertable<InventoryStockLedgerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(
        _storeIdMeta,
        storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storeIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('delta')) {
      context.handle(
        _deltaMeta,
        delta.isAcceptableOrUnknown(data['delta']!, _deltaMeta),
      );
    } else if (isInserting) {
      context.missing(_deltaMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('actor_id')) {
      context.handle(
        _actorIdMeta,
        actorId.isAcceptableOrUnknown(data['actor_id']!, _actorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_actorIdMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InventoryStockLedgerRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryStockLedgerRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      storeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      )!,
      delta: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}delta'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      actorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_id'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
    );
  }

  @override
  $InventoryStockLedgerTable createAlias(String alias) {
    return $InventoryStockLedgerTable(attachedDatabase, alias);
  }
}

class InventoryStockLedgerRow extends DataClass
    implements Insertable<InventoryStockLedgerRow> {
  final String id;
  final String storeId;
  final String productId;
  final String transactionId;
  final int delta;
  final String action;
  final String actorId;
  final String? reason;
  final DateTime occurredAt;
  const InventoryStockLedgerRow({
    required this.id,
    required this.storeId,
    required this.productId,
    required this.transactionId,
    required this.delta,
    required this.action,
    required this.actorId,
    this.reason,
    required this.occurredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['store_id'] = Variable<String>(storeId);
    map['product_id'] = Variable<String>(productId);
    map['transaction_id'] = Variable<String>(transactionId);
    map['delta'] = Variable<int>(delta);
    map['action'] = Variable<String>(action);
    map['actor_id'] = Variable<String>(actorId);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    return map;
  }

  InventoryStockLedgerCompanion toCompanion(bool nullToAbsent) {
    return InventoryStockLedgerCompanion(
      id: Value(id),
      storeId: Value(storeId),
      productId: Value(productId),
      transactionId: Value(transactionId),
      delta: Value(delta),
      action: Value(action),
      actorId: Value(actorId),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      occurredAt: Value(occurredAt),
    );
  }

  factory InventoryStockLedgerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryStockLedgerRow(
      id: serializer.fromJson<String>(json['id']),
      storeId: serializer.fromJson<String>(json['storeId']),
      productId: serializer.fromJson<String>(json['productId']),
      transactionId: serializer.fromJson<String>(json['transactionId']),
      delta: serializer.fromJson<int>(json['delta']),
      action: serializer.fromJson<String>(json['action']),
      actorId: serializer.fromJson<String>(json['actorId']),
      reason: serializer.fromJson<String?>(json['reason']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'storeId': serializer.toJson<String>(storeId),
      'productId': serializer.toJson<String>(productId),
      'transactionId': serializer.toJson<String>(transactionId),
      'delta': serializer.toJson<int>(delta),
      'action': serializer.toJson<String>(action),
      'actorId': serializer.toJson<String>(actorId),
      'reason': serializer.toJson<String?>(reason),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
    };
  }

  InventoryStockLedgerRow copyWith({
    String? id,
    String? storeId,
    String? productId,
    String? transactionId,
    int? delta,
    String? action,
    String? actorId,
    Value<String?> reason = const Value.absent(),
    DateTime? occurredAt,
  }) => InventoryStockLedgerRow(
    id: id ?? this.id,
    storeId: storeId ?? this.storeId,
    productId: productId ?? this.productId,
    transactionId: transactionId ?? this.transactionId,
    delta: delta ?? this.delta,
    action: action ?? this.action,
    actorId: actorId ?? this.actorId,
    reason: reason.present ? reason.value : this.reason,
    occurredAt: occurredAt ?? this.occurredAt,
  );
  InventoryStockLedgerRow copyWithCompanion(
    InventoryStockLedgerCompanion data,
  ) {
    return InventoryStockLedgerRow(
      id: data.id.present ? data.id.value : this.id,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      productId: data.productId.present ? data.productId.value : this.productId,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      delta: data.delta.present ? data.delta.value : this.delta,
      action: data.action.present ? data.action.value : this.action,
      actorId: data.actorId.present ? data.actorId.value : this.actorId,
      reason: data.reason.present ? data.reason.value : this.reason,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryStockLedgerRow(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('productId: $productId, ')
          ..write('transactionId: $transactionId, ')
          ..write('delta: $delta, ')
          ..write('action: $action, ')
          ..write('actorId: $actorId, ')
          ..write('reason: $reason, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    storeId,
    productId,
    transactionId,
    delta,
    action,
    actorId,
    reason,
    occurredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryStockLedgerRow &&
          other.id == this.id &&
          other.storeId == this.storeId &&
          other.productId == this.productId &&
          other.transactionId == this.transactionId &&
          other.delta == this.delta &&
          other.action == this.action &&
          other.actorId == this.actorId &&
          other.reason == this.reason &&
          other.occurredAt == this.occurredAt);
}

class InventoryStockLedgerCompanion
    extends UpdateCompanion<InventoryStockLedgerRow> {
  final Value<String> id;
  final Value<String> storeId;
  final Value<String> productId;
  final Value<String> transactionId;
  final Value<int> delta;
  final Value<String> action;
  final Value<String> actorId;
  final Value<String?> reason;
  final Value<DateTime> occurredAt;
  final Value<int> rowid;
  const InventoryStockLedgerCompanion({
    this.id = const Value.absent(),
    this.storeId = const Value.absent(),
    this.productId = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.delta = const Value.absent(),
    this.action = const Value.absent(),
    this.actorId = const Value.absent(),
    this.reason = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InventoryStockLedgerCompanion.insert({
    required String id,
    required String storeId,
    required String productId,
    required String transactionId,
    required int delta,
    required String action,
    required String actorId,
    this.reason = const Value.absent(),
    required DateTime occurredAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       storeId = Value(storeId),
       productId = Value(productId),
       transactionId = Value(transactionId),
       delta = Value(delta),
       action = Value(action),
       actorId = Value(actorId),
       occurredAt = Value(occurredAt);
  static Insertable<InventoryStockLedgerRow> custom({
    Expression<String>? id,
    Expression<String>? storeId,
    Expression<String>? productId,
    Expression<String>? transactionId,
    Expression<int>? delta,
    Expression<String>? action,
    Expression<String>? actorId,
    Expression<String>? reason,
    Expression<DateTime>? occurredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storeId != null) 'store_id': storeId,
      if (productId != null) 'product_id': productId,
      if (transactionId != null) 'transaction_id': transactionId,
      if (delta != null) 'delta': delta,
      if (action != null) 'action': action,
      if (actorId != null) 'actor_id': actorId,
      if (reason != null) 'reason': reason,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InventoryStockLedgerCompanion copyWith({
    Value<String>? id,
    Value<String>? storeId,
    Value<String>? productId,
    Value<String>? transactionId,
    Value<int>? delta,
    Value<String>? action,
    Value<String>? actorId,
    Value<String?>? reason,
    Value<DateTime>? occurredAt,
    Value<int>? rowid,
  }) {
    return InventoryStockLedgerCompanion(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      productId: productId ?? this.productId,
      transactionId: transactionId ?? this.transactionId,
      delta: delta ?? this.delta,
      action: action ?? this.action,
      actorId: actorId ?? this.actorId,
      reason: reason ?? this.reason,
      occurredAt: occurredAt ?? this.occurredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (delta.present) {
      map['delta'] = Variable<int>(delta.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (actorId.present) {
      map['actor_id'] = Variable<String>(actorId.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryStockLedgerCompanion(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('productId: $productId, ')
          ..write('transactionId: $transactionId, ')
          ..write('delta: $delta, ')
          ..write('action: $action, ')
          ..write('actorId: $actorId, ')
          ..write('reason: $reason, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionAuditsTable extends TransactionAudits
    with TableInfo<$TransactionAuditsTable, TransactionAuditRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionAuditsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeIdMeta = const VerificationMeta(
    'storeId',
  );
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
    'store_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mutationIdMeta = const VerificationMeta(
    'mutationId',
  );
  @override
  late final GeneratedColumn<String> mutationId = GeneratedColumn<String>(
    'mutation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actorIdMeta = const VerificationMeta(
    'actorId',
  );
  @override
  late final GeneratedColumn<String> actorId = GeneratedColumn<String>(
    'actor_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    storeId,
    transactionId,
    mutationId,
    action,
    actorId,
    reason,
    occurredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_audits';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionAuditRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(
        _storeIdMeta,
        storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storeIdMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('mutation_id')) {
      context.handle(
        _mutationIdMeta,
        mutationId.isAcceptableOrUnknown(data['mutation_id']!, _mutationIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mutationIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('actor_id')) {
      context.handle(
        _actorIdMeta,
        actorId.isAcceptableOrUnknown(data['actor_id']!, _actorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_actorIdMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {storeId, mutationId},
  ];
  @override
  TransactionAuditRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionAuditRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      storeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      )!,
      mutationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mutation_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      actorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_id'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
    );
  }

  @override
  $TransactionAuditsTable createAlias(String alias) {
    return $TransactionAuditsTable(attachedDatabase, alias);
  }
}

class TransactionAuditRow extends DataClass
    implements Insertable<TransactionAuditRow> {
  final String id;
  final String storeId;
  final String transactionId;
  final String mutationId;
  final String action;
  final String actorId;
  final String reason;
  final DateTime occurredAt;
  const TransactionAuditRow({
    required this.id,
    required this.storeId,
    required this.transactionId,
    required this.mutationId,
    required this.action,
    required this.actorId,
    required this.reason,
    required this.occurredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['store_id'] = Variable<String>(storeId);
    map['transaction_id'] = Variable<String>(transactionId);
    map['mutation_id'] = Variable<String>(mutationId);
    map['action'] = Variable<String>(action);
    map['actor_id'] = Variable<String>(actorId);
    map['reason'] = Variable<String>(reason);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    return map;
  }

  TransactionAuditsCompanion toCompanion(bool nullToAbsent) {
    return TransactionAuditsCompanion(
      id: Value(id),
      storeId: Value(storeId),
      transactionId: Value(transactionId),
      mutationId: Value(mutationId),
      action: Value(action),
      actorId: Value(actorId),
      reason: Value(reason),
      occurredAt: Value(occurredAt),
    );
  }

  factory TransactionAuditRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionAuditRow(
      id: serializer.fromJson<String>(json['id']),
      storeId: serializer.fromJson<String>(json['storeId']),
      transactionId: serializer.fromJson<String>(json['transactionId']),
      mutationId: serializer.fromJson<String>(json['mutationId']),
      action: serializer.fromJson<String>(json['action']),
      actorId: serializer.fromJson<String>(json['actorId']),
      reason: serializer.fromJson<String>(json['reason']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'storeId': serializer.toJson<String>(storeId),
      'transactionId': serializer.toJson<String>(transactionId),
      'mutationId': serializer.toJson<String>(mutationId),
      'action': serializer.toJson<String>(action),
      'actorId': serializer.toJson<String>(actorId),
      'reason': serializer.toJson<String>(reason),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
    };
  }

  TransactionAuditRow copyWith({
    String? id,
    String? storeId,
    String? transactionId,
    String? mutationId,
    String? action,
    String? actorId,
    String? reason,
    DateTime? occurredAt,
  }) => TransactionAuditRow(
    id: id ?? this.id,
    storeId: storeId ?? this.storeId,
    transactionId: transactionId ?? this.transactionId,
    mutationId: mutationId ?? this.mutationId,
    action: action ?? this.action,
    actorId: actorId ?? this.actorId,
    reason: reason ?? this.reason,
    occurredAt: occurredAt ?? this.occurredAt,
  );
  TransactionAuditRow copyWithCompanion(TransactionAuditsCompanion data) {
    return TransactionAuditRow(
      id: data.id.present ? data.id.value : this.id,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      mutationId: data.mutationId.present
          ? data.mutationId.value
          : this.mutationId,
      action: data.action.present ? data.action.value : this.action,
      actorId: data.actorId.present ? data.actorId.value : this.actorId,
      reason: data.reason.present ? data.reason.value : this.reason,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionAuditRow(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('transactionId: $transactionId, ')
          ..write('mutationId: $mutationId, ')
          ..write('action: $action, ')
          ..write('actorId: $actorId, ')
          ..write('reason: $reason, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    storeId,
    transactionId,
    mutationId,
    action,
    actorId,
    reason,
    occurredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionAuditRow &&
          other.id == this.id &&
          other.storeId == this.storeId &&
          other.transactionId == this.transactionId &&
          other.mutationId == this.mutationId &&
          other.action == this.action &&
          other.actorId == this.actorId &&
          other.reason == this.reason &&
          other.occurredAt == this.occurredAt);
}

class TransactionAuditsCompanion extends UpdateCompanion<TransactionAuditRow> {
  final Value<String> id;
  final Value<String> storeId;
  final Value<String> transactionId;
  final Value<String> mutationId;
  final Value<String> action;
  final Value<String> actorId;
  final Value<String> reason;
  final Value<DateTime> occurredAt;
  final Value<int> rowid;
  const TransactionAuditsCompanion({
    this.id = const Value.absent(),
    this.storeId = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.mutationId = const Value.absent(),
    this.action = const Value.absent(),
    this.actorId = const Value.absent(),
    this.reason = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionAuditsCompanion.insert({
    required String id,
    required String storeId,
    required String transactionId,
    required String mutationId,
    required String action,
    required String actorId,
    required String reason,
    required DateTime occurredAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       storeId = Value(storeId),
       transactionId = Value(transactionId),
       mutationId = Value(mutationId),
       action = Value(action),
       actorId = Value(actorId),
       reason = Value(reason),
       occurredAt = Value(occurredAt);
  static Insertable<TransactionAuditRow> custom({
    Expression<String>? id,
    Expression<String>? storeId,
    Expression<String>? transactionId,
    Expression<String>? mutationId,
    Expression<String>? action,
    Expression<String>? actorId,
    Expression<String>? reason,
    Expression<DateTime>? occurredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storeId != null) 'store_id': storeId,
      if (transactionId != null) 'transaction_id': transactionId,
      if (mutationId != null) 'mutation_id': mutationId,
      if (action != null) 'action': action,
      if (actorId != null) 'actor_id': actorId,
      if (reason != null) 'reason': reason,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionAuditsCompanion copyWith({
    Value<String>? id,
    Value<String>? storeId,
    Value<String>? transactionId,
    Value<String>? mutationId,
    Value<String>? action,
    Value<String>? actorId,
    Value<String>? reason,
    Value<DateTime>? occurredAt,
    Value<int>? rowid,
  }) {
    return TransactionAuditsCompanion(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      transactionId: transactionId ?? this.transactionId,
      mutationId: mutationId ?? this.mutationId,
      action: action ?? this.action,
      actorId: actorId ?? this.actorId,
      reason: reason ?? this.reason,
      occurredAt: occurredAt ?? this.occurredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (mutationId.present) {
      map['mutation_id'] = Variable<String>(mutationId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (actorId.present) {
      map['actor_id'] = Variable<String>(actorId.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionAuditsCompanion(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('transactionId: $transactionId, ')
          ..write('mutationId: $mutationId, ')
          ..write('action: $action, ')
          ..write('actorId: $actorId, ')
          ..write('reason: $reason, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $SalesTransactionsTable salesTransactions =
      $SalesTransactionsTable(this);
  late final $TransactionItemsTable transactionItems = $TransactionItemsTable(
    this,
  );
  late final $PredictionsTable predictions = $PredictionsTable(this);
  late final $StoreLayoutsTable storeLayouts = $StoreLayoutsTable(this);
  late final $StoreFixturesTable storeFixtures = $StoreFixturesTable(this);
  late final $SyncOutboxTable syncOutbox = $SyncOutboxTable(this);
  late final $InventoryStockLedgerTable inventoryStockLedger =
      $InventoryStockLedgerTable(this);
  late final $TransactionAuditsTable transactionAudits =
      $TransactionAuditsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    products,
    salesTransactions,
    transactionItems,
    predictions,
    storeLayouts,
    storeFixtures,
    syncOutbox,
    inventoryStockLedger,
    transactionAudits,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sales_transactions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transaction_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'store_layouts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('store_fixtures', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      required String id,
      required String storeId,
      required String name,
      required String email,
      Value<String?> passwordHash,
      required String role,
      Value<bool> active,
      required DateTime updatedAt,
      Value<String> syncState,
      Value<int> rowid,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<String> id,
      Value<String> storeId,
      Value<String> name,
      Value<String> email,
      Value<String?> passwordHash,
      Value<String> role,
      Value<bool> active,
      Value<DateTime> updatedAt,
      Value<String> syncState,
      Value<int> rowid,
    });

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
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

  ColumnFilters<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
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

  ColumnOrderings<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          UserRow,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (UserRow, BaseReferences<_$AppDatabase, $UsersTable, UserRow>),
          UserRow,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> storeId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String?> passwordHash = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                storeId: storeId,
                name: name,
                email: email,
                passwordHash: passwordHash,
                role: role,
                active: active,
                updatedAt: updatedAt,
                syncState: syncState,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String storeId,
                required String name,
                required String email,
                Value<String?> passwordHash = const Value.absent(),
                required String role,
                Value<bool> active = const Value.absent(),
                required DateTime updatedAt,
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                storeId: storeId,
                name: name,
                email: email,
                passwordHash: passwordHash,
                role: role,
                active: active,
                updatedAt: updatedAt,
                syncState: syncState,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      UserRow,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (UserRow, BaseReferences<_$AppDatabase, $UsersTable, UserRow>),
      UserRow,
      PrefetchHooks Function()
    >;
typedef $$ProductsTableCreateCompanionBuilder =
    ProductsCompanion Function({
      required String id,
      required String storeId,
      required String name,
      required String normalizedName,
      required String category,
      required int purchasePrice,
      required int sellingPrice,
      required int stock,
      required int minimumStock,
      Value<int> leadTimeDays,
      Value<String?> barcode,
      Value<String?> photoUri,
      Value<String?> shelfLocation,
      Value<String?> aiLabel,
      Value<bool> active,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> syncState,
      Value<int> rowid,
    });
typedef $$ProductsTableUpdateCompanionBuilder =
    ProductsCompanion Function({
      Value<String> id,
      Value<String> storeId,
      Value<String> name,
      Value<String> normalizedName,
      Value<String> category,
      Value<int> purchasePrice,
      Value<int> sellingPrice,
      Value<int> stock,
      Value<int> minimumStock,
      Value<int> leadTimeDays,
      Value<String?> barcode,
      Value<String?> photoUri,
      Value<String?> shelfLocation,
      Value<String?> aiLabel,
      Value<bool> active,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> syncState,
      Value<int> rowid,
    });

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
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

  ColumnFilters<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sellingPrice => $composableBuilder(
    column: $table.sellingPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minimumStock => $composableBuilder(
    column: $table.minimumStock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get leadTimeDays => $composableBuilder(
    column: $table.leadTimeDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoUri => $composableBuilder(
    column: $table.photoUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shelfLocation => $composableBuilder(
    column: $table.shelfLocation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aiLabel => $composableBuilder(
    column: $table.aiLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
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

  ColumnOrderings<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sellingPrice => $composableBuilder(
    column: $table.sellingPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minimumStock => $composableBuilder(
    column: $table.minimumStock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get leadTimeDays => $composableBuilder(
    column: $table.leadTimeDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoUri => $composableBuilder(
    column: $table.photoUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shelfLocation => $composableBuilder(
    column: $table.shelfLocation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aiLabel => $composableBuilder(
    column: $table.aiLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sellingPrice => $composableBuilder(
    column: $table.sellingPrice,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stock =>
      $composableBuilder(column: $table.stock, builder: (column) => column);

  GeneratedColumn<int> get minimumStock => $composableBuilder(
    column: $table.minimumStock,
    builder: (column) => column,
  );

  GeneratedColumn<int> get leadTimeDays => $composableBuilder(
    column: $table.leadTimeDays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get photoUri =>
      $composableBuilder(column: $table.photoUri, builder: (column) => column);

  GeneratedColumn<String> get shelfLocation => $composableBuilder(
    column: $table.shelfLocation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get aiLabel =>
      $composableBuilder(column: $table.aiLabel, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);
}

class $$ProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductsTable,
          ProductRow,
          $$ProductsTableFilterComposer,
          $$ProductsTableOrderingComposer,
          $$ProductsTableAnnotationComposer,
          $$ProductsTableCreateCompanionBuilder,
          $$ProductsTableUpdateCompanionBuilder,
          (
            ProductRow,
            BaseReferences<_$AppDatabase, $ProductsTable, ProductRow>,
          ),
          ProductRow,
          PrefetchHooks Function()
        > {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> storeId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> normalizedName = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> purchasePrice = const Value.absent(),
                Value<int> sellingPrice = const Value.absent(),
                Value<int> stock = const Value.absent(),
                Value<int> minimumStock = const Value.absent(),
                Value<int> leadTimeDays = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String?> photoUri = const Value.absent(),
                Value<String?> shelfLocation = const Value.absent(),
                Value<String?> aiLabel = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion(
                id: id,
                storeId: storeId,
                name: name,
                normalizedName: normalizedName,
                category: category,
                purchasePrice: purchasePrice,
                sellingPrice: sellingPrice,
                stock: stock,
                minimumStock: minimumStock,
                leadTimeDays: leadTimeDays,
                barcode: barcode,
                photoUri: photoUri,
                shelfLocation: shelfLocation,
                aiLabel: aiLabel,
                active: active,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String storeId,
                required String name,
                required String normalizedName,
                required String category,
                required int purchasePrice,
                required int sellingPrice,
                required int stock,
                required int minimumStock,
                Value<int> leadTimeDays = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String?> photoUri = const Value.absent(),
                Value<String?> shelfLocation = const Value.absent(),
                Value<String?> aiLabel = const Value.absent(),
                Value<bool> active = const Value.absent(),
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion.insert(
                id: id,
                storeId: storeId,
                name: name,
                normalizedName: normalizedName,
                category: category,
                purchasePrice: purchasePrice,
                sellingPrice: sellingPrice,
                stock: stock,
                minimumStock: minimumStock,
                leadTimeDays: leadTimeDays,
                barcode: barcode,
                photoUri: photoUri,
                shelfLocation: shelfLocation,
                aiLabel: aiLabel,
                active: active,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductsTable,
      ProductRow,
      $$ProductsTableFilterComposer,
      $$ProductsTableOrderingComposer,
      $$ProductsTableAnnotationComposer,
      $$ProductsTableCreateCompanionBuilder,
      $$ProductsTableUpdateCompanionBuilder,
      (ProductRow, BaseReferences<_$AppDatabase, $ProductsTable, ProductRow>),
      ProductRow,
      PrefetchHooks Function()
    >;
typedef $$SalesTransactionsTableCreateCompanionBuilder =
    SalesTransactionsCompanion Function({
      required String id,
      required String storeId,
      required String clientMutationId,
      required DateTime occurredAt,
      required int totalAmount,
      required int grossProfitAmount,
      required String paymentMethod,
      required int receivedAmount,
      required int changeAmount,
      required String cashierId,
      required String status,
      required DateTime updatedAt,
      Value<String> syncState,
      Value<int> rowid,
    });
typedef $$SalesTransactionsTableUpdateCompanionBuilder =
    SalesTransactionsCompanion Function({
      Value<String> id,
      Value<String> storeId,
      Value<String> clientMutationId,
      Value<DateTime> occurredAt,
      Value<int> totalAmount,
      Value<int> grossProfitAmount,
      Value<String> paymentMethod,
      Value<int> receivedAmount,
      Value<int> changeAmount,
      Value<String> cashierId,
      Value<String> status,
      Value<DateTime> updatedAt,
      Value<String> syncState,
      Value<int> rowid,
    });

final class $$SalesTransactionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $SalesTransactionsTable, TransactionRow> {
  $$SalesTransactionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$TransactionItemsTable, List<TransactionItemRow>>
  _transactionItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactionItems,
    aliasName: $_aliasNameGenerator(
      db.salesTransactions.id,
      db.transactionItems.transactionId,
    ),
  );

  $$TransactionItemsTableProcessedTableManager get transactionItemsRefs {
    final manager = $$TransactionItemsTableTableManager(
      $_db,
      $_db.transactionItems,
    ).filter((f) => f.transactionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _transactionItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SalesTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $SalesTransactionsTable> {
  $$SalesTransactionsTableFilterComposer({
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

  ColumnFilters<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientMutationId => $composableBuilder(
    column: $table.clientMutationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get grossProfitAmount => $composableBuilder(
    column: $table.grossProfitAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get receivedAmount => $composableBuilder(
    column: $table.receivedAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get changeAmount => $composableBuilder(
    column: $table.changeAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cashierId => $composableBuilder(
    column: $table.cashierId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> transactionItemsRefs(
    Expression<bool> Function($$TransactionItemsTableFilterComposer f) f,
  ) {
    final $$TransactionItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactionItems,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionItemsTableFilterComposer(
            $db: $db,
            $table: $db.transactionItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SalesTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SalesTransactionsTable> {
  $$SalesTransactionsTableOrderingComposer({
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

  ColumnOrderings<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientMutationId => $composableBuilder(
    column: $table.clientMutationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get grossProfitAmount => $composableBuilder(
    column: $table.grossProfitAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get receivedAmount => $composableBuilder(
    column: $table.receivedAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get changeAmount => $composableBuilder(
    column: $table.changeAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cashierId => $composableBuilder(
    column: $table.cashierId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SalesTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalesTransactionsTable> {
  $$SalesTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<String> get clientMutationId => $composableBuilder(
    column: $table.clientMutationId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get grossProfitAmount => $composableBuilder(
    column: $table.grossProfitAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<int> get receivedAmount => $composableBuilder(
    column: $table.receivedAmount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get changeAmount => $composableBuilder(
    column: $table.changeAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cashierId =>
      $composableBuilder(column: $table.cashierId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  Expression<T> transactionItemsRefs<T extends Object>(
    Expression<T> Function($$TransactionItemsTableAnnotationComposer a) f,
  ) {
    final $$TransactionItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactionItems,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactionItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SalesTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SalesTransactionsTable,
          TransactionRow,
          $$SalesTransactionsTableFilterComposer,
          $$SalesTransactionsTableOrderingComposer,
          $$SalesTransactionsTableAnnotationComposer,
          $$SalesTransactionsTableCreateCompanionBuilder,
          $$SalesTransactionsTableUpdateCompanionBuilder,
          (TransactionRow, $$SalesTransactionsTableReferences),
          TransactionRow,
          PrefetchHooks Function({bool transactionItemsRefs})
        > {
  $$SalesTransactionsTableTableManager(
    _$AppDatabase db,
    $SalesTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SalesTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalesTransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalesTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> storeId = const Value.absent(),
                Value<String> clientMutationId = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<int> totalAmount = const Value.absent(),
                Value<int> grossProfitAmount = const Value.absent(),
                Value<String> paymentMethod = const Value.absent(),
                Value<int> receivedAmount = const Value.absent(),
                Value<int> changeAmount = const Value.absent(),
                Value<String> cashierId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalesTransactionsCompanion(
                id: id,
                storeId: storeId,
                clientMutationId: clientMutationId,
                occurredAt: occurredAt,
                totalAmount: totalAmount,
                grossProfitAmount: grossProfitAmount,
                paymentMethod: paymentMethod,
                receivedAmount: receivedAmount,
                changeAmount: changeAmount,
                cashierId: cashierId,
                status: status,
                updatedAt: updatedAt,
                syncState: syncState,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String storeId,
                required String clientMutationId,
                required DateTime occurredAt,
                required int totalAmount,
                required int grossProfitAmount,
                required String paymentMethod,
                required int receivedAmount,
                required int changeAmount,
                required String cashierId,
                required String status,
                required DateTime updatedAt,
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalesTransactionsCompanion.insert(
                id: id,
                storeId: storeId,
                clientMutationId: clientMutationId,
                occurredAt: occurredAt,
                totalAmount: totalAmount,
                grossProfitAmount: grossProfitAmount,
                paymentMethod: paymentMethod,
                receivedAmount: receivedAmount,
                changeAmount: changeAmount,
                cashierId: cashierId,
                status: status,
                updatedAt: updatedAt,
                syncState: syncState,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SalesTransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({transactionItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (transactionItemsRefs) db.transactionItems,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transactionItemsRefs)
                    await $_getPrefetchedData<
                      TransactionRow,
                      $SalesTransactionsTable,
                      TransactionItemRow
                    >(
                      currentTable: table,
                      referencedTable: $$SalesTransactionsTableReferences
                          ._transactionItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SalesTransactionsTableReferences(
                            db,
                            table,
                            p0,
                          ).transactionItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.transactionId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SalesTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SalesTransactionsTable,
      TransactionRow,
      $$SalesTransactionsTableFilterComposer,
      $$SalesTransactionsTableOrderingComposer,
      $$SalesTransactionsTableAnnotationComposer,
      $$SalesTransactionsTableCreateCompanionBuilder,
      $$SalesTransactionsTableUpdateCompanionBuilder,
      (TransactionRow, $$SalesTransactionsTableReferences),
      TransactionRow,
      PrefetchHooks Function({bool transactionItemsRefs})
    >;
typedef $$TransactionItemsTableCreateCompanionBuilder =
    TransactionItemsCompanion Function({
      required String transactionId,
      required String productId,
      required String productNameSnapshot,
      required int quantity,
      required int purchasePriceSnapshot,
      required int sellingPriceSnapshot,
      required int subtotalAmount,
      required int grossProfitAmount,
      Value<int> rowid,
    });
typedef $$TransactionItemsTableUpdateCompanionBuilder =
    TransactionItemsCompanion Function({
      Value<String> transactionId,
      Value<String> productId,
      Value<String> productNameSnapshot,
      Value<int> quantity,
      Value<int> purchasePriceSnapshot,
      Value<int> sellingPriceSnapshot,
      Value<int> subtotalAmount,
      Value<int> grossProfitAmount,
      Value<int> rowid,
    });

final class $$TransactionItemsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TransactionItemsTable,
          TransactionItemRow
        > {
  $$TransactionItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SalesTransactionsTable _transactionIdTable(_$AppDatabase db) =>
      db.salesTransactions.createAlias(
        $_aliasNameGenerator(
          db.transactionItems.transactionId,
          db.salesTransactions.id,
        ),
      );

  $$SalesTransactionsTableProcessedTableManager get transactionId {
    final $_column = $_itemColumn<String>('transaction_id')!;

    final manager = $$SalesTransactionsTableTableManager(
      $_db,
      $_db.salesTransactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransactionItemsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionItemsTable> {
  $$TransactionItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productNameSnapshot => $composableBuilder(
    column: $table.productNameSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get purchasePriceSnapshot => $composableBuilder(
    column: $table.purchasePriceSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sellingPriceSnapshot => $composableBuilder(
    column: $table.sellingPriceSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get subtotalAmount => $composableBuilder(
    column: $table.subtotalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get grossProfitAmount => $composableBuilder(
    column: $table.grossProfitAmount,
    builder: (column) => ColumnFilters(column),
  );

  $$SalesTransactionsTableFilterComposer get transactionId {
    final $$SalesTransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.salesTransactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTransactionsTableFilterComposer(
            $db: $db,
            $table: $db.salesTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionItemsTable> {
  $$TransactionItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productNameSnapshot => $composableBuilder(
    column: $table.productNameSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get purchasePriceSnapshot => $composableBuilder(
    column: $table.purchasePriceSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sellingPriceSnapshot => $composableBuilder(
    column: $table.sellingPriceSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get subtotalAmount => $composableBuilder(
    column: $table.subtotalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get grossProfitAmount => $composableBuilder(
    column: $table.grossProfitAmount,
    builder: (column) => ColumnOrderings(column),
  );

  $$SalesTransactionsTableOrderingComposer get transactionId {
    final $$SalesTransactionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.salesTransactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTransactionsTableOrderingComposer(
            $db: $db,
            $table: $db.salesTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionItemsTable> {
  $$TransactionItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get productNameSnapshot => $composableBuilder(
    column: $table.productNameSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get purchasePriceSnapshot => $composableBuilder(
    column: $table.purchasePriceSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sellingPriceSnapshot => $composableBuilder(
    column: $table.sellingPriceSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get subtotalAmount => $composableBuilder(
    column: $table.subtotalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get grossProfitAmount => $composableBuilder(
    column: $table.grossProfitAmount,
    builder: (column) => column,
  );

  $$SalesTransactionsTableAnnotationComposer get transactionId {
    final $$SalesTransactionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.transactionId,
          referencedTable: $db.salesTransactions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SalesTransactionsTableAnnotationComposer(
                $db: $db,
                $table: $db.salesTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$TransactionItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionItemsTable,
          TransactionItemRow,
          $$TransactionItemsTableFilterComposer,
          $$TransactionItemsTableOrderingComposer,
          $$TransactionItemsTableAnnotationComposer,
          $$TransactionItemsTableCreateCompanionBuilder,
          $$TransactionItemsTableUpdateCompanionBuilder,
          (TransactionItemRow, $$TransactionItemsTableReferences),
          TransactionItemRow,
          PrefetchHooks Function({bool transactionId})
        > {
  $$TransactionItemsTableTableManager(
    _$AppDatabase db,
    $TransactionItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> transactionId = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> productNameSnapshot = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<int> purchasePriceSnapshot = const Value.absent(),
                Value<int> sellingPriceSnapshot = const Value.absent(),
                Value<int> subtotalAmount = const Value.absent(),
                Value<int> grossProfitAmount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionItemsCompanion(
                transactionId: transactionId,
                productId: productId,
                productNameSnapshot: productNameSnapshot,
                quantity: quantity,
                purchasePriceSnapshot: purchasePriceSnapshot,
                sellingPriceSnapshot: sellingPriceSnapshot,
                subtotalAmount: subtotalAmount,
                grossProfitAmount: grossProfitAmount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String transactionId,
                required String productId,
                required String productNameSnapshot,
                required int quantity,
                required int purchasePriceSnapshot,
                required int sellingPriceSnapshot,
                required int subtotalAmount,
                required int grossProfitAmount,
                Value<int> rowid = const Value.absent(),
              }) => TransactionItemsCompanion.insert(
                transactionId: transactionId,
                productId: productId,
                productNameSnapshot: productNameSnapshot,
                quantity: quantity,
                purchasePriceSnapshot: purchasePriceSnapshot,
                sellingPriceSnapshot: sellingPriceSnapshot,
                subtotalAmount: subtotalAmount,
                grossProfitAmount: grossProfitAmount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransactionItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({transactionId = false}) {
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
                    if (transactionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.transactionId,
                                referencedTable:
                                    $$TransactionItemsTableReferences
                                        ._transactionIdTable(db),
                                referencedColumn:
                                    $$TransactionItemsTableReferences
                                        ._transactionIdTable(db)
                                        .id,
                              )
                              as T;
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

typedef $$TransactionItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionItemsTable,
      TransactionItemRow,
      $$TransactionItemsTableFilterComposer,
      $$TransactionItemsTableOrderingComposer,
      $$TransactionItemsTableAnnotationComposer,
      $$TransactionItemsTableCreateCompanionBuilder,
      $$TransactionItemsTableUpdateCompanionBuilder,
      (TransactionItemRow, $$TransactionItemsTableReferences),
      TransactionItemRow,
      PrefetchHooks Function({bool transactionId})
    >;
typedef $$PredictionsTableCreateCompanionBuilder =
    PredictionsCompanion Function({
      required String id,
      required String storeId,
      required DateTime capturedAt,
      Value<String?> aiLabel,
      Value<double?> confidence,
      Value<String?> selectedProductId,
      required bool corrected,
      Value<String?> correctionPhotoUri,
      Value<DateTime?> correctionPhotoExpiresAt,
      required String cashierId,
      required String modelVersion,
      Value<bool> consentToTraining,
      required DateTime updatedAt,
      Value<String> syncState,
      Value<int> rowid,
    });
typedef $$PredictionsTableUpdateCompanionBuilder =
    PredictionsCompanion Function({
      Value<String> id,
      Value<String> storeId,
      Value<DateTime> capturedAt,
      Value<String?> aiLabel,
      Value<double?> confidence,
      Value<String?> selectedProductId,
      Value<bool> corrected,
      Value<String?> correctionPhotoUri,
      Value<DateTime?> correctionPhotoExpiresAt,
      Value<String> cashierId,
      Value<String> modelVersion,
      Value<bool> consentToTraining,
      Value<DateTime> updatedAt,
      Value<String> syncState,
      Value<int> rowid,
    });

class $$PredictionsTableFilterComposer
    extends Composer<_$AppDatabase, $PredictionsTable> {
  $$PredictionsTableFilterComposer({
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

  ColumnFilters<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aiLabel => $composableBuilder(
    column: $table.aiLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selectedProductId => $composableBuilder(
    column: $table.selectedProductId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get corrected => $composableBuilder(
    column: $table.corrected,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get correctionPhotoUri => $composableBuilder(
    column: $table.correctionPhotoUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get correctionPhotoExpiresAt => $composableBuilder(
    column: $table.correctionPhotoExpiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cashierId => $composableBuilder(
    column: $table.cashierId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get consentToTraining => $composableBuilder(
    column: $table.consentToTraining,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PredictionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PredictionsTable> {
  $$PredictionsTableOrderingComposer({
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

  ColumnOrderings<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aiLabel => $composableBuilder(
    column: $table.aiLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedProductId => $composableBuilder(
    column: $table.selectedProductId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get corrected => $composableBuilder(
    column: $table.corrected,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get correctionPhotoUri => $composableBuilder(
    column: $table.correctionPhotoUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get correctionPhotoExpiresAt => $composableBuilder(
    column: $table.correctionPhotoExpiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cashierId => $composableBuilder(
    column: $table.cashierId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get consentToTraining => $composableBuilder(
    column: $table.consentToTraining,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PredictionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PredictionsTable> {
  $$PredictionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get aiLabel =>
      $composableBuilder(column: $table.aiLabel, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get selectedProductId => $composableBuilder(
    column: $table.selectedProductId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get corrected =>
      $composableBuilder(column: $table.corrected, builder: (column) => column);

  GeneratedColumn<String> get correctionPhotoUri => $composableBuilder(
    column: $table.correctionPhotoUri,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get correctionPhotoExpiresAt => $composableBuilder(
    column: $table.correctionPhotoExpiresAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cashierId =>
      $composableBuilder(column: $table.cashierId, builder: (column) => column);

  GeneratedColumn<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get consentToTraining => $composableBuilder(
    column: $table.consentToTraining,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);
}

class $$PredictionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PredictionsTable,
          PredictionRow,
          $$PredictionsTableFilterComposer,
          $$PredictionsTableOrderingComposer,
          $$PredictionsTableAnnotationComposer,
          $$PredictionsTableCreateCompanionBuilder,
          $$PredictionsTableUpdateCompanionBuilder,
          (
            PredictionRow,
            BaseReferences<_$AppDatabase, $PredictionsTable, PredictionRow>,
          ),
          PredictionRow,
          PrefetchHooks Function()
        > {
  $$PredictionsTableTableManager(_$AppDatabase db, $PredictionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PredictionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PredictionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PredictionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> storeId = const Value.absent(),
                Value<DateTime> capturedAt = const Value.absent(),
                Value<String?> aiLabel = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<String?> selectedProductId = const Value.absent(),
                Value<bool> corrected = const Value.absent(),
                Value<String?> correctionPhotoUri = const Value.absent(),
                Value<DateTime?> correctionPhotoExpiresAt =
                    const Value.absent(),
                Value<String> cashierId = const Value.absent(),
                Value<String> modelVersion = const Value.absent(),
                Value<bool> consentToTraining = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PredictionsCompanion(
                id: id,
                storeId: storeId,
                capturedAt: capturedAt,
                aiLabel: aiLabel,
                confidence: confidence,
                selectedProductId: selectedProductId,
                corrected: corrected,
                correctionPhotoUri: correctionPhotoUri,
                correctionPhotoExpiresAt: correctionPhotoExpiresAt,
                cashierId: cashierId,
                modelVersion: modelVersion,
                consentToTraining: consentToTraining,
                updatedAt: updatedAt,
                syncState: syncState,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String storeId,
                required DateTime capturedAt,
                Value<String?> aiLabel = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<String?> selectedProductId = const Value.absent(),
                required bool corrected,
                Value<String?> correctionPhotoUri = const Value.absent(),
                Value<DateTime?> correctionPhotoExpiresAt =
                    const Value.absent(),
                required String cashierId,
                required String modelVersion,
                Value<bool> consentToTraining = const Value.absent(),
                required DateTime updatedAt,
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PredictionsCompanion.insert(
                id: id,
                storeId: storeId,
                capturedAt: capturedAt,
                aiLabel: aiLabel,
                confidence: confidence,
                selectedProductId: selectedProductId,
                corrected: corrected,
                correctionPhotoUri: correctionPhotoUri,
                correctionPhotoExpiresAt: correctionPhotoExpiresAt,
                cashierId: cashierId,
                modelVersion: modelVersion,
                consentToTraining: consentToTraining,
                updatedAt: updatedAt,
                syncState: syncState,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PredictionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PredictionsTable,
      PredictionRow,
      $$PredictionsTableFilterComposer,
      $$PredictionsTableOrderingComposer,
      $$PredictionsTableAnnotationComposer,
      $$PredictionsTableCreateCompanionBuilder,
      $$PredictionsTableUpdateCompanionBuilder,
      (
        PredictionRow,
        BaseReferences<_$AppDatabase, $PredictionsTable, PredictionRow>,
      ),
      PredictionRow,
      PrefetchHooks Function()
    >;
typedef $$StoreLayoutsTableCreateCompanionBuilder =
    StoreLayoutsCompanion Function({
      required String id,
      required String storeId,
      required String name,
      required double canvasAspectRatio,
      Value<int> templateVersion,
      required DateTime updatedAt,
      Value<String> syncState,
      Value<int> rowid,
    });
typedef $$StoreLayoutsTableUpdateCompanionBuilder =
    StoreLayoutsCompanion Function({
      Value<String> id,
      Value<String> storeId,
      Value<String> name,
      Value<double> canvasAspectRatio,
      Value<int> templateVersion,
      Value<DateTime> updatedAt,
      Value<String> syncState,
      Value<int> rowid,
    });

final class $$StoreLayoutsTableReferences
    extends BaseReferences<_$AppDatabase, $StoreLayoutsTable, StoreLayoutRow> {
  $$StoreLayoutsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$StoreFixturesTable, List<StoreFixtureRow>>
  _storeFixturesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.storeFixtures,
    aliasName: $_aliasNameGenerator(
      db.storeLayouts.id,
      db.storeFixtures.layoutId,
    ),
  );

  $$StoreFixturesTableProcessedTableManager get storeFixturesRefs {
    final manager = $$StoreFixturesTableTableManager(
      $_db,
      $_db.storeFixtures,
    ).filter((f) => f.layoutId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_storeFixturesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StoreLayoutsTableFilterComposer
    extends Composer<_$AppDatabase, $StoreLayoutsTable> {
  $$StoreLayoutsTableFilterComposer({
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

  ColumnFilters<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get canvasAspectRatio => $composableBuilder(
    column: $table.canvasAspectRatio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get templateVersion => $composableBuilder(
    column: $table.templateVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> storeFixturesRefs(
    Expression<bool> Function($$StoreFixturesTableFilterComposer f) f,
  ) {
    final $$StoreFixturesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.storeFixtures,
      getReferencedColumn: (t) => t.layoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StoreFixturesTableFilterComposer(
            $db: $db,
            $table: $db.storeFixtures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StoreLayoutsTableOrderingComposer
    extends Composer<_$AppDatabase, $StoreLayoutsTable> {
  $$StoreLayoutsTableOrderingComposer({
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

  ColumnOrderings<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get canvasAspectRatio => $composableBuilder(
    column: $table.canvasAspectRatio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get templateVersion => $composableBuilder(
    column: $table.templateVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StoreLayoutsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StoreLayoutsTable> {
  $$StoreLayoutsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get canvasAspectRatio => $composableBuilder(
    column: $table.canvasAspectRatio,
    builder: (column) => column,
  );

  GeneratedColumn<int> get templateVersion => $composableBuilder(
    column: $table.templateVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  Expression<T> storeFixturesRefs<T extends Object>(
    Expression<T> Function($$StoreFixturesTableAnnotationComposer a) f,
  ) {
    final $$StoreFixturesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.storeFixtures,
      getReferencedColumn: (t) => t.layoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StoreFixturesTableAnnotationComposer(
            $db: $db,
            $table: $db.storeFixtures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StoreLayoutsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StoreLayoutsTable,
          StoreLayoutRow,
          $$StoreLayoutsTableFilterComposer,
          $$StoreLayoutsTableOrderingComposer,
          $$StoreLayoutsTableAnnotationComposer,
          $$StoreLayoutsTableCreateCompanionBuilder,
          $$StoreLayoutsTableUpdateCompanionBuilder,
          (StoreLayoutRow, $$StoreLayoutsTableReferences),
          StoreLayoutRow,
          PrefetchHooks Function({bool storeFixturesRefs})
        > {
  $$StoreLayoutsTableTableManager(_$AppDatabase db, $StoreLayoutsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StoreLayoutsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StoreLayoutsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StoreLayoutsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> storeId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> canvasAspectRatio = const Value.absent(),
                Value<int> templateVersion = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoreLayoutsCompanion(
                id: id,
                storeId: storeId,
                name: name,
                canvasAspectRatio: canvasAspectRatio,
                templateVersion: templateVersion,
                updatedAt: updatedAt,
                syncState: syncState,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String storeId,
                required String name,
                required double canvasAspectRatio,
                Value<int> templateVersion = const Value.absent(),
                required DateTime updatedAt,
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoreLayoutsCompanion.insert(
                id: id,
                storeId: storeId,
                name: name,
                canvasAspectRatio: canvasAspectRatio,
                templateVersion: templateVersion,
                updatedAt: updatedAt,
                syncState: syncState,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StoreLayoutsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({storeFixturesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (storeFixturesRefs) db.storeFixtures,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (storeFixturesRefs)
                    await $_getPrefetchedData<
                      StoreLayoutRow,
                      $StoreLayoutsTable,
                      StoreFixtureRow
                    >(
                      currentTable: table,
                      referencedTable: $$StoreLayoutsTableReferences
                          ._storeFixturesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$StoreLayoutsTableReferences(
                            db,
                            table,
                            p0,
                          ).storeFixturesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.layoutId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$StoreLayoutsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StoreLayoutsTable,
      StoreLayoutRow,
      $$StoreLayoutsTableFilterComposer,
      $$StoreLayoutsTableOrderingComposer,
      $$StoreLayoutsTableAnnotationComposer,
      $$StoreLayoutsTableCreateCompanionBuilder,
      $$StoreLayoutsTableUpdateCompanionBuilder,
      (StoreLayoutRow, $$StoreLayoutsTableReferences),
      StoreLayoutRow,
      PrefetchHooks Function({bool storeFixturesRefs})
    >;
typedef $$StoreFixturesTableCreateCompanionBuilder =
    StoreFixturesCompanion Function({
      required String id,
      required String layoutId,
      required String storeId,
      required String type,
      required String label,
      required double x,
      required double y,
      required double fixtureWidth,
      required double fixtureHeight,
      Value<int> rotationQuarterTurns,
      Value<String> productIdsJson,
      Value<String?> panoramaZoneId,
      required DateTime updatedAt,
      Value<String> syncState,
      Value<int> rowid,
    });
typedef $$StoreFixturesTableUpdateCompanionBuilder =
    StoreFixturesCompanion Function({
      Value<String> id,
      Value<String> layoutId,
      Value<String> storeId,
      Value<String> type,
      Value<String> label,
      Value<double> x,
      Value<double> y,
      Value<double> fixtureWidth,
      Value<double> fixtureHeight,
      Value<int> rotationQuarterTurns,
      Value<String> productIdsJson,
      Value<String?> panoramaZoneId,
      Value<DateTime> updatedAt,
      Value<String> syncState,
      Value<int> rowid,
    });

final class $$StoreFixturesTableReferences
    extends
        BaseReferences<_$AppDatabase, $StoreFixturesTable, StoreFixtureRow> {
  $$StoreFixturesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StoreLayoutsTable _layoutIdTable(_$AppDatabase db) =>
      db.storeLayouts.createAlias(
        $_aliasNameGenerator(db.storeFixtures.layoutId, db.storeLayouts.id),
      );

  $$StoreLayoutsTableProcessedTableManager get layoutId {
    final $_column = $_itemColumn<String>('layout_id')!;

    final manager = $$StoreLayoutsTableTableManager(
      $_db,
      $_db.storeLayouts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_layoutIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StoreFixturesTableFilterComposer
    extends Composer<_$AppDatabase, $StoreFixturesTable> {
  $$StoreFixturesTableFilterComposer({
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

  ColumnFilters<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get x => $composableBuilder(
    column: $table.x,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get y => $composableBuilder(
    column: $table.y,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fixtureWidth => $composableBuilder(
    column: $table.fixtureWidth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fixtureHeight => $composableBuilder(
    column: $table.fixtureHeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rotationQuarterTurns => $composableBuilder(
    column: $table.rotationQuarterTurns,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productIdsJson => $composableBuilder(
    column: $table.productIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get panoramaZoneId => $composableBuilder(
    column: $table.panoramaZoneId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  $$StoreLayoutsTableFilterComposer get layoutId {
    final $$StoreLayoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.layoutId,
      referencedTable: $db.storeLayouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StoreLayoutsTableFilterComposer(
            $db: $db,
            $table: $db.storeLayouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StoreFixturesTableOrderingComposer
    extends Composer<_$AppDatabase, $StoreFixturesTable> {
  $$StoreFixturesTableOrderingComposer({
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

  ColumnOrderings<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get x => $composableBuilder(
    column: $table.x,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get y => $composableBuilder(
    column: $table.y,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fixtureWidth => $composableBuilder(
    column: $table.fixtureWidth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fixtureHeight => $composableBuilder(
    column: $table.fixtureHeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rotationQuarterTurns => $composableBuilder(
    column: $table.rotationQuarterTurns,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productIdsJson => $composableBuilder(
    column: $table.productIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get panoramaZoneId => $composableBuilder(
    column: $table.panoramaZoneId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  $$StoreLayoutsTableOrderingComposer get layoutId {
    final $$StoreLayoutsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.layoutId,
      referencedTable: $db.storeLayouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StoreLayoutsTableOrderingComposer(
            $db: $db,
            $table: $db.storeLayouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StoreFixturesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StoreFixturesTable> {
  $$StoreFixturesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<double> get x =>
      $composableBuilder(column: $table.x, builder: (column) => column);

  GeneratedColumn<double> get y =>
      $composableBuilder(column: $table.y, builder: (column) => column);

  GeneratedColumn<double> get fixtureWidth => $composableBuilder(
    column: $table.fixtureWidth,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fixtureHeight => $composableBuilder(
    column: $table.fixtureHeight,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rotationQuarterTurns => $composableBuilder(
    column: $table.rotationQuarterTurns,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productIdsJson => $composableBuilder(
    column: $table.productIdsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get panoramaZoneId => $composableBuilder(
    column: $table.panoramaZoneId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  $$StoreLayoutsTableAnnotationComposer get layoutId {
    final $$StoreLayoutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.layoutId,
      referencedTable: $db.storeLayouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StoreLayoutsTableAnnotationComposer(
            $db: $db,
            $table: $db.storeLayouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StoreFixturesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StoreFixturesTable,
          StoreFixtureRow,
          $$StoreFixturesTableFilterComposer,
          $$StoreFixturesTableOrderingComposer,
          $$StoreFixturesTableAnnotationComposer,
          $$StoreFixturesTableCreateCompanionBuilder,
          $$StoreFixturesTableUpdateCompanionBuilder,
          (StoreFixtureRow, $$StoreFixturesTableReferences),
          StoreFixtureRow,
          PrefetchHooks Function({bool layoutId})
        > {
  $$StoreFixturesTableTableManager(_$AppDatabase db, $StoreFixturesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StoreFixturesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StoreFixturesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StoreFixturesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> layoutId = const Value.absent(),
                Value<String> storeId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<double> x = const Value.absent(),
                Value<double> y = const Value.absent(),
                Value<double> fixtureWidth = const Value.absent(),
                Value<double> fixtureHeight = const Value.absent(),
                Value<int> rotationQuarterTurns = const Value.absent(),
                Value<String> productIdsJson = const Value.absent(),
                Value<String?> panoramaZoneId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoreFixturesCompanion(
                id: id,
                layoutId: layoutId,
                storeId: storeId,
                type: type,
                label: label,
                x: x,
                y: y,
                fixtureWidth: fixtureWidth,
                fixtureHeight: fixtureHeight,
                rotationQuarterTurns: rotationQuarterTurns,
                productIdsJson: productIdsJson,
                panoramaZoneId: panoramaZoneId,
                updatedAt: updatedAt,
                syncState: syncState,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String layoutId,
                required String storeId,
                required String type,
                required String label,
                required double x,
                required double y,
                required double fixtureWidth,
                required double fixtureHeight,
                Value<int> rotationQuarterTurns = const Value.absent(),
                Value<String> productIdsJson = const Value.absent(),
                Value<String?> panoramaZoneId = const Value.absent(),
                required DateTime updatedAt,
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoreFixturesCompanion.insert(
                id: id,
                layoutId: layoutId,
                storeId: storeId,
                type: type,
                label: label,
                x: x,
                y: y,
                fixtureWidth: fixtureWidth,
                fixtureHeight: fixtureHeight,
                rotationQuarterTurns: rotationQuarterTurns,
                productIdsJson: productIdsJson,
                panoramaZoneId: panoramaZoneId,
                updatedAt: updatedAt,
                syncState: syncState,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StoreFixturesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({layoutId = false}) {
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
                    if (layoutId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.layoutId,
                                referencedTable: $$StoreFixturesTableReferences
                                    ._layoutIdTable(db),
                                referencedColumn: $$StoreFixturesTableReferences
                                    ._layoutIdTable(db)
                                    .id,
                              )
                              as T;
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

typedef $$StoreFixturesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StoreFixturesTable,
      StoreFixtureRow,
      $$StoreFixturesTableFilterComposer,
      $$StoreFixturesTableOrderingComposer,
      $$StoreFixturesTableAnnotationComposer,
      $$StoreFixturesTableCreateCompanionBuilder,
      $$StoreFixturesTableUpdateCompanionBuilder,
      (StoreFixtureRow, $$StoreFixturesTableReferences),
      StoreFixtureRow,
      PrefetchHooks Function({bool layoutId})
    >;
typedef $$SyncOutboxTableCreateCompanionBuilder =
    SyncOutboxCompanion Function({
      required String id,
      required String storeId,
      required String aggregateType,
      required String aggregateId,
      required String operation,
      required String payloadJson,
      required DateTime createdAt,
      Value<int> attemptCount,
      Value<DateTime?> nextAttemptAt,
      Value<String?> lastError,
      Value<int> rowid,
    });
typedef $$SyncOutboxTableUpdateCompanionBuilder =
    SyncOutboxCompanion Function({
      Value<String> id,
      Value<String> storeId,
      Value<String> aggregateType,
      Value<String> aggregateId,
      Value<String> operation,
      Value<String> payloadJson,
      Value<DateTime> createdAt,
      Value<int> attemptCount,
      Value<DateTime?> nextAttemptAt,
      Value<String?> lastError,
      Value<int> rowid,
    });

class $$SyncOutboxTableFilterComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableFilterComposer({
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

  ColumnFilters<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aggregateType => $composableBuilder(
    column: $table.aggregateType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aggregateId => $composableBuilder(
    column: $table.aggregateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncOutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableOrderingComposer({
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

  ColumnOrderings<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aggregateType => $composableBuilder(
    column: $table.aggregateType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aggregateId => $composableBuilder(
    column: $table.aggregateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncOutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<String> get aggregateType => $composableBuilder(
    column: $table.aggregateType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get aggregateId => $composableBuilder(
    column: $table.aggregateId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$SyncOutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncOutboxTable,
          SyncOutboxRow,
          $$SyncOutboxTableFilterComposer,
          $$SyncOutboxTableOrderingComposer,
          $$SyncOutboxTableAnnotationComposer,
          $$SyncOutboxTableCreateCompanionBuilder,
          $$SyncOutboxTableUpdateCompanionBuilder,
          (
            SyncOutboxRow,
            BaseReferences<_$AppDatabase, $SyncOutboxTable, SyncOutboxRow>,
          ),
          SyncOutboxRow,
          PrefetchHooks Function()
        > {
  $$SyncOutboxTableTableManager(_$AppDatabase db, $SyncOutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> storeId = const Value.absent(),
                Value<String> aggregateType = const Value.absent(),
                Value<String> aggregateId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxCompanion(
                id: id,
                storeId: storeId,
                aggregateType: aggregateType,
                aggregateId: aggregateId,
                operation: operation,
                payloadJson: payloadJson,
                createdAt: createdAt,
                attemptCount: attemptCount,
                nextAttemptAt: nextAttemptAt,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String storeId,
                required String aggregateType,
                required String aggregateId,
                required String operation,
                required String payloadJson,
                required DateTime createdAt,
                Value<int> attemptCount = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxCompanion.insert(
                id: id,
                storeId: storeId,
                aggregateType: aggregateType,
                aggregateId: aggregateId,
                operation: operation,
                payloadJson: payloadJson,
                createdAt: createdAt,
                attemptCount: attemptCount,
                nextAttemptAt: nextAttemptAt,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncOutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncOutboxTable,
      SyncOutboxRow,
      $$SyncOutboxTableFilterComposer,
      $$SyncOutboxTableOrderingComposer,
      $$SyncOutboxTableAnnotationComposer,
      $$SyncOutboxTableCreateCompanionBuilder,
      $$SyncOutboxTableUpdateCompanionBuilder,
      (
        SyncOutboxRow,
        BaseReferences<_$AppDatabase, $SyncOutboxTable, SyncOutboxRow>,
      ),
      SyncOutboxRow,
      PrefetchHooks Function()
    >;
typedef $$InventoryStockLedgerTableCreateCompanionBuilder =
    InventoryStockLedgerCompanion Function({
      required String id,
      required String storeId,
      required String productId,
      required String transactionId,
      required int delta,
      required String action,
      required String actorId,
      Value<String?> reason,
      required DateTime occurredAt,
      Value<int> rowid,
    });
typedef $$InventoryStockLedgerTableUpdateCompanionBuilder =
    InventoryStockLedgerCompanion Function({
      Value<String> id,
      Value<String> storeId,
      Value<String> productId,
      Value<String> transactionId,
      Value<int> delta,
      Value<String> action,
      Value<String> actorId,
      Value<String?> reason,
      Value<DateTime> occurredAt,
      Value<int> rowid,
    });

class $$InventoryStockLedgerTableFilterComposer
    extends Composer<_$AppDatabase, $InventoryStockLedgerTable> {
  $$InventoryStockLedgerTableFilterComposer({
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

  ColumnFilters<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get delta => $composableBuilder(
    column: $table.delta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InventoryStockLedgerTableOrderingComposer
    extends Composer<_$AppDatabase, $InventoryStockLedgerTable> {
  $$InventoryStockLedgerTableOrderingComposer({
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

  ColumnOrderings<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get delta => $composableBuilder(
    column: $table.delta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InventoryStockLedgerTableAnnotationComposer
    extends Composer<_$AppDatabase, $InventoryStockLedgerTable> {
  $$InventoryStockLedgerTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get delta =>
      $composableBuilder(column: $table.delta, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get actorId =>
      $composableBuilder(column: $table.actorId, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );
}

class $$InventoryStockLedgerTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InventoryStockLedgerTable,
          InventoryStockLedgerRow,
          $$InventoryStockLedgerTableFilterComposer,
          $$InventoryStockLedgerTableOrderingComposer,
          $$InventoryStockLedgerTableAnnotationComposer,
          $$InventoryStockLedgerTableCreateCompanionBuilder,
          $$InventoryStockLedgerTableUpdateCompanionBuilder,
          (
            InventoryStockLedgerRow,
            BaseReferences<
              _$AppDatabase,
              $InventoryStockLedgerTable,
              InventoryStockLedgerRow
            >,
          ),
          InventoryStockLedgerRow,
          PrefetchHooks Function()
        > {
  $$InventoryStockLedgerTableTableManager(
    _$AppDatabase db,
    $InventoryStockLedgerTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoryStockLedgerTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InventoryStockLedgerTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$InventoryStockLedgerTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> storeId = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> transactionId = const Value.absent(),
                Value<int> delta = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> actorId = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InventoryStockLedgerCompanion(
                id: id,
                storeId: storeId,
                productId: productId,
                transactionId: transactionId,
                delta: delta,
                action: action,
                actorId: actorId,
                reason: reason,
                occurredAt: occurredAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String storeId,
                required String productId,
                required String transactionId,
                required int delta,
                required String action,
                required String actorId,
                Value<String?> reason = const Value.absent(),
                required DateTime occurredAt,
                Value<int> rowid = const Value.absent(),
              }) => InventoryStockLedgerCompanion.insert(
                id: id,
                storeId: storeId,
                productId: productId,
                transactionId: transactionId,
                delta: delta,
                action: action,
                actorId: actorId,
                reason: reason,
                occurredAt: occurredAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InventoryStockLedgerTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InventoryStockLedgerTable,
      InventoryStockLedgerRow,
      $$InventoryStockLedgerTableFilterComposer,
      $$InventoryStockLedgerTableOrderingComposer,
      $$InventoryStockLedgerTableAnnotationComposer,
      $$InventoryStockLedgerTableCreateCompanionBuilder,
      $$InventoryStockLedgerTableUpdateCompanionBuilder,
      (
        InventoryStockLedgerRow,
        BaseReferences<
          _$AppDatabase,
          $InventoryStockLedgerTable,
          InventoryStockLedgerRow
        >,
      ),
      InventoryStockLedgerRow,
      PrefetchHooks Function()
    >;
typedef $$TransactionAuditsTableCreateCompanionBuilder =
    TransactionAuditsCompanion Function({
      required String id,
      required String storeId,
      required String transactionId,
      required String mutationId,
      required String action,
      required String actorId,
      required String reason,
      required DateTime occurredAt,
      Value<int> rowid,
    });
typedef $$TransactionAuditsTableUpdateCompanionBuilder =
    TransactionAuditsCompanion Function({
      Value<String> id,
      Value<String> storeId,
      Value<String> transactionId,
      Value<String> mutationId,
      Value<String> action,
      Value<String> actorId,
      Value<String> reason,
      Value<DateTime> occurredAt,
      Value<int> rowid,
    });

class $$TransactionAuditsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionAuditsTable> {
  $$TransactionAuditsTableFilterComposer({
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

  ColumnFilters<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionAuditsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionAuditsTable> {
  $$TransactionAuditsTableOrderingComposer({
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

  ColumnOrderings<String> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionAuditsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionAuditsTable> {
  $$TransactionAuditsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get actorId =>
      $composableBuilder(column: $table.actorId, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );
}

class $$TransactionAuditsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionAuditsTable,
          TransactionAuditRow,
          $$TransactionAuditsTableFilterComposer,
          $$TransactionAuditsTableOrderingComposer,
          $$TransactionAuditsTableAnnotationComposer,
          $$TransactionAuditsTableCreateCompanionBuilder,
          $$TransactionAuditsTableUpdateCompanionBuilder,
          (
            TransactionAuditRow,
            BaseReferences<
              _$AppDatabase,
              $TransactionAuditsTable,
              TransactionAuditRow
            >,
          ),
          TransactionAuditRow,
          PrefetchHooks Function()
        > {
  $$TransactionAuditsTableTableManager(
    _$AppDatabase db,
    $TransactionAuditsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionAuditsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionAuditsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionAuditsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> storeId = const Value.absent(),
                Value<String> transactionId = const Value.absent(),
                Value<String> mutationId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> actorId = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionAuditsCompanion(
                id: id,
                storeId: storeId,
                transactionId: transactionId,
                mutationId: mutationId,
                action: action,
                actorId: actorId,
                reason: reason,
                occurredAt: occurredAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String storeId,
                required String transactionId,
                required String mutationId,
                required String action,
                required String actorId,
                required String reason,
                required DateTime occurredAt,
                Value<int> rowid = const Value.absent(),
              }) => TransactionAuditsCompanion.insert(
                id: id,
                storeId: storeId,
                transactionId: transactionId,
                mutationId: mutationId,
                action: action,
                actorId: actorId,
                reason: reason,
                occurredAt: occurredAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionAuditsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionAuditsTable,
      TransactionAuditRow,
      $$TransactionAuditsTableFilterComposer,
      $$TransactionAuditsTableOrderingComposer,
      $$TransactionAuditsTableAnnotationComposer,
      $$TransactionAuditsTableCreateCompanionBuilder,
      $$TransactionAuditsTableUpdateCompanionBuilder,
      (
        TransactionAuditRow,
        BaseReferences<
          _$AppDatabase,
          $TransactionAuditsTable,
          TransactionAuditRow
        >,
      ),
      TransactionAuditRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$SalesTransactionsTableTableManager get salesTransactions =>
      $$SalesTransactionsTableTableManager(_db, _db.salesTransactions);
  $$TransactionItemsTableTableManager get transactionItems =>
      $$TransactionItemsTableTableManager(_db, _db.transactionItems);
  $$PredictionsTableTableManager get predictions =>
      $$PredictionsTableTableManager(_db, _db.predictions);
  $$StoreLayoutsTableTableManager get storeLayouts =>
      $$StoreLayoutsTableTableManager(_db, _db.storeLayouts);
  $$StoreFixturesTableTableManager get storeFixtures =>
      $$StoreFixturesTableTableManager(_db, _db.storeFixtures);
  $$SyncOutboxTableTableManager get syncOutbox =>
      $$SyncOutboxTableTableManager(_db, _db.syncOutbox);
  $$InventoryStockLedgerTableTableManager get inventoryStockLedger =>
      $$InventoryStockLedgerTableTableManager(_db, _db.inventoryStockLedger);
  $$TransactionAuditsTableTableManager get transactionAudits =>
      $$TransactionAuditsTableTableManager(_db, _db.transactionAudits);
}
