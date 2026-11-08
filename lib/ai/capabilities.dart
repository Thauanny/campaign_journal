import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'gemini_models.dart';
import 'model_catalog.dart';
import 'quota.dart';
import 'retry.dart';

/// Resultado de um teste de capacidade de uma IA.
class CapResult {
  final bool ok;
  final String? model;
  final String note;
  const CapResult(this.ok, this.model, this.note);
  Map<String, dynamic> toJson() => {'ok': ok, 'model': model, 'note': note};
  factory CapResult.fromJson(Map<String, dynamic> j) => CapResult(j['ok'] == true, j['model'] as String?, (j['note'] ?? '').toString());
}

const capKeys = ['text', 'voice', 'vision', 'document'];
const capLabels = {'text': 'Texto', 'voice': 'Voz', 'vision': 'Imagem', 'document': 'Documento (PDF)'};

Map<String, CapResult> capsFromJson(String? raw) {
  if (raw == null) return {};
  try {
    final m = jsonDecode(raw) as Map<String, dynamic>;
    if (m['v'] != 2) return {}; // relatório de versão antiga: refaz a verificação
    return {for (final k in capKeys) if (m[k] is Map) k: CapResult.fromJson((m[k] as Map).cast<String, dynamic>())};
  } catch (_) {
    return {};
  }
}

String capsToJson(Map<String, CapResult> m) => jsonEncode({'v': 2, for (final e in m.entries) e.key: e.value.toJson()});

// PNG 1x1 válido (para testar leitura de imagem).
const _png1 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';

/// PDF mínimo válido de uma página (para testar leitura de documento).
Uint8List _tinyPdf() {
  final objs = [
    '<</Type/Catalog/Pages 2 0 R>>',
    '<</Type/Pages/Kids[3 0 R]/Count 1>>',
    '<</Type/Page/Parent 2 0 R/MediaBox[0 0 200 200]/Contents 4 0 R/Resources<</Font<</F1 5 0 R>>>>>>',
    '<</Length 44>>\nstream\nBT /F1 18 Tf 20 100 Td (Ola mundo) Tj ET\nendstream',
    '<</Type/Font/Subtype/Type1/BaseFont/Helvetica>>',
  ];
  final b = StringBuffer('%PDF-1.4\n');
  final offs = <int>[];
  for (var i = 0; i < objs.length; i++) {
    offs.add(b.length);
    b.write('${i + 1} 0 obj\n${objs[i]}\nendobj\n');
  }
  final xref = b.length;
  b.write('xref\n0 ${objs.length + 1}\n0000000000 65535 f \n');
  for (final o in offs) {
    b.write('${o.toString().padLeft(10, '0')} 00000 n \n');
  }
  b.write('trailer\n<</Size ${objs.length + 1}/Root 1 0 R>>\nstartxref\n$xref\n%%EOF');
  return Uint8List.fromList(latin1.encode(b.toString()));
}

const _notCovered = 'Não coberto pela conta';

/// Mensagem padrão e curta: limite/conexão mantêm o motivo; o resto é "não coberto".
String shortCapNote(String msg) {
  final l = msg.toLowerCase();
  if (l.contains('limite de uso') || l.contains('cota')) return 'Limite de uso atingido agora';
  if (l.contains('sem conexão') || l.contains('demorou') || l.contains('sobrecarregado')) return 'Sem resposta agora, tente de novo';
  return _notCovered;
}

CapResult _res(String? model, String? err) => err == null ? CapResult(true, model, 'Funciona') : CapResult(false, model, shortCapNote(err));

Future<CapResult> _guard(String? model, Future<void> Function() f) async {
  try {
    await f();
    return CapResult(true, model, 'Funciona');
  } on DioException catch (e) {
    final q = await quotaFrom(e, 'x');
    return CapResult(false, model, shortCapNote(q?.message ?? explainDio(e)));
  } catch (e) {
    return CapResult(false, model, shortCapNote(e.toString()));
  }
}

