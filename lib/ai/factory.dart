import 'package:dio/dio.dart';

import '../core/engines.dart';
import '../core/settings.dart';
import '../core/setup_service.dart';
import '../domain/models.dart';
import 'activity.dart';
import 'capabilities.dart';
import 'gemini_models.dart';
import 'interfaces.dart';
import 'llm_adapters.dart';
import 'model_catalog.dart';
import 'local_heuristic.dart';
import 'transcribers.dart';

class ModeConfig {
  final Transcriber transcriber;
  final TextModel extractor;
  final TextModel summarizer;
  final String extractModel;
  final String summarizeModel;
  final bool cloudTranscribe;
  const ModeConfig(this.transcriber, this.extractor, this.summarizer,
      this.extractModel, this.summarizeModel, this.cloudTranscribe);
}

/// A IA ativa ainda não está pronta (não escolhida, sem chave ou sem ferramenta).
class SetupRequired extends ProviderException {
  final String needs; // 'text' | 'audio'
  SetupRequired(this.needs, String message) : super(message);
}

class ProviderFactory {
  final Settings settings;
  final Dio dio;
  ProviderFactory(this.settings, this.dio);

  Future<String> _key(String provider, String engineName) async {
    final key = await settings.apiKey(provider);
    if (key == null) {
      throw SetupRequired('text', settings.keyFlag(provider)
          ? 'A chave de "$engineName" está salva, mas o chaveiro do sistema não a liberou. No Mac, aprove o acesso quando aparecer a janela do chaveiro e tente de novo; se persistir, cole a chave de novo em Configurações > IA.'
          : 'A IA "$engineName" está sem chave. Abra Configurações > IA e cole a chave.');
    }
    return key;
  }

  /// Modelo de texto da IA em nuvem [id]; [paidModel] vem da tabela de preços.
  Future<TextModel> _cloudText(String id, {String? paidModel}) async {
    final info = engineById(id)!;
    final key = await _key(id, info.name);
    switch (id) {
      case 'gemini':
        return GeminiText(dio, key, await resolveGeminiModel(dio, key, override: settings.modelFor('gemini')));
      case 'groq':
        return OpenAiText.groq(dio, key, await resolveGroqModel(dio, key, override: settings.modelFor('groq'), audio: false, fallback: info.textModel!));
      case 'openai':
        return OpenAiText(dio, key, paidModel ?? 'gpt-4o-mini');
      case 'claude':
        return ClaudeText(dio, key, paidModel ?? 'claude-sonnet-5-5');
    }
    throw ProviderException('IA desconhecida: $id');
  }

  Future<Transcriber?> _cloudAudio(String id, String key) async => switch (id) {
        'gemini' => GeminiTranscriber(dio, key, await resolveGeminiModel(dio, key, override: settings.modelFor('gemini'))),
        'groq' => OpenAiTranscriber.groq(dio, key, model: await resolveGroqModel(dio, key, override: settings.modelFor('groq_audio'), audio: true, fallback: 'whisper-large-v3-turbo')),
        'openai' => OpenAiTranscriber(dio, key),
        _ => null,
      };

  Future<Transcriber?> _localWhisper() async {
    final svc = SetupService(settings, dio);
    final bin = await Tools.find('whisper-cli', custom: settings.whisperBinary);
    final ffmpeg = await Tools.find('ffmpeg');
    final model = await svc.whisperModelPath();
    if (bin == null || ffmpeg == null || model.isEmpty) return null;
    return WhisperLocalTranscriber(bin, model);
  }

  Future<Transcriber?> _directAudio(String id) async {
    final key = await settings.apiKey(id);
    return key == null ? null : await _cloudAudio(id, key);
  }

