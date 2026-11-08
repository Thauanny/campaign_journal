import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers.dart';
import '../core/recorder_service.dart';
import '../core/rpg_theme.dart';
import '../core/ui.dart';
import '../data/database.dart';
import 'audio_import.dart';
import 'text_import.dart';
import '../core/px_icons.dart';

String _clock(Duration d) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
}

/// Tela 5 — Gravador: botão grande, cronômetro, nível de som, pausar e marcar momento.
class RecorderScreen extends ConsumerStatefulWidget {
  final String cid;
  final String sid;
  const RecorderScreen(this.cid, this.sid, {super.key});
  @override
  ConsumerState<RecorderScreen> createState() => _RecorderScreenState();
}

class _RecorderScreenState extends ConsumerState<RecorderScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat(reverse: true);
  final List<double> _hist = List.filled(28, 0.0, growable: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<bool> _consent() async {
    final s = ref.read(settingsProvider);
    if (s.consentGiven) return true;
    final ok = await confirmDialog(
        context,
        'Consentimento da mesa',
        'Todos na mesa sabem e concordam que a sessão será gravada? '
            'O áudio fica no seu aparelho e pode ser apagado depois da transcrição. '
            'Dica: coloque o celular no centro da mesa.',
        ok: 'Todos concordam');
    if (ok) await s.setConsent();
    return ok;
  }

  Future<void> _start() async {
    if (!await _consent()) return;
    final svc = ref.read(recorderProvider.notifier).svc;
    if (await svc.lowStorage()) {
      if (!mounted) return;
      final go = await confirmDialog(context, 'Pouco espaço livre',
          'O aparelho está com pouco espaço. A gravação pode falhar. Continuar?',
          ok: 'Gravar mesmo assim');
      if (!go) return;
    }
    await svc.start(widget.sid);
    final err = ref.read(recorderProvider).error;
    if (err != null && mounted) snack(context, err);
  }

  Future<void> _stop() async {
    final marks = await ref.read(recorderProvider.notifier).svc.stop();
    final repo = ref.read(repoProvider);
    await repo.updateSession(widget.sid, SessionsCompanion(bookmarks: Value(jsonEncode(marks))));
    if (mounted) context.go('/campaign/${widget.cid}/session/${widget.sid}/recordings?fresh=1');
  }

  static const _marcos = [(5, 'Aquecendo'), (15, 'Primeiro ato'), (30, 'Meia hora'), (60, 'Uma hora!'), (120, 'Maratona')];

  Widget _equalizer(RpgPalette p, bool live) {
    return Container(
      height: 96,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: p.bgDeep, border: Border.all(color: p.border, width: 2)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        for (final v in _hist)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                for (var i = 0; i < 8; i++)
                  Container(
                    height: 7,
                    margin: const EdgeInsets.only(top: 1),
                    color: (live && v * 8 > (7 - i) + 0.2)
                        ? (i < 2 ? p.crimson : i < 4 ? p.gold : p.emerald)
                        : p.border.withValues(alpha: 0.35),
                  ),
              ]),
            ),
          ),
      ]),
    );
  }

  Widget _bigButton(RpgPalette p, {required IconData icon, required String label, required VoidCallback onTap, required Color color}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (_, __) => Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 132 + _pulse.value * 8,
            height: 132 + _pulse.value * 8,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: p.bgDeep, width: 4),
              boxShadow: [BoxShadow(color: color.withValues(alpha: 0.35 + _pulse.value * 0.3), blurRadius: 0, spreadRadius: 4 + _pulse.value * 6), BoxShadow(color: p.bgDeep, offset: const Offset(6, 6))],
            ),
            child: Icon(icon, size: 64, color: onColor(color)),
          ),
          const SizedBox(height: 14),
          Text(label, style: pxText(16, p.text)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.rpg;
    final st = ref.watch(recorderProvider);
    final audios = ref.watch(audiosProvider(widget.sid)).value ?? [];
    final rec = st.state != RecState.idle;
    final live = st.state == RecState.recording;
    ref.listen(recorderProvider, (prev, next) {
      if (next.state == RecState.recording) {
        setState(() {
          _hist.removeAt(0);
          _hist.add(next.level);
        });
      } else if (next.state == RecState.idle && _hist.any((v) => v > 0)) {
        setState(() => _hist.fillRange(0, _hist.length, 0.0));
      }
    });
    final secs = st.elapsed.inSeconds;
    final inBlock = secs % 300;
    final mins = secs ~/ 60;
    return PopScope(
      canPop: !rec,
      child: Scaffold(
        appBar: GameBar(
            title: const Text('Gravador'),
            leading: rec ? const SizedBox() : BackButton(onPressed: () => context.go('/campaign/${widget.cid}/session/${widget.sid}'))),
        body: MaxWidth(
          width: 560,
          ListView(padding: const EdgeInsets.all(16), children: [
            // ── placar: cronômetro e estado ──
            RpgCard(
              accent: live ? p.crimson : p.gold,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  AnimatedBuilder(
                    animation: _pulse,
                    builder: (_, __) => Container(width: 14, height: 14, color: live ? p.crimson.withValues(alpha: 0.4 + _pulse.value * 0.6) : p.muted.withValues(alpha: 0.4)),
                  ),
                  const SizedBox(width: 10),
                  Text(switch (st.state) { RecState.idle => 'PRONTO', RecState.recording => 'GRAVANDO', RecState.paused => 'PAUSADO' }, style: pxText(14, live ? p.crimson : p.muted)),
                ]),
                const SizedBox(height: 8),
                Text(_clock(st.elapsed), style: pxText(54, p.text)),
                if (rec) ...[
                  const SizedBox(height: 14),
                  Row(children: [
                    Icon(PxIcons.archive, size: 22, color: p.gold),
                    const SizedBox(width: 8),
                    Text('BLOCO ${st.blocks + 1}', style: pxText(13, p.gold)),
                    const Spacer(),
                    Text('salva em ${_clock(Duration(seconds: 300 - inBlock)).substring(3)}', style: TextStyle(fontSize: 19, color: p.muted)),
                  ]),
                  const SizedBox(height: 6),
                  XpBar(inBlock / 300, color: p.gold),
                ],
              ]),
            ),
            const SizedBox(height: 16),
            // ── ouvindo a mesa ──
            Row(children: [
              Icon(PxIcons.audioDevice, size: 22, color: p.arcane),
              const SizedBox(width: 8),
              Text(live ? 'OUVINDO A MESA' : 'NÍVEL DE SOM', style: pxText(13, p.muted)),
            ]),
            const SizedBox(height: 6),
            _equalizer(p, live),
            const SizedBox(height: 24),
            // ── controles ──
            if (!rec)
              Center(child: _bigButton(p, icon: PxIcons.audioDevice, label: 'INICIAR GRAVAÇÃO', onTap: _start, color: p.crimson))
            else
              Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Column(children: [
                    RuneButton(st.state == RecState.paused ? 'Retomar' : 'Pausar',
                        icon: st.state == RecState.paused ? PxIcons.play : PxIcons.pause,
                        tone: RuneTone.arcane,
                        compact: true,
                        onPressed: () => st.state == RecState.paused ? ref.read(recorderProvider.notifier).svc.resume() : ref.read(recorderProvider.notifier).svc.pause()),
                    const SizedBox(height: 12),
                    RuneButton('Marcar',
                        icon: PxIcons.bookmarks,
                        compact: true,
                        onPressed: () {
                          ref.read(recorderProvider.notifier).svc.bookmark();
                          snack(context, 'Momento marcado em ${_clock(st.elapsed)}');
                        }),
                  ]),
                ),
                const SizedBox(width: 28),
                _bigButton(p, icon: PxIcons.closeBox, label: 'ENCERRAR', onTap: _stop, color: p.crimson),
              ]),
            const SizedBox(height: 24),
            // ── conquistas ──
            if (rec) ...[
              Row(children: [
                Icon(PxIcons.trophy, size: 22, color: p.gold),
                const SizedBox(width: 8),
                Text('CONQUISTAS', style: pxText(13, p.muted)),
              ]),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final m in _marcos)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    color: mins >= m.$1 ? p.gold : p.border.withValues(alpha: 0.3),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(mins >= m.$1 ? PxIcons.trophy : PxIcons.lock, size: 20, color: mins >= m.$1 ? onColor(p.gold) : p.muted),
                      const SizedBox(width: 6),
                      Text('${m.$1 >= 60 ? '${m.$1 ~/ 60}h' : '${m.$1}min'} · ${m.$2}', style: pxText(12, mins >= m.$1 ? onColor(p.gold) : p.muted)),
                    ]),
                  ),
                if (st.bookmarksSec.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    color: p.arcane,
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(PxIcons.bookmarks, size: 20, color: onColor(p.arcane)),
                      const SizedBox(width: 6),
                      Text('${st.bookmarksSec.length} momento(s)', style: pxText(12, onColor(p.arcane))),
                    ]),
                  ),
              ]),
              const SizedBox(height: 14),
              Text('Blocos de 5 min são salvos em disco automaticamente.', style: TextStyle(fontSize: 19, color: p.muted)),
            ] else ...[
              if (audios.isNotEmpty) ...[
                MenuTile(PxIcons.headphone, 'Histórico de gravações', '${audios.length} áudio(s) · ouvir e apagar', () => context.go('/campaign/${widget.cid}/session/${widget.sid}/recordings'), color: p.gold),
                const SizedBox(height: 16),
              ],
              Text('OU TRAGA O MATERIAL PRONTO', style: pxText(13, p.muted)),
              const SizedBox(height: 8),
              MenuTile(PxIcons.upload, 'Importar áudio', 'Discord, Craig, gravador do celular', () => importAudioFiles(context, ref, widget.sid), color: p.arcane),
              const SizedBox(height: 10),
              MenuTile(PxIcons.clipboard, 'Colar transcrição', 'Já tenho o texto da sessão', () async {
                if (await showTranscriptImport(context, ref, widget.sid) && context.mounted) {
                  context.go('/campaign/${widget.cid}/session/${widget.sid}');
                }
              }, color: p.emerald),
            ],
          ]),
        ),
      ),
    );
  }
}
