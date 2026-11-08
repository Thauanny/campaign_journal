import 'package:dio/dio.dart';

/// Apelido que o próprio Google mantém apontando para o Flash atual. É a forma
/// recomendada na documentação: não quebra quando um modelo é desligado.
const geminiAuto = 'gemini-flash-latest';

/// Qual modelo do Gemini usar: o escolhido pelo usuário ou o apelido
/// "gemini-flash-latest". (Não consulta a rede: a lista de modelos é só para a
/// tela de escolha.)
Future<String> resolveGeminiModel(Dio dio, String apiKey, {String? override, String fallback = geminiAuto}) async {
  if (override != null && override.trim().isNotEmpty) return override.trim();
  return fallback;
}