/// Procura os modelos da conta e testa texto, voz, imagem e documento de uma vez.
/// [onStep] informa o passo em andamento. Não mexe em nada: só devolve o relatório.
Future<Map<String, CapResult>> scanCapabilities({
  required Dio dio,
  required String engine,
  required String key,
  String? chosenText,
  String? chosenVoice,
  String? paidModel,
  void Function(String step)? onStep,
}) async {
  final out = <String, CapResult>{};
  Options auth() => Options(headers: {'Authorization': 'Bearer $key'}, receiveTimeout: const Duration(seconds: 60));

  if (engine == 'gemini') {
    final text = await resolveGeminiModel(dio, key, override: chosenText);
    Options h() => Options(headers: {'x-goog-api-key': key, 'Content-Type': 'application/json'}, receiveTimeout: const Duration(seconds: 90));
    String url(String m) => 'https://generativelanguage.googleapis.com/v1beta/models/$m:generateContent';
    onStep?.call('Texto');
    final t = await testTextModel(dio, 'gemini', key, text, allowFallback: true);
    out['text'] = _res(text, t);
    onStep?.call('Voz');
    final v = await testVoiceModel(dio, 'gemini', key, text);
    out['voice'] = _res(text, v);
    onStep?.call('Imagem');
    out['vision'] = await _guard(text, () async {
      await retrying(() => dio.post(url(text), options: h(), data: {
            'contents': [
              {'parts': [{'text': 'Responda apenas: ok'}, {'inline_data': {'mime_type': 'image/png', 'data': _png1}}]}
            ]
          }));
    });
    onStep?.call('Documento');
    out['document'] = await _guard(text, () async {
      await retrying(() => dio.post(url(text), options: h(), data: {
            'contents': [
              {'parts': [{'text': 'Responda apenas: ok'}, {'inline_data': {'mime_type': 'application/pdf', 'data': base64Encode(_tinyPdf())}}]}
            ]
          }));
    });
    return out;
  }

  if (engine == 'groq') {
    onStep?.call('Buscando os modelos da conta');
    final all = <String>[];
    try {
      final r = await dio.get('https://api.groq.com/openai/v1/models', options: auth());
      for (final m in (r.data['data'] as List? ?? const [])) {
        if (m['active'] != false) all.add(m['id'] as String);
      }
    } on DioException catch (e) {
      final n = CapResult(false, null, shortCapNote(explainDio(e)));
      return {for (final k in capKeys) k: n};
    }
    final texts = await listGroqModels(dio, key, audio: false);
    final voices = await listGroqModels(dio, key, audio: true);
    final text = chosenText ?? (texts.isEmpty ? null : texts.first.id);
    final voice = chosenVoice ?? (voices.isEmpty ? null : voices.first.id);
    onStep?.call('Procurando um modelo que leia imagens');
    final vision = await groqVisionModel(dio, key, refresh: true);
    onStep?.call('Texto');
    if (text == null) {
      out['text'] = const CapResult(false, null, _notCovered);
    } else {
      final t = await testTextModel(dio, 'groq', key, text);
      out['text'] = _res(text, t);
    }
    onStep?.call('Voz');
    if (voice == null) {
      out['voice'] = const CapResult(false, null, _notCovered);
    } else {
      final v = await testVoiceModel(dio, 'groq', key, voice);
      out['voice'] = _res(voice, v);
    }
    out['vision'] = vision == null
        ? const CapResult(false, null, _notCovered)
        : CapResult(true, vision, 'Funciona');
    // Groq não recebe PDF direto: o app converte as páginas em imagem.
    final v = out['vision']!;
    out['document'] = CapResult(v.ok, v.model, v.ok ? 'Funciona (via imagens das páginas)' : _notCovered);
    return out;
  }

  if (engine == 'openai') {
    const text = 'gpt-4o-mini';
    onStep?.call('Texto');
    out['text'] = await _guard(text, () async {
      await retrying(() => dio.post('https://api.openai.com/v1/chat/completions', options: auth(), data: {'model': text, 'max_tokens': 4, 'messages': [{'role': 'user', 'content': 'ok'}]}));
    });
    onStep?.call('Voz');
    final v = await testVoiceModel(dio, 'openai', key, 'whisper-1');
    out['voice'] = _res('whisper-1', v);
    onStep?.call('Imagem');
    out['vision'] = await _guard(text, () async {
      await retrying(() => dio.post('https://api.openai.com/v1/chat/completions', options: auth(), data: {
            'model': text,
            'max_tokens': 4,
            'messages': [
              {'role': 'user', 'content': [{'type': 'text', 'text': 'ok?'}, {'type': 'image_url', 'image_url': {'url': 'data:image/png;base64,$_png1'}}]}
            ]
          }));
    });
    final vi = out['vision']!;
    out['document'] = CapResult(vi.ok, vi.model, vi.ok ? 'Funciona (via imagens das páginas)' : _notCovered);
    return out;
  }

  if (engine == 'claude') {
    final text = paidModel ?? 'claude-sonnet-5-5';
    Options h() => Options(headers: {'x-api-key': key, 'anthropic-version': '2023-06-01'}, receiveTimeout: const Duration(seconds: 60));
    Future<void> call(List<Map<String, dynamic>> content) => retrying(() => dio.post('https://api.anthropic.com/v1/messages', options: h(), data: {
          'model': text,
          'max_tokens': 8,
          'messages': [{'role': 'user', 'content': content}]
        }));
    onStep?.call('Texto');
    out['text'] = await _guard(text, () => call([{'type': 'text', 'text': 'ok'}]));
    out['voice'] = const CapResult(false, null, 'Não disponível nesta IA');
    onStep?.call('Imagem');
    out['vision'] = await _guard(text, () => call([{'type': 'image', 'source': {'type': 'base64', 'media_type': 'image/png', 'data': _png1}}, {'type': 'text', 'text': 'ok?'}]));
    onStep?.call('Documento');
    out['document'] = await _guard(text, () => call([{'type': 'document', 'source': {'type': 'base64', 'media_type': 'application/pdf', 'data': base64Encode(_tinyPdf())}}, {'type': 'text', 'text': 'ok?'}]));
    return out;
  }

  return out;
}

