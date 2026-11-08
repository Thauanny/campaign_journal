import 'package:drift/drift.dart';

import 'database.dart';
import 'repository.dart';

/// Ganchos em aberto, segredos/pistas, início forte e ligações entre entidades.
extension RepoNotes on Repository {
  Stream<List<Note>> watchNotes(String cid, String kind) => (db.select(db.notes)
        ..where((n) => n.campaignId.equals(cid) & n.kind.equals(kind))
        ..orderBy([(n) => OrderingTerm.asc(n.status), (n) => OrderingTerm.desc(n.createdAt)]))
      .watch();

  Future<List<Note>> notesOf(String cid, String kind) => (db.select(db.notes)
        ..where((n) => n.campaignId.equals(cid) & n.kind.equals(kind))
        ..orderBy([(n) => OrderingTerm.asc(n.status), (n) => OrderingTerm.desc(n.createdAt)]))
      .get();

  Future<void> addNote(String cid, String kind, String body, {String? sessionId, String source = 'manual'}) async {
    final t = body.trim();
    if (t.isEmpty) return;
    await db.into(db.notes).insert(NotesCompanion.insert(
        id: newId(), campaignId: cid, kind: kind, body: t, sessionId: Value(sessionId), source: Value(source), createdAt: DateTime.now()));
  }

  Future<void> setNoteStatus(String id, String status) =>
      (db.update(db.notes)..where((n) => n.id.equals(id))).write(NotesCompanion(status: Value(status)));

  Future<void> deleteNote(String id) => (db.delete(db.notes)..where((n) => n.id.equals(id))).go();

  /// Substitui os ganchos que a IA gerou para [sessionId] (reprocessar não duplica).
  Future<void> replaceAiThreads(String cid, String sessionId, List<String> threads) async {
    await (db.delete(db.notes)
          ..where((n) => n.sessionId.equals(sessionId) & n.kind.equals('thread') & n.source.equals('ai') & n.status.equals('open')))
        .go();
    for (final t in threads) {
      await addNote(cid, 'thread', t, sessionId: sessionId, source: 'ai');
    }
  }

  /// Início forte da próxima sessão (uma nota única por campanha).
  Future<void> setStrongStart(String cid, String body) async {
    await (db.delete(db.notes)..where((n) => n.campaignId.equals(cid) & n.kind.equals('strong_start'))).go();
    await addNote(cid, 'strong_start', body);
  }

  // ───── ligações entre entidades ─────
  Stream<List<Relation>> watchRelations(String cid) =>
      (db.select(db.relations)..where((r) => r.campaignId.equals(cid))).watch();

  Future<void> addRelation(String cid, String fromId, String toId, String label) async {
    if (fromId == toId) return;
    await db.into(db.relations).insert(RelationsCompanion.insert(
        id: newId(), campaignId: cid, fromId: fromId, toId: toId, label: Value(label.trim())));
  }

  /// Cria a ligação só se ainda não existir (mesmos extremos e rótulo).
  Future<void> ensureRelation(String cid, String fromId, String toId, String label) async {
    if (fromId == toId) return;
    final ex = await (db.select(db.relations)
          ..where((r) => r.fromId.equals(fromId) & r.toId.equals(toId) & r.label.equals(label.trim())))
        .get();
    if (ex.isEmpty) await addRelation(cid, fromId, toId, label);
  }

  Future<void> deleteRelation(String id) => (db.delete(db.relations)..where((r) => r.id.equals(id))).go();

  Future<void> deleteRelationsOf(String entityId) =>
      (db.delete(db.relations)..where((r) => r.fromId.equals(entityId) | r.toId.equals(entityId))).go();

  Future<void> moveRelations(String fromEntity, String intoEntity) async {
    await (db.update(db.relations)..where((r) => r.fromId.equals(fromEntity))).write(RelationsCompanion(fromId: Value(intoEntity)));
    await (db.update(db.relations)..where((r) => r.toId.equals(fromEntity))).write(RelationsCompanion(toId: Value(intoEntity)));
    // remove laços de uma entidade com ela mesma criados pela mesclagem
    await (db.delete(db.relations)..where((r) => r.fromId.equals(intoEntity) & r.toId.equals(intoEntity))).go();
  }
}
