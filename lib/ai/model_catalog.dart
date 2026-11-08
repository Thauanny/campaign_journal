import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'quota.dart';
import 'retry.dart';

/// Situação de custo de um modelo.
enum FreeLevel { free, check, paid }

class ModelOption {
  final String id;
  final String label;
  final FreeLevel level;
  final String note;
  final String? size; // modelos locais
  final bool installed; // modelos locais
  const ModelOption(this.id, this.label, this.level, this.note, {this.size, this.installed = false});
}

const _geminiSkip = ['embedding', 'imagen', 'veo', 'tts', 'image', 'live', 'native-audio', 'robotics', 'computer-use', 'aqa', 'learnlm', 'gemma'];

double _ver(String n) {
  final m = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(n);
  return m == null ? 0 : double.tryParse(m.group(1)!) ?? 0;
}

/// Modelos de texto/voz que a chave do Gemini pode usar. A API não informa
/// preço: Flash/Flash-Lite entram no plano gratuito; Pro e outros variam, por
/// isso são marcados "verificar" até você testar.
Future<List<ModelOption>> listGeminiModels(Dio dio, String key) async {
  final r = await dio.get('https://generativelanguage.googleapis.com/v1beta/models',
      queryParameters: {'pageSize': 200}, options: Options(headers: {'x-goog-api-key': key}));
  final out = <ModelOption>[];
  for (final m in (r.data['models'] as List? ?? const [])) {
    final methods = (m['supportedGenerationMethods'] as List? ?? const []);
    final id = (m['name'] as String).replaceFirst('models/', '');
    if (!methods.contains('generateContent') || !id.startsWith('gemini-')) continue;
    if (_geminiSkip.any(id.contains)) continue;
    final flash = id.contains('flash');
    final preview = id.contains('preview') || id.contains('exp');
    out.add(ModelOption(
      id,
      (m['displayName'] as String?) ?? id,
      flash ? FreeLevel.free : FreeLevel.check,
      flash
          ? 'Plano gratuito, com limite diário${preview ? ' (prévia: pode mudar)' : ''}'
          : 'A cota grátis varia — toque em TESTAR',
    ));
  }
  out.sort((a, b) {
    final fa = a.level == FreeLevel.free ? 0 : 1, fb = b.level == FreeLevel.free ? 0 : 1;
    if (fa != fb) return fa.compareTo(fb);
    final pa = a.id.contains('preview') || a.id.contains('exp') ? 1 : 0, pb = b.id.contains('preview') || b.id.contains('exp') ? 1 : 0;
    if (pa != pb) return pa.compareTo(pb);
    return _ver(b.id).compareTo(_ver(a.id));
  });
  return out;
}

/// Modelos do Groq: [audio] = Whisper; senão os de texto. Todo o catálogo está
/// disponível no plano gratuito, com limites por minuto/dia.
Future<List<ModelOption>> listGroqModels(Dio dio, String key, {required bool audio}) async {
  final r = await dio.get('https://api.groq.com/openai/v1/models', options: Options(headers: {'Authorization': 'Bearer $key'}));
  final out = <ModelOption>[];
  for (final m in (r.data['data'] as List? ?? const [])) {
    final id = m['id'] as String;
    final isWhisper = id.contains('whisper');
    if (isWhisper != audio) continue;
    if (!audio && ['guard', 'tts', 'playai', 'orpheus', 'safeguard'].any(id.contains)) continue;
    if (m['active'] == false) continue;
    final ctx = m['context_window'];
    out.add(ModelOption(id, id, FreeLevel.free,
        'Plano gratuito, com limite por minuto e por dia${ctx != null ? ' · contexto $ctx' : ''}'));
  }
  int rank(String id) {
    if (audio) return id.contains('turbo') ? 0 : 1;
    const pref = ['gpt-oss-120b', 'llama-3.3-70b', 'qwen', 'gpt-oss-20b', 'llama'];
    final i = pref.indexWhere(id.contains);
    return i < 0 ? pref.length : i;
  }
  out.sort((a, b) {
    final c = rank(a.id).compareTo(rank(b.id));
    return c != 0 ? c : b.id.compareTo(a.id);
  });
  return out;
}

