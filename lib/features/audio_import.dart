import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;

import '../core/providers.dart';
import '../core/ui.dart';

/// Nome do falante a partir de arquivos do Craig bot ("1-nome.flac" → "nome").
String? craigSpeaker(String filename) {
  final m = RegExp(r'^\d+[-_](.+)\.(flac|ogg|aac|mp3|wav|m4a)$', caseSensitive: false)
      .firstMatch(p.basename(filename));
  return m?.group(1);
}

/// Importa arquivos (Discord, Craig, celular, gravador) para a sessão.
Future<int> importAudioFiles(BuildContext context, WidgetRef ref, String sessionId) async {
  final r = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'm4a', 'wav', 'ogg', 'flac', 'aac', 'opus']);
  final files = r.where((f) => f.path != null).toList()
    ..sort((a, b) => a.name.compareTo(b.name));
  // Várias trilhas "N-nome" = Craig (uma por pessoa, todas começam em 0).
  final craig = files.length > 1 && files.every((f) => craigSpeaker(f.name) != null);
  var n = 0;
  for (final f in files) {
    var dur = 0;
    final player = AudioPlayer();
    try {
      final d = await player.setFilePath(f.path!);
      dur = d?.inSeconds ?? 0;
    } catch (_) {
      // sem duração: o processamento ainda funciona, só o offset fica impreciso
    } finally {
      await player.dispose();
    }
    await ref.read(repoProvider).addAudio(sessionId, f.path!,
        durationSec: dur, origin: 'imported', speaker: craig ? craigSpeaker(f.name) : null);
    n++;
  }
  if (context.mounted) {
    snack(context, craig
        ? '$n trilhas do Craig importadas (uma por jogador).'
        : '$n arquivo(s) importado(s).');
  }
  return n;
}
