import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/engines.dart';
import 'interfaces.dart';

/// Aviso de limite de uso (cota) de um provedor de IA.
class QuotaNotice {
  final String provider;

  /// Quando o limite deve voltar a ficar livre (nulo = não informado).
  final DateTime? resetAt;

  /// Limite diário (volta só no dia seguinte) ou por minuto/hora.
  final bool daily;

  /// O horário foi calculado por estimativa (não veio do provedor).
  final bool estimated;
  final DateTime createdAt;
  const QuotaNotice(this.provider, this.resetAt, this.daily, this.estimated, this.createdAt);

  /// Expira quando o horário passa; sem horário, some depois de 15 minutos.
  bool expired(DateTime now) => resetAt != null ? now.isAfter(resetAt!) : now.difference(createdAt).inMinutes >= 15;

  String get providerName => engineById(provider)?.name ?? provider;

  Map<String, dynamic> toJson() => {'p': provider, 'r': resetAt?.millisecondsSinceEpoch, 'd': daily, 'e': estimated, 'c': createdAt.millisecondsSinceEpoch};
  static QuotaNotice? fromJson(Map<String, dynamic> j) {
    try {
      return QuotaNotice(j['p'] as String, j['r'] == null ? null : DateTime.fromMillisecondsSinceEpoch(j['r'] as int), j['d'] == true, j['e'] == true,
          DateTime.fromMillisecondsSinceEpoch(j['c'] as int));
    } catch (_) {
      return null;
    }
  }
}

/// Guarda o aviso mais recente (persistido) para a interface mostrar em tela fixa.
class QuotaCenter {
  static final notice = ValueNotifier<QuotaNotice?>(null);
  static SharedPreferences? _prefs;

  static void init(SharedPreferences prefs) {
    _prefs = prefs;
    try {
      final raw = prefs.getString('quota_notice');
      final n = raw == null ? null : QuotaNotice.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      notice.value = (n == null || n.expired(DateTime.now())) ? null : n;
    } catch (_) {}
  }

  static void hit(QuotaNotice n) {
    notice.value = n;
    _prefs?.setString('quota_notice', jsonEncode(n.toJson()));
  }

  /// Uma chamada deu certo: se o aviso era desse provedor, o limite já voltou.
  static void ok(String provider) {
    if (notice.value?.provider == provider) clear();
  }

  static void clear() {
    notice.value = null;
    _prefs?.remove('quota_notice');
  }
}

/// Erro de limite de uso, com a hora estimada em que volta a liberar.
class QuotaException extends ProviderException {
  final QuotaNotice info;
  QuotaException(this.info, String message) : super(message);
}

// ───────────── leitura da resposta 429 ─────────────

/// Texto do corpo de um erro (JSON, texto ou resposta em fluxo).
Future<String> errorBodyText(DioException e) async {
  final d = e.response?.data;
  try {
    if (d is ResponseBody) {
      final bytes = <int>[];
      await for (final c in d.stream) {
        bytes.addAll(c);
      }
      return utf8.decode(bytes, allowMalformed: true);
    }
    if (d is String) return d;
    if (d != null) return jsonEncode(d);
  } catch (_) {}
  return '';
}

/// "1h2m3.5s", "34s", "2m59.56s", "250ms" → Duration.
Duration? parseDuration(String s) {
  final m = RegExp(r'(?:(\d+(?:\.\d+)?)\s*h)?\s*(?:(\d+(?:\.\d+)?)\s*m(?!s))?\s*(?:(\d+(?:\.\d+)?)\s*s)?\s*(?:(\d+)\s*ms)?').firstMatch(s.trim());
  if (m == null || (m.group(0) ?? '').trim().isEmpty) return null;
  double v(int i) => double.tryParse(m.group(i) ?? '') ?? 0;
  final ms = v(1) * 3600000 + v(2) * 60000 + v(3) * 1000 + v(4);
  return ms <= 0 ? null : Duration(milliseconds: ms.round());
}

/// Próxima meia-noite no horário do Pacífico (EUA), onde o Gemini reinicia os
/// limites diários. É uma estimativa: considera horário de verão dos EUA.
DateTime nextPacificMidnight(DateTime now) {
  final utc = now.toUtc();
  DateTime nthSunday(int year, int month, int n) {
    var d = DateTime.utc(year, month, 1);
    while (d.weekday != DateTime.sunday) {
      d = d.add(const Duration(days: 1));
    }
    return d.add(Duration(days: 7 * (n - 1)));
  }

  final dstStart = nthSunday(utc.year, 3, 2).add(const Duration(hours: 10)); // 2h PST
  final dstEnd = nthSunday(utc.year, 11, 1).add(const Duration(hours: 9)); // 2h PDT
  final offset = (utc.isAfter(dstStart) && utc.isBefore(dstEnd)) ? -7 : -8;
  final local = utc.add(Duration(hours: offset));
  final midnightLocal = DateTime.utc(local.year, local.month, local.day + 1);
  return midnightLocal.subtract(Duration(hours: offset)).toLocal();
}

