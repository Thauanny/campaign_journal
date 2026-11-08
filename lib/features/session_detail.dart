import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';

import '../core/providers.dart';
import '../core/rpg_theme.dart';
import '../core/ui.dart';
import '../data/database.dart';
import '../domain/pipeline.dart';
import 'audio_import.dart';
import 'journey.dart';
import 'sessions.dart' show confirmDeleteSession;
import 'text_import.dart';
import 'export_actions.dart';
import '../core/px_icons.dart';

/// Tela 7 — Sessão: Crônica, Pergaminho (transcrição), Descobertas e Jornada.
class SessionDetailScreen extends ConsumerWidget {
  final String cid;
  final String sid;
  const SessionDetailScreen(this.cid, this.sid, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(sessionProvider(sid)).value;
    if (s == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: GameBar(
          title: Text('Sessão ${s.number}'),
          leading: BackButton(onPressed: () => context.go('/campaign/$cid/sessions')),
          actions: [
            StatusChip(s.status),
            PopupMenuButton<String>(
              icon: Icon(PxIcons.moreHorizontal, color: context.rpg.text),
              onSelected: (v) async {
                if (v == 'delete') {
                  if (!await confirmDeleteSession(context, ref, sid, s.number)) return;
                  if (context.mounted) context.go('/campaign/$cid/sessions');
                } else if (v == 'recordings') {
                  context.go('/campaign/$cid/session/$sid/recordings');
                } else if (v == 'record') {
                  context.go('/campaign/$cid/session/$sid/record');
                } else if (v == 'import') {
                  await importAudioFiles(context, ref, sid);
                } else if (v == 'export') {
                  await showExportSheet(context, ref, cid, sessionId: sid);
                } else if (v == 'text') {
                  await showTranscriptImport(context, ref, sid);
                } else if (v == 'reprocess') {
                  context.go('/campaign/$cid/session/$sid/process');
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'record', child: Text('Gravar mais')),
                PopupMenuItem(value: 'recordings', child: Text('Gravações (ouvir e apagar)')),
                PopupMenuItem(value: 'import', child: Text('Importar áudio')),
                PopupMenuItem(value: 'text', child: Text('Colar/importar transcrição')),
                PopupMenuItem(value: 'reprocess', child: Text('Reprocessar com IA')),
                PopupMenuItem(value: 'export', child: Text('Exportar…')),
                PopupMenuItem(value: 'delete', child: Text('Excluir sessão')),
              ],
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: MaxWidth(
          width: 1000,
          Column(children: [
            _QuestHeader(cid, sid, s),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 10, 10),
              child: GameTabs([
                (PxIcons.bookOpen, 'Crônica'),
                (PxIcons.scriptText, 'Pergaminho'),
                (PxIcons.map, 'Descobertas'),
                (PxIcons.timeline, 'Jornada'),
              ]),
            ),
            Expanded(child: TabBarView(children: [
              _SummaryTab(cid, s),
              _TranscriptTab(sid),
              _EntitiesTab(cid, sid),
              SessionTimelineTab(cid, sid),
            ])),
          ]),
        ),
      ),
    );
  }
}

/// Cabeçalho da sessão: uma linha de resumo e a ação principal. Nada mais.
class _QuestHeader extends ConsumerWidget {
  final String cid;
  final String sid;
  final Session s;
  const _QuestHeader(this.cid, this.sid, this.s);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.rpg;
    final audios = ref.watch(audiosProvider(sid)).value ?? [];
    final ms = ref.watch(sessionMentionsProvider(sid)).value ?? [];
    final evs = ref.watch(eventsProvider(sid)).value ?? [];
    final proc = ref.watch(processingProvider)[sid];
    final hasText = (ref.watch(segmentsProvider(sid)).value ?? []).isNotEmpty;
    final pending = ms.where((m) => m.status == 'suggested').length;
    final confirmed = ms.length - pending; // menções já julgadas (para a barra)
    final discoveries = ms.where((m) => m.status == 'confirmed').map((m) => m.entityId).toSet().length; // entradas distintas

