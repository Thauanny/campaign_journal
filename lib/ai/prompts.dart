import 'dart:convert';

import '../domain/models.dart';

/// JSON schema (resumido) devolvido pela extração — os três provedores o recebem.
const extractionSchemaHint = '''
{"entities":[{"kind":"npc|location|quest|item|faction|spell","name":"","aliases":[""],
"description":"","status":"npc: aliado|neutro|inimigo; quest: ativa|concluída|falhou; faction: relação com o grupo",
"attr":"npc: vivo|morto; location: tipo; item: raridade","giver":"","reward":"","parent":"nome do local pai","caster":"spell: quem lançou","target":"spell: em quem","side":"spell: hero|enemy","result":"spell: acertou|errou|resistiu|curou",
"at":"mm:ss","quote":"trecho curto da transcrição"}],
"events":[{"text":"","at":"mm:ss"}],
"facts":[{"kind":"damage|heal|xp|condition|loot","actor":"","target":"","side":"hero|enemy|neutral","amount":0,"text":"","at":"mm:ss","quote":""}]}''';

String knownContext(List<KnownEntity> known) {
  if (known.isEmpty) return 'A campanha ainda não tem entidades conhecidas.';
  final b = StringBuffer('Entidades já conhecidas da campanha '
      '(reutilize o MESMO nome quando for a mesma coisa, não crie duplicatas):\n');
  for (final k in known) {
    b.writeln('- [${k.kind}] ${k.name}'
        '${k.aliases.isEmpty ? '' : ' (também: ${k.aliases.join(', ')})'}'
        '${k.status.isEmpty ? '' : ' — ${k.status}'}');
  }
  return b.toString();
}

String extractionSystem(List<KnownEntity> known, String extra) => '''
Você é o arquivista de uma campanha de RPG de mesa. Analisa a transcrição de uma sessão em português do Brasil.
A transcrição mistura a fala do mestre (narração), dos jogadores (ações e conversa fora do jogo) e erros de reconhecimento de voz em nomes de fantasia.

Extraia SOMENTE o que um jogador precisaria consultar semanas depois:
- npc: personagem do mundo (não jogador) com nome próprio ou papel marcante.
- location: lugar nomeado ou relevante para a trama.
- quest: objetivo/missão que o grupo assumiu, recebeu ou concluiu.
- item: objeto relevante (mágico, único, entregue ao grupo).
- faction: organização, reino, culto, grupo.
- events: marcos da história (o que aconteceu, com consequência).
- spell: CADA vez que um feitiço, magia ou habilidade mágica for lançado/usado na cena (falado pelo jogador, "Eu lanço Bola de Fogo", ou narrado pelo mestre). Crie UMA entrada POR USO, repetindo o mesmo nome se foi usado de novo. INCLUA os feitiços dos INIMIGOS e dos NPCs, não só dos heróis. "caster" = quem lançou, "target" = em quem foi usado, "side" = "hero" se quem lançou é um herói/aliado do grupo ou "enemy" se é inimigo, "result" = acertou/errou/resistiu/curou, "description" = efeito em 1 frase, "at" e "quote" do momento do uso. Não registre magias só mencionadas em explicação de regra.

REGRAS:
- NÃO extraia: personagens dos jogadores (heróis do grupo) nem os próprios jogadores; termos de regra/mecânica (Defesa, Ação de movimento, Fortitude, PM, dados, rolagens, turnos); palavras comuns; itens triviais; conversa fora do jogo.
- Um NPC precisa ter nome próprio OU função clara ("o capitão da guarda"). Junte variações do mesmo nome (erros de transcrição) em "aliases".
- "description": 1–2 frases AUTOSSUFICIENTES dizendo quem/o que é e por que importa na história — compreensíveis por quem não leu a transcrição. Nada de "citado 2x".
- Se a transcrição não deixar claro quem é, não crie a entidade.
- Cada evento: uma frase completa no passado, com sujeito explícito ("O grupo derrotou…"), nunca fragmentos de fala.
- "at" = horário [mm:ss] copiado da linha e "quote" curta e literal.
- facts: anote CADA dano e cura (kind "damage"/"heal", "amount" = número de pontos de vida; "actor" = quem causou/curou, "target" = quem sofreu/recebeu, "side" = lado do ALVO: hero ou enemy), cada ganho de XP/experiência (kind "xp", "amount", "target" = herói ou "grupo"), condições aplicadas como envenenado ou atordoado (kind "condition", "text") e saque relevante (kind "loot", "text"). Só registre o que foi dito na cena; se o valor não foi dito, deixe "amount" nulo.
- Seja seletivo nas entidades: prefira 8 entidades certas a 40 duvidosas. Os feitiços e fatos de combate, porém, devem ser completos.
Responda SOMENTE com JSON válido neste formato:
$extractionSchemaHint

${knownContext(known)}
$extra''';

