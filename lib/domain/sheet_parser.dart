import 'dart:convert';

import 'name_match.dart';
import 'systems.dart';

/// Campos lidos de uma ficha. Tudo passa por conferência antes de salvar.
class SheetFields {
  String name = '';
  String player = '';
  String heroClass = '';
  String race = '';
  int? level;
  String story = '';
  List<String> items = [];
  /// atributos, vida, perícias etc.
  Map<String, String> extra = {};
  /// Texto cru de campos sem lugar no modelo.
  String notes = '';
  bool supportedSystem = true;

  bool get isEmpty =>
      name.isEmpty && heroClass.isEmpty && race.isEmpty && level == null && items.isEmpty && extra.isEmpty;

  Map<String, dynamic> toJson() => {
        'name': name, 'player': player, 'class': heroClass, 'race': race,
        'level': level, 'story': story, 'items': items, 'extra': extra, 'notes': notes,
      };

  static SheetFields fromJson(Map<String, dynamic> j) {
    final f = SheetFields()
      ..name = (j['name'] ?? '').toString()
      ..player = (j['player'] ?? '').toString()
      ..heroClass = (j['class'] ?? '').toString()
      ..race = (j['race'] ?? '').toString()
      ..level = j['level'] is num ? (j['level'] as num).toInt() : int.tryParse('${j['level']}')
      ..story = (j['story'] ?? '').toString()
      ..notes = (j['notes'] ?? '').toString();
    if (j['items'] is List) f.items = (j['items'] as List).map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
    if (j['extra'] is Map) {
      f.extra = (j['extra'] as Map).map((k, v) => MapEntry(k.toString(), v.toString()));
    }
    f.extra.removeWhere((k, v) => v.trim().isEmpty || v.trim() == 'null');
    // PV e XP aparecem na conferência como campos comuns e são movidos para a ficha ao salvar.
    void vital(String jsonKey, String label) {
      final v = j[jsonKey];
      final n = v is num ? v.toInt() : int.tryParse('${v ?? ''}');
      if (n != null && n > 0) f.extra[label] = '$n';
    }
    vital('hp_max', kHpMaxKey);
    vital('hp_current', kHpNowKey);
    vital('xp', kXpKey);
    return f;
  }
}

/// Rótulos usados na conferência para PV e XP lidos da ficha.
const kHpMaxKey = 'PV máximo';
const kHpNowKey = 'PV atual';
const kXpKey = 'XP';

Map<String, String> sheetExtraToMap(String json) {
  try {
    final m = jsonDecode(json);
    return m is Map ? m.map((k, v) => MapEntry(k.toString(), v.toString())) : {};
  } catch (_) {
    return {};
  }
}

const supportedSheetSystems = {'D&D 5e', 'Tormenta20'};

/// Esquema (JSON) enviado a modelos com visão, por sistema.
String sheetSchemaHint(String system) {
  final prof = profileFor(system);
  final extraKeys = prof.extras.map((e) => '"${e.key}" (${e.label})').join(', ');
  final tip = switch (system) {
    'Tormenta20' =>
      'Em Tormenta20 o topo da ficha tem: PERSONAGEM (nome), JOGADOR, RAÇA, ORIGEM, CLASSE & NÍVEL (ex.: "Druida 2" = classe Druida, nível 2) e DIVINDADE. '
          'Depois vêm os atributos FOR, DES, CON, INT, SAB, CAR; PONTOS DE VIDA (máximos e atuais); PONTOS DE MANA (máximos e atuais); DEFESA; ATAQUES; PERÍCIAS; EQUIPAMENTO.',
    'D&D 5e' =>
      'Em D&D 5e: nome do personagem, classe e nível, antecedente, raça, tendência, atributos (FOR, DES, CON, INT, SAB, CAR), CA, pontos de vida e equipamento.',
    _ => 'Use os rótulos do sistema: ${prof.classLabel}, ${prof.raceLabel}, ${prof.levelLabel}, ${prof.hpLabel}.',
  };
  return '''
Ficha de $system. Esta é uma ficha de FORMULÁRIO: leia os VALORES preenchidos dentro dos campos e ignore os rótulos impressos (ex.: a palavra "PERSONAGEM" ou "RAÇA" não é um valor).
$tip
Responda SOMENTE JSON:
{"name":"nome do personagem","player":"nome do jogador","class":"${prof.classLabel} (sem o nível)","race":"${prof.raceLabel}","level":0,
"hp_max":0,"hp_current":0,"xp":0,"story":"",
"items":["cada item do equipamento/inventário, um por entrada, sem o peso"],
"extra":{"chave":"valor"},
"notes":"qualquer campo que não caiba nos anteriores"}
Chaves de "extra": ${extraKeys.isEmpty ? 'use nomes curtos' : extraKeys}, e os atributos "FOR","DES","CON","INT","SAB","CAR" com o valor escrito na ficha (inclusive 0). Valores de PM, PE, SAN etc. devem ser números.
Se um campo estiver vazio ou ilegível, deixe vazio. Não invente.''';
}

