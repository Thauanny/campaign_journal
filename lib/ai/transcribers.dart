import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import '../core/setup_service.dart';
import 'activity.dart';
import 'quota.dart';
import 'retry.dart';
import '../domain/models.dart';
import 'interfaces.dart';
import 'prompts.dart';

String _mime(String path) =>
    switch (p.extension(path).toLowerCase().replaceFirst('.', '')) {
      'mp3' => 'audio/mp3',
      'wav' => 'audio/wav',
      'ogg' || 'opus' => 'audio/ogg',
      'flac' => 'audio/flac',
      'aac' => 'audio/aac',
      _ => 'audio/mp4', // m4a
    };

/// Whisper local via whisper.cpp (binário `whisper-cli`) — só desktop.
/// Alternativa ao FFI do plano: o binário roda como processo, sem compilar
/// nada dentro do app. O app NÃO embute o modelo: o usuário informa o caminho.
class WhisperLocalTranscriber implements Transcriber {
  final String binary;
  final String modelPath;
  WhisperLocalTranscriber(this.binary, this.modelPath);
  @override
  String get id => 'whisper_local';
  @override
  String get label => 'Whisper local (whisper.cpp)';
  @override
  bool get needsNetwork => false;

  static Future<String?> findBinary([String? custom]) async {
    final candidates = [
      if (custom != null && custom.isNotEmpty) custom,
      'whisper-cli',
      'whisper-cpp',
      '/opt/homebrew/bin/whisper-cli',
      '/usr/local/bin/whisper-cli',
    ];
    for (final c in candidates) {
      try {
        final r = await Process.run(Platform.isWindows ? 'where' : 'which', [c]);
        if (r.exitCode == 0) return r.stdout.toString().trim().split('\n').first;
        if (File(c).existsSync()) return c;
      } catch (_) {}
    }
    return null;
  }

  @override
  Future<List<TranscriptSegment>> transcribe(String audioPath,
      {String language = 'pt-BR',
      List<String> vocabularyHints = const [],
      int offsetMs = 0}) async {
    if (!(Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
      throw ProviderException(
          'Whisper local via binário só está disponível no desktop. '
          'No celular, use o modo com chave ou processe no desktop.');
    }
    if (!File(modelPath).existsSync()) {
      throw ProviderException(
          'Modelo Whisper não encontrado: "$modelPath". Configure em Configurações.');
    }
    final tmp = await Directory.systemTemp.createTemp('whisper');
    try {
      final wav = p.join(tmp.path, 'in.wav');
      final ffmpeg = await Tools.find('ffmpeg') ?? 'ffmpeg';
      final ff = await Process.run(ffmpeg,
          ['-y', '-i', audioPath, '-ar', '16000', '-ac', '1', wav],
          environment: Tools.env);
      if (ff.exitCode != 0) {
        throw ProviderException(
            'ffmpeg é necessário para converter o áudio (instale-o): ${ff.stderr}');
      }
      final out = p.join(tmp.path, 'out');
      final r = await Process.run(binary, [
        '-m', modelPath, '-f', wav, '-l', language.split('-').first,
        '-oj', '-of', out,
        // segmentos curtos, quebrados em palavras inteiras: horários mais finos
        '-ml', '90', '-sow',
        if (vocabularyHints.isNotEmpty) ...[
          '--prompt',
          'Termos da campanha: ${vocabularyHints.take(100).join(', ')}.'
        ],
      ], environment: Tools.env);
      final jf = File('$out.json');
      if (r.exitCode != 0 || !jf.existsSync()) {
        throw ProviderException('whisper falhou: ${r.stderr}');
      }
      final j = jsonDecode(await jf.readAsString()) as Map;
      final segs = <TranscriptSegment>[];
      for (final s in (j['transcription'] as List)) {
        final t = (s['text'] as String).trim();
        if (t.isEmpty) continue;
        segs.add(TranscriptSegment(
            (s['offsets']['from'] as int) + offsetMs,
            (s['offsets']['to'] as int) + offsetMs,
            t));
      }
      return segs;
    } finally {
      tmp.delete(recursive: true).ignore();
    }
  }
}

class OpenAiTranscriber implements Transcriber {
  final Dio dio;
  final String apiKey;
  final String model;
  final String baseUrl;
  final String _name;
  OpenAiTranscriber(this.dio, this.apiKey, {this.model = 'whisper-1', this.baseUrl = 'https://api.openai.com/v1', String name = 'OpenAI'})
      : _name = name;

  /// Whisper large-v3 turbo na Groq (mesmo protocolo da OpenAI).
  factory OpenAiTranscriber.groq(Dio dio, String key, {String model = 'whisper-large-v3-turbo'}) => OpenAiTranscriber(dio, key,
      model: model, baseUrl: 'https://api.groq.com/openai/v1', name: 'Groq');
  @override
  String get id => 'openai_audio';
  @override
  String get label => '$_name ($model)';
  @override
  bool get needsNetwork => true;

