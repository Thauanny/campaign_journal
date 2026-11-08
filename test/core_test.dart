import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:campaign_journal/ai/factory.dart';
import 'package:campaign_journal/ai/gemini_models.dart';
import 'package:campaign_journal/ai/llm_adapters.dart';
import 'package:campaign_journal/ai/retry.dart';
import 'package:campaign_journal/ai/quota.dart';
import 'package:campaign_journal/ai/capabilities.dart';
import 'package:campaign_journal/core/engines.dart';
import 'package:campaign_journal/ai/model_catalog.dart';
import 'package:campaign_journal/ai/interfaces.dart';
import 'package:campaign_journal/ai/local_heuristic.dart';
import 'package:campaign_journal/ai/prompts.dart';
import 'package:campaign_journal/core/settings.dart';
import 'package:campaign_journal/data/database.dart';
import 'package:campaign_journal/data/repository.dart';
import 'package:campaign_journal/domain/models.dart';
import 'package:campaign_journal/domain/name_match.dart';
import 'package:campaign_journal/domain/pipeline.dart';
import 'package:campaign_journal/data/repo_notes.dart';
import 'package:campaign_journal/domain/exporter.dart';
import 'package:campaign_journal/domain/sheet_parser.dart';
import 'package:campaign_journal/domain/spell_detector.dart';
import 'package:campaign_journal/domain/locate.dart';
import 'package:campaign_journal/domain/combat_detector.dart';
import 'package:campaign_journal/domain/balance.dart';
import 'package:campaign_journal/domain/hero_context.dart';
import 'package:campaign_journal/features/journey.dart';
import 'package:campaign_journal/domain/systems.dart';
import 'package:campaign_journal/data/repo_facts.dart';
import 'package:campaign_journal/core/rpg_theme.dart';
import 'package:campaign_journal/domain/transcript_import.dart';
import 'package:campaign_journal/domain/ask.dart';

class FakeTranscriber implements Transcriber {
  int calls = 0;
  @override String get id => 'fake';
  @override String get label => 'fake';
  @override bool get needsNetwork => false;
  @override
  Future<List<TranscriptSegment>> transcribe(String audioPath,
      {String language = 'pt-BR', List<String> vocabularyHints = const [], int offsetMs = 0}) async {
    calls++;
    return [
      TranscriptSegment(offsetMs, offsetMs + 4000, 'O cavaleiro Aldo chegou em Valdoria.'),
      TranscriptSegment(offsetMs + 4000, offsetMs + 8000, 'Ele aceitou a missão do ferreiro.'),
      TranscriptSegment(offsetMs + 4000, offsetMs + 8000, 'Ele aceitou a missão do ferreiro.'),
      TranscriptSegment(offsetMs + 4000, offsetMs + 8000, 'Ele aceitou a missão do ferreiro.'),
    ];
  }
}

class FakeText implements TextModel {
  @override String get id => 'fake';
  @override String get label => 'fake';
  @override bool get needsNetwork => false;
  @override
  Future<(ExtractionResult, UsageInfo)> extract(String t,
      {required List<KnownEntity> known, String system = ''}) async => (
        const ExtractionResult([
          ExtractedEntity(kind: 'npc', name: 'Ser Aldo', status: 'aliado', atMs: 1000, quote: 'O cavaleiro Aldo chegou'),
          ExtractedEntity(kind: 'location', name: 'Valdoria', atMs: 1000, quote: 'em Valdoria'),
          ExtractedEntity(kind: 'quest', name: 'Espada perdida', status: 'ativa', atMs: 5000),
        ], [ExtractedEvent('Aldo chega a Valdoria', 1000)]),
        const UsageInfo(100, 50)
      );
  @override
  Future<(SessionSummary, UsageInfo)> summarize(String t,
      {required List<KnownEntity> known, String campaignName = '', String extra = ''}) async =>
      (const SessionSummary('curto', 'longo', 'Anteriormente...', openThreads: ['Quem enviou os recrutas?']), const UsageInfo(10, 5));
}

class SpellTranscriber implements Transcriber {
  @override
  String get id => 'spell';
  @override
  String get label => 'spell';
  @override
  bool get needsNetwork => false;
  @override
  Future<List<TranscriptSegment>> transcribe(String audioPath, {String language = 'pt-BR', List<String> vocabularyHints = const [], int offsetMs = 0}) async =>
      [TranscriptSegment(offsetMs, offsetMs + 3000, 'Eu lanço Bola de Fogo nos recrutas.', speaker: 'Bia')];
}

class FakeFactory extends ProviderFactory {
  final Transcriber tr;
  FakeFactory(Settings s, this.tr) : super(s, Dio());
  @override
  Future<ModeConfig> forMode(ProcessingMode mode, {bool needTranscriber = true}) async =>
      ModeConfig(tr, FakeText(), FakeText(), 'fake', 'fake', false);
}

