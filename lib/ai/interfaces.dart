import '../domain/models.dart';

/// Voz para texto. Cada adaptador (Whisper local, Gemini, OpenAI) implementa.
abstract class Transcriber {
  String get id;
  String get label;
  bool get needsNetwork;
  Future<List<TranscriptSegment>> transcribe(
    String audioPath, {
    String language = 'pt-BR',
    List<String> vocabularyHints = const [],
    int offsetMs = 0,
  });
}

/// Texto para extração/resumo. Claude, GPT, Gemini, Ollama ou heurística local.
abstract class TextModel {
  String get id;
  String get label;
  bool get needsNetwork;

  /// Texto da transcrição já com horários `[mm:ss]` por trecho.
  Future<(ExtractionResult, UsageInfo)> extract(
    String transcript, {
    required List<KnownEntity> known,
    String system = '',
  });

  Future<(SessionSummary, UsageInfo)> summarize(
    String transcript, {
    required List<KnownEntity> known,
    String campaignName = '',
    String extra = '',
  });
}

class ProviderException implements Exception {
  final String message;
  ProviderException(this.message);
  @override
  String toString() => message;
}
