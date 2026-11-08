import 'dart:convert';

import '../data/database.dart';
import 'models.dart';
import 'spell_detector.dart';
import 'systems.dart';

/// Apelidos extras do herói (guardados em `extra`).
List<String> heroAliases(Heroe h) {
  try {
    final m = jsonDecode(h.extra);
    final a = m is Map ? (m['apelidos'] ?? '').toString() : '';
    return a.split(RegExp(r'[,;]')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  } catch (_) {
    return const [];
  }
}

Map<String, String> heroFields(Heroe h) {
  try {
    final m = jsonDecode(h.extra);
    return m is Map ? m.map((k, v) => MapEntry(k.toString(), v.toString())) : {};
  } catch (_) {
    return {};
  }
}

/// Todos os nomes que identificam os heróis: personagem, jogador e apelidos.
List<String> heroNamesFor(List<Heroe> heroes) => [
      for (final h in heroes) ...[h.name, if (h.player.isNotEmpty) h.player, ...heroAliases(h)],
    ];

/// Texto que descreve os heróis cadastrados para a IA (extração e resumo).
/// É o que permite à IA casar nomes da transcrição com os personagens reais.
String heroContext(List<Heroe> heroes, String system) {
  if (heroes.isEmpty) return '';
  final prof = profileFor(system);
  final b = StringBuffer();
  b.writeln('HERÓIS CADASTRADOS (o grupo dos jogadores). Use EXATAMENTE estes nomes:');
  final extras = {for (final e in prof.extras) e.key: e.label};
  for (final h in heroes) {
    final f = heroFields(h);
    final parts = <String>[
      if (h.player.isNotEmpty) 'jogador ${h.player}',
      if (heroAliases(h).isNotEmpty) 'também chamado de ${heroAliases(h).join(' / ')}',
      if (h.heroClass.isNotEmpty) '${prof.classLabel.toLowerCase()}: ${h.heroClass}',
      if (h.race.isNotEmpty) '${prof.raceLabel.toLowerCase()}: ${h.race}',
      '${prof.levelLabel.toLowerCase()}: ${h.level}',
      if (h.hpMax != null) '${prof.hpLabel}: ${h.hpCurrent ?? h.hpMax}/${h.hpMax}',
      for (final e in extras.entries)
        if ((f[e.key] ?? '').isNotEmpty) '${e.value}: ${f[e.key]}',
    ];
    b.writeln('- ${h.name} — ${parts.join('; ')}');
  }
  b.writeln('REGRAS SOBRE OS HERÓIS:');
  b.writeln('1) Quem fala como "NomeDoJogador:" está falando pelo herói dele.');
  b.writeln('2) Um nome da transcrição parecido com um herói (erro de reconhecimento de voz, apelido, só o primeiro nome) é o herói: escreva sempre a grafia cadastrada.');
  b.writeln('3) NÃO crie entidade (NPC, aliado, inimigo) para um herói. Heróis têm lado "hero".');
  b.writeln('4) Cite sempre o PERSONAGEM (ex.: "${heroes.first.name}"), não o jogador.');
  return b.toString();
}

/// Nome cadastrado do herói a que [name] se refere (ou nulo).
String? canonicalHero(String name, List<Heroe> heroes) {
  if (name.trim().isEmpty) return null;
  for (final h in heroes) {
    if (isHeroName(name, heroKeys([h.name, h.player, ...heroAliases(h)]))) return h.name;
  }
  return null;
}

/// Casa os nomes devolvidos pela IA com os heróis cadastrados: remove "NPCs"
/// que na verdade são heróis e troca apelidos/jogadores pelo nome oficial.
({List<ExtractedEntity> entities, List<ExtractedFact> facts, int dropped}) normalizeHeroNames(
    List<ExtractedEntity> entities, List<ExtractedFact> facts, List<Heroe> heroes) {
  if (heroes.isEmpty) return (entities: entities, facts: facts, dropped: 0);
  String fix(String n) => canonicalHero(n, heroes) ?? n;
  var dropped = 0;
  final outE = <ExtractedEntity>[];
  for (final e in entities) {
    // herói não é NPC/entidade (feitiços ficam; só seus nomes são corrigidos)
    if (e.kind != 'spell' && canonicalHero(e.name, heroes) != null) {
      dropped++;
      continue;
    }
    outE.add(e.kind == 'spell' ? e.copyWith(caster: fix(e.caster), target: fix(e.target)) : e);
  }
  final outF = [for (final f in facts) f.copyWith(actor: fix(f.actor), target: fix(f.target))];
  return (entities: outE, facts: outF, dropped: dropped);
}
