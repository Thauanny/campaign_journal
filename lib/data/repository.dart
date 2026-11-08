import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../domain/name_match.dart';
import '../domain/models.dart';
import 'database.dart';
import 'repo_facts.dart';
import '../domain/hero_context.dart';
import '../domain/systems.dart';

const _uuid = Uuid();
String newId() => _uuid.v4();

class Repository {
  final AppDatabase db;
  Repository(this.db);

  // ---------- Campanhas ----------
  Stream<List<Campaign>> watchCampaigns() => (db.select(db.campaigns)
        ..orderBy([(c) => OrderingTerm.desc(c.createdAt)]))
      .watch();
  Stream<Campaign?> watchCampaign(String id) =>
      (db.select(db.campaigns)..where((c) => c.id.equals(id))).watchSingleOrNull();
  Future<Campaign?> campaign(String id) =>
      (db.select(db.campaigns)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<String> saveCampaign({
    String? id,
    required String name,
    required String system,
    String description = '',
    String? coverPath,
    String players = '',
    String language = 'pt-BR',
  }) async {
    final cid = id ?? newId();
    await db.into(db.campaigns).insertOnConflictUpdate(CampaignsCompanion(
          id: Value(cid),
          name: Value(name),
          system: Value(system),
          description: Value(description),
          coverPath: Value(coverPath),
          players: Value(players),
          language: Value(language),
          createdAt: Value(id == null
              ? DateTime.now()
              : (await campaign(cid))?.createdAt ?? DateTime.now()),
        ));
    return cid;
  }

  /// Resumo do que existe (para a confirmação de "limpar dados").
  Future<({int sessions, int entries, int heroes})> campaignCounts(String cid) async => (
        sessions: (await sessionsOf(cid)).length,
        entries: (await entitiesOf(cid)).where((e) => e.ownerId == null).length,
        heroes: (await (db.select(db.heroes)..where((h) => h.campaignId.equals(cid))).get()).length,
      );

  /// Apaga o conteúdo da campanha mantendo a campanha: sessões (e áudios gravados),
  /// enciclopédia, ganchos/segredos, ligações e fatos. Os heróis ficam, a não ser
  /// que [deleteHeroes] seja verdadeiro.
  Future<void> clearCampaignData(String cid, {bool deleteHeroes = false}) async {
    for (final s in await sessionsOf(cid)) {
      await deleteSession(s.id);
    }
    for (final e in await entitiesOf(cid)) {
      if (e.ownerId != null && !deleteHeroes) continue; // inventário dos heróis que ficam
      await deleteEntity(e.id);
    }
    await (db.delete(db.notes)..where((n) => n.campaignId.equals(cid))).go();
    await (db.delete(db.relations)..where((r) => r.campaignId.equals(cid))).go();
    await (db.delete(db.facts)..where((f) => f.campaignId.equals(cid))).go();
    await (db.delete(db.usageLog)..where((u) => u.campaignId.equals(cid))).go();
    if (deleteHeroes) await (db.delete(db.heroes)..where((h) => h.campaignId.equals(cid))).go();
  }

  Future<void> deleteCampaign(String id) async {
    final sessions = await sessionsOf(id);
    for (final s in sessions) {
      await deleteSession(s.id);
    }
    await (db.delete(db.notes)..where((n) => n.campaignId.equals(id))).go();
    await (db.delete(db.relations)..where((r) => r.campaignId.equals(id))).go();
    await (db.delete(db.facts)..where((f) => f.campaignId.equals(id))).go();
    await (db.delete(db.heroes)..where((h) => h.campaignId.equals(id))).go();
    await (db.delete(db.entities)..where((e) => e.campaignId.equals(id))).go();
    await (db.delete(db.usageLog)..where((e) => e.campaignId.equals(id))).go();
    await (db.delete(db.campaigns)..where((c) => c.id.equals(id))).go();
  }

  // ---------- Heróis ----------
  Stream<List<Heroe>> watchHeroes(String cid) => (db.select(db.heroes)
        ..where((h) => h.campaignId.equals(cid))
        ..orderBy([(h) => OrderingTerm.asc(h.name)]))
      .watch();
  Future<Heroe?> hero(String id) =>
      (db.select(db.heroes)..where((h) => h.id.equals(id))).getSingleOrNull();

  Future<String> saveHero(HeroesCompanion h) async {
    final id = h.id.present ? h.id.value : newId();
    await db.into(db.heroes).insertOnConflictUpdate(h.copyWith(id: Value(id)));
    return id;
  }

  Future<void> deleteHero(String id) async {
    await (db.delete(db.entities)
          ..where((e) => e.kind.equals('item') & e.ownerId.equals(id)))
        .go();
    await (db.delete(db.heroes)..where((h) => h.id.equals(id))).go();
  }

  Stream<List<Entity>> watchHeroItems(String heroId) => (db.select(db.entities)
        ..where((e) => e.kind.equals('item') & e.ownerId.equals(heroId)))
      .watch();

  Future<void> addHeroItem(String campaignId, String heroId, String name) =>
      db.into(db.entities).insert(EntitiesCompanion.insert(
          id: newId(),
          campaignId: campaignId,
          kind: 'item',
          name: name,
          ownerId: Value(heroId),
          review: const Value('confirmed')));

  // ---------- Sessões ----------
  Stream<List<Session>> watchSessions(String cid) => (db.select(db.sessions)
        ..where((s) => s.campaignId.equals(cid))
        ..orderBy([(s) => OrderingTerm.desc(s.number)]))
      .watch();
  Future<List<Session>> sessionsOf(String cid) => (db.select(db.sessions)
        ..where((s) => s.campaignId.equals(cid))
        ..orderBy([(s) => OrderingTerm.asc(s.number)]))
      .get();
  Stream<Session?> watchSession(String id) =>
      (db.select(db.sessions)..where((s) => s.id.equals(id))).watchSingleOrNull();
  Future<Session?> session(String id) =>
      (db.select(db.sessions)..where((s) => s.id.equals(id))).getSingleOrNull();

  Future<String> createSession(String cid) async {
    final n = (await sessionsOf(cid)).fold<int>(0, (a, s) => s.number > a ? s.number : a);
    final id = newId();
    await db.into(db.sessions).insert(SessionsCompanion.insert(
        id: id, campaignId: cid, number: n + 1, date: DateTime.now()));
    return id;
  }

  Future<void> updateSession(String id, SessionsCompanion c) =>
      (db.update(db.sessions)..where((s) => s.id.equals(id))).write(c);

  Future<void> setSessionStatus(String id, String status) =>
      updateSession(id, SessionsCompanion(status: Value(status)));

  /// Apaga a sessão. Opcionalmente também apaga as descobertas que só existiam
  /// nela ([deleteExclusiveEntities]) e desfaz o dano/cura/XP aplicados aos
  /// heróis ([revertFacts]).
  Future<void> deleteSession(String id, {bool deleteExclusiveEntities = false, bool revertFacts = false}) async {
    final exclusive = deleteExclusiveEntities ? (await deletionPreview(id)).exclusive : <Entity>[];
    if (revertFacts) await revertFactsOf(id);
    final audios = await audiosOf(id);
    for (final a in audios) {
      if (a.origin == 'recorded') {
        try { File(a.filePath).deleteSync(); } catch (_) {}
      }
    }
    await (db.delete(db.mentions)..where((m) => m.sessionId.equals(id))).go();
    await (db.delete(db.facts)..where((f) => f.sessionId.equals(id))).go();
    await (db.delete(db.notes)..where((n) => n.sessionId.equals(id) & n.source.equals('ai'))).go();
    await (db.delete(db.entityHistory)..where((m) => m.sessionId.equals(id))).go();
    await (db.delete(db.events)..where((m) => m.sessionId.equals(id))).go();
    await (db.delete(db.segments)..where((m) => m.sessionId.equals(id))).go();
    await (db.delete(db.audios)..where((m) => m.sessionId.equals(id))).go();
    await (db.delete(db.sessions)..where((m) => m.id.equals(id))).go();
    for (final e in exclusive) {
      await deleteEntity(e.id);
    }
    // Descobertas que só existiam por causa desta sessão (ainda sugeridas e sem
    // nenhuma menção restante) somem junto, para não sobrar lixo na enciclopédia.
    final orphans = await (db.select(db.entities)..where((e) => e.review.equals('suggested'))).get();
    for (final e in orphans) {
      final left = await (db.select(db.mentions)..where((m) => m.entityId.equals(e.id))).get();
      if (left.isEmpty) await deleteEntity(e.id);
    }
  }

  // ---------- Áudio ----------
  Future<List<Audio>> audiosOf(String sid) => (db.select(db.audios)
        ..where((a) => a.sessionId.equals(sid))
        ..orderBy([(a) => OrderingTerm.asc(a.ord)]))
      .get();
  Stream<List<Audio>> watchAudios(String sid) => (db.select(db.audios)
        ..where((a) => a.sessionId.equals(sid))
        ..orderBy([(a) => OrderingTerm.asc(a.ord)]))
      .watch();

  Future<void> addAudio(String sid, String path,
      {required int durationSec, String origin = 'recorded', String? speaker}) async {
    final ord = (await audiosOf(sid)).length;
    await db.into(db.audios).insert(AudiosCompanion.insert(
        id: newId(),
        sessionId: sid,
        filePath: path,
        ord: ord,
        durationSec: Value(durationSec),
        origin: Value(origin),
        speaker: Value(speaker)));
    final total = (await audiosOf(sid))
        .where((a) => a.speaker == null)
        .fold<int>(0, (a, b) => a + b.durationSec);
    await updateSession(sid, SessionsCompanion(durationSec: Value(total)));
  }

  /// Apaga uma gravação (arquivo gravado + registro) e recalcula a duração da sessão.
  Future<void> deleteAudio(String audioId) async {
    final a = await (db.select(db.audios)..where((x) => x.id.equals(audioId))).getSingleOrNull();
    if (a == null) return;
    if (a.origin == 'recorded') {
      try { File(a.filePath).deleteSync(); } catch (_) {}
    }
    await (db.delete(db.audios)..where((x) => x.id.equals(audioId))).go();
    final total = (await audiosOf(a.sessionId)).where((x) => x.speaker == null).fold<int>(0, (s, x) => s + x.durationSec);
    await updateSession(a.sessionId, SessionsCompanion(durationSec: Value(total)));
  }

  Future<void> markTranscribed(String audioId) =>
      (db.update(db.audios)..where((a) => a.id.equals(audioId)))
          .write(const AudiosCompanion(transcribed: Value(true)));

  // ---------- Transcrição ----------
  Stream<List<Segment>> watchSegments(String sid) => (db.select(db.segments)
        ..where((s) => s.sessionId.equals(sid))
        ..orderBy([(s) => OrderingTerm.asc(s.startMs)]))
      .watch();
  Future<List<Segment>> segmentsOf(String sid) => (db.select(db.segments)
        ..where((s) => s.sessionId.equals(sid))
        ..orderBy([(s) => OrderingTerm.asc(s.startMs)]))
      .get();

  Future<void> insertSegments(String sid, List<TranscriptSegment> segs) =>
      db.batch((b) => b.insertAll(
          db.segments,
          segs.map((s) => SegmentsCompanion.insert(
              id: newId(),
              sessionId: sid,
              startMs: s.startMs,
              endMs: s.endMs,
              text_: s.text,
              speaker: Value(s.speaker),
              confidence: Value(s.confidence)))));

  /// Importa/cola uma transcrição pronta; [replace] troca a existente.
  Future<int> importTranscript(String sid, List<TranscriptSegment> segs, {bool replace = false}) async {
    if (replace) await clearSegments(sid);
    await insertSegments(sid, segs);
    final end = segs.isEmpty ? 0 : segs.map((s) => s.endMs).reduce((a, b) => a > b ? a : b);
    final s = await session(sid);
    if (s != null && s.durationSec == 0) {
      await updateSession(sid, SessionsCompanion(durationSec: Value(end ~/ 1000)));
    }
    return segs.length;
  }

  Future<void> clearSegments(String sid) =>
      (db.delete(db.segments)..where((s) => s.sessionId.equals(sid))).go();

  Future<void> updateSegmentText(String id, String text) =>
      (db.update(db.segments)..where((s) => s.id.equals(id))).write(
          SegmentsCompanion(text_: Value(text), confidence: const Value(1.0)));

  /// Busca de texto na transcrição.
  Future<List<Segment>> searchSegments(String sid, String q) =>
      (db.select(db.segments)
            ..where((s) => s.sessionId.equals(sid) & s.text_.like('%$q%'))
            ..orderBy([(s) => OrderingTerm.asc(s.startMs)]))
          .get();

  // ---------- Entidades ----------
  Stream<List<Entity>> watchEntities(String cid, {String? kind}) =>
      (db.select(db.entities)
            ..where((e) {
              // itens do inventário de um herói (ownerId) não entram na enciclopédia
              final base = e.campaignId.equals(cid) & e.review.equals('confirmed') & e.ownerId.isNull();
              return kind == null ? base : base & e.kind.equals(kind);
            })
            ..orderBy([(e) => OrderingTerm.asc(e.name)]))
          .watch();

  /// Todas as entidades, inclusive as ainda SUGERIDAS (aguardando revisão).
  Stream<List<Entity>> watchAllEntities(String cid) => (db.select(db.entities)
        ..where((e) => e.campaignId.equals(cid) & e.ownerId.isNull())
        ..orderBy([(e) => OrderingTerm.asc(e.name)]))
      .watch();

  Future<List<Entity>> entitiesOf(String cid) => (db.select(db.entities)
        ..where((e) => e.campaignId.equals(cid)))
      .get();
  Future<Entity?> entity(String id) =>
      (db.select(db.entities)..where((e) => e.id.equals(id))).getSingleOrNull();
  Stream<Entity?> watchEntity(String id) =>
      (db.select(db.entities)..where((e) => e.id.equals(id))).watchSingleOrNull();

  Future<String> saveEntity(EntitiesCompanion e) async {
    final id = e.id.present ? e.id.value : newId();
    await db.into(db.entities).insertOnConflictUpdate(e.copyWith(id: Value(id)));
    return id;
  }

  Future<void> renameEntity(String id, String name) =>
      (db.update(db.entities)..where((e) => e.id.equals(id))).write(EntitiesCompanion(name: Value(name)));

  Future<void> deleteEntity(String id) async {
    await (db.delete(db.mentions)..where((m) => m.entityId.equals(id))).go();
    await (db.delete(db.entityHistory)..where((m) => m.entityId.equals(id))).go();
    await (db.delete(db.relations)..where((r) => r.fromId.equals(id) | r.toId.equals(id))).go();
    await (db.delete(db.entities)..where((e) => e.id.equals(id))).go();
  }

  /// Contexto da campanha para a IA (só entidades confirmadas + sugeridas).
  Future<List<KnownEntity>> knownEntities(String cid) async => [
        for (final e in (await entitiesOf(cid)).where((e) => e.ownerId == null))
            KnownEntity(
                e.kind,
                e.name,
                e.aliases.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
                e.status)
      ];

  Future<List<String>> vocabularyHints(String cid) async {
    final out = <String>{};
    for (final e in await entitiesOf(cid)) {
      out.add(e.name);
      out.addAll(e.aliases.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty));
    }
    for (final h in await (db.select(db.heroes)..where((h) => h.campaignId.equals(cid))).get()) {
      out.add(h.name);
      if (h.player.isNotEmpty) out.add(h.player);
      out.addAll(heroAliases(h));
    }
    // Termos do sistema (classes, raças, recursos): ajudam a reconhecer o áudio.
    final camp = await campaign(cid);
    if (camp != null) out.addAll(profileFor(camp.system).vocab);
    return out.toList();
  }