final Map<String, String> _groqDefaults = {};

const _probePng = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';
final Map<String, String?> _groqVision = {};

/// Modelo do Groq que lê imagens. A lista de modelos do Groq NÃO informa se o
/// modelo enxerga, e os nomes enganam (ex.: Qwen novos leem imagens), então o app
/// PROVA: manda uma imagem mínima a cada modelo de texto da conta, os mais
/// prováveis primeiro, e usa o primeiro que aceitar. Nulo se nenhum aceitar.
Future<String?> groqVisionModel(Dio dio, String key, {bool refresh = false}) async {
  final ck = '${key.hashCode}';
  if (!refresh && _groqVision.containsKey(ck)) return _groqVision[ck];
  String? found;
  try {
    final r = await dio.get('https://api.groq.com/openai/v1/models', options: Options(headers: {'Authorization': 'Bearer $key'}));
    final ids = [
      for (final m in (r.data['data'] as List? ?? const []))
        if (m['active'] != false) m['id'] as String
    ].where((i) => !['whisper', 'guard', 'tts', 'playai', 'orpheus', 'safeguard', 'allam', 'embed'].any(i.contains)).toList();
    int rank(String i) {
      const pref = ['llama-4', 'qwen', 'vision', 'gemma', 'gpt-oss'];
      final k = pref.indexWhere(i.contains);
      return k < 0 ? pref.length : k;
    }
    ids.sort((a, b) => rank(a).compareTo(rank(b)));
    for (final id in ids.take(8)) {
      try {
        await dio.post('https://api.groq.com/openai/v1/chat/completions',
            options: Options(headers: {'Authorization': 'Bearer $key'}, receiveTimeout: const Duration(seconds: 45)),
            data: {
              'model': id,
              'max_tokens': 4,
              'messages': [
                {'role': 'user', 'content': [{'type': 'text', 'text': 'ok?'}, {'type': 'image_url', 'image_url': {'url': 'data:image/png;base64,$_probePng'}}]}
              ]
            });
        found = id;
        break;
      } on DioException catch (e) {
        if (e.response?.statusCode == 429) break; // sem fôlego agora: não conclui nada
        // 400/404: este modelo não lê imagens; tenta o próximo
      }
    }
    if (found == null && ids.isNotEmpty) _groqVision[ck] = null;
    if (found != null) _groqVision[ck] = found;
  } catch (_) {}
  return found;
}

/// Modelo do Groq a usar: o escolhido ou, sem escolha, o PRIMEIRO da lista da
/// própria conta (assim nunca cai num modelo que a conta não tem).
Future<String> resolveGroqModel(Dio dio, String key, {String? override, required bool audio, required String fallback}) async {
  if (override != null && override.trim().isNotEmpty) return override.trim();
  final ck = '${audio ? 'a' : 't'}:${key.hashCode}';
  final cached = _groqDefaults[ck];
  if (cached != null) return cached;
  try {
    final list = await listGroqModels(dio, key, audio: audio);
    if (list.isNotEmpty) return _groqDefaults[ck] = list.first.id;
  } catch (_) {}
  return fallback;
}

/// Gera ~1,5 s de silêncio em WAV (16 kHz, mono) para testar a transcrição.
List<int> _silentWav() {
  const rate = 16000, secs = 1.5;
  final n = (rate * secs).round();
  final data = n * 2;
  final b = BytesBuilder();
  void s(String t) => b.add(t.codeUnits);
  void i32(int v) => b.add([v & 255, (v >> 8) & 255, (v >> 16) & 255, (v >> 24) & 255]);
  void i16(int v) => b.add([v & 255, (v >> 8) & 255]);
  s('RIFF'); i32(36 + data); s('WAVE'); s('fmt '); i32(16); i16(1); i16(1); i32(rate); i32(rate * 2); i16(2); i16(16); s('data'); i32(data);
  b.add(List.filled(data, 0));
  return b.toBytes();
}