  /// Voz para texto da IA ativa. Claude e "Sem IA" não ouvem áudio: usam a
  /// primeira outra IA com chave, ou o Whisper local.
  Future<Transcriber> _transcriber(String engine) async {
    if (engine == 'local') {
      final w = await _localWhisper();
      if (w != null) return w;
      throw SetupRequired('audio', 'O Whisper local não está pronto. Abra Configurações > IA para instalar.');
    }
    // A IA escolhida vem primeiro; só se ela não ouve áudio (ou está sem chave)
    // o app procura outra, preferindo as que medem os horários (Whisper).
    final order = <String>[
      if (const {'gemini', 'groq', 'openai'}.contains(engine)) engine,
      'groq',
      'openai',
      'gemini',
    ];
    for (final id in order) {
      // A verificação da conta já mostrou que esta IA não transcreve: pula.
      final vc = capsFromJson(settings.capsJson(id))['voice'];
      if (vc != null && !vc.ok) continue;
      final t = await _directAudio(id);
      if (t != null) {
        if (id != engine && engine != 'claude' && engine != 'none') {
          Activity.log('${engineById(engine)?.name ?? engine} não ouve áudio neste caso: usando ${engineById(id)?.name ?? id} só para a transcrição.');
        }
        return t;
      }
    }
    final w = await _localWhisper();
    if (w != null) return w;
    throw SetupRequired('audio',
        'A IA escolhida não ouve áudio e não há outra com chave. Cole um texto transcrito ou ative Gemini/Groq em Configurações > IA.');
  }

  String? _paidModel(PricingTable pricing, String engine) =>
      settings.engineIsPaid ? (pricing.raw['defaults']['balanced'] as Map)[engine] as String? : null;

  /// Monta os adaptadores da IA ativa — a mesma para voz, extração, resumo e
  /// perguntas. O parâmetro [mode] existe só por compatibilidade.
  Future<ModeConfig> forMode(ProcessingMode mode, {bool needTranscriber = true}) async {
    final engine = settings.engine;
    if (engine == null) {
      throw SetupRequired('text', 'Nenhuma IA escolhida. Abra Configurações > IA e escolha uma.');
    }
    if (engine == 'none') {
      final t = LocalHeuristicText();
      final tr = needTranscriber ? await _transcriber(engine) : _NoTranscriber();
      return ModeConfig(tr, t, t, 'free:heuristic', 'free:heuristic', false);
    }
    if (engine == 'local') {
      final st = await SetupService(settings, dio).ollamaStatus();
      if (!st.ready) {
        throw SetupRequired('text', 'O Ollama não está pronto (ligado e com o modelo ${settings.ollamaModel}). Abra Configurações > IA.');
      }
      final t = OllamaText(dio, settings.ollamaModel, baseUrl: settings.ollamaUrl);
      final tr = needTranscriber ? await _transcriber(engine) : _NoTranscriber();
      return ModeConfig(tr, t, t, 'free:${settings.ollamaModel}', 'free:${settings.ollamaModel}', false);
    }
    // nuvem: gemini | groq | openai | claude
    final pricing = await settings.pricing();
    final paid = _paidModel(pricing, engine);
    final em = settings.modelFor('extract') ?? paid;
    final sm = settings.modelFor('summarize') ?? paid;
    final ext = await _cloudText(engine, paidModel: em);
    final sum = em == sm ? ext : await _cloudText(engine, paidModel: sm);
    final tr = needTranscriber ? await _transcriber(engine) : _NoTranscriber();
    final isFree = !settings.engineIsPaid;
    final tag = engineById(engine)!.textModel;
    return ModeConfig(tr, ext, sum, isFree ? 'free:$tag' : (em ?? ''), isFree ? 'free:$tag' : (sm ?? ''),
        !isFree && tr.needsNetwork);
  }

