import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class Campaigns extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get system => text().withDefault(const Constant('D&D 5e'))();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get coverPath => text().nullable()();
  TextColumn get language => text().withDefault(const Constant('pt-BR'))();
  TextColumn get players => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class Heroes extends Table {
  TextColumn get id => text()();
  TextColumn get campaignId => text().references(Campaigns, #id)();
  TextColumn get player => text().withDefault(const Constant(''))();
  TextColumn get name => text()();
  TextColumn get heroClass => text().withDefault(const Constant(''))();
  TextColumn get race => text().withDefault(const Constant(''))();
  IntColumn get level => integer().withDefault(const Constant(1))();
  TextColumn get story => text().withDefault(const Constant(''))();
  TextColumn get photoPath => text().nullable()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get sheetPath => text().nullable()();
  /// JSON com atributos, vida, perícias etc. lidos da ficha.
  TextColumn get extra => text().withDefault(const Constant('{}'))();
  /// Pontos de vida atuais / máximos (nulo = não cadastrado) e experiência.
  IntColumn get hpCurrent => integer().nullable()();
  IntColumn get hpMax => integer().nullable()();
  IntColumn get xp => integer().withDefault(const Constant(0))();
  @override
  Set<Column> get primaryKey => {id};
}

class Sessions extends Table {
  TextColumn get id => text()();
  TextColumn get campaignId => text().references(Campaigns, #id)();
  IntColumn get number => integer()();
  DateTimeColumn get date => dateTime()();
  IntColumn get durationSec => integer().withDefault(const Constant(0))();
  /// recorded | processing | review | done
  TextColumn get status => text().withDefault(const Constant('recorded'))();
  TextColumn get shortSummary => text().withDefault(const Constant(''))();
  TextColumn get longSummary => text().withDefault(const Constant(''))();
  TextColumn get previouslyOn => text().withDefault(const Constant(''))();
  TextColumn get processingMode => text().withDefault(const Constant('free'))();
  /// JSON com momentos marcados (segundos) durante a gravação.
  TextColumn get bookmarks => text().withDefault(const Constant('[]'))();
  @override
  Set<Column> get primaryKey => {id};
}

class Audios extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(Sessions, #id)();
  TextColumn get filePath => text()();
  IntColumn get ord => integer()();
  IntColumn get durationSec => integer().withDefault(const Constant(0))();
  /// recorded | imported
  TextColumn get origin => text().withDefault(const Constant('recorded'))();
  /// Para trilhas por pessoa (Craig): nome do falante.
  TextColumn get speaker => text().nullable()();
  BoolColumn get transcribed => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}

class Segments extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(Sessions, #id)();
  IntColumn get startMs => integer()();
  IntColumn get endMs => integer()();
  TextColumn get text_ => text().named('text')();
  TextColumn get speaker => text().nullable()();
  RealColumn get confidence => real().withDefault(const Constant(1.0))();
  @override
  Set<Column> get primaryKey => {id};
}

/// NPC, local, missão, item e facção numa tabela só, separados por [kind].
class Entities extends Table {
  TextColumn get id => text()();
  TextColumn get campaignId => text().references(Campaigns, #id)();
  /// npc | location | quest | item | faction
  TextColumn get kind => text()();
  TextColumn get name => text()();
  TextColumn get aliases => text().withDefault(const Constant(''))();
  TextColumn get description => text().withDefault(const Constant(''))();
  /// npc: aliado/neutro/inimigo · missão: ativa/concluída/falhou · facção: relação
  TextColumn get status => text().withDefault(const Constant(''))();
  /// npc: vivo/morto · local: tipo · item: raridade
  TextColumn get attr => text().withDefault(const Constant(''))();
  TextColumn get parentId => text().nullable()();
  TextColumn get ownerId => text().nullable()();
  TextColumn get giver => text().withDefault(const Constant(''))();
  TextColumn get reward => text().withDefault(const Constant(''))();
  /// suggested | confirmed
  TextColumn get review => text().withDefault(const Constant('suggested'))();
  @override
  Set<Column> get primaryKey => {id};
}

/// Histórico de mudanças por sessão (alimenta a linha do tempo).
class EntityHistory extends Table {
  TextColumn get id => text()();
  TextColumn get entityId => text().references(Entities, #id)();
  TextColumn get sessionId => text().references(Sessions, #id)();
  TextColumn get field => text()();
  TextColumn get oldValue => text().withDefault(const Constant(''))();
  TextColumn get newValue => text().withDefault(const Constant(''))();
  @override
  Set<Column> get primaryKey => {id};
}

class Events extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(Sessions, #id)();
  TextColumn get text_ => text().named('text')();
  IntColumn get ord => integer()();
  IntColumn get atMs => integer().nullable()();
  /// suggested | confirmed
  TextColumn get review => text().withDefault(const Constant('suggested'))();
  @override
  Set<Column> get primaryKey => {id};
}

/// Liga entidade a um trecho de sessão: base da revisão e das citações.
class Mentions extends Table {
  TextColumn get id => text()();
  TextColumn get entityId => text().references(Entities, #id)();
  TextColumn get sessionId => text().references(Sessions, #id)();
  IntColumn get atMs => integer().nullable()();
  TextColumn get quote => text().withDefault(const Constant(''))();
  /// Mudança proposta (ex.: status -> concluída), vazio se só citação.
  TextColumn get proposedField => text().withDefault(const Constant(''))();
  TextColumn get proposedValue => text().withDefault(const Constant(''))();
  /// Detalhe do uso (ex.: "Lançado por Orquídea"). Cada feitiço usado é uma menção.
  TextColumn get detail => text().withDefault(const Constant(''))();
  /// Feitiços: em quem foi usado, de que lado veio (hero | enemy | neutral) e o resultado.
  TextColumn get target => text().withDefault(const Constant(''))();
  TextColumn get side => text().withDefault(const Constant(''))();
  TextColumn get result => text().withDefault(const Constant(''))();
  /// suggested | confirmed
  TextColumn get status => text().withDefault(const Constant('suggested'))();
  @override
  Set<Column> get primaryKey => {id};
}

/// Gasto de API por campanha (estimado a partir de tokens).
class UsageLog extends Table {
  TextColumn get id => text()();
  TextColumn get campaignId => text()();
  TextColumn get provider => text()();
  TextColumn get step => text()();
  IntColumn get inputTokens => integer()();
  IntColumn get outputTokens => integer()();
  RealColumn get costUsd => real()();
  DateTimeColumn get at => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

/// Fatos de combate e recompensa de uma sessão: dano, cura, XP, condições e saque.
class Facts extends Table {
  TextColumn get id => text()();
  TextColumn get campaignId => text().references(Campaigns, #id)();
  TextColumn get sessionId => text().references(Sessions, #id)();
  /// damage | heal | xp | condition | loot
  TextColumn get kind => text()();
  /// Quem causou (ou quem ganhou, no XP) e quem sofreu.
  TextColumn get actor => text().withDefault(const Constant(''))();
  TextColumn get target => text().withDefault(const Constant(''))();
  /// hero | enemy | neutral — de que lado está o ALVO (quem sofreu/ganhou).
  TextColumn get side => text().withDefault(const Constant(''))();
  IntColumn get amount => integer().nullable()();
  TextColumn get text_ => text().named('text').withDefault(const Constant(''))();
  IntColumn get atMs => integer().nullable()();
  TextColumn get quote => text().withDefault(const Constant(''))();
  /// suggested | confirmed
  TextColumn get status => text().withDefault(const Constant('suggested'))();
  /// Já foi somado/subtraído da ficha do herói?
  BoolColumn get applied => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}

/// Anotações de campanha: ganchos em aberto, segredos/pistas e roteiro de preparação.
class Notes extends Table {
  TextColumn get id => text()();
  TextColumn get campaignId => text().references(Campaigns, #id)();
  /// Sessão de origem (nulo = criada à mão na campanha).
  TextColumn get sessionId => text().nullable()();
  /// thread | secret | strong_start
  TextColumn get kind => text()();
  TextColumn get body => text()();
  /// open | done (gancho resolvido / segredo revelado)
  TextColumn get status => text().withDefault(const Constant('open'))();
  /// ai | manual
  TextColumn get source => text().withDefault(const Constant('manual'))();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

/// Ligação entre duas entidades (ex.: Verren — "lidera" — Recrutas; Verren — "vive em" — Pedraalta).
class Relations extends Table {
  TextColumn get id => text()();
  TextColumn get campaignId => text().references(Campaigns, #id)();
  TextColumn get fromId => text().references(Entities, #id)();
  TextColumn get toId => text().references(Entities, #id)();
  TextColumn get label => text().withDefault(const Constant(''))();
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  Campaigns,
  Heroes,
  Sessions,
  Audios,
  Segments,
  Entities,
  EntityHistory,
  Events,
  Mentions,
  UsageLog,
  Notes,
  Relations,
  Facts,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(notes);
            await m.createTable(relations);
          }
          if (from < 3) {
            await m.addColumn(mentions, mentions.detail);
          }
          if (from < 4) {
            await m.addColumn(heroes, heroes.hpCurrent);
            await m.addColumn(heroes, heroes.hpMax);
            await m.addColumn(heroes, heroes.xp);
            await m.addColumn(mentions, mentions.target);
            await m.addColumn(mentions, mentions.side);
            await m.addColumn(mentions, mentions.result);
            await m.createTable(facts);
          }
        },
      );

  static LazyDatabase _open() => LazyDatabase(() async {
        final dir = await getApplicationDocumentsDirectory();
        return NativeDatabase.createInBackground(
            File(p.join(dir.path, 'campaign_journal.sqlite')));
      });
}