/// Testa a transcrição de voz do [engine] com um áudio mínimo. Devolve `null`
/// se funcionou ou a mensagem do problema.
Future<String?> testVoiceModel(Dio dio, String engine, String key, String model) async {
  try {
    final wav = _silentWav();
    if (engine == 'gemini') {
      await retrying(() => dio.post('https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent',
          options: Options(headers: {'x-goog-api-key': key, 'Content-Type': 'application/json'}, receiveTimeout: const Duration(seconds: 90)),
          data: {
            'contents': [
              {
                'parts': [
                  {'text': 'Transcreva este áudio. Se for silêncio, responda apenas: (silêncio)'},
                  {'inline_data': {'mime_type': 'audio/wav', 'data': base64Encode(wav)}},
                ]
              }
            ],
          }));
    } else {
      final base = engine == 'groq' ? 'https://api.groq.com/openai/v1' : 'https://api.openai.com/v1';
      await dio.post('$base/audio/transcriptions',
          data: FormData.fromMap({'model': model, 'file': MultipartFile.fromBytes(wav, filename: 'teste.wav')}),
          options: Options(headers: {'Authorization': 'Bearer $key'}, receiveTimeout: const Duration(seconds: 60)));
    }
    return null;
  } on DioException catch (e) {
    final q = await quotaFrom(e, engine);
    return q != null ? q.message : _explain(e);
  }
}

/// Testa um modelo de texto com uma chamada mínima. Devolve `null` se funcionou
/// ou a mensagem do problema (incluindo "sem cota grátis").
Future<String?> testTextModel(Dio dio, String engine, String key, String model, {bool allowFallback = false, List<Duration>? delays}) async {
  try {
    await (delays == null ? retrying(() => _ping(dio, engine, key, model)) : retrying(() => _ping(dio, engine, key, model), delays: delays));
    return null;
  } on DioException catch (e) {
    // Chave válida mas modelo sobrecarregado: tenta o modelo lite só para validar a chave.
    if (allowFallback && engine == 'gemini' && isTransient(e) && model != 'gemini-flash-lite-latest') {
      return testTextModel(dio, engine, key, 'gemini-flash-lite-latest', delays: delays);
    }
    final q = await quotaFrom(e, engine);
    return q != null ? q.message : _explain(e);
  }
}

Future<void> _ping(Dio dio, String engine, String key, String model) async {
  if (engine == 'gemini') {
    // Mesma chamada do exemplo oficial (curl). Para só testar a chave, desliga o
    // "pensamento" do modelo (no seu teste ele gastou 347 tokens pensando para
    // responder 14). Se o modelo recusar esse ajuste (400), repete sem ele.
    Future<void> call(bool noThinking) => dio.post('https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent',
        options: Options(headers: {'x-goog-api-key': key, 'Content-Type': 'application/json'}, receiveTimeout: const Duration(seconds: 90)),
        data: {
          'contents': [
            {'parts': [{'text': 'Responda apenas: ok'}]}
          ],
          if (noThinking) 'generationConfig': {'thinkingConfig': {'thinkingBudget': 0}},
        });
    try {
      await call(true);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        await call(false);
      } else {
        rethrow;
      }
    }
  } else {
    await dio.post('https://api.groq.com/openai/v1/chat/completions',
        options: Options(headers: {'Authorization': 'Bearer $key'}, receiveTimeout: const Duration(seconds: 60)),
        data: {'model': model, 'max_tokens': 4, 'messages': [{'role': 'user', 'content': 'ok'}]});
  }
}

/// Mensagem amigável para um erro HTTP de teste.
String explainDio(DioException e) => _explain(e);

