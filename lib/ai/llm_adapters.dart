import 'dart:convert';

import 'package:dio/dio.dart';

import '../domain/models.dart';
import 'interfaces.dart';
import 'activity.dart';
import 'quota.dart';
import 'retry.dart';
import 'prompts.dart';

/// Base: monta extração/resumo sobre uma função `complete(system, user)`.
/// Valida o JSON e tenta de novo uma vez se vier malformado (plano: pipeline de IA).
abstract class JsonTextModel implements TextModel {
  Future<(String, UsageInfo)> complete(String system, String user,
      {bool json = true});

  Future<(Map<String, dynamic>, UsageInfo)> _json(
      String system, String user) async {
    var in_ = 0, out = 0;
    for (var attempt = 0; attempt < 2; attempt++) {
      final (raw, u) = await complete(
          system,
          attempt == 0
              ? user
              : '$user\n\nSua resposta anterior não era JSON válido. Responda só com o JSON.');
      in_ += u.inputTokens;
      out += u.outputTokens;
      final j = parseJsonObject(raw);
      if (j != null) {
        QuotaCenter.ok(id);
        return (j, UsageInfo(in_, out));
      }
    }
    throw ProviderException('$label devolveu JSON malformado duas vezes.');
  }

  @override
  Future<(ExtractionResult, UsageInfo)> extract(String transcript,
      {required List<KnownEntity> known, String system = ''}) async {
    Activity.log('Lendo a transcrição (${transcript.length} letras) com $label e procurando NPCs, locais, missões, itens e feitiços…');
    final (j, u) = await _json(extractionSystem(known, system),
        'Transcrição:\n$transcript');
    final r = parseExtraction(j);
    Activity.log('A IA encontrou ${r.entities.length} entrada(s) e ${r.events.length} evento(s) nesta parte.');
    return (r, u);
  }

  @override
  Future<(SessionSummary, UsageInfo)> summarize(String transcript,
      {required List<KnownEntity> known, String campaignName = '', String extra = ''}) async {
    Activity.log('Escrevendo a crônica da sessão com $label…');
    final (j, u) = await _json(
        summarySystem(known, campaignName, extra: extra), 'Transcrição:\n$transcript');
    final s = parseSummary(j);
    if (s != null) Activity.log('Crônica pronta (${s.narrative.length} letras, ${s.openThreads.length} gancho(s) em aberto).');
    if (s == null) throw ProviderException('Resumo vazio em $label.');
    return (s, u);
  }
}

String _dioMsg(DioException e) {
  final code = e.response?.statusCode;
  final body = e.response?.data;
  final detail = body is Map ? (body['error'] ?? body).toString() : '';
  if (e.type == DioExceptionType.receiveTimeout || e.type == DioExceptionType.connectionTimeout) {
    return 'O provedor demorou demais para responder e o app já tentou de novo. O modelo pode estar lento ou sobrecarregado: tente mais tarde ou escolha outro modelo/IA em Configurações.';
  }
  if (e.type == DioExceptionType.connectionError) return 'Sem conexão com a internet (ou o provedor está inacessível).';
  if (code == 401 || code == 403) return 'Chave de API recusada ($code).';
  if (code == 429) return 'Limite de uso do plano gratuito atingido (429). Espere um pouco (limite por minuto) ou até amanhã (limite diário), ou escolha outro modelo.';
  if (code == 503 || code == 500 || code == 504) {
    return 'O servidor do provedor está sobrecarregado ou instável agora ($code). É temporário: o app já tentou de novo. Tente mais tarde ou escolha outro modelo/IA.';
  }
  return 'Erro de rede${code != null ? ' ($code)' : ''}: '
      '${detail.isNotEmpty ? detail : e.message}';
}

/// Converte um erro HTTP em exceção amigável (limite de uso ganha aviso e horário).
Future<ProviderException> providerError(DioException e, String provider) async =>
    await quotaFrom(e, provider) ?? ProviderException(_dioMsg(e));

class ClaudeText extends JsonTextModel {
  final Dio dio;
  final String apiKey;
  final String model;
  ClaudeText(this.dio, this.apiKey, this.model);
  @override
  String get id => 'claude';
  @override
  String get label => 'Claude ($model)';
  @override
  bool get needsNetwork => true;