  /// Arquivos acima do limite da API (25 MB) são cortados em partes de 10 min.
  static const _partSeconds = 600;

  @override
  Future<List<TranscriptSegment>> transcribe(String audioPath,
      {String language = 'pt-BR',
      List<String> vocabularyHints = const [],
      int offsetMs = 0}) async {
    final size = await File(audioPath).length();
    Activity.log('Enviando o áudio (${(size / 1048576).toStringAsFixed(1)} MB) a $_name para transcrever…');
    if (size <= 24 * 1024 * 1024) return _one(audioPath, language, vocabularyHints, offsetMs);
    final tmp = await Directory.systemTemp.createTemp('whisper_parts');
    try {
      final parts = await splitAudio(audioPath, tmp, _partSeconds);
      if (parts.length <= 1) {
        throw ProviderException('Áudio acima de 25 MB: $_name recusa e não consegui dividi-lo (precisa do ffmpeg no computador). Importe em blocos menores.');
      }
      Activity.log('Áudio grande: dividido em ${parts.length} partes de ${_partSeconds ~/ 60} min para respeitar o limite de $_name.');
      final out = <TranscriptSegment>[];
      for (var i = 0; i < parts.length; i++) {
        Activity.log('Transcrevendo a parte ${i + 1}/${parts.length}…');
        out.addAll(await _one(parts[i], language, vocabularyHints, offsetMs + i * _partSeconds * 1000));
      }
      return out;
    } finally {
      tmp.delete(recursive: true).ignore();
    }
  }

  Future<List<TranscriptSegment>> _one(String audioPath, String language, List<String> vocabularyHints, int offsetMs) async {
    try {
      // O formulário só pode ser enviado uma vez: é montado a cada tentativa.
      final r = await retrying(() async => dio.post('$baseUrl/audio/transcriptions',
          data: FormData.fromMap({
            'model': model,
            'language': language.split('-').first,
            'response_format': 'verbose_json',
            if (vocabularyHints.isNotEmpty) 'prompt': 'Termos: ${vocabularyHints.take(100).join(', ')}.',
            'file': await MultipartFile.fromFile(audioPath, filename: p.basename(audioPath)),
          }),
          options: Options(headers: {'Authorization': 'Bearer $apiKey'})));
      final d = r.data as Map;
      final segs = <TranscriptSegment>[];
      for (final s in (d['segments'] as List? ?? const [])) {
        final lp = (s['avg_logprob'] as num?)?.toDouble() ?? 0;
        segs.add(TranscriptSegment(
            ((s['start'] as num) * 1000).round() + offsetMs,
            ((s['end'] as num) * 1000).round() + offsetMs,
            (s['text'] as String).trim(),
            // logprob (~ -1..0) -> confiança 0..1 aproximada
            confidence: (1 + lp).clamp(0.0, 1.0)));
      }
      if (segs.isEmpty && (d['text'] ?? '').toString().isNotEmpty) {
        segs.add(TranscriptSegment(offsetMs, offsetMs, d['text'].toString()));
      }
      return segs;
    } on DioException catch (e) {
      final q = await quotaFrom(e, baseUrl.contains('groq') ? 'groq' : 'openai');
      if (q != null) throw q;
      throw ProviderException(
          '$_name áudio: ${e.response?.statusCode ?? ''} ${e.response?.data ?? e.message}');
    }
  }
}

/// Corta um áudio em partes de [seconds] com o ffmpeg (sem recodificar).
/// Sem ffmpeg, devolve o próprio arquivo.
Future<List<String>> splitAudio(String audioPath, Directory tmp, int seconds) async {
  if (!canRunTools) return [audioPath];
  final ffmpeg = await Tools.find('ffmpeg');
  if (ffmpeg == null) return [audioPath];
  try {
    final ext = p.extension(audioPath).isEmpty ? '.m4a' : p.extension(audioPath);
    final r = await Process.run(ffmpeg, ['-y', '-i', audioPath, '-f', 'segment', '-segment_time', '$seconds', '-reset_timestamps', '1', '-c', 'copy', p.join(tmp.path, 'chunk%03d$ext')], environment: Tools.env);
    if (r.exitCode != 0) return [audioPath];
    final files = tmp.listSync().whereType<File>().where((f) => p.basename(f.path).startsWith('chunk')).map((f) => f.path).toList()..sort();
    return files.isEmpty ? [audioPath] : files;
  } catch (_) {
    return [audioPath];
  }
}

class GeminiTranscriber implements Transcriber {
  final Dio dio;
  final String apiKey;
  final String model;
  GeminiTranscriber(this.dio, this.apiKey, this.model);
  @override
  String get id => 'gemini_audio';
  @override
  String get label => 'Gemini ($model)';
  @override
  bool get needsNetwork => true;

  /// O Gemini estima os horários e costuma "derivar" em áudios longos (relatos
  /// de desenvolvedores). Por isso cortamos em blocos curtos e somamos o
  /// deslocamento de cada bloco aqui, no código.
  static const chunkSeconds = 300;

