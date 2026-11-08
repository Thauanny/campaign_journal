import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../domain/sheet_parser.dart';
import 'interfaces.dart';
import 'quota.dart';
import 'retry.dart';
import 'prompts.dart';

/// Leitura de ficha por modelo com visão (Fase 2): a imagem vai direto ao
/// modelo com um schema JSON de saída.
Future<SheetFields> readSheetWithVision({
  required Dio dio,
  required String provider,
  required String apiKey,
  required String model,
  required List<Uint8List> pagesPng,
  required String system,
}) async {
  final prompt = 'Leia esta ficha de personagem de RPG (as imagens são as páginas da ficha, na ordem). ${sheetSchemaHint(system)}';
  try {
    String text;
    switch (provider) {
      case 'gemini':
        final r = await retrying(() => dio.post(
            'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent',
            options: Options(headers: {'x-goog-api-key': apiKey}, receiveTimeout: const Duration(minutes: 3)),
            data: {
              'contents': [
                {'parts': [
                  {'text': prompt},
                  for (final p in pagesPng) {'inline_data': {'mime_type': 'image/png', 'data': base64Encode(p)}},
                ]}
              ],
              'generationConfig': {'responseMimeType': 'application/json', 'temperature': 0},
            }));
        text = (r.data['candidates'][0]['content']['parts'] as List).map((p) => p['text'] ?? '').join();
      case 'openai' || 'groq':
        final r = await dio.post(provider == 'groq' ? 'https://api.groq.com/openai/v1/chat/completions' : 'https://api.openai.com/v1/chat/completions',
            options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
            data: {
              'model': model,
              'response_format': {'type': 'json_object'},
              'messages': [
                {'role': 'user', 'content': [
                  {'type': 'text', 'text': prompt},
                  for (final p in (provider == 'groq' ? pagesPng.take(5) : pagesPng)) {'type': 'image_url', 'image_url': {'url': 'data:image/png;base64,${base64Encode(p)}'}},
                ]}
              ],
            });
        text = r.data['choices'][0]['message']['content'] as String;
      case 'claude':
        final r = await dio.post('https://api.anthropic.com/v1/messages',
            options: Options(headers: {'x-api-key': apiKey, 'anthropic-version': '2023-06-01'}),
            data: {
              'model': model,
              'max_tokens': 4000,
              'messages': [
                {'role': 'user', 'content': [
                  for (final p in pagesPng) {'type': 'image', 'source': {'type': 'base64', 'media_type': 'image/png', 'data': base64Encode(p)}},
                  {'type': 'text', 'text': prompt},
                ]}
              ],
            });
        text = (r.data['content'] as List).where((c) => c['type'] == 'text').map((c) => c['text']).join();
      default:
        throw ProviderException('Provedor desconhecido: $provider');
    }
    final j = parseJsonObject(text);
    if (j == null) throw ProviderException('O modelo não devolveu JSON válido para a ficha.');
    return SheetFields.fromJson(j);
  } on DioException catch (e) {
    final q = await quotaFrom(e, provider);
    if (q != null) throw q;
    throw ProviderException('Visão ($provider): ${e.response?.statusCode ?? ''} ${e.response?.data ?? e.message}');
  }
}