    Widget? cta;
    if (s.status == 'processing' || (proc?.running ?? false)) {
      cta = RuneButton('Ver progresso', icon: PxIcons.hourglass, onPressed: () => context.go('/campaign/$cid/session/$sid/process'));
    } else if (s.status == 'review') {
      cta = RuneButton(pending == 0 ? 'Concluir revisão' : 'Revisar $pending descobertas', icon: PxIcons.scale, onPressed: () => context.go('/campaign/$cid/session/$sid/review'));
    } else if (audios.isNotEmpty || hasText || s.status == 'recorded') {
      cta = RuneButton(s.status == 'done' ? 'Reprocessar' : 'Processar sessão',
          icon: PxIcons.zap, tone: s.status == 'done' ? RuneTone.ghost : RuneTone.primary, onPressed: (audios.isEmpty && !hasText) ? null : () => context.go('/campaign/$cid/session/$sid/process'));
    }
    final chips = <(IconData, String, Color)>[
      if (s.durationSec > 0) (PxIcons.clock, s.durationSec < 60 ? '${s.durationSec}s' : '${(s.durationSec / 60).round()} min', p.arcane),
      if (discoveries > 0) (PxIcons.map, '$discoveries ${discoveries == 1 ? 'descoberta' : 'descobertas'}', p.gold),
      if (evs.isNotEmpty) (PxIcons.flag, '${evs.length} ${evs.length == 1 ? 'evento' : 'eventos'}', p.emerald),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: RpgCard(
        accent: p.gold,
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (chips.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Wrap(spacing: 8, runSpacing: 8, children: [
                for (final c in chips)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    color: c.$3.withValues(alpha: 0.16),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(c.$1, size: 20, color: c.$3),
                      const SizedBox(width: 6),
                      Text(c.$2, style: pxText(13, p.text)),
                    ]),
                  ),
              ]),
            ),
          if (s.status == 'review' && ms.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 12), child: XpBar(confirmed / ms.length, height: 10)),
          Wrap(spacing: 10, runSpacing: 10, children: [
            ?cta,
            RuneButton(audios.isEmpty ? 'Gravações' : 'Gravações (${audios.length})',
                icon: PxIcons.headphone, tone: RuneTone.ghost, onPressed: () => context.go('/campaign/$cid/session/$sid/recordings')),
          ]),
        ]),
      ),
    );
  }
}

/// Aba Crônica: só dois blocos expansíveis — Resumo e Crônica.
class _SummaryTab extends ConsumerWidget {
  final String cid;
  final Session s;
  const _SummaryTab(this.cid, this.s);

  static const _autoMark = '(Resumo automático';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.rpg;
    if (s.shortSummary.isEmpty && s.longSummary.isEmpty) {
      return const EmptyState(PxIcons.bookOpen, 'A crônica ainda não foi escrita',
          'Grave ou importe o áudio e toque em "Processar sessão" para gerar o resumo.');
    }
    var paragraphs = s.longSummary.split(RegExp(r'\n\s*\n')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final isAuto = paragraphs.isNotEmpty && paragraphs.last.startsWith(_autoMark);
    if (isAuto) paragraphs = paragraphs.sublist(0, paragraphs.length - 1);
    final body = TextStyle(fontSize: 22, height: 1.45, color: p.text);

    Widget para(String t) {
      final stopped = t.toLowerCase().startsWith('onde paramos');
      if (!stopped) return Padding(padding: const EdgeInsets.only(bottom: 14), child: SelectableText(t, style: body));
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: SelectableText.rich(TextSpan(children: [
          TextSpan(text: 'Onde paramos: ', style: body.copyWith(fontWeight: FontWeight.w700, color: p.emerald)),
          TextSpan(text: t.replaceFirst(RegExp(r'^onde paramos:?\s*', caseSensitive: false), ''), style: body),
        ])),
      );
    }

