import '../domain/models.dart';

/// Detecta feitiços lançados em uma transcrição (que também vale para áudio,
/// já transcrito). Gera UM registro por uso, com quem lançou e o horário.
/// Funciona sem IA e complementa a extração por IA.

final _line = RegExp(r'^\[(\d+):(\d{2})(?::(\d{2}))?\]\s*(.*)$');
final _speaker = RegExp(r"^([A-ZÁÉÍÓÚÂÊÔÃÕÇ][\wáéíóúâêôãõç]{1,20}):\s+");
const _cap = r"A-ZÁÉÍÓÚÂÊÔÃÕÇ";
const _low = r"a-záéíóúâêôãõç";

// Verbos de conjuração (lanço/lança/lançou, conjuro…, ativo…, uso…, invoco…).
const _verbs = r"(?:lan[çc](?:o|a|ou|ando|amos)|conjur(?:o|a|ou|ando)|ativ(?:o|a|ou|ando)|us(?:o|a|ou|ando)|invoc(?:o|a|ou|ando)|cast(?:o|a|ou)|faço|faz|fez)";

/// Nomes de feitiços comuns (D&D 5e e Tormenta20 em pt-BR). Nomes de várias
/// palavras valem em qualquer lugar; os de uma palavra só contam perto de um
/// verbo de conjuração, para não confundir com "a luz do sol".
const _strong = [
  'Bola de Fogo', 'Mísseis Mágicos', 'Míssil Mágico', 'Projétil Mágico', 'Armadura Arcana', 'Escudo Arcano', 'Raio de Fogo', 'Raio Gélido',
  'Raio Ardente', 'Curar Ferimentos', 'Palavra de Cura', 'Cura Completa', 'Restauração Menor', 'Dissipar Magia', 'Porta Dimensional',
  'Passo Nebuloso', 'Imobilizar Pessoa', 'Patas de Aranha', 'Detectar Magia', 'Mãos Mágicas', 'Encantar Pessoa', 'Compreender Idiomas',
  'Muralha de Fogo', 'Tempestade de Gelo', 'Cone de Frio', 'Toque Chocante', 'Rajada de Fogo', 'Escudo da Fé', 'Armadura de Allihanna',
  'Luz do Dia', 'Relâmpago Elétrico', 'Palavra de Poder', 'Névoa Sombria', 'Chuva de Meteoros', 'Toque Vampírico', 'Curar Doenças',
  'Reviver os Mortos', 'Sopro do Dragão', 'Explosão Solar', 'Convocar Animais', 'Forma Selvagem',
];
const _weak = [
  'Cura', 'Escudo', 'Relâmpago', 'Invisibilidade', 'Voo', 'Teia', 'Sono', 'Luz', 'Medo', 'Maldição', 'Bênção', 'Sugestão', 'Despistar',
  'Prestidigitação', 'Orientação', 'Ressurreição', 'Contrafeitiço', 'Identificar', 'Amedrontar', 'Metamorfose', 'Silêncio', 'Teletransporte',
];

const _denyNames = {'Defesa', 'Rola', 'Ação', 'Dado', 'Turno', 'Ataque', 'Dano', 'Teste', 'Magia', 'Feitiço', 'Habilidade', 'Truque', 'Vida', 'Eu', 'Ele', 'Ela', 'Um', 'Uma'};

String _norm(String s) => s.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();

int _toMs(RegExpMatch m) {
  final a = int.parse(m.group(1)!), b = int.parse(m.group(2)!);
  final c = m.group(3);
  final sec = c == null ? a * 60 + b : a * 3600 + b * 60 + int.parse(c);
  return sec * 1000;
}

/// Lê "Participantes: Rafa (Bram Cascalho), Duda (Pimpão)" → {rafa: Bram Cascalho}.
Map<String, String> _characters(List<String> lines) {
  final out = <String, String>{};
  final re = RegExp(r"([A-ZÁÉÍÓÚÂÊÔÃÕÇ][\wáéíóúâêôãõç]+)\s*\(([^)]+)\)");
  for (final t in lines) {
    if (!t.toLowerCase().contains('particip')) continue;
    for (final m in re.allMatches(t)) {
      final role = m.group(2)!.trim();
      if (role.toLowerCase() != 'mestre') out[m.group(1)!.toLowerCase()] = role;
    }
  }
  return out;
}