  /// Procura entidade existente do mesmo tipo com nome/apelido equivalente.
  Entity? findMatch(List<Entity> all, String kind, String name, List<String> aliases) {
    for (final e in all.where((e) => e.kind == kind)) {
      final names = [e.name, ...e.aliases.split(',').map((s) => s.trim())];
      for (final n in names.where((n) => n.isNotEmpty)) {
        if (sameName(n, name) || aliases.any((a) => sameName(n, a))) return e;
      }
    }
    return null;
  }

  // ---------- Revisão ----------
  Stream<List<Mention>> watchPendingMentions(String sid) => (db.select(db.mentions)
        ..where((m) => m.sessionId.equals(sid) & m.status.equals('suggested'))
        ..orderBy([(m) => OrderingTerm.asc(m.atMs)]))
      .watch();
  Stream<List<Mention>> watchMentionsOfEntity(String eid) => (db.select(db.mentions)
        ..where((m) => m.entityId.equals(eid))
        ..orderBy([(m) => OrderingTerm.asc(m.atMs)]))
      .watch();
  Stream<List<Mention>> watchMentionsOfSession(String sid) => (db.select(db.mentions)
        ..where((m) => m.sessionId.equals(sid)))
      .watch();
  Future<List<Mention>> pendingMentions(String sid) => (db.select(db.mentions)
        ..where((m) => m.sessionId.equals(sid) & m.status.equals('suggested')))
      .get();

