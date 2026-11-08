import 'dart:io';
import 'package:drift/drift.dart' show Value;

import '../ai/activity.dart';
import '../ai/factory.dart';
import '../ai/interfaces.dart';
import '../ai/prompts.dart';
import '../core/engines.dart';
import '../core/settings.dart';
import '../data/database.dart';
import '../data/repository.dart';
import '../data/repo_notes.dart';
import 'models.dart';
import '../data/repo_facts.dart';
import 'balance.dart';
import 'combat_detector.dart';
import 'hero_context.dart';
import 'systems.dart';
import 'locate.dart';
import 'spell_detector.dart';

typedef Progress = void Function(String step, double fraction, String detail);

String fmtClock(int ms) {
  final s = ms ~/ 1000;
  final h = s ~/ 3600, m = (s % 3600) ~/ 60, sec = s % 60;
  String two(int v) => v.toString().padLeft(2, '0');
  return h > 0 ? '$h:${two(m)}:${two(sec)}' : '${two(m)}:${two(sec)}';
}

/// Junta os trechos num texto com horários `[mm:ss] (falante) texto`.
String formatTranscript(List<Segment> segs) {
  final b = StringBuffer();
  for (final s in segs) {
    b.writeln('[${fmtClock(s.startMs)}] ${s.speaker != null ? '${s.speaker}: ' : ''}${s.text_}');
  }
  return b.toString();
}

/// Etapa 3: limpeza. Remove repetições consecutivas idênticas (alucinação
/// típica do Whisper) e ordena; baixa confiança é preservada para marcação.
List<TranscriptSegment> cleanSegments(List<TranscriptSegment> input) {
  final segs = [...input]..sort((a, b) => a.startMs.compareTo(b.startMs));
  final out = <TranscriptSegment>[];
  String norm(String s) => s.toLowerCase().replaceAll(RegExp(r'[^\wà-ÿ ]'), '').trim();
  var repeats = 0;
  for (final s in segs) {
    if (s.text.trim().isEmpty) continue;
    if (out.isNotEmpty && norm(out.last.text) == norm(s.text)) {
      repeats++;
      if (repeats >= 2) continue; // mantém no máx. 2 repetições seguidas
    } else {
      repeats = 0;
    }
    out.add(s);
  }
  return out;
}

/// Divide o texto em pedaços por linhas, respeitando ~[maxTokens] tokens.
List<String> chunkTranscript(String text, int maxTokens) {
  if (estimateTokens(text) <= maxTokens) return [text];
  final chunks = <String>[];
  final cur = StringBuffer();
  for (final line in text.split('\n')) {
    if (estimateTokens(cur.toString()) + estimateTokens(line) > maxTokens &&
        cur.isNotEmpty) {
      chunks.add(cur.toString());
      cur.clear();
    }
    cur.writeln(line);
  }
  if (cur.isNotEmpty) chunks.add(cur.toString());
  return chunks;
}

class CostEstimate {
  final double usd;
  final String note;
  final int tokens;
  final int minutes;
  const CostEstimate(this.usd, this.note, this.tokens, this.minutes);
}

class SessionProcessor {
  final Repository repo;
  final Settings settings;
  final ProviderFactory factory;
  SessionProcessor(this.repo, this.settings, this.factory);

  /// Estimativa mostrada ANTES de processar (passo 3 do fluxo do usuário).
  Future<CostEstimate> estimate(String sessionId, ProcessingMode mode) async {
    final s = (await repo.session(sessionId))!;
    final audios = await repo.audiosOf(sessionId);
    final minutes = (audios.fold<int>(0, (a, b) => a + b.durationSec) / 60).ceil();
    // ~150 palavras/min * ~1,5 tokens/palavra em pt-BR
    final existing = await repo.segmentsOf(sessionId);
    final tokens = existing.isNotEmpty
        ? estimateTokens(formatTranscript(existing))
        : (minutes * 150 * 1.5).round();
    if (!settings.engineIsPaid) {
      final eng = settings.engine == 'local'
          ? 'Roda no seu computador: ~${(minutes * 0.5).ceil()}–${minutes * 2} min para ouvir o áudio.'
          : 'Usa o plano gratuito da IA escolhida; respeita os limites do provedor.';
      return CostEstimate(0, 'Sem custo em dinheiro. $eng', tokens, minutes);
    }
    final pricing = await settings.pricing();
    final tp = settings.engine ?? settings.textProvider;
    final model = settings.modelFor('extract') ?? pricing.defaultModel(mode, tp);
    final textCost = pricing.cost(model, tokens * 2 + 3000, 3500);
    final audioKey = settings.audioProvider == 'openai' ? 'whisper-1' : 'gemini';
    final audioCost = existing.isNotEmpty ? 0 : minutes * pricing.audioPerMinute(audioKey);
    return CostEstimate(
        textCost + audioCost,
        'Estimativa aproximada (${s.number}ª sessão, ~$minutes min de áudio, modelo $model). '
        'Valores da tabela de preços editável.',
        tokens, minutes);
  }

