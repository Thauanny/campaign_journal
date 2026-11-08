import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import '../core/providers.dart';
import '../core/ui.dart';
import '../domain/models.dart';
import '../domain/transcript_import.dart';
import '../core/px_icons.dart';

/// Cola ou importa (.txt, .srt, .vtt) uma transcrição pronta; pula a etapa de voz.
Future<bool> showTranscriptImport(BuildContext context, WidgetRef ref, String sessionId) async {
  final ctl = TextEditingController();
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(builder: (ctx, set) {
      final n = parseTranscriptText(ctl.text).length;
      return AlertDialog(
        title: const Text('Colar ou importar transcrição'),
        content: SizedBox(
          width: 560,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Cole o texto ou escolha um arquivo. Aceita "[mm:ss] Falante: fala", SRT, VTT ou texto corrido (horários estimados).', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            TextField(controller: ctl, maxLines: 10, onChanged: (_) => set(() {}), decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Cole a transcrição aqui')),
            const SizedBox(height: 8),
            Row(children: [
              OutlinedButton.icon(
                  icon: const Icon(PxIcons.upload),
                  label: const Text('Arquivo .txt/.srt/.vtt'),
                  onPressed: () async {
                    final f = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['txt', 'srt', 'vtt', 'md']);
                    if (f.isNotEmpty && f.first.path != null) {
                      ctl.text = await File(f.first.path!).readAsString();
                      set(() {});
                    }
                  }),
              const Spacer(),
              Text('$n trecho(s)'),
            ]),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: n == 0 ? null : () => Navigator.pop(ctx, true), child: const Text('Importar')),
        ],
      );
    }),
  );
  if (r != true) return false;
  final segs = parseTranscriptText(ctl.text);
  final repo = ref.read(repoProvider);
  final existing = await repo.segmentsOf(sessionId);
  var replace = false;
  if (existing.isNotEmpty && context.mounted) {
    replace = await confirmDialog(context, 'Já existe transcrição', 'Substituir a transcrição atual pelo novo texto? (Cancelar = acrescentar ao final.)', ok: 'Substituir');
  }
  // sem substituir: acrescenta depois do último trecho
  final shifted = (!replace && existing.isNotEmpty)
      ? [for (final s in segs) TranscriptSegment(s.startMs + existing.last.endMs, s.endMs + existing.last.endMs, s.text, speaker: s.speaker)]
      : segs;
  await repo.importTranscript(sessionId, shifted, replace: replace);
  if (context.mounted) snack(context, '${segs.length} trecho(s) importado(s). Toque em "Processar" para gerar o resumo.');
  return true;
}

