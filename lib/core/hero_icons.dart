import 'package:flutter/widgets.dart';

import 'px_icons.dart';

String _n(String s) => s.toLowerCase().replaceAll(RegExp(r'[áàâã]'), 'a').replaceAll(RegExp(r'[éê]'), 'e').replaceAll('í', 'i').replaceAll(RegExp(r'[óôõ]'), 'o').replaceAll('ú', 'u').replaceAll('ç', 'c');

/// Ícone de um item do inventário, pelo nome.
IconData itemIcon(String name) {
  final s = _n(name);
  bool has(List<String> k) => k.any(s.contains);
  if (has(['pocao', 'elixir', 'cura', 'erva', 'antidoto'])) return PxIcons.heart;
  if (has(['escudo', 'armadura', 'cota', 'couraca', 'elmo', 'capacete', 'bracadeira', 'manto', 'capa', 'bota'])) return PxIcons.shield;
  if (has(['espada', 'adaga', 'machado', 'arco', 'flecha', 'lanca', 'cajado', 'varinha', 'clava', 'martelo', 'funda', 'besta', 'foice', 'cetro', 'arma'])) return PxIcons.zap;
  if (has(['livro', 'grimorio', 'diario', 'tomo'])) return PxIcons.book;
  if (has(['pergaminho', 'carta', 'bilhete', 'nota', 'contrato'])) return PxIcons.scriptText;
  if (has(['mapa', 'bussola'])) return PxIcons.map;
  if (has(['moeda', 'ouro', 'prata', 'gema', 'joia', 'tesouro', 'bolsa', 'tibar', 'po '])) return PxIcons.coin;
  if (has(['chave', 'cadeado', 'tranca'])) return PxIcons.lock;
  if (has(['tocha', 'lanterna', 'vela', 'lampiao', 'cristal', 'amuleto', 'anel', 'talisma'])) return PxIcons.lightbulbOn;
  if (has(['dado', 'baralho', 'jogo'])) return PxIcons.dice;
  if (has(['mochila', 'corda', 'saco', 'bau', 'ração', 'racao', 'kit'])) return PxIcons.archive;
  return PxIcons.archive;
}

/// Ícone de um campo da ficha (atributos e estatísticas), pela chave.
IconData statIcon(String key) {
  final s = _n(key).trim();
  switch (s) {
    case 'for': case 'forca': case 'str': return PxIcons.zap;
    case 'des': case 'destreza': case 'dex': return PxIcons.forward;
    case 'con': case 'constituicao': case 'vigor': return PxIcons.heart;
    case 'int': case 'inteligencia': case 'intelecto': return PxIcons.lightbulbOn;
    case 'sab': case 'sabedoria': case 'wis': case 'percepcao': return PxIcons.eye;
    case 'car': case 'carisma': case 'cha': case 'presenca': return PxIcons.users;
    case 'pm': case 'pe': case 'mana': return PxIcons.zap;
    case 'ca': case 'defesa': case 'armadura': return PxIcons.shield;
    case 'san': case 'sanidade': case 'humanidade': case 'vontade': return PxIcons.eye;
    case 'sorte': return PxIcons.dice;
    case 'xp': return PxIcons.trophy;
    case 'fome': return PxIcons.heart;
    case 'origem': case 'antecedente': case 'heranca': case 'trilha': case 'patente': case 'divindade': case 'tendencia': return PxIcons.flag;
  }
  if (s.startsWith('pv')) return PxIcons.heart;
  return PxIcons.sliders;
}

const attributeKeys = {'for', 'des', 'con', 'int', 'sab', 'car', 'forca', 'destreza', 'constituicao', 'inteligencia', 'sabedoria', 'carisma', 'vigor', 'presenca', 'str', 'dex', 'wis', 'cha'};
bool isAttribute(String key) => attributeKeys.contains(_n(key).trim());
