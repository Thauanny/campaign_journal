import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/engines.dart';
import '../core/providers.dart';
import '../core/px_icons.dart';
import '../core/rpg_theme.dart';
import '../core/ui.dart';
import '../domain/pipeline.dart';
import 'ai_screen.dart';
import 'quota_banner.dart';

const _steps = [
  ('config', 'Preparar a IA', 'Conferindo a IA escolhida e o que a campanha já sabe.'),
  ('transcribe', 'Ouvir o áudio', 'Transformando o áudio em texto.'),
  ('clean', 'Limpar o texto', 'Juntando os blocos e tirando repetições.'),
  ('extract', 'Achar NPCs, locais, missões e feitiços', 'A IA lê o texto e procura o que importa para a campanha.'),
  ('merge', 'Comparar com a campanha', 'Conferindo a enciclopédia para não duplicar nada.'),
  ('summarize', 'Escrever a crônica', 'A IA escreve o resumo, o "anteriormente em…" e os ganchos em aberto.'),
  ('done', 'Pronto para revisão', 'Tudo certo: agora é com você.'),
];

String _mmss(Duration d) => '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

/// Processamento: usa a IA ativa (escolhida em Configurações) em tudo e mostra
/// ao vivo o que ela está fazendo. Com [autostart], começa sozinho.
class ProcessingScreen extends ConsumerStatefulWidget {
  final String cid;
  final String sid;
  final bool autostart;
  const ProcessingScreen(this.cid, this.sid, {super.key, this.autostart = false});
  @override
  ConsumerState<ProcessingScreen> createState() => _ProcessingState();
}

