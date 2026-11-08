import '../domain/models.dart';
import 'interfaces.dart';

/// Fallback 100% offline e gratuito: sem LLM. Faz resumo extrativo cronológico
/// e detecta nomes próprios por heurística. Tudo que sai daqui entra como
/// "sugerido" para o mestre revisar. Para resumos narrativos de verdade, use
/// uma IA (API ou Ollama).
class LocalHeuristicText implements TextModel {
  @override
  String get id => 'heuristic';
  @override
  String get label => 'Heurística local (sem IA)';
  @override
  bool get needsNetwork => false;

  static final _line = RegExp(r'^\[(\d+):(\d{2})(?::(\d{2}))?\]\s*(.*)$');
  static final _speaker = RegExp(r"^([A-ZÁÉÍÓÚÂÊÔÃÕÇ][\wáéíóúâêôãõç]{1,20}):\s+");
  static final _word = RegExp(
      r"[A-ZÁÉÍÓÚÂÊÔÃÕÇ][\wáéíóúâêôãõç'’]+(?:\s+(?:de|da|do|dos|das|e)\s+[A-ZÁÉÍÓÚÂÊÔÃÕÇ][\wáéíóúâêôãõç'’]+|\s+[A-ZÁÉÍÓÚÂÊÔÃÕÇ][\wáéíóúâêôãõç'’]+)*");

  /// Palavras que começam com maiúscula mas não são entidades da história:
  /// gramática, interjeições e vocabulário de mecânica de jogo.
  static const _stop = {
    // gramática / fala
    'O', 'A', 'Os', 'As', 'Um', 'Uma', 'E', 'Eu', 'Ele', 'Ela', 'Mas', 'Se',
    'Então', 'Aí', 'Tá', 'Não', 'Sim', 'Que', 'Como', 'Quando', 'Vou', 'Vamos',
    'Eles', 'Elas', 'Você', 'Vocês', 'Nós', 'Isso', 'Essa', 'Esse', 'Tem',
    'Mestre', 'Ok', 'Bom', 'Beleza', 'Pra', 'Por', 'De', 'Do', 'Da', 'Em',
    'No', 'Na', 'Com', 'Para', 'Já', 'Ah', 'Ué', 'Hmm', 'Opa', 'Olha', 'Eca',
    'Aqui', 'Ali', 'Agora', 'Depois', 'Antes', 'Tipo', 'Tudo', 'Todos', 'Nada',
    'Mais', 'Muito', 'Pode', 'Posso', 'Vai', 'Foi', 'Era', 'Cara', 'Gente',
    'Meu', 'Minha', 'Seu', 'Sua', 'Dois', 'Três', 'Quatro', 'Cinco', 'Seis',
    'Sete', 'Oito', 'Nove', 'Dez', 'Primeiro', 'Segundo', 'Terceiro',
    // mecânica de jogo
    'Defesa', 'Rola', 'Rolo', 'Rolar', 'Missão', 'Ação', 'Ações', 'Dado',
    'Dados', 'Turno', 'Rodada', 'Iniciativa', 'Ataque', 'Dano', 'Cura',
    'Perícia', 'Teste', 'Fortitude', 'Reflexos', 'Vontade', 'Força', 'Destreza',
    'Constituição', 'Inteligência', 'Sabedoria', 'Carisma', 'Armadura', 'Magia',
    'Movimento', 'Padrão', 'Reação', 'Bônus', 'Vantagem', 'Desvantagem',
    'PM', 'PV', 'PF', 'CD', 'CA', 'XP', 'Nível', 'Level', 'Crítico', 'Falha',
    'Sucesso', 'Sessão', 'Capítulo', 'Participantes', 'Anteriormente',
  };

  static const _locationCue = {
    'cidade', 'vila', 'floresta', 'taverna', 'reino', 'templo', 'castelo',
    'caverna', 'montanha', 'porto', 'rio', 'ilha', 'torre', 'masmorra',
    'estrada', 'aldeia', 'forte', 'mina', 'santuário', 'pântano', 'deserto',
  };
  static const _npcCue = {
    'lorde', 'lady', 'rei', 'rainha', 'dona', 'senhor', 'senhora', 'capitão',
    'mestre', 'guarda', 'sacerdote', 'druida', 'mago', 'bruxa', 'príncipe',
    'princesa', 'barão', 'duque', 'general', 'chamado', 'chamada',
  };
  static const _itemCue = {
    'espada', 'machado', 'adaga', 'poção', 'cajado', 'anel', 'amuleto', 'arco',
    'escudo', 'grimório', 'pergaminho', 'chave', 'elmo', 'manto', 'orbe',
  };
  static const _factionCue = {
    'ordem', 'guilda', 'clã', 'culto', 'exército', 'legião', 'irmandade',
    'companhia', 'cavaleiros',
  };