  @override
  Future<(String, UsageInfo)> complete(String system, String user,
      {bool json = true}) async {
    try {
      final r = await retrying(() => dio.post('https://api.anthropic.com/v1/messages',
          options: Options(headers: {
            'x-api-key': apiKey,
            'anthropic-version': '2023-06-01',
          }),
          data: {
            'model': model,
            'max_tokens': 8000,
            // Prompt caching: o contexto da campanha vai num bloco cacheável.
            'system': [
              {
                'type': 'text',
                'text': system,
                'cache_control': {'type': 'ephemeral'}
              }
            ],
            'messages': [
              {'role': 'user', 'content': user}
            ],
          }));
      final d = r.data as Map;
      final text = (d['content'] as List)
          .where((c) => c['type'] == 'text')
          .map((c) => c['text'])
          .join();
      final u = d['usage'] as Map? ?? {};
      return (
        text,
        UsageInfo((u['input_tokens'] ?? 0) as int,
            (u['output_tokens'] ?? 0) as int)
      );
    } on DioException catch (e) {
      throw await providerError(e, id);
    }
  }
}

class OpenAiText extends JsonTextModel {
  final Dio dio;
  final String apiKey;
  final String model;
  final String baseUrl;
  final String _id;
  final String _name;
  OpenAiText(this.dio, this.apiKey, this.model,
      {this.baseUrl = 'https://api.openai.com/v1', String id = 'openai', String name = 'GPT'})
      : _id = id,
        _name = name;

  /// Groq fala o mesmo protocolo da OpenAI.
  factory OpenAiText.groq(Dio dio, String key, String model) => OpenAiText(dio, key, model,
      baseUrl: 'https://api.groq.com/openai/v1', id: 'groq', name: 'Groq');
  @override
  String get id => _id;
  @override
  String get label => '$_name ($model)';
  @override
  bool get needsNetwork => true;

  @override
  Future<(String, UsageInfo)> complete(String system, String user,
      {bool json = true}) async {
    try {
      final r = await retrying(() => dio.post('$baseUrl/chat/completions',
          options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
          data: {
            'model': model,
            if (json) 'response_format': {'type': 'json_object'},
            'messages': [
              {'role': 'system', 'content': system},
              {'role': 'user', 'content': user},
            ],
          }));
      final d = r.data as Map;
      final text = d['choices'][0]['message']['content'] as String;
      final u = d['usage'] as Map? ?? {};
      return (
        text,
        UsageInfo((u['prompt_tokens'] ?? 0) as int,
            (u['completion_tokens'] ?? 0) as int)
      );
    } on DioException catch (e) {
      throw await providerError(e, id);
    }
  }
}

class GeminiText extends JsonTextModel {
  final Dio dio;
  final String apiKey;
  final String model;

  /// Reserva quando o modelo principal está sobrecarregado ou lento.
  static const fallbackModel = 'gemini-flash-lite-latest';

  /// Modelos que recusaram desligar o "pensamento" (lembra para não repetir o erro).
  static final _noThinkingRefused = <String>{};
  GeminiText(this.dio, this.apiKey, this.model);
  @override
  String get id => 'gemini';
  @override
  String get label => 'Gemini ($model)';
  @override
  bool get needsNetwork => true;

  /// Uma chamada em fluxo (SSE): o servidor manda a resposta aos poucos, então o
  /// limite de tempo vale para cada pausa, não para a resposta inteira.
  Future<(String, Map)> _stream(String m, String system, String user, bool json, bool noThinking) async {
    final r = await dio.post<ResponseBody>(
        'https://generativelanguage.googleapis.com/v1beta/models/$m:streamGenerateContent',
        queryParameters: {'alt': 'sse'},
        options: Options(headers: {'x-goog-api-key': apiKey}, responseType: ResponseType.stream, receiveTimeout: const Duration(seconds: 90)),
        data: {
          'systemInstruction': {'parts': [{'text': system}]},
          'contents': [
            {'role': 'user', 'parts': [{'text': user}]}
          ],
          'generationConfig': {
            if (json) 'responseMimeType': 'application/json',
            if (noThinking) 'thinkingConfig': {'thinkingBudget': 0},
          },
        });
    final out = StringBuffer();
    Map usage = {};
    var lastLogged = 0;
    await for (final line in r.data!.stream.cast<List<int>>().transform(utf8.decoder).transform(const LineSplitter())) {
      final text = parseSseLine(line);
      if (text == null) continue;
      out.write(text.$1);
      if (text.$2.isNotEmpty) usage = text.$2;
      if (out.length - lastLogged >= 800) {
        lastLogged = out.length;
        Activity.log('Resposta chegando… ${out.length} letras recebidas.');
      }
    }
    return (out.toString(), usage);
  }