void main() {
  sheetTests();
  transcriptImportTests();
  TestWidgetsFlutterBinding.ensureInitialized();

  group('name matching', () {
    test('SerAldo == o cavaleiro Aldo', () => expect(sameName('SerAldo', 'o cavaleiro Aldo'), isTrue));
    test('erro de grafia de 1 letra', () => expect(sameName('Valdória', 'Valdoria'), isTrue));
    test('nomes diferentes', () => expect(sameName('Aldo', 'Borin'), isFalse));
  });

  group('jornada da campanha', () {
    final verren = Entity(id: 'v', campaignId: 'c', kind: 'npc', name: 'Verren', aliases: '', description: 'Soldado', status: '', attr: '', parentId: null, ownerId: null, giver: '', reward: '', review: 'confirmed');
    final teia = Entity(id: 't', campaignId: 'c', kind: 'spell', name: 'Teia', aliases: '', description: '', status: '', attr: '', parentId: null, ownerId: null, giver: '', reward: '', review: 'confirmed');
    Mention m(String e, int ms) => Mention(id: '$e$ms', entityId: e, sessionId: 's', atMs: ms, quote: '', proposedField: '', proposedValue: '', detail: '', target: '', side: '', result: '', status: 'confirmed');
    test('NPC só na primeira aparição da CAMPANHA; feitiço, cada uso', () {
      final seen = <String>{};
      final ents = {'v': verren, 't': teia};
      final s1 = timelineItems(events: [], mentions: [m('v', 1000), m('t', 2000)], facts: [], ents: ents, seen: seen);
      final s2 = timelineItems(events: [], mentions: [m('v', 500), m('t', 800), m('t', 900)], facts: [], ents: ents, seen: seen);
      expect(s1.where((i) => i.type == 'npc').length, 1);
      expect(s2.where((i) => i.type == 'npc').length, 0); // já tinha aparecido na sessão 1
      expect(s2.where((i) => i.type == 'spell').length, 2);
    });
    test('itens de herói nunca entram', () {
      final item = Entity(id: 'i', campaignId: 'c', kind: 'item', name: 'Bordão', aliases: '', description: '', status: '', attr: '', parentId: null, ownerId: 'hero', giver: '', reward: '', review: 'confirmed');
      expect(timelineItems(events: [], mentions: [m('i', 1)], facts: [], ents: {'i': item}, seen: <String>{}), isEmpty);
    });
  });

  group('sistema de RPG nos prompts', () {
    test('o contexto do sistema ensina vocabulário próprio', () {
      final t = systemContext('Tormenta20');
      expect(t, contains('SISTEMA DE RPG DA CAMPANHA: Tormenta20'));
      expect(t, contains('PM'));
      expect(t, contains('kind "spell"'));
      expect(t, contains('abalado'));
      final o = systemContext('Ordem Paranormal');
      expect(o, contains('rituais'));
      expect(o, contains('SAN'));
      expect(systemContext('Daggerheart'), contains('Daggerheart')); // sistema desconhecido: ainda informa o nome
    });
    test('termos do sistema entram no vocabulário do áudio', () {
      expect(profileFor('Tormenta20').vocab, containsAll(['Dahllan', 'Allihanna', 'Druida']));
      expect(profileFor('Vampiro: A Máscara').vocab, contains('Toreador'));
      expect(profileFor('Outro').vocab, isEmpty);
    });
  });

  group('ficha lida pela IA', () {
    test('o esquema pede os campos do sistema e avisa que é formulário', () {
      final h = sheetSchemaHint('Tormenta20');
      expect(h, contains('FORMULÁRIO'));
      expect(h, contains('"pm"'));
      expect(h, contains('"defesa"'));
      expect(h, contains('Druida 2'));
      expect(sheetSchemaHint('Ordem Paranormal'), contains('"pe"'));
    });
    test('PV, XP e campos do sistema chegam à conferência', () {
      final f = SheetFields.fromJson({
        'name': 'Cristina', 'player': 'Nanda', 'class': 'Druida', 'race': 'Dahllan', 'level': 2,
        'hp_max': 24, 'hp_current': 24, 'xp': 0,
        'extra': {'pm': '8', 'defesa': '13', 'origem': 'Acólito', 'divindade': 'Allihanna', 'vazio': ''},
        'items': ['Bordão', 'Funda'],
      });
      expect(f.name, 'Cristina');
      expect(f.heroClass, 'Druida');
      expect(f.level, 2);
      expect(f.extra['pm'], '8');
      expect(f.extra['divindade'], 'Allihanna');
      expect(f.extra.containsKey('vazio'), isFalse); // campo vazio descartado
      expect(f.extra[kHpMaxKey], '24');
      expect(f.extra[kHpNowKey], '24');
      expect(f.extra.containsKey(kXpKey), isFalse); // XP 0 não é informação
    });
  });

  group('chaves de API: leitura do chaveiro', () {
    test('chaveiro indisponível NÃO vira "sem chave" se a chave foi salva antes', () async {
      SharedPreferences.setMockInitialValues({'keyflag_gemini': true});
      final st = Settings(await SharedPreferences.getInstance(), const FlutterSecureStorage()); // sem plugin no teste: leitura falha
      expect(await st.keyConfigured('gemini'), isTrue);
    });
    test('sem marca e sem chave = não configurada', () async {
      SharedPreferences.setMockInitialValues({});
      final st = Settings(await SharedPreferences.getInstance(), const FlutterSecureStorage());
      expect(await st.keyConfigured('gemini'), isFalse);
    });
  });

  group('legibilidade: contraste das cores (WCAG 4,5:1)', () {
    for (final (nome, pal) in [('escuro', RpgPalette.dark), ('claro', RpgPalette.light)]) {
      test('$nome: texto e rótulos sobre as superfícies', () {
        for (final bg in [pal.bg, pal.surface, pal.surface2, pal.bgDeep]) {
          expect(contrastRatio(pal.text, bg), greaterThanOrEqualTo(4.5), reason: 'text em $nome');
          expect(contrastRatio(pal.muted, bg), greaterThanOrEqualTo(4.5), reason: 'muted em $nome');
        }
      });
      test('$nome: cores de tipo e destaque legíveis sobre o cartão', () {
        for (final e in {...pal.kinds, 'gold': pal.gold, 'arcane': pal.arcane, 'emerald': pal.emerald, 'crimson': pal.crimson}.entries) {
          expect(contrastRatio(e.value, pal.surface), greaterThanOrEqualTo(4.5), reason: '${e.key} em $nome');
        }
      });
      test('$nome: texto sobre cor chapada (selos)', () {
        for (final c in [...pal.kinds.values, pal.gold, pal.arcane, pal.emerald, pal.crimson]) {
          expect(contrastRatio(onColor(c), c), greaterThanOrEqualTo(4.5));
        }
      });
    }
  });

  group('heróis: contexto da IA e correspondência de nomes', () {
    Heroe hero(String name, {String player = '', String cls = '', String race = '', String extra = '{}', int level = 3}) => Heroe(
        id: name, campaignId: 'c', player: player, name: name, heroClass: cls, race: race, level: level, story: '', photoPath: null,
        notes: '', sheetPath: null, extra: extra, hpCurrent: 30, hpMax: 30, xp: 0);
    final bram = hero('Bram Cascalho', player: 'Rafa', cls: 'Guerreiro', race: 'Minotauro', extra: '{"apelidos":"Bram, o Touro","pm":"6"}');
    final orq = hero('Orquídea', player: 'Bia', cls: 'Druida', race: 'Elfa');

    test('a IA recebe nome, jogador, apelidos, classe, raça, nível, PV e campos do sistema', () {
      final c = heroContext([bram, orq], 'Tormenta20');
      expect(c, contains('Bram Cascalho — jogador Rafa'));
      expect(c, contains('também chamado de Bram / o Touro'));
      expect(c, contains('classe: Guerreiro'));
      expect(c, contains('raça: Minotauro'));
      expect(c, contains('PM (pontos de mana): 6'));
      expect(c, contains('NÃO crie entidade'));
      expect(c, isNot(contains('\\n'))); // sem "\n" literal
      expect(heroContext([], 'D&D 5e'), '');
    });
    test('cada sistema usa os próprios rótulos', () {
      expect(profileFor('Ordem Paranormal').levelLabel, 'NEX (%)');
      expect(profileFor('Call of Cthulhu').classLabel, 'Ocupação');
      expect(profileFor('Vampiro: A Máscara').classLabel, 'Clã');
      expect(profileFor('Sistema inventado').name, 'Outro');
    });
    test('apelido, jogador e primeiro nome apontam para o herói cadastrado', () {
      expect(canonicalHero('Rafa', [bram, orq]), 'Bram Cascalho');
      expect(canonicalHero('Bram', [bram, orq]), 'Bram Cascalho');
      expect(canonicalHero('o Touro', [bram, orq]), 'Bram Cascalho');
      expect(canonicalHero('Verren', [bram, orq]), isNull);
    });
    test('heróis não viram NPCs e os nomes nos fatos ficam oficiais', () {
      final r = normalizeHeroNames(
        [
          const ExtractedEntity(kind: 'npc', name: 'Bram'), // é o herói: sai
          const ExtractedEntity(kind: 'npc', name: 'Verren'),
          const ExtractedEntity(kind: 'spell', name: 'Teia', caster: 'Bia', target: 'Rafa'),
        ],
        [const ExtractedFact(kind: 'damage', actor: 'Verren', target: 'Rafa', amount: 5)],
        [bram, orq],
      );
      expect(r.dropped, 1);
      expect(r.entities.map((e) => e.name), ['Verren', 'Teia']);
      expect(r.entities.last.caster, 'Orquídea');
      expect(r.entities.last.target, 'Bram Cascalho');
      expect(r.facts.single.target, 'Bram Cascalho');
    });
  });

  group('combate: lado, alvo, dano, cura e XP', () {
    const t = '''[00:01] Participantes: Caio (Mestre), Bia (Orquídea), Rafa (Bram Cascalho)
[05:00] Bia: Eu lanço Bola de Fogo nos recrutas e acerto em cheio.
[05:10] Caio: Verren conjura Teia em Bram Cascalho.
[05:20] Caio: Bram Cascalho sofre 8 de dano da espada.
[05:30] Rafa: Eu uso Cura em Orquídea e ela recupera 6 PV.
[09:00] Caio: Cada herói ganha 150 XP.''';
    final heroes = ['Bram Cascalho', 'Orquídea', 'Rafa', 'Bia'];
    test('feitiço dos heróis × dos inimigos, com alvo e resultado', () {
      final sp = detectSpells(t, heroNames: heroes);
      final fogo = sp.firstWhere((e) => e.name == 'Bola de Fogo');
      expect(fogo.side, 'hero');
      expect(fogo.target, contains('recrutas'));
      expect(fogo.result, 'acertou');
      final teia = sp.firstWhere((e) => e.name == 'Teia');
      expect(teia.side, 'enemy');
      expect(teia.caster, 'Verren');
      expect(teia.target, 'Bram Cascalho');
    });
    test('dano, cura e XP', () {
      final f = detectCombat(t, heroNames: heroes);
      final d = f.firstWhere((x) => x.kind == 'damage');
      expect(d.amount, 8);
      expect(d.target, 'Bram Cascalho');
      expect(d.side, 'hero');
      final h = f.firstWhere((x) => x.kind == 'heal');
      expect(h.amount, 6);
      final x = f.firstWhere((x) => x.kind == 'xp');
      expect(x.amount, 150);
      expect(x.target, 'grupo');
    });
    test('balanço entra nos resumos, antes do aviso de "sem IA"', () {
      final b = buildBalance([
        const SpellUse('Bola de Fogo', 'Orquídea', 'os recrutas', 'hero', 'acertou'),
        const SpellUse('Teia', 'Verren', 'Bram Cascalho', 'enemy', ''),
      ], [const ExtractedFact(kind: 'damage', target: 'Bram Cascalho', side: 'hero', amount: 8), const ExtractedFact(kind: 'xp', target: 'grupo', side: 'hero', amount: 150)]);
      expect(b.shortText, contains('1 dos heróis, 1 dos inimigos'));
      expect(b.shortText, contains('+150 XP'));
      expect(b.longText, contains('Feitiços dos inimigos: Teia (Verren → Bram Cascalho)'));
      final r = withBalance(const SessionSummary('curto', 'longa\n\n(Resumo automático extrativo, sem IA)', ''), b);
      expect(r.short, contains('Combate:'));
      expect(r.narrative.indexOf('Balanço do combate'), lessThan(r.narrative.indexOf('(Resumo automático')));
    });
  });

  group('localizar trecho', () {
    Segment seg(int id, int ms, String t) => Segment(id: '$id', sessionId: 's', startMs: ms, endMs: ms + 3000, text_: t, speaker: null, confidence: 1.0);
    final segs = [
      seg(1, 0, 'Gente, vamos começar? Duda, guarda o celular.'),
      seg(2, 8000, 'Orquídea conjura Teia e prende os recrutas.'),
      seg(3, 30000, 'Verren foge para Pedraalta.'),
    ];
    test('acha pela citação mesmo com horário errado', () {
      final s = locateMention(segs, quote: 'Orquídea conjura Teia e prende os recrutas.', name: 'Teia', atMs: 0);
      expect(s!.id, '2');
    });
    test('sem citação, acha pelo nome', () {
      expect(locateMention(segs, quote: '', name: 'Pedraalta', atMs: 0)!.id, '3');
    });
    test('citação com acentos/pontuação diferentes ainda casa', () {
      expect(locateMention(segs, quote: 'orquidea conjura teia', name: 'x')!.id, '2');
    });
    test('não inventa quando não há nada', () {
      expect(locateMention(segs, quote: 'nada a ver com a sessão inteira', name: 'Zzz'), isNull);
    });
  });

  group('detector de feitiços', () {
    const t = '''[00:01] Participantes: Caio (Mestre), Bia (Orquídea), Rafa (Bram Cascalho)
[09:54] Rafa: Eu ativo Armadura de Allihanna! Um PM, mais dois na Defesa.
[10:20] Bia: Eu lanço Bola de Fogo nos recrutas.
[10:21] Caio: A luz do sol some atrás da serra.
[11:02] Orquídea conjura Cura Completa em Bram.
[11:30] Rafa: Eu uso Cura no Duda.
[12:00] Rafa: A Cura aqui é demorada.
[12:10] Bia: Lanço Bola de Fogo de novo!''';
    final hits = detectSpells(t);
    test('um registro por uso, com quem lançou', () {
      final names = hits.map((h) => h.name).toList();
      expect(names.where((n) => n == 'Bola de Fogo').length, 2);
      expect(names, contains('Armadura de Allihanna'));
      expect(names, contains('Cura Completa'));
      final a = hits.firstWhere((h) => h.name == 'Armadura de Allihanna');
      expect(a.caster, 'Bram Cascalho (Rafa)');
      expect(a.atMs, 594000);
      final f = hits.firstWhere((h) => h.name == 'Bola de Fogo');
      expect(f.caster, 'Orquídea (Bia)');
    });
    test('palavra comum sem verbo de conjuração não vira feitiço', () {
      expect(hits.any((h) => h.name == 'Luz'), isFalse);
      // "Eu uso Cura" conta; "A Cura aqui é demorada" não
      expect(hits.where((h) => h.name == 'Cura').length, 1);
    });
    test('não duplica o que a IA já apontou', () {
      final ai = [ExtractedEntity(kind: 'spell', name: 'Bola de Fogo', atMs: 622000)];
      final extra = mergeSpellUses(ai, hits);
      expect(extra.where((h) => h.name == 'Bola de Fogo').length, 1); // só o segundo uso
    });
  });

  group('gemini: streaming (SSE)', () {
    test('junta o texto das partes e ignora pensamento', () {
      final a = parseSseLine('data: {"candidates":[{"content":{"parts":[{"text":"{\\"a\\":"},{"text":"x","thought":true}]}}]}');
      expect(a!.$1, '{"a":');
      final b = parseSseLine('data: {"candidates":[{"content":{"parts":[{"text":"1}"}]}}],"usageMetadata":{"promptTokenCount":8}}');
      expect(b!.$1, '1}');
      expect(b.$2['promptTokenCount'], 8);
      expect(parseSseLine(''), isNull);
      expect(parseSseLine('data: [DONE]'), isNull);
    });
    test('demora sem resposta também é tentada de novo', () async {
      var n = 0;
      final r = await retrying(() async {
        n++;
        if (n < 2) throw DioException(requestOptions: RequestOptions(path: '/'), type: DioExceptionType.receiveTimeout);
        return 'ok';
      }, delays: const [Duration.zero]);
      expect(r, 'ok');
    });
  });

  group('gemini: sobrecarga (503)', () {
    DioException err(RequestOptions o, int code) => DioException(requestOptions: o, response: Response(requestOptions: o, statusCode: code), type: DioExceptionType.badResponse);
    test('tenta de novo e funciona na 3ª vez', () async {
      var n = 0;
      final r = await retrying(() async {
        n++;
        if (n < 3) throw err(RequestOptions(path: '/'), 503);
        return 'ok';
      }, delays: const [Duration.zero, Duration.zero, Duration.zero]);
      expect(r, 'ok');
      expect(n, 3);
    });
    test('erro 400 não é repetido', () async {
      var n = 0;
      await expectLater(retrying(() async { n++; throw err(RequestOptions(path: '/'), 400); }, delays: const [Duration.zero]), throwsA(isA<DioException>()));
      expect(n, 1);
    });
    test('teste da chave: se o modelo recusa desligar o pensamento (400), repete sem isso', () async {
      final bodies = <dynamic>[];
      final d = Dio()
        ..interceptors.add(InterceptorsWrapper(onRequest: (o, h) {
          bodies.add(o.data);
          if (bodies.length == 1) return h.reject(err(o, 400));
          h.resolve(Response(requestOptions: o, statusCode: 200, data: {}));
        }));
      final msg = await testTextModel(d, 'gemini', 'k', 'm');
      expect(msg, isNull);
      expect(bodies.length, 2);
      expect((bodies[0] as Map).containsKey('generationConfig'), isTrue);
      expect((bodies[1] as Map).containsKey('generationConfig'), isFalse);
    });

    test('503 persistente no teste vira mensagem amigável (sem usar a chave real)', () async {
      final d = Dio()..interceptors.add(InterceptorsWrapper(onRequest: (o, h) => h.reject(err(o, 503))));
      final msg = await testTextModel(d, 'gemini', 'k', 'm', allowFallback: false, delays: const [Duration.zero]);
      expect(msg, contains('sobrecarregado'));
    });
  });

  group('gemini: modelo automático', () {
    test('sem escolha usa o apelido flash-latest, sem rede', () async {
      expect(await resolveGeminiModel(Dio(), 'k'), 'gemini-flash-latest');
    });
    test('a escolha do usuário vence', () async {
      expect(await resolveGeminiModel(Dio(), 'k', override: 'meu-modelo'), 'meu-modelo');
    });
  });

  group('prompts/parsing', () {
    test('status copiado do molde do prompt é limpo', () {
      final e = ExtractedEntity.fromJson({'kind': 'npc', 'name': 'Verren', 'status': 'npc: inimigo', 'attr': 'aliado|neutro|inimigo'})!;
      expect(e.status, 'inimigo');
      expect(e.attr, 'aliado');
      expect(ExtractedEntity.cleanValue('ativa'), 'ativa');
      expect(ExtractedEntity.cleanValue('quest: concluída'), 'concluída');
    });
    test('resumo lê open_threads', () {
      final s = parseSummary({'short': 'a', 'narrative': 'b', 'open_threads': ['x', ' ', 'y']})!;
      expect(s.openThreads, ['x', 'y']);
    });
    test('JSON dentro de cerca markdown', () {
      final j = parseJsonObject('```json\n{"entities":[{"kind":"npc","name":"X"}],"events":[]}\n```');
      expect(parseExtraction(j!).entities.single.name, 'X');
    });
    test('JSON malformado -> null', () => expect(parseJsonObject('sem json'), isNull));
    test('tipo inválido é descartado', () {
      expect(parseExtraction({'entities': [{'kind': 'xyz', 'name': 'A'}]}).entities, isEmpty);
    });
  });

  group('pipeline', () {
    test('chunking respeita limite', () {
      final text = List.generate(500, (i) => '[00:0$i] ${'palavra ' * 20}').join('\n');
      final chunks = chunkTranscript(text, 1000);
      expect(chunks.length, greaterThan(1));
      expect(chunks.every((c) => estimateTokens(c) <= 1100), isTrue);
    });
    test('limpeza remove repetições em loop', () {
      final out = cleanSegments([for (var i = 0; i < 6; i++) TranscriptSegment(i, i + 1, 'Obrigado.')]);
      expect(out.length, 2); // no máx. 2 iguais seguidas
    });
    test('heurística offline devolve resumo e entidades', () async {
      final t = '[00:01] Hoje o grupo encontrou Borin na taverna.\n' * 3 +
          '[00:10] Depois Borin entregou um mapa antigo para o grupo inteiro.';
      final m = LocalHeuristicText();
      final (s, _) = await m.summarize(t, known: []);
      expect(s.short, isNotEmpty);
    });
  });

  group('sessão ponta a ponta (provedores falsos)', () {
    late AppDatabase db;
    late Repository repo;
    late Settings settings;
    late FakeTranscriber tr;
    late SessionProcessor proc;
    late String cid, sid;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = Repository(db);
      settings = Settings(await SharedPreferences.getInstance(), const FlutterSecureStorage());
      tr = FakeTranscriber();
      proc = SessionProcessor(repo, settings, FakeFactory(settings, tr));
      cid = await repo.saveCampaign(name: 'Teste', system: 'D&D 5e');
      sid = await repo.createSession(cid);
      await repo.addAudio(sid, '/x/a.m4a', durationSec: 300);
      await repo.addAudio(sid, '/x/b.m4a', durationSec: 300);
    });
    tearDown(() => db.close());

    test('processa, cria sugestões e não duplica na 2ª sessão', () async {
      await proc.process(sid, ProcessingMode.free, (_, __, ___) {});
      var s = (await repo.session(sid))!;
      expect(s.status, 'review');
      expect(s.shortSummary, 'curto');
      // 2 blocos, offset do 2º = 300s
      final segs = await repo.segmentsOf(sid);
      expect(segs.any((x) => x.startMs >= 300000), isTrue);
      // repetição removida (3 iguais -> 2 por bloco)
      expect(segs.length, 6);

      final pending = await repo.pendingMentions(sid);
      expect(pending, isNotEmpty);
      // Nada é "fato" antes da revisão
      expect(await (db.select(db.entities)..where((e) => e.review.equals('confirmed'))).get(), isEmpty);

      await repo.confirmAll(sid);
      s = (await repo.session(sid))!;
      expect(s.status, 'done');
      final ents = await repo.entitiesOf(cid);
      expect(ents.every((e) => e.review == 'confirmed'), isTrue);

      // Sessão 2: "Aldo" de novo vira menção, não entidade nova
      final sid2 = await repo.createSession(cid);
      await repo.addAudio(sid2, '/x/c.m4a', durationSec: 60);
      final before = (await repo.entitiesOf(cid)).length;
      await proc.process(sid2, ProcessingMode.free, (_, __, ___) {});
      expect((await repo.entitiesOf(cid)).length, before);
    });

    test('retomada: blocos já transcritos não são refeitos', () async {
      final a = await repo.audiosOf(sid);
      await repo.markTranscribed(a.first.id);
      await proc.process(sid, ProcessingMode.free, (_, __, ___) {});
      expect(tr.calls, 1);
    });

    test('descartar sugestão remove entidade órfã', () async {
      await proc.process(sid, ProcessingMode.free, (_, __, ___) {});
      final before = (await repo.entitiesOf(cid)).length;
      final m = (await repo.pendingMentions(sid)).first;
      await repo.discardMention(m.id);
      expect((await repo.entitiesOf(cid)).length, lessThan(before + 1));
    });

    test('mudança de status confirmada gera histórico', () async {
      await proc.process(sid, ProcessingMode.free, (_, __, ___) {});
      await repo.confirmAll(sid);
      final quest = (await repo.entitiesOf(cid)).firstWhere((e) => e.kind == 'quest');
      expect(quest.status, 'ativa');
      final h = await (db.select(db.entityHistory)..where((x) => x.entityId.equals(quest.id))).get();
      expect(h.any((x) => x.field == 'status' && x.newValue == 'ativa'), isTrue);
    });

    test('mesclar duplicados move menções e vira apelido', () async {
      final a = await repo.saveEntity(EntitiesCompanion.insert(
          id: newId(), campaignId: cid, kind: 'npc', name: 'Borin', review: const Value('confirmed')));
      final b = await repo.saveEntity(EntitiesCompanion.insert(
          id: newId(), campaignId: cid, kind: 'npc', name: 'Burin o anão', review: const Value('confirmed')));
      await repo.mergeEntities(b, a);
      final e = (await repo.entity(a))!;
      expect(e.aliases, contains('Burin o anão'));
      expect(await repo.entity(b), isNull);
    });

    test('ganchos da IA viram notas e reprocessar não duplica', () async {
      await proc.process(sid, ProcessingMode.free, (_, __, ___) {});
      await proc.process(sid, ProcessingMode.free, (_, __, ___) {});
      final th = await repo.notesOf(cid, 'thread');
      expect(th.length, 1);
      expect(th.first.body, 'Quem enviou os recrutas?');
      expect(th.first.source, 'ai');
    });

    test('feitiços da transcrição viram menções com quem lançou', () async {
      final f = FakeFactory(settings, SpellTranscriber());
      final pr = SessionProcessor(repo, settings, f);
      await pr.process(sid, ProcessingMode.free, (_, __, ___) {});
      final spell = (await db.select(db.entities).get()).where((e) => e.kind == 'spell').toList();
      expect(spell.map((e) => e.name), contains('Bola de Fogo'));
      final ms = (await db.select(db.mentions).get()).where((m) => m.detail.isNotEmpty).toList();
      expect(ms.any((m) => m.detail == 'Lançado por Bia'), isTrue);
    });

    test('excluir sessão apaga tudo dela e as descobertas órfãs', () async {
      await proc.process(sid, ProcessingMode.free, (_, __, ___) {});
      expect(await db.select(db.segments).get(), isNotEmpty);
      expect(await (db.select(db.entities)..where((e) => e.review.equals('suggested'))).get(), isNotEmpty);
      await repo.deleteSession(sid);
      expect(await repo.session(sid), isNull);
      expect(await db.select(db.segments).get(), isEmpty);
      expect(await db.select(db.mentions).get(), isEmpty);
      expect(await db.select(db.events).get(), isEmpty);
      expect(await repo.notesOf(cid, 'thread'), isEmpty); // ganchos da IA desta sessão
      expect(await (db.select(db.entities)..where((e) => e.review.equals('suggested'))).get(), isEmpty);
    });

    test('excluir sessão mantém entidades já confirmadas', () async {
      await proc.process(sid, ProcessingMode.free, (_, __, ___) {});
      await repo.confirmAll(sid);
      final n = (await db.select(db.entities).get()).length;
      expect(n, greaterThan(0));
      await repo.deleteSession(sid);
      expect((await db.select(db.entities).get()).length, n);
    });

    test('fatos confirmados mexem nos PV e no XP dos heróis (uma vez só)', () async {
      final a = await repo.saveHero(HeroesCompanion.insert(id: newId(), campaignId: cid, name: 'Bram Cascalho', player: const Value('Rafa'), hpCurrent: const Value(20), hpMax: const Value(30)));
      final b = await repo.saveHero(HeroesCompanion.insert(id: newId(), campaignId: cid, name: 'Orquídea', hpCurrent: const Value(10), hpMax: const Value(18)));
      await repo.replaceFacts(cid, sid, const [
        ExtractedFact(kind: 'damage', target: 'Bram Cascalho', side: 'hero', amount: 8),
        ExtractedFact(kind: 'heal', target: 'Orquídea', side: 'hero', amount: 20), // passa do máximo
        ExtractedFact(kind: 'xp', target: 'grupo', side: 'hero', amount: 150),
        ExtractedFact(kind: 'damage', target: 'Verren', side: 'enemy', amount: 30), // inimigo: não mexe nos heróis
      ]);
      await repo.confirmAllFacts(sid);
      await repo.confirmAllFacts(sid); // repetir não aplica de novo
      final ha = (await repo.hero(a))!, hb = (await repo.hero(b))!;
      expect(ha.hpCurrent, 12);
      expect(hb.hpCurrent, 18);
      expect(ha.xp, 150);
      expect(hb.xp, 150);
    });

    test('ajuste manual de PV respeita 0 e o máximo', () async {
      final a = await repo.saveHero(HeroesCompanion.insert(id: newId(), campaignId: cid, name: 'Bram', hpCurrent: const Value(5), hpMax: const Value(30)));
      await repo.adjustHp(a, -10);
      expect((await repo.hero(a))!.hpCurrent, 0);
      await repo.adjustHp(a, 99);
      expect((await repo.hero(a))!.hpCurrent, 30);
    });

    test('excluir sessão pode apagar as descobertas exclusivas e desfazer o combate', () async {
      final hero = await repo.saveHero(HeroesCompanion.insert(id: newId(), campaignId: cid, name: 'Bram', hpCurrent: const Value(20), hpMax: const Value(30)));
      await proc.process(sid, ProcessingMode.free, (_, __, ___) {});
      await repo.replaceFacts(cid, sid, const [
        ExtractedFact(kind: 'damage', target: 'Bram', side: 'hero', amount: 8),
        ExtractedFact(kind: 'xp', target: 'grupo', side: 'hero', amount: 100),
      ]);
      await repo.confirmAll(sid); // entidades viram confirmadas + aplica 8 de dano e 100 XP
      expect((await repo.hero(hero))!.hpCurrent, 12);
      final shared = await repo.saveEntity(EntitiesCompanion.insert(id: newId(), campaignId: cid, kind: 'npc', name: 'Compartilhado', review: const Value('confirmed')));
      final s2 = await repo.createSession(cid);
      await db.into(db.mentions).insert(MentionsCompanion.insert(id: newId(), entityId: shared, sessionId: sid, status: const Value('confirmed')));
      await db.into(db.mentions).insert(MentionsCompanion.insert(id: newId(), entityId: shared, sessionId: s2, status: const Value('confirmed')));
      final pv = await repo.deletionPreview(sid);
      expect(pv.appliedFacts, 2);
      expect(pv.exclusive.any((e) => e.name == 'Compartilhado'), isFalse); // aparece em outra sessão
      expect(pv.exclusive, isNotEmpty);
      await repo.deleteSession(sid, deleteExclusiveEntities: true, revertFacts: true);
      final left = await db.select(db.entities).get();
      expect(left.map((e) => e.name), ['Compartilhado']);
      final h = (await repo.hero(hero))!;
      expect(h.hpCurrent, 20); // dano desfeito
      expect(h.xp, 0); // XP desfeito
    });

    test('itens do inventário do herói não aparecem na enciclopédia nem contam como descobertas', () async {
      final hero = await repo.saveHero(HeroesCompanion.insert(id: newId(), campaignId: cid, name: 'Cristina'));
      for (final it in ['Bordão', 'Funda', 'Poção de cura']) {
        await repo.addHeroItem(cid, hero, it);
      }
      await repo.saveEntity(EntitiesCompanion.insert(id: newId(), campaignId: cid, kind: 'npc', name: 'Verren', review: const Value('confirmed')));
      final enc = await repo.watchEntities(cid).first;
      expect(enc.map((e) => e.name), ['Verren']);
      expect((await repo.watchAllEntities(cid).first).map((e) => e.name), ['Verren']);
      expect((await repo.knownEntities(cid)).map((k) => k.name), ['Verren']); // a IA também não recebe o inventário
      expect(await repo.watchHeroItems(hero).first, hasLength(3)); // mas o herói continua com os itens
    });

    test('entradas sem sessão são detectadas (inventário de herói não conta)', () async {
      final hero = await repo.saveHero(HeroesCompanion.insert(id: newId(), campaignId: cid, name: 'Bram'));
      await repo.addHeroItem(cid, hero, 'Espada'); // pertence a um herói: não é órfã
      final solta = await repo.saveEntity(EntitiesCompanion.insert(id: newId(), campaignId: cid, kind: 'npc', name: 'Sobrou', review: const Value('confirmed')));
      final ligada = await repo.saveEntity(EntitiesCompanion.insert(id: newId(), campaignId: cid, kind: 'npc', name: 'Ligada', review: const Value('confirmed')));
      await db.into(db.mentions).insert(MentionsCompanion.insert(id: newId(), entityId: ligada, sessionId: sid, status: const Value('confirmed')));
      final o = await repo.orphanEntities(cid);
      expect(o.map((e) => e.name), ['Sobrou']);
      await repo.deleteEntity(solta);
      expect(await repo.orphanEntities(cid), isEmpty);
    });

    test('segredos: marcar revelado e remover', () async {
      await repo.addNote(cid, 'secret', 'O prefeito é um lobisomem');
      var n = (await repo.notesOf(cid, 'secret')).single;
      expect(n.status, 'open');
      await repo.setNoteStatus(n.id, 'done');
      n = (await repo.notesOf(cid, 'secret')).single;
      expect(n.status, 'done');
      await repo.deleteNote(n.id);
      expect(await repo.notesOf(cid, 'secret'), isEmpty);
    });

    test('ligações: não duplica, move na mesclagem e some ao excluir', () async {
      final a = await repo.saveEntity(EntitiesCompanion.insert(id: newId(), campaignId: cid, kind: 'npc', name: 'Verren', review: const Value('confirmed')));
      final b = await repo.saveEntity(EntitiesCompanion.insert(id: newId(), campaignId: cid, kind: 'location', name: 'Pedraalta', review: const Value('confirmed')));
      final c = await repo.saveEntity(EntitiesCompanion.insert(id: newId(), campaignId: cid, kind: 'npc', name: 'Verren o capitão', review: const Value('confirmed')));
      await repo.ensureRelation(cid, a, b, 'vive em');
      await repo.ensureRelation(cid, a, b, 'vive em');
      expect((await db.select(db.relations).get()).length, 1);
      await repo.mergeEntities(a, c);
      final r = (await db.select(db.relations).get()).single;
      expect(r.fromId, c);
      await repo.deleteEntity(b);
      expect(await db.select(db.relations).get(), isEmpty);
    });

    test('recap dos jogadores não vaza segredos nem ganchos', () async {
      await proc.process(sid, ProcessingMode.free, (_, __, ___) {});
      await repo.confirmAll(sid);
      await repo.addNote(cid, 'secret', 'SEGREDO-DO-MESTRE');
      final d = ExportData((await repo.campaign(cid))!, await repo.sessionsOf(cid), await repo.entitiesOf(cid),
          await db.select(db.mentions).get(), await db.select(db.events).get(), (_) => []);
      final md = playerRecapMarkdown(d);
      expect(md, contains('curto'));
      expect(md, isNot(contains('SEGREDO-DO-MESTRE')));
      expect(md, isNot(contains('Quem enviou os recrutas?')));
    });

    test('estimativa: grátis custa zero', () async {
      final e = await proc.estimate(sid, ProcessingMode.free);
      expect(e.usd, 0);
      await settings.setEngine('claude'); // IA paga: estimativa passa a ter custo
      final p = await proc.estimate(sid, ProcessingMode.premium);
      expect(p.usd, greaterThan(0));
    });

    test('sessão só com texto colado processa sem áudio', () async {
      final sid3 = await repo.createSession(cid);
      await repo.insertSegments(sid3, parseTranscriptText('[00:01] Aldo chegou em Valdoria.\n[00:09] Ele aceitou a missão.'));
      await proc.process(sid3, ProcessingMode.free, (_, __, ___) {});
      expect(tr.calls, 0);
      expect((await repo.session(sid3))!.status, 'review');
    });

    test('exporta markdown, discord e obsidian', () async {
      await proc.process(sid, ProcessingMode.free, (_, __, ___) {});
      await repo.confirmAll(sid);
      final sessions = await repo.sessionsOf(cid);
      final ents = await repo.entitiesOf(cid);
      final ments = await db.select(db.mentions).get();
      final evs = await db.select(db.events).get();
      final segs = await repo.segmentsOf(sid);
      final d = ExportData((await repo.campaign(cid))!, sessions, ents, ments, evs, (_) => segs);
      final md = sessionMarkdown(d, sessions.first, transcript: true);
      expect(md, contains('## Resumo'));
      expect(md, contains('Transcrição'));
      final vault = obsidianVault(d);
      expect(vault.keys.any((k) => k.startsWith('NPCs/')), isTrue);
      expect(vault.values.any((v) => v.contains('[[')), isTrue);
      expect(discordMessages(d, sessions.first).every((m) => m.length <= 2000), isTrue);
    });

    test('perguntas: recupera trecho com sessão e horário', () async {
      await proc.process(sid, ProcessingMode.free, (_, __, ___) {});
      final sessions = await repo.sessionsOf(cid);
      final ps = retrievePassages('Quem era o ferreiro de Valdoria?', sessions, {sid: await repo.segmentsOf(sid)});
      expect(ps, isNotEmpty);
      expect(ps.first.text.toLowerCase(), contains('ferreiro'));
      expect(ps.first.sessionNumber, 1);
    });

    test('busca no texto da transcrição', () async {
      await proc.process(sid, ProcessingMode.free, (_, __, ___) {});
      expect((await repo.searchSegments(sid, 'ferreiro')), isNotEmpty);
    });
  });
}