    return MaxWidth(
      width: 760,
      ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 40), children: [
        if (s.shortSummary.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: PxExpandable(title: 'Resumo', icon: PxIcons.zap, initiallyOpen: true, child: SelectableText(s.shortSummary, style: body)),
          ),
        if (paragraphs.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: PxExpandable(
              title: 'Crônica',
              icon: PxIcons.bookOpen,
              accent: p.arcane,
              preview: paragraphs.first,
              hint: '${paragraphs.length} parágrafos',
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [for (final t in paragraphs) para(t)]),
            ),
          ),
        if (isAuto)
          Text('Resumo montado sem IA (frases reais da sessão). Para uma crônica narrativa, escolha uma IA em Configurações e reprocese.', style: TextStyle(color: p.muted, fontSize: 19, height: 1.3)),
        if (s.status == 'review' && !isAuto) Text('Gerado pela IA: confira antes de concluir a revisão.', style: TextStyle(color: p.muted, fontSize: 19)),
      ]),
    );
  }
}

/// Transcrição com horários, edição, busca e player sincronizado.
class _TranscriptTab extends ConsumerStatefulWidget {
  final String sid;
  const _TranscriptTab(this.sid);
  @override
  ConsumerState<_TranscriptTab> createState() => _TranscriptTabState();
}

class _TranscriptTabState extends ConsumerState<_TranscriptTab> {
  final _player = AudioPlayer();
  final _search = TextEditingController();
  String _q = '';
  int? _loadedAudio;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  /// Toca o trecho no bloco de áudio correspondente (offset = soma dos blocos anteriores).
  Future<void> _playAt(int ms) async {
    final audios = (await ref.read(repoProvider).audiosOf(widget.sid)).where((a) => a.speaker == null).toList();
    if (audios.isEmpty) return snack(context, 'Sem áudio local para tocar (apagado ou só trilhas por pessoa).');
    var acc = 0;
    for (var i = 0; i < audios.length; i++) {
      final len = audios[i].durationSec * 1000;
      if (ms < acc + len || i == audios.length - 1) {
        try {
          if (_loadedAudio != i) {
            await _player.setFilePath(audios[i].filePath);
            _loadedAudio = i;
          }
          await _player.seek(Duration(milliseconds: ms - acc));
          _player.play();
        } catch (e) {
          if (mounted) snack(context, 'Não foi possível tocar: $e');
        }
        return;
      }
      acc += len;
    }
  }

  Future<void> _edit(Segment seg) async {
    final c = TextEditingController(text: seg.text_);
    final r = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(
          title: Text('Editar ${fmtClock(seg.startMs)}'),
          content: TextField(controller: c, maxLines: 5, autofocus: true),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: const Text('Salvar')),
          ],
        ));
    if (r != null && r.isNotEmpty) await ref.read(repoProvider).updateSegmentText(seg.id, r);
  }

  @override
  Widget build(BuildContext context) {
    final segs = ref.watch(segmentsProvider(widget.sid)).value ?? [];
    final shown = _q.isEmpty ? segs : segs.where((s) => s.text_.toLowerCase().contains(_q.toLowerCase())).toList();
    if (segs.isEmpty) {
      return EmptyState(PxIcons.scriptText, 'Pergaminho em branco', 'A transcrição aparece aqui depois do processamento — ou cole um texto pronto.',
          action: OutlinedButton.icon(onPressed: () => showTranscriptImport(context, ref, widget.sid), icon: const Icon(PxIcons.clipboard), label: const Text('Colar/importar transcrição')));
    }
    return MaxWidth(Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 8), child: TextField(
          controller: _search,
          decoration: InputDecoration(prefixIcon: const Icon(PxIcons.search), hintText: 'Buscar no pergaminho', suffixText: _q.isEmpty ? null : '${shown.length} resultado(s)'),
          onChanged: (v) => setState(() => _q = v.trim()))),
      StreamBuilder<PlayerState>(stream: _player.playerStateStream, builder: (_, snap) {
        final playing = snap.data?.playing ?? false;
        return playing ? ListTile(dense: true, leading: const Icon(PxIcons.volume2), title: const Text('Tocando'), trailing: IconButton(icon: const Icon(PxIcons.pause), onPressed: _player.pause)) : const SizedBox.shrink();
      }),
      Expanded(child: ListView.builder(
        itemCount: shown.length,
        itemBuilder: (_, i) {
          final s = shown[i];
          final low = s.confidence < 0.6;
          final p = context.rpg;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: RpgCard(
              accent: low ? p.crimson : null,
              padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
              onTap: () => _edit(s),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _playAt(s.startMs),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(color: p.gold.withValues(alpha: .14), borderRadius: BorderRadius.circular(8)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(PxIcons.play, size: 12, color: p.gold),
                      const SizedBox(width: 2),
                      Text(fmtClock(s.startMs), style: TextStyle(color: p.gold, fontWeight: FontWeight.w700, fontSize: 12)),
                    ]),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (s.speaker != null) Text(s.speaker!, style: TextStyle(color: p.arcane, fontWeight: FontWeight.w800, fontSize: 12)),
                  Text(s.text_, style: const TextStyle(height: 1.45)),
                  if (low) Text('Baixa confiança — confira', style: TextStyle(fontSize: 11, color: p.crimson)),
                ])),
                Icon(PxIcons.edit, size: 24, color: p.muted),
                const SizedBox(width: 6),
              ]),
            ),
          );
        },
      )),
    ]));
  }
}