  List<(int, String)> _lines(String t) {
    final out = <(int, String)>[];
    for (final l in t.split('\n')) {
      final m = _line.firstMatch(l.trim());
      if (m == null) {
        if (l.trim().isNotEmpty) out.add((0, l.trim()));
        continue;
      }
      final a = int.parse(m.group(1)!), b = int.parse(m.group(2)!);
      final c = m.group(3);
      final sec = c == null ? a * 60 + b : a * 3600 + b * 60 + int.parse(c);
      out.add((sec * 1000, m.group(4)!));
    }
    return out;
  }

  /// Nomes de jogadores/personagens citados no cabeçalho ("Participantes: Caio
  /// (Mestre), Bia (Orquídea) …") e falantes de linhas "Nome: fala".
  /// Personagens dos jogadores não são NPCs.
  ({Set<String> people, Set<String> characters, Map<String, String> roles})
      _participants(List<(int, String)> lines) {
    final people = <String>{}, characters = <String>{};
    final roles = <String, String>{};
    final pRe = RegExp(r"([A-ZÁÉÍÓÚÂÊÔÃÕÇ][\wáéíóúâêôãõç]+)\s*\(([^)]+)\)");
    for (final (_, t) in lines) {
      for (final m in pRe.allMatches(t)) {
        final who = m.group(1)!, role = m.group(2)!.trim();
        // só aceita se a linha parecer lista de participantes
        if (t.toLowerCase().contains('particip')) {
          people.add(who);
          roles[who] = role;
          if (role.toLowerCase() != 'mestre') characters.addAll(role.split(RegExp(r'\s+')).where((w) => w.length > 2 && w[0] == w[0].toUpperCase()));
          if (role.toLowerCase() != 'mestre') characters.add(role);
        }
      }
      final s = _speaker.firstMatch(t);
      if (s != null) people.add(s.group(1)!);
    }
    return (people: people, characters: characters, roles: roles);
  }

  String _strip(String t) => t.replaceFirst(_speaker, '');