// ---- Fichas (Fase 1: PDF digital/OCR) ----
void sheetTests() {
  group('ficha D&D 5e', () {
    const txt = '''
Nome do Personagem
Thorin Pedrarrubra
Classe e Nível
Guerreiro 5
Raça
Anão
Nome do Jogador: Maria
FOR 16
DES
12
CON 15
Pontos de Vida: 44
Classe de Armadura 18
Equipamento
Espada longa
Escudo
Poção de cura

Histórico
''';
    test('lê campos principais', () {
      final f = parseSheetText(txt, 'D&D 5e');
      expect(f.name, 'Thorin Pedrarrubra');
      expect(f.heroClass, 'Guerreiro');
      expect(f.level, 5);
      expect(f.race, 'Anão');
      expect(f.player, 'Maria');
      expect(f.extra['FOR'], '16');
      expect(f.extra['DES'], '12');
      expect(f.extra['PV'], '44');
      expect(f.items, containsAll(['Espada longa', 'Escudo']));
    });
    test('sistema não suportado -> texto cru em notas', () {
      final f = parseSheetText(txt, 'Call of Cthulhu');
      expect(f.supportedSystem, isFalse);
      expect(f.notes, contains('Thorin'));
      expect(f.name, isEmpty);
    });
    test('diff campo a campo ao subir de nível', () {
      final inc = parseSheetText(txt.replaceFirst('Guerreiro 5', 'Guerreiro 6'), 'D&D 5e');
      final d = diffSheet(name: 'Thorin Pedrarrubra', player: 'Maria', heroClass: 'Guerreiro', race: 'Anão', level: 5, story: '', extra: {'FOR': '16'}, items: ['Espada longa'], incoming: inc);
      expect(d.any((x) => x.field == 'level' && x.newValue == '6'), isTrue);
      expect(d.any((x) => x.field == 'extra:FOR'), isFalse);
      expect(d.any((x) => x.field.startsWith('item:Escudo')), isTrue);
      expect(d.any((x) => x.field == 'item:Espada longa'), isFalse);
    });
  });
}