/// Testa a leitura de IMAGEM do [engine] com [model]. Nulo = funcionou.
Future<String?> testVisionModel(Dio dio, String engine, String key, String model) async {
  try {
    await retrying(() => switch (engine) {
          'gemini' => dio.post('https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent',
              options: Options(headers: {'x-goog-api-key': key}, receiveTimeout: const Duration(seconds: 90)),
              data: {'contents': [{'parts': [{'text': 'Responda apenas: ok'}, {'inline_data': {'mime_type': 'image/png', 'data': _png1}}]}]}),
          'claude' => dio.post('https://api.anthropic.com/v1/messages',
              options: Options(headers: {'x-api-key': key, 'anthropic-version': '2023-06-01'}),
              data: {'model': model, 'max_tokens': 8, 'messages': [{'role': 'user', 'content': [{'type': 'image', 'source': {'type': 'base64', 'media_type': 'image/png', 'data': _png1}}, {'type': 'text', 'text': 'ok?'}]}]}),
          _ => dio.post(engine == 'groq' ? 'https://api.groq.com/openai/v1/chat/completions' : 'https://api.openai.com/v1/chat/completions',
              options: Options(headers: {'Authorization': 'Bearer $key'}, receiveTimeout: const Duration(seconds: 60)),
              data: {'model': model, 'max_tokens': 4, 'messages': [{'role': 'user', 'content': [{'type': 'text', 'text': 'ok?'}, {'type': 'image_url', 'image_url': {'url': 'data:image/png;base64,$_png1'}}]}]}),
        });
    return null;
  } on DioException catch (e) {
    final q = await quotaFrom(e, engine);
    return q?.message ?? explainDio(e);
  }
}

/// Testa a leitura de DOCUMENTO (PDF). Gemini e Claude recebem o PDF direto;
/// Groq e OpenAI não: o app converte as páginas em imagem, então vale o teste de imagem.
Future<String?> testDocumentModel(Dio dio, String engine, String key, String model) async {
  if (engine != 'gemini' && engine != 'claude') return testVisionModel(dio, engine, key, model);
  try {
    final pdf = base64Encode(_tinyPdf());
    await retrying(() => engine == 'gemini'
        ? dio.post('https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent',
            options: Options(headers: {'x-goog-api-key': key}, receiveTimeout: const Duration(seconds: 90)),
            data: {'contents': [{'parts': [{'text': 'Responda apenas: ok'}, {'inline_data': {'mime_type': 'application/pdf', 'data': pdf}}]}]})
        : dio.post('https://api.anthropic.com/v1/messages',
            options: Options(headers: {'x-api-key': key, 'anthropic-version': '2023-06-01'}),
            data: {'model': model, 'max_tokens': 8, 'messages': [{'role': 'user', 'content': [{'type': 'document', 'source': {'type': 'base64', 'media_type': 'application/pdf', 'data': pdf}}, {'type': 'text', 'text': 'ok?'}]}]}));
    return null;
  } on DioException catch (e) {
    final q = await quotaFrom(e, engine);
    return q?.message ?? explainDio(e);
  }
}