  Future<void> _applyField(Entity e, String field, String value, String sessionId) async {
    if (value.isEmpty) return;
    final old = switch (field) {
      'status' => e.status,
      'attr' => e.attr,
      'description' => e.description,
      _ => '',
    };
    if (old == value) return;
    final c = switch (field) {
      'status' => EntitiesCompanion(status: Value(value)),
      'attr' => EntitiesCompanion(attr: Value(value)),
      'description' => EntitiesCompanion(description: Value(value)),
      _ => null,
    };
    if (c == null) return;
    await (db.update(db.entities)..where((x) => x.id.equals(e.id))).write(c);
    await db.into(db.entityHistory).insert(EntityHistoryCompanion.insert(
        id: newId(), entityId: e.id, sessionId: sessionId,
        field: field, oldValue: Value(old), newValue: Value(value)));
  }

  /// Confirmar: a entidade vira "fato", a mudança proposta é aplicada e entra no histórico.
  Future<void> confirmMention(String mentionId) async {
    final m = await (db.select(db.mentions)..where((x) => x.id.equals(mentionId))).getSingle();
    final e = await entity(m.entityId);
    if (e != null) {
      if (e.review != 'confirmed') {
        await (db.update(db.entities)..where((x) => x.id.equals(e.id)))
            .write(const EntitiesCompanion(review: Value('confirmed')));
        await db.into(db.entityHistory).insert(EntityHistoryCompanion.insert(
            id: newId(), entityId: e.id, sessionId: m.sessionId,
            field: 'criada', newValue: Value(e.name)));
        if (e.status.isNotEmpty) {
          await db.into(db.entityHistory).insert(EntityHistoryCompanion.insert(
              id: newId(), entityId: e.id, sessionId: m.sessionId,
              field: 'status', newValue: Value(e.status)));
        }
      }
      if (m.proposedField.isNotEmpty) {
        await _applyField((await entity(e.id))!, m.proposedField, m.proposedValue, m.sessionId);
      }
    }
    await (db.update(db.mentions)..where((x) => x.id.equals(mentionId)))
        .write(const MentionsCompanion(status: Value('confirmed')));
  }