final _attrs = <String, List<String>>{
  'FOR': ['FOR', 'FORÇA', 'FORCA', 'STR', 'STRENGTH'],
  'DES': ['DES', 'DESTREZA', 'DEX', 'DEXTERITY'],
  'CON': ['CON', 'CONSTITUIÇÃO', 'CONSTITUICAO', 'CONSTITUTION'],
  'INT': ['INT', 'INTELIGÊNCIA', 'INTELIGENCIA', 'INTELLIGENCE'],
  'SAB': ['SAB', 'SABEDORIA', 'WIS', 'WISDOM'],
  'CAR': ['CAR', 'CARISMA', 'CHA', 'CHARISMA'],
};

String? _after(String text, List<String> labels) {
  final lines = text.split('\n').map((l) => l.trim()).toList();
  for (final label in labels) {
    final re = RegExp('^(?:$label)\\s*[:\\-]?\\s*(.*)\$', caseSensitive: false);
    for (var i = 0; i < lines.length; i++) {
      final m = re.firstMatch(lines[i]);
      if (m == null) continue;
      final same = m.group(1)!.trim();
      if (same.isNotEmpty) return same;
      // valor na linha seguinte (comum em PDFs com caixas rotuladas)
      for (var j = i + 1; j < lines.length && j <= i + 2; j++) {
        if (lines[j].isNotEmpty) return lines[j];
      }
    }
  }
  return null;
}