class _ProcessingState extends ConsumerState<ProcessingScreen> with SingleTickerProviderStateMixin {
  CostEstimate? _est;
  String? _err;
  Timer? _tick;
  final _scroll = ScrollController();
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);

  String get _here => '/campaign/${widget.cid}/session/${widget.sid}/process?go=1';

  @override
  void initState() {
    super.initState();
    _refresh();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && (ref.read(processingProvider)[widget.sid]?.running ?? false)) setState(() {});
    });
    if (widget.autostart) WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    _tick?.cancel();
    _pulse.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    try {
      final s = ref.read(settingsProvider);
      final e = await ref.read(processorProvider).estimate(widget.sid, s.engineMode);
      if (mounted) setState(() { _est = e; _err = null; });
    } catch (e) {
      if (mounted) setState(() => _err = '$e');
    }
  }

  Future<void> _start() async {
    final s = ref.read(settingsProvider);
    final eng = s.engine;
    if (eng == null) {
      context.go('/ai?back=${Uri.encodeComponent(_here)}');
      return;
    }
    final st = await ref.read(aiStatusProvider.future);
    if (!st.ready(eng)) {
      if (mounted) context.go('/ai?back=${Uri.encodeComponent(_here)}');
      return;
    }
    if (s.engineIsPaid && mounted) {
      final ok = await confirmDialog(context, 'Enviar para a nuvem?',
          'O texto da sessão (e o áudio, se for o caso) será enviado ao provedor com a sua chave. Custo estimado ≈ US\$ ${(_est?.usd ?? 0).toStringAsFixed(3)}.',
          ok: 'Processar');
      if (!ok) return;
    }
    await s.setDefaultMode(s.engineMode);
    ref.read(processingProvider.notifier).run(widget.sid, s.engineMode);
  }

  String _hint(String step, Duration inStep) {
    if (!{'extract', 'summarize', 'transcribe'}.contains(step)) return '';
    final s = inStep.inSeconds;
    if (s > 100) return 'Está demorando mais que o normal. O app tenta de novo sozinho e troca de modelo se o servidor falhar — veja o registro abaixo.';
    if (s > 25) return 'Esta etapa costuma levar de 20 a 90 segundos. Está tudo certo; se o servidor falhar, o app avisa e tenta de novo.';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.rpg;
    final ps = ref.watch(processingProvider)[widget.sid];
    final active = ref.watch(engineProvider);
    final info = engineById(active);
    final running = ps?.running ?? false;
    final failed = ps?.error != null;
    final done = ps?.step == 'done' && !failed;
    final idx = _steps.indexWhere((s) => s.$1 == ps?.step);
    final now = DateTime.now();
    final total = ps?.startedAt == null ? Duration.zero : now.difference(ps!.startedAt!);
    final inStep = ps?.stepStartedAt == null ? Duration.zero : now.difference(ps!.stepStartedAt!);

    ref.listen(processingProvider.select((m) => m[widget.sid]?.log.length ?? 0), (_, __) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      });
    });

    final stageColor = failed ? p.crimson : (done ? p.emerald : p.gold);
    final progress = ps == null ? 0.0 : (done ? 1.0 : ((idx < 0 ? 0 : idx) + ps.fraction.clamp(0, 1)) / (_steps.length - 1));

    return Scaffold(
      appBar: GameBar(title: const Text('Processar'), leading: BackButton(onPressed: () => context.go('/campaign/${widget.cid}/session/${widget.sid}'))),
      body: MaxWidth(
        width: 760,
        ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 48), children: [
          const QuotaBanner(),
          const AiBanner(),
          // ── IA em uso ──
          if (!running) RpgCard(
            accent: running ? p.gold : p.arcane,
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              AnimatedBuilder(
                animation: _pulse,
                builder: (_, child) => Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(color: p.bgDeep, boxShadow: running ? [BoxShadow(color: p.gold.withValues(alpha: .15 + .35 * _pulse.value), blurRadius: 14 + 8 * _pulse.value)] : null),
                  child: child,
                ),
                child: Icon(info?.icon ?? PxIcons.alert, color: p.gold, size: 36),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('IA USADA', style: pxText(11, p.muted)),
                const SizedBox(height: 4),
                Text((info?.name ?? 'Nenhuma').toUpperCase(), style: pxText(18, p.text)),
              ])),
              if (ps != null) Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('TEMPO', style: pxText(11, p.muted)),
                const SizedBox(height: 4),
                Text(_mmss(total), style: pxText(18, p.gold)),
              ]),
              if (!running && !done) Padding(padding: const EdgeInsets.only(left: 10), child: RuneButton('Trocar', compact: true, tone: RuneTone.ghost, onPressed: () => context.go('/ai?back=${Uri.encodeComponent(_here)}'))),
            ]),
          ),
          const SizedBox(height: 12),
          // ── antes de começar ──
          if (ps == null) ...[
            RpgCard(
              child: _est == null
                  ? Text(_err ?? 'Calculando…', style: const TextStyle(fontSize: 22))
                  : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(_est!.usd == 0 ? 'CUSTO: GRÁTIS' : 'CUSTO ≈ US\$ ${_est!.usd.toStringAsFixed(3)}', style: pxText(15, _est!.usd == 0 ? p.emerald : p.gold)),
                      const SizedBox(height: 8),
                      Text('~${_est!.minutes} min de áudio · ~${_est!.tokens} tokens de texto', style: const TextStyle(fontSize: 22)),
                    ]),
            ),
            const SizedBox(height: 16),
            Center(child: RuneButton('Processar agora', icon: PxIcons.play, onPressed: _start)),
          ] else ...[
            // ── AGORA ──
            RpgCard(
              accent: stageColor,
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(failed ? 'PAROU COM ERRO' : (done ? 'CONCLUÍDO' : 'AGORA'), style: pxText(12, stageColor)),
                  const Spacer(),
                  if (running) PxLoader(color: stageColor),
                ]),
                const SizedBox(height: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (c, a) => FadeTransition(opacity: a, child: SlideTransition(position: Tween(begin: const Offset(0, .25), end: Offset.zero).animate(a), child: c)),
                  child: Column(
                    key: ValueKey(ps.step),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text((idx < 0 ? 'Processando' : _steps[idx].$2).toUpperCase(), style: pxText(18, p.text)),
                      const SizedBox(height: 6),
                      Text(idx < 0 ? '' : _steps[idx].$3, style: TextStyle(fontSize: 22, color: p.muted, height: 1.1)),
                      if (running && ps.log.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(ps.log.last.$2, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 21, color: p.gold, height: 1.25))),
                    ],
                  ),
                ),
                if (running) ...[
                  const SizedBox(height: 10),
                  Row(children: [
                    Icon(PxIcons.clock, size: 24, color: p.muted),
                    const SizedBox(width: 6),
                    Text('Nesta etapa há ${_mmss(inStep)}', style: TextStyle(fontSize: 21, color: p.muted)),
                  ]),
                  if (_hint(ps.step, inStep).isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        color: p.bgDeep,
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Icon(PxIcons.infoBox, size: 24, color: p.arcane),
                          const SizedBox(width: 10),
                          Expanded(child: Text(_hint(ps.step, inStep), style: TextStyle(fontSize: 20, color: p.text, height: 1.05))),
                        ]),
                      ),
                    ),
                ],
                const SizedBox(height: 14),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOut,
                  builder: (_, v, __) => XpBar(v, color: stageColor),
                ),
                const SizedBox(height: 4),
                Align(alignment: Alignment.centerRight, child: Text('${(progress * 100).round()}%', style: pxText(12, p.muted))),
                if (failed) ...[
                  const SizedBox(height: 10),
                  Text(ps.error!.replaceFirst('Exception: ', ''), style: TextStyle(fontSize: 22, color: p.crimson, height: 1.1)),
                  const SizedBox(height: 14),
                  Wrap(spacing: 10, runSpacing: 10, children: [
                    RuneButton('Tentar de novo', icon: PxIcons.reload, onPressed: _start),
                    RuneButton('Trocar de IA', icon: PxIcons.zap, tone: RuneTone.ghost, onPressed: () => context.go('/ai?back=${Uri.encodeComponent(_here)}')),
                  ]),
                  const SizedBox(height: 4),
                  Text('Blocos já transcritos ficam salvos: ao tentar de novo, o app retoma de onde parou.', style: TextStyle(fontSize: 19, color: p.muted, height: 1.05)),
                ],
              ]),
            ),
            // ── detalhes sob demanda ──
            const SizedBox(height: 16),
            PxExpandable(
              title: 'Etapas',
              icon: PxIcons.list,
              flat: true,
              hint: idx < 0 ? null : '${(idx + 1).clamp(1, _steps.length)} de ${_steps.length}',
              child: Column(children: [
                for (var i = 0; i < _steps.length; i++)
                  _StepRow(title: _steps[i].$2, state: failed && i == idx ? 2 : (i < idx || done ? 1 : (i == idx ? 3 : 0)), took: ps.stepTimes[_steps[i].$1], pulse: _pulse),
              ]),
            ),
            PxExpandable(
              title: 'Registro da IA',
              icon: PxIcons.scriptText,
              flat: true,
              hint: '${ps.log.length} linhas',
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Terminal: sempre preto, em qualquer tema.
                Container(
                  height: 240,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFF0A0C14), border: Border.all(color: p.border, width: 2)),
                  child: ListView(controller: _scroll, children: [
                    for (final e in ps.log)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('[${_mmss(e.$1.difference(ps.startedAt ?? e.$1))}] ', style: const TextStyle(color: Color(0xFFFFD166), fontSize: 19)),
                          Expanded(child: Text(e.$2, style: TextStyle(color: e.$2.startsWith('Erro') ? const Color(0xFFFF8A8A) : const Color(0xFFD7DEFF), fontSize: 20, height: 1.15))),
                        ]),
                      ),
                    if (running)
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Align(alignment: Alignment.centerLeft, child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text('> ', style: TextStyle(color: Color(0xFF7EE0A1), fontSize: 20)),
                          BlinkCursor(color: Color(0xFF7EE0A1)),
                        ])),
                      ),
                  ]),
                ),
                TextButton(onPressed: () {
                  Clipboard.setData(ClipboardData(text: ps.log.map((e) => '[${_mmss(e.$1.difference(ps.startedAt ?? e.$1))}] ${e.$2}').join('\n')));
                  snack(context, 'Registro copiado.');
                }, child: const Text('COPIAR REGISTRO')),
              ]),
            ),
            // ── resultado ──
            if (done) _Result(cid: widget.cid, sid: widget.sid, total: total),
          ],
        ]),
      ),
    );
  }
}

