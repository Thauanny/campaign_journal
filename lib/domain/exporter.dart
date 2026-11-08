import '../data/database.dart';
import 'pipeline.dart' show fmtClock;

class ExportData {
  final Campaign campaign;
  final List<Session> sessions;
  final List<Entity> entities;
  final List<Mention> mentions;
  final List<Event> events;
  final List<Segment> Function(String sessionId) segments;
  ExportData(this.campaign, this.sessions, this.entities, this.mentions, this.events, this.segments);
}

const _kind = {'npc': 'NPCs', 'location': 'Locais', 'quest': 'Missões', 'item': 'Itens', 'faction': 'Facções', 'spell': 'Feitiços'};

String _safe(String s) => s.replaceAll(RegExp(r'[\\/:*?"<>|#\[\]^]'), '').trim();

String sessionMarkdown(ExportData d, Session s, {bool transcript = false, bool wikilinks = false}) {
  final b = StringBuffer('# Sessão ${s.number} — ${d.campaign.name}\n\n');
  b.writeln('*${s.date.day.toString().padLeft(2, '0')}/${s.date.month.toString().padLeft(2, '0')}/${s.date.year}*\n');
  if (s.shortSummary.isNotEmpty) b.writeln('## Resumo\n\n${s.shortSummary}\n');
  if (s.longSummary.isNotEmpty) b.writeln('## Crônica\n\n${s.longSummary}\n');
  if (s.previouslyOn.isNotEmpty) b.writeln('## Anteriormente em…\n\n${s.previouslyOn}\n');
  final evs = d.events.where((e) => e.sessionId == s.id && e.review == 'confirmed').toList()..sort((a, b) => a.ord.compareTo(b.ord));
  if (evs.isNotEmpty) {
    b.writeln('## Linha do tempo\n');
    for (final e in evs) { b.writeln('- ${e.atMs != null ? '[${fmtClock(e.atMs!)}] ' : ''}${e.text_}'); }
    b.writeln();
  }
  final ids = d.mentions.where((m) => m.sessionId == s.id && m.status == 'confirmed').map((m) => m.entityId).toSet();
  final ents = d.entities.where((e) => ids.contains(e.id)).toList();
  if (ents.isNotEmpty) {
    b.writeln('## Entidades\n');
    for (final e in ents) {
      b.writeln('- ${wikilinks ? '[[${_safe(e.name)}]]' : '**${e.name}**'} (${_kind[e.kind]}${e.status.isEmpty ? '' : ', ${e.status}'})');
    }
    b.writeln();
  }
  if (transcript) {
    b.writeln('## Transcrição\n');
    for (final g in d.segments(s.id)) {
      b.writeln('**[${fmtClock(g.startMs)}]** ${g.speaker != null ? '${g.speaker}: ' : ''}${g.text_}\n');
    }
  }
  return b.toString();
}

String entityMarkdown(ExportData d, Entity e, {bool wikilinks = false}) {
  final b = StringBuffer('# ${e.name}\n\n');
  b.writeln('- Tipo: ${_kind[e.kind]}');
  if (e.status.isNotEmpty) b.writeln('- Status: ${e.status}');
  if (e.attr.isNotEmpty) b.writeln('- Atributo: ${e.attr}');
  if (e.aliases.isNotEmpty) b.writeln('- Também: ${e.aliases}');
  if (e.giver.isNotEmpty) b.writeln('- Quem deu: ${e.giver}');
  if (e.reward.isNotEmpty) b.writeln('- Recompensa: ${e.reward}');
  if (e.description.isNotEmpty) b.writeln('\n${e.description}');
  final ms = d.mentions.where((m) => m.entityId == e.id && m.status == 'confirmed').toList();
  if (ms.isNotEmpty) {
    b.writeln('\n## Citações\n');
    for (final m in ms) {
      final n = d.sessions.where((s) => s.id == m.sessionId).firstOrNull?.number ?? '?';
      final ref = wikilinks ? '[[Sessão ${n.toString().padLeft(2, '0')}]]' : 'Sessão $n';
      b.writeln('- $ref${m.atMs != null ? ' · ${fmtClock(m.atMs!)}' : ''}${m.detail.isEmpty ? '' : ' · ${m.detail}'}${m.quote.isEmpty ? '' : ' — "${m.quote}"'}');
    }
  }
  return b.toString();
}