  @override
  Future<(ExtractionResult, UsageInfo)> extract(String transcript,
      {required List<KnownEntity> known, String system = ''}) async {
    final lines = _lines(transcript);
    final p = _participants(lines);
    final skip = <String>{
      ...p.people,
      ...p.characters,
      for (final k in known) ...[k.name, ...k.aliases],
    }.map((s) => s.toLowerCase()).toSet();

    final lowerText = transcript.toLowerCase();
    final counts = <String, int>{};
    final first = <String, (int, String)>{};
    final ctxWords = <String, List<String>>{};

    for (final (ms, raw) in lines) {
      final text = _strip(raw);
      for (final m in _word.allMatches(text)) {
        final name = m.group(0)!.trim();
        // Início de frase: maiúscula por gramática, não por ser nome próprio.
        final before = text.substring(0, m.start).trimRight();
        final sentenceStart = before.isEmpty ||
            RegExp(r'[.!?…:—–"“\-]$').hasMatch(before);
        final multi = name.contains(' ');
        if (sentenceStart && !multi) continue;
        // Em início de frase, só nomes compostos já são pistas razoáveis.
        final head = name.split(' ').first;
        if (_stop.contains(name) || _stop.contains(head) || name.length < 3) continue;
        if (skip.contains(name.toLowerCase())) continue;
        counts[name] = (counts[name] ?? 0) + 1;
        first.putIfAbsent(name, () => (ms, raw));
        final w = before.split(RegExp(r'\s+'));
        ctxWords.putIfAbsent(name, () => []).addAll(
            w.skip(w.length > 2 ? w.length - 2 : 0).map((e) => e.toLowerCase().replaceAll(RegExp(r'[^\wà-ÿ]'), '')));
      }
    }

    final ents = <ExtractedEntity>[];
    final sorted = counts.entries.where((e) {
      if (e.value < 2) return false;
      // Se a mesma palavra aparece em minúscula tantas vezes quanto em
      // maiúscula, é palavra comum ("defesa", "bálsamo"), não nome próprio.
      final lower = RegExp('\\b${RegExp.escape(e.key.toLowerCase())}\\b')
          .allMatches(lowerText)
          .length;
      return lower - e.value < e.value; // maiúsculas dominam
    }).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final e in sorted.take(15)) {
      final f = first[e.key]!;
      final ctx = ctxWords[e.key] ?? const [];
      final lowName = e.key.toLowerCase();
      var kind = 'npc';
      if (ctx.any(_locationCue.contains) ||
          ctx.any(const {'em', 'na', 'no', 'para', 'até', 'rumo'}.contains) &&
              !ctx.any(_npcCue.contains)) {
        kind = ctx.any(_locationCue.contains) ? 'location' : 'npc';
      }
      if (ctx.any(_itemCue.contains)) kind = 'item';
      if (ctx.any(_factionCue.contains) || lowName.startsWith('ordem ')) kind = 'faction';
      if (ctx.any(_npcCue.contains)) kind = 'npc';
      final q = _strip(f.$2);
      ents.add(ExtractedEntity(
          kind: kind,
          name: e.key,
          description: 'Citado ${e.value}× — confira o trecho e ajuste o tipo.',
          atMs: f.$1,
          quote: q.length > 160 ? q.substring(0, 160) : q));
    }
    return (ExtractionResult(ents, const []), const UsageInfo(0, 0));
  }

  static const _chatter = {
    'eu', 'você', 'vc', 'né', 'tá', 'pra', 'tô', 'cara', 'gente', 'kkk',
    'aham', 'hmm', 'ué', 'então', 'tipo', 'meu', 'minha', 'vou', 'quero',
  };

  @override
  Future<(SessionSummary, UsageInfo)> summarize(String transcript,
      {required List<KnownEntity> known, String campaignName = '', String extra = ''}) async {
    final lines = _lines(transcript);
    final p = _participants(lines);

    // Frases candidatas com posição na sessão.
    final cands = <({int ms, int idx, String text})>[];
    var idx = 0;
    for (final (ms, raw) in lines) {
      if (raw.toLowerCase().startsWith('participantes')) continue;
      final isDialogue = _speaker.hasMatch(raw);
      final body = _strip(raw);
      for (final s in body.split(RegExp(r'(?<=[.!?])\s+'))) {
        final t = s.trim();
        final n = t.split(RegExp(r'\s+')).length;
        if (n < 7 || n > 35 || t.endsWith('?')) continue;
        if (t.toLowerCase().startsWith('participantes')) continue;
        // Falas soltas entre jogadores raramente contam a história.
        if (isDialogue && n < 10) continue;
        cands.add((ms: ms, idx: idx++, text: t));
      }
    }
    if (cands.isEmpty) {
      return (
        const SessionSummary('Transcrição vazia ou curta demais.', '', ''),
        const UsageInfo(0, 0)
      );
    }

    final freq = <String, int>{};
    for (final c in cands) {
      for (final w in c.text.toLowerCase().split(RegExp(r'\W+'))) {
        if (w.length > 3) freq[w] = (freq[w] ?? 0) + 1;
      }
    }
    final names = {...p.characters, for (final k in known) k.name};
    double score(String s) {
      final ws = s.toLowerCase().split(RegExp(r'\W+')).where((w) => w.length > 3).toList();
      if (ws.isEmpty) return 0;
      var v = ws.fold<int>(0, (a, w) => a + (freq[w] ?? 0)) / ws.length;
      // Mais pontos para frases com nomes/personagens e narração em 3ª pessoa.
      v += names.where((n) => s.contains(n)).length * 2.5;
      v += _word.allMatches(s).length * .3;
      final chat = s.toLowerCase().split(RegExp(r'\W+')).where(_chatter.contains).length;
      v -= chat * 2;
      return v;
    }

    // Divide a sessão em N trechos de tempo e escolhe a melhor frase de cada
    // um — o resumo segue a ordem em que as coisas aconteceram.
    List<String> timeline(int parts) {
      final per = (cands.length / parts).ceil();
      final out = <String>[];
      for (var i = 0; i < cands.length; i += per) {
        final slice = cands.sublist(i, (i + per).clamp(0, cands.length));
        final best = (slice.toList()..sort((a, b) => score(b.text).compareTo(score(a.text)))).first;
        out.add(best.text);
      }
      return out;
    }

    final cast = p.roles.entries
        .where((e) => e.value.toLowerCase() != 'mestre')
        .map((e) => '${e.value} (${e.key})')
        .toList();
    final gm = p.roles.entries.where((e) => e.value.toLowerCase() == 'mestre').map((e) => e.key);

    final head = StringBuffer();
    if (cast.isNotEmpty) {
      head.write('Em cena: ${cast.join(', ')}');
      if (gm.isNotEmpty) head.write(', com ${gm.join(', ')} como mestre');
      head.write('.');
    }

    final shortParts = timeline(3);
    final longParts = timeline(8);
    final short = shortParts.join(' ');
    final narrative = [
      if (head.isNotEmpty) head.toString(),
      for (var i = 0; i < longParts.length; i++) longParts[i],
      '(Resumo automático extrativo, sem IA: os trechos acima são frases reais '
          'da sessão em ordem cronológica. Conecte uma IA em Configurações para '
          'receber um resumo narrativo completo.)',
    ].join('\n\n');
    final last = shortParts.length > 1 ? shortParts.sublist(shortParts.length - 2) : shortParts;
    final prev = 'Na última sessão: ${last.join(' ')}';
    return (SessionSummary(short, narrative, prev), const UsageInfo(0, 0));
  }
}