/// Nomes que identificam um herói (nome completo, primeiro nome, jogador).
Set<String> heroKeys(Iterable<String> names) {
  final out = <String>{};
  for (final n in names) {
    final t = _norm(n);
    if (t.length < 2) continue;
    out.add(t);
    final first = t.split(' ').first;
    if (first.length >= 3) out.add(first);
  }
  return out;
}

bool isHeroName(String who, Set<String> keys) {
  final t = _norm(who.replaceAll(RegExp(r'\(.*?\)'), ' '));
  if (t.isEmpty) return false;
  if (keys.contains(t)) return true;
  // "Bram Cascalho (Rafa)": confere o personagem e o jogador
  for (final m in RegExp(r'\(([^)]+)\)').allMatches(who)) {
    if (keys.contains(_norm(m.group(1)!))) return true;
  }
  return t.split(' ').any((w) => w.length >= 3 && keys.contains(w));
}

final _cn = "[$_cap][\\w$_low']+(?:\\s+(?:de|da|do|dos|das)\\s+[$_cap][\\w$_low']+|\\s+[$_cap][\\w$_low']+)*";
final _targetRe = RegExp(
    '\\b(no|na|nos|nas)\\s+($_cn|[$_low]{3,})|\\b(em|contra|sobre|para)\\s+($_cn|(?:os|as|o|a)\\s+[$_low]{3,})');

/// Primeiro alvo citado depois do feitiço: "em Bram", "contra Verren", "nos recrutas".
String _targetOf(String rest) {
  final m = _targetRe.firstMatch(rest);
  if (m == null) return '';
  if (m.group(1) != null) {
    final w = m.group(2)!.trim();
    if (RegExp('^[$_cap]').hasMatch(w)) return w;
    const art = {'no': 'o', 'na': 'a', 'nos': 'os', 'nas': 'as'};
    return '${art[m.group(1)!]} $w';
  }
  return m.group(4)!.trim();
}

String _resultOf(String text) {
  final t = _norm(text);
  if (RegExp(r'\b(errou|erra|falh\w*|desvi\w*)\b').hasMatch(t)) return 'errou';
  if (RegExp(r'\b(resist\w*|passou no teste|passa no teste)\b').hasMatch(t)) return 'resistiu';
  if (RegExp(r'\b(acert\w*|atingi\w*|pegou|pega em cheio)\b').hasMatch(t)) return 'acertou';
  if (RegExp(r'\b(cur\w*|recuper\w*)\b').hasMatch(t)) return 'curou';
  return '';
}

/// Quem é o mestre: marcado como "(Mestre)" no cabeçalho de participantes.
Set<String> _gmNames(List<String> lines) {
  final out = <String>{'mestre', 'gm', 'narrador'};
  final re = RegExp(r"([A-ZÁÉÍÓÚÂÊÔÃÕÇ][\wáéíóúâêôãõç]+)\s*\(\s*mestre\s*\)", caseSensitive: false);
  for (final t in lines) {
    if (!t.toLowerCase().contains('particip')) continue;
    for (final m in re.allMatches(t)) {
      out.add(m.group(1)!.toLowerCase());
    }
  }
  return out;
}