  Future<List<String>> _split(String audioPath, Directory tmp) async {
    if (!canRunTools) return [audioPath];
    final ffmpeg = await Tools.find('ffmpeg');
    if (ffmpeg == null) return [audioPath];
    try {
      final ext = p.extension(audioPath).isEmpty ? '.m4a' : p.extension(audioPath);
      final r = await Process.run(ffmpeg, ['-y', '-i', audioPath, '-f', 'segment', '-segment_time', '$chunkSeconds', '-reset_timestamps', '1', '-c', 'copy', p.join(tmp.path, 'chunk%03d$ext')], environment: Tools.env);
      if (r.exitCode != 0) return [audioPath];
      final files = tmp.listSync().whereType<File>().where((f) => p.basename(f.path).startsWith('chunk')).map((f) => f.path).toList()..sort();
      return files.isEmpty ? [audioPath] : files;
    } catch (_) {
      return [audioPath];
    }
  }

  @override
  Future<List<TranscriptSegment>> transcribe(String audioPath,
      {String language = 'pt-BR',
      List<String> vocabularyHints = const [],
      int offsetMs = 0}) async {
    final tmp = await Directory.systemTemp.createTemp('gemini_chunks');
    try {
      final parts = await _split(audioPath, tmp);
      if (parts.length > 1) Activity.log('Áudio dividido em ${parts.length} blocos de ${chunkSeconds ~/ 60} min para os horários ficarem precisos.');
      final out = <TranscriptSegment>[];
      for (var i = 0; i < parts.length; i++) {
        if (parts.length > 1) Activity.log('Transcrevendo o bloco ${i + 1}/${parts.length}…');
        out.addAll(await retrying(() => _one(parts[i], vocabularyHints, offsetMs + (parts.length > 1 ? i * chunkSeconds * 1000 : 0))));
      }
      return out;
    } finally {
      tmp.delete(recursive: true).ignore();
    }
  }

  Future<List<TranscriptSegment>> _one(String audioPath, List<String> vocabularyHints, int offsetMs) async {
    final bytes = await File(audioPath).readAsBytes();
    Activity.log('Enviando o áudio (${(bytes.length / 1048576).toStringAsFixed(1)} MB) ao Gemini para transcrever…');
    if (bytes.length > 18 * 1024 * 1024) {
      throw ProviderException('Áudio acima de ~18 MB para envio direto ao '
          'Gemini. Divida em blocos menores.');
    }
    final prompt = '''
Transcreva fielmente este áudio de uma sessão de RPG de mesa em português do Brasil.
${vocabularyHints.isEmpty ? '' : 'Grafia correta de nomes: ${vocabularyHints.take(100).join(', ')}.'}
Responda SOMENTE JSON: {"segments":[{"start":"mm:ss","end":"mm:ss","text":"","speaker":"opcional"}]}
Regras de tempo: use o formato mm:ss, contado a partir do INÍCIO deste áudio (00:00). Os segmentos devem ser curtos (5 a 15 segundos), em ordem, sem sobreposição e cobrindo o áudio até o fim. O último "end" deve ser a duração real do áudio. Não invente trechos nem repita falas.''';
    try {
      final r = await dio.post(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent',
          options: Options(
              headers: {'x-goog-api-key': apiKey},
              receiveTimeout: const Duration(minutes: 10)),
          data: {
            'contents': [
              {
                'parts': [
                  {'text': prompt},
                  {
                    'inline_data': {
                      'mime_type': _mime(audioPath),
                      'data': base64Encode(bytes)
                    }
                  },
                ]
              }
            ],
            'generationConfig': {'responseMimeType': 'application/json', 'temperature': 0},
          });
      final text = (r.data['candidates'][0]['content']['parts'] as List)
          .map((x) => x['text'] ?? '')
          .join();
      final j = parseJsonObject(text);
      if (j == null) throw ProviderException('Gemini devolveu JSON inválido.');
      final segs = <TranscriptSegment>[];
      for (final s in (j['segments'] as List? ?? const [])) {
        final t = (s['text'] ?? '').toString().trim();
        if (t.isEmpty) continue;
        final st = parseClock(s['start']) ?? ((s['start_ms'] ?? 0) as num).toInt();
        final en = parseClock(s['end']) ?? ((s['end_ms'] ?? st) as num).toInt();
        segs.add(TranscriptSegment(st + offsetMs, en + offsetMs, t, speaker: s['speaker']?.toString()));
      }
      return segs;
    } on DioException catch (e) {
      if (isTransient(e)) rethrow; // `retrying` tenta de novo
      final q = await quotaFrom(e, 'gemini');
      if (q != null) throw q;
      throw ProviderException(
          'Gemini áudio: ${e.response?.statusCode ?? ''} ${e.response?.data ?? e.message}');
    }
  }
}