String _explain(DioException e) {
  final c = e.response?.statusCode;
  if (e.type == DioExceptionType.receiveTimeout || e.type == DioExceptionType.connectionTimeout) {
    return 'O servidor demorou demais para responder. Tente de novo ou escolha outro modelo na lista.';
  }
  if (e.type == DioExceptionType.connectionError) return 'Sem conexão com a internet (ou o servidor está inacessível).';
  if (c == 503 || c == 500 || c == 504) {
    return 'O servidor do Google está sobrecarregado agora (erro $c). É temporário e não é problema da sua chave — o app já tentou de novo. Tente em alguns minutos ou teste outro modelo.';
  }
  if (c == 429) return 'Sem cota gratuita para este modelo agora (limite por minuto/dia atingido ou zerado).';
  if (c == 404) return 'Modelo indisponível para esta chave (pode ter sido desligado para contas novas).';
  if (c == 400) return 'Pedido recusado (400). A chave pode estar incorreta ou incompleta.';
  if (c == 401 || c == 403) return 'A chave não tem permissão para este modelo.';
  return 'Falhou${c != null ? ' ($c)' : ''}: ${e.message}';
}

// ───────────── Local ─────────────

/// Modelos do Ollama sugeridos (todos gratuitos; rodam no seu computador).
const ollamaCatalog = [
  ModelOption('qwen2.5:7b', 'Qwen 2.5 · 7B', FreeLevel.free, 'Bom em português. Recomendado.', size: '4,7 GB'),
  ModelOption('llama3.1:8b', 'Llama 3.1 · 8B', FreeLevel.free, 'Equilibrado e popular.', size: '4,9 GB'),
  ModelOption('gemma2:9b', 'Gemma 2 · 9B', FreeLevel.free, 'Boa escrita; pede mais memória.', size: '5,4 GB'),
  ModelOption('mistral:7b', 'Mistral · 7B', FreeLevel.free, 'Rápido; português razoável.', size: '4,1 GB'),
  ModelOption('qwen2.5:3b', 'Qwen 2.5 · 3B', FreeLevel.free, 'Leve, para computador modesto. Qualidade menor.', size: '1,9 GB'),
  ModelOption('llama3.2:3b', 'Llama 3.2 · 3B', FreeLevel.free, 'Leve. Qualidade menor.', size: '2,0 GB'),
];

/// Modelos de voz do whisper.cpp (arquivos ggml). Gratuitos.
const whisperCatalog = [
  ModelOption('tiny', 'Whisper tiny', FreeLevel.free, 'Muito rápido; erra bastante nomes.', size: '75 MB'),
  ModelOption('base', 'Whisper base', FreeLevel.free, 'Rápido; qualidade básica.', size: '142 MB'),
  ModelOption('small', 'Whisper small', FreeLevel.free, 'Bom equilíbrio. Recomendado.', size: '466 MB'),
  ModelOption('medium', 'Whisper medium', FreeLevel.free, 'Melhor com nomes de fantasia; mais lento.', size: '1,5 GB'),
  ModelOption('large-v3-turbo', 'Whisper large-v3 turbo', FreeLevel.free, 'Melhor qualidade; precisa de bom computador.', size: '1,6 GB'),
];

String whisperFileName(String name) => 'ggml-$name.bin';
String whisperDownloadUrl(String name) => 'https://huggingface.co/ggerganov/whisper.cpp/resolve/main/${whisperFileName(name)}';

/// Nomes dos modelos já baixados no Ollama.
Future<Set<String>> ollamaInstalled(Dio dio, String baseUrl) async {
  try {
    final r = await dio.get('$baseUrl/api/tags', options: Options(receiveTimeout: const Duration(seconds: 3)));
    return {for (final m in (r.data['models'] as List? ?? const [])) (m['name'] ?? '').toString()};
  } catch (_) {
    return {};
  }
}
