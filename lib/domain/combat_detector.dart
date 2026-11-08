import 'models.dart';
import 'spell_detector.dart';

/// Detecta dano, cura e XP na transcrição sem usar IA. É um complemento:
/// a IA entende melhor o contexto, este detector garante o básico.

final _line = RegExp(r'^\[(\d+):(\d{2})(?::(\d{2}))?\]\s*(.*)$');
final _speaker = RegExp(r"^([A-ZÁÉÍÓÚÂÊÔÃÕÇ][\wáéíóúâêôãõç]{1,20}):\s+");
const _cap = 'A-ZÁÉÍÓÚÂÊÔÃÕÇ';
const _low = 'a-záéíóúâêôãõç';

final _damage = [
  RegExp(r'(\d{1,3})\s+(?:pontos?\s+)?(?:de\s+)?dano', caseSensitive: false),
  RegExp(r'(?:perde|perdeu|perdem|perdi)\s+(\d{1,3})\s*(?:PV|pontos?\s+de\s+vida|de\s+vida|de\s+PV)?', caseSensitive: false),
  RegExp(r'(?:sofre|sofreu|toma|tomou|recebe|recebeu|leva|levou)\s+(\d{1,3})\b', caseSensitive: false),
];
final _heal = RegExp(r'(?:recupera|recuperou|recuperam|cura|curou|regenera|regenerou|ganha|ganhou)\s+(\d{1,3})\s*(?:PV|pontos?\s+de\s+vida|de\s+vida|de\s+PV)', caseSensitive: false);
final _xp = RegExp(r'(\d{1,5})\s*(?:XP|pontos?\s+de\s+experi[eê]ncia|de\s+experi[eê]ncia|de\s+xp)', caseSensitive: false);
final _name = RegExp("[$_cap][\\w$_low']+(?:\\s+(?:de|da|do)\\s+[$_cap][\\w$_low']+|\\s+[$_cap][\\w$_low']+)*");

String _norm(String s) => s.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();

int _toMs(RegExpMatch m) {
  final a = int.parse(m.group(1)!), b = int.parse(m.group(2)!);
  final c = m.group(3);
  return (c == null ? a * 60 + b : a * 3600 + b * 60 + int.parse(c)) * 1000;
}

const _stop = {'Defesa', 'Rola', 'Dano', 'Ação', 'Vida', 'Eu', 'Ele', 'Ela', 'Mestre', 'Participantes', 'XP'};

List<ExtractedFact> detectCombat(String transcript, {List<String> heroNames = const []}) {
  final keys = heroKeys(heroNames);
  final out = <ExtractedFact>[];
  for (final raw in transcript.split('\n')) {
    final m = _line.firstMatch(raw.trim());
    if (m == null) continue;
    final ms = _toMs(m);
    var text = m.group(4)!;
    final sp = _speaker.firstMatch(text);
    final speaker = sp?.group(1);
    if (sp != null) text = text.substring(sp.end);
    if (text.toLowerCase().startsWith('participantes')) continue;
    final quote = text.trim().length > 160 ? text.trim().substring(0, 160) : text.trim();

    // nomes citados na linha, na ordem
    final names = [for (final n in _name.allMatches(text)) n.group(0)!.trim()].where((n) => !_stop.contains(n) && n.length >= 3).toList();
    final heroesIn = names.where((n) => isHeroName(n, keys)).toList();
    final others = names.where((n) => !isHeroName(n, keys)).toList();

    // XP
    final x = _xp.firstMatch(text);
    if (x != null) {
      final amount = int.parse(x.group(1)!);
      final who = heroesIn.isNotEmpty ? heroesIn.first : 'grupo';
      out.add(ExtractedFact(kind: 'xp', target: who, side: 'hero', amount: amount, text: '+$amount XP', atMs: ms, quote: quote));
      continue;
    }
    // cura
    final h = _heal.firstMatch(text);
    if (h != null) {
      final amount = int.parse(h.group(1)!);
      final target = heroesIn.isNotEmpty ? heroesIn.first : (others.isNotEmpty ? others.first : (speaker != null && speaker.toLowerCase() != 'mestre' ? speaker : ''));
      out.add(ExtractedFact(kind: 'heal', target: target, side: target.isEmpty ? '' : (isHeroName(target, keys) ? 'hero' : 'enemy'), amount: amount, text: 'Cura de $amount PV', atMs: ms, quote: quote));
      continue;
    }
    // dano
    for (final re in _damage) {
      final d = re.firstMatch(text);
      if (d == null) continue;
      final amount = int.parse(d.group(1)!);
      // quem sofreu: herói citado; senão outro nome; "causa/acerta" indica o autor
      String target = '', actor = '';
      final mention = RegExp(r'\b(?:em|no|na|nos|nas|contra|de)\s+(' + _name.pattern + r')').firstMatch(text);
      if (heroesIn.isNotEmpty) {
        target = heroesIn.first;
        actor = others.isNotEmpty ? others.first : '';
      } else if (mention != null) {
        target = mention.group(1)!.trim();
        actor = names.firstWhere((n) => n != target, orElse: () => '');
      } else if (others.isNotEmpty) {
        target = others.first;
      }
      final side = target.isEmpty ? '' : (isHeroName(target, keys) ? 'hero' : 'enemy');
      out.add(ExtractedFact(kind: 'damage', actor: actor, target: target, side: side, amount: amount, text: '$amount de dano', atMs: ms, quote: quote));
      break;
    }
  }
  return out;
}

/// Junta o que o detector achou ao que a IA já apontou, sem repetir o mesmo fato
/// (mesmo tipo, mesmo valor e a menos de 10 s de distância).
List<ExtractedFact> mergeFacts(List<ExtractedFact> fromAi, List<ExtractedFact> detected) {
  final extra = <ExtractedFact>[];
  for (final d in detected) {
    final dup = fromAi.any((a) =>
        a.kind == d.kind && a.amount == d.amount && (a.atMs == null || d.atMs == null || (a.atMs! - d.atMs!).abs() <= 10000));
    if (!dup) extra.add(d);
  }
  return extra;
}

String normFact(String s) => _norm(s);