  Future<void> discardMention(String mentionId) async {
    final m = await (db.select(db.mentions)..where((x) => x.id.equals(mentionId))).getSingle();
    await (db.delete(db.mentions)..where((x) => x.id.equals(mentionId))).go();
    final e = await entity(m.entityId);
    if (e != null && e.review == 'suggested') {
      final left = await (db.select(db.mentions)..where((x) => x.entityId.equals(e.id))).get();
      if (left.isEmpty) await deleteEntity(e.id);
    }
  }

  /// Mescla [fromId] em [intoId]: menções e histórico migram; nome vira apelido.
  Future<void> mergeEntities(String fromId, String intoId) async {
    if (fromId == intoId) return;
    final from = await entity(fromId);
    final into = await entity(intoId);
    if (from == null || into == null) return;
    final aliases = {
      ...into.aliases.split(',').map((s) => s.trim()),
      ...from.aliases.split(',').map((s) => s.trim()),
      from.name,
    }..removeWhere((s) => s.isEmpty || s == into.name);
    await (db.update(db.entities)..where((x) => x.id.equals(intoId))).write(
        EntitiesCompanion(
            aliases: Value(aliases.join(', ')),
            description: Value(into.description.isEmpty ? from.description : into.description),
            review: Value(into.review == 'confirmed' || from.review == 'confirmed'
                ? 'confirmed' : 'suggested')));
    await (db.update(db.mentions)..where((x) => x.entityId.equals(fromId)))
        .write(MentionsCompanion(entityId: Value(intoId)));
    await (db.update(db.entityHistory)..where((x) => x.entityId.equals(fromId)))
        .write(EntityHistoryCompanion(entityId: Value(intoId)));
    await (db.update(db.entities)..where((x) => x.parentId.equals(fromId)))
        .write(EntitiesCompanion(parentId: Value(intoId)));
    await (db.update(db.relations)..where((r) => r.fromId.equals(fromId))).write(RelationsCompanion(fromId: Value(intoId)));
    await (db.update(db.relations)..where((r) => r.toId.equals(fromId))).write(RelationsCompanion(toId: Value(intoId)));
    await (db.delete(db.relations)..where((r) => r.fromId.equals(intoId) & r.toId.equals(intoId))).go();
    await (db.delete(db.entities)..where((x) => x.id.equals(fromId))).go();
  }