String campaignMarkdown(ExportData d, {bool transcript = false}) {
  final b = StringBuffer('# ${d.campaign.name}\n\n*${d.campaign.system}*\n\n');
  if (d.campaign.description.isNotEmpty) b.writeln('${d.campaign.description}\n');
  for (final s in d.sessions.where((s) => s.status == 'done' || s.shortSummary.isNotEmpty)) {
    b.writeln(sessionMarkdown(d, s, transcript: transcript).replaceFirst('# ', '## '));
  }
  b.writeln('\n# Enciclopédia\n');
  for (final k in _kind.entries) {
    final es = d.entities.where((e) => e.kind == k.key && e.review == 'confirmed').toList();
    if (es.isEmpty) continue;
    b.writeln('## ${k.value}\n');
    for (final e in es) {
      b.writeln('### ${e.name}\n\n${entityMarkdown(d, e).split('\n').skip(2).join('\n')}\n');
    }
  }
  return b.toString();
}

/// Texto para colar no Discord: usa o limite de 2000 caracteres por mensagem.
List<String> discordMessages(ExportData d, Session s) {
  final head = '📜 **${d.campaign.name} — Sessão ${s.number}**\n';
  final body = StringBuffer();
  if (s.previouslyOn.isNotEmpty) body.writeln('*${s.previouslyOn}*\n');
  if (s.shortSummary.isNotEmpty) body.writeln('**Resumo**\n${s.shortSummary}\n');
  if (s.longSummary.isNotEmpty) body.writeln('**Crônica**\n${s.longSummary}');
  final text = head + body.toString();
  final out = <String>[];
  var cur = StringBuffer();
  for (final para in text.split('\n')) {
    final line = para.length > 1900 ? para.substring(0, 1900) : para;
    if (cur.length + line.length + 1 > 1900) { out.add(cur.toString()); cur = StringBuffer(); }
    cur.writeln(line);
  }
  if (cur.isNotEmpty) out.add(cur.toString());
  return out;
}

/// Arquivos de um cofre Obsidian: `caminho relativo` → conteúdo.
Map<String, String> obsidianVault(ExportData d, {bool transcript = false}) {
  final files = <String, String>{};
  for (final s in d.sessions) {
    files['Sessões/Sessão ${s.number.toString().padLeft(2, '0')}.md'] = '---\nsessao: ${s.number}\ndata: ${s.date.toIso8601String().substring(0, 10)}\n---\n${sessionMarkdown(d, s, transcript: transcript, wikilinks: true)}';
  }
  for (final e in d.entities.where((e) => e.review == 'confirmed')) {
    files['${_kind[e.kind]}/${_safe(e.name)}.md'] = entityMarkdown(d, e, wikilinks: true);
  }
  return files;
}

/// Recap para os JOGADORES: só o que o grupo já viveu. Não inclui segredos,
/// ganchos nem notas de preparação do mestre.
String playerRecapMarkdown(ExportData d, {int last = 3}) {
  final b = StringBuffer('# ${d.campaign.name} — o que aconteceu até agora\n\n');
  final done = d.sessions
      .where((s) => s.shortSummary.isNotEmpty || s.longSummary.isNotEmpty)
      .toList()
    ..sort((a, c) => c.number.compareTo(a.number));
  if (done.isEmpty) return '$b(Ainda não há sessões resumidas.)\n';
  final recent = (last <= 0 ? done : done.take(last)).toList()..sort((a, c) => a.number.compareTo(c.number));
  final prev = done.first.previouslyOn;
  if (prev.isNotEmpty) b.writeln('## Anteriormente em…\n\n$prev\n');
  for (final s in recent) {
    b.writeln('## Sessão ${s.number}\n');
    b.writeln('${s.shortSummary.isNotEmpty ? s.shortSummary : s.longSummary}\n');
    final evs = d.events.where((e) => e.sessionId == s.id && e.review == 'confirmed').toList()..sort((a, c) => a.ord.compareTo(c.ord));
    if (evs.isNotEmpty) {
      for (final e in evs) { b.writeln('- ${e.text_}'); }
      b.writeln();
    }
  }
  for (final k in _kind.entries) {
    if (k.key == 'item') continue;
    final es = d.entities.where((e) => e.kind == k.key && e.review == 'confirmed').toList();
    if (es.isEmpty) continue;
    b.writeln('## ${k.value} que vocês conhecem\n');
    for (final e in es) { b.writeln('- ${e.name}${e.status.isEmpty ? '' : ' (${e.status})'}'); }
    b.writeln();
  }
  return b.toString();
}
