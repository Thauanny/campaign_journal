import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models.dart';

class ModelPrice {
  final String provider;
  final double inPerM;
  final double outPerM;
  final String tier;
  const ModelPrice(this.provider, this.inPerM, this.outPerM, this.tier);
}

/// Tabela de preços/modelos lida de configuração (asset + sobrescrita do
/// usuário), nunca fixa no código — o plano pede que os limites sejam atualizáveis.
class PricingTable {
  final Map<String, ModelPrice> models;
  final Map<String, dynamic> raw;
  PricingTable(this.models, this.raw);

  static PricingTable parse(String json) {
    final j = jsonDecode(json) as Map<String, dynamic>;
    final m = <String, ModelPrice>{};
    (j['models'] as Map<String, dynamic>).forEach((k, v) {
      m[k] = ModelPrice(v['provider'], (v['in'] as num).toDouble(),
          (v['out'] as num).toDouble(), v['tier']);
    });
    return PricingTable(m, j);
  }

  String defaultModel(ProcessingMode mode, String provider) {
    final d = raw['defaults'] as Map<String, dynamic>;
    final tier = mode == ProcessingMode.premium ? 'premium' : 'balanced';
    return d[tier][provider] as String;
  }

  double audioPerMinute(String key) =>
      ((raw['audio_per_minute_usd'] as Map)[key] as num?)?.toDouble() ?? 0;

  double cost(String model, int inTok, int outTok) {
    final p = models[model];
    if (p == null) return 0;
    return inTok / 1e6 * p.inPerM + outTok / 1e6 * p.outPerM;
  }
}

class Settings {
  final SharedPreferences prefs;
  final FlutterSecureStorage secure;
  Settings(this.prefs, this.secure);

  static const providers = ['claude', 'openai', 'gemini', 'groq'];

  ProcessingMode get defaultMode =>
      ProcessingModeX.parse(prefs.getString('mode') ?? 'free');
  Future<void> setDefaultMode(ProcessingMode m) =>
      prefs.setString('mode', m.key);

  /// Provedor usado nos modos Equilibrado/Premium.
  String get textProvider => prefs.getString('text_provider') ?? 'gemini';
  Future<void> setTextProvider(String v) => prefs.setString('text_provider', v);

  /// IA ativa para TUDO no fluxo da campanha (voz, extração, resumo, perguntas):
  /// local | gemini | groq | openai | claude | none. Nulo = ainda não escolhida.
  String? get engine => prefs.getString('engine');
  Future<void> setEngine(String v) => prefs.setString('engine', v);

  /// Claude e OpenAI cobram por uso; as demais são gratuitas.
  bool get engineIsPaid => engine == 'claude' || engine == 'openai';
  ProcessingMode get engineMode => engineIsPaid ? ProcessingMode.balanced : ProcessingMode.free;

  String get audioProvider => engine == 'openai' ? 'openai' : (prefs.getString('audio_provider') ?? 'gemini');
  Future<void> setAudioProvider(String v) =>
      prefs.setString('audio_provider', v);

  /// Modelo por etapa (extract | summarize); vazio = padrão do modo.
  String? modelFor(String step) => prefs.getString('model_$step');
  Future<void> setModelFor(String step, String? v) => v == null || v.isEmpty
      ? prefs.remove('model_$step')
      : prefs.setString('model_$step', v);

  /// Modelo de voz local escolhido (tiny | base | small | medium | large-v3-turbo).
  String get whisperName => prefs.getString('whisper_name') ?? 'small';
  Future<void> setWhisperName(String v) => prefs.setString('whisper_name', v);

  String get whisperModelPath => prefs.getString('whisper_model') ?? '';
  Future<void> setWhisperModelPath(String v) =>
      prefs.setString('whisper_model', v);
  String get whisperBinary => prefs.getString('whisper_bin') ?? '';
  Future<void> setWhisperBinary(String v) => prefs.setString('whisper_bin', v);
  String get ollamaModel => prefs.getString('ollama_model') ?? 'qwen2.5:7b';
  Future<void> setOllamaModel(String v) => prefs.setString('ollama_model', v);

  /// Onde está o Ollama (no celular: o IP do seu computador na rede).
  String get ollamaUrl => prefs.getString('ollama_url') ?? 'http://localhost:11434';
  Future<void> setOllamaUrl(String v) => prefs.setString('ollama_url', v.trim().replaceFirst(RegExp(r'/+$'), ''));

