/// Modelos de transporte entre IA e domínio (sem dependência de banco).
class TranscriptSegment {
  final int startMs;
  final int endMs;
  final String text;
  final String? speaker;
  final double confidence;
  const TranscriptSegment(this.startMs, this.endMs, this.text,
      {this.speaker, this.confidence = 1.0});
}

/// Lê "mm:ss" ou "h:mm:ss" (também "[mm:ss]") e devolve milissegundos.
int? parseClock(Object? v) {
  if (v == null) return null;
  final m = RegExp(r'(\d+):(\d{2})(?::(\d{2}))?').firstMatch(v.toString());
  if (m == null) return null;
  final a = int.parse(m.group(1)!), b = int.parse(m.group(2)!);
  final c = m.group(3);
  return (c == null ? a * 60 + b : a * 3600 + b * 60 + int.parse(c)) * 1000;
}

/// Horário de um item da IA: prefere "at" ("mm:ss", copiado da linha) e cai para
/// "at_ms" (milissegundos) se for o único.
int? clockOf(Map<String, dynamic> j) =>
    parseClock(j['at']) ?? (j['at_ms'] is num ? (j['at_ms'] as num).toInt() : null);

class ExtractedEntity {
  /// npc | location | quest | item | faction
  final String kind;
  final String name;
  final List<String> aliases;
  final String description;
  final String status;
  final String attr;
  final String giver;
  final String reward;
  final String parentName;

  /// Só para feitiços: quem lançou, em quem, de que lado (hero|enemy) e o resultado.
  final String caster;
  final String target;
  final String side;
  final String result;
  final int? atMs;
  final String quote;
  const ExtractedEntity({
    required this.kind,
    required this.name,
    this.aliases = const [],
    this.description = '',
    this.status = '',
    this.attr = '',
    this.giver = '',
    this.reward = '',
    this.parentName = '',
    this.caster = '',
    this.target = '',
    this.side = '',
    this.result = '',
    this.atMs,
    this.quote = '',
  });

  /// A IA às vezes copia o molde do prompt ("npc: inimigo", "aliado|neutro").
  /// Fica só com o valor.
  static String cleanValue(Object? v) {
    var t = (v ?? '').toString().trim();
    t = t.replaceFirst(RegExp(r'^(npc|quest|miss[aã]o|faction|fac[cç][aã]o|location|local|item|spell|feiti[cç]o)\s*:\s*', caseSensitive: false), '');
    if (t.contains('|')) t = t.split('|').first.trim();
    return t;
  }

  /// Normaliza o lado: hero | enemy | neutral (ou vazio).
  static String cleanSide(Object? v) {
    final t = (v ?? '').toString().toLowerCase();
    if (t.contains('her') || t.contains('alia') || t.contains('grupo') || t.contains('party')) return 'hero';
    if (t.contains('enem') || t.contains('inimig') || t.contains('mons')) return 'enemy';
    if (t.contains('neutr')) return 'neutral';
    return '';
  }

  ExtractedEntity copyWith({String? caster, String? target}) => ExtractedEntity(
      kind: kind, name: name, aliases: aliases, description: description, status: status, attr: attr, giver: giver, reward: reward,
      parentName: parentName, caster: caster ?? this.caster, target: target ?? this.target, side: side, result: result, atMs: atMs, quote: quote);

  static const kinds = {'npc', 'location', 'quest', 'item', 'faction', 'spell'};

  static ExtractedEntity? fromJson(Map<String, dynamic> j) {
    final kind = (j['kind'] ?? '').toString();
    final name = (j['name'] ?? '').toString().trim();
    if (!kinds.contains(kind) || name.isEmpty) return null;
    final al = j['aliases'];
    return ExtractedEntity(
      kind: kind,
      name: name,
      aliases: al is List ? al.map((e) => e.toString()).toList() : const [],
      description: (j['description'] ?? '').toString(),
      status: cleanValue(j['status']),
      attr: cleanValue(j['attr']),
      giver: (j['giver'] ?? '').toString(),
      reward: (j['reward'] ?? '').toString(),
      parentName: (j['parent'] ?? '').toString(),
      caster: (j['caster'] ?? '').toString(),
      target: (j['target'] ?? '').toString(),
      side: cleanSide(j['side']),
      result: (j['result'] ?? '').toString(),
      atMs: clockOf(j),
      quote: (j['quote'] ?? '').toString(),
    );
  }
}

class ExtractedEvent {
  final String text;
  final int? atMs;
  const ExtractedEvent(this.text, [this.atMs]);
}

/// Fato de combate ou recompensa: dano, cura, XP, condição ou saque.
class ExtractedFact {
  /// damage | heal | xp | condition | loot
  final String kind;
  final String actor;
  final String target;

  /// Lado do ALVO: hero | enemy | neutral.
  final String side;
  final int? amount;
  final String text;
  final int? atMs;
  final String quote;
  const ExtractedFact({required this.kind, this.actor = '', this.target = '', this.side = '', this.amount, this.text = '', this.atMs, this.quote = ''});

  ExtractedFact copyWith({String? actor, String? target}) => ExtractedFact(
      kind: kind, actor: actor ?? this.actor, target: target ?? this.target, side: side, amount: amount, text: text, atMs: atMs, quote: quote);

  static const kinds = {'damage', 'heal', 'xp', 'condition', 'loot'};

  static ExtractedFact? fromJson(Map<String, dynamic> j) {
    final kind = (j['kind'] ?? '').toString().toLowerCase();
    if (!kinds.contains(kind)) return null;
    final a = j['amount'];
    return ExtractedFact(
      kind: kind,
      actor: (j['actor'] ?? '').toString().trim(),
      target: (j['target'] ?? '').toString().trim(),
      side: ExtractedEntity.cleanSide(j['side']),
      amount: a is num ? a.toInt() : int.tryParse('${a ?? ''}'),
      text: (j['text'] ?? '').toString().trim(),
      atMs: clockOf(j),
      quote: (j['quote'] ?? '').toString(),
    );
  }
}

class ExtractionResult {
  final List<ExtractedEntity> entities;
  final List<ExtractedEvent> events;
  final List<ExtractedFact> facts;
  const ExtractionResult(this.entities, this.events, {this.facts = const []});
  static const empty = ExtractionResult([], []);
}

class SessionSummary {
  final String short;
  final String narrative;
  final String previouslyOn;

  /// Mistérios, objetivos e perguntas que ficaram sem resposta ("ganchos").
  final List<String> openThreads;
  const SessionSummary(this.short, this.narrative, this.previouslyOn, {this.openThreads = const []});
}

/// Conhecimento prévio da campanha, enviado como contexto (e cacheável).
class KnownEntity {
  final String kind;
  final String name;
  final List<String> aliases;
  final String status;
  const KnownEntity(this.kind, this.name, this.aliases, this.status);
}

class UsageInfo {
  final int inputTokens;
  final int outputTokens;
  const UsageInfo(this.inputTokens, this.outputTokens);
}

enum ProcessingMode { free, balanced, premium }

extension ProcessingModeX on ProcessingMode {
  String get label => switch (this) {
        ProcessingMode.free => 'Grátis',
        ProcessingMode.balanced => 'Equilibrado',
        ProcessingMode.premium => 'Premium',
      };
  String get key => name;
  static ProcessingMode parse(String s) => ProcessingMode.values
      .firstWhere((m) => m.name == s, orElse: () => ProcessingMode.free);
}