  /// Confirma e aplica às fichas os fatos de combate da sessão.
  Future<void> _confirmFactsOf(String sid) async {
    for (final f in await (db.select(db.facts)..where((x) => x.sessionId.equals(sid) & x.status.equals('suggested'))).get()) {
      await applyFact(f);
    }
  }

  Future<void> confirmAll(String sid) async {
    for (final m in await pendingMentions(sid)) {
      await confirmMention(m.id);
    }
    await confirmEvents(sid);
    await _confirmFactsOf(sid);
    await setSessionStatus(sid, 'done');
  }

  Stream<List<Event>> watchEvents(String sid) => (db.select(db.events)
        ..where((e) => e.sessionId.equals(sid))
        ..orderBy([(e) => OrderingTerm.asc(e.ord)]))
      .watch();
  Future<void> confirmEvents(String sid) =>
      (db.update(db.events)..where((e) => e.sessionId.equals(sid)))
          .write(const EventsCompanion(review: Value('confirmed')));
  Future<void> deleteEvent(String id) =>
      (db.delete(db.events)..where((e) => e.id.equals(id))).go();

  Stream<List<EntityHistoryData>> watchHistory(String cid) {
    final q = db.select(db.entityHistory).join([
      innerJoin(db.entities, db.entities.id.equalsExp(db.entityHistory.entityId)),
    ])..where(db.entities.campaignId.equals(cid));
    return q.watch().map((rows) => rows.map((r) => r.readTable(db.entityHistory)).toList());
  }
  Stream<List<EntityHistoryData>> watchHistoryOfEntity(String eid) =>
      (db.select(db.entityHistory)..where((h) => h.entityId.equals(eid))).watch();

  // ---------- Uso/custo ----------
  Future<void> logUsage(String cid, String provider, String step, UsageInfo u, double cost) =>
      db.into(db.usageLog).insert(UsageLogCompanion.insert(
          id: newId(), campaignId: cid, provider: provider, step: step,
          inputTokens: u.inputTokens, outputTokens: u.outputTokens,
          costUsd: cost, at: DateTime.now()));

  Stream<double> watchSpent(String cid) => (db.select(db.usageLog)
        ..where((u) => u.campaignId.equals(cid)))
      .watch()
      .map((l) => l.fold<double>(0, (a, b) => a + b.costUsd));

  Future<List<String>> bookmarks(String sid) async {
    final s = await session(sid);
    return s == null ? [] : (jsonDecode(s.bookmarks) as List).map((e) => e.toString()).toList();
  }
}