Duration? _parseWait(DioException e, String body) {
  Duration? wait;
  // 1) cabeçalho retry-after (segundos)
  final ra = e.response?.headers.value('retry-after');
  if (ra != null) {
    final secs = double.tryParse(ra.trim());
    wait = secs != null ? Duration(milliseconds: (secs * 1000).round()) : null;
  }
  // 2) Gemini: details[].retryDelay ("34s")
  wait ??= () {
    final m = RegExp(r'"retryDelay"\s*:\s*"([^"]+)"').firstMatch(body);
    return m == null ? null : parseDuration(m.group(1)!);
  }();
  // 3) texto: "try again in 7m13.5s" / "retry in 34.5s"
  wait ??= () {
    final m = RegExp(r'(?:try again|retry)\s+in\s+([0-9hms.\s]+)', caseSensitive: false).firstMatch(body);
    return m == null ? null : parseDuration(m.group(1)!.trim());
  }();
  // 4) Groq/OpenAI: cabeçalhos x-ratelimit-reset-*
  wait ??= () {
    final h = e.response?.headers;
    for (final k in ['x-ratelimit-reset-requests', 'x-ratelimit-reset-tokens']) {
      final v = h?.value(k);
      final d = v == null ? null : parseDuration(v);
      if (d != null) return d;
    }
    return null;
  }();

  return wait;
}

bool _isDaily(String body) {
  final low = body.toLowerCase();
  return low.contains('perday') || low.contains('per day') || low.contains('daily') || low.contains('(tpd)') || low.contains('(rpd)') || low.contains('requests per day');
}

/// Limite POR MINUTO (curto): devolve quanto esperar para tentar de novo; nulo se
/// não é 429, se é limite diário ou se a espera é longa demais para aguardar.
Future<Duration?> shortRateLimitWait(DioException e) async {
  if (e.response?.statusCode != 429) return null;
  final body = await errorBodyText(e);
  if (_isDaily(body)) return null;
  final w = _parseWait(e, body) ?? const Duration(seconds: 20);
  return w > const Duration(seconds: 90) ? null : w;
}

/// Se [e] é erro de limite de uso (429), devolve a exceção com o aviso e já o
/// registra para a tela fixa. Caso contrário, nulo.
Future<QuotaException?> quotaFrom(DioException e, String provider, {DateTime? now}) async {
  if (e.response?.statusCode != 429) return null;
  final t = now ?? DateTime.now();
  final body = await errorBodyText(e);
  final low = body.toLowerCase();

  final wait = _parseWait(e, body);

  final daily = low.contains('perday') || low.contains('per day') || low.contains('daily') || low.contains('(tpd)') || low.contains('(rpd)') || low.contains('requests per day');
  DateTime? reset;
  var estimated = false;
  if (wait != null) {
    reset = t.add(wait);
  } else if (daily && provider == 'gemini') {
    reset = nextPacificMidnight(t); // limite diário do Gemini: meia-noite do Pacífico
    estimated = true;
  }
  final n = QuotaNotice(provider, reset, daily, estimated, t);
  QuotaCenter.hit(n);
  return QuotaException(n, quotaMessage(n, now: t));
}

String _hhmm(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

String humanWait(Duration d) {
  if (d.inMinutes < 1) return 'menos de 1 min';
  if (d.inHours < 1) return '${d.inMinutes} min';
  final m = d.inMinutes % 60;
  return '${d.inHours}h${m == 0 ? '' : ' ${m}min'}';
}

/// Texto para o usuário: o que aconteceu e quando volta.
String quotaMessage(QuotaNotice n, {DateTime? now}) {
  final t = now ?? DateTime.now();
  final b = StringBuffer('Limite de uso do ${n.providerName} atingido${n.daily ? ' (limite diário)' : ''}.');
  if (n.resetAt != null) {
    final left = n.resetAt!.difference(t);
    final sameDay = n.resetAt!.day == t.day && n.resetAt!.month == t.month;
    b.write(' Deve liberar de novo ${n.estimated ? 'por volta d' : ''}${sameDay ? 'as' : 'amanhã às'} ${_hhmm(n.resetAt!)} (em ${humanWait(left)})${n.estimated ? ', estimativa' : ''}.');
  } else {
    b.write(' O provedor não informou quando libera; tente de novo em alguns minutos.');
  }
  return b.toString();
}
