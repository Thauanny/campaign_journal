import '../data/database.dart';

/// Normaliza para comparar: minúsculas, sem acentos nem pontuação.
String normText(String s) {
  const from = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
  const to = 'aaaaaeeeeiiiiooooouuuucn';
  final b = StringBuffer();
  for (final r in s.toLowerCase().runes) {
    final ch = String.fromCharCode(r);
    final i = from.indexOf(ch);
    b.write(i >= 0 ? to[i] : ch);
  }
  return b.toString().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
}

/// Acha o trecho real da transcrição onde algo aconteceu. A IA costuma errar o
/// horário (muitas vezes devolve 0 ou o mesmo para tudo), então procuramos
/// primeiro pela CITAÇÃO, depois pelo NOME; o horário só desempata.
Segment? locateMention(List<Segment> segs, {required String quote, required String name, List<String> aliases = const [], int? atMs}) {
  if (segs.isEmpty) return null;
  final norm = [for (final s in segs) normText(s.text_)];

  Segment? nearest(List<int> idx) {
    if (idx.isEmpty) return null;
    if (atMs == null) return segs[idx.first];
    idx.sort((a, b) => (segs[a].startMs - atMs).abs().compareTo((segs[b].startMs - atMs).abs()));
    return segs[idx.first];
  }

  final q = normText(quote);
  if (q.length >= 10) {
    final hit = <int>[];
    for (var i = 0; i < segs.length; i++) {
      final t = norm[i];
      if (t.isEmpty) continue;
      if (t.contains(q) || (t.length >= 12 && q.contains(t))) hit.add(i);
    }
    final r = nearest(hit);
    if (r != null) return r;
    // citação parcial: as primeiras palavras
    final words = q.split(' ');
    if (words.length >= 4) {
      final head = words.take(4).join(' ');
      final hit2 = [for (var i = 0; i < segs.length; i++) if (norm[i].contains(head)) i];
      final r2 = nearest(hit2);
      if (r2 != null) return r2;
    }
  }
  for (final n in [name, ...aliases]) {
    final nn = normText(n);
    if (nn.length < 3) continue;
    final hit = [for (var i = 0; i < segs.length; i++) if (' ${norm[i]} '.contains(' $nn ')) i];
    final r = nearest(hit);
    if (r != null) return r;
  }
  return null;
}