/// state: 0 = aguardando, 1 = feita, 2 = erro, 3 = em andamento
class _StepRow extends StatelessWidget {
  final String title;
  final int state;
  final Duration? took;
  final Animation<double> pulse;
  const _StepRow({required this.title, required this.state, required this.took, required this.pulse});
  @override
  Widget build(BuildContext context) {
    final p = context.rpg;
    final color = switch (state) { 1 => p.emerald, 2 => p.crimson, 3 => p.gold, _ => p.muted };
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: state == 3 ? p.gold.withValues(alpha: .12) : Colors.transparent,
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(children: [
        SizedBox(
          width: 28,
          child: state == 3
              ? FadeTransition(opacity: Tween(begin: .45, end: 1.0).animate(pulse), child: Icon(PxIcons.hourglass, color: color))
              : Icon(state == 1 ? PxIcons.checkboxOn : (state == 2 ? PxIcons.alert : PxIcons.checkbox), color: color),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(title.toUpperCase(), style: pxText(13, state == 0 ? p.muted : p.text))),
        if (took != null && state == 1) Text(_mmss(took!), style: TextStyle(color: p.muted, fontSize: 20)),
      ]),
    );
  }
}

class _Result extends ConsumerWidget {
  final String cid, sid;
  final Duration total;
  const _Result({required this.cid, required this.sid, required this.total});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.rpg;
    final ms = ref.watch(sessionMentionsProvider(sid)).value ?? [];
    final ents = {for (final e in ref.watch(allEntitiesProvider(cid)).value ?? []) e.id: e};
    final spells = ms.where((m) => ents[m.entityId]?.kind == 'spell').length;
    final events = ref.watch(eventsProvider(sid)).value ?? [];
    final threads = (ref.watch(notesProvider((cid, 'thread'))).value ?? []).where((n) => n.sessionId == sid).length;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionTitle('O que a IA achou'),
      Wrap(spacing: 10, runSpacing: 10, children: [
        StatTile(PxIcons.map, '${ms.length - spells}', 'descobertas', p.emerald),
        StatTile(PxIcons.moonStars, '$spells', 'usos de feitiço', p.kind('spell')),
        StatTile(PxIcons.zap, '${events.length}', 'eventos', p.gold),
        StatTile(PxIcons.alert, '$threads', 'ganchos', p.arcane),
        StatTile(PxIcons.clock, _mmss(total), 'tempo', p.muted),
      ]),
      const SizedBox(height: 18),
      Center(child: RuneButton('Revisar descobertas', icon: PxIcons.scale, tone: RuneTone.arcane, onPressed: () => context.go('/campaign/$cid/session/$sid/review'))),
    ]);
  }
}
