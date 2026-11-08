import 'models.dart';

/// Balanço do combate: texto curto e parágrafo, montados a partir dos
/// feitiços e fatos da sessão. Entra nos resumos e dá o contexto à IA.
class Balance {
  final String shortText;
  final String longText;
  const Balance(this.shortText, this.longText);
  bool get isEmpty => shortText.isEmpty && longText.isEmpty;
}

class SpellUse {
  final String name, caster, target, side, result;
  const SpellUse(this.name, this.caster, this.target, this.side, this.result);
}

String _plural(int n, String one, String many) => '$n ${n == 1 ? one : many}';

Balance buildBalance(List<SpellUse> spells, List<ExtractedFact> facts) {
  final hero = spells.where((s) => s.side == 'hero').toList();
  final enemy = spells.where((s) => s.side == 'enemy').toList();
  final other = spells.where((s) => s.side != 'hero' && s.side != 'enemy').toList();

  // dano e cura por alvo
  final dmg = <String, int>{}, heal = <String, int>{};
  var dmgHeroes = 0, dmgEnemies = 0, xp = 0;
  final xpBy = <String, int>{};
  for (final f in facts) {
    final a = f.amount ?? 0;
    final who = f.target.isEmpty ? 'alguém' : f.target;
    if (f.kind == 'damage' && a > 0) {
      dmg[who] = (dmg[who] ?? 0) + a;
      if (f.side == 'hero') dmgHeroes += a;
      if (f.side == 'enemy') dmgEnemies += a;
    } else if (f.kind == 'heal' && a > 0) {
      heal[who] = (heal[who] ?? 0) + a;
    } else if (f.kind == 'xp' && a > 0) {
      xp += a;
      xpBy[who] = (xpBy[who] ?? 0) + a;
    }
  }
  final conditions = [for (final f in facts) if (f.kind == 'condition') f.text.isEmpty ? f.target : '${f.target.isEmpty ? '' : '${f.target}: '}${f.text}'];

  String spellList(List<SpellUse> l) {
    final by = <String, List<SpellUse>>{};
    for (final s in l) {
      (by[s.name] ??= []).add(s);
    }
    return by.entries.map((e) {
      final casters = e.value.map((s) => s.caster).where((c) => c.isNotEmpty).toSet();
      final targets = e.value.map((s) => s.target).where((c) => c.isNotEmpty).toSet();
      return '${e.key}${e.value.length > 1 ? ' ×${e.value.length}' : ''}'
          '${casters.isEmpty ? '' : ' (${casters.join(', ')}${targets.isEmpty ? '' : ' → ${targets.join(', ')}'})'}';
    }).join('; ');
  }

  final shortParts = <String>[];
  if (spells.isNotEmpty) {
    shortParts.add('${_plural(spells.length, 'feitiço', 'feitiços')} (${hero.length} dos heróis, ${enemy.length} dos inimigos)');
  }
  if (dmgHeroes > 0) shortParts.add('$dmgHeroes de dano sofrido pelos heróis');
  if (dmgEnemies > 0) shortParts.add('$dmgEnemies de dano causado aos inimigos');
  if (xp > 0) shortParts.add('+$xp XP');
  final shortText = shortParts.isEmpty ? '' : 'Combate: ${shortParts.join('; ')}.';

  final lines = <String>[];
  if (hero.isNotEmpty) lines.add('Feitiços dos heróis: ${spellList(hero)}.');
  if (enemy.isNotEmpty) lines.add('Feitiços dos inimigos: ${spellList(enemy)}.');
  if (other.isNotEmpty) lines.add('Outros feitiços: ${spellList(other)}.');
  if (dmg.isNotEmpty) lines.add('Dano: ${dmg.entries.map((e) => '${e.key} −${e.value}').join(', ')}.');
  if (heal.isNotEmpty) lines.add('Curas: ${heal.entries.map((e) => '${e.key} +${e.value}').join(', ')}.');
  if (xpBy.isNotEmpty) lines.add('XP: ${xpBy.entries.map((e) => '${e.key} +${e.value}').join(', ')}.');
  if (conditions.isNotEmpty) lines.add('Condições: ${conditions.join('; ')}.');
  final longText = lines.isEmpty ? '' : 'Balanço do combate — ${lines.join(' ')}';
  return Balance(shortText, longText);
}

/// Acrescenta o balanço aos resumos (antes do aviso de "resumo automático").
SessionSummary withBalance(SessionSummary s, Balance b) {
  if (b.isEmpty) return s;
  final short = b.shortText.isEmpty ? s.short : '${s.short} ${b.shortText}'.trim();
  var long = s.narrative;
  if (b.longText.isNotEmpty) {
    const mark = '(Resumo automático';
    final i = long.indexOf(mark);
    long = i >= 0 ? '${long.substring(0, i).trimRight()}\n\n${b.longText}\n\n${long.substring(i)}' : (long.isEmpty ? b.longText : '$long\n\n${b.longText}');
  }
  return SessionSummary(short, long, s.previouslyOn, openThreads: s.openThreads);
}