  Future<void> process(String sessionId, ProcessingMode mode, Progress progress) async {
    final session = (await repo.session(sessionId))!;
    final cid = session.campaignId;
    final campaign = (await repo.campaign(cid))!;
    await repo.updateSession(sessionId, SessionsCompanion(
        status: const Value('processing'), processingMode: Value(mode.key)));
    try {
      progress('config', 0, 'Preparando provedores…');
      Activity.log('Sessão ${session.number}: preparando a IA e conferindo o que já existe na campanha.');
      final audios = await repo.audiosOf(sessionId);
      final hasPending = audios.any((a) => !a.transcribed);
      final cfg = await factory.forMode(mode, needTranscriber: hasPending);
      final pricing = await settings.pricing();
      final hints = await repo.vocabularyHints(cid);

      // 2) Transcrição por bloco -------------------------------------------
      final pending = audios.where((a) => !a.transcribed).toList();
      var offset = 0;
      for (final a in audios) {
        if (a.transcribed) { if (a.speaker == null) offset += a.durationSec * 1000; continue; }
        break;
      }
      for (var i = 0; i < pending.length; i++) {
        final a = pending[i];
        progress('transcribe', i / (pending.isEmpty ? 1 : pending.length),
            'Transcrevendo bloco ${i + 1}/${pending.length} (${cfg.transcriber.label})');
        final segs = await cfg.transcriber.transcribe(a.filePath,
            language: campaign.language, vocabularyHints: hints,
            offsetMs: a.speaker == null ? offset : 0);
        await repo.insertSegments(sessionId, [
          for (final s in cleanSegments(segs))
            TranscriptSegment(s.startMs, s.endMs, s.text,
                speaker: s.speaker ?? a.speaker, confidence: s.confidence)
        ]);
        await repo.markTranscribed(a.id); // retomável: bloco salvo
        if (a.speaker == null) offset += a.durationSec * 1000;
      }
      if (cfg.cloudTranscribe && pending.isNotEmpty) {
        final mins = pending.fold<int>(0, (x, a) => x + a.durationSec) / 60;
        final key = settings.audioProvider == 'openai' ? 'whisper-1' : 'gemini';
        await repo.logUsage(cid, settings.audioProvider, 'transcribe',
            const UsageInfo(0, 0), mins * pricing.audioPerMinute(key));
      }

      // 3) Limpeza (junta, ordena, sem repetições) --------------------------
      progress('clean', 0, 'Limpando transcrição…');
      Activity.log('Juntando os blocos e removendo repetições.');
      final all = await repo.segmentsOf(sessionId);
      final text = formatTranscript(all);
      if (text.trim().isEmpty) {
        throw ProviderException('Transcrição vazia: nada para resumir.');
      }

      // 4) Extração por bloco -----------------------------------------------
      // Premium: sessão inteira numa chamada. Demais: blocos de ~6k tokens.
      // Cada IA tem o seu tamanho de bloco e o seu ritmo (limites por minuto).
      final lim = limitsFor(settings.engine);
      final limit = mode == ProcessingMode.premium && lim.chunkTokens >= 12000 ? 200000 : lim.chunkTokens;
      final chunks = chunkTranscript(text, limit);
      final knownAll = await repo.knownEntities(cid);
      // IAs com janela pequena recebem só as entidades mais recentes no contexto.
      final known = knownAll.length <= lim.knownMax ? knownAll : knownAll.sublist(knownAll.length - lim.knownMax);
      if (known.length < knownAll.length) Activity.log('Contexto reduzido: ${known.length} de ${knownAll.length} entidades conhecidas (limite da IA escolhida).');
      DateTime? lastCall;
      Future<void> pace() async {
        final now = DateTime.now();
        if (lastCall != null) {
          final wait = lim.minGap - now.difference(lastCall!);
          if (wait > Duration.zero) {
            Activity.log('Respeitando o limite por minuto da IA: pausa de ${wait.inSeconds + 1}s antes da próxima chamada.');
            await Future<void>.delayed(wait);
          }
        }
        lastCall = DateTime.now();
      }
      if (chunks.length > 1) Activity.log('Transcrição dividida em ${chunks.length} partes (limite da IA escolhida: ~$limit tokens por vez).');
      final heroes = await repo.heroesOf(cid);
      final heroNames = heroNamesFor(heroes);
      // A IA recebe a ficha resumida de cada herói e as regras para casar nomes.
      final heroCtx = [systemContext(campaign.system), heroContext(heroes, campaign.system)].where((e) => e.isNotEmpty).join('\n\n');
      if (heroes.isEmpty) {
        Activity.log('Nenhum herói cadastrado: a IA não saberá quem são os jogadores. Cadastre os heróis para um resultado melhor.');
      } else {
        Activity.log('Heróis conhecidos pela IA: ${heroes.map((h) => h.name).join(', ')}.');
      }
      final entities = <ExtractedEntity>[];
      final events = <ExtractedEvent>[];
      final facts = <ExtractedFact>[];
      for (var i = 0; i < chunks.length; i++) {
        progress('extract', i / chunks.length, 'Extraindo entidades ${i + 1}/${chunks.length}');
        await pace();
        final (r, u) = await cfg.extractor.extract(chunks[i], known: known, system: heroCtx);
        entities.addAll(r.entities);
        events.addAll(r.events);
        facts.addAll(r.facts);
        await repo.logUsage(cid, cfg.extractor.id, 'extract', u,
            pricing.cost(cfg.extractModel, u.inputTokens, u.outputTokens));
      }

      // Feitiços: o detector lê a transcrição (inclusive a do áudio) e registra
      // cada uso que a IA não tenha apontado.
      final spellsFound = mergeSpellUses(entities, detectSpells(text, known: knownAll, heroNames: heroNames));
      Activity.log('Detector de feitiços: ${spellsFound.length} uso(s) a mais além dos que a IA apontou.');
      entities.addAll(spellsFound);
      // Dano, cura e XP: a IA entende o contexto; o detector garante o básico.
      final combatFound = mergeFacts(facts, detectCombat(text, heroNames: heroNames));
      Activity.log('Combate: ${facts.length} fato(s) pela IA e ${combatFound.length} pelo detector (dano, cura, XP).');
      facts.addAll(combatFound);
      final norm = normalizeHeroNames(entities, facts, heroes);
      if (norm.dropped > 0) Activity.log('${norm.dropped} entrada(s) eram heróis cadastrados e foram removidas das descobertas.');
      // copia antes de limpar: sem heróis, `norm` devolve as próprias listas
      final keepEntities = [...norm.entities], keepFacts = [...norm.facts];
      entities
        ..clear()
        ..addAll(keepEntities);
      facts
        ..clear()
        ..addAll(keepFacts);
      final heroKeysSet = heroKeys(heroNames);
      final fixedFacts = [
        for (final f in facts)
          ExtractedFact(
            kind: f.kind, actor: f.actor, target: f.target, amount: f.amount, text: f.text, atMs: f.atMs, quote: f.quote,
            side: f.side.isNotEmpty ? f.side : (f.target.isEmpty ? '' : (isHeroName(f.target, heroKeysSet) ? 'hero' : 'enemy')),
          )
      ];

      // 5) Mesclagem ---------------------------------------------------------
      progress('merge', 0, 'Comparando com a campanha…');
      Activity.log('Comparando ${entities.length} entrada(s) com a enciclopédia para não duplicar.');
      await _merge(cid, sessionId, entities, events, all);
      await repo.replaceFacts(cid, sessionId, fixedFacts, timeOf: (f) => locateMention(all, quote: f.quote, name: f.target, atMs: f.atMs)?.startMs ?? f.atMs);

      // 6) Resumo final ------------------------------------------------------
      progress('summarize', 0, 'Gerando resumos…');
      Activity.log('Extração concluída. Agora o resumo e o "anteriormente em…".');
      var source = text;
      if (chunks.length > 1 && mode != ProcessingMode.premium) {
        // Resumo em duas passadas: resume cada bloco e depois resume os resumos.
        final parts = <String>[];
        for (var i = 0; i < chunks.length; i++) {
          await pace();
          final (s, u) = await cfg.summarizer.summarize(chunks[i],
              known: known, campaignName: campaign.name);
          parts.add('[parte ${i + 1}] ${s.narrative.isEmpty ? s.short : s.narrative}');
          await repo.logUsage(cid, cfg.summarizer.id, 'summarize', u,
              pricing.cost(cfg.summarizeModel, u.inputTokens, u.outputTokens));
        }
        source = parts.join('\n');
        // O resumo final também precisa caber no limite da IA: se passar, encurta cada parte.
        final maxChars = (limit * 4).toInt();
        if (source.length > maxChars) {
          final each = (maxChars / parts.length).floor();
          source = parts.map((x) => x.length <= each ? x : '${x.substring(0, each)}…').join('\n');
          Activity.log('Resumos parciais encurtados para caber no limite da IA.');
        }
      }
      final balance = buildBalance([
        for (final e in entities)
          if (e.kind == 'spell') SpellUse(e.name, e.caster, e.target, e.side, e.result)
      ], fixedFacts);
      final combatCtx = [
        heroCtx,
        if (balance.longText.isNotEmpty) 'Dados de combate já extraídos (use na crônica): ${balance.longText}',
      ].where((e) => e.isNotEmpty).join('\n\n');
      await pace();
      final (sum0, u) = await cfg.summarizer.summarize(source,
          known: known, campaignName: campaign.name, extra: combatCtx);
      await repo.logUsage(cid, cfg.summarizer.id, 'summarize', u,
          pricing.cost(cfg.summarizeModel, u.inputTokens, u.outputTokens));
      final sum = withBalance(sum0, balance);
      await repo.updateSession(sessionId, SessionsCompanion(
          shortSummary: Value(sum.short), longSummary: Value(sum.narrative),
          previouslyOn: Value(sum.previouslyOn)));
      await repo.replaceAiThreads(cid, sessionId, sum.openThreads);

      // 7) Fila de revisão ---------------------------------------------------
      await repo.setSessionStatus(sessionId, 'review');
      Activity.log('Tudo pronto: ${entities.length} descoberta(s) aguardam a sua revisão.');
      progress('done', 1, 'Pronto para revisão.');
      if (settings.deleteAudioAfter) {
        // privacidade: apaga áudio gravado após transcrever (opcional)
        for (final a in await repo.audiosOf(sessionId)) {
          if (a.origin == 'recorded') {
            try { await File(a.filePath).delete(); } catch (_) {}
          }
        }
      }
    } catch (e) {
      // Volta para "recorded": blocos já transcritos ficam salvos e a
      // reexecução retoma de onde parou.
      await repo.setSessionStatus(sessionId, 'recorded');
      rethrow;
    }
  }