  /// Modo grátis com as duas IAs prontas: 'cloud' (melhor qualidade) ou 'local' (privacidade).
  String get freePriority => prefs.getString('free_priority') ?? 'cloud';
  Future<void> setFreePriority(String v) => prefs.setString('free_priority', v);

  /// Permite o resumo simples sem IA (heurística) como último recurso.
  bool get allowHeuristic => prefs.getBool('allow_heuristic') ?? false;
  Future<void> setAllowHeuristic(bool v) => prefs.setBool('allow_heuristic', v);

  /// Já mostramos o assistente de preparação na primeira abertura?
  bool get setupSeen => prefs.getBool('setup_seen') ?? false;
  Future<void> setSetupSeen() => prefs.setBool('setup_seen', true);


  String get themeMode => prefs.getString('theme') ?? 'dark';
  Future<void> setThemeMode(String v) => prefs.setString('theme', v);

  bool get consentGiven => prefs.getBool('consent') ?? false;
  Future<void> setConsent() => prefs.setBool('consent', true);
  bool get cloudImageWarned => prefs.getBool('cloud_image_warned') ?? false;
  Future<void> setCloudImageWarned() => prefs.setBool('cloud_image_warned', true);
  bool get deleteAudioAfter => prefs.getBool('delete_audio') ?? false;
  Future<void> setDeleteAudioAfter(bool v) => prefs.setBool('delete_audio', v);

  /// Cópia na memória (só durante esta execução): evita ir ao chaveiro toda vez.
  final _keyCache = <String, String>{};

  /// Marca simples (sem segredo) de que uma chave FOI salva. Serve para o app
  /// não confundir "o chaveiro não respondeu" com "não existe chave".
  /// Relatório de capacidades (texto, voz, imagem, documento) por IA, em JSON.
  String? capsJson(String engine) => prefs.getString('caps_$engine');
  Future<void> setCapsJson(String engine, String? v) => v == null ? prefs.remove('caps_$engine') : prefs.setString('caps_$engine', v);

  bool keyFlag(String provider) => prefs.getBool('keyflag_$provider') ?? false;

  /// Lê a chave. Devolve (chave, leituraOk): `leituraOk` é falso quando o
  /// chaveiro falhou ou demorou (no Mac, costuma estar esperando autorização).
  Future<(String?, bool)> readKey(String provider) async {
    final cached = _keyCache[provider];
    if (cached != null) return (cached, true);
    try {
      final v = await secure.read(key: 'key_$provider').timeout(const Duration(seconds: 30));
      if (v != null) {
        _keyCache[provider] = v;
        if (!keyFlag(provider)) await prefs.setBool('keyflag_$provider', true);
      }
      return (v, true);
    } catch (_) {
      return (null, false);
    }
  }

  /// Chaves de API: só no armazenamento seguro, nunca em log.
  Future<String?> apiKey(String provider) async => (await readKey(provider)).$1;

  /// A IA tem chave configurada? Se o chaveiro não respondeu, confia na marca de
  /// "salva" em vez de acusar falta de chave.
  Future<bool> keyConfigured(String provider) async {
    final (k, ok) = await readKey(provider);
    if (k != null) return true;
    return ok ? false : keyFlag(provider);
  }

  Future<void> setApiKey(String provider, String? v) async {
    try {
      if (v == null || v.trim().isEmpty) {
        await secure.delete(key: 'key_$provider').timeout(const Duration(seconds: 30));
        _keyCache.remove(provider);
        await prefs.setBool('keyflag_$provider', false);
      } else {
        await secure.write(key: 'key_$provider', value: v.trim()).timeout(const Duration(seconds: 30));
        _keyCache[provider] = v.trim();
        await prefs.setBool('keyflag_$provider', true);
      }
    } on TimeoutException {
      throw Exception('O chaveiro do sistema não respondeu. No Mac, procure uma janela pedindo permissão ou senha '
          '(às vezes fica atrás do app), toque em "Permitir sempre" e tente de novo.');
    }
  }

  Future<PricingTable> pricing() async {
    final override = prefs.getString('pricing_override');
    if (override != null) {
      try {
        return PricingTable.parse(override);
      } catch (_) {}
    }
    return PricingTable.parse(await rootBundle.loadString('assets/pricing.json'));
  }

  Future<void> setPricingOverride(String json) async {
    PricingTable.parse(json); // valida antes de salvar
    await prefs.setString('pricing_override', json);
  }

  Future<String> pricingJson() async =>
      prefs.getString('pricing_override') ??
      await rootBundle.loadString('assets/pricing.json');
}