  Future<bool> _ollamaUp() async {
    try {
      await dio.get('${settings.ollamaUrl}/api/tags',
          options: Options(receiveTimeout: const Duration(seconds: 2), sendTimeout: const Duration(seconds: 2)));
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Modelo de texto livre (perguntas à campanha) com a IA ativa.
  Future<JsonTextModel> chatModel() async {
    final engine = settings.engine;
    if (engine == null || engine == 'none') {
      throw ProviderException('Perguntas precisam de uma IA. Escolha uma em Configurações > IA.');
    }
    if (engine == 'local') {
      if (await _ollamaUp()) return BudgetedText(OllamaText(dio, settings.ollamaModel, baseUrl: settings.ollamaUrl), limitsFor('local').contextChars);
      throw ProviderException('O Ollama não está respondendo em ${settings.ollamaUrl}.');
    }
    final pricing = await settings.pricing();
    final m = await _cloudText(engine, paidModel: _paidModel(pricing, engine)) as JsonTextModel;
    return BudgetedText(m, limitsFor(engine).contextChars);
  }

  /// Teste de voz: manda um áudio mínimo ao transcritor da IA [provider].
  Future<String> testVoice(String provider) async {
    final key = await settings.apiKey(provider);
    if (key == null) throw ProviderException('A chave não foi guardada. Tente salvar de novo.');
    final model = switch (provider) {
      'gemini' => await resolveGeminiModel(dio, key, override: settings.modelFor('gemini')),
      'groq' => await resolveGroqModel(dio, key, override: settings.modelFor('groq_audio'), audio: true, fallback: 'whisper-large-v3-turbo'),
      'openai' => 'whisper-1',
      _ => throw ProviderException('Esta IA não transcreve voz na nuvem.'),
    };
    final err = await testVoiceModel(dio, provider, key, model);
    if (err != null) throw ProviderException(shortCapNote(err));
    return 'Voz OK ($model)';
  }

  /// Modelo usado nos testes de imagem/documento de [provider].
  Future<String> _visionTestModel(String provider, String key) async {
    switch (provider) {
      case 'gemini':
        return resolveGeminiModel(dio, key, override: settings.modelFor('gemini'));
      case 'groq':
        final m = capsFromJson(settings.capsJson('groq'))['vision']?.model ?? await groqVisionModel(dio, key);
        if (m == null) throw ProviderException('Não coberto pela conta.');
        return m;
      case 'openai':
        return 'gpt-4o-mini';
      case 'claude':
        final pr = await settings.pricing();
        return pr.defaultModel(ProcessingMode.balanced, 'claude');
    }
    throw ProviderException('Esta IA não lê imagens na nuvem.');
  }

  /// Teste de imagem ('image') ou documento ('document'): manda um arquivo mínimo.
  Future<String> testMedia(String provider, {required bool document}) async {
    final key = await settings.apiKey(provider);
    if (key == null) throw ProviderException('A chave não foi guardada. Tente salvar de novo.');
    final model = await _visionTestModel(provider, key);
    final err = document ? await testDocumentModel(dio, provider, key, model) : await testVisionModel(dio, provider, key, model);
    if (err != null) throw ProviderException(shortCapNote(err));
    if (document && provider != 'gemini' && provider != 'claude') return 'Documento OK ($model) — via imagens das páginas';
    return '${document ? 'Documento' : 'Imagem'} OK ($model)';
  }

  /// Teste de conexão (tela de IA): uma chamada mínima, com limite de tempo.
  /// Gemini e Groq usam a chamada leve do catálogo (sem tentar duas vezes).
  Future<String> testConnection(String provider) async {
    final key = await settings.apiKey(provider);
    if (key == null) {
      throw ProviderException(settings.keyFlag(provider)
          ? 'O chaveiro do sistema não liberou a chave. No Mac, aprove o acesso na janela do chaveiro e tente de novo.'
          : 'A chave não foi guardada. Tente salvar de novo.');
    }
    if (provider == 'gemini' || provider == 'groq') {
      final model = provider == 'gemini'
          ? await resolveGeminiModel(dio, key, override: settings.modelFor('gemini'))
          : await resolveGroqModel(dio, key, override: settings.modelFor('groq'), audio: false, fallback: engineById('groq')!.textModel!);
      final err = await testTextModel(dio, provider, key, model, allowFallback: true);
      if (err != null) throw ProviderException(err);
      return 'Conexão OK ($model)';
    }
    final pricing = await settings.pricing();
    final paid = (pricing.raw['defaults']['balanced'] as Map)[provider] as String?;
    final m = await _cloudText(provider, paidModel: paid);
    await (m as JsonTextModel).complete('Responda só com JSON.', 'Retorne {"ok":true}').timeout(const Duration(seconds: 30));
    return 'Conexão OK';
  }
}

/// Sessão só com texto (colado/importado): nenhuma transcrição é necessária.
class _NoTranscriber implements Transcriber {
  @override
  String get id => 'none';
  @override
  String get label => 'texto importado';
  @override
  bool get needsNetwork => false;
  @override
  Future<List<TranscriptSegment>> transcribe(String audioPath,
          {String language = 'pt-BR', List<String> vocabularyHints = const [], int offsetMs = 0}) async =>
      throw ProviderException('Sem transcritor: sessão só com texto.');
}
