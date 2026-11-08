import 'package:dio/dio.dart';

import 'activity.dart';
import 'quota.dart';

/// Erros temporários (500/503/504, queda de conexão e demora sem resposta)
/// merecem nova tentativa; o Google recomenda "exponential backoff".
bool isTransient(DioException e) {
  final c = e.response?.statusCode;
  return c == 500 ||
      c == 503 ||
      c == 504 ||
      e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.connectionTimeout;
}

Future<T> retrying<T>(Future<T> Function() f,
    {List<Duration> delays = const [Duration(seconds: 2), Duration(seconds: 5), Duration(seconds: 10)],
    void Function(int attempt, int total, Duration wait, DioException e)? onRetry}) async {
  var rateWaits = 0;
  for (var i = 0;;) {
    try {
      return await f();
    } on DioException catch (e) {
      // Limite por minuto (429): espera o tempo informado pela IA e tenta de novo.
      if (e.response?.statusCode == 429 && rateWaits < 4) {
        final w = await shortRateLimitWait(e);
        if (w != null) {
          rateWaits++;
          final secs = w.inSeconds + 1;
          Activity.log('Limite por minuto da IA: aguardando ${secs}s e tentando de novo…');
          await Future.delayed(Duration(seconds: secs));
          continue;
        }
      }
      if (!isTransient(e) || i >= delays.length) rethrow;
      onRetry?.call(i + 1, delays.length, delays[i], e);
      await Future.delayed(delays[i]);
      i++;
    }
  }
}