  Future<(String, Map)> _attempt(String m, String system, String user, bool json) async {
    final skip = _noThinkingRefused.contains(m);
    Activity.log('Enviando o pedido ao Gemini ($m)${skip ? '' : ' sem raciocínio extra, para ser mais rápido'}…');
    try {
      return await _stream(m, system, user, json, !skip);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 && !skip) {
        _noThinkingRefused.add(m);
        Activity.log('Este modelo não aceita desligar o raciocínio; repetindo no modo normal…');
        return await _stream(m, system, user, json, false);
      }
      rethrow;
    }
  }

  @override
  Future<(String, UsageInfo)> complete(String system, String user, {bool json = true}) async {
    void onRetry(int n, int total, Duration w, DioException e) =>
        Activity.log('O Gemini não respondeu direito (${e.response?.statusCode ?? 'sem resposta'}). Nova tentativa $n/$total em ${w.inSeconds}s…');
    try {
      (String, Map) r;
      try {
        r = await retrying(() => _attempt(model, system, user, json), onRetry: onRetry);
      } on DioException catch (e) {
        if ((isTransient(e) || e.response?.statusCode == 429) && model != fallbackModel) {
          Activity.log(e.response?.statusCode == 429
              ? 'Limite de uso do modelo principal. Tentando o modelo de reserva ($fallbackModel), que tem cota própria…'
              : 'Modelo principal instável. Trocando para o modelo de reserva ($fallbackModel)…');
          r = await retrying(() => _attempt(fallbackModel, system, user, json), delays: const [Duration(seconds: 3)], onRetry: onRetry);
        } else {
          rethrow;
        }
      }
      final u = r.$2;
      return (r.$1, UsageInfo((u['promptTokenCount'] ?? 0) as int, (u['candidatesTokenCount'] ?? 0) as int));
    } on DioException catch (e) {
      throw await providerError(e, id);
    }
  }
}

/// Lê uma linha SSE ("data: {...}") do Gemini: devolve (texto, uso) ou null se
/// a linha não tem dados. Ignora partes de "pensamento".
(String, Map)? parseSseLine(String line) {
  if (!line.startsWith('data:')) return null;
  try {
    final j = jsonDecode(line.substring(5).trim());
    if (j is! Map) return null;
    final buf = StringBuffer();
    final cands = j['candidates'];
    if (cands is List && cands.isNotEmpty) {
      final parts = (cands[0]['content']?['parts'] as List?) ?? const [];
      for (final p in parts) {
        if (p is Map && p['thought'] != true) buf.write(p['text'] ?? '');
      }
    }
    return (buf.toString(), (j['usageMetadata'] as Map?) ?? const {});
  } catch (_) {
    return null;
  }
}

/// Ollama local (grátis, desktop).
class OllamaText extends JsonTextModel {
  final Dio dio;
  final String baseUrl;
  final String model;
  OllamaText(this.dio, this.model, {this.baseUrl = 'http://localhost:11434'});
  @override
  String get id => 'ollama';
  @override
  String get label => 'Ollama ($model)';
  @override
  bool get needsNetwork => false;

  @override
  Future<(String, UsageInfo)> complete(String system, String user,
      {bool json = true}) async {
    try {
      final r = await dio.post('$baseUrl/api/chat',
          data: {
            'model': model,
            'stream': false,
            // Janela de contexto maior que o padrão (2048), senão a transcrição é cortada.
            'options': {'num_ctx': 8192},
            if (json) 'format': 'json',
            'messages': [
              {'role': 'system', 'content': system},
              {'role': 'user', 'content': user},
            ],
          },
          options: Options(receiveTimeout: const Duration(minutes: 20)));
      final d = r.data as Map;
      return (
        d['message']['content'] as String,
        UsageInfo((d['prompt_eval_count'] ?? 0) as int,
            (d['eval_count'] ?? 0) as int)
      );
    } on DioException catch (e) {
      throw ProviderException(
          'Ollama indisponível em $baseUrl (${e.message}). Ele está rodando?');
    }
  }
}

/// Limita o tamanho do texto enviado (perguntas e planejamento) ao que a IA
/// ativa aguarda de uma vez; a pergunta, no começo, é preservada.
class BudgetedText extends JsonTextModel {
  final JsonTextModel inner;
  final int maxChars;
  BudgetedText(this.inner, this.maxChars);
  @override
  String get id => inner.id;
  @override
  String get label => inner.label;
  @override
  bool get needsNetwork => inner.needsNetwork;
  @override
  Future<(String, UsageInfo)> complete(String system, String user, {bool json = true}) {
    final u = user.length <= maxChars ? user : '${user.substring(0, maxChars)}\n[…contexto cortado para caber no limite da IA]';
    return inner.complete(system, u, json: json);
  }
}