class _EntitiesTab extends ConsumerWidget {
  final String cid;
  final String sid;
  const _EntitiesTab(this.cid, this.sid);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.rpg;
    final ms = ref.watch(sessionMentionsProvider(sid)).value ?? [];
    final all = ref.watch(entitiesProvider((cid, null))).value ?? [];
    final ids = ms.where((m) => m.status == 'confirmed').map((m) => m.entityId).toSet();
    final ents = all.where((e) => ids.contains(e.id)).toList();
    final pending = ms.where((m) => m.status == 'suggested').length;
    final teaser = pending == 0
        ? null
        : Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RpgCard(
              accent: p.arcane,
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
              child: Row(children: [
                Icon(PxIcons.hourglass, color: p.arcane),
                const SizedBox(width: 12),
                Expanded(child: Text('$pending descobertas aguardam revisão antes de entrarem no bestiário da campanha.')),
                FilledButton(onPressed: () => context.go('/campaign/$cid/session/$sid/review'), child: const Text('Revisar')),
              ]),
            ),
          );
    if (ents.isEmpty) {
      return MaxWidth(ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 24), children: [
        ?teaser,
        const SizedBox(height: 24),
        const EmptyState(PxIcons.map, 'Nenhuma descoberta confirmada', 'NPCs, locais, missões, itens e facções aparecem aqui assim que você os confirma na revisão.'),
      ]));
    }
    return MaxWidth(ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 32), children: [
      ?teaser,
      for (final kind in kindLabels.keys)
        if (ents.any((e) => e.kind == kind)) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Row(children: [
              Icon(kindIcons[kind], size: 24, color: p.kind(kind)),
              const SizedBox(width: 8),
              Text('${kindLabels[kind]!.toUpperCase()} · ${ents.where((e) => e.kind == kind).length}',
                  style: pxText(12, p.kind(kind), spacing: 1.6)),
            ]),
          ),
          for (final e in ents.where((e) => e.kind == kind))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: RpgCard(
                accent: p.kind(kind),
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                onTap: () => context.go('/campaign/$cid/entity/${e.id}'),
                child: Row(children: [
                  KindAvatar(kind),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(e.name, style: pxText(15, p.text, spacing: .6)),
                    if (e.status.isNotEmpty) Text(e.status, style: TextStyle(color: p.kind(kind), fontSize: 12, fontWeight: FontWeight.w700)),
                    if (kind == 'spell') Text('USADO ×${ms.where((m) => m.entityId == e.id && m.status == 'confirmed').length}', style: pxText(12, p.kind(kind))),
                    if (e.description.isNotEmpty)
                      Padding(padding: const EdgeInsets.only(top: 4), child: Text(e.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: p.muted, height: 1.35))),
                  ])),
                  Icon(PxIcons.chevronRight, color: p.muted),
                ]),
              ),
            ),
        ],
    ]));
  }
}