String summarySystem(List<KnownEntity> known, String campaign, {String extra = ''}) => '''
Você é o cronista da campanha "$campaign". A partir da transcrição de uma sessão de RPG em pt-BR, escreva o diário de modo que alguém que NÃO estava na mesa, ou que voltou uma semana depois, entenda tudo sem ver a transcrição.

Regras de escrita:
- Terceira pessoa, passado, ordem cronológica, frases completas. Sem horários e sem falas soltas ("Rafa: ...").
- Distinga jogadores (pessoas) de personagens (heróis). Cite sempre o personagem: "Bram Cascalho", não "Rafa". Se não souber o personagem, use o nome do jogador entre parênteses uma vez.
- Explique causa e consequência: quem fez o quê, por quê e o que mudou.
- Apresente cada NPC/local novo com uma breve identificação na primeira menção.
- Ignore conversa fora do jogo, regras, rolagens e brincadeiras, a menos que mudem a história.
- Quando houver combate, conte o essencial: quem lançou feitiços (heróis E inimigos) e em quem, o dano sofrido e as curas de cada herói e o XP ganho.
- Não invente nada fora da transcrição; se algo estiver ambíguo, diga que ficou em aberto.

Campos (JSON):
- "short": 3–5 frases com o essencial: onde estavam, o que aconteceu de mais importante, como terminou.
- "narrative": crônica em 3–6 parágrafos separados por linha em branco. Termine com um parágrafo iniciado por "Onde paramos:" (situação atual, ameaças e objetivos pendentes).
- "previously_on": 80–120 palavras no estilo "Anteriormente em…", para ler em voz alta no início da próxima mesa, terminando no gancho.
- "open_threads": lista (até 8) de ganchos em aberto: mistérios, objetivos e perguntas que ficaram SEM resposta e merecem retorno na próxima sessão. Cada um é uma frase curta e autossuficiente (ex.: "Quem enviou os recrutas atrás do grupo?").
Responda SOMENTE com JSON: {"short":"","narrative":"","previously_on":"","open_threads":[""]}

${knownContext(known)}
$extra''';

/// Extrai o primeiro objeto JSON de uma resposta (tolera cercas ```json).
Map<String, dynamic>? parseJsonObject(String raw) {
  var s = raw.trim();
  final fence = RegExp(r'```(?:json)?\s*([\s\S]*?)```').firstMatch(s);
  if (fence != null) s = fence.group(1)!.trim();
  final a = s.indexOf('{');
  final b = s.lastIndexOf('}');
  if (a < 0 || b <= a) return null;
  try {
    final v = jsonDecode(s.substring(a, b + 1));
    return v is Map<String, dynamic> ? v : null;
  } catch (_) {
    return null;
  }
}

ExtractionResult parseExtraction(Map<String, dynamic> j) {
  final ents = <ExtractedEntity>[];
  for (final e in (j['entities'] as List? ?? const [])) {
    if (e is Map<String, dynamic>) {
      final x = ExtractedEntity.fromJson(e);
      if (x != null) ents.add(x);
    }
  }
  final evs = <ExtractedEvent>[];
  for (final e in (j['events'] as List? ?? const [])) {
    if (e is Map<String, dynamic> && (e['text'] ?? '').toString().isNotEmpty) {
      evs.add(ExtractedEvent(e['text'].toString(),
          clockOf(e)));
    }
  }
  final facts = <ExtractedFact>[];
  for (final f in (j['facts'] as List? ?? const [])) {
    if (f is Map<String, dynamic>) {
      final x = ExtractedFact.fromJson(f);
      if (x != null) facts.add(x);
    }
  }
  return ExtractionResult(ents, evs, facts: facts);
}

SessionSummary? parseSummary(Map<String, dynamic> j) {
  final s = (j['short'] ?? '').toString();
  final n = (j['narrative'] ?? '').toString();
  if (s.isEmpty && n.isEmpty) return null;
  final th = [
    for (final t in (j['open_threads'] as List? ?? const []))
      if (t.toString().trim().isNotEmpty) t.toString().trim()
  ];
  return SessionSummary(s, n, (j['previously_on'] ?? '').toString(), openThreads: th);
}

/// ~4 caracteres por token em pt-BR (estimativa grosseira).
int estimateTokens(String s) => (s.length / 4).ceil();
