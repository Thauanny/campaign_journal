import 'dart:math' as math;

import 'package:drift/drift.dart';

import '../domain/models.dart';
import '../domain/spell_detector.dart';
import 'database.dart';
import 'repository.dart';

/// Fatos de combate (dano, cura, XP…) e ficha viva dos heróis (PV e XP).
extension RepoFacts on Repository {
  Stream<List<Fact>> watchFacts(String sid) => (db.select(db.facts)
        ..where((f) => f.sessionId.equals(sid))
        ..orderBy([(f) => OrderingTerm.asc(f.atMs)]))
      .watch();

  Future<List<Fact>> factsOf(String sid) => (db.select(db.facts)..where((f) => f.sessionId.equals(sid))).get();

  Future<List<Heroe>> heroesOf(String cid) => (db.select(db.heroes)..where((h) => h.campaignId.equals(cid))).get();

  /// Substitui os fatos AINDA não aplicados da sessão (reprocessar não duplica).
  Future<void> replaceFacts(String cid, String sid, List<ExtractedFact> facts, {int? Function(ExtractedFact)? timeOf}) async {
    await (db.delete(db.facts)..where((f) => f.sessionId.equals(sid) & f.applied.equals(false))).go();
    for (final f in facts) {
      await db.into(db.facts).insert(FactsCompanion.insert(
            id: newId(),
            campaignId: cid,
            sessionId: sid,
            kind: f.kind,
            actor: Value(f.actor),
            target: Value(f.target),
            side: Value(f.side),
            amount: Value(f.amount),
            text_: Value(f.text),
            atMs: Value(timeOf == null ? f.atMs : timeOf(f)),
            quote: Value(f.quote),
          ));
    }
  }

  bool _heroMatches(Heroe h, String name) => isHeroName(name, heroKeys([h.name, h.player]));

  /// Aplica um fato confirmado às fichas: dano/cura mexem nos PV; XP soma.
  /// Dano e cura só valem para heróis com PV cadastrado.
  Future<void> applyFact(Fact f) async {
    if (f.applied) return;
    final amount = f.amount ?? 0;
    if (amount > 0 && (f.kind == 'damage' || f.kind == 'heal' || f.kind == 'xp')) {
      final heroes = await heroesOf(f.campaignId);
      final t = f.target.trim().toLowerCase();
      final everyone = f.kind == 'xp' && (t.isEmpty || const {'grupo', 'party', 'todos', 'heróis', 'herois', 'o grupo'}.contains(t));
      final targets = everyone ? heroes : heroes.where((h) => t.isNotEmpty && _heroMatches(h, f.target)).toList();
      for (final h in targets) {
        switch (f.kind) {
          case 'damage':
            if (h.hpCurrent != null) await _setHp(h, math.max(0, h.hpCurrent! - amount));
          case 'heal':
            if (h.hpCurrent != null) {
              final top = h.hpMax ?? (h.hpCurrent! + amount);
              await _setHp(h, math.min(top, h.hpCurrent! + amount));
            }
          case 'xp':
            await (db.update(db.heroes)..where((x) => x.id.equals(h.id))).write(HeroesCompanion(xp: Value(h.xp + amount)));
        }
      }
    }
    await (db.update(db.facts)..where((x) => x.id.equals(f.id))).write(const FactsCompanion(status: Value('confirmed'), applied: Value(true)));
  }

  Future<void> _setHp(Heroe h, int hp) =>
      (db.update(db.heroes)..where((x) => x.id.equals(h.id))).write(HeroesCompanion(hpCurrent: Value(hp)));

  Future<void> confirmFact(String id) async {
    final f = await (db.select(db.facts)..where((x) => x.id.equals(id))).getSingleOrNull();
    if (f != null) await applyFact(f);
  }

  Future<void> discardFact(String id) => (db.delete(db.facts)..where((x) => x.id.equals(id))).go();

  Future<void> confirmAllFacts(String sid) async {
    for (final f in await (db.select(db.facts)..where((x) => x.sessionId.equals(sid) & x.status.equals('suggested'))).get()) {
      await applyFact(f);
    }
  }