List<ExtractedEntity> detectSpells(String transcript, {List<KnownEntity> known = const [], List<String> heroNames = const []}) {
  final rawLines = transcript.split('\n');
  final chars = _characters(rawLines);
  final gm = _gmNames(rawLines);
  final knownSpells = [for (final k in known) if (k.kind == 'spell') ...[k.name, ...k.aliases]];
  final strong = {..._strong, ...knownSpells};
  RegExp phrase(String n) => RegExp('(?<![\\w$_low$_cap])${RegExp.escape(n)}(?![\\w$_low$_cap])', caseSensitive: false);
  final strongRe = {for (final n in strong) n: phrase(n)};
  final weakRe = {for (final n in _weak) n: phrase(n)};
  final cue = RegExp('\\b$_verbs\\b', caseSensitive: false);
  final generic = RegExp(
      '\\b$_verbs\\s+(?:a magia|o feiti[çc]o|a habilidade|o truque|a|o)?\\s*([$_cap][\\w$_low\']+(?:\\s+(?:de|da|do|dos|das|e)\\s+[$_cap][\\w$_low\']+|\\s+[$_cap][\\w$_low\']+)*)');
  final subject = RegExp('([$_cap][\\w$_low]{2,})\\s+$_verbs\\b');

  final keys = heroKeys([...heroNames, ...chars.values, ...chars.keys]);
  final out = <ExtractedEntity>[];
  for (final raw in rawLines) {
    final m = _line.firstMatch(raw.trim());
    if (m == null) continue;
    final ms = _toMs(m);
    var text = m.group(4)!;
    final sp = _speaker.firstMatch(text);
    final speaker = sp?.group(1);
    if (speaker != null) text = text.substring(sp!.end);
    if (text.toLowerCase().startsWith('participantes')) continue;

    final found = <String>{};
    for (final e in strongRe.entries) {
      if (e.value.hasMatch(text)) found.add(e.key);
    }
    if (cue.hasMatch(text)) {
      for (final e in weakRe.entries) {
        if (e.value.hasMatch(text)) found.add(e.key);
      }
      for (final g in generic.allMatches(text)) {
        final name = g.group(1)!.trim();
        if (name.length >= 4 && !_denyNames.contains(name) && !_denyNames.contains(name.split(' ').first)) found.add(name);
      }
    }
    if (found.isEmpty) continue;
    // Remove nomes contidos em outros mais longos ("Cura" dentro de "Cura Completa").
    final names = found.where((n) => !found.any((o) => o != n && _norm(o).contains(_norm(n)))).toList();

    // Quem lançou: personagem de quem fala; senão o sujeito da frase.
    String caster = '';
    if (speaker != null && !gm.contains(speaker.toLowerCase())) {
      final c = chars[speaker.toLowerCase()];
      caster = c == null ? speaker : '$c ($speaker)';
    } else {
      final s = subject.firstMatch(text)?.group(1);
      if (s != null && !_denyNames.contains(s)) caster = s;
    }
    final quote = text.trim().length > 160 ? text.trim().substring(0, 160) : text.trim();
    // Lado: jogadores falam pelos heróis; narração do mestre → inimigo, a não ser que o sujeito seja um herói.
    var side = '';
    if (caster.isNotEmpty) {
      side = (speaker != null && !gm.contains(speaker.toLowerCase())) ? 'hero' : (isHeroName(caster, keys) ? 'hero' : 'enemy');
    }
    final result = _resultOf(text);
    for (final n in names) {
      // nome canônico se for um feitiço conhecido
      final canon = strong.firstWhere((k) => _norm(k) == _norm(n), orElse: () => n);
      // alvo: o primeiro "em/contra X" depois do nome do feitiço
      final at = text.toLowerCase().indexOf(n.toLowerCase());
      final rest = at < 0 ? text : text.substring(at + n.length);
      var target = _targetOf(rest);
      if (target.isNotEmpty && _norm(target) == _norm(canon)) target = '';
      out.add(ExtractedEntity(kind: 'spell', name: canon, caster: caster, target: target, side: side, result: result, atMs: ms, quote: quote));
    }
  }
  return out;
}

/// Junta os feitiços achados pelo detector aos da IA, sem duplicar o mesmo uso
/// (mesmo nome a menos de 10 s de distância).
List<ExtractedEntity> mergeSpellUses(List<ExtractedEntity> fromAi, List<ExtractedEntity> detected) {
  final ai = fromAi.where((e) => e.kind == 'spell').toList();
  final extra = <ExtractedEntity>[];
  for (final d in detected) {
    final dup = ai.any((a) =>
        _norm(a.name) == _norm(d.name) && (a.atMs == null || d.atMs == null || (a.atMs! - d.atMs!).abs() <= 10000));
    if (!dup) extra.add(d);
  }
  return extra;
}
