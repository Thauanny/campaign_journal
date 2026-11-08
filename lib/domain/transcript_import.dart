import 'models.dart';

int? _parseClock(String s) {
  final m = RegExp(r'^(?:(\d{1,2}):)?(\d{1,2}):(\d{2})(?:[.,](\d{1,3}))?$').firstMatch(s.trim());
  if (m == null) return null;
  final h = int.tryParse(m.group(1) ?? '0')!;
  final min = int.parse(m.group(2)!), sec = int.parse(m.group(3)!);
  final ms = m.group(4) == null ? 0 : int.parse(m.group(4)!.padRight(3, '0'));
  return ((h * 60 + min) * 60 + sec) * 1000 + ms;
}

/// Converte texto colado/arquivo (.txt, .srt, .vtt) em trechos.
/// Aceita: SRT/VTT, linhas "[mm:ss] texto", "mm:ss texto", "Falante: texto"
/// ou texto corrido (horários estimados a ~150 palavras/min).
List<TranscriptSegment> parseTranscriptText(String raw) {
  final text = raw.replaceAll('\r', '').replaceFirst('﻿', '').trim();
  if (text.isEmpty) return [];
  final segs = <TranscriptSegment>[];

  // SRT / VTT
  final cue = RegExp(r'^((?:\d{1,2}:)?\d{1,2}:\d{2}[.,]\d{1,3})\s*-->\s*((?:\d{1,2}:)?\d{1,2}:\d{2}[.,]\d{1,3})', multiLine: true);
  if (cue.hasMatch(text)) {
    for (final block in text.split(RegExp(r'\n\s*\n'))) {
      final lines = block.split('\n').map((l) => l.trim()).toList();
      final i = lines.indexWhere((l) => cue.hasMatch(l));
      if (i < 0) continue;
      final m = cue.firstMatch(lines[i])!;
      final body = lines.sublist(i + 1).where((l) => l.isNotEmpty).join(' ').replaceAll(RegExp(r'<[^>]+>'), '').trim();
      if (body.isEmpty) continue;
      final (sp, t) = _speaker(body);
      segs.add(TranscriptSegment(_parseClock(m.group(1)!) ?? 0, _parseClock(m.group(2)!) ?? 0, t, speaker: sp));
    }
    return segs;
  }

  final stamp = RegExp(r'^\[?((?:\d{1,2}:)?\d{1,2}:\d{2})\]?\s*[-–]?\s*(.*)$');
  var cursor = 0;
  final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
  // Texto corrido sem quebras: separa por frases para ter trechos úteis.
  final units = lines.length == 1 && !stamp.hasMatch(lines.first)
      ? lines.first.split(RegExp(r'(?<=[.!?])\s+')).where((s) => s.trim().isNotEmpty).toList()
      : lines;
  for (final l in units) {
    final m = stamp.firstMatch(l);
    int start;
    String body;
    if (m != null && _parseClock(m.group(1)!) != null) {
      start = _parseClock(m.group(1)!)!;
      body = m.group(2)!.trim();
    } else {
      start = cursor;
      body = l;
    }
    if (body.isEmpty) continue;
    final (sp, t) = _speaker(body);
    final words = t.split(RegExp(r'\s+')).length;
    final end = start + (words * 400); // ~150 palavras/min
    segs.add(TranscriptSegment(start, end, t, speaker: sp));
    cursor = end;
  }
  return segs;
}

/// "Fulano: fala" → (Fulano, fala). Limita o rótulo para não confundir com frases.
(String?, String) _speaker(String s) {
  final m = RegExp(r'^([\p{L}][\p{L}0-9 _.\-]{0,24}):\s+(.+)$', unicode: true).firstMatch(s);
  if (m == null) return (null, s);
  return (m.group(1)!.trim(), m.group(2)!.trim());
}
