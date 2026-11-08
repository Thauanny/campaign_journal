/// Comparação de nomes para a etapa de mesclagem ("SerAldo" = "o cavaleiro Aldo").
String stripAccents(String s) {
  const from = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
  const to = 'aaaaaeeeeiiiiooooouuuucn';
  final b = StringBuffer();
  for (final c in s.toLowerCase().split('')) {
    final i = from.indexOf(c);
    b.write(i >= 0 ? to[i] : c);
  }
  return b.toString();
}

const _fillers = {
  'ser', 'sir', 'o', 'a', 'os', 'as', 'de', 'do', 'da', 'dos', 'das', 'dom',
  'dona', 'lorde', 'lord', 'lady', 'cavaleiro', 'capitao', 'senhor', 'senhora',
  'rei', 'rainha', 'mestre', 'mago', 'maga', 'the', 'um', 'uma', 'cidade',
  'vila', 'reino', 'taverna', 'ordem', 'guilda',
};

Set<String> nameTokens(String name) {
  // separa CamelCase colado: "SerAldo" -> "Ser Aldo"
  final spaced = name.replaceAllMapped(
      RegExp(r'([a-zà-ÿ])([A-ZÀ-Ý])'), (m) => '${m[1]} ${m[2]}');
  final toks = stripAccents(spaced)
      .split(RegExp(r"[^a-z0-9]+"))
      .where((t) => t.isNotEmpty && !_fillers.contains(t))
      .toSet();
  return toks;
}

int _lev(String a, String b) {
  if (a == b) return 0;
  var prev = List<int>.generate(b.length + 1, (i) => i);
  for (var i = 1; i <= a.length; i++) {
    final cur = List<int>.filled(b.length + 1, 0)..[0] = i;
    for (var j = 1; j <= b.length; j++) {
      cur[j] = [
        prev[j] + 1,
        cur[j - 1] + 1,
        prev[j - 1] + (a[i - 1] == b[j - 1] ? 0 : 1)
      ].reduce((x, y) => x < y ? x : y);
    }
    prev = cur;
  }
  return prev[b.length];
}

/// Verdadeiro se [a] e [b] provavelmente são a mesma entidade.
bool sameName(String a, String b) {
  final ta = nameTokens(a), tb = nameTokens(b);
  if (ta.isEmpty || tb.isEmpty) {
    return stripAccents(a).trim() == stripAccents(b).trim();
  }
  if (ta.length == tb.length && ta.containsAll(tb)) return true;
  if (ta.containsAll(tb) || tb.containsAll(ta)) return true;
  // erro de grafia da transcrição: 1 letra de diferença em nome único longo
  if (ta.length == 1 && tb.length == 1) {
    final x = ta.first, y = tb.first;
    if (x.length >= 5 && y.length >= 5 && _lev(x, y) <= 1) return true;
  }
  return false;
}