void transcriptImportTests() {
  group('importar texto transcrito', () {
    test('linhas com [mm:ss] e falante', () {
      final r = parseTranscriptText('[00:05] Mestre: Vocês entram na taverna.\n[01:10] Ana: Eu olho em volta.');
      expect(r.length, 2);
      expect(r[0].startMs, 5000);
      expect(r[0].speaker, 'Mestre');
      expect(r[1].startMs, 70000);
    });
    test('SRT', () {
      final r = parseTranscriptText('1\n00:00:01,000 --> 00:00:04,500\nOlá, aventureiros.\n\n2\n00:00:05,000 --> 00:00:08,000\nA porta range.');
      expect(r.length, 2);
      expect(r[0].endMs, 4500);
      expect(r[1].text, 'A porta range.');
    });
    test('texto corrido ganha horários estimados em ordem', () {
      final r = parseTranscriptText('O grupo chegou à vila. Aldo falou com o ferreiro. Tudo acabou bem.');
      expect(r.length, 3);
      expect(r[1].startMs, greaterThan(r[0].startMs));
    });
    test('vazio', () => expect(parseTranscriptText('  \n '), isEmpty));
  });

  group('limites por IA', () {
    DioException err429(String body, {String? retryAfter}) => DioException(
          requestOptions: RequestOptions(path: '/x'),
          response: Response(
            requestOptions: RequestOptions(path: '/x'),
            statusCode: 429,
            data: {'error': {'message': body}},
            headers: Headers.fromMap({if (retryAfter != null) 'retry-after': [retryAfter]}),
          ),
        );

    test('cada IA tem limites próprios (Groq bem menor que Gemini)', () {
      expect(limitsFor('groq').chunkTokens, lessThan(limitsFor('gemini').chunkTokens));
      expect(limitsFor('groq').minGap, greaterThan(Duration.zero));
      expect(limitsFor('local').knownMax, lessThan(limitsFor('claude').knownMax));
    });

    test('espera curta só para limite por minuto', () async {
      expect(await shortRateLimitWait(err429('Rate limit', retryAfter: '5')), const Duration(seconds: 5));
      expect(await shortRateLimitWait(err429('Rate limit reached (TPD) per day')), isNull);
      expect(await shortRateLimitWait(err429('x', retryAfter: '600')), isNull);
    });

    test('retrying espera e repete após 429 por minuto', () async {
      var calls = 0;
      final r = await retrying(() async {
        calls++;
        if (calls == 1) throw err429('Rate limit', retryAfter: '0');
        return 'ok';
      });
      expect(r, 'ok');
      expect(calls, 2);
    });

    test('transcrição longa é dividida conforme a IA', () {
      final text = List.generate(400, (i) => '[00:${i.toString().padLeft(2, '0')}] ' + 'palavra ' * 25).join('\n');
      expect(chunkTranscript(text, limitsFor('groq').chunkTokens).length, greaterThan(chunkTranscript(text, limitsFor('gemini').chunkTokens).length));
    });
  });

  test('relatório de capacidades vai e volta do armazenamento', () {
    final m = {'text': const CapResult(true, 'qwen', 'Funciona'), 'vision': const CapResult(false, null, 'sem modelo')};
    final back = capsFromJson(capsToJson(m));
    expect(back['text']!.ok, isTrue);
    expect(back['text']!.model, 'qwen');
    expect(back['vision']!.ok, isFalse);
    expect(back['voice'], isNull);
    expect(capsFromJson('lixo'), isEmpty);
  });
}
