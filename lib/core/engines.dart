import 'package:flutter/widgets.dart';

import 'px_icons.dart';

enum EngineCost { free, paid }

/// Uma opção de IA que o usuário pode escolher como "IA ativa".
class EngineInfo {
  final String id;
  final String name;
  final String maker;
  final EngineCost cost;
  final IconData icon;
  final String blurb;
  final List<String> pros;
  final List<String> cons;

  /// Provedor da chave de API (nulo para local e sem IA).
  final String? keyProvider;
  final String? keyUrl;
  final String? keyLabel;
  final String? textModel;
  final bool audio;
  const EngineInfo(this.id, this.name, this.maker, this.cost, this.icon, this.blurb,
      {this.pros = const [], this.cons = const [], this.keyProvider, this.keyUrl, this.keyLabel, this.textModel, this.audio = true});
  bool get needsKey => keyProvider != null;
  bool get free => cost == EngineCost.free;
}

const engines = <EngineInfo>[
  EngineInfo('gemini', 'Gemini', 'Google', EngineCost.free, PxIcons.cloud,
      'Nuvem com plano grátis. Ouve áudio e escreve resumos.',
      pros: ['Ótima qualidade em português', 'Áudio e texto com 1 chave', 'Funciona no celular'],
      cons: ['Texto/áudio vão para o Google', 'Tem limite diário (zera à meia-noite do horário do Pacífico)', 'Sessões longas podem bater no limite do plano grátis'],
      keyProvider: 'gemini',
      keyUrl: 'https://aistudio.google.com/apikey',
      keyLabel: 'Google AI Studio',
      textModel: 'auto'),
  EngineInfo('groq', 'Groq', 'Groq', EngineCost.free, PxIcons.zap,
      'Nuvem com plano grátis, muito rápida (Whisper + Llama).',
      pros: ['Transcrição de áudio muito rápida', 'Sem cartão de crédito', 'Funciona no celular'],
      cons: ['Limites por minuto e por dia, bem baixos no plano grátis', 'Sessões longas ficam lentas (o app espera entre as partes)', 'Não recebe PDF direto (o app converte em imagem)', 'Texto/áudio vão para a Groq'],
      keyProvider: 'groq',
      keyUrl: 'https://console.groq.com/keys',
      keyLabel: 'Groq Console',
      textModel: 'llama-3.3-70b-versatile'),
  EngineInfo('local', 'Neste computador', 'Ollama + Whisper', EngineCost.free, PxIcons.deviceLaptop,
      'Tudo roda na sua máquina. Privado e sem limites.',
      pros: ['100% privado e offline', 'Sem limites de uso'],
      cons: ['Baixa ~5 GB uma vez', 'Qualidade média em português', 'Não lê ficha em imagem/PDF (usa outra IA com chave)', 'Só no computador (celular usa só texto)']),
  EngineInfo('claude', 'Claude', 'Anthropic', EngineCost.paid, PxIcons.script,
      'Melhor escrita. Pago por uso. Só texto (áudio usa outra IA).',
      pros: ['Resumos e crônicas excelentes'],
      cons: ['Cobrado por uso', 'Não ouve áudio'],
      keyProvider: 'claude',
      keyUrl: 'https://console.anthropic.com/settings/keys',
      keyLabel: 'Anthropic Console',
      audio: false),
  EngineInfo('openai', 'OpenAI', 'GPT + Whisper', EngineCost.paid, PxIcons.sliders,
      'Pago por uso. Ouve áudio (Whisper) e escreve resumos.',
      pros: ['Áudio e texto com 1 chave'],
      cons: ['Cobrado por uso'],
      keyProvider: 'openai',
      keyUrl: 'https://platform.openai.com/api-keys',
      keyLabel: 'OpenAI Platform'),
  EngineInfo('none', 'Sem IA', 'Resumo simples', EngineCost.free, PxIcons.list,
      'Seleciona frases da sessão. Não ouve áudio; só texto colado.',
      pros: ['Zero configuração'],
      cons: ['Resumo fraco e entidades pouco confiáveis'],
      audio: false),
];

EngineInfo? engineById(String? id) {
  for (final e in engines) {
    if (e.id == id) return e;
  }
  return null;
}

/// Limites práticos de cada IA (plano gratuito/padrão): o app divide o trabalho,
/// espera entre chamadas e corta o contexto para caber em cada uma.
class EngineLimits {
  /// Tamanho máximo (tokens) de cada parte da transcrição enviada de uma vez.
  final int chunkTokens;

  /// Intervalo mínimo entre duas chamadas (respeita limites por minuto).
  final Duration minGap;

  /// Quantas entidades já conhecidas vão no contexto de cada chamada.
  final int knownMax;

  /// Teto de caracteres do contexto em perguntas e planejamento.
  final int contextChars;

  /// Tamanho máximo de um arquivo de áudio enviado de uma vez (MB); 0 = sem limite.
  final int audioMaxMb;
  const EngineLimits({required this.chunkTokens, required this.minGap, required this.knownMax, required this.contextChars, required this.audioMaxMb});
}

EngineLimits limitsFor(String? engine) => switch (engine) {
      // Gemini grátis: ~10–15 chamadas/min, contexto enorme.
      'gemini' => const EngineLimits(chunkTokens: 12000, minGap: Duration(seconds: 5), knownMax: 150, contextChars: 120000, audioMaxMb: 18),
      // Groq grátis: poucos milhares de tokens POR MINUTO (6–12k conforme o modelo).
      'groq' => const EngineLimits(chunkTokens: 2200, minGap: Duration(seconds: 8), knownMax: 25, contextChars: 11000, audioMaxMb: 24),
      // Ollama: janela de contexto pequena por padrão; sem limite de taxa.
      'local' => const EngineLimits(chunkTokens: 3000, minGap: Duration.zero, knownMax: 30, contextChars: 14000, audioMaxMb: 0),
      'openai' => const EngineLimits(chunkTokens: 12000, minGap: Duration.zero, knownMax: 150, contextChars: 120000, audioMaxMb: 24),
      'claude' => const EngineLimits(chunkTokens: 12000, minGap: Duration.zero, knownMax: 150, contextChars: 120000, audioMaxMb: 0),
      _ => const EngineLimits(chunkTokens: 6000, minGap: Duration.zero, knownMax: 60, contextChars: 40000, audioMaxMb: 0),
    };
