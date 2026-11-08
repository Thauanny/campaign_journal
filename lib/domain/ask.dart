import 'systems.dart';
import '../data/database.dart';
import 'name_match.dart';
import 'pipeline.dart' show fmtClock;

class Passage {
  final int sessionNumber;
  final int atMs;
  final String text;
  final double score;
  const Passage(this.sessionNumber, this.atMs, this.text, this.score);
}

Set<String> _terms(String q) => stripAccents(q)
    .split(RegExp(r'[^a-z0-9]+'))
    .where((w) => w.length > 3 && !const {'quem', 'qual', 'quais', 'onde', 'como', 'quando', 'sobre', 'era', 'foi', 'esta', 'esse', 'essa', 'para', 'pelo', 'pela'}.contains(w))
    .toSet();

/// Recuperação simples por sobreposição de termos (sem embeddings, offline).
List<Passage> retrievePassages(String question, List<Session> sessions, Map<String, List<Segment>> segs, {int top = 12}) {
  final terms = _terms(question);
  if (terms.isEmpty) return [];
  final out = <Passage>[];
  for (final s in sessions) {
    final list = segs[s.id] ?? [];
    for (var i = 0; i < list.length; i++) {
      final t = stripAccents(list[i].text_);
      final hits = terms.where(t.contains).length;
      if (hits == 0) continue;
      final ctx = list.sublist((i - 1).clamp(0, list.length), (i + 2).clamp(0, list.length)).map((x) => x.text_).join(' ');
      out.add(Passage(s.number, list[i].startMs, ctx, hits / terms.length));
    }
  }
  out.sort((a, b) => b.score.compareTo(a.score));
  return out.take(top).toList();
}

String askSystem({String system = ''}) => '''
Você responde perguntas sobre uma campanha de RPG usando SOMENTE os trechos fornecidos.
Cite a fonte no formato (Sessão N, mm:ss). Se os trechos não responderem, diga que não encontrou na campanha.
Responda em português do Brasil, de forma curta. Responda SOMENTE com JSON: {"answer":"..."}
${system.isEmpty ? '' : '\n${systemContext(system)}'}''';

String askUser(String question, List<Passage> ps, List<Entity> ents) {
  final b = StringBuffer('Pergunta: $question\n\nFichas confirmadas:\n');
  for (final e in ents.where((e) => e.review == 'confirmed').take(60)) {
    b.writeln('- ${e.name} (${e.kind}${e.status.isEmpty ? '' : ', ${e.status}'}): ${e.description}');
  }
  b.writeln('\nTrechos:');
  for (final p in ps) {
    b.writeln('(Sessão ${p.sessionNumber}, ${fmtClock(p.atMs)}) ${p.text}');
  }
  return b.toString();
}
