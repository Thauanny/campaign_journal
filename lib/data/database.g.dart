// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CampaignsTable extends Campaigns
    with TableInfo<$CampaignsTable, Campaign> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CampaignsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _systemMeta = const VerificationMeta('system');
  @override
  late final GeneratedColumn<String> system = GeneratedColumn<String>(
    'system',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('D&D 5e'),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _coverPathMeta = const VerificationMeta(
    'coverPath',
  );
  @override
  late final GeneratedColumn<String> coverPath = GeneratedColumn<String>(
    'cover_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pt-BR'),
  );
  static const VerificationMeta _playersMeta = const VerificationMeta(
    'players',
  );
  @override
  late final GeneratedColumn<String> players = GeneratedColumn<String>(
    'players',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
    name,
    system,
    description,
    coverPath,
    language,
    players,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'campaigns';
  @override
  VerificationContext validateIntegrity(
    Insertable<Campaign> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
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
    if (data.containsKey('system')) {
      context.handle(
        _systemMeta,
        system.isAcceptableOrUnknown(data['system']!, _systemMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('cover_path')) {
      context.handle(
        _coverPathMeta,
        coverPath.isAcceptableOrUnknown(data['cover_path']!, _coverPathMeta),
      );
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    if (data.containsKey('players')) {
      context.handle(
        _playersMeta,
        players.isAcceptableOrUnknown(data['players']!, _playersMeta),
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
  Campaign map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Campaign(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      system: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}system'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      coverPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_path'],
      ),
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      players: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}players'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CampaignsTable createAlias(String alias) {
    return $CampaignsTable(attachedDatabase, alias);
  }
}

class Campaign extends DataClass implements Insertable<Campaign> {
  final String id;
  final String name;
  final String system;
  final String description;
  final String? coverPath;
  final String language;
  final String players;
  final DateTime createdAt;
  const Campaign({
    required this.id,
    required this.name,
    required this.system,
    required this.description,
    this.coverPath,
    required this.language,
    required this.players,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['system'] = Variable<String>(system);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || coverPath != null) {
      map['cover_path'] = Variable<String>(coverPath);
    }
    map['language'] = Variable<String>(language);
    map['players'] = Variable<String>(players);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CampaignsCompanion toCompanion(bool nullToAbsent) {
    return CampaignsCompanion(
      id: Value(id),
      name: Value(name),
      system: Value(system),
      description: Value(description),
      coverPath: coverPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPath),
      language: Value(language),
      players: Value(players),
      createdAt: Value(createdAt),
    );
  }

  factory Campaign.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Campaign(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      system: serializer.fromJson<String>(json['system']),
      description: serializer.fromJson<String>(json['description']),
      coverPath: serializer.fromJson<String?>(json['coverPath']),
      language: serializer.fromJson<String>(json['language']),
      players: serializer.fromJson<String>(json['players']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'system': serializer.toJson<String>(system),
      'description': serializer.toJson<String>(description),
      'coverPath': serializer.toJson<String?>(coverPath),
      'language': serializer.toJson<String>(language),
      'players': serializer.toJson<String>(players),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Campaign copyWith({
    String? id,
    String? name,
    String? system,
    String? description,
    Value<String?> coverPath = const Value.absent(),
    String? language,
    String? players,
    DateTime? createdAt,
  }) => Campaign(
    id: id ?? this.id,
    name: name ?? this.name,
    system: system ?? this.system,
    description: description ?? this.description,
    coverPath: coverPath.present ? coverPath.value : this.coverPath,
    language: language ?? this.language,
    players: players ?? this.players,
    createdAt: createdAt ?? this.createdAt,
  );
  Campaign copyWithCompanion(CampaignsCompanion data) {
    return Campaign(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      system: data.system.present ? data.system.value : this.system,
      description: data.description.present
          ? data.description.value
          : this.description,
      coverPath: data.coverPath.present ? data.coverPath.value : this.coverPath,
      language: data.language.present ? data.language.value : this.language,
      players: data.players.present ? data.players.value : this.players,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Campaign(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('system: $system, ')
          ..write('description: $description, ')
          ..write('coverPath: $coverPath, ')
          ..write('language: $language, ')
          ..write('players: $players, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    system,
    description,
    coverPath,
    language,
    players,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Campaign &&
          other.id == this.id &&
          other.name == this.name &&
          other.system == this.system &&
          other.description == this.description &&
          other.coverPath == this.coverPath &&
          other.language == this.language &&
          other.players == this.players &&
          other.createdAt == this.createdAt);
}

class CampaignsCompanion extends UpdateCompanion<Campaign> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> system;
  final Value<String> description;
  final Value<String?> coverPath;
  final Value<String> language;
  final Value<String> players;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CampaignsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.system = const Value.absent(),
    this.description = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.language = const Value.absent(),
    this.players = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CampaignsCompanion.insert({
    required String id,
    required String name,
    this.system = const Value.absent(),
    this.description = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.language = const Value.absent(),
    this.players = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<Campaign> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? system,
    Expression<String>? description,
    Expression<String>? coverPath,
    Expression<String>? language,
    Expression<String>? players,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (system != null) 'system': system,
      if (description != null) 'description': description,
      if (coverPath != null) 'cover_path': coverPath,
      if (language != null) 'language': language,
      if (players != null) 'players': players,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CampaignsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? system,
    Value<String>? description,
    Value<String?>? coverPath,
    Value<String>? language,
    Value<String>? players,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CampaignsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      system: system ?? this.system,
      description: description ?? this.description,
      coverPath: coverPath ?? this.coverPath,
      language: language ?? this.language,
      players: players ?? this.players,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (system.present) {
      map['system'] = Variable<String>(system.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (coverPath.present) {
      map['cover_path'] = Variable<String>(coverPath.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (players.present) {
      map['players'] = Variable<String>(players.value);
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
    return (StringBuffer('CampaignsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('system: $system, ')
          ..write('description: $description, ')
          ..write('coverPath: $coverPath, ')
          ..write('language: $language, ')
          ..write('players: $players, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HeroesTable extends Heroes with TableInfo<$HeroesTable, Heroe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HeroesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _campaignIdMeta = const VerificationMeta(
    'campaignId',
  );
  @override
  late final GeneratedColumn<String> campaignId = GeneratedColumn<String>(
    'campaign_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES campaigns (id)',
    ),
  );
  static const VerificationMeta _playerMeta = const VerificationMeta('player');
  @override
  late final GeneratedColumn<String> player = GeneratedColumn<String>(
    'player',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
  static const VerificationMeta _heroClassMeta = const VerificationMeta(
    'heroClass',
  );
  @override
  late final GeneratedColumn<String> heroClass = GeneratedColumn<String>(
    'hero_class',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _raceMeta = const VerificationMeta('race');
  @override
  late final GeneratedColumn<String> race = GeneratedColumn<String>(
    'race',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _storyMeta = const VerificationMeta('story');
  @override
  late final GeneratedColumn<String> story = GeneratedColumn<String>(
    'story',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sheetPathMeta = const VerificationMeta(
    'sheetPath',
  );
  @override
  late final GeneratedColumn<String> sheetPath = GeneratedColumn<String>(
    'sheet_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _extraMeta = const VerificationMeta('extra');
  @override
  late final GeneratedColumn<String> extra = GeneratedColumn<String>(
    'extra',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _hpCurrentMeta = const VerificationMeta(
    'hpCurrent',
  );
  @override
  late final GeneratedColumn<int> hpCurrent = GeneratedColumn<int>(
    'hp_current',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hpMaxMeta = const VerificationMeta('hpMax');
  @override
  late final GeneratedColumn<int> hpMax = GeneratedColumn<int>(
    'hp_max',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _xpMeta = const VerificationMeta('xp');
  @override
  late final GeneratedColumn<int> xp = GeneratedColumn<int>(
    'xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    campaignId,
    player,
    name,
    heroClass,
    race,
    level,
    story,
    photoPath,
    notes,
    sheetPath,
    extra,
    hpCurrent,
    hpMax,
    xp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'heroes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Heroe> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('campaign_id')) {
      context.handle(
        _campaignIdMeta,
        campaignId.isAcceptableOrUnknown(data['campaign_id']!, _campaignIdMeta),
      );
    } else if (isInserting) {
      context.missing(_campaignIdMeta);
    }
    if (data.containsKey('player')) {
      context.handle(
        _playerMeta,
        player.isAcceptableOrUnknown(data['player']!, _playerMeta),
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
    if (data.containsKey('hero_class')) {
      context.handle(
        _heroClassMeta,
        heroClass.isAcceptableOrUnknown(data['hero_class']!, _heroClassMeta),
      );
    }
    if (data.containsKey('race')) {
      context.handle(
        _raceMeta,
        race.isAcceptableOrUnknown(data['race']!, _raceMeta),
      );
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('story')) {
      context.handle(
        _storyMeta,
        story.isAcceptableOrUnknown(data['story']!, _storyMeta),
      );
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('sheet_path')) {
      context.handle(
        _sheetPathMeta,
        sheetPath.isAcceptableOrUnknown(data['sheet_path']!, _sheetPathMeta),
      );
    }
    if (data.containsKey('extra')) {
      context.handle(
        _extraMeta,
        extra.isAcceptableOrUnknown(data['extra']!, _extraMeta),
      );
    }
    if (data.containsKey('hp_current')) {
      context.handle(
        _hpCurrentMeta,
        hpCurrent.isAcceptableOrUnknown(data['hp_current']!, _hpCurrentMeta),
      );
    }
    if (data.containsKey('hp_max')) {
      context.handle(
        _hpMaxMeta,
        hpMax.isAcceptableOrUnknown(data['hp_max']!, _hpMaxMeta),
      );
    }
    if (data.containsKey('xp')) {
      context.handle(_xpMeta, xp.isAcceptableOrUnknown(data['xp']!, _xpMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Heroe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Heroe(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      campaignId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}campaign_id'],
      )!,
      player: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}player'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      heroClass: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hero_class'],
      )!,
      race: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}race'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
      story: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}story'],
      )!,
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      sheetPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sheet_path'],
      ),
      extra: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extra'],
      )!,
      hpCurrent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hp_current'],
      ),
      hpMax: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hp_max'],
      ),
      xp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp'],
      )!,
    );
  }

  @override
  $HeroesTable createAlias(String alias) {
    return $HeroesTable(attachedDatabase, alias);
  }
}

class Heroe extends DataClass implements Insertable<Heroe> {
  final String id;
  final String campaignId;
  final String player;
  final String name;
  final String heroClass;
  final String race;
  final int level;
  final String story;
  final String? photoPath;
  final String notes;
  final String? sheetPath;

  /// JSON com atributos, vida, perícias etc. lidos da ficha.
  final String extra;

  /// Pontos de vida atuais / máximos (nulo = não cadastrado) e experiência.
  final int? hpCurrent;
  final int? hpMax;
  final int xp;
  const Heroe({
    required this.id,
    required this.campaignId,
    required this.player,
    required this.name,
    required this.heroClass,
    required this.race,
    required this.level,
    required this.story,
    this.photoPath,
    required this.notes,
    this.sheetPath,
    required this.extra,
    this.hpCurrent,
    this.hpMax,
    required this.xp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['campaign_id'] = Variable<String>(campaignId);
    map['player'] = Variable<String>(player);
    map['name'] = Variable<String>(name);
    map['hero_class'] = Variable<String>(heroClass);
    map['race'] = Variable<String>(race);
    map['level'] = Variable<int>(level);
    map['story'] = Variable<String>(story);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    map['notes'] = Variable<String>(notes);
    if (!nullToAbsent || sheetPath != null) {
      map['sheet_path'] = Variable<String>(sheetPath);
    }
    map['extra'] = Variable<String>(extra);
    if (!nullToAbsent || hpCurrent != null) {
      map['hp_current'] = Variable<int>(hpCurrent);
    }
    if (!nullToAbsent || hpMax != null) {
      map['hp_max'] = Variable<int>(hpMax);
    }
    map['xp'] = Variable<int>(xp);
    return map;
  }

  HeroesCompanion toCompanion(bool nullToAbsent) {
    return HeroesCompanion(
      id: Value(id),
      campaignId: Value(campaignId),
      player: Value(player),
      name: Value(name),
      heroClass: Value(heroClass),
      race: Value(race),
      level: Value(level),
      story: Value(story),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      notes: Value(notes),
      sheetPath: sheetPath == null && nullToAbsent
          ? const Value.absent()
          : Value(sheetPath),
      extra: Value(extra),
      hpCurrent: hpCurrent == null && nullToAbsent
          ? const Value.absent()
          : Value(hpCurrent),
      hpMax: hpMax == null && nullToAbsent
          ? const Value.absent()
          : Value(hpMax),
      xp: Value(xp),
    );
  }

  factory Heroe.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Heroe(
      id: serializer.fromJson<String>(json['id']),
      campaignId: serializer.fromJson<String>(json['campaignId']),
      player: serializer.fromJson<String>(json['player']),
      name: serializer.fromJson<String>(json['name']),
      heroClass: serializer.fromJson<String>(json['heroClass']),
      race: serializer.fromJson<String>(json['race']),
      level: serializer.fromJson<int>(json['level']),
      story: serializer.fromJson<String>(json['story']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      notes: serializer.fromJson<String>(json['notes']),
      sheetPath: serializer.fromJson<String?>(json['sheetPath']),
      extra: serializer.fromJson<String>(json['extra']),
      hpCurrent: serializer.fromJson<int?>(json['hpCurrent']),
      hpMax: serializer.fromJson<int?>(json['hpMax']),
      xp: serializer.fromJson<int>(json['xp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'campaignId': serializer.toJson<String>(campaignId),
      'player': serializer.toJson<String>(player),
      'name': serializer.toJson<String>(name),
      'heroClass': serializer.toJson<String>(heroClass),
      'race': serializer.toJson<String>(race),
      'level': serializer.toJson<int>(level),
      'story': serializer.toJson<String>(story),
      'photoPath': serializer.toJson<String?>(photoPath),
      'notes': serializer.toJson<String>(notes),
      'sheetPath': serializer.toJson<String?>(sheetPath),
      'extra': serializer.toJson<String>(extra),
      'hpCurrent': serializer.toJson<int?>(hpCurrent),
      'hpMax': serializer.toJson<int?>(hpMax),
      'xp': serializer.toJson<int>(xp),
    };
  }

  Heroe copyWith({
    String? id,
    String? campaignId,
    String? player,
    String? name,
    String? heroClass,
    String? race,
    int? level,
    String? story,
    Value<String?> photoPath = const Value.absent(),
    String? notes,
    Value<String?> sheetPath = const Value.absent(),
    String? extra,
    Value<int?> hpCurrent = const Value.absent(),
    Value<int?> hpMax = const Value.absent(),
    int? xp,
  }) => Heroe(
    id: id ?? this.id,
    campaignId: campaignId ?? this.campaignId,
    player: player ?? this.player,
    name: name ?? this.name,
    heroClass: heroClass ?? this.heroClass,
    race: race ?? this.race,
    level: level ?? this.level,
    story: story ?? this.story,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    notes: notes ?? this.notes,
    sheetPath: sheetPath.present ? sheetPath.value : this.sheetPath,
    extra: extra ?? this.extra,
    hpCurrent: hpCurrent.present ? hpCurrent.value : this.hpCurrent,
    hpMax: hpMax.present ? hpMax.value : this.hpMax,
    xp: xp ?? this.xp,
  );
  Heroe copyWithCompanion(HeroesCompanion data) {
    return Heroe(
      id: data.id.present ? data.id.value : this.id,
      campaignId: data.campaignId.present
          ? data.campaignId.value
          : this.campaignId,
      player: data.player.present ? data.player.value : this.player,
      name: data.name.present ? data.name.value : this.name,
      heroClass: data.heroClass.present ? data.heroClass.value : this.heroClass,
      race: data.race.present ? data.race.value : this.race,
      level: data.level.present ? data.level.value : this.level,
      story: data.story.present ? data.story.value : this.story,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      notes: data.notes.present ? data.notes.value : this.notes,
      sheetPath: data.sheetPath.present ? data.sheetPath.value : this.sheetPath,
      extra: data.extra.present ? data.extra.value : this.extra,
      hpCurrent: data.hpCurrent.present ? data.hpCurrent.value : this.hpCurrent,
      hpMax: data.hpMax.present ? data.hpMax.value : this.hpMax,
      xp: data.xp.present ? data.xp.value : this.xp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Heroe(')
          ..write('id: $id, ')
          ..write('campaignId: $campaignId, ')
          ..write('player: $player, ')
          ..write('name: $name, ')
          ..write('heroClass: $heroClass, ')
          ..write('race: $race, ')
          ..write('level: $level, ')
          ..write('story: $story, ')
          ..write('photoPath: $photoPath, ')
          ..write('notes: $notes, ')
          ..write('sheetPath: $sheetPath, ')
          ..write('extra: $extra, ')
          ..write('hpCurrent: $hpCurrent, ')
          ..write('hpMax: $hpMax, ')
          ..write('xp: $xp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    campaignId,
    player,
    name,
    heroClass,
    race,
    level,
    story,
    photoPath,
    notes,
    sheetPath,
    extra,
    hpCurrent,
    hpMax,
    xp,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Heroe &&
          other.id == this.id &&
          other.campaignId == this.campaignId &&
          other.player == this.player &&
          other.name == this.name &&
          other.heroClass == this.heroClass &&
          other.race == this.race &&
          other.level == this.level &&
          other.story == this.story &&
          other.photoPath == this.photoPath &&
          other.notes == this.notes &&
          other.sheetPath == this.sheetPath &&
          other.extra == this.extra &&
          other.hpCurrent == this.hpCurrent &&
          other.hpMax == this.hpMax &&
          other.xp == this.xp);
}

class HeroesCompanion extends UpdateCompanion<Heroe> {
  final Value<String> id;
  final Value<String> campaignId;
  final Value<String> player;
  final Value<String> name;
  final Value<String> heroClass;
  final Value<String> race;
  final Value<int> level;
  final Value<String> story;
  final Value<String?> photoPath;
  final Value<String> notes;
  final Value<String?> sheetPath;
  final Value<String> extra;
  final Value<int?> hpCurrent;
  final Value<int?> hpMax;
  final Value<int> xp;
  final Value<int> rowid;
  const HeroesCompanion({
    this.id = const Value.absent(),
    this.campaignId = const Value.absent(),
    this.player = const Value.absent(),
    this.name = const Value.absent(),
    this.heroClass = const Value.absent(),
    this.race = const Value.absent(),
    this.level = const Value.absent(),
    this.story = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.notes = const Value.absent(),
    this.sheetPath = const Value.absent(),
    this.extra = const Value.absent(),
    this.hpCurrent = const Value.absent(),
    this.hpMax = const Value.absent(),
    this.xp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HeroesCompanion.insert({
    required String id,
    required String campaignId,
    this.player = const Value.absent(),
    required String name,
    this.heroClass = const Value.absent(),
    this.race = const Value.absent(),
    this.level = const Value.absent(),
    this.story = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.notes = const Value.absent(),
    this.sheetPath = const Value.absent(),
    this.extra = const Value.absent(),
    this.hpCurrent = const Value.absent(),
    this.hpMax = const Value.absent(),
    this.xp = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       campaignId = Value(campaignId),
       name = Value(name);
  static Insertable<Heroe> custom({
    Expression<String>? id,
    Expression<String>? campaignId,
    Expression<String>? player,
    Expression<String>? name,
    Expression<String>? heroClass,
    Expression<String>? race,
    Expression<int>? level,
    Expression<String>? story,
    Expression<String>? photoPath,
    Expression<String>? notes,
    Expression<String>? sheetPath,
    Expression<String>? extra,
    Expression<int>? hpCurrent,
    Expression<int>? hpMax,
    Expression<int>? xp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (campaignId != null) 'campaign_id': campaignId,
      if (player != null) 'player': player,
      if (name != null) 'name': name,
      if (heroClass != null) 'hero_class': heroClass,
      if (race != null) 'race': race,
      if (level != null) 'level': level,
      if (story != null) 'story': story,
      if (photoPath != null) 'photo_path': photoPath,
      if (notes != null) 'notes': notes,
      if (sheetPath != null) 'sheet_path': sheetPath,
      if (extra != null) 'extra': extra,
      if (hpCurrent != null) 'hp_current': hpCurrent,
      if (hpMax != null) 'hp_max': hpMax,
      if (xp != null) 'xp': xp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HeroesCompanion copyWith({
    Value<String>? id,
    Value<String>? campaignId,
    Value<String>? player,
    Value<String>? name,
    Value<String>? heroClass,
    Value<String>? race,
    Value<int>? level,
    Value<String>? story,
    Value<String?>? photoPath,
    Value<String>? notes,
    Value<String?>? sheetPath,
    Value<String>? extra,
    Value<int?>? hpCurrent,
    Value<int?>? hpMax,
    Value<int>? xp,
    Value<int>? rowid,
  }) {
    return HeroesCompanion(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      player: player ?? this.player,
      name: name ?? this.name,
      heroClass: heroClass ?? this.heroClass,
      race: race ?? this.race,
      level: level ?? this.level,
      story: story ?? this.story,
      photoPath: photoPath ?? this.photoPath,
      notes: notes ?? this.notes,
      sheetPath: sheetPath ?? this.sheetPath,
      extra: extra ?? this.extra,
      hpCurrent: hpCurrent ?? this.hpCurrent,
      hpMax: hpMax ?? this.hpMax,
      xp: xp ?? this.xp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (campaignId.present) {
      map['campaign_id'] = Variable<String>(campaignId.value);
    }
    if (player.present) {
      map['player'] = Variable<String>(player.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (heroClass.present) {
      map['hero_class'] = Variable<String>(heroClass.value);
    }
    if (race.present) {
      map['race'] = Variable<String>(race.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (story.present) {
      map['story'] = Variable<String>(story.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (sheetPath.present) {
      map['sheet_path'] = Variable<String>(sheetPath.value);
    }
    if (extra.present) {
      map['extra'] = Variable<String>(extra.value);
    }
    if (hpCurrent.present) {
      map['hp_current'] = Variable<int>(hpCurrent.value);
    }
    if (hpMax.present) {
      map['hp_max'] = Variable<int>(hpMax.value);
    }
    if (xp.present) {
      map['xp'] = Variable<int>(xp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HeroesCompanion(')
          ..write('id: $id, ')
          ..write('campaignId: $campaignId, ')
          ..write('player: $player, ')
          ..write('name: $name, ')
          ..write('heroClass: $heroClass, ')
          ..write('race: $race, ')
          ..write('level: $level, ')
          ..write('story: $story, ')
          ..write('photoPath: $photoPath, ')
          ..write('notes: $notes, ')
          ..write('sheetPath: $sheetPath, ')
          ..write('extra: $extra, ')
          ..write('hpCurrent: $hpCurrent, ')
          ..write('hpMax: $hpMax, ')
          ..write('xp: $xp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _campaignIdMeta = const VerificationMeta(
    'campaignId',
  );
  @override
  late final GeneratedColumn<String> campaignId = GeneratedColumn<String>(
    'campaign_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES campaigns (id)',
    ),
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecMeta = const VerificationMeta(
    'durationSec',
  );
  @override
  late final GeneratedColumn<int> durationSec = GeneratedColumn<int>(
    'duration_sec',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('recorded'),
  );
  static const VerificationMeta _shortSummaryMeta = const VerificationMeta(
    'shortSummary',
  );
  @override
  late final GeneratedColumn<String> shortSummary = GeneratedColumn<String>(
    'short_summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _longSummaryMeta = const VerificationMeta(
    'longSummary',
  );
  @override
  late final GeneratedColumn<String> longSummary = GeneratedColumn<String>(
    'long_summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _previouslyOnMeta = const VerificationMeta(
    'previouslyOn',
  );
  @override
  late final GeneratedColumn<String> previouslyOn = GeneratedColumn<String>(
    'previously_on',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _processingModeMeta = const VerificationMeta(
    'processingMode',
  );
  @override
  late final GeneratedColumn<String> processingMode = GeneratedColumn<String>(
    'processing_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('free'),
  );
  static const VerificationMeta _bookmarksMeta = const VerificationMeta(
    'bookmarks',
  );
  @override
  late final GeneratedColumn<String> bookmarks = GeneratedColumn<String>(
    'bookmarks',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    campaignId,
    number,
    date,
    durationSec,
    status,
    shortSummary,
    longSummary,
    previouslyOn,
    processingMode,
    bookmarks,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('campaign_id')) {
      context.handle(
        _campaignIdMeta,
        campaignId.isAcceptableOrUnknown(data['campaign_id']!, _campaignIdMeta),
      );
    } else if (isInserting) {
      context.missing(_campaignIdMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('duration_sec')) {
      context.handle(
        _durationSecMeta,
        durationSec.isAcceptableOrUnknown(
          data['duration_sec']!,
          _durationSecMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('short_summary')) {
      context.handle(
        _shortSummaryMeta,
        shortSummary.isAcceptableOrUnknown(
          data['short_summary']!,
          _shortSummaryMeta,
        ),
      );
    }
    if (data.containsKey('long_summary')) {
      context.handle(
        _longSummaryMeta,
        longSummary.isAcceptableOrUnknown(
          data['long_summary']!,
          _longSummaryMeta,
        ),
      );
    }
    if (data.containsKey('previously_on')) {
      context.handle(
        _previouslyOnMeta,
        previouslyOn.isAcceptableOrUnknown(
          data['previously_on']!,
          _previouslyOnMeta,
        ),
      );
    }
    if (data.containsKey('processing_mode')) {
      context.handle(
        _processingModeMeta,
        processingMode.isAcceptableOrUnknown(
          data['processing_mode']!,
          _processingModeMeta,
        ),
      );
    }
    if (data.containsKey('bookmarks')) {
      context.handle(
        _bookmarksMeta,
        bookmarks.isAcceptableOrUnknown(data['bookmarks']!, _bookmarksMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      campaignId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}campaign_id'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      durationSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_sec'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      shortSummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}short_summary'],
      )!,
      longSummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}long_summary'],
      )!,
      previouslyOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}previously_on'],
      )!,
      processingMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}processing_mode'],
      )!,
      bookmarks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bookmarks'],
      )!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final String id;
  final String campaignId;
  final int number;
  final DateTime date;
  final int durationSec;

  /// recorded | processing | review | done
  final String status;
  final String shortSummary;
  final String longSummary;
  final String previouslyOn;
  final String processingMode;

  /// JSON com momentos marcados (segundos) durante a gravação.
  final String bookmarks;
  const Session({
    required this.id,
    required this.campaignId,
    required this.number,
    required this.date,
    required this.durationSec,
    required this.status,
    required this.shortSummary,
    required this.longSummary,
    required this.previouslyOn,
    required this.processingMode,
    required this.bookmarks,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['campaign_id'] = Variable<String>(campaignId);
    map['number'] = Variable<int>(number);
    map['date'] = Variable<DateTime>(date);
    map['duration_sec'] = Variable<int>(durationSec);
    map['status'] = Variable<String>(status);
    map['short_summary'] = Variable<String>(shortSummary);
    map['long_summary'] = Variable<String>(longSummary);
    map['previously_on'] = Variable<String>(previouslyOn);
    map['processing_mode'] = Variable<String>(processingMode);
    map['bookmarks'] = Variable<String>(bookmarks);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      campaignId: Value(campaignId),
      number: Value(number),
      date: Value(date),
      durationSec: Value(durationSec),
      status: Value(status),
      shortSummary: Value(shortSummary),
      longSummary: Value(longSummary),
      previouslyOn: Value(previouslyOn),
      processingMode: Value(processingMode),
      bookmarks: Value(bookmarks),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<String>(json['id']),
      campaignId: serializer.fromJson<String>(json['campaignId']),
      number: serializer.fromJson<int>(json['number']),
      date: serializer.fromJson<DateTime>(json['date']),
      durationSec: serializer.fromJson<int>(json['durationSec']),
      status: serializer.fromJson<String>(json['status']),
      shortSummary: serializer.fromJson<String>(json['shortSummary']),
      longSummary: serializer.fromJson<String>(json['longSummary']),
      previouslyOn: serializer.fromJson<String>(json['previouslyOn']),
      processingMode: serializer.fromJson<String>(json['processingMode']),
      bookmarks: serializer.fromJson<String>(json['bookmarks']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'campaignId': serializer.toJson<String>(campaignId),
      'number': serializer.toJson<int>(number),
      'date': serializer.toJson<DateTime>(date),
      'durationSec': serializer.toJson<int>(durationSec),
      'status': serializer.toJson<String>(status),
      'shortSummary': serializer.toJson<String>(shortSummary),
      'longSummary': serializer.toJson<String>(longSummary),
      'previouslyOn': serializer.toJson<String>(previouslyOn),
      'processingMode': serializer.toJson<String>(processingMode),
      'bookmarks': serializer.toJson<String>(bookmarks),
    };
  }

  Session copyWith({
    String? id,
    String? campaignId,
    int? number,
    DateTime? date,
    int? durationSec,
    String? status,
    String? shortSummary,
    String? longSummary,
    String? previouslyOn,
    String? processingMode,
    String? bookmarks,
  }) => Session(
    id: id ?? this.id,
    campaignId: campaignId ?? this.campaignId,
    number: number ?? this.number,
    date: date ?? this.date,
    durationSec: durationSec ?? this.durationSec,
    status: status ?? this.status,
    shortSummary: shortSummary ?? this.shortSummary,
    longSummary: longSummary ?? this.longSummary,
    previouslyOn: previouslyOn ?? this.previouslyOn,
    processingMode: processingMode ?? this.processingMode,
    bookmarks: bookmarks ?? this.bookmarks,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      campaignId: data.campaignId.present
          ? data.campaignId.value
          : this.campaignId,
      number: data.number.present ? data.number.value : this.number,
      date: data.date.present ? data.date.value : this.date,
      durationSec: data.durationSec.present
          ? data.durationSec.value
          : this.durationSec,
      status: data.status.present ? data.status.value : this.status,
      shortSummary: data.shortSummary.present
          ? data.shortSummary.value
          : this.shortSummary,
      longSummary: data.longSummary.present
          ? data.longSummary.value
          : this.longSummary,
      previouslyOn: data.previouslyOn.present
          ? data.previouslyOn.value
          : this.previouslyOn,
      processingMode: data.processingMode.present
          ? data.processingMode.value
          : this.processingMode,
      bookmarks: data.bookmarks.present ? data.bookmarks.value : this.bookmarks,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('campaignId: $campaignId, ')
          ..write('number: $number, ')
          ..write('date: $date, ')
          ..write('durationSec: $durationSec, ')
          ..write('status: $status, ')
          ..write('shortSummary: $shortSummary, ')
          ..write('longSummary: $longSummary, ')
          ..write('previouslyOn: $previouslyOn, ')
          ..write('processingMode: $processingMode, ')
          ..write('bookmarks: $bookmarks')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    campaignId,
    number,
    date,
    durationSec,
    status,
    shortSummary,
    longSummary,
    previouslyOn,
    processingMode,
    bookmarks,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.campaignId == this.campaignId &&
          other.number == this.number &&
          other.date == this.date &&
          other.durationSec == this.durationSec &&
          other.status == this.status &&
          other.shortSummary == this.shortSummary &&
          other.longSummary == this.longSummary &&
          other.previouslyOn == this.previouslyOn &&
          other.processingMode == this.processingMode &&
          other.bookmarks == this.bookmarks);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<String> id;
  final Value<String> campaignId;
  final Value<int> number;
  final Value<DateTime> date;
  final Value<int> durationSec;
  final Value<String> status;
  final Value<String> shortSummary;
  final Value<String> longSummary;
  final Value<String> previouslyOn;
  final Value<String> processingMode;
  final Value<String> bookmarks;
  final Value<int> rowid;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.campaignId = const Value.absent(),
    this.number = const Value.absent(),
    this.date = const Value.absent(),
    this.durationSec = const Value.absent(),
    this.status = const Value.absent(),
    this.shortSummary = const Value.absent(),
    this.longSummary = const Value.absent(),
    this.previouslyOn = const Value.absent(),
    this.processingMode = const Value.absent(),
    this.bookmarks = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsCompanion.insert({
    required String id,
    required String campaignId,
    required int number,
    required DateTime date,
    this.durationSec = const Value.absent(),
    this.status = const Value.absent(),
    this.shortSummary = const Value.absent(),
    this.longSummary = const Value.absent(),
    this.previouslyOn = const Value.absent(),
    this.processingMode = const Value.absent(),
    this.bookmarks = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       campaignId = Value(campaignId),
       number = Value(number),
       date = Value(date);
  static Insertable<Session> custom({
    Expression<String>? id,
    Expression<String>? campaignId,
    Expression<int>? number,
    Expression<DateTime>? date,
    Expression<int>? durationSec,
    Expression<String>? status,
    Expression<String>? shortSummary,
    Expression<String>? longSummary,
    Expression<String>? previouslyOn,
    Expression<String>? processingMode,
    Expression<String>? bookmarks,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (campaignId != null) 'campaign_id': campaignId,
      if (number != null) 'number': number,
      if (date != null) 'date': date,
      if (durationSec != null) 'duration_sec': durationSec,
      if (status != null) 'status': status,
      if (shortSummary != null) 'short_summary': shortSummary,
      if (longSummary != null) 'long_summary': longSummary,
      if (previouslyOn != null) 'previously_on': previouslyOn,
      if (processingMode != null) 'processing_mode': processingMode,
      if (bookmarks != null) 'bookmarks': bookmarks,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? campaignId,
    Value<int>? number,
    Value<DateTime>? date,
    Value<int>? durationSec,
    Value<String>? status,
    Value<String>? shortSummary,
    Value<String>? longSummary,
    Value<String>? previouslyOn,
    Value<String>? processingMode,
    Value<String>? bookmarks,
    Value<int>? rowid,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      number: number ?? this.number,
      date: date ?? this.date,
      durationSec: durationSec ?? this.durationSec,
      status: status ?? this.status,
      shortSummary: shortSummary ?? this.shortSummary,
      longSummary: longSummary ?? this.longSummary,
      previouslyOn: previouslyOn ?? this.previouslyOn,
      processingMode: processingMode ?? this.processingMode,
      bookmarks: bookmarks ?? this.bookmarks,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (campaignId.present) {
      map['campaign_id'] = Variable<String>(campaignId.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (durationSec.present) {
      map['duration_sec'] = Variable<int>(durationSec.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (shortSummary.present) {
      map['short_summary'] = Variable<String>(shortSummary.value);
    }
    if (longSummary.present) {
      map['long_summary'] = Variable<String>(longSummary.value);
    }
    if (previouslyOn.present) {
      map['previously_on'] = Variable<String>(previouslyOn.value);
    }
    if (processingMode.present) {
      map['processing_mode'] = Variable<String>(processingMode.value);
    }
    if (bookmarks.present) {
      map['bookmarks'] = Variable<String>(bookmarks.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('campaignId: $campaignId, ')
          ..write('number: $number, ')
          ..write('date: $date, ')
          ..write('durationSec: $durationSec, ')
          ..write('status: $status, ')
          ..write('shortSummary: $shortSummary, ')
          ..write('longSummary: $longSummary, ')
          ..write('previouslyOn: $previouslyOn, ')
          ..write('processingMode: $processingMode, ')
          ..write('bookmarks: $bookmarks, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AudiosTable extends Audios with TableInfo<$AudiosTable, Audio> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudiosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id)',
    ),
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ordMeta = const VerificationMeta('ord');
  @override
  late final GeneratedColumn<int> ord = GeneratedColumn<int>(
    'ord',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecMeta = const VerificationMeta(
    'durationSec',
  );
  @override
  late final GeneratedColumn<int> durationSec = GeneratedColumn<int>(
    'duration_sec',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('recorded'),
  );
  static const VerificationMeta _speakerMeta = const VerificationMeta(
    'speaker',
  );
  @override
  late final GeneratedColumn<String> speaker = GeneratedColumn<String>(
    'speaker',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transcribedMeta = const VerificationMeta(
    'transcribed',
  );
  @override
  late final GeneratedColumn<bool> transcribed = GeneratedColumn<bool>(
    'transcribed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("transcribed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    filePath,
    ord,
    durationSec,
    origin,
    speaker,
    transcribed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audios';
  @override
  VerificationContext validateIntegrity(
    Insertable<Audio> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('ord')) {
      context.handle(
        _ordMeta,
        ord.isAcceptableOrUnknown(data['ord']!, _ordMeta),
      );
    } else if (isInserting) {
      context.missing(_ordMeta);
    }
    if (data.containsKey('duration_sec')) {
      context.handle(
        _durationSecMeta,
        durationSec.isAcceptableOrUnknown(
          data['duration_sec']!,
          _durationSecMeta,
        ),
      );
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    }
    if (data.containsKey('speaker')) {
      context.handle(
        _speakerMeta,
        speaker.isAcceptableOrUnknown(data['speaker']!, _speakerMeta),
      );
    }
    if (data.containsKey('transcribed')) {
      context.handle(
        _transcribedMeta,
        transcribed.isAcceptableOrUnknown(
          data['transcribed']!,
          _transcribedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Audio map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Audio(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      ord: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ord'],
      )!,
      durationSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_sec'],
      )!,
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      speaker: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}speaker'],
      ),
      transcribed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}transcribed'],
      )!,
    );
  }

  @override
  $AudiosTable createAlias(String alias) {
    return $AudiosTable(attachedDatabase, alias);
  }
}

class Audio extends DataClass implements Insertable<Audio> {
  final String id;
  final String sessionId;
  final String filePath;
  final int ord;
  final int durationSec;

  /// recorded | imported
  final String origin;

  /// Para trilhas por pessoa (Craig): nome do falante.
  final String? speaker;
  final bool transcribed;
  const Audio({
    required this.id,
    required this.sessionId,
    required this.filePath,
    required this.ord,
    required this.durationSec,
    required this.origin,
    this.speaker,
    required this.transcribed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['file_path'] = Variable<String>(filePath);
    map['ord'] = Variable<int>(ord);
    map['duration_sec'] = Variable<int>(durationSec);
    map['origin'] = Variable<String>(origin);
    if (!nullToAbsent || speaker != null) {
      map['speaker'] = Variable<String>(speaker);
    }
    map['transcribed'] = Variable<bool>(transcribed);
    return map;
  }

  AudiosCompanion toCompanion(bool nullToAbsent) {
    return AudiosCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      filePath: Value(filePath),
      ord: Value(ord),
      durationSec: Value(durationSec),
      origin: Value(origin),
      speaker: speaker == null && nullToAbsent
          ? const Value.absent()
          : Value(speaker),
      transcribed: Value(transcribed),
    );
  }

  factory Audio.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Audio(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      filePath: serializer.fromJson<String>(json['filePath']),
      ord: serializer.fromJson<int>(json['ord']),
      durationSec: serializer.fromJson<int>(json['durationSec']),
      origin: serializer.fromJson<String>(json['origin']),
      speaker: serializer.fromJson<String?>(json['speaker']),
      transcribed: serializer.fromJson<bool>(json['transcribed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'filePath': serializer.toJson<String>(filePath),
      'ord': serializer.toJson<int>(ord),
      'durationSec': serializer.toJson<int>(durationSec),
      'origin': serializer.toJson<String>(origin),
      'speaker': serializer.toJson<String?>(speaker),
      'transcribed': serializer.toJson<bool>(transcribed),
    };
  }

  Audio copyWith({
    String? id,
    String? sessionId,
    String? filePath,
    int? ord,
    int? durationSec,
    String? origin,
    Value<String?> speaker = const Value.absent(),
    bool? transcribed,
  }) => Audio(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    filePath: filePath ?? this.filePath,
    ord: ord ?? this.ord,
    durationSec: durationSec ?? this.durationSec,
    origin: origin ?? this.origin,
    speaker: speaker.present ? speaker.value : this.speaker,
    transcribed: transcribed ?? this.transcribed,
  );
  Audio copyWithCompanion(AudiosCompanion data) {
    return Audio(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      ord: data.ord.present ? data.ord.value : this.ord,
      durationSec: data.durationSec.present
          ? data.durationSec.value
          : this.durationSec,
      origin: data.origin.present ? data.origin.value : this.origin,
      speaker: data.speaker.present ? data.speaker.value : this.speaker,
      transcribed: data.transcribed.present
          ? data.transcribed.value
          : this.transcribed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Audio(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('filePath: $filePath, ')
          ..write('ord: $ord, ')
          ..write('durationSec: $durationSec, ')
          ..write('origin: $origin, ')
          ..write('speaker: $speaker, ')
          ..write('transcribed: $transcribed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    filePath,
    ord,
    durationSec,
    origin,
    speaker,
    transcribed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Audio &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.filePath == this.filePath &&
          other.ord == this.ord &&
          other.durationSec == this.durationSec &&
          other.origin == this.origin &&
          other.speaker == this.speaker &&
          other.transcribed == this.transcribed);
}

class AudiosCompanion extends UpdateCompanion<Audio> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> filePath;
  final Value<int> ord;
  final Value<int> durationSec;
  final Value<String> origin;
  final Value<String?> speaker;
  final Value<bool> transcribed;
  final Value<int> rowid;
  const AudiosCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.filePath = const Value.absent(),
    this.ord = const Value.absent(),
    this.durationSec = const Value.absent(),
    this.origin = const Value.absent(),
    this.speaker = const Value.absent(),
    this.transcribed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AudiosCompanion.insert({
    required String id,
    required String sessionId,
    required String filePath,
    required int ord,
    this.durationSec = const Value.absent(),
    this.origin = const Value.absent(),
    this.speaker = const Value.absent(),
    this.transcribed = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       filePath = Value(filePath),
       ord = Value(ord);
  static Insertable<Audio> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? filePath,
    Expression<int>? ord,
    Expression<int>? durationSec,
    Expression<String>? origin,
    Expression<String>? speaker,
    Expression<bool>? transcribed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (filePath != null) 'file_path': filePath,
      if (ord != null) 'ord': ord,
      if (durationSec != null) 'duration_sec': durationSec,
      if (origin != null) 'origin': origin,
      if (speaker != null) 'speaker': speaker,
      if (transcribed != null) 'transcribed': transcribed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AudiosCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? filePath,
    Value<int>? ord,
    Value<int>? durationSec,
    Value<String>? origin,
    Value<String?>? speaker,
    Value<bool>? transcribed,
    Value<int>? rowid,
  }) {
    return AudiosCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      filePath: filePath ?? this.filePath,
      ord: ord ?? this.ord,
      durationSec: durationSec ?? this.durationSec,
      origin: origin ?? this.origin,
      speaker: speaker ?? this.speaker,
      transcribed: transcribed ?? this.transcribed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (ord.present) {
      map['ord'] = Variable<int>(ord.value);
    }
    if (durationSec.present) {
      map['duration_sec'] = Variable<int>(durationSec.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (speaker.present) {
      map['speaker'] = Variable<String>(speaker.value);
    }
    if (transcribed.present) {
      map['transcribed'] = Variable<bool>(transcribed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudiosCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('filePath: $filePath, ')
          ..write('ord: $ord, ')
          ..write('durationSec: $durationSec, ')
          ..write('origin: $origin, ')
          ..write('speaker: $speaker, ')
          ..write('transcribed: $transcribed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SegmentsTable extends Segments with TableInfo<$SegmentsTable, Segment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SegmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id)',
    ),
  );
  static const VerificationMeta _startMsMeta = const VerificationMeta(
    'startMs',
  );
  @override
  late final GeneratedColumn<int> startMs = GeneratedColumn<int>(
    'start_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMsMeta = const VerificationMeta('endMs');
  @override
  late final GeneratedColumn<int> endMs = GeneratedColumn<int>(
    'end_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _text_Meta = const VerificationMeta('text_');
  @override
  late final GeneratedColumn<String> text_ = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speakerMeta = const VerificationMeta(
    'speaker',
  );
  @override
  late final GeneratedColumn<String> speaker = GeneratedColumn<String>(
    'speaker',
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
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    startMs,
    endMs,
    text_,
    speaker,
    confidence,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'segments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Segment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('start_ms')) {
      context.handle(
        _startMsMeta,
        startMs.isAcceptableOrUnknown(data['start_ms']!, _startMsMeta),
      );
    } else if (isInserting) {
      context.missing(_startMsMeta);
    }
    if (data.containsKey('end_ms')) {
      context.handle(
        _endMsMeta,
        endMs.isAcceptableOrUnknown(data['end_ms']!, _endMsMeta),
      );
    } else if (isInserting) {
      context.missing(_endMsMeta);
    }
    if (data.containsKey('text')) {
      context.handle(
        _text_Meta,
        text_.isAcceptableOrUnknown(data['text']!, _text_Meta),
      );
    } else if (isInserting) {
      context.missing(_text_Meta);
    }
    if (data.containsKey('speaker')) {
      context.handle(
        _speakerMeta,
        speaker.isAcceptableOrUnknown(data['speaker']!, _speakerMeta),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Segment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Segment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      startMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_ms'],
      )!,
      endMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_ms'],
      )!,
      text_: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
      speaker: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}speaker'],
      ),
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
    );
  }

  @override
  $SegmentsTable createAlias(String alias) {
    return $SegmentsTable(attachedDatabase, alias);
  }
}

class Segment extends DataClass implements Insertable<Segment> {
  final String id;
  final String sessionId;
  final int startMs;
  final int endMs;
  final String text_;
  final String? speaker;
  final double confidence;
  const Segment({
    required this.id,
    required this.sessionId,
    required this.startMs,
    required this.endMs,
    required this.text_,
    this.speaker,
    required this.confidence,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['start_ms'] = Variable<int>(startMs);
    map['end_ms'] = Variable<int>(endMs);
    map['text'] = Variable<String>(text_);
    if (!nullToAbsent || speaker != null) {
      map['speaker'] = Variable<String>(speaker);
    }
    map['confidence'] = Variable<double>(confidence);
    return map;
  }

  SegmentsCompanion toCompanion(bool nullToAbsent) {
    return SegmentsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      startMs: Value(startMs),
      endMs: Value(endMs),
      text_: Value(text_),
      speaker: speaker == null && nullToAbsent
          ? const Value.absent()
          : Value(speaker),
      confidence: Value(confidence),
    );
  }

  factory Segment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Segment(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      startMs: serializer.fromJson<int>(json['startMs']),
      endMs: serializer.fromJson<int>(json['endMs']),
      text_: serializer.fromJson<String>(json['text_']),
      speaker: serializer.fromJson<String?>(json['speaker']),
      confidence: serializer.fromJson<double>(json['confidence']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'startMs': serializer.toJson<int>(startMs),
      'endMs': serializer.toJson<int>(endMs),
      'text_': serializer.toJson<String>(text_),
      'speaker': serializer.toJson<String?>(speaker),
      'confidence': serializer.toJson<double>(confidence),
    };
  }

  Segment copyWith({
    String? id,
    String? sessionId,
    int? startMs,
    int? endMs,
    String? text_,
    Value<String?> speaker = const Value.absent(),
    double? confidence,
  }) => Segment(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    startMs: startMs ?? this.startMs,
    endMs: endMs ?? this.endMs,
    text_: text_ ?? this.text_,
    speaker: speaker.present ? speaker.value : this.speaker,
    confidence: confidence ?? this.confidence,
  );
  Segment copyWithCompanion(SegmentsCompanion data) {
    return Segment(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      startMs: data.startMs.present ? data.startMs.value : this.startMs,
      endMs: data.endMs.present ? data.endMs.value : this.endMs,
      text_: data.text_.present ? data.text_.value : this.text_,
      speaker: data.speaker.present ? data.speaker.value : this.speaker,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Segment(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('startMs: $startMs, ')
          ..write('endMs: $endMs, ')
          ..write('text_: $text_, ')
          ..write('speaker: $speaker, ')
          ..write('confidence: $confidence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sessionId, startMs, endMs, text_, speaker, confidence);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Segment &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.startMs == this.startMs &&
          other.endMs == this.endMs &&
          other.text_ == this.text_ &&
          other.speaker == this.speaker &&
          other.confidence == this.confidence);
}

class SegmentsCompanion extends UpdateCompanion<Segment> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<int> startMs;
  final Value<int> endMs;
  final Value<String> text_;
  final Value<String?> speaker;
  final Value<double> confidence;
  final Value<int> rowid;
  const SegmentsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.startMs = const Value.absent(),
    this.endMs = const Value.absent(),
    this.text_ = const Value.absent(),
    this.speaker = const Value.absent(),
    this.confidence = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SegmentsCompanion.insert({
    required String id,
    required String sessionId,
    required int startMs,
    required int endMs,
    required String text_,
    this.speaker = const Value.absent(),
    this.confidence = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       startMs = Value(startMs),
       endMs = Value(endMs),
       text_ = Value(text_);
  static Insertable<Segment> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<int>? startMs,
    Expression<int>? endMs,
    Expression<String>? text_,
    Expression<String>? speaker,
    Expression<double>? confidence,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (startMs != null) 'start_ms': startMs,
      if (endMs != null) 'end_ms': endMs,
      if (text_ != null) 'text': text_,
      if (speaker != null) 'speaker': speaker,
      if (confidence != null) 'confidence': confidence,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SegmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<int>? startMs,
    Value<int>? endMs,
    Value<String>? text_,
    Value<String?>? speaker,
    Value<double>? confidence,
    Value<int>? rowid,
  }) {
    return SegmentsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      startMs: startMs ?? this.startMs,
      endMs: endMs ?? this.endMs,
      text_: text_ ?? this.text_,
      speaker: speaker ?? this.speaker,
      confidence: confidence ?? this.confidence,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (startMs.present) {
      map['start_ms'] = Variable<int>(startMs.value);
    }
    if (endMs.present) {
      map['end_ms'] = Variable<int>(endMs.value);
    }
    if (text_.present) {
      map['text'] = Variable<String>(text_.value);
    }
    if (speaker.present) {
      map['speaker'] = Variable<String>(speaker.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SegmentsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('startMs: $startMs, ')
          ..write('endMs: $endMs, ')
          ..write('text_: $text_, ')
          ..write('speaker: $speaker, ')
          ..write('confidence: $confidence, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EntitiesTable extends Entities with TableInfo<$EntitiesTable, Entity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _campaignIdMeta = const VerificationMeta(
    'campaignId',
  );
  @override
  late final GeneratedColumn<String> campaignId = GeneratedColumn<String>(
    'campaign_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES campaigns (id)',
    ),
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aliasesMeta = const VerificationMeta(
    'aliases',
  );
  @override
  late final GeneratedColumn<String> aliases = GeneratedColumn<String>(
    'aliases',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _attrMeta = const VerificationMeta('attr');
  @override
  late final GeneratedColumn<String> attr = GeneratedColumn<String>(
    'attr',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _giverMeta = const VerificationMeta('giver');
  @override
  late final GeneratedColumn<String> giver = GeneratedColumn<String>(
    'giver',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _rewardMeta = const VerificationMeta('reward');
  @override
  late final GeneratedColumn<String> reward = GeneratedColumn<String>(
    'reward',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _reviewMeta = const VerificationMeta('review');
  @override
  late final GeneratedColumn<String> review = GeneratedColumn<String>(
    'review',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('suggested'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    campaignId,
    kind,
    name,
    aliases,
    description,
    status,
    attr,
    parentId,
    ownerId,
    giver,
    reward,
    review,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entities';
  @override
  VerificationContext validateIntegrity(
    Insertable<Entity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('campaign_id')) {
      context.handle(
        _campaignIdMeta,
        campaignId.isAcceptableOrUnknown(data['campaign_id']!, _campaignIdMeta),
      );
    } else if (isInserting) {
      context.missing(_campaignIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('aliases')) {
      context.handle(
        _aliasesMeta,
        aliases.isAcceptableOrUnknown(data['aliases']!, _aliasesMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('attr')) {
      context.handle(
        _attrMeta,
        attr.isAcceptableOrUnknown(data['attr']!, _attrMeta),
      );
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('giver')) {
      context.handle(
        _giverMeta,
        giver.isAcceptableOrUnknown(data['giver']!, _giverMeta),
      );
    }
    if (data.containsKey('reward')) {
      context.handle(
        _rewardMeta,
        reward.isAcceptableOrUnknown(data['reward']!, _rewardMeta),
      );
    }
    if (data.containsKey('review')) {
      context.handle(
        _reviewMeta,
        review.isAcceptableOrUnknown(data['review']!, _reviewMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Entity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Entity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      campaignId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}campaign_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      aliases: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aliases'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      attr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attr'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      ),
      giver: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}giver'],
      )!,
      reward: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reward'],
      )!,
      review: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review'],
      )!,
    );
  }

  @override
  $EntitiesTable createAlias(String alias) {
    return $EntitiesTable(attachedDatabase, alias);
  }
}

class Entity extends DataClass implements Insertable<Entity> {
  final String id;
  final String campaignId;

  /// npc | location | quest | item | faction
  final String kind;
  final String name;
  final String aliases;
  final String description;

  /// npc: aliado/neutro/inimigo · missão: ativa/concluída/falhou · facção: relação
  final String status;

  /// npc: vivo/morto · local: tipo · item: raridade
  final String attr;
  final String? parentId;
  final String? ownerId;
  final String giver;
  final String reward;

  /// suggested | confirmed
  final String review;
  const Entity({
    required this.id,
    required this.campaignId,
    required this.kind,
    required this.name,
    required this.aliases,
    required this.description,
    required this.status,
    required this.attr,
    this.parentId,
    this.ownerId,
    required this.giver,
    required this.reward,
    required this.review,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['campaign_id'] = Variable<String>(campaignId);
    map['kind'] = Variable<String>(kind);
    map['name'] = Variable<String>(name);
    map['aliases'] = Variable<String>(aliases);
    map['description'] = Variable<String>(description);
    map['status'] = Variable<String>(status);
    map['attr'] = Variable<String>(attr);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<String>(ownerId);
    }
    map['giver'] = Variable<String>(giver);
    map['reward'] = Variable<String>(reward);
    map['review'] = Variable<String>(review);
    return map;
  }

  EntitiesCompanion toCompanion(bool nullToAbsent) {
    return EntitiesCompanion(
      id: Value(id),
      campaignId: Value(campaignId),
      kind: Value(kind),
      name: Value(name),
      aliases: Value(aliases),
      description: Value(description),
      status: Value(status),
      attr: Value(attr),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      giver: Value(giver),
      reward: Value(reward),
      review: Value(review),
    );
  }

  factory Entity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Entity(
      id: serializer.fromJson<String>(json['id']),
      campaignId: serializer.fromJson<String>(json['campaignId']),
      kind: serializer.fromJson<String>(json['kind']),
      name: serializer.fromJson<String>(json['name']),
      aliases: serializer.fromJson<String>(json['aliases']),
      description: serializer.fromJson<String>(json['description']),
      status: serializer.fromJson<String>(json['status']),
      attr: serializer.fromJson<String>(json['attr']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      ownerId: serializer.fromJson<String?>(json['ownerId']),
      giver: serializer.fromJson<String>(json['giver']),
      reward: serializer.fromJson<String>(json['reward']),
      review: serializer.fromJson<String>(json['review']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'campaignId': serializer.toJson<String>(campaignId),
      'kind': serializer.toJson<String>(kind),
      'name': serializer.toJson<String>(name),
      'aliases': serializer.toJson<String>(aliases),
      'description': serializer.toJson<String>(description),
      'status': serializer.toJson<String>(status),
      'attr': serializer.toJson<String>(attr),
      'parentId': serializer.toJson<String?>(parentId),
      'ownerId': serializer.toJson<String?>(ownerId),
      'giver': serializer.toJson<String>(giver),
      'reward': serializer.toJson<String>(reward),
      'review': serializer.toJson<String>(review),
    };
  }

  Entity copyWith({
    String? id,
    String? campaignId,
    String? kind,
    String? name,
    String? aliases,
    String? description,
    String? status,
    String? attr,
    Value<String?> parentId = const Value.absent(),
    Value<String?> ownerId = const Value.absent(),
    String? giver,
    String? reward,
    String? review,
  }) => Entity(
    id: id ?? this.id,
    campaignId: campaignId ?? this.campaignId,
    kind: kind ?? this.kind,
    name: name ?? this.name,
    aliases: aliases ?? this.aliases,
    description: description ?? this.description,
    status: status ?? this.status,
    attr: attr ?? this.attr,
    parentId: parentId.present ? parentId.value : this.parentId,
    ownerId: ownerId.present ? ownerId.value : this.ownerId,
    giver: giver ?? this.giver,
    reward: reward ?? this.reward,
    review: review ?? this.review,
  );
  Entity copyWithCompanion(EntitiesCompanion data) {
    return Entity(
      id: data.id.present ? data.id.value : this.id,
      campaignId: data.campaignId.present
          ? data.campaignId.value
          : this.campaignId,
      kind: data.kind.present ? data.kind.value : this.kind,
      name: data.name.present ? data.name.value : this.name,
      aliases: data.aliases.present ? data.aliases.value : this.aliases,
      description: data.description.present
          ? data.description.value
          : this.description,
      status: data.status.present ? data.status.value : this.status,
      attr: data.attr.present ? data.attr.value : this.attr,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      giver: data.giver.present ? data.giver.value : this.giver,
      reward: data.reward.present ? data.reward.value : this.reward,
      review: data.review.present ? data.review.value : this.review,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Entity(')
          ..write('id: $id, ')
          ..write('campaignId: $campaignId, ')
          ..write('kind: $kind, ')
          ..write('name: $name, ')
          ..write('aliases: $aliases, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('attr: $attr, ')
          ..write('parentId: $parentId, ')
          ..write('ownerId: $ownerId, ')
          ..write('giver: $giver, ')
          ..write('reward: $reward, ')
          ..write('review: $review')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    campaignId,
    kind,
    name,
    aliases,
    description,
    status,
    attr,
    parentId,
    ownerId,
    giver,
    reward,
    review,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Entity &&
          other.id == this.id &&
          other.campaignId == this.campaignId &&
          other.kind == this.kind &&
          other.name == this.name &&
          other.aliases == this.aliases &&
          other.description == this.description &&
          other.status == this.status &&
          other.attr == this.attr &&
          other.parentId == this.parentId &&
          other.ownerId == this.ownerId &&
          other.giver == this.giver &&
          other.reward == this.reward &&
          other.review == this.review);
}

class EntitiesCompanion extends UpdateCompanion<Entity> {
  final Value<String> id;
  final Value<String> campaignId;
  final Value<String> kind;
  final Value<String> name;
  final Value<String> aliases;
  final Value<String> description;
  final Value<String> status;
  final Value<String> attr;
  final Value<String?> parentId;
  final Value<String?> ownerId;
  final Value<String> giver;
  final Value<String> reward;
  final Value<String> review;
  final Value<int> rowid;
  const EntitiesCompanion({
    this.id = const Value.absent(),
    this.campaignId = const Value.absent(),
    this.kind = const Value.absent(),
    this.name = const Value.absent(),
    this.aliases = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.attr = const Value.absent(),
    this.parentId = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.giver = const Value.absent(),
    this.reward = const Value.absent(),
    this.review = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntitiesCompanion.insert({
    required String id,
    required String campaignId,
    required String kind,
    required String name,
    this.aliases = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.attr = const Value.absent(),
    this.parentId = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.giver = const Value.absent(),
    this.reward = const Value.absent(),
    this.review = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       campaignId = Value(campaignId),
       kind = Value(kind),
       name = Value(name);
  static Insertable<Entity> custom({
    Expression<String>? id,
    Expression<String>? campaignId,
    Expression<String>? kind,
    Expression<String>? name,
    Expression<String>? aliases,
    Expression<String>? description,
    Expression<String>? status,
    Expression<String>? attr,
    Expression<String>? parentId,
    Expression<String>? ownerId,
    Expression<String>? giver,
    Expression<String>? reward,
    Expression<String>? review,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (campaignId != null) 'campaign_id': campaignId,
      if (kind != null) 'kind': kind,
      if (name != null) 'name': name,
      if (aliases != null) 'aliases': aliases,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (attr != null) 'attr': attr,
      if (parentId != null) 'parent_id': parentId,
      if (ownerId != null) 'owner_id': ownerId,
      if (giver != null) 'giver': giver,
      if (reward != null) 'reward': reward,
      if (review != null) 'review': review,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntitiesCompanion copyWith({
    Value<String>? id,
    Value<String>? campaignId,
    Value<String>? kind,
    Value<String>? name,
    Value<String>? aliases,
    Value<String>? description,
    Value<String>? status,
    Value<String>? attr,
    Value<String?>? parentId,
    Value<String?>? ownerId,
    Value<String>? giver,
    Value<String>? reward,
    Value<String>? review,
    Value<int>? rowid,
  }) {
    return EntitiesCompanion(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      kind: kind ?? this.kind,
      name: name ?? this.name,
      aliases: aliases ?? this.aliases,
      description: description ?? this.description,
      status: status ?? this.status,
      attr: attr ?? this.attr,
      parentId: parentId ?? this.parentId,
      ownerId: ownerId ?? this.ownerId,
      giver: giver ?? this.giver,
      reward: reward ?? this.reward,
      review: review ?? this.review,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (campaignId.present) {
      map['campaign_id'] = Variable<String>(campaignId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (aliases.present) {
      map['aliases'] = Variable<String>(aliases.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (attr.present) {
      map['attr'] = Variable<String>(attr.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (giver.present) {
      map['giver'] = Variable<String>(giver.value);
    }
    if (reward.present) {
      map['reward'] = Variable<String>(reward.value);
    }
    if (review.present) {
      map['review'] = Variable<String>(review.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntitiesCompanion(')
          ..write('id: $id, ')
          ..write('campaignId: $campaignId, ')
          ..write('kind: $kind, ')
          ..write('name: $name, ')
          ..write('aliases: $aliases, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('attr: $attr, ')
          ..write('parentId: $parentId, ')
          ..write('ownerId: $ownerId, ')
          ..write('giver: $giver, ')
          ..write('reward: $reward, ')
          ..write('review: $review, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EntityHistoryTable extends EntityHistory
    with TableInfo<$EntityHistoryTable, EntityHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntityHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES entities (id)',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id)',
    ),
  );
  static const VerificationMeta _fieldMeta = const VerificationMeta('field');
  @override
  late final GeneratedColumn<String> field = GeneratedColumn<String>(
    'field',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _oldValueMeta = const VerificationMeta(
    'oldValue',
  );
  @override
  late final GeneratedColumn<String> oldValue = GeneratedColumn<String>(
    'old_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _newValueMeta = const VerificationMeta(
    'newValue',
  );
  @override
  late final GeneratedColumn<String> newValue = GeneratedColumn<String>(
    'new_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityId,
    sessionId,
    field,
    oldValue,
    newValue,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entity_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntityHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('field')) {
      context.handle(
        _fieldMeta,
        field.isAcceptableOrUnknown(data['field']!, _fieldMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldMeta);
    }
    if (data.containsKey('old_value')) {
      context.handle(
        _oldValueMeta,
        oldValue.isAcceptableOrUnknown(data['old_value']!, _oldValueMeta),
      );
    }
    if (data.containsKey('new_value')) {
      context.handle(
        _newValueMeta,
        newValue.isAcceptableOrUnknown(data['new_value']!, _newValueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntityHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntityHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      field: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field'],
      )!,
      oldValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}old_value'],
      )!,
      newValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}new_value'],
      )!,
    );
  }

  @override
  $EntityHistoryTable createAlias(String alias) {
    return $EntityHistoryTable(attachedDatabase, alias);
  }
}

class EntityHistoryData extends DataClass
    implements Insertable<EntityHistoryData> {
  final String id;
  final String entityId;
  final String sessionId;
  final String field;
  final String oldValue;
  final String newValue;
  const EntityHistoryData({
    required this.id,
    required this.entityId,
    required this.sessionId,
    required this.field,
    required this.oldValue,
    required this.newValue,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_id'] = Variable<String>(entityId);
    map['session_id'] = Variable<String>(sessionId);
    map['field'] = Variable<String>(field);
    map['old_value'] = Variable<String>(oldValue);
    map['new_value'] = Variable<String>(newValue);
    return map;
  }

  EntityHistoryCompanion toCompanion(bool nullToAbsent) {
    return EntityHistoryCompanion(
      id: Value(id),
      entityId: Value(entityId),
      sessionId: Value(sessionId),
      field: Value(field),
      oldValue: Value(oldValue),
      newValue: Value(newValue),
    );
  }

  factory EntityHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntityHistoryData(
      id: serializer.fromJson<String>(json['id']),
      entityId: serializer.fromJson<String>(json['entityId']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      field: serializer.fromJson<String>(json['field']),
      oldValue: serializer.fromJson<String>(json['oldValue']),
      newValue: serializer.fromJson<String>(json['newValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityId': serializer.toJson<String>(entityId),
      'sessionId': serializer.toJson<String>(sessionId),
      'field': serializer.toJson<String>(field),
      'oldValue': serializer.toJson<String>(oldValue),
      'newValue': serializer.toJson<String>(newValue),
    };
  }

  EntityHistoryData copyWith({
    String? id,
    String? entityId,
    String? sessionId,
    String? field,
    String? oldValue,
    String? newValue,
  }) => EntityHistoryData(
    id: id ?? this.id,
    entityId: entityId ?? this.entityId,
    sessionId: sessionId ?? this.sessionId,
    field: field ?? this.field,
    oldValue: oldValue ?? this.oldValue,
    newValue: newValue ?? this.newValue,
  );
  EntityHistoryData copyWithCompanion(EntityHistoryCompanion data) {
    return EntityHistoryData(
      id: data.id.present ? data.id.value : this.id,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      field: data.field.present ? data.field.value : this.field,
      oldValue: data.oldValue.present ? data.oldValue.value : this.oldValue,
      newValue: data.newValue.present ? data.newValue.value : this.newValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntityHistoryData(')
          ..write('id: $id, ')
          ..write('entityId: $entityId, ')
          ..write('sessionId: $sessionId, ')
          ..write('field: $field, ')
          ..write('oldValue: $oldValue, ')
          ..write('newValue: $newValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, entityId, sessionId, field, oldValue, newValue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntityHistoryData &&
          other.id == this.id &&
          other.entityId == this.entityId &&
          other.sessionId == this.sessionId &&
          other.field == this.field &&
          other.oldValue == this.oldValue &&
          other.newValue == this.newValue);
}

class EntityHistoryCompanion extends UpdateCompanion<EntityHistoryData> {
  final Value<String> id;
  final Value<String> entityId;
  final Value<String> sessionId;
  final Value<String> field;
  final Value<String> oldValue;
  final Value<String> newValue;
  final Value<int> rowid;
  const EntityHistoryCompanion({
    this.id = const Value.absent(),
    this.entityId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.field = const Value.absent(),
    this.oldValue = const Value.absent(),
    this.newValue = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntityHistoryCompanion.insert({
    required String id,
    required String entityId,
    required String sessionId,
    required String field,
    this.oldValue = const Value.absent(),
    this.newValue = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityId = Value(entityId),
       sessionId = Value(sessionId),
       field = Value(field);
  static Insertable<EntityHistoryData> custom({
    Expression<String>? id,
    Expression<String>? entityId,
    Expression<String>? sessionId,
    Expression<String>? field,
    Expression<String>? oldValue,
    Expression<String>? newValue,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityId != null) 'entity_id': entityId,
      if (sessionId != null) 'session_id': sessionId,
      if (field != null) 'field': field,
      if (oldValue != null) 'old_value': oldValue,
      if (newValue != null) 'new_value': newValue,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntityHistoryCompanion copyWith({
    Value<String>? id,
    Value<String>? entityId,
    Value<String>? sessionId,
    Value<String>? field,
    Value<String>? oldValue,
    Value<String>? newValue,
    Value<int>? rowid,
  }) {
    return EntityHistoryCompanion(
      id: id ?? this.id,
      entityId: entityId ?? this.entityId,
      sessionId: sessionId ?? this.sessionId,
      field: field ?? this.field,
      oldValue: oldValue ?? this.oldValue,
      newValue: newValue ?? this.newValue,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (field.present) {
      map['field'] = Variable<String>(field.value);
    }
    if (oldValue.present) {
      map['old_value'] = Variable<String>(oldValue.value);
    }
    if (newValue.present) {
      map['new_value'] = Variable<String>(newValue.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntityHistoryCompanion(')
          ..write('id: $id, ')
          ..write('entityId: $entityId, ')
          ..write('sessionId: $sessionId, ')
          ..write('field: $field, ')
          ..write('oldValue: $oldValue, ')
          ..write('newValue: $newValue, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventsTable extends Events with TableInfo<$EventsTable, Event> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id)',
    ),
  );
  static const VerificationMeta _text_Meta = const VerificationMeta('text_');
  @override
  late final GeneratedColumn<String> text_ = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ordMeta = const VerificationMeta('ord');
  @override
  late final GeneratedColumn<int> ord = GeneratedColumn<int>(
    'ord',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMsMeta = const VerificationMeta('atMs');
  @override
  late final GeneratedColumn<int> atMs = GeneratedColumn<int>(
    'at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewMeta = const VerificationMeta('review');
  @override
  late final GeneratedColumn<String> review = GeneratedColumn<String>(
    'review',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('suggested'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    text_,
    ord,
    atMs,
    review,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'events';
  @override
  VerificationContext validateIntegrity(
    Insertable<Event> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('text')) {
      context.handle(
        _text_Meta,
        text_.isAcceptableOrUnknown(data['text']!, _text_Meta),
      );
    } else if (isInserting) {
      context.missing(_text_Meta);
    }
    if (data.containsKey('ord')) {
      context.handle(
        _ordMeta,
        ord.isAcceptableOrUnknown(data['ord']!, _ordMeta),
      );
    } else if (isInserting) {
      context.missing(_ordMeta);
    }
    if (data.containsKey('at_ms')) {
      context.handle(
        _atMsMeta,
        atMs.isAcceptableOrUnknown(data['at_ms']!, _atMsMeta),
      );
    }
    if (data.containsKey('review')) {
      context.handle(
        _reviewMeta,
        review.isAcceptableOrUnknown(data['review']!, _reviewMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Event map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Event(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      text_: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
      ord: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ord'],
      )!,
      atMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}at_ms'],
      ),
      review: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review'],
      )!,
    );
  }

  @override
  $EventsTable createAlias(String alias) {
    return $EventsTable(attachedDatabase, alias);
  }
}

class Event extends DataClass implements Insertable<Event> {
  final String id;
  final String sessionId;
  final String text_;
  final int ord;
  final int? atMs;

  /// suggested | confirmed
  final String review;
  const Event({
    required this.id,
    required this.sessionId,
    required this.text_,
    required this.ord,
    this.atMs,
    required this.review,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['text'] = Variable<String>(text_);
    map['ord'] = Variable<int>(ord);
    if (!nullToAbsent || atMs != null) {
      map['at_ms'] = Variable<int>(atMs);
    }
    map['review'] = Variable<String>(review);
    return map;
  }

  EventsCompanion toCompanion(bool nullToAbsent) {
    return EventsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      text_: Value(text_),
      ord: Value(ord),
      atMs: atMs == null && nullToAbsent ? const Value.absent() : Value(atMs),
      review: Value(review),
    );
  }

  factory Event.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Event(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      text_: serializer.fromJson<String>(json['text_']),
      ord: serializer.fromJson<int>(json['ord']),
      atMs: serializer.fromJson<int?>(json['atMs']),
      review: serializer.fromJson<String>(json['review']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'text_': serializer.toJson<String>(text_),
      'ord': serializer.toJson<int>(ord),
      'atMs': serializer.toJson<int?>(atMs),
      'review': serializer.toJson<String>(review),
    };
  }

  Event copyWith({
    String? id,
    String? sessionId,
    String? text_,
    int? ord,
    Value<int?> atMs = const Value.absent(),
    String? review,
  }) => Event(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    text_: text_ ?? this.text_,
    ord: ord ?? this.ord,
    atMs: atMs.present ? atMs.value : this.atMs,
    review: review ?? this.review,
  );
  Event copyWithCompanion(EventsCompanion data) {
    return Event(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      text_: data.text_.present ? data.text_.value : this.text_,
      ord: data.ord.present ? data.ord.value : this.ord,
      atMs: data.atMs.present ? data.atMs.value : this.atMs,
      review: data.review.present ? data.review.value : this.review,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Event(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('text_: $text_, ')
          ..write('ord: $ord, ')
          ..write('atMs: $atMs, ')
          ..write('review: $review')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionId, text_, ord, atMs, review);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Event &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.text_ == this.text_ &&
          other.ord == this.ord &&
          other.atMs == this.atMs &&
          other.review == this.review);
}

class EventsCompanion extends UpdateCompanion<Event> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> text_;
  final Value<int> ord;
  final Value<int?> atMs;
  final Value<String> review;
  final Value<int> rowid;
  const EventsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.text_ = const Value.absent(),
    this.ord = const Value.absent(),
    this.atMs = const Value.absent(),
    this.review = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventsCompanion.insert({
    required String id,
    required String sessionId,
    required String text_,
    required int ord,
    this.atMs = const Value.absent(),
    this.review = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       text_ = Value(text_),
       ord = Value(ord);
  static Insertable<Event> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? text_,
    Expression<int>? ord,
    Expression<int>? atMs,
    Expression<String>? review,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (text_ != null) 'text': text_,
      if (ord != null) 'ord': ord,
      if (atMs != null) 'at_ms': atMs,
      if (review != null) 'review': review,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? text_,
    Value<int>? ord,
    Value<int?>? atMs,
    Value<String>? review,
    Value<int>? rowid,
  }) {
    return EventsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      text_: text_ ?? this.text_,
      ord: ord ?? this.ord,
      atMs: atMs ?? this.atMs,
      review: review ?? this.review,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (text_.present) {
      map['text'] = Variable<String>(text_.value);
    }
    if (ord.present) {
      map['ord'] = Variable<int>(ord.value);
    }
    if (atMs.present) {
      map['at_ms'] = Variable<int>(atMs.value);
    }
    if (review.present) {
      map['review'] = Variable<String>(review.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('text_: $text_, ')
          ..write('ord: $ord, ')
          ..write('atMs: $atMs, ')
          ..write('review: $review, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MentionsTable extends Mentions with TableInfo<$MentionsTable, Mention> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MentionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES entities (id)',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id)',
    ),
  );
  static const VerificationMeta _atMsMeta = const VerificationMeta('atMs');
  @override
  late final GeneratedColumn<int> atMs = GeneratedColumn<int>(
    'at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quoteMeta = const VerificationMeta('quote');
  @override
  late final GeneratedColumn<String> quote = GeneratedColumn<String>(
    'quote',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _proposedFieldMeta = const VerificationMeta(
    'proposedField',
  );
  @override
  late final GeneratedColumn<String> proposedField = GeneratedColumn<String>(
    'proposed_field',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _proposedValueMeta = const VerificationMeta(
    'proposedValue',
  );
  @override
  late final GeneratedColumn<String> proposedValue = GeneratedColumn<String>(
    'proposed_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _detailMeta = const VerificationMeta('detail');
  @override
  late final GeneratedColumn<String> detail = GeneratedColumn<String>(
    'detail',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  @override
  late final GeneratedColumn<String> target = GeneratedColumn<String>(
    'target',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sideMeta = const VerificationMeta('side');
  @override
  late final GeneratedColumn<String> side = GeneratedColumn<String>(
    'side',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _resultMeta = const VerificationMeta('result');
  @override
  late final GeneratedColumn<String> result = GeneratedColumn<String>(
    'result',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('suggested'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityId,
    sessionId,
    atMs,
    quote,
    proposedField,
    proposedValue,
    detail,
    target,
    side,
    result,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mentions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Mention> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('at_ms')) {
      context.handle(
        _atMsMeta,
        atMs.isAcceptableOrUnknown(data['at_ms']!, _atMsMeta),
      );
    }
    if (data.containsKey('quote')) {
      context.handle(
        _quoteMeta,
        quote.isAcceptableOrUnknown(data['quote']!, _quoteMeta),
      );
    }
    if (data.containsKey('proposed_field')) {
      context.handle(
        _proposedFieldMeta,
        proposedField.isAcceptableOrUnknown(
          data['proposed_field']!,
          _proposedFieldMeta,
        ),
      );
    }
    if (data.containsKey('proposed_value')) {
      context.handle(
        _proposedValueMeta,
        proposedValue.isAcceptableOrUnknown(
          data['proposed_value']!,
          _proposedValueMeta,
        ),
      );
    }
    if (data.containsKey('detail')) {
      context.handle(
        _detailMeta,
        detail.isAcceptableOrUnknown(data['detail']!, _detailMeta),
      );
    }
    if (data.containsKey('target')) {
      context.handle(
        _targetMeta,
        target.isAcceptableOrUnknown(data['target']!, _targetMeta),
      );
    }
    if (data.containsKey('side')) {
      context.handle(
        _sideMeta,
        side.isAcceptableOrUnknown(data['side']!, _sideMeta),
      );
    }
    if (data.containsKey('result')) {
      context.handle(
        _resultMeta,
        result.isAcceptableOrUnknown(data['result']!, _resultMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Mention map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Mention(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      atMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}at_ms'],
      ),
      quote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quote'],
      )!,
      proposedField: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}proposed_field'],
      )!,
      proposedValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}proposed_value'],
      )!,
      detail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detail'],
      )!,
      target: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target'],
      )!,
      side: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}side'],
      )!,
      result: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $MentionsTable createAlias(String alias) {
    return $MentionsTable(attachedDatabase, alias);
  }
}

class Mention extends DataClass implements Insertable<Mention> {
  final String id;
  final String entityId;
  final String sessionId;
  final int? atMs;
  final String quote;

  /// Mudança proposta (ex.: status -> concluída), vazio se só citação.
  final String proposedField;
  final String proposedValue;

  /// Detalhe do uso (ex.: "Lançado por Orquídea"). Cada feitiço usado é uma menção.
  final String detail;

  /// Feitiços: em quem foi usado, de que lado veio (hero | enemy | neutral) e o resultado.
  final String target;
  final String side;
  final String result;

  /// suggested | confirmed
  final String status;
  const Mention({
    required this.id,
    required this.entityId,
    required this.sessionId,
    this.atMs,
    required this.quote,
    required this.proposedField,
    required this.proposedValue,
    required this.detail,
    required this.target,
    required this.side,
    required this.result,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_id'] = Variable<String>(entityId);
    map['session_id'] = Variable<String>(sessionId);
    if (!nullToAbsent || atMs != null) {
      map['at_ms'] = Variable<int>(atMs);
    }
    map['quote'] = Variable<String>(quote);
    map['proposed_field'] = Variable<String>(proposedField);
    map['proposed_value'] = Variable<String>(proposedValue);
    map['detail'] = Variable<String>(detail);
    map['target'] = Variable<String>(target);
    map['side'] = Variable<String>(side);
    map['result'] = Variable<String>(result);
    map['status'] = Variable<String>(status);
    return map;
  }

  MentionsCompanion toCompanion(bool nullToAbsent) {
    return MentionsCompanion(
      id: Value(id),
      entityId: Value(entityId),
      sessionId: Value(sessionId),
      atMs: atMs == null && nullToAbsent ? const Value.absent() : Value(atMs),
      quote: Value(quote),
      proposedField: Value(proposedField),
      proposedValue: Value(proposedValue),
      detail: Value(detail),
      target: Value(target),
      side: Value(side),
      result: Value(result),
      status: Value(status),
    );
  }

  factory Mention.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Mention(
      id: serializer.fromJson<String>(json['id']),
      entityId: serializer.fromJson<String>(json['entityId']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      atMs: serializer.fromJson<int?>(json['atMs']),
      quote: serializer.fromJson<String>(json['quote']),
      proposedField: serializer.fromJson<String>(json['proposedField']),
      proposedValue: serializer.fromJson<String>(json['proposedValue']),
      detail: serializer.fromJson<String>(json['detail']),
      target: serializer.fromJson<String>(json['target']),
      side: serializer.fromJson<String>(json['side']),
      result: serializer.fromJson<String>(json['result']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityId': serializer.toJson<String>(entityId),
      'sessionId': serializer.toJson<String>(sessionId),
      'atMs': serializer.toJson<int?>(atMs),
      'quote': serializer.toJson<String>(quote),
      'proposedField': serializer.toJson<String>(proposedField),
      'proposedValue': serializer.toJson<String>(proposedValue),
      'detail': serializer.toJson<String>(detail),
      'target': serializer.toJson<String>(target),
      'side': serializer.toJson<String>(side),
      'result': serializer.toJson<String>(result),
      'status': serializer.toJson<String>(status),
    };
  }

  Mention copyWith({
    String? id,
    String? entityId,
    String? sessionId,
    Value<int?> atMs = const Value.absent(),
    String? quote,
    String? proposedField,
    String? proposedValue,
    String? detail,
    String? target,
    String? side,
    String? result,
    String? status,
  }) => Mention(
    id: id ?? this.id,
    entityId: entityId ?? this.entityId,
    sessionId: sessionId ?? this.sessionId,
    atMs: atMs.present ? atMs.value : this.atMs,
    quote: quote ?? this.quote,
    proposedField: proposedField ?? this.proposedField,
    proposedValue: proposedValue ?? this.proposedValue,
    detail: detail ?? this.detail,
    target: target ?? this.target,
    side: side ?? this.side,
    result: result ?? this.result,
    status: status ?? this.status,
  );
  Mention copyWithCompanion(MentionsCompanion data) {
    return Mention(
      id: data.id.present ? data.id.value : this.id,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      atMs: data.atMs.present ? data.atMs.value : this.atMs,
      quote: data.quote.present ? data.quote.value : this.quote,
      proposedField: data.proposedField.present
          ? data.proposedField.value
          : this.proposedField,
      proposedValue: data.proposedValue.present
          ? data.proposedValue.value
          : this.proposedValue,
      detail: data.detail.present ? data.detail.value : this.detail,
      target: data.target.present ? data.target.value : this.target,
      side: data.side.present ? data.side.value : this.side,
      result: data.result.present ? data.result.value : this.result,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Mention(')
          ..write('id: $id, ')
          ..write('entityId: $entityId, ')
          ..write('sessionId: $sessionId, ')
          ..write('atMs: $atMs, ')
          ..write('quote: $quote, ')
          ..write('proposedField: $proposedField, ')
          ..write('proposedValue: $proposedValue, ')
          ..write('detail: $detail, ')
          ..write('target: $target, ')
          ..write('side: $side, ')
          ..write('result: $result, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityId,
    sessionId,
    atMs,
    quote,
    proposedField,
    proposedValue,
    detail,
    target,
    side,
    result,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Mention &&
          other.id == this.id &&
          other.entityId == this.entityId &&
          other.sessionId == this.sessionId &&
          other.atMs == this.atMs &&
          other.quote == this.quote &&
          other.proposedField == this.proposedField &&
          other.proposedValue == this.proposedValue &&
          other.detail == this.detail &&
          other.target == this.target &&
          other.side == this.side &&
          other.result == this.result &&
          other.status == this.status);
}

class MentionsCompanion extends UpdateCompanion<Mention> {
  final Value<String> id;
  final Value<String> entityId;
  final Value<String> sessionId;
  final Value<int?> atMs;
  final Value<String> quote;
  final Value<String> proposedField;
  final Value<String> proposedValue;
  final Value<String> detail;
  final Value<String> target;
  final Value<String> side;
  final Value<String> result;
  final Value<String> status;
  final Value<int> rowid;
  const MentionsCompanion({
    this.id = const Value.absent(),
    this.entityId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.atMs = const Value.absent(),
    this.quote = const Value.absent(),
    this.proposedField = const Value.absent(),
    this.proposedValue = const Value.absent(),
    this.detail = const Value.absent(),
    this.target = const Value.absent(),
    this.side = const Value.absent(),
    this.result = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MentionsCompanion.insert({
    required String id,
    required String entityId,
    required String sessionId,
    this.atMs = const Value.absent(),
    this.quote = const Value.absent(),
    this.proposedField = const Value.absent(),
    this.proposedValue = const Value.absent(),
    this.detail = const Value.absent(),
    this.target = const Value.absent(),
    this.side = const Value.absent(),
    this.result = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityId = Value(entityId),
       sessionId = Value(sessionId);
  static Insertable<Mention> custom({
    Expression<String>? id,
    Expression<String>? entityId,
    Expression<String>? sessionId,
    Expression<int>? atMs,
    Expression<String>? quote,
    Expression<String>? proposedField,
    Expression<String>? proposedValue,
    Expression<String>? detail,
    Expression<String>? target,
    Expression<String>? side,
    Expression<String>? result,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityId != null) 'entity_id': entityId,
      if (sessionId != null) 'session_id': sessionId,
      if (atMs != null) 'at_ms': atMs,
      if (quote != null) 'quote': quote,
      if (proposedField != null) 'proposed_field': proposedField,
      if (proposedValue != null) 'proposed_value': proposedValue,
      if (detail != null) 'detail': detail,
      if (target != null) 'target': target,
      if (side != null) 'side': side,
      if (result != null) 'result': result,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MentionsCompanion copyWith({
    Value<String>? id,
    Value<String>? entityId,
    Value<String>? sessionId,
    Value<int?>? atMs,
    Value<String>? quote,
    Value<String>? proposedField,
    Value<String>? proposedValue,
    Value<String>? detail,
    Value<String>? target,
    Value<String>? side,
    Value<String>? result,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return MentionsCompanion(
      id: id ?? this.id,
      entityId: entityId ?? this.entityId,
      sessionId: sessionId ?? this.sessionId,
      atMs: atMs ?? this.atMs,
      quote: quote ?? this.quote,
      proposedField: proposedField ?? this.proposedField,
      proposedValue: proposedValue ?? this.proposedValue,
      detail: detail ?? this.detail,
      target: target ?? this.target,
      side: side ?? this.side,
      result: result ?? this.result,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (atMs.present) {
      map['at_ms'] = Variable<int>(atMs.value);
    }
    if (quote.present) {
      map['quote'] = Variable<String>(quote.value);
    }
    if (proposedField.present) {
      map['proposed_field'] = Variable<String>(proposedField.value);
    }
    if (proposedValue.present) {
      map['proposed_value'] = Variable<String>(proposedValue.value);
    }
    if (detail.present) {
      map['detail'] = Variable<String>(detail.value);
    }
    if (target.present) {
      map['target'] = Variable<String>(target.value);
    }
    if (side.present) {
      map['side'] = Variable<String>(side.value);
    }
    if (result.present) {
      map['result'] = Variable<String>(result.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MentionsCompanion(')
          ..write('id: $id, ')
          ..write('entityId: $entityId, ')
          ..write('sessionId: $sessionId, ')
          ..write('atMs: $atMs, ')
          ..write('quote: $quote, ')
          ..write('proposedField: $proposedField, ')
          ..write('proposedValue: $proposedValue, ')
          ..write('detail: $detail, ')
          ..write('target: $target, ')
          ..write('side: $side, ')
          ..write('result: $result, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsageLogTable extends UsageLog
    with TableInfo<$UsageLogTable, UsageLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsageLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _campaignIdMeta = const VerificationMeta(
    'campaignId',
  );
  @override
  late final GeneratedColumn<String> campaignId = GeneratedColumn<String>(
    'campaign_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stepMeta = const VerificationMeta('step');
  @override
  late final GeneratedColumn<String> step = GeneratedColumn<String>(
    'step',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _inputTokensMeta = const VerificationMeta(
    'inputTokens',
  );
  @override
  late final GeneratedColumn<int> inputTokens = GeneratedColumn<int>(
    'input_tokens',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _outputTokensMeta = const VerificationMeta(
    'outputTokens',
  );
  @override
  late final GeneratedColumn<int> outputTokens = GeneratedColumn<int>(
    'output_tokens',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costUsdMeta = const VerificationMeta(
    'costUsd',
  );
  @override
  late final GeneratedColumn<double> costUsd = GeneratedColumn<double>(
    'cost_usd',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    campaignId,
    provider,
    step,
    inputTokens,
    outputTokens,
    costUsd,
    at,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'usage_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<UsageLogData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('campaign_id')) {
      context.handle(
        _campaignIdMeta,
        campaignId.isAcceptableOrUnknown(data['campaign_id']!, _campaignIdMeta),
      );
    } else if (isInserting) {
      context.missing(_campaignIdMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('step')) {
      context.handle(
        _stepMeta,
        step.isAcceptableOrUnknown(data['step']!, _stepMeta),
      );
    } else if (isInserting) {
      context.missing(_stepMeta);
    }
    if (data.containsKey('input_tokens')) {
      context.handle(
        _inputTokensMeta,
        inputTokens.isAcceptableOrUnknown(
          data['input_tokens']!,
          _inputTokensMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_inputTokensMeta);
    }
    if (data.containsKey('output_tokens')) {
      context.handle(
        _outputTokensMeta,
        outputTokens.isAcceptableOrUnknown(
          data['output_tokens']!,
          _outputTokensMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_outputTokensMeta);
    }
    if (data.containsKey('cost_usd')) {
      context.handle(
        _costUsdMeta,
        costUsd.isAcceptableOrUnknown(data['cost_usd']!, _costUsdMeta),
      );
    } else if (isInserting) {
      context.missing(_costUsdMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UsageLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UsageLogData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      campaignId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}campaign_id'],
      )!,
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      )!,
      step: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}step'],
      )!,
      inputTokens: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}input_tokens'],
      )!,
      outputTokens: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}output_tokens'],
      )!,
      costUsd: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost_usd'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
    );
  }

  @override
  $UsageLogTable createAlias(String alias) {
    return $UsageLogTable(attachedDatabase, alias);
  }
}

class UsageLogData extends DataClass implements Insertable<UsageLogData> {
  final String id;
  final String campaignId;
  final String provider;
  final String step;
  final int inputTokens;
  final int outputTokens;
  final double costUsd;
  final DateTime at;
  const UsageLogData({
    required this.id,
    required this.campaignId,
    required this.provider,
    required this.step,
    required this.inputTokens,
    required this.outputTokens,
    required this.costUsd,
    required this.at,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['campaign_id'] = Variable<String>(campaignId);
    map['provider'] = Variable<String>(provider);
    map['step'] = Variable<String>(step);
    map['input_tokens'] = Variable<int>(inputTokens);
    map['output_tokens'] = Variable<int>(outputTokens);
    map['cost_usd'] = Variable<double>(costUsd);
    map['at'] = Variable<DateTime>(at);
    return map;
  }

  UsageLogCompanion toCompanion(bool nullToAbsent) {
    return UsageLogCompanion(
      id: Value(id),
      campaignId: Value(campaignId),
      provider: Value(provider),
      step: Value(step),
      inputTokens: Value(inputTokens),
      outputTokens: Value(outputTokens),
      costUsd: Value(costUsd),
      at: Value(at),
    );
  }

  factory UsageLogData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UsageLogData(
      id: serializer.fromJson<String>(json['id']),
      campaignId: serializer.fromJson<String>(json['campaignId']),
      provider: serializer.fromJson<String>(json['provider']),
      step: serializer.fromJson<String>(json['step']),
      inputTokens: serializer.fromJson<int>(json['inputTokens']),
      outputTokens: serializer.fromJson<int>(json['outputTokens']),
      costUsd: serializer.fromJson<double>(json['costUsd']),
      at: serializer.fromJson<DateTime>(json['at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'campaignId': serializer.toJson<String>(campaignId),
      'provider': serializer.toJson<String>(provider),
      'step': serializer.toJson<String>(step),
      'inputTokens': serializer.toJson<int>(inputTokens),
      'outputTokens': serializer.toJson<int>(outputTokens),
      'costUsd': serializer.toJson<double>(costUsd),
      'at': serializer.toJson<DateTime>(at),
    };
  }

  UsageLogData copyWith({
    String? id,
    String? campaignId,
    String? provider,
    String? step,
    int? inputTokens,
    int? outputTokens,
    double? costUsd,
    DateTime? at,
  }) => UsageLogData(
    id: id ?? this.id,
    campaignId: campaignId ?? this.campaignId,
    provider: provider ?? this.provider,
    step: step ?? this.step,
    inputTokens: inputTokens ?? this.inputTokens,
    outputTokens: outputTokens ?? this.outputTokens,
    costUsd: costUsd ?? this.costUsd,
    at: at ?? this.at,
  );
  UsageLogData copyWithCompanion(UsageLogCompanion data) {
    return UsageLogData(
      id: data.id.present ? data.id.value : this.id,
      campaignId: data.campaignId.present
          ? data.campaignId.value
          : this.campaignId,
      provider: data.provider.present ? data.provider.value : this.provider,
      step: data.step.present ? data.step.value : this.step,
      inputTokens: data.inputTokens.present
          ? data.inputTokens.value
          : this.inputTokens,
      outputTokens: data.outputTokens.present
          ? data.outputTokens.value
          : this.outputTokens,
      costUsd: data.costUsd.present ? data.costUsd.value : this.costUsd,
      at: data.at.present ? data.at.value : this.at,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UsageLogData(')
          ..write('id: $id, ')
          ..write('campaignId: $campaignId, ')
          ..write('provider: $provider, ')
          ..write('step: $step, ')
          ..write('inputTokens: $inputTokens, ')
          ..write('outputTokens: $outputTokens, ')
          ..write('costUsd: $costUsd, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    campaignId,
    provider,
    step,
    inputTokens,
    outputTokens,
    costUsd,
    at,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UsageLogData &&
          other.id == this.id &&
          other.campaignId == this.campaignId &&
          other.provider == this.provider &&
          other.step == this.step &&
          other.inputTokens == this.inputTokens &&
          other.outputTokens == this.outputTokens &&
          other.costUsd == this.costUsd &&
          other.at == this.at);
}

class UsageLogCompanion extends UpdateCompanion<UsageLogData> {
  final Value<String> id;
  final Value<String> campaignId;
  final Value<String> provider;
  final Value<String> step;
  final Value<int> inputTokens;
  final Value<int> outputTokens;
  final Value<double> costUsd;
  final Value<DateTime> at;
  final Value<int> rowid;
  const UsageLogCompanion({
    this.id = const Value.absent(),
    this.campaignId = const Value.absent(),
    this.provider = const Value.absent(),
    this.step = const Value.absent(),
    this.inputTokens = const Value.absent(),
    this.outputTokens = const Value.absent(),
    this.costUsd = const Value.absent(),
    this.at = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsageLogCompanion.insert({
    required String id,
    required String campaignId,
    required String provider,
    required String step,
    required int inputTokens,
    required int outputTokens,
    required double costUsd,
    required DateTime at,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       campaignId = Value(campaignId),
       provider = Value(provider),
       step = Value(step),
       inputTokens = Value(inputTokens),
       outputTokens = Value(outputTokens),
       costUsd = Value(costUsd),
       at = Value(at);
  static Insertable<UsageLogData> custom({
    Expression<String>? id,
    Expression<String>? campaignId,
    Expression<String>? provider,
    Expression<String>? step,
    Expression<int>? inputTokens,
    Expression<int>? outputTokens,
    Expression<double>? costUsd,
    Expression<DateTime>? at,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (campaignId != null) 'campaign_id': campaignId,
      if (provider != null) 'provider': provider,
      if (step != null) 'step': step,
      if (inputTokens != null) 'input_tokens': inputTokens,
      if (outputTokens != null) 'output_tokens': outputTokens,
      if (costUsd != null) 'cost_usd': costUsd,
      if (at != null) 'at': at,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsageLogCompanion copyWith({
    Value<String>? id,
    Value<String>? campaignId,
    Value<String>? provider,
    Value<String>? step,
    Value<int>? inputTokens,
    Value<int>? outputTokens,
    Value<double>? costUsd,
    Value<DateTime>? at,
    Value<int>? rowid,
  }) {
    return UsageLogCompanion(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      provider: provider ?? this.provider,
      step: step ?? this.step,
      inputTokens: inputTokens ?? this.inputTokens,
      outputTokens: outputTokens ?? this.outputTokens,
      costUsd: costUsd ?? this.costUsd,
      at: at ?? this.at,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (campaignId.present) {
      map['campaign_id'] = Variable<String>(campaignId.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (step.present) {
      map['step'] = Variable<String>(step.value);
    }
    if (inputTokens.present) {
      map['input_tokens'] = Variable<int>(inputTokens.value);
    }
    if (outputTokens.present) {
      map['output_tokens'] = Variable<int>(outputTokens.value);
    }
    if (costUsd.present) {
      map['cost_usd'] = Variable<double>(costUsd.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsageLogCompanion(')
          ..write('id: $id, ')
          ..write('campaignId: $campaignId, ')
          ..write('provider: $provider, ')
          ..write('step: $step, ')
          ..write('inputTokens: $inputTokens, ')
          ..write('outputTokens: $outputTokens, ')
          ..write('costUsd: $costUsd, ')
          ..write('at: $at, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, Note> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _campaignIdMeta = const VerificationMeta(
    'campaignId',
  );
  @override
  late final GeneratedColumn<String> campaignId = GeneratedColumn<String>(
    'campaign_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES campaigns (id)',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
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
    requiredDuringInsert: false,
    defaultValue: const Constant('open'),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
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
    campaignId,
    sessionId,
    kind,
    body,
    status,
    source,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Note> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('campaign_id')) {
      context.handle(
        _campaignIdMeta,
        campaignId.isAcceptableOrUnknown(data['campaign_id']!, _campaignIdMeta),
      );
    } else if (isInserting) {
      context.missing(_campaignIdMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
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
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
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
  Note map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Note(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      campaignId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}campaign_id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }
}

class Note extends DataClass implements Insertable<Note> {
  final String id;
  final String campaignId;

  /// Sessão de origem (nulo = criada à mão na campanha).
  final String? sessionId;

  /// thread | secret | strong_start
  final String kind;
  final String body;

  /// open | done (gancho resolvido / segredo revelado)
  final String status;

  /// ai | manual
  final String source;
  final DateTime createdAt;
  const Note({
    required this.id,
    required this.campaignId,
    this.sessionId,
    required this.kind,
    required this.body,
    required this.status,
    required this.source,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['campaign_id'] = Variable<String>(campaignId);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<String>(sessionId);
    }
    map['kind'] = Variable<String>(kind);
    map['body'] = Variable<String>(body);
    map['status'] = Variable<String>(status);
    map['source'] = Variable<String>(source);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      campaignId: Value(campaignId),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      kind: Value(kind),
      body: Value(body),
      status: Value(status),
      source: Value(source),
      createdAt: Value(createdAt),
    );
  }

  factory Note.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Note(
      id: serializer.fromJson<String>(json['id']),
      campaignId: serializer.fromJson<String>(json['campaignId']),
      sessionId: serializer.fromJson<String?>(json['sessionId']),
      kind: serializer.fromJson<String>(json['kind']),
      body: serializer.fromJson<String>(json['body']),
      status: serializer.fromJson<String>(json['status']),
      source: serializer.fromJson<String>(json['source']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'campaignId': serializer.toJson<String>(campaignId),
      'sessionId': serializer.toJson<String?>(sessionId),
      'kind': serializer.toJson<String>(kind),
      'body': serializer.toJson<String>(body),
      'status': serializer.toJson<String>(status),
      'source': serializer.toJson<String>(source),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Note copyWith({
    String? id,
    String? campaignId,
    Value<String?> sessionId = const Value.absent(),
    String? kind,
    String? body,
    String? status,
    String? source,
    DateTime? createdAt,
  }) => Note(
    id: id ?? this.id,
    campaignId: campaignId ?? this.campaignId,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
    kind: kind ?? this.kind,
    body: body ?? this.body,
    status: status ?? this.status,
    source: source ?? this.source,
    createdAt: createdAt ?? this.createdAt,
  );
  Note copyWithCompanion(NotesCompanion data) {
    return Note(
      id: data.id.present ? data.id.value : this.id,
      campaignId: data.campaignId.present
          ? data.campaignId.value
          : this.campaignId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      kind: data.kind.present ? data.kind.value : this.kind,
      body: data.body.present ? data.body.value : this.body,
      status: data.status.present ? data.status.value : this.status,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Note(')
          ..write('id: $id, ')
          ..write('campaignId: $campaignId, ')
          ..write('sessionId: $sessionId, ')
          ..write('kind: $kind, ')
          ..write('body: $body, ')
          ..write('status: $status, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    campaignId,
    sessionId,
    kind,
    body,
    status,
    source,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Note &&
          other.id == this.id &&
          other.campaignId == this.campaignId &&
          other.sessionId == this.sessionId &&
          other.kind == this.kind &&
          other.body == this.body &&
          other.status == this.status &&
          other.source == this.source &&
          other.createdAt == this.createdAt);
}

class NotesCompanion extends UpdateCompanion<Note> {
  final Value<String> id;
  final Value<String> campaignId;
  final Value<String?> sessionId;
  final Value<String> kind;
  final Value<String> body;
  final Value<String> status;
  final Value<String> source;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.campaignId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.kind = const Value.absent(),
    this.body = const Value.absent(),
    this.status = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotesCompanion.insert({
    required String id,
    required String campaignId,
    this.sessionId = const Value.absent(),
    required String kind,
    required String body,
    this.status = const Value.absent(),
    this.source = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       campaignId = Value(campaignId),
       kind = Value(kind),
       body = Value(body),
       createdAt = Value(createdAt);
  static Insertable<Note> custom({
    Expression<String>? id,
    Expression<String>? campaignId,
    Expression<String>? sessionId,
    Expression<String>? kind,
    Expression<String>? body,
    Expression<String>? status,
    Expression<String>? source,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (campaignId != null) 'campaign_id': campaignId,
      if (sessionId != null) 'session_id': sessionId,
      if (kind != null) 'kind': kind,
      if (body != null) 'body': body,
      if (status != null) 'status': status,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotesCompanion copyWith({
    Value<String>? id,
    Value<String>? campaignId,
    Value<String?>? sessionId,
    Value<String>? kind,
    Value<String>? body,
    Value<String>? status,
    Value<String>? source,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return NotesCompanion(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      sessionId: sessionId ?? this.sessionId,
      kind: kind ?? this.kind,
      body: body ?? this.body,
      status: status ?? this.status,
      source: source ?? this.source,
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
    if (campaignId.present) {
      map['campaign_id'] = Variable<String>(campaignId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
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
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('campaignId: $campaignId, ')
          ..write('sessionId: $sessionId, ')
          ..write('kind: $kind, ')
          ..write('body: $body, ')
          ..write('status: $status, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RelationsTable extends Relations
    with TableInfo<$RelationsTable, Relation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RelationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _campaignIdMeta = const VerificationMeta(
    'campaignId',
  );
  @override
  late final GeneratedColumn<String> campaignId = GeneratedColumn<String>(
    'campaign_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES campaigns (id)',
    ),
  );
  static const VerificationMeta _fromIdMeta = const VerificationMeta('fromId');
  @override
  late final GeneratedColumn<String> fromId = GeneratedColumn<String>(
    'from_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES entities (id)',
    ),
  );
  static const VerificationMeta _toIdMeta = const VerificationMeta('toId');
  @override
  late final GeneratedColumn<String> toId = GeneratedColumn<String>(
    'to_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES entities (id)',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [id, campaignId, fromId, toId, label];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'relations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Relation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('campaign_id')) {
      context.handle(
        _campaignIdMeta,
        campaignId.isAcceptableOrUnknown(data['campaign_id']!, _campaignIdMeta),
      );
    } else if (isInserting) {
      context.missing(_campaignIdMeta);
    }
    if (data.containsKey('from_id')) {
      context.handle(
        _fromIdMeta,
        fromId.isAcceptableOrUnknown(data['from_id']!, _fromIdMeta),
      );
    } else if (isInserting) {
      context.missing(_fromIdMeta);
    }
    if (data.containsKey('to_id')) {
      context.handle(
        _toIdMeta,
        toId.isAcceptableOrUnknown(data['to_id']!, _toIdMeta),
      );
    } else if (isInserting) {
      context.missing(_toIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Relation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Relation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      campaignId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}campaign_id'],
      )!,
      fromId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_id'],
      )!,
      toId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
    );
  }

  @override
  $RelationsTable createAlias(String alias) {
    return $RelationsTable(attachedDatabase, alias);
  }
}

class Relation extends DataClass implements Insertable<Relation> {
  final String id;
  final String campaignId;
  final String fromId;
  final String toId;
  final String label;
  const Relation({
    required this.id,
    required this.campaignId,
    required this.fromId,
    required this.toId,
    required this.label,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['campaign_id'] = Variable<String>(campaignId);
    map['from_id'] = Variable<String>(fromId);
    map['to_id'] = Variable<String>(toId);
    map['label'] = Variable<String>(label);
    return map;
  }

  RelationsCompanion toCompanion(bool nullToAbsent) {
    return RelationsCompanion(
      id: Value(id),
      campaignId: Value(campaignId),
      fromId: Value(fromId),
      toId: Value(toId),
      label: Value(label),
    );
  }

  factory Relation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Relation(
      id: serializer.fromJson<String>(json['id']),
      campaignId: serializer.fromJson<String>(json['campaignId']),
      fromId: serializer.fromJson<String>(json['fromId']),
      toId: serializer.fromJson<String>(json['toId']),
      label: serializer.fromJson<String>(json['label']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'campaignId': serializer.toJson<String>(campaignId),
      'fromId': serializer.toJson<String>(fromId),
      'toId': serializer.toJson<String>(toId),
      'label': serializer.toJson<String>(label),
    };
  }

  Relation copyWith({
    String? id,
    String? campaignId,
    String? fromId,
    String? toId,
    String? label,
  }) => Relation(
    id: id ?? this.id,
    campaignId: campaignId ?? this.campaignId,
    fromId: fromId ?? this.fromId,
    toId: toId ?? this.toId,
    label: label ?? this.label,
  );
  Relation copyWithCompanion(RelationsCompanion data) {
    return Relation(
      id: data.id.present ? data.id.value : this.id,
      campaignId: data.campaignId.present
          ? data.campaignId.value
          : this.campaignId,
      fromId: data.fromId.present ? data.fromId.value : this.fromId,
      toId: data.toId.present ? data.toId.value : this.toId,
      label: data.label.present ? data.label.value : this.label,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Relation(')
          ..write('id: $id, ')
          ..write('campaignId: $campaignId, ')
          ..write('fromId: $fromId, ')
          ..write('toId: $toId, ')
          ..write('label: $label')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, campaignId, fromId, toId, label);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Relation &&
          other.id == this.id &&
          other.campaignId == this.campaignId &&
          other.fromId == this.fromId &&
          other.toId == this.toId &&
          other.label == this.label);
}

class RelationsCompanion extends UpdateCompanion<Relation> {
  final Value<String> id;
  final Value<String> campaignId;
  final Value<String> fromId;
  final Value<String> toId;
  final Value<String> label;
  final Value<int> rowid;
  const RelationsCompanion({
    this.id = const Value.absent(),
    this.campaignId = const Value.absent(),
    this.fromId = const Value.absent(),
    this.toId = const Value.absent(),
    this.label = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RelationsCompanion.insert({
    required String id,
    required String campaignId,
    required String fromId,
    required String toId,
    this.label = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       campaignId = Value(campaignId),
       fromId = Value(fromId),
       toId = Value(toId);
  static Insertable<Relation> custom({
    Expression<String>? id,
    Expression<String>? campaignId,
    Expression<String>? fromId,
    Expression<String>? toId,
    Expression<String>? label,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (campaignId != null) 'campaign_id': campaignId,
      if (fromId != null) 'from_id': fromId,
      if (toId != null) 'to_id': toId,
      if (label != null) 'label': label,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RelationsCompanion copyWith({
    Value<String>? id,
    Value<String>? campaignId,
    Value<String>? fromId,
    Value<String>? toId,
    Value<String>? label,
    Value<int>? rowid,
  }) {
    return RelationsCompanion(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      fromId: fromId ?? this.fromId,
      toId: toId ?? this.toId,
      label: label ?? this.label,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (campaignId.present) {
      map['campaign_id'] = Variable<String>(campaignId.value);
    }
    if (fromId.present) {
      map['from_id'] = Variable<String>(fromId.value);
    }
    if (toId.present) {
      map['to_id'] = Variable<String>(toId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RelationsCompanion(')
          ..write('id: $id, ')
          ..write('campaignId: $campaignId, ')
          ..write('fromId: $fromId, ')
          ..write('toId: $toId, ')
          ..write('label: $label, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FactsTable extends Facts with TableInfo<$FactsTable, Fact> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _campaignIdMeta = const VerificationMeta(
    'campaignId',
  );
  @override
  late final GeneratedColumn<String> campaignId = GeneratedColumn<String>(
    'campaign_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES campaigns (id)',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id)',
    ),
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
  static const VerificationMeta _actorMeta = const VerificationMeta('actor');
  @override
  late final GeneratedColumn<String> actor = GeneratedColumn<String>(
    'actor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  @override
  late final GeneratedColumn<String> target = GeneratedColumn<String>(
    'target',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sideMeta = const VerificationMeta('side');
  @override
  late final GeneratedColumn<String> side = GeneratedColumn<String>(
    'side',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _text_Meta = const VerificationMeta('text_');
  @override
  late final GeneratedColumn<String> text_ = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _atMsMeta = const VerificationMeta('atMs');
  @override
  late final GeneratedColumn<int> atMs = GeneratedColumn<int>(
    'at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quoteMeta = const VerificationMeta('quote');
  @override
  late final GeneratedColumn<String> quote = GeneratedColumn<String>(
    'quote',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('suggested'),
  );
  static const VerificationMeta _appliedMeta = const VerificationMeta(
    'applied',
  );
  @override
  late final GeneratedColumn<bool> applied = GeneratedColumn<bool>(
    'applied',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("applied" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    campaignId,
    sessionId,
    kind,
    actor,
    target,
    side,
    amount,
    text_,
    atMs,
    quote,
    status,
    applied,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'facts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Fact> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('campaign_id')) {
      context.handle(
        _campaignIdMeta,
        campaignId.isAcceptableOrUnknown(data['campaign_id']!, _campaignIdMeta),
      );
    } else if (isInserting) {
      context.missing(_campaignIdMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('actor')) {
      context.handle(
        _actorMeta,
        actor.isAcceptableOrUnknown(data['actor']!, _actorMeta),
      );
    }
    if (data.containsKey('target')) {
      context.handle(
        _targetMeta,
        target.isAcceptableOrUnknown(data['target']!, _targetMeta),
      );
    }
    if (data.containsKey('side')) {
      context.handle(
        _sideMeta,
        side.isAcceptableOrUnknown(data['side']!, _sideMeta),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    }
    if (data.containsKey('text')) {
      context.handle(
        _text_Meta,
        text_.isAcceptableOrUnknown(data['text']!, _text_Meta),
      );
    }
    if (data.containsKey('at_ms')) {
      context.handle(
        _atMsMeta,
        atMs.isAcceptableOrUnknown(data['at_ms']!, _atMsMeta),
      );
    }
    if (data.containsKey('quote')) {
      context.handle(
        _quoteMeta,
        quote.isAcceptableOrUnknown(data['quote']!, _quoteMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('applied')) {
      context.handle(
        _appliedMeta,
        applied.isAcceptableOrUnknown(data['applied']!, _appliedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Fact map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Fact(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      campaignId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}campaign_id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      actor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor'],
      )!,
      target: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target'],
      )!,
      side: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}side'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      ),
      text_: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
      atMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}at_ms'],
      ),
      quote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quote'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      applied: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}applied'],
      )!,
    );
  }

  @override
  $FactsTable createAlias(String alias) {
    return $FactsTable(attachedDatabase, alias);
  }
}

class Fact extends DataClass implements Insertable<Fact> {
  final String id;
  final String campaignId;
  final String sessionId;

  /// damage | heal | xp | condition | loot
  final String kind;

  /// Quem causou (ou quem ganhou, no XP) e quem sofreu.
  final String actor;
  final String target;

  /// hero | enemy | neutral — de que lado está o ALVO (quem sofreu/ganhou).
  final String side;
  final int? amount;
  final String text_;
  final int? atMs;
  final String quote;

  /// suggested | confirmed
  final String status;

  /// Já foi somado/subtraído da ficha do herói?
  final bool applied;
  const Fact({
    required this.id,
    required this.campaignId,
    required this.sessionId,
    required this.kind,
    required this.actor,
    required this.target,
    required this.side,
    this.amount,
    required this.text_,
    this.atMs,
    required this.quote,
    required this.status,
    required this.applied,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['campaign_id'] = Variable<String>(campaignId);
    map['session_id'] = Variable<String>(sessionId);
    map['kind'] = Variable<String>(kind);
    map['actor'] = Variable<String>(actor);
    map['target'] = Variable<String>(target);
    map['side'] = Variable<String>(side);
    if (!nullToAbsent || amount != null) {
      map['amount'] = Variable<int>(amount);
    }
    map['text'] = Variable<String>(text_);
    if (!nullToAbsent || atMs != null) {
      map['at_ms'] = Variable<int>(atMs);
    }
    map['quote'] = Variable<String>(quote);
    map['status'] = Variable<String>(status);
    map['applied'] = Variable<bool>(applied);
    return map;
  }

  FactsCompanion toCompanion(bool nullToAbsent) {
    return FactsCompanion(
      id: Value(id),
      campaignId: Value(campaignId),
      sessionId: Value(sessionId),
      kind: Value(kind),
      actor: Value(actor),
      target: Value(target),
      side: Value(side),
      amount: amount == null && nullToAbsent
          ? const Value.absent()
          : Value(amount),
      text_: Value(text_),
      atMs: atMs == null && nullToAbsent ? const Value.absent() : Value(atMs),
      quote: Value(quote),
      status: Value(status),
      applied: Value(applied),
    );
  }

  factory Fact.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Fact(
      id: serializer.fromJson<String>(json['id']),
      campaignId: serializer.fromJson<String>(json['campaignId']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      kind: serializer.fromJson<String>(json['kind']),
      actor: serializer.fromJson<String>(json['actor']),
      target: serializer.fromJson<String>(json['target']),
      side: serializer.fromJson<String>(json['side']),
      amount: serializer.fromJson<int?>(json['amount']),
      text_: serializer.fromJson<String>(json['text_']),
      atMs: serializer.fromJson<int?>(json['atMs']),
      quote: serializer.fromJson<String>(json['quote']),
      status: serializer.fromJson<String>(json['status']),
      applied: serializer.fromJson<bool>(json['applied']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'campaignId': serializer.toJson<String>(campaignId),
      'sessionId': serializer.toJson<String>(sessionId),
      'kind': serializer.toJson<String>(kind),
      'actor': serializer.toJson<String>(actor),
      'target': serializer.toJson<String>(target),
      'side': serializer.toJson<String>(side),
      'amount': serializer.toJson<int?>(amount),
      'text_': serializer.toJson<String>(text_),
      'atMs': serializer.toJson<int?>(atMs),
      'quote': serializer.toJson<String>(quote),
      'status': serializer.toJson<String>(status),
      'applied': serializer.toJson<bool>(applied),
    };
  }

  Fact copyWith({
    String? id,
    String? campaignId,
    String? sessionId,
    String? kind,
    String? actor,
    String? target,
    String? side,
    Value<int?> amount = const Value.absent(),
    String? text_,
    Value<int?> atMs = const Value.absent(),
    String? quote,
    String? status,
    bool? applied,
  }) => Fact(
    id: id ?? this.id,
    campaignId: campaignId ?? this.campaignId,
    sessionId: sessionId ?? this.sessionId,
    kind: kind ?? this.kind,
    actor: actor ?? this.actor,
    target: target ?? this.target,
    side: side ?? this.side,
    amount: amount.present ? amount.value : this.amount,
    text_: text_ ?? this.text_,
    atMs: atMs.present ? atMs.value : this.atMs,
    quote: quote ?? this.quote,
    status: status ?? this.status,
    applied: applied ?? this.applied,
  );
  Fact copyWithCompanion(FactsCompanion data) {
    return Fact(
      id: data.id.present ? data.id.value : this.id,
      campaignId: data.campaignId.present
          ? data.campaignId.value
          : this.campaignId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      kind: data.kind.present ? data.kind.value : this.kind,
      actor: data.actor.present ? data.actor.value : this.actor,
      target: data.target.present ? data.target.value : this.target,
      side: data.side.present ? data.side.value : this.side,
      amount: data.amount.present ? data.amount.value : this.amount,
      text_: data.text_.present ? data.text_.value : this.text_,
      atMs: data.atMs.present ? data.atMs.value : this.atMs,
      quote: data.quote.present ? data.quote.value : this.quote,
      status: data.status.present ? data.status.value : this.status,
      applied: data.applied.present ? data.applied.value : this.applied,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Fact(')
          ..write('id: $id, ')
          ..write('campaignId: $campaignId, ')
          ..write('sessionId: $sessionId, ')
          ..write('kind: $kind, ')
          ..write('actor: $actor, ')
          ..write('target: $target, ')
          ..write('side: $side, ')
          ..write('amount: $amount, ')
          ..write('text_: $text_, ')
          ..write('atMs: $atMs, ')
          ..write('quote: $quote, ')
          ..write('status: $status, ')
          ..write('applied: $applied')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    campaignId,
    sessionId,
    kind,
    actor,
    target,
    side,
    amount,
    text_,
    atMs,
    quote,
    status,
    applied,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Fact &&
          other.id == this.id &&
          other.campaignId == this.campaignId &&
          other.sessionId == this.sessionId &&
          other.kind == this.kind &&
          other.actor == this.actor &&
          other.target == this.target &&
          other.side == this.side &&
          other.amount == this.amount &&
          other.text_ == this.text_ &&
          other.atMs == this.atMs &&
          other.quote == this.quote &&
          other.status == this.status &&
          other.applied == this.applied);
}

class FactsCompanion extends UpdateCompanion<Fact> {
  final Value<String> id;
  final Value<String> campaignId;
  final Value<String> sessionId;
  final Value<String> kind;
  final Value<String> actor;
  final Value<String> target;
  final Value<String> side;
  final Value<int?> amount;
  final Value<String> text_;
  final Value<int?> atMs;
  final Value<String> quote;
  final Value<String> status;
  final Value<bool> applied;
  final Value<int> rowid;
  const FactsCompanion({
    this.id = const Value.absent(),
    this.campaignId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.kind = const Value.absent(),
    this.actor = const Value.absent(),
    this.target = const Value.absent(),
    this.side = const Value.absent(),
    this.amount = const Value.absent(),
    this.text_ = const Value.absent(),
    this.atMs = const Value.absent(),
    this.quote = const Value.absent(),
    this.status = const Value.absent(),
    this.applied = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FactsCompanion.insert({
    required String id,
    required String campaignId,
    required String sessionId,
    required String kind,
    this.actor = const Value.absent(),
    this.target = const Value.absent(),
    this.side = const Value.absent(),
    this.amount = const Value.absent(),
    this.text_ = const Value.absent(),
    this.atMs = const Value.absent(),
    this.quote = const Value.absent(),
    this.status = const Value.absent(),
    this.applied = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       campaignId = Value(campaignId),
       sessionId = Value(sessionId),
       kind = Value(kind);
  static Insertable<Fact> custom({
    Expression<String>? id,
    Expression<String>? campaignId,
    Expression<String>? sessionId,
    Expression<String>? kind,
    Expression<String>? actor,
    Expression<String>? target,
    Expression<String>? side,
    Expression<int>? amount,
    Expression<String>? text_,
    Expression<int>? atMs,
    Expression<String>? quote,
    Expression<String>? status,
    Expression<bool>? applied,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (campaignId != null) 'campaign_id': campaignId,
      if (sessionId != null) 'session_id': sessionId,
      if (kind != null) 'kind': kind,
      if (actor != null) 'actor': actor,
      if (target != null) 'target': target,
      if (side != null) 'side': side,
      if (amount != null) 'amount': amount,
      if (text_ != null) 'text': text_,
      if (atMs != null) 'at_ms': atMs,
      if (quote != null) 'quote': quote,
      if (status != null) 'status': status,
      if (applied != null) 'applied': applied,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FactsCompanion copyWith({
    Value<String>? id,
    Value<String>? campaignId,
    Value<String>? sessionId,
    Value<String>? kind,
    Value<String>? actor,
    Value<String>? target,
    Value<String>? side,
    Value<int?>? amount,
    Value<String>? text_,
    Value<int?>? atMs,
    Value<String>? quote,
    Value<String>? status,
    Value<bool>? applied,
    Value<int>? rowid,
  }) {
    return FactsCompanion(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      sessionId: sessionId ?? this.sessionId,
      kind: kind ?? this.kind,
      actor: actor ?? this.actor,
      target: target ?? this.target,
      side: side ?? this.side,
      amount: amount ?? this.amount,
      text_: text_ ?? this.text_,
      atMs: atMs ?? this.atMs,
      quote: quote ?? this.quote,
      status: status ?? this.status,
      applied: applied ?? this.applied,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (campaignId.present) {
      map['campaign_id'] = Variable<String>(campaignId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (actor.present) {
      map['actor'] = Variable<String>(actor.value);
    }
    if (target.present) {
      map['target'] = Variable<String>(target.value);
    }
    if (side.present) {
      map['side'] = Variable<String>(side.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (text_.present) {
      map['text'] = Variable<String>(text_.value);
    }
    if (atMs.present) {
      map['at_ms'] = Variable<int>(atMs.value);
    }
    if (quote.present) {
      map['quote'] = Variable<String>(quote.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (applied.present) {
      map['applied'] = Variable<bool>(applied.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FactsCompanion(')
          ..write('id: $id, ')
          ..write('campaignId: $campaignId, ')
          ..write('sessionId: $sessionId, ')
          ..write('kind: $kind, ')
          ..write('actor: $actor, ')
          ..write('target: $target, ')
          ..write('side: $side, ')
          ..write('amount: $amount, ')
          ..write('text_: $text_, ')
          ..write('atMs: $atMs, ')
          ..write('quote: $quote, ')
          ..write('status: $status, ')
          ..write('applied: $applied, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CampaignsTable campaigns = $CampaignsTable(this);
  late final $HeroesTable heroes = $HeroesTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $AudiosTable audios = $AudiosTable(this);
  late final $SegmentsTable segments = $SegmentsTable(this);
  late final $EntitiesTable entities = $EntitiesTable(this);
  late final $EntityHistoryTable entityHistory = $EntityHistoryTable(this);
  late final $EventsTable events = $EventsTable(this);
  late final $MentionsTable mentions = $MentionsTable(this);
  late final $UsageLogTable usageLog = $UsageLogTable(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $RelationsTable relations = $RelationsTable(this);
  late final $FactsTable facts = $FactsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    campaigns,
    heroes,
    sessions,
    audios,
    segments,
    entities,
    entityHistory,
    events,
    mentions,
    usageLog,
    notes,
    relations,
    facts,
  ];
}

typedef $$CampaignsTableCreateCompanionBuilder =
    CampaignsCompanion Function({
      required String id,
      required String name,
      Value<String> system,
      Value<String> description,
      Value<String?> coverPath,
      Value<String> language,
      Value<String> players,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CampaignsTableUpdateCompanionBuilder =
    CampaignsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> system,
      Value<String> description,
      Value<String?> coverPath,
      Value<String> language,
      Value<String> players,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$CampaignsTableReferences
    extends BaseReferences<_$AppDatabase, $CampaignsTable, Campaign> {
  $$CampaignsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$HeroesTable, List<Heroe>> _heroesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.heroes,
    aliasName: $_aliasNameGenerator(db.campaigns.id, db.heroes.campaignId),
  );

  $$HeroesTableProcessedTableManager get heroesRefs {
    final manager = $$HeroesTableTableManager(
      $_db,
      $_db.heroes,
    ).filter((f) => f.campaignId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_heroesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SessionsTable, List<Session>> _sessionsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sessions,
    aliasName: $_aliasNameGenerator(db.campaigns.id, db.sessions.campaignId),
  );

  $$SessionsTableProcessedTableManager get sessionsRefs {
    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.campaignId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EntitiesTable, List<Entity>> _entitiesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.entities,
    aliasName: $_aliasNameGenerator(db.campaigns.id, db.entities.campaignId),
  );

  $$EntitiesTableProcessedTableManager get entitiesRefs {
    final manager = $$EntitiesTableTableManager(
      $_db,
      $_db.entities,
    ).filter((f) => f.campaignId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_entitiesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$NotesTable, List<Note>> _notesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.notes,
    aliasName: $_aliasNameGenerator(db.campaigns.id, db.notes.campaignId),
  );

  $$NotesTableProcessedTableManager get notesRefs {
    final manager = $$NotesTableTableManager(
      $_db,
      $_db.notes,
    ).filter((f) => f.campaignId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_notesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RelationsTable, List<Relation>>
  _relationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.relations,
    aliasName: $_aliasNameGenerator(db.campaigns.id, db.relations.campaignId),
  );

  $$RelationsTableProcessedTableManager get relationsRefs {
    final manager = $$RelationsTableTableManager(
      $_db,
      $_db.relations,
    ).filter((f) => f.campaignId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_relationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FactsTable, List<Fact>> _factsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.facts,
    aliasName: $_aliasNameGenerator(db.campaigns.id, db.facts.campaignId),
  );

  $$FactsTableProcessedTableManager get factsRefs {
    final manager = $$FactsTableTableManager(
      $_db,
      $_db.facts,
    ).filter((f) => f.campaignId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_factsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CampaignsTableFilterComposer
    extends Composer<_$AppDatabase, $CampaignsTable> {
  $$CampaignsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get system => $composableBuilder(
    column: $table.system,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverPath => $composableBuilder(
    column: $table.coverPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get players => $composableBuilder(
    column: $table.players,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> heroesRefs(
    Expression<bool> Function($$HeroesTableFilterComposer f) f,
  ) {
    final $$HeroesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.heroes,
      getReferencedColumn: (t) => t.campaignId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HeroesTableFilterComposer(
            $db: $db,
            $table: $db.heroes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sessionsRefs(
    Expression<bool> Function($$SessionsTableFilterComposer f) f,
  ) {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.campaignId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> entitiesRefs(
    Expression<bool> Function($$EntitiesTableFilterComposer f) f,
  ) {
    final $$EntitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entities,
      getReferencedColumn: (t) => t.campaignId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntitiesTableFilterComposer(
            $db: $db,
            $table: $db.entities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> notesRefs(
    Expression<bool> Function($$NotesTableFilterComposer f) f,
  ) {
    final $$NotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.campaignId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableFilterComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> relationsRefs(
    Expression<bool> Function($$RelationsTableFilterComposer f) f,
  ) {
    final $$RelationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.relations,
      getReferencedColumn: (t) => t.campaignId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RelationsTableFilterComposer(
            $db: $db,
            $table: $db.relations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> factsRefs(
    Expression<bool> Function($$FactsTableFilterComposer f) f,
  ) {
    final $$FactsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.facts,
      getReferencedColumn: (t) => t.campaignId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FactsTableFilterComposer(
            $db: $db,
            $table: $db.facts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CampaignsTableOrderingComposer
    extends Composer<_$AppDatabase, $CampaignsTable> {
  $$CampaignsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get system => $composableBuilder(
    column: $table.system,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverPath => $composableBuilder(
    column: $table.coverPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get players => $composableBuilder(
    column: $table.players,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CampaignsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CampaignsTable> {
  $$CampaignsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get system =>
      $composableBuilder(column: $table.system, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverPath =>
      $composableBuilder(column: $table.coverPath, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get players =>
      $composableBuilder(column: $table.players, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> heroesRefs<T extends Object>(
    Expression<T> Function($$HeroesTableAnnotationComposer a) f,
  ) {
    final $$HeroesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.heroes,
      getReferencedColumn: (t) => t.campaignId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HeroesTableAnnotationComposer(
            $db: $db,
            $table: $db.heroes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sessionsRefs<T extends Object>(
    Expression<T> Function($$SessionsTableAnnotationComposer a) f,
  ) {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.campaignId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> entitiesRefs<T extends Object>(
    Expression<T> Function($$EntitiesTableAnnotationComposer a) f,
  ) {
    final $$EntitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entities,
      getReferencedColumn: (t) => t.campaignId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.entities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> notesRefs<T extends Object>(
    Expression<T> Function($$NotesTableAnnotationComposer a) f,
  ) {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.campaignId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableAnnotationComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> relationsRefs<T extends Object>(
    Expression<T> Function($$RelationsTableAnnotationComposer a) f,
  ) {
    final $$RelationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.relations,
      getReferencedColumn: (t) => t.campaignId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RelationsTableAnnotationComposer(
            $db: $db,
            $table: $db.relations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> factsRefs<T extends Object>(
    Expression<T> Function($$FactsTableAnnotationComposer a) f,
  ) {
    final $$FactsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.facts,
      getReferencedColumn: (t) => t.campaignId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FactsTableAnnotationComposer(
            $db: $db,
            $table: $db.facts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CampaignsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CampaignsTable,
          Campaign,
          $$CampaignsTableFilterComposer,
          $$CampaignsTableOrderingComposer,
          $$CampaignsTableAnnotationComposer,
          $$CampaignsTableCreateCompanionBuilder,
          $$CampaignsTableUpdateCompanionBuilder,
          (Campaign, $$CampaignsTableReferences),
          Campaign,
          PrefetchHooks Function({
            bool heroesRefs,
            bool sessionsRefs,
            bool entitiesRefs,
            bool notesRefs,
            bool relationsRefs,
            bool factsRefs,
          })
        > {
  $$CampaignsTableTableManager(_$AppDatabase db, $CampaignsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CampaignsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CampaignsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CampaignsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> system = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String?> coverPath = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String> players = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CampaignsCompanion(
                id: id,
                name: name,
                system: system,
                description: description,
                coverPath: coverPath,
                language: language,
                players: players,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> system = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String?> coverPath = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String> players = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CampaignsCompanion.insert(
                id: id,
                name: name,
                system: system,
                description: description,
                coverPath: coverPath,
                language: language,
                players: players,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CampaignsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                heroesRefs = false,
                sessionsRefs = false,
                entitiesRefs = false,
                notesRefs = false,
                relationsRefs = false,
                factsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (heroesRefs) db.heroes,
                    if (sessionsRefs) db.sessions,
                    if (entitiesRefs) db.entities,
                    if (notesRefs) db.notes,
                    if (relationsRefs) db.relations,
                    if (factsRefs) db.facts,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (heroesRefs)
                        await $_getPrefetchedData<
                          Campaign,
                          $CampaignsTable,
                          Heroe
                        >(
                          currentTable: table,
                          referencedTable: $$CampaignsTableReferences
                              ._heroesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CampaignsTableReferences(
                                db,
                                table,
                                p0,
                              ).heroesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.campaignId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (sessionsRefs)
                        await $_getPrefetchedData<
                          Campaign,
                          $CampaignsTable,
                          Session
                        >(
                          currentTable: table,
                          referencedTable: $$CampaignsTableReferences
                              ._sessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CampaignsTableReferences(
                                db,
                                table,
                                p0,
                              ).sessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.campaignId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (entitiesRefs)
                        await $_getPrefetchedData<
                          Campaign,
                          $CampaignsTable,
                          Entity
                        >(
                          currentTable: table,
                          referencedTable: $$CampaignsTableReferences
                              ._entitiesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CampaignsTableReferences(
                                db,
                                table,
                                p0,
                              ).entitiesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.campaignId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (notesRefs)
                        await $_getPrefetchedData<
                          Campaign,
                          $CampaignsTable,
                          Note
                        >(
                          currentTable: table,
                          referencedTable: $$CampaignsTableReferences
                              ._notesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CampaignsTableReferences(
                                db,
                                table,
                                p0,
                              ).notesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.campaignId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (relationsRefs)
                        await $_getPrefetchedData<
                          Campaign,
                          $CampaignsTable,
                          Relation
                        >(
                          currentTable: table,
                          referencedTable: $$CampaignsTableReferences
                              ._relationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CampaignsTableReferences(
                                db,
                                table,
                                p0,
                              ).relationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.campaignId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (factsRefs)
                        await $_getPrefetchedData<
                          Campaign,
                          $CampaignsTable,
                          Fact
                        >(
                          currentTable: table,
                          referencedTable: $$CampaignsTableReferences
                              ._factsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CampaignsTableReferences(
                                db,
                                table,
                                p0,
                              ).factsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.campaignId == item.id,
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

typedef $$CampaignsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CampaignsTable,
      Campaign,
      $$CampaignsTableFilterComposer,
      $$CampaignsTableOrderingComposer,
      $$CampaignsTableAnnotationComposer,
      $$CampaignsTableCreateCompanionBuilder,
      $$CampaignsTableUpdateCompanionBuilder,
      (Campaign, $$CampaignsTableReferences),
      Campaign,
      PrefetchHooks Function({
        bool heroesRefs,
        bool sessionsRefs,
        bool entitiesRefs,
        bool notesRefs,
        bool relationsRefs,
        bool factsRefs,
      })
    >;
typedef $$HeroesTableCreateCompanionBuilder =
    HeroesCompanion Function({
      required String id,
      required String campaignId,
      Value<String> player,
      required String name,
      Value<String> heroClass,
      Value<String> race,
      Value<int> level,
      Value<String> story,
      Value<String?> photoPath,
      Value<String> notes,
      Value<String?> sheetPath,
      Value<String> extra,
      Value<int?> hpCurrent,
      Value<int?> hpMax,
      Value<int> xp,
      Value<int> rowid,
    });
typedef $$HeroesTableUpdateCompanionBuilder =
    HeroesCompanion Function({
      Value<String> id,
      Value<String> campaignId,
      Value<String> player,
      Value<String> name,
      Value<String> heroClass,
      Value<String> race,
      Value<int> level,
      Value<String> story,
      Value<String?> photoPath,
      Value<String> notes,
      Value<String?> sheetPath,
      Value<String> extra,
      Value<int?> hpCurrent,
      Value<int?> hpMax,
      Value<int> xp,
      Value<int> rowid,
    });

final class $$HeroesTableReferences
    extends BaseReferences<_$AppDatabase, $HeroesTable, Heroe> {
  $$HeroesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CampaignsTable _campaignIdTable(_$AppDatabase db) => db.campaigns
      .createAlias($_aliasNameGenerator(db.heroes.campaignId, db.campaigns.id));

  $$CampaignsTableProcessedTableManager get campaignId {
    final $_column = $_itemColumn<String>('campaign_id')!;

    final manager = $$CampaignsTableTableManager(
      $_db,
      $_db.campaigns,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_campaignIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HeroesTableFilterComposer
    extends Composer<_$AppDatabase, $HeroesTable> {
  $$HeroesTableFilterComposer({
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

  ColumnFilters<String> get player => $composableBuilder(
    column: $table.player,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get heroClass => $composableBuilder(
    column: $table.heroClass,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get race => $composableBuilder(
    column: $table.race,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get story => $composableBuilder(
    column: $table.story,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sheetPath => $composableBuilder(
    column: $table.sheetPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extra => $composableBuilder(
    column: $table.extra,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hpCurrent => $composableBuilder(
    column: $table.hpCurrent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hpMax => $composableBuilder(
    column: $table.hpMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xp => $composableBuilder(
    column: $table.xp,
    builder: (column) => ColumnFilters(column),
  );

  $$CampaignsTableFilterComposer get campaignId {
    final $$CampaignsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.campaignId,
      referencedTable: $db.campaigns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CampaignsTableFilterComposer(
            $db: $db,
            $table: $db.campaigns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HeroesTableOrderingComposer
    extends Composer<_$AppDatabase, $HeroesTable> {
  $$HeroesTableOrderingComposer({
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

  ColumnOrderings<String> get player => $composableBuilder(
    column: $table.player,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get heroClass => $composableBuilder(
    column: $table.heroClass,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get race => $composableBuilder(
    column: $table.race,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get story => $composableBuilder(
    column: $table.story,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sheetPath => $composableBuilder(
    column: $table.sheetPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extra => $composableBuilder(
    column: $table.extra,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hpCurrent => $composableBuilder(
    column: $table.hpCurrent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hpMax => $composableBuilder(
    column: $table.hpMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xp => $composableBuilder(
    column: $table.xp,
    builder: (column) => ColumnOrderings(column),
  );

  $$CampaignsTableOrderingComposer get campaignId {
    final $$CampaignsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.campaignId,
      referencedTable: $db.campaigns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CampaignsTableOrderingComposer(
            $db: $db,
            $table: $db.campaigns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HeroesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HeroesTable> {
  $$HeroesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get player =>
      $composableBuilder(column: $table.player, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get heroClass =>
      $composableBuilder(column: $table.heroClass, builder: (column) => column);

  GeneratedColumn<String> get race =>
      $composableBuilder(column: $table.race, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get story =>
      $composableBuilder(column: $table.story, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get sheetPath =>
      $composableBuilder(column: $table.sheetPath, builder: (column) => column);

  GeneratedColumn<String> get extra =>
      $composableBuilder(column: $table.extra, builder: (column) => column);

  GeneratedColumn<int> get hpCurrent =>
      $composableBuilder(column: $table.hpCurrent, builder: (column) => column);

  GeneratedColumn<int> get hpMax =>
      $composableBuilder(column: $table.hpMax, builder: (column) => column);

  GeneratedColumn<int> get xp =>
      $composableBuilder(column: $table.xp, builder: (column) => column);

  $$CampaignsTableAnnotationComposer get campaignId {
    final $$CampaignsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.campaignId,
      referencedTable: $db.campaigns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CampaignsTableAnnotationComposer(
            $db: $db,
            $table: $db.campaigns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HeroesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HeroesTable,
          Heroe,
          $$HeroesTableFilterComposer,
          $$HeroesTableOrderingComposer,
          $$HeroesTableAnnotationComposer,
          $$HeroesTableCreateCompanionBuilder,
          $$HeroesTableUpdateCompanionBuilder,
          (Heroe, $$HeroesTableReferences),
          Heroe,
          PrefetchHooks Function({bool campaignId})
        > {
  $$HeroesTableTableManager(_$AppDatabase db, $HeroesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HeroesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HeroesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HeroesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> campaignId = const Value.absent(),
                Value<String> player = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> heroClass = const Value.absent(),
                Value<String> race = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<String> story = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String?> sheetPath = const Value.absent(),
                Value<String> extra = const Value.absent(),
                Value<int?> hpCurrent = const Value.absent(),
                Value<int?> hpMax = const Value.absent(),
                Value<int> xp = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HeroesCompanion(
                id: id,
                campaignId: campaignId,
                player: player,
                name: name,
                heroClass: heroClass,
                race: race,
                level: level,
                story: story,
                photoPath: photoPath,
                notes: notes,
                sheetPath: sheetPath,
                extra: extra,
                hpCurrent: hpCurrent,
                hpMax: hpMax,
                xp: xp,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String campaignId,
                Value<String> player = const Value.absent(),
                required String name,
                Value<String> heroClass = const Value.absent(),
                Value<String> race = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<String> story = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String?> sheetPath = const Value.absent(),
                Value<String> extra = const Value.absent(),
                Value<int?> hpCurrent = const Value.absent(),
                Value<int?> hpMax = const Value.absent(),
                Value<int> xp = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HeroesCompanion.insert(
                id: id,
                campaignId: campaignId,
                player: player,
                name: name,
                heroClass: heroClass,
                race: race,
                level: level,
                story: story,
                photoPath: photoPath,
                notes: notes,
                sheetPath: sheetPath,
                extra: extra,
                hpCurrent: hpCurrent,
                hpMax: hpMax,
                xp: xp,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$HeroesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({campaignId = false}) {
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
                    if (campaignId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.campaignId,
                                referencedTable: $$HeroesTableReferences
                                    ._campaignIdTable(db),
                                referencedColumn: $$HeroesTableReferences
                                    ._campaignIdTable(db)
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

typedef $$HeroesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HeroesTable,
      Heroe,
      $$HeroesTableFilterComposer,
      $$HeroesTableOrderingComposer,
      $$HeroesTableAnnotationComposer,
      $$HeroesTableCreateCompanionBuilder,
      $$HeroesTableUpdateCompanionBuilder,
      (Heroe, $$HeroesTableReferences),
      Heroe,
      PrefetchHooks Function({bool campaignId})
    >;
typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      required String id,
      required String campaignId,
      required int number,
      required DateTime date,
      Value<int> durationSec,
      Value<String> status,
      Value<String> shortSummary,
      Value<String> longSummary,
      Value<String> previouslyOn,
      Value<String> processingMode,
      Value<String> bookmarks,
      Value<int> rowid,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<String> id,
      Value<String> campaignId,
      Value<int> number,
      Value<DateTime> date,
      Value<int> durationSec,
      Value<String> status,
      Value<String> shortSummary,
      Value<String> longSummary,
      Value<String> previouslyOn,
      Value<String> processingMode,
      Value<String> bookmarks,
      Value<int> rowid,
    });

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, Session> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CampaignsTable _campaignIdTable(_$AppDatabase db) =>
      db.campaigns.createAlias(
        $_aliasNameGenerator(db.sessions.campaignId, db.campaigns.id),
      );

  $$CampaignsTableProcessedTableManager get campaignId {
    final $_column = $_itemColumn<String>('campaign_id')!;

    final manager = $$CampaignsTableTableManager(
      $_db,
      $_db.campaigns,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_campaignIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$AudiosTable, List<Audio>> _audiosRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.audios,
    aliasName: $_aliasNameGenerator(db.sessions.id, db.audios.sessionId),
  );

  $$AudiosTableProcessedTableManager get audiosRefs {
    final manager = $$AudiosTableTableManager(
      $_db,
      $_db.audios,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_audiosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SegmentsTable, List<Segment>> _segmentsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.segments,
    aliasName: $_aliasNameGenerator(db.sessions.id, db.segments.sessionId),
  );

  $$SegmentsTableProcessedTableManager get segmentsRefs {
    final manager = $$SegmentsTableTableManager(
      $_db,
      $_db.segments,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_segmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EntityHistoryTable, List<EntityHistoryData>>
  _entityHistoryRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.entityHistory,
    aliasName: $_aliasNameGenerator(db.sessions.id, db.entityHistory.sessionId),
  );

  $$EntityHistoryTableProcessedTableManager get entityHistoryRefs {
    final manager = $$EntityHistoryTableTableManager(
      $_db,
      $_db.entityHistory,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_entityHistoryRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EventsTable, List<Event>> _eventsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.events,
    aliasName: $_aliasNameGenerator(db.sessions.id, db.events.sessionId),
  );

  $$EventsTableProcessedTableManager get eventsRefs {
    final manager = $$EventsTableTableManager(
      $_db,
      $_db.events,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_eventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MentionsTable, List<Mention>> _mentionsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.mentions,
    aliasName: $_aliasNameGenerator(db.sessions.id, db.mentions.sessionId),
  );

  $$MentionsTableProcessedTableManager get mentionsRefs {
    final manager = $$MentionsTableTableManager(
      $_db,
      $_db.mentions,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_mentionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FactsTable, List<Fact>> _factsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.facts,
    aliasName: $_aliasNameGenerator(db.sessions.id, db.facts.sessionId),
  );

  $$FactsTableProcessedTableManager get factsRefs {
    final manager = $$FactsTableTableManager(
      $_db,
      $_db.facts,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_factsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
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

  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shortSummary => $composableBuilder(
    column: $table.shortSummary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get longSummary => $composableBuilder(
    column: $table.longSummary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get previouslyOn => $composableBuilder(
    column: $table.previouslyOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get processingMode => $composableBuilder(
    column: $table.processingMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookmarks => $composableBuilder(
    column: $table.bookmarks,
    builder: (column) => ColumnFilters(column),
  );

  $$CampaignsTableFilterComposer get campaignId {
    final $$CampaignsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.campaignId,
      referencedTable: $db.campaigns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CampaignsTableFilterComposer(
            $db: $db,
            $table: $db.campaigns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> audiosRefs(
    Expression<bool> Function($$AudiosTableFilterComposer f) f,
  ) {
    final $$AudiosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.audios,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudiosTableFilterComposer(
            $db: $db,
            $table: $db.audios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> segmentsRefs(
    Expression<bool> Function($$SegmentsTableFilterComposer f) f,
  ) {
    final $$SegmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.segments,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SegmentsTableFilterComposer(
            $db: $db,
            $table: $db.segments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> entityHistoryRefs(
    Expression<bool> Function($$EntityHistoryTableFilterComposer f) f,
  ) {
    final $$EntityHistoryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entityHistory,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntityHistoryTableFilterComposer(
            $db: $db,
            $table: $db.entityHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> eventsRefs(
    Expression<bool> Function($$EventsTableFilterComposer f) f,
  ) {
    final $$EventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableFilterComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> mentionsRefs(
    Expression<bool> Function($$MentionsTableFilterComposer f) f,
  ) {
    final $$MentionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mentions,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MentionsTableFilterComposer(
            $db: $db,
            $table: $db.mentions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> factsRefs(
    Expression<bool> Function($$FactsTableFilterComposer f) f,
  ) {
    final $$FactsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.facts,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FactsTableFilterComposer(
            $db: $db,
            $table: $db.facts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
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

  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shortSummary => $composableBuilder(
    column: $table.shortSummary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get longSummary => $composableBuilder(
    column: $table.longSummary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get previouslyOn => $composableBuilder(
    column: $table.previouslyOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get processingMode => $composableBuilder(
    column: $table.processingMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookmarks => $composableBuilder(
    column: $table.bookmarks,
    builder: (column) => ColumnOrderings(column),
  );

  $$CampaignsTableOrderingComposer get campaignId {
    final $$CampaignsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.campaignId,
      referencedTable: $db.campaigns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CampaignsTableOrderingComposer(
            $db: $db,
            $table: $db.campaigns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get shortSummary => $composableBuilder(
    column: $table.shortSummary,
    builder: (column) => column,
  );

  GeneratedColumn<String> get longSummary => $composableBuilder(
    column: $table.longSummary,
    builder: (column) => column,
  );

  GeneratedColumn<String> get previouslyOn => $composableBuilder(
    column: $table.previouslyOn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get processingMode => $composableBuilder(
    column: $table.processingMode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bookmarks =>
      $composableBuilder(column: $table.bookmarks, builder: (column) => column);

  $$CampaignsTableAnnotationComposer get campaignId {
    final $$CampaignsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.campaignId,
      referencedTable: $db.campaigns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CampaignsTableAnnotationComposer(
            $db: $db,
            $table: $db.campaigns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> audiosRefs<T extends Object>(
    Expression<T> Function($$AudiosTableAnnotationComposer a) f,
  ) {
    final $$AudiosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.audios,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudiosTableAnnotationComposer(
            $db: $db,
            $table: $db.audios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> segmentsRefs<T extends Object>(
    Expression<T> Function($$SegmentsTableAnnotationComposer a) f,
  ) {
    final $$SegmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.segments,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SegmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.segments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> entityHistoryRefs<T extends Object>(
    Expression<T> Function($$EntityHistoryTableAnnotationComposer a) f,
  ) {
    final $$EntityHistoryTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entityHistory,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntityHistoryTableAnnotationComposer(
            $db: $db,
            $table: $db.entityHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> eventsRefs<T extends Object>(
    Expression<T> Function($$EventsTableAnnotationComposer a) f,
  ) {
    final $$EventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableAnnotationComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> mentionsRefs<T extends Object>(
    Expression<T> Function($$MentionsTableAnnotationComposer a) f,
  ) {
    final $$MentionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mentions,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MentionsTableAnnotationComposer(
            $db: $db,
            $table: $db.mentions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> factsRefs<T extends Object>(
    Expression<T> Function($$FactsTableAnnotationComposer a) f,
  ) {
    final $$FactsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.facts,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FactsTableAnnotationComposer(
            $db: $db,
            $table: $db.facts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, $$SessionsTableReferences),
          Session,
          PrefetchHooks Function({
            bool campaignId,
            bool audiosRefs,
            bool segmentsRefs,
            bool entityHistoryRefs,
            bool eventsRefs,
            bool mentionsRefs,
            bool factsRefs,
          })
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> campaignId = const Value.absent(),
                Value<int> number = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> durationSec = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> shortSummary = const Value.absent(),
                Value<String> longSummary = const Value.absent(),
                Value<String> previouslyOn = const Value.absent(),
                Value<String> processingMode = const Value.absent(),
                Value<String> bookmarks = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                campaignId: campaignId,
                number: number,
                date: date,
                durationSec: durationSec,
                status: status,
                shortSummary: shortSummary,
                longSummary: longSummary,
                previouslyOn: previouslyOn,
                processingMode: processingMode,
                bookmarks: bookmarks,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String campaignId,
                required int number,
                required DateTime date,
                Value<int> durationSec = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> shortSummary = const Value.absent(),
                Value<String> longSummary = const Value.absent(),
                Value<String> previouslyOn = const Value.absent(),
                Value<String> processingMode = const Value.absent(),
                Value<String> bookmarks = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                campaignId: campaignId,
                number: number,
                date: date,
                durationSec: durationSec,
                status: status,
                shortSummary: shortSummary,
                longSummary: longSummary,
                previouslyOn: previouslyOn,
                processingMode: processingMode,
                bookmarks: bookmarks,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                campaignId = false,
                audiosRefs = false,
                segmentsRefs = false,
                entityHistoryRefs = false,
                eventsRefs = false,
                mentionsRefs = false,
                factsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (audiosRefs) db.audios,
                    if (segmentsRefs) db.segments,
                    if (entityHistoryRefs) db.entityHistory,
                    if (eventsRefs) db.events,
                    if (mentionsRefs) db.mentions,
                    if (factsRefs) db.facts,
                  ],
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
                        if (campaignId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.campaignId,
                                    referencedTable: $$SessionsTableReferences
                                        ._campaignIdTable(db),
                                    referencedColumn: $$SessionsTableReferences
                                        ._campaignIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (audiosRefs)
                        await $_getPrefetchedData<
                          Session,
                          $SessionsTable,
                          Audio
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._audiosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).audiosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (segmentsRefs)
                        await $_getPrefetchedData<
                          Session,
                          $SessionsTable,
                          Segment
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._segmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).segmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (entityHistoryRefs)
                        await $_getPrefetchedData<
                          Session,
                          $SessionsTable,
                          EntityHistoryData
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._entityHistoryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).entityHistoryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (eventsRefs)
                        await $_getPrefetchedData<
                          Session,
                          $SessionsTable,
                          Event
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._eventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).eventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (mentionsRefs)
                        await $_getPrefetchedData<
                          Session,
                          $SessionsTable,
                          Mention
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._mentionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).mentionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (factsRefs)
                        await $_getPrefetchedData<
                          Session,
                          $SessionsTable,
                          Fact
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._factsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).factsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
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

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, $$SessionsTableReferences),
      Session,
      PrefetchHooks Function({
        bool campaignId,
        bool audiosRefs,
        bool segmentsRefs,
        bool entityHistoryRefs,
        bool eventsRefs,
        bool mentionsRefs,
        bool factsRefs,
      })
    >;
typedef $$AudiosTableCreateCompanionBuilder =
    AudiosCompanion Function({
      required String id,
      required String sessionId,
      required String filePath,
      required int ord,
      Value<int> durationSec,
      Value<String> origin,
      Value<String?> speaker,
      Value<bool> transcribed,
      Value<int> rowid,
    });
typedef $$AudiosTableUpdateCompanionBuilder =
    AudiosCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String> filePath,
      Value<int> ord,
      Value<int> durationSec,
      Value<String> origin,
      Value<String?> speaker,
      Value<bool> transcribed,
      Value<int> rowid,
    });

final class $$AudiosTableReferences
    extends BaseReferences<_$AppDatabase, $AudiosTable, Audio> {
  $$AudiosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) => db.sessions
      .createAlias($_aliasNameGenerator(db.audios.sessionId, db.sessions.id));

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AudiosTableFilterComposer
    extends Composer<_$AppDatabase, $AudiosTable> {
  $$AudiosTableFilterComposer({
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

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ord => $composableBuilder(
    column: $table.ord,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get speaker => $composableBuilder(
    column: $table.speaker,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get transcribed => $composableBuilder(
    column: $table.transcribed,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AudiosTableOrderingComposer
    extends Composer<_$AppDatabase, $AudiosTable> {
  $$AudiosTableOrderingComposer({
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

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ord => $composableBuilder(
    column: $table.ord,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get speaker => $composableBuilder(
    column: $table.speaker,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get transcribed => $composableBuilder(
    column: $table.transcribed,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AudiosTableAnnotationComposer
    extends Composer<_$AppDatabase, $AudiosTable> {
  $$AudiosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<int> get ord =>
      $composableBuilder(column: $table.ord, builder: (column) => column);

  GeneratedColumn<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => column,
  );

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<String> get speaker =>
      $composableBuilder(column: $table.speaker, builder: (column) => column);

  GeneratedColumn<bool> get transcribed => $composableBuilder(
    column: $table.transcribed,
    builder: (column) => column,
  );

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AudiosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AudiosTable,
          Audio,
          $$AudiosTableFilterComposer,
          $$AudiosTableOrderingComposer,
          $$AudiosTableAnnotationComposer,
          $$AudiosTableCreateCompanionBuilder,
          $$AudiosTableUpdateCompanionBuilder,
          (Audio, $$AudiosTableReferences),
          Audio,
          PrefetchHooks Function({bool sessionId})
        > {
  $$AudiosTableTableManager(_$AppDatabase db, $AudiosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AudiosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AudiosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AudiosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<int> ord = const Value.absent(),
                Value<int> durationSec = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<String?> speaker = const Value.absent(),
                Value<bool> transcribed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AudiosCompanion(
                id: id,
                sessionId: sessionId,
                filePath: filePath,
                ord: ord,
                durationSec: durationSec,
                origin: origin,
                speaker: speaker,
                transcribed: transcribed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required String filePath,
                required int ord,
                Value<int> durationSec = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<String?> speaker = const Value.absent(),
                Value<bool> transcribed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AudiosCompanion.insert(
                id: id,
                sessionId: sessionId,
                filePath: filePath,
                ord: ord,
                durationSec: durationSec,
                origin: origin,
                speaker: speaker,
                transcribed: transcribed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$AudiosTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
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
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$AudiosTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$AudiosTableReferences
                                    ._sessionIdTable(db)
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

typedef $$AudiosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AudiosTable,
      Audio,
      $$AudiosTableFilterComposer,
      $$AudiosTableOrderingComposer,
      $$AudiosTableAnnotationComposer,
      $$AudiosTableCreateCompanionBuilder,
      $$AudiosTableUpdateCompanionBuilder,
      (Audio, $$AudiosTableReferences),
      Audio,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$SegmentsTableCreateCompanionBuilder =
    SegmentsCompanion Function({
      required String id,
      required String sessionId,
      required int startMs,
      required int endMs,
      required String text_,
      Value<String?> speaker,
      Value<double> confidence,
      Value<int> rowid,
    });
typedef $$SegmentsTableUpdateCompanionBuilder =
    SegmentsCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<int> startMs,
      Value<int> endMs,
      Value<String> text_,
      Value<String?> speaker,
      Value<double> confidence,
      Value<int> rowid,
    });

final class $$SegmentsTableReferences
    extends BaseReferences<_$AppDatabase, $SegmentsTable, Segment> {
  $$SegmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) => db.sessions
      .createAlias($_aliasNameGenerator(db.segments.sessionId, db.sessions.id));

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SegmentsTableFilterComposer
    extends Composer<_$AppDatabase, $SegmentsTable> {
  $$SegmentsTableFilterComposer({
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

  ColumnFilters<int> get startMs => $composableBuilder(
    column: $table.startMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMs => $composableBuilder(
    column: $table.endMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get text_ => $composableBuilder(
    column: $table.text_,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get speaker => $composableBuilder(
    column: $table.speaker,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SegmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $SegmentsTable> {
  $$SegmentsTableOrderingComposer({
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

  ColumnOrderings<int> get startMs => $composableBuilder(
    column: $table.startMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMs => $composableBuilder(
    column: $table.endMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get text_ => $composableBuilder(
    column: $table.text_,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get speaker => $composableBuilder(
    column: $table.speaker,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SegmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SegmentsTable> {
  $$SegmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get startMs =>
      $composableBuilder(column: $table.startMs, builder: (column) => column);

  GeneratedColumn<int> get endMs =>
      $composableBuilder(column: $table.endMs, builder: (column) => column);

  GeneratedColumn<String> get text_ =>
      $composableBuilder(column: $table.text_, builder: (column) => column);

  GeneratedColumn<String> get speaker =>
      $composableBuilder(column: $table.speaker, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SegmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SegmentsTable,
          Segment,
          $$SegmentsTableFilterComposer,
          $$SegmentsTableOrderingComposer,
          $$SegmentsTableAnnotationComposer,
          $$SegmentsTableCreateCompanionBuilder,
          $$SegmentsTableUpdateCompanionBuilder,
          (Segment, $$SegmentsTableReferences),
          Segment,
          PrefetchHooks Function({bool sessionId})
        > {
  $$SegmentsTableTableManager(_$AppDatabase db, $SegmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SegmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SegmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SegmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<int> startMs = const Value.absent(),
                Value<int> endMs = const Value.absent(),
                Value<String> text_ = const Value.absent(),
                Value<String?> speaker = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SegmentsCompanion(
                id: id,
                sessionId: sessionId,
                startMs: startMs,
                endMs: endMs,
                text_: text_,
                speaker: speaker,
                confidence: confidence,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required int startMs,
                required int endMs,
                required String text_,
                Value<String?> speaker = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SegmentsCompanion.insert(
                id: id,
                sessionId: sessionId,
                startMs: startMs,
                endMs: endMs,
                text_: text_,
                speaker: speaker,
                confidence: confidence,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SegmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
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
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$SegmentsTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$SegmentsTableReferences
                                    ._sessionIdTable(db)
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

typedef $$SegmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SegmentsTable,
      Segment,
      $$SegmentsTableFilterComposer,
      $$SegmentsTableOrderingComposer,
      $$SegmentsTableAnnotationComposer,
      $$SegmentsTableCreateCompanionBuilder,
      $$SegmentsTableUpdateCompanionBuilder,
      (Segment, $$SegmentsTableReferences),
      Segment,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$EntitiesTableCreateCompanionBuilder =
    EntitiesCompanion Function({
      required String id,
      required String campaignId,
      required String kind,
      required String name,
      Value<String> aliases,
      Value<String> description,
      Value<String> status,
      Value<String> attr,
      Value<String?> parentId,
      Value<String?> ownerId,
      Value<String> giver,
      Value<String> reward,
      Value<String> review,
      Value<int> rowid,
    });
typedef $$EntitiesTableUpdateCompanionBuilder =
    EntitiesCompanion Function({
      Value<String> id,
      Value<String> campaignId,
      Value<String> kind,
      Value<String> name,
      Value<String> aliases,
      Value<String> description,
      Value<String> status,
      Value<String> attr,
      Value<String?> parentId,
      Value<String?> ownerId,
      Value<String> giver,
      Value<String> reward,
      Value<String> review,
      Value<int> rowid,
    });

final class $$EntitiesTableReferences
    extends BaseReferences<_$AppDatabase, $EntitiesTable, Entity> {
  $$EntitiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CampaignsTable _campaignIdTable(_$AppDatabase db) =>
      db.campaigns.createAlias(
        $_aliasNameGenerator(db.entities.campaignId, db.campaigns.id),
      );

  $$CampaignsTableProcessedTableManager get campaignId {
    final $_column = $_itemColumn<String>('campaign_id')!;

    final manager = $$CampaignsTableTableManager(
      $_db,
      $_db.campaigns,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_campaignIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$EntityHistoryTable, List<EntityHistoryData>>
  _entityHistoryRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.entityHistory,
    aliasName: $_aliasNameGenerator(db.entities.id, db.entityHistory.entityId),
  );

  $$EntityHistoryTableProcessedTableManager get entityHistoryRefs {
    final manager = $$EntityHistoryTableTableManager(
      $_db,
      $_db.entityHistory,
    ).filter((f) => f.entityId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_entityHistoryRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MentionsTable, List<Mention>> _mentionsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.mentions,
    aliasName: $_aliasNameGenerator(db.entities.id, db.mentions.entityId),
  );

  $$MentionsTableProcessedTableManager get mentionsRefs {
    final manager = $$MentionsTableTableManager(
      $_db,
      $_db.mentions,
    ).filter((f) => f.entityId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_mentionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EntitiesTableFilterComposer
    extends Composer<_$AppDatabase, $EntitiesTable> {
  $$EntitiesTableFilterComposer({
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

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aliases => $composableBuilder(
    column: $table.aliases,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attr => $composableBuilder(
    column: $table.attr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get giver => $composableBuilder(
    column: $table.giver,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reward => $composableBuilder(
    column: $table.reward,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get review => $composableBuilder(
    column: $table.review,
    builder: (column) => ColumnFilters(column),
  );

  $$CampaignsTableFilterComposer get campaignId {
    final $$CampaignsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.campaignId,
      referencedTable: $db.campaigns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CampaignsTableFilterComposer(
            $db: $db,
            $table: $db.campaigns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> entityHistoryRefs(
    Expression<bool> Function($$EntityHistoryTableFilterComposer f) f,
  ) {
    final $$EntityHistoryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entityHistory,
      getReferencedColumn: (t) => t.entityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntityHistoryTableFilterComposer(
            $db: $db,
            $table: $db.entityHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> mentionsRefs(
    Expression<bool> Function($$MentionsTableFilterComposer f) f,
  ) {
    final $$MentionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mentions,
      getReferencedColumn: (t) => t.entityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MentionsTableFilterComposer(
            $db: $db,
            $table: $db.mentions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EntitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $EntitiesTable> {
  $$EntitiesTableOrderingComposer({
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aliases => $composableBuilder(
    column: $table.aliases,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attr => $composableBuilder(
    column: $table.attr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get giver => $composableBuilder(
    column: $table.giver,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reward => $composableBuilder(
    column: $table.reward,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get review => $composableBuilder(
    column: $table.review,
    builder: (column) => ColumnOrderings(column),
  );

  $$CampaignsTableOrderingComposer get campaignId {
    final $$CampaignsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.campaignId,
      referencedTable: $db.campaigns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CampaignsTableOrderingComposer(
            $db: $db,
            $table: $db.campaigns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntitiesTable> {
  $$EntitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get aliases =>
      $composableBuilder(column: $table.aliases, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get attr =>
      $composableBuilder(column: $table.attr, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get giver =>
      $composableBuilder(column: $table.giver, builder: (column) => column);

  GeneratedColumn<String> get reward =>
      $composableBuilder(column: $table.reward, builder: (column) => column);

  GeneratedColumn<String> get review =>
      $composableBuilder(column: $table.review, builder: (column) => column);

  $$CampaignsTableAnnotationComposer get campaignId {
    final $$CampaignsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.campaignId,
      referencedTable: $db.campaigns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CampaignsTableAnnotationComposer(
            $db: $db,
            $table: $db.campaigns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> entityHistoryRefs<T extends Object>(
    Expression<T> Function($$EntityHistoryTableAnnotationComposer a) f,
  ) {
    final $$EntityHistoryTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entityHistory,
      getReferencedColumn: (t) => t.entityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntityHistoryTableAnnotationComposer(
            $db: $db,
            $table: $db.entityHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> mentionsRefs<T extends Object>(
    Expression<T> Function($$MentionsTableAnnotationComposer a) f,
  ) {
    final $$MentionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mentions,
      getReferencedColumn: (t) => t.entityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MentionsTableAnnotationComposer(
            $db: $db,
            $table: $db.mentions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EntitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntitiesTable,
          Entity,
          $$EntitiesTableFilterComposer,
          $$EntitiesTableOrderingComposer,
          $$EntitiesTableAnnotationComposer,
          $$EntitiesTableCreateCompanionBuilder,
          $$EntitiesTableUpdateCompanionBuilder,
          (Entity, $$EntitiesTableReferences),
          Entity,
          PrefetchHooks Function({
            bool campaignId,
            bool entityHistoryRefs,
            bool mentionsRefs,
          })
        > {
  $$EntitiesTableTableManager(_$AppDatabase db, $EntitiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> campaignId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> aliases = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> attr = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<String?> ownerId = const Value.absent(),
                Value<String> giver = const Value.absent(),
                Value<String> reward = const Value.absent(),
                Value<String> review = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntitiesCompanion(
                id: id,
                campaignId: campaignId,
                kind: kind,
                name: name,
                aliases: aliases,
                description: description,
                status: status,
                attr: attr,
                parentId: parentId,
                ownerId: ownerId,
                giver: giver,
                reward: reward,
                review: review,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String campaignId,
                required String kind,
                required String name,
                Value<String> aliases = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> attr = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<String?> ownerId = const Value.absent(),
                Value<String> giver = const Value.absent(),
                Value<String> reward = const Value.absent(),
                Value<String> review = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntitiesCompanion.insert(
                id: id,
                campaignId: campaignId,
                kind: kind,
                name: name,
                aliases: aliases,
                description: description,
                status: status,
                attr: attr,
                parentId: parentId,
                ownerId: ownerId,
                giver: giver,
                reward: reward,
                review: review,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EntitiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                campaignId = false,
                entityHistoryRefs = false,
                mentionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (entityHistoryRefs) db.entityHistory,
                    if (mentionsRefs) db.mentions,
                  ],
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
                        if (campaignId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.campaignId,
                                    referencedTable: $$EntitiesTableReferences
                                        ._campaignIdTable(db),
                                    referencedColumn: $$EntitiesTableReferences
                                        ._campaignIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (entityHistoryRefs)
                        await $_getPrefetchedData<
                          Entity,
                          $EntitiesTable,
                          EntityHistoryData
                        >(
                          currentTable: table,
                          referencedTable: $$EntitiesTableReferences
                              ._entityHistoryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EntitiesTableReferences(
                                db,
                                table,
                                p0,
                              ).entityHistoryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.entityId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (mentionsRefs)
                        await $_getPrefetchedData<
                          Entity,
                          $EntitiesTable,
                          Mention
                        >(
                          currentTable: table,
                          referencedTable: $$EntitiesTableReferences
                              ._mentionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EntitiesTableReferences(
                                db,
                                table,
                                p0,
                              ).mentionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.entityId == item.id,
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

typedef $$EntitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntitiesTable,
      Entity,
      $$EntitiesTableFilterComposer,
      $$EntitiesTableOrderingComposer,
      $$EntitiesTableAnnotationComposer,
      $$EntitiesTableCreateCompanionBuilder,
      $$EntitiesTableUpdateCompanionBuilder,
      (Entity, $$EntitiesTableReferences),
      Entity,
      PrefetchHooks Function({
        bool campaignId,
        bool entityHistoryRefs,
        bool mentionsRefs,
      })
    >;
typedef $$EntityHistoryTableCreateCompanionBuilder =
    EntityHistoryCompanion Function({
      required String id,
      required String entityId,
      required String sessionId,
      required String field,
      Value<String> oldValue,
      Value<String> newValue,
      Value<int> rowid,
    });
typedef $$EntityHistoryTableUpdateCompanionBuilder =
    EntityHistoryCompanion Function({
      Value<String> id,
      Value<String> entityId,
      Value<String> sessionId,
      Value<String> field,
      Value<String> oldValue,
      Value<String> newValue,
      Value<int> rowid,
    });

final class $$EntityHistoryTableReferences
    extends
        BaseReferences<_$AppDatabase, $EntityHistoryTable, EntityHistoryData> {
  $$EntityHistoryTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $EntitiesTable _entityIdTable(_$AppDatabase db) =>
      db.entities.createAlias(
        $_aliasNameGenerator(db.entityHistory.entityId, db.entities.id),
      );

  $$EntitiesTableProcessedTableManager get entityId {
    final $_column = $_itemColumn<String>('entity_id')!;

    final manager = $$EntitiesTableTableManager(
      $_db,
      $_db.entities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_entityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias(
        $_aliasNameGenerator(db.entityHistory.sessionId, db.sessions.id),
      );

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EntityHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $EntityHistoryTable> {
  $$EntityHistoryTableFilterComposer({
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

  ColumnFilters<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oldValue => $composableBuilder(
    column: $table.oldValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get newValue => $composableBuilder(
    column: $table.newValue,
    builder: (column) => ColumnFilters(column),
  );

  $$EntitiesTableFilterComposer get entityId {
    final $$EntitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entityId,
      referencedTable: $db.entities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntitiesTableFilterComposer(
            $db: $db,
            $table: $db.entities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntityHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $EntityHistoryTable> {
  $$EntityHistoryTableOrderingComposer({
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

  ColumnOrderings<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oldValue => $composableBuilder(
    column: $table.oldValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get newValue => $composableBuilder(
    column: $table.newValue,
    builder: (column) => ColumnOrderings(column),
  );

  $$EntitiesTableOrderingComposer get entityId {
    final $$EntitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entityId,
      referencedTable: $db.entities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntitiesTableOrderingComposer(
            $db: $db,
            $table: $db.entities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntityHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntityHistoryTable> {
  $$EntityHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get field =>
      $composableBuilder(column: $table.field, builder: (column) => column);

  GeneratedColumn<String> get oldValue =>
      $composableBuilder(column: $table.oldValue, builder: (column) => column);

  GeneratedColumn<String> get newValue =>
      $composableBuilder(column: $table.newValue, builder: (column) => column);

  $$EntitiesTableAnnotationComposer get entityId {
    final $$EntitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entityId,
      referencedTable: $db.entities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.entities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntityHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntityHistoryTable,
          EntityHistoryData,
          $$EntityHistoryTableFilterComposer,
          $$EntityHistoryTableOrderingComposer,
          $$EntityHistoryTableAnnotationComposer,
          $$EntityHistoryTableCreateCompanionBuilder,
          $$EntityHistoryTableUpdateCompanionBuilder,
          (EntityHistoryData, $$EntityHistoryTableReferences),
          EntityHistoryData,
          PrefetchHooks Function({bool entityId, bool sessionId})
        > {
  $$EntityHistoryTableTableManager(_$AppDatabase db, $EntityHistoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntityHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntityHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntityHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> field = const Value.absent(),
                Value<String> oldValue = const Value.absent(),
                Value<String> newValue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntityHistoryCompanion(
                id: id,
                entityId: entityId,
                sessionId: sessionId,
                field: field,
                oldValue: oldValue,
                newValue: newValue,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entityId,
                required String sessionId,
                required String field,
                Value<String> oldValue = const Value.absent(),
                Value<String> newValue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntityHistoryCompanion.insert(
                id: id,
                entityId: entityId,
                sessionId: sessionId,
                field: field,
                oldValue: oldValue,
                newValue: newValue,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EntityHistoryTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({entityId = false, sessionId = false}) {
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
                    if (entityId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.entityId,
                                referencedTable: $$EntityHistoryTableReferences
                                    ._entityIdTable(db),
                                referencedColumn: $$EntityHistoryTableReferences
                                    ._entityIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$EntityHistoryTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$EntityHistoryTableReferences
                                    ._sessionIdTable(db)
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

typedef $$EntityHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntityHistoryTable,
      EntityHistoryData,
      $$EntityHistoryTableFilterComposer,
      $$EntityHistoryTableOrderingComposer,
      $$EntityHistoryTableAnnotationComposer,
      $$EntityHistoryTableCreateCompanionBuilder,
      $$EntityHistoryTableUpdateCompanionBuilder,
      (EntityHistoryData, $$EntityHistoryTableReferences),
      EntityHistoryData,
      PrefetchHooks Function({bool entityId, bool sessionId})
    >;
typedef $$EventsTableCreateCompanionBuilder =
    EventsCompanion Function({
      required String id,
      required String sessionId,
      required String text_,
      required int ord,
      Value<int?> atMs,
      Value<String> review,
      Value<int> rowid,
    });
typedef $$EventsTableUpdateCompanionBuilder =
    EventsCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String> text_,
      Value<int> ord,
      Value<int?> atMs,
      Value<String> review,
      Value<int> rowid,
    });

final class $$EventsTableReferences
    extends BaseReferences<_$AppDatabase, $EventsTable, Event> {
  $$EventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) => db.sessions
      .createAlias($_aliasNameGenerator(db.events.sessionId, db.sessions.id));

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EventsTableFilterComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableFilterComposer({
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

  ColumnFilters<String> get text_ => $composableBuilder(
    column: $table.text_,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ord => $composableBuilder(
    column: $table.ord,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get atMs => $composableBuilder(
    column: $table.atMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get review => $composableBuilder(
    column: $table.review,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventsTableOrderingComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableOrderingComposer({
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

  ColumnOrderings<String> get text_ => $composableBuilder(
    column: $table.text_,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ord => $composableBuilder(
    column: $table.ord,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get atMs => $composableBuilder(
    column: $table.atMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get review => $composableBuilder(
    column: $table.review,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get text_ =>
      $composableBuilder(column: $table.text_, builder: (column) => column);

  GeneratedColumn<int> get ord =>
      $composableBuilder(column: $table.ord, builder: (column) => column);

  GeneratedColumn<int> get atMs =>
      $composableBuilder(column: $table.atMs, builder: (column) => column);

  GeneratedColumn<String> get review =>
      $composableBuilder(column: $table.review, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventsTable,
          Event,
          $$EventsTableFilterComposer,
          $$EventsTableOrderingComposer,
          $$EventsTableAnnotationComposer,
          $$EventsTableCreateCompanionBuilder,
          $$EventsTableUpdateCompanionBuilder,
          (Event, $$EventsTableReferences),
          Event,
          PrefetchHooks Function({bool sessionId})
        > {
  $$EventsTableTableManager(_$AppDatabase db, $EventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> text_ = const Value.absent(),
                Value<int> ord = const Value.absent(),
                Value<int?> atMs = const Value.absent(),
                Value<String> review = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventsCompanion(
                id: id,
                sessionId: sessionId,
                text_: text_,
                ord: ord,
                atMs: atMs,
                review: review,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required String text_,
                required int ord,
                Value<int?> atMs = const Value.absent(),
                Value<String> review = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventsCompanion.insert(
                id: id,
                sessionId: sessionId,
                text_: text_,
                ord: ord,
                atMs: atMs,
                review: review,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$EventsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
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
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$EventsTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$EventsTableReferences
                                    ._sessionIdTable(db)
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

typedef $$EventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventsTable,
      Event,
      $$EventsTableFilterComposer,
      $$EventsTableOrderingComposer,
      $$EventsTableAnnotationComposer,
      $$EventsTableCreateCompanionBuilder,
      $$EventsTableUpdateCompanionBuilder,
      (Event, $$EventsTableReferences),
      Event,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$MentionsTableCreateCompanionBuilder =
    MentionsCompanion Function({
      required String id,
      required String entityId,
      required String sessionId,
      Value<int?> atMs,
      Value<String> quote,
      Value<String> proposedField,
      Value<String> proposedValue,
      Value<String> detail,
      Value<String> target,
      Value<String> side,
      Value<String> result,
      Value<String> status,
      Value<int> rowid,
    });
typedef $$MentionsTableUpdateCompanionBuilder =
    MentionsCompanion Function({
      Value<String> id,
      Value<String> entityId,
      Value<String> sessionId,
      Value<int?> atMs,
      Value<String> quote,
      Value<String> proposedField,
      Value<String> proposedValue,
      Value<String> detail,
      Value<String> target,
      Value<String> side,
      Value<String> result,
      Value<String> status,
      Value<int> rowid,
    });

final class $$MentionsTableReferences
    extends BaseReferences<_$AppDatabase, $MentionsTable, Mention> {
  $$MentionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EntitiesTable _entityIdTable(_$AppDatabase db) => db.entities
      .createAlias($_aliasNameGenerator(db.mentions.entityId, db.entities.id));

  $$EntitiesTableProcessedTableManager get entityId {
    final $_column = $_itemColumn<String>('entity_id')!;

    final manager = $$EntitiesTableTableManager(
      $_db,
      $_db.entities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_entityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SessionsTable _sessionIdTable(_$AppDatabase db) => db.sessions
      .createAlias($_aliasNameGenerator(db.mentions.sessionId, db.sessions.id));

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MentionsTableFilterComposer
    extends Composer<_$AppDatabase, $MentionsTable> {
  $$MentionsTableFilterComposer({
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

  ColumnFilters<int> get atMs => $composableBuilder(
    column: $table.atMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quote => $composableBuilder(
    column: $table.quote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get proposedField => $composableBuilder(
    column: $table.proposedField,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get proposedValue => $composableBuilder(
    column: $table.proposedValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get side => $composableBuilder(
    column: $table.side,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  $$EntitiesTableFilterComposer get entityId {
    final $$EntitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entityId,
      referencedTable: $db.entities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntitiesTableFilterComposer(
            $db: $db,
            $table: $db.entities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MentionsTableOrderingComposer
    extends Composer<_$AppDatabase, $MentionsTable> {
  $$MentionsTableOrderingComposer({
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

  ColumnOrderings<int> get atMs => $composableBuilder(
    column: $table.atMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quote => $composableBuilder(
    column: $table.quote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get proposedField => $composableBuilder(
    column: $table.proposedField,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get proposedValue => $composableBuilder(
    column: $table.proposedValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get side => $composableBuilder(
    column: $table.side,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  $$EntitiesTableOrderingComposer get entityId {
    final $$EntitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entityId,
      referencedTable: $db.entities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntitiesTableOrderingComposer(
            $db: $db,
            $table: $db.entities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MentionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MentionsTable> {
  $$MentionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get atMs =>
      $composableBuilder(column: $table.atMs, builder: (column) => column);

  GeneratedColumn<String> get quote =>
      $composableBuilder(column: $table.quote, builder: (column) => column);

  GeneratedColumn<String> get proposedField => $composableBuilder(
    column: $table.proposedField,
    builder: (column) => column,
  );

  GeneratedColumn<String> get proposedValue => $composableBuilder(
    column: $table.proposedValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get detail =>
      $composableBuilder(column: $table.detail, builder: (column) => column);

  GeneratedColumn<String> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  GeneratedColumn<String> get side =>
      $composableBuilder(column: $table.side, builder: (column) => column);

  GeneratedColumn<String> get result =>
      $composableBuilder(column: $table.result, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  $$EntitiesTableAnnotationComposer get entityId {
    final $$EntitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entityId,
      referencedTable: $db.entities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.entities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MentionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MentionsTable,
          Mention,
          $$MentionsTableFilterComposer,
          $$MentionsTableOrderingComposer,
          $$MentionsTableAnnotationComposer,
          $$MentionsTableCreateCompanionBuilder,
          $$MentionsTableUpdateCompanionBuilder,
          (Mention, $$MentionsTableReferences),
          Mention,
          PrefetchHooks Function({bool entityId, bool sessionId})
        > {
  $$MentionsTableTableManager(_$AppDatabase db, $MentionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MentionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MentionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MentionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<int?> atMs = const Value.absent(),
                Value<String> quote = const Value.absent(),
                Value<String> proposedField = const Value.absent(),
                Value<String> proposedValue = const Value.absent(),
                Value<String> detail = const Value.absent(),
                Value<String> target = const Value.absent(),
                Value<String> side = const Value.absent(),
                Value<String> result = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MentionsCompanion(
                id: id,
                entityId: entityId,
                sessionId: sessionId,
                atMs: atMs,
                quote: quote,
                proposedField: proposedField,
                proposedValue: proposedValue,
                detail: detail,
                target: target,
                side: side,
                result: result,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entityId,
                required String sessionId,
                Value<int?> atMs = const Value.absent(),
                Value<String> quote = const Value.absent(),
                Value<String> proposedField = const Value.absent(),
                Value<String> proposedValue = const Value.absent(),
                Value<String> detail = const Value.absent(),
                Value<String> target = const Value.absent(),
                Value<String> side = const Value.absent(),
                Value<String> result = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MentionsCompanion.insert(
                id: id,
                entityId: entityId,
                sessionId: sessionId,
                atMs: atMs,
                quote: quote,
                proposedField: proposedField,
                proposedValue: proposedValue,
                detail: detail,
                target: target,
                side: side,
                result: result,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MentionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({entityId = false, sessionId = false}) {
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
                    if (entityId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.entityId,
                                referencedTable: $$MentionsTableReferences
                                    ._entityIdTable(db),
                                referencedColumn: $$MentionsTableReferences
                                    ._entityIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$MentionsTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$MentionsTableReferences
                                    ._sessionIdTable(db)
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

typedef $$MentionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MentionsTable,
      Mention,
      $$MentionsTableFilterComposer,
      $$MentionsTableOrderingComposer,
      $$MentionsTableAnnotationComposer,
      $$MentionsTableCreateCompanionBuilder,
      $$MentionsTableUpdateCompanionBuilder,
      (Mention, $$MentionsTableReferences),
      Mention,
      PrefetchHooks Function({bool entityId, bool sessionId})
    >;
typedef $$UsageLogTableCreateCompanionBuilder =
    UsageLogCompanion Function({
      required String id,
      required String campaignId,
      required String provider,
      required String step,
      required int inputTokens,
      required int outputTokens,
      required double costUsd,
      required DateTime at,
      Value<int> rowid,
    });
typedef $$UsageLogTableUpdateCompanionBuilder =
    UsageLogCompanion Function({
      Value<String> id,
      Value<String> campaignId,
      Value<String> provider,
      Value<String> step,
      Value<int> inputTokens,
      Value<int> outputTokens,
      Value<double> costUsd,
      Value<DateTime> at,
      Value<int> rowid,
    });

class $$UsageLogTableFilterComposer
    extends Composer<_$AppDatabase, $UsageLogTable> {
  $$UsageLogTableFilterComposer({
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

  ColumnFilters<String> get campaignId => $composableBuilder(
    column: $table.campaignId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get step => $composableBuilder(
    column: $table.step,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get inputTokens => $composableBuilder(
    column: $table.inputTokens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get outputTokens => $composableBuilder(
    column: $table.outputTokens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costUsd => $composableBuilder(
    column: $table.costUsd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsageLogTableOrderingComposer
    extends Composer<_$AppDatabase, $UsageLogTable> {
  $$UsageLogTableOrderingComposer({
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

  ColumnOrderings<String> get campaignId => $composableBuilder(
    column: $table.campaignId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get step => $composableBuilder(
    column: $table.step,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get inputTokens => $composableBuilder(
    column: $table.inputTokens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get outputTokens => $composableBuilder(
    column: $table.outputTokens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costUsd => $composableBuilder(
    column: $table.costUsd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsageLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsageLogTable> {
  $$UsageLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get campaignId => $composableBuilder(
    column: $table.campaignId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get step =>
      $composableBuilder(column: $table.step, builder: (column) => column);

  GeneratedColumn<int> get inputTokens => $composableBuilder(
    column: $table.inputTokens,
    builder: (column) => column,
  );

  GeneratedColumn<int> get outputTokens => $composableBuilder(
    column: $table.outputTokens,
    builder: (column) => column,
  );

  GeneratedColumn<double> get costUsd =>
      $composableBuilder(column: $table.costUsd, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);
}

class $$UsageLogTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsageLogTable,
          UsageLogData,
          $$UsageLogTableFilterComposer,
          $$UsageLogTableOrderingComposer,
          $$UsageLogTableAnnotationComposer,
          $$UsageLogTableCreateCompanionBuilder,
          $$UsageLogTableUpdateCompanionBuilder,
          (
            UsageLogData,
            BaseReferences<_$AppDatabase, $UsageLogTable, UsageLogData>,
          ),
          UsageLogData,
          PrefetchHooks Function()
        > {
  $$UsageLogTableTableManager(_$AppDatabase db, $UsageLogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsageLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsageLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsageLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> campaignId = const Value.absent(),
                Value<String> provider = const Value.absent(),
                Value<String> step = const Value.absent(),
                Value<int> inputTokens = const Value.absent(),
                Value<int> outputTokens = const Value.absent(),
                Value<double> costUsd = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsageLogCompanion(
                id: id,
                campaignId: campaignId,
                provider: provider,
                step: step,
                inputTokens: inputTokens,
                outputTokens: outputTokens,
                costUsd: costUsd,
                at: at,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String campaignId,
                required String provider,
                required String step,
                required int inputTokens,
                required int outputTokens,
                required double costUsd,
                required DateTime at,
                Value<int> rowid = const Value.absent(),
              }) => UsageLogCompanion.insert(
                id: id,
                campaignId: campaignId,
                provider: provider,
                step: step,
                inputTokens: inputTokens,
                outputTokens: outputTokens,
                costUsd: costUsd,
                at: at,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsageLogTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsageLogTable,
      UsageLogData,
      $$UsageLogTableFilterComposer,
      $$UsageLogTableOrderingComposer,
      $$UsageLogTableAnnotationComposer,
      $$UsageLogTableCreateCompanionBuilder,
      $$UsageLogTableUpdateCompanionBuilder,
      (
        UsageLogData,
        BaseReferences<_$AppDatabase, $UsageLogTable, UsageLogData>,
      ),
      UsageLogData,
      PrefetchHooks Function()
    >;
typedef $$NotesTableCreateCompanionBuilder =
    NotesCompanion Function({
      required String id,
      required String campaignId,
      Value<String?> sessionId,
      required String kind,
      required String body,
      Value<String> status,
      Value<String> source,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$NotesTableUpdateCompanionBuilder =
    NotesCompanion Function({
      Value<String> id,
      Value<String> campaignId,
      Value<String?> sessionId,
      Value<String> kind,
      Value<String> body,
      Value<String> status,
      Value<String> source,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$NotesTableReferences
    extends BaseReferences<_$AppDatabase, $NotesTable, Note> {
  $$NotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CampaignsTable _campaignIdTable(_$AppDatabase db) => db.campaigns
      .createAlias($_aliasNameGenerator(db.notes.campaignId, db.campaigns.id));

  $$CampaignsTableProcessedTableManager get campaignId {
    final $_column = $_itemColumn<String>('campaign_id')!;

    final manager = $$CampaignsTableTableManager(
      $_db,
      $_db.campaigns,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_campaignIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NotesTableFilterComposer extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
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

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
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

  $$CampaignsTableFilterComposer get campaignId {
    final $$CampaignsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.campaignId,
      referencedTable: $db.campaigns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CampaignsTableFilterComposer(
            $db: $db,
            $table: $db.campaigns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotesTableOrderingComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
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

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
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

  $$CampaignsTableOrderingComposer get campaignId {
    final $$CampaignsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.campaignId,
      referencedTable: $db.campaigns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CampaignsTableOrderingComposer(
            $db: $db,
            $table: $db.campaigns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CampaignsTableAnnotationComposer get campaignId {
    final $$CampaignsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.campaignId,
      referencedTable: $db.campaigns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CampaignsTableAnnotationComposer(
            $db: $db,
            $table: $db.campaigns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotesTable,
          Note,
          $$NotesTableFilterComposer,
          $$NotesTableOrderingComposer,
          $$NotesTableAnnotationComposer,
          $$NotesTableCreateCompanionBuilder,
          $$NotesTableUpdateCompanionBuilder,
          (Note, $$NotesTableReferences),
          Note,
          PrefetchHooks Function({bool campaignId})
        > {
  $$NotesTableTableManager(_$AppDatabase db, $NotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> campaignId = const Value.absent(),
                Value<String?> sessionId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotesCompanion(
                id: id,
                campaignId: campaignId,
                sessionId: sessionId,
                kind: kind,
                body: body,
                status: status,
                source: source,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String campaignId,
                Value<String?> sessionId = const Value.absent(),
                required String kind,
                required String body,
                Value<String> status = const Value.absent(),
                Value<String> source = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => NotesCompanion.insert(
                id: id,
                campaignId: campaignId,
                sessionId: sessionId,
                kind: kind,
                body: body,
                status: status,
                source: source,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$NotesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({campaignId = false}) {
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
                    if (campaignId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.campaignId,
                                referencedTable: $$NotesTableReferences
                                    ._campaignIdTable(db),
                                referencedColumn: $$NotesTableReferences
                                    ._campaignIdTable(db)
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

typedef $$NotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotesTable,
      Note,
      $$NotesTableFilterComposer,
      $$NotesTableOrderingComposer,
      $$NotesTableAnnotationComposer,
      $$NotesTableCreateCompanionBuilder,
      $$NotesTableUpdateCompanionBuilder,
      (Note, $$NotesTableReferences),
      Note,
      PrefetchHooks Function({bool campaignId})
    >;
typedef $$RelationsTableCreateCompanionBuilder =
    RelationsCompanion Function({
      required String id,
      required String campaignId,
      required String fromId,
      required String toId,
      Value<String> label,
      Value<int> rowid,
    });
typedef $$RelationsTableUpdateCompanionBuilder =
    RelationsCompanion Function({
      Value<String> id,
      Value<String> campaignId,
      Value<String> fromId,
      Value<String> toId,
      Value<String> label,
      Value<int> rowid,
    });

final class $$RelationsTableReferences
    extends BaseReferences<_$AppDatabase, $RelationsTable, Relation> {
  $$RelationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CampaignsTable _campaignIdTable(_$AppDatabase db) =>
      db.campaigns.createAlias(
        $_aliasNameGenerator(db.relations.campaignId, db.campaigns.id),
      );

  $$CampaignsTableProcessedTableManager get campaignId {
    final $_column = $_itemColumn<String>('campaign_id')!;

    final manager = $$CampaignsTableTableManager(
      $_db,
      $_db.campaigns,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_campaignIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EntitiesTable _fromIdTable(_$AppDatabase db) => db.entities
      .createAlias($_aliasNameGenerator(db.relations.fromId, db.entities.id));

  $$EntitiesTableProcessedTableManager get fromId {
    final $_column = $_itemColumn<String>('from_id')!;

    final manager = $$EntitiesTableTableManager(
      $_db,
      $_db.entities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fromIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EntitiesTable _toIdTable(_$AppDatabase db) => db.entities.createAlias(
    $_aliasNameGenerator(db.relations.toId, db.entities.id),
  );

  $$EntitiesTableProcessedTableManager get toId {
    final $_column = $_itemColumn<String>('to_id')!;

    final manager = $$EntitiesTableTableManager(
      $_db,
      $_db.entities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_toIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RelationsTableFilterComposer
    extends Composer<_$AppDatabase, $RelationsTable> {
  $$RelationsTableFilterComposer({
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

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  $$CampaignsTableFilterComposer get campaignId {
    final $$CampaignsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.campaignId,
      referencedTable: $db.campaigns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CampaignsTableFilterComposer(
            $db: $db,
            $table: $db.campaigns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EntitiesTableFilterComposer get fromId {
    final $$EntitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromId,
      referencedTable: $db.entities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntitiesTableFilterComposer(
            $db: $db,
            $table: $db.entities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EntitiesTableFilterComposer get toId {
    final $$EntitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toId,
      referencedTable: $db.entities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntitiesTableFilterComposer(
            $db: $db,
            $table: $db.entities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RelationsTableOrderingComposer
    extends Composer<_$AppDatabase, $RelationsTable> {
  $$RelationsTableOrderingComposer({
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

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  $$CampaignsTableOrderingComposer get campaignId {
    final $$CampaignsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.campaignId,
      referencedTable: $db.campaigns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CampaignsTableOrderingComposer(
            $db: $db,
            $table: $db.campaigns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EntitiesTableOrderingComposer get fromId {
    final $$EntitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromId,
      referencedTable: $db.entities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntitiesTableOrderingComposer(
            $db: $db,
            $table: $db.entities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EntitiesTableOrderingComposer get toId {
    final $$EntitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toId,
      referencedTable: $db.entities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntitiesTableOrderingComposer(
            $db: $db,
            $table: $db.entities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RelationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RelationsTable> {
  $$RelationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  $$CampaignsTableAnnotationComposer get campaignId {
    final $$CampaignsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.campaignId,
      referencedTable: $db.campaigns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CampaignsTableAnnotationComposer(
            $db: $db,
            $table: $db.campaigns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EntitiesTableAnnotationComposer get fromId {
    final $$EntitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromId,
      referencedTable: $db.entities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.entities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EntitiesTableAnnotationComposer get toId {
    final $$EntitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toId,
      referencedTable: $db.entities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.entities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RelationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RelationsTable,
          Relation,
          $$RelationsTableFilterComposer,
          $$RelationsTableOrderingComposer,
          $$RelationsTableAnnotationComposer,
          $$RelationsTableCreateCompanionBuilder,
          $$RelationsTableUpdateCompanionBuilder,
          (Relation, $$RelationsTableReferences),
          Relation,
          PrefetchHooks Function({bool campaignId, bool fromId, bool toId})
        > {
  $$RelationsTableTableManager(_$AppDatabase db, $RelationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RelationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RelationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RelationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> campaignId = const Value.absent(),
                Value<String> fromId = const Value.absent(),
                Value<String> toId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RelationsCompanion(
                id: id,
                campaignId: campaignId,
                fromId: fromId,
                toId: toId,
                label: label,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String campaignId,
                required String fromId,
                required String toId,
                Value<String> label = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RelationsCompanion.insert(
                id: id,
                campaignId: campaignId,
                fromId: fromId,
                toId: toId,
                label: label,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RelationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({campaignId = false, fromId = false, toId = false}) {
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
                        if (campaignId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.campaignId,
                                    referencedTable: $$RelationsTableReferences
                                        ._campaignIdTable(db),
                                    referencedColumn: $$RelationsTableReferences
                                        ._campaignIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (fromId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.fromId,
                                    referencedTable: $$RelationsTableReferences
                                        ._fromIdTable(db),
                                    referencedColumn: $$RelationsTableReferences
                                        ._fromIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (toId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.toId,
                                    referencedTable: $$RelationsTableReferences
                                        ._toIdTable(db),
                                    referencedColumn: $$RelationsTableReferences
                                        ._toIdTable(db)
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

typedef $$RelationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RelationsTable,
      Relation,
      $$RelationsTableFilterComposer,
      $$RelationsTableOrderingComposer,
      $$RelationsTableAnnotationComposer,
      $$RelationsTableCreateCompanionBuilder,
      $$RelationsTableUpdateCompanionBuilder,
      (Relation, $$RelationsTableReferences),
      Relation,
      PrefetchHooks Function({bool campaignId, bool fromId, bool toId})
    >;
typedef $$FactsTableCreateCompanionBuilder =
    FactsCompanion Function({
      required String id,
      required String campaignId,
      required String sessionId,
      required String kind,
      Value<String> actor,
      Value<String> target,
      Value<String> side,
      Value<int?> amount,
      Value<String> text_,
      Value<int?> atMs,
      Value<String> quote,
      Value<String> status,
      Value<bool> applied,
      Value<int> rowid,
    });
typedef $$FactsTableUpdateCompanionBuilder =
    FactsCompanion Function({
      Value<String> id,
      Value<String> campaignId,
      Value<String> sessionId,
      Value<String> kind,
      Value<String> actor,
      Value<String> target,
      Value<String> side,
      Value<int?> amount,
      Value<String> text_,
      Value<int?> atMs,
      Value<String> quote,
      Value<String> status,
      Value<bool> applied,
      Value<int> rowid,
    });

final class $$FactsTableReferences
    extends BaseReferences<_$AppDatabase, $FactsTable, Fact> {
  $$FactsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CampaignsTable _campaignIdTable(_$AppDatabase db) => db.campaigns
      .createAlias($_aliasNameGenerator(db.facts.campaignId, db.campaigns.id));

  $$CampaignsTableProcessedTableManager get campaignId {
    final $_column = $_itemColumn<String>('campaign_id')!;

    final manager = $$CampaignsTableTableManager(
      $_db,
      $_db.campaigns,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_campaignIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SessionsTable _sessionIdTable(_$AppDatabase db) => db.sessions
      .createAlias($_aliasNameGenerator(db.facts.sessionId, db.sessions.id));

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FactsTableFilterComposer extends Composer<_$AppDatabase, $FactsTable> {
  $$FactsTableFilterComposer({
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

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actor => $composableBuilder(
    column: $table.actor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get side => $composableBuilder(
    column: $table.side,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get text_ => $composableBuilder(
    column: $table.text_,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get atMs => $composableBuilder(
    column: $table.atMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quote => $composableBuilder(
    column: $table.quote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get applied => $composableBuilder(
    column: $table.applied,
    builder: (column) => ColumnFilters(column),
  );

  $$CampaignsTableFilterComposer get campaignId {
    final $$CampaignsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.campaignId,
      referencedTable: $db.campaigns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CampaignsTableFilterComposer(
            $db: $db,
            $table: $db.campaigns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FactsTableOrderingComposer
    extends Composer<_$AppDatabase, $FactsTable> {
  $$FactsTableOrderingComposer({
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actor => $composableBuilder(
    column: $table.actor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get side => $composableBuilder(
    column: $table.side,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get text_ => $composableBuilder(
    column: $table.text_,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get atMs => $composableBuilder(
    column: $table.atMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quote => $composableBuilder(
    column: $table.quote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get applied => $composableBuilder(
    column: $table.applied,
    builder: (column) => ColumnOrderings(column),
  );

  $$CampaignsTableOrderingComposer get campaignId {
    final $$CampaignsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.campaignId,
      referencedTable: $db.campaigns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CampaignsTableOrderingComposer(
            $db: $db,
            $table: $db.campaigns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FactsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FactsTable> {
  $$FactsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get actor =>
      $composableBuilder(column: $table.actor, builder: (column) => column);

  GeneratedColumn<String> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  GeneratedColumn<String> get side =>
      $composableBuilder(column: $table.side, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get text_ =>
      $composableBuilder(column: $table.text_, builder: (column) => column);

  GeneratedColumn<int> get atMs =>
      $composableBuilder(column: $table.atMs, builder: (column) => column);

  GeneratedColumn<String> get quote =>
      $composableBuilder(column: $table.quote, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get applied =>
      $composableBuilder(column: $table.applied, builder: (column) => column);

  $$CampaignsTableAnnotationComposer get campaignId {
    final $$CampaignsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.campaignId,
      referencedTable: $db.campaigns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CampaignsTableAnnotationComposer(
            $db: $db,
            $table: $db.campaigns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FactsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FactsTable,
          Fact,
          $$FactsTableFilterComposer,
          $$FactsTableOrderingComposer,
          $$FactsTableAnnotationComposer,
          $$FactsTableCreateCompanionBuilder,
          $$FactsTableUpdateCompanionBuilder,
          (Fact, $$FactsTableReferences),
          Fact,
          PrefetchHooks Function({bool campaignId, bool sessionId})
        > {
  $$FactsTableTableManager(_$AppDatabase db, $FactsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FactsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> campaignId = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> actor = const Value.absent(),
                Value<String> target = const Value.absent(),
                Value<String> side = const Value.absent(),
                Value<int?> amount = const Value.absent(),
                Value<String> text_ = const Value.absent(),
                Value<int?> atMs = const Value.absent(),
                Value<String> quote = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> applied = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FactsCompanion(
                id: id,
                campaignId: campaignId,
                sessionId: sessionId,
                kind: kind,
                actor: actor,
                target: target,
                side: side,
                amount: amount,
                text_: text_,
                atMs: atMs,
                quote: quote,
                status: status,
                applied: applied,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String campaignId,
                required String sessionId,
                required String kind,
                Value<String> actor = const Value.absent(),
                Value<String> target = const Value.absent(),
                Value<String> side = const Value.absent(),
                Value<int?> amount = const Value.absent(),
                Value<String> text_ = const Value.absent(),
                Value<int?> atMs = const Value.absent(),
                Value<String> quote = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> applied = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FactsCompanion.insert(
                id: id,
                campaignId: campaignId,
                sessionId: sessionId,
                kind: kind,
                actor: actor,
                target: target,
                side: side,
                amount: amount,
                text_: text_,
                atMs: atMs,
                quote: quote,
                status: status,
                applied: applied,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$FactsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({campaignId = false, sessionId = false}) {
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
                    if (campaignId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.campaignId,
                                referencedTable: $$FactsTableReferences
                                    ._campaignIdTable(db),
                                referencedColumn: $$FactsTableReferences
                                    ._campaignIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$FactsTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$FactsTableReferences
                                    ._sessionIdTable(db)
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

typedef $$FactsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FactsTable,
      Fact,
      $$FactsTableFilterComposer,
      $$FactsTableOrderingComposer,
      $$FactsTableAnnotationComposer,
      $$FactsTableCreateCompanionBuilder,
      $$FactsTableUpdateCompanionBuilder,
      (Fact, $$FactsTableReferences),
      Fact,
      PrefetchHooks Function({bool campaignId, bool sessionId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CampaignsTableTableManager get campaigns =>
      $$CampaignsTableTableManager(_db, _db.campaigns);
  $$HeroesTableTableManager get heroes =>
      $$HeroesTableTableManager(_db, _db.heroes);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$AudiosTableTableManager get audios =>
      $$AudiosTableTableManager(_db, _db.audios);
  $$SegmentsTableTableManager get segments =>
      $$SegmentsTableTableManager(_db, _db.segments);
  $$EntitiesTableTableManager get entities =>
      $$EntitiesTableTableManager(_db, _db.entities);
  $$EntityHistoryTableTableManager get entityHistory =>
      $$EntityHistoryTableTableManager(_db, _db.entityHistory);
  $$EventsTableTableManager get events =>
      $$EventsTableTableManager(_db, _db.events);
  $$MentionsTableTableManager get mentions =>
      $$MentionsTableTableManager(_db, _db.mentions);
  $$UsageLogTableTableManager get usageLog =>
      $$UsageLogTableTableManager(_db, _db.usageLog);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $$RelationsTableTableManager get relations =>
      $$RelationsTableTableManager(_db, _db.relations);
  $$FactsTableTableManager get facts =>
      $$FactsTableTableManager(_db, _db.facts);
}