  Future<void> _merge(String cid, String sid, List<ExtractedEntity> found,
      List<ExtractedEvent> events, List<Segment> segs) async {
    final existing = await repo.entitiesOf(cid);
    final created = <Entity>[];
    for (final x in found) {
      final pool = [...existing, ...created];
      var match = repo.findMatch(pool, x.kind, x.name, x.aliases);
      if (match == null) {
        final id = await repo.saveEntity(EntitiesCompanion.insert(
            id: newId(), campaignId: cid, kind: x.kind, name: x.name,
            aliases: Value(x.aliases.join(', ')),
            description: Value(x.description),
            status: Value(x.status), attr: Value(x.attr),
            giver: Value(x.giver), reward: Value(x.reward),
            review: const Value('suggested')));
        match = (await repo.entity(id))!;
        created.add(match);
      }
      // Ligações automáticas: local dentro de local e quem deu a missão.
      final poolNow = [...existing, ...created];
      if (x.parentName.isNotEmpty) {
        final parent = repo.findMatch(poolNow, 'location', x.parentName, const []);
        if (parent != null) await repo.ensureRelation(cid, match.id, parent.id, 'fica em');
      }
      if (x.kind == 'quest' && x.giver.isNotEmpty) {
        final giver = repo.findMatch(poolNow, 'npc', x.giver, const []);
        if (giver != null) await repo.ensureRelation(cid, giver.id, match.id, 'deu a missão');
      }
      // Propõe atualização (status), nunca duplicata.
      var field = '', value = '';
      if (x.status.isNotEmpty && x.status != match.status) {
        field = 'status'; value = x.status;
      } else if (x.attr.isNotEmpty && x.attr != match.attr) {
        field = 'attr'; value = x.attr;
      }
      // A IA erra o horário com frequência: localiza o trecho real pela citação/nome.
      final loc = locateMention(segs, quote: x.quote, name: x.name, aliases: x.aliases, atMs: x.atMs);
      final realAt = loc?.startMs ?? x.atMs;
      final realQuote = x.quote.isNotEmpty ? x.quote : (loc?.text_ ?? '');
      await repo.db.into(repo.db.mentions).insert(MentionsCompanion.insert(
          id: newId(), entityId: match.id, sessionId: sid,
          atMs: Value(realAt), quote: Value(realQuote),
          detail: Value(x.kind == 'spell' && x.caster.isNotEmpty ? 'Lançado por ${x.caster}' : ''),
          target: Value(x.target), side: Value(x.side), result: Value(x.result),
          proposedField: Value(field), proposedValue: Value(value)));
    }
    var ord = 0;
    for (final e in events) {
      await repo.db.into(repo.db.events).insert(EventsCompanion.insert(
          id: newId(), sessionId: sid, text_: e.text, ord: ord++, atMs: Value(e.atMs)));
    }
  }
}
