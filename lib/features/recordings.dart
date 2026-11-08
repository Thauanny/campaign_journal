import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';

import '../core/providers.dart' hide ProcessingState;
import '../core/px_icons.dart';
import '../core/rpg_theme.dart';
import '../core/ui.dart';
import '../data/database.dart';

String _dur(int s) => s >= 3600
    ? '${s ~/ 3600}h ${(s % 3600 ~/ 60).toString().padLeft(2, '0')}min'
    : s >= 60
        ? '${s ~/ 60}min ${(s % 60).toString().padLeft(2, '0')}s'
        : '${s}s';

/// Gravações da sessão: ouvir, apagar e seguir para a análise da IA.
/// Com [fresh] é a tela de "gravação concluída" logo depois de parar de gravar.
class RecordingsScreen extends ConsumerStatefulWidget {
  final String cid;
  final String sid;
  final bool fresh;
  const RecordingsScreen(this.cid, this.sid, {this.fresh = false, super.key});
  @override
  ConsumerState<RecordingsScreen> createState() => _RecordingsState();
}

class _RecordingsState extends ConsumerState<RecordingsScreen> {
  final _player = AudioPlayer();
  String? _playing;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle(Audio a) async {
    try {
      if (_playing == a.id && _player.playing) {
        await _player.pause();
        setState(() {});
        return;
      }
      if (_playing != a.id) {
        if (!File(a.filePath).existsSync()) {
          if (mounted) snack(context, 'O arquivo deste áudio não foi encontrado.');
          return;
        }
        await _player.setFilePath(a.filePath);
        _playing = a.id;
        _player.playerStateStream.listen((s) {
          if (s.processingState == ProcessingState.completed && mounted) {
            _player.pause();
            _player.seek(Duration.zero);
            setState(() {});
          }
        });
      }
      _player.play();
      setState(() {});
    } catch (e) {
      if (mounted) snack(context, 'Não consegui tocar: $e');
    }
  }

  Future<void> _delete(Audio a) async {
    if (!await confirmDialog(context, 'Apagar gravação?', 'O arquivo de áudio será removido do aparelho. A transcrição e o que a IA já extraiu continuam.', ok: 'Apagar')) return;
    if (_playing == a.id) {
      await _player.stop();
      _playing = null;
    }
    await ref.read(repoProvider).deleteAudio(a.id);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.rpg;
    final audios = ref.watch(audiosProvider(widget.sid)).value ?? [];
    final total = audios.where((a) => a.speaker == null).fold<int>(0, (x, a) => x + a.durationSec);
    final back = '/campaign/${widget.cid}/session/${widget.sid}';
    return Scaffold(
      appBar: GameBar(
        title: Text(widget.fresh ? 'Gravação concluída' : 'Gravações'),
        leading: BackButton(onPressed: () => context.go(back)),
      ),
      body: MaxWidth(
        width: 640,
        ListView(padding: const EdgeInsets.all(16), children: [
          RpgCard(
            accent: widget.fresh ? p.gold : p.arcane,
            child: Row(children: [
              Container(width: 56, height: 56, color: p.gold, child: Icon(widget.fresh ? PxIcons.trophy : PxIcons.headphone, size: 34, color: onColor(p.gold))),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.fresh ? 'MISSÃO CUMPRIDA!' : 'HISTÓRICO', style: pxText(15, p.text)),
                const SizedBox(height: 2),
                Text(audios.isEmpty ? 'Nenhuma gravação nesta sessão.' : '${audios.length} gravação(ões) · ${_dur(total)} no total', style: TextStyle(fontSize: 21, color: p.muted)),
              ])),
            ]),
          ),
          const SizedBox(height: 16),
          if (audios.isNotEmpty) ...[
            Text('OUÇA ANTES DE ANALISAR', style: pxText(13, p.muted)),
            const SizedBox(height: 8),
          ],
          for (final a in audios)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: RpgCard(
                padding: const EdgeInsets.all(10),
                child: Row(children: [
                  IconButton(
                    tooltip: 'Ouvir',
                    iconSize: 32,
                    icon: Icon(_playing == a.id && _player.playing ? PxIcons.pause : PxIcons.play, color: p.gold),
                    onPressed: () => _toggle(a),
                  ),
                  const SizedBox(width: 6),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(a.speaker != null ? 'Faixa de ${a.speaker}' : a.origin == 'recorded' ? 'Bloco ${a.ord + 1}' : 'Áudio importado ${a.ord + 1}', style: pxText(14, p.text)),
                    Row(children: [
                      Icon(PxIcons.clock, size: 18, color: p.muted),
                      const SizedBox(width: 4),
                      Text(_dur(a.durationSec), style: TextStyle(fontSize: 20, color: p.muted)),
                      const SizedBox(width: 12),
                      Icon(a.transcribed ? PxIcons.checkDouble : PxIcons.hourglass, size: 18, color: a.transcribed ? p.emerald : p.muted),
                      const SizedBox(width: 4),
                      Text(a.transcribed ? 'transcrito' : 'a transcrever', style: TextStyle(fontSize: 20, color: p.muted)),
                    ]),
                  ])),
                  IconButton(tooltip: 'Apagar', icon: Icon(PxIcons.trash, color: p.crimson), onPressed: () => _delete(a)),
                ]),
              ),
            ),
          const SizedBox(height: 14),
          if (audios.isNotEmpty)
            RuneButton('Analisar com IA', icon: PxIcons.zap, onPressed: () {
              _player.pause();
              context.go('/campaign/${widget.cid}/session/${widget.sid}/process?go=1');
            }),
          const SizedBox(height: 12),
          Wrap(spacing: 12, runSpacing: 12, children: [
            RuneButton('Gravar mais', icon: PxIcons.audioDevice, tone: RuneTone.ghost, compact: true, onPressed: () => context.go('/campaign/${widget.cid}/session/${widget.sid}/record')),
            RuneButton('Ver sessão', icon: PxIcons.book, tone: RuneTone.ghost, compact: true, onPressed: () => context.go(back)),
          ]),
        ]),
      ),
    );
  }
}
