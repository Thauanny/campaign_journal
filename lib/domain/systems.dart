/// Campo extra de ficha (varia por sistema de RPG).
class ExtraField {
  final String key;
  final String label;
  const ExtraField(this.key, this.label);
}

/// Como cada sistema de RPG chama as coisas na ficha. Serve ao formulário do
/// herói e ao contexto que a IA recebe.
class SystemProfile {
  final String name;
  final String classLabel;
  final String raceLabel;
  final String levelLabel;
  final String hpLabel;
  final List<ExtraField> extras;
  final String tip;
  const SystemProfile(this.name, this.classLabel, this.raceLabel, this.levelLabel, this.hpLabel, this.extras, this.tip);

  /// Como o sistema chama os poderes sobrenaturais (para a IA registrar como "spell").
  String get powerTerm => _info[name]?.power ?? 'poder ou habilidade especial';

  /// Resumo das regras e do vocabulário, enviado à IA para ela interpretar a mesa.
  String get glossary => _info[name]?.glossary ?? '';

  /// Termos próprios (classes, raças, recursos) que ajudam a reconhecer o áudio.
  List<String> get vocab => _info[name]?.vocab ?? const [];
}

class _SysInfo {
  final String power;
  final String glossary;
  final List<String> vocab;
  const _SysInfo(this.power, this.glossary, this.vocab);
}

const _info = <String, _SysInfo>{
  'D&D 5e': _SysInfo(
    'magia (feitiço), truque ou habilidade de classe',
    '- Poderes: magias (truques e magias de círculo 1 a 9, que gastam espaços de magia) e habilidades de classe.\n'
    '- Vida: PV. Armadura: CA. Testes: ataque, salvaguarda (resistência) e perícia.\n'
    '- Progressão: nível 1–20, por XP ou marcos.\n'
    '- Condições: agarrado, amedrontado, atordoado, caído, cego, enfeitiçado, envenenado, incapacitado, inconsciente, invisível, paralisado, petrificado, surdo, contido.',
    ['Bárbaro', 'Bardo', 'Bruxo', 'Clérigo', 'Druida', 'Feiticeiro', 'Guerreiro', 'Ladino', 'Mago', 'Monge', 'Paladino', 'Patrulheiro', 'Anão', 'Elfo', 'Halfling', 'Meio-elfo', 'Meio-orc', 'Tiefling', 'Draconato', 'Gnomo']),
  'Tormenta20': _SysInfo(
    'magia (arcana ou divina) ou poder de classe',
    '- Poderes: magias arcanas e divinas (cada uma gasta PM) e poderes de classe ou de raça.\n'
    '- Vida: PV. Mana: PM. Armadura: Defesa. Testes de perícia (Luta, Pontaria, Fortitude, Reflexos, Vontade, Atletismo, Misticismo…).\n'
    '- Progressão: nível 1–20 e XP.\n'
    '- Condições: abalado, agarrado, alquebrado, apavorado, atordoado, caído, cego, confuso, debilitado, desprevenido, doente, em chamas, enjoado, envenenado, exausto, fascinado, fatigado, fraco, frustrado, imóvel, inconsciente, indefeso, lento, paralisado, pasmo, petrificado, sangrando, surdo, vulnerável.',
    ['Arcanista', 'Bárbaro', 'Bardo', 'Bucaneiro', 'Caçador', 'Cavaleiro', 'Clérigo', 'Druida', 'Guerreiro', 'Inventor', 'Ladino', 'Lutador', 'Nobre', 'Paladino', 'Humano', 'Anão', 'Dahllan', 'Elfo', 'Goblin', 'Lefou', 'Minotauro', 'Qareen', 'Golem', 'Hynne', 'Kliren', 'Medusa', 'Osteon', 'Sereia', 'Tritão', 'Sílfide', 'Aggelus', 'Suraggel', 'Trog', 'Allihanna', 'Khalmyr', 'Wynna', 'Tenebra']),
  'Pathfinder 2e': _SysInfo(
    'magia (truque ou magia de nível 1 a 10), talento ou ação especial',
    '- Turno de 3 ações (mais reação). Poderes: magias, talentos de classe e ancestralidade.\n'
    '- Vida: PV. Armadura: CA. Testes de resistência: Fortitude, Reflexos e Vontade. Perícias com graus de proficiência.\n'
    '- Progressão: nível 1–20 e XP.\n'
    '- Condições: apavorado, assustado, atordoado, cego, confuso, debilitado, enfraquecido, imobilizado, lento, nauseado, paralisado, desajeitado, drenado, fascinado.',
    ['Alquimista', 'Bárbaro', 'Bardo', 'Campeão', 'Clérigo', 'Druida', 'Feiticeiro', 'Guerreiro', 'Ladino', 'Mago', 'Monge', 'Patrulheiro', 'Anão', 'Elfo', 'Gnomo', 'Goblin', 'Halfling', 'Humano']),
  'Call of Cthulhu': _SysInfo(
    'feitiço dos Mitos ou poder sobrenatural',
    '- Testes percentuais (d100): sucesso normal, difícil e extremo; falha crítica.\n'
    '- Vida: PV (ferimento grave, morrendo). Sanidade: SAN (testes de Sanidade, perda de SAN, loucura temporária ou indefinida). Sorte. Pontos de magia: PM.\n'
    '- Sem níveis: investigadores evoluem pelas perícias.',
    ['Sanidade', 'Mitos', 'Cthulhu', 'Investigador', 'Guardião']),
  'Ordem Paranormal': _SysInfo(
    'ritual, poder de classe ou habilidade paranormal',
    '- Poderes: rituais (gastam PE), poderes de classe e de trilha, habilidades de origem.\n'
    '- Vida: PV. Esforço: PE. Sanidade: SAN. Armadura: Defesa. Progressão: NEX (%) e patente.\n'
    '- Testes de atributo + perícia. Elementos: Sangue, Morte, Conhecimento, Energia e Medo.\n'
    '- Condições: abalado, agarrado, apavorado, atordoado, caído, cego, confuso, debilitado, enjoado, exausto, fatigado, lento, paralisado, sangrando, surdo, vulnerável.',
    ['Combatente', 'Especialista', 'Ocultista', 'Sobrevivente', 'Mundano', 'Ordem', 'Paranormal', 'Outro Lado', 'NEX']),
  'Vampiro: A Máscara': _SysInfo(
    'disciplina ou poder de clã',
    '- Poderes: disciplinas (Dominação, Presença, Potência, Rapidez, Ofuscação, Auspícios, Fortitude, Animalismo, Feitiçaria de Sangue…).\n'
    '- Fome (0–5), Humanidade, Vitalidade (saúde), Força de Vontade. Testes com reservas de d10; frenesi e fome.',
    ['Brujah', 'Gangrel', 'Malkaviano', 'Nosferatu', 'Toreador', 'Tremere', 'Ventrue', 'Lasombra', 'Ministério', 'Banu Haqim', 'Hecata', 'Ravnos', 'Salubri', 'Fome', 'Humanidade', 'Disciplinas']),
};