  /// Desfaz nas fichas o que os fatos APLICADOS desta sessão fizeram (dano, cura, XP).
  Future<void> revertFactsOf(String sid) async {
    for (final f in await (db.select(db.facts)..where((x) => x.sessionId.equals(sid) & x.applied.equals(true))).get()) {
      final amount = f.amount ?? 0;
      if (amount <= 0) continue;
      final heroes = await heroesOf(f.campaignId);
      final t = f.target.trim().toLowerCase();
      final everyone = f.kind == 'xp' && (t.isEmpty || const {'grupo', 'party', 'todos', 'heróis', 'herois', 'o grupo'}.contains(t));
      final targets = everyone ? heroes : heroes.where((h) => t.isNotEmpty && _heroMatches(h, f.target)).toList();
      for (final h in targets) {
        switch (f.kind) {
          case 'damage':
            if (h.hpCurrent != null) await _setHp(h, math.min(h.hpMax ?? (h.hpCurrent! + amount), h.hpCurrent! + amount));
          case 'heal':
            if (h.hpCurrent != null) await _setHp(h, math.max(0, h.hpCurrent! - amount));
          case 'xp':
            await (db.update(db.heroes)..where((x) => x.id.equals(h.id))).write(HeroesCompanion(xp: Value(math.max(0, h.xp - amount))));
        }
      }
    }
  }

  /// Entradas da enciclopédia que não aparecem em NENHUMA sessão (restos de sessões
  /// já apagadas ou criadas à mão). Itens de inventário de heróis ficam de fora.
  Future<List<Entity>> orphanEntities(String cid) async {
    final all = await entitiesOf(cid);
    final withMention = (await db.select(db.mentions).get()).map((m) => m.entityId).toSet();
    return all.where((e) => e.ownerId == null && !withMention.contains(e.id)).toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  /// O que a exclusão de uma sessão afetaria (para perguntar antes).
  Future<({List<Entity> exclusive, int appliedFacts})> deletionPreview(String sid) async {
    final ms = await (db.select(db.mentions)..where((m) => m.sessionId.equals(sid))).get();
    final exclusive = <Entity>[];
    for (final id in ms.map((m) => m.entityId).toSet()) {
      final other = await (db.select(db.mentions)..where((m) => m.entityId.equals(id) & m.sessionId.equals(sid).not())).get();
      final e = await entity(id);
      if (other.isEmpty && e != null && e.ownerId == null) exclusive.add(e);
    }
    final applied = await (db.select(db.facts)..where((f) => f.sessionId.equals(sid) & f.applied.equals(true))).get();
    return (exclusive: exclusive, appliedFacts: applied.length);
  }

  // ───── ficha do herói (edição manual) ─────
  Future<void> setHeroVitals(String id, {int? hpCurrent, int? hpMax, int? xp, bool clearHp = false}) =>
      (db.update(db.heroes)..where((h) => h.id.equals(id))).write(HeroesCompanion(
        hpCurrent: clearHp ? const Value(null) : (hpCurrent == null ? const Value.absent() : Value(hpCurrent)),
        hpMax: hpMax == null ? const Value.absent() : Value(hpMax),
        xp: xp == null ? const Value.absent() : Value(xp),
      ));

  /// +/- PV (limitado entre 0 e o máximo, se houver).
  Future<void> adjustHp(String id, int delta) async {
    final h = await hero(id);
    if (h == null) return;
    final cur = h.hpCurrent ?? h.hpMax ?? 0;
    var next = math.max(0, cur + delta);
    if (h.hpMax != null) next = math.min(h.hpMax!, next);
    await (db.update(db.heroes)..where((x) => x.id.equals(id))).write(HeroesCompanion(hpCurrent: Value(next)));
  }

  /// Fatos que afetaram um herói (para o histórico dele).
  Future<List<Fact>> factsAbout(String cid, Heroe h) async {
    final all = await (db.select(db.facts)..where((f) => f.campaignId.equals(cid) & f.status.equals('confirmed'))).get();
    return all.where((f) => f.target.isNotEmpty && _heroMatches(h, f.target)).toList()..sort((a, b) => b.id.compareTo(a.id));
  }
}

/// Frase curta de um fato ("Verren causou 8 de dano em Bram").
String factTitle(Fact f) {
  final amt = f.amount;
  final a = f.actor, t = f.target.isEmpty ? 'alguém' : f.target;
  return switch (f.kind) {
    'damage' => amt == null ? '$t sofreu dano${a.isEmpty ? '' : ' de $a'}' : (a.isEmpty ? '$t sofreu $amt de dano' : '$a causou $amt de dano em $t'),
    'heal' => '$t recuperou ${amt ?? '?'} PV${a.isEmpty ? '' : ' (por $a)'}',
    'xp' => '${f.target.isEmpty ? 'O grupo' : f.target} ganhou ${amt ?? '?'} XP',
    'condition' => f.text_.isEmpty ? 'Condição em $t' : '$t: ${f.text_}',
    _ => f.text_.isEmpty ? 'Saque' : f.text_,
  };
}