/// Lê o texto de PDF digital ou de OCR usando regras do sistema da campanha.
/// Para sistema não suportado, o texto cru vai inteiro para "notas".
SheetFields parseSheetText(String raw, String system) {
  final f = SheetFields();
  final text = raw.replaceAll('\r', '');
  if (!supportedSheetSystems.contains(system)) {
    f.supportedSystem = false;
    f.notes = text.trim();
    return f;
  }

  f.name = _after(text, ['Nome do Personagem', 'Character Name', 'Nome']) ?? '';
  f.player = _after(text, ['Nome do Jogador', 'Player Name', 'Jogador', 'Player']) ?? '';
  f.race = _after(text, ['Raça', 'Raca', 'Race']) ?? '';
  final cl = _after(text, ['Classe e N[ií]vel', 'Classe & N[ií]vel', 'Class & Level', 'Class and Level', 'Classe', 'Class']);
  if (cl != null) {
    final lv = RegExp(r'(\d{1,2})').firstMatch(cl);
    f.level = lv == null ? null : int.tryParse(lv.group(1)!);
    f.heroClass = cl.replaceAll(RegExp(r'\d+'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
  }
  if (f.level == null) {
    final lv = _after(text, ['N[ií]vel', 'Level']);
    f.level = lv == null ? null : int.tryParse(RegExp(r'\d+').firstMatch(lv)?.group(0) ?? '');
  }
  if (system == 'Tormenta20') {
    final o = _after(text, ['Origem']);
    if (o != null) f.extra['Origem'] = o;
    final d = _after(text, ['Divindade']);
    if (d != null) f.extra['Divindade'] = d;
  } else {
    final bg = _after(text, ['Antecedente', 'Background']);
    if (bg != null) f.extra['Antecedente'] = bg;
    final al = _after(text, ['Tendência', 'Alinhamento', 'Alignment']);
    if (al != null) f.extra['Tendência'] = al;
  }

  // Atributos: "FOR 16", "Força\n16" ou "STR: 16"
  final lines = text.split('\n').map((l) => l.trim()).toList();
  for (final e in _attrs.entries) {
    for (var i = 0; i < lines.length; i++) {
      final up = lines[i].toUpperCase();
      for (final alias in e.value) {
        final m = RegExp('^$alias\\s*[:\\-]?\\s*(\\d{1,2})\\b').firstMatch(up);
        if (m != null) { f.extra.putIfAbsent(e.key, () => m.group(1)!); }
        else if (up == alias && i + 1 < lines.length && RegExp(r'^\d{1,2}$').hasMatch(lines[i + 1])) {
          f.extra.putIfAbsent(e.key, () => lines[i + 1]);
        }
      }
    }
  }
  final hp = _after(text, ['Pontos de Vida(?: M[aá]ximos)?', 'Hit Point Maximum', 'Hit Points', 'PV', 'HP']);
  if (hp != null && RegExp(r'\d').hasMatch(hp)) f.extra['PV'] = hp;
  final ca = _after(text, ['Classe de Armadura', 'Armor Class', 'CA', 'AC', 'Defesa']);
  if (ca != null && RegExp(r'^\d').hasMatch(ca)) f.extra['CA'] = ca;

  // Inventário: bloco após "Equipamento"/"Inventário" até linha vazia dupla ou novo rótulo
  final inv = RegExp(r'(?:Equipamento|Invent[aá]rio|Equipment|Itens)\s*:?\s*\n([\s\S]{1,800}?)(?:\n\s*\n|\Z)', caseSensitive: false).firstMatch(text);
  if (inv != null) {
    f.items = inv.group(1)!
        .split(RegExp(r'\n|;|•|·'))
        .map((s) => s.replaceFirst(RegExp(r'^[\-\*\s]+'), '').trim())
        .where((s) => s.length > 1 && s.length < 80)
        .toList();
  }
  final story = RegExp(r'(?:Hist[oó]ria do Personagem|Backstory|Hist[oó]ria)\s*:?\s*\n([\s\S]{1,1500}?)(?:\n\s*\n|\Z)', caseSensitive: false).firstMatch(text);
  if (story != null) f.story = story.group(1)!.trim();
  return f;
}

class FieldDiff {
  final String field;
  final String label;
  final String oldValue;
  final String newValue;
  const FieldDiff(this.field, this.label, this.oldValue, this.newValue);
}

/// Reenviar a ficha (subiu de nível): diferença campo a campo.
List<FieldDiff> diffSheet({
  required String name, required String player, required String heroClass,
  required String race, required int level, required String story,
  required Map<String, String> extra, required List<String> items,
  required SheetFields incoming,
}) {
  final out = <FieldDiff>[];
  void s(String k, String label, String a, String b) {
    if (b.trim().isNotEmpty && a.trim() != b.trim()) out.add(FieldDiff(k, label, a, b.trim()));
  }
  s('name', 'Nome', name, incoming.name);
  s('player', 'Jogador', player, incoming.player);
  s('class', 'Classe', heroClass, incoming.heroClass);
  s('race', 'Raça', race, incoming.race);
  if (incoming.level != null && incoming.level != level) {
    out.add(FieldDiff('level', 'Nível', '$level', '${incoming.level}'));
  }
  s('story', 'História', story, incoming.story);
  for (final e in incoming.extra.entries) {
    if (extra[e.key] != e.value) out.add(FieldDiff('extra:${e.key}', e.key, extra[e.key] ?? '', e.value));
  }
  final have = items.map(stripAccents).toSet();
  for (final it in incoming.items) {
    if (!have.contains(stripAccents(it))) out.add(FieldDiff('item:$it', 'Novo item', '', it));
  }
  return out;
}