const _profiles = <String, SystemProfile>{
  'D&D 5e': SystemProfile('D&D 5e', 'Classe', 'Raça / espécie', 'Nível', 'PV',
      [ExtraField('ca', 'Classe de Armadura (CA)'), ExtraField('antecedente', 'Antecedente'), ExtraField('tendencia', 'Tendência')],
      'Classe, raça, nível, PV e CA são os dados que mais ajudam a IA.'),
  'Tormenta20': SystemProfile('Tormenta20', 'Classe', 'Raça', 'Nível', 'PV',
      [ExtraField('pm', 'PM (pontos de mana)'), ExtraField('defesa', 'Defesa'), ExtraField('origem', 'Origem'), ExtraField('divindade', 'Divindade')],
      'Informe classe, raça, nível, PV e PM; a IA usa isso para reconhecer o personagem.'),
  'Pathfinder 2e': SystemProfile('Pathfinder 2e', 'Classe', 'Ancestralidade', 'Nível', 'PV',
      [ExtraField('ca', 'Classe de Armadura (CA)'), ExtraField('heranca', 'Herança'), ExtraField('antecedente', 'Antecedente')],
      'Classe, ancestralidade e nível identificam o personagem.'),
  'Call of Cthulhu': SystemProfile('Call of Cthulhu', 'Ocupação', 'Origem', 'Nível (se houver)', 'PV',
      [ExtraField('san', 'Sanidade (SAN)'), ExtraField('sorte', 'Sorte'), ExtraField('pm', 'Pontos de magia')],
      'Aqui o que identifica o investigador é a ocupação; SAN e PV mudam durante a sessão.'),
  'Ordem Paranormal': SystemProfile('Ordem Paranormal', 'Classe', 'Origem', 'NEX (%)', 'PV',
      [ExtraField('pe', 'PE (pontos de esforço)'), ExtraField('san', 'SAN (sanidade)'), ExtraField('trilha', 'Trilha'), ExtraField('patente', 'Patente')],
      'Classe, origem, NEX, PV, PE e SAN são os dados principais.'),
  'Vampiro: A Máscara': SystemProfile('Vampiro: A Máscara', 'Clã', 'Predador / natureza', 'Geração', 'Vitalidade',
      [ExtraField('fome', 'Fome'), ExtraField('humanidade', 'Humanidade'), ExtraField('vontade', 'Força de Vontade')],
      'Clã e predador definem quem é o personagem; fome e humanidade mudam na sessão.'),
};

const _generic = SystemProfile('Outro', 'Classe / função', 'Raça / origem', 'Nível', 'PV', [], 'Preencha o que o seu sistema tiver: nome, função e origem já ajudam a IA.');

SystemProfile profileFor(String system) => _profiles[system] ?? _generic;

/// Todas as chaves de campos extras de qualquer sistema (para guardar na ficha).
final Set<String> allExtraKeys = {for (final p in _profiles.values) for (final e in p.extras) e.key};


/// Contexto do sistema de RPG enviado à IA em toda análise (mesmo sem heróis).
String systemContext(String system) {
  final p = profileFor(system);
  final b = StringBuffer('SISTEMA DE RPG DA CAMPANHA: $system.\n');
  b.writeln('Aqui, poderes sobrenaturais são: ${p.powerTerm}. Registre cada USO deles como kind "spell".');
  b.writeln('Na ficha: ${p.classLabel}, ${p.raceLabel}, ${p.levelLabel}, ${p.hpLabel}.');
  if (p.glossary.isNotEmpty) b.writeln(p.glossary);
  return b.toString().trimRight();
}
