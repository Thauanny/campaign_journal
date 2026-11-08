import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../ai/prompts.dart';
import '../core/providers.dart';
import '../core/px_icons.dart';
import '../core/rpg_theme.dart';
import '../core/ui.dart';
import '../data/repo_notes.dart';
import '../domain/systems.dart';

/// Preparar a próxima sessão (método "Lazy DM"): início forte, ganchos em
/// aberto e segredos/pistas — tudo guardado na campanha e carregado de uma
/// sessão para a outra.
class PrepScreen extends ConsumerStatefulWidget {
  final String cid;
  const PrepScreen(this.cid, {super.key});
  @override
  ConsumerState<PrepScreen> createState() => _PrepState();
}

class _PrepState extends ConsumerState<PrepScreen> {
  final _start = TextEditingController();
  Timer? _debounce;
  bool _loaded = false, _suggesting = false;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _saveStart(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () => ref.read(repoProvider).setStrongStart(widget.cid, v));
  }

  Future<void> _suggestSecrets() async {
    setState(() => _suggesting = true);
    try {
      final repo = ref.read(repoProvider);
      final sessions = (await repo.sessionsOf(widget.cid)).where((s) => s.longSummary.isNotEmpty || s.shortSummary.isNotEmpty).toList();
      final threads = (await repo.notesOf(widget.cid, 'thread')).where((n) => n.status == 'open').map((n) => '- ${n.body}').join('\n');
      final recap = sessions.isEmpty ? '' : (sessions.last.longSummary.isNotEmpty ? sessions.last.longSummary : sessions.last.shortSummary);
      final ents = (await repo.entitiesOf(widget.cid)).where((e) => e.review == 'confirmed').take(25).map((e) => '- ${e.name} (${e.kind}): ${e.description}').join('\n');
      final model = await ref.read(factoryProvider).chatModel();
      final sysName = (await repo.campaign(widget.cid))?.system ?? '';
      final system = 'Você ajuda um mestre de RPG a preparar a próxima sessão. Responda SOMENTE com JSON: {"secrets":["..."]}. '
          'Escreva de 6 a 8 segredos e pistas curtos (uma frase cada) que o mestre pode revelar na próxima sessão, '
          'coerentes com o que já aconteceu, sem contradizer fatos e conectados aos ganchos em aberto.${sysName.isEmpty ? '' : '\n\n${systemContext(sysName)}'}';
      final user = 'Última sessão:\n$recap\n\nGanchos em aberto:\n$threads\n\nPersonagens e lugares conhecidos:\n$ents';
      final (raw, _) = await model.complete(system, user);
      final list = (parseJsonObject(raw)?['secrets'] as List? ?? const []).map((e) => e.toString()).where((e) => e.trim().isNotEmpty);
      for (final t in list) {
        await repo.addNote(widget.cid, 'secret', t, source: 'ai');
      }
      if (mounted) snack(context, list.isEmpty ? 'A IA não devolveu sugestões.' : '${list.length} sugestões adicionadas.');
    } catch (e) {
      if (mounted) snack(context, '$e');
    } finally {
      if (mounted) setState(() => _suggesting = false);
    }
  }

  Future<void> _copyAll() async {
    final repo = ref.read(repoProvider);
    final start = (await repo.notesOf(widget.cid, 'strong_start')).firstOrNull?.body ?? '';
    final th = (await repo.notesOf(widget.cid, 'thread')).where((n) => n.status == 'open');
    final se = (await repo.notesOf(widget.cid, 'secret')).where((n) => n.status == 'open');
    final b = StringBuffer('# Roteiro da próxima sessão\n\n');
    b.writeln('## Início forte\n\n${start.isEmpty ? '(a definir)' : start}\n');
    b.writeln('## Ganchos em aberto\n');
    for (final n in th) { b.writeln('- ${n.body}'); }
    b.writeln('\n## Segredos e pistas\n');
    for (final n in se) { b.writeln('- [ ] ${n.body}'); }
    await Clipboard.setData(ClipboardData(text: b.toString()));
    if (mounted) snack(context, 'Roteiro copiado.');
  }

  @override
  Widget build(BuildContext context) {
    final p = context.rpg;
    final cid = widget.cid;
    final starts = ref.watch(notesProvider((cid, 'strong_start'))).value;
    if (!_loaded && starts != null) {
      _loaded = true;
      _start.text = starts.firstOrNull?.body ?? '';
    }

    Widget intro(String n, String title, String body) => Padding(
          padding: const EdgeInsets.fromLTRB(0, 22, 0, 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 32, height: 32, color: p.gold, alignment: Alignment.center, child: Text(n, style: pxText(14, p.bgDeep))),
              const SizedBox(width: 12),
              Expanded(child: Text(title.toUpperCase(), style: pxText(16, p.gold))),
            ]),
            const SizedBox(height: 6),
            Text(body, style: TextStyle(color: p.muted, fontSize: 21, height: 1.1)),
          ]),
        );

    return Scaffold(
      appBar: GameBar(
        title: const Text('Planejar sessão'),
        leading: BackButton(onPressed: () => context.go('/campaign/$cid')),
        actions: [IconButton(tooltip: 'Copiar roteiro', onPressed: _copyAll, icon: const Icon(PxIcons.copy))],
      ),
      body: MaxWidth(
        width: 820,
        ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 48), children: [
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text('Roteiro rápido para a próxima mesa: como começar, o que ficou em aberto e o que o grupo pode descobrir. É só para o mestre; nada disso aparece no recap dos jogadores.', style: TextStyle(color: p.muted, fontSize: 21, height: 1.3)),
          ),
          intro('1', 'Início forte', 'Comece no meio da ação.'),
          TextField(
            controller: _start,
            minLines: 3,
            maxLines: 6,
            onChanged: _saveStart,
            decoration: const InputDecoration(hintText: 'Ex.: Os recrutas de Verren cercam a taverna enquanto o grupo ainda dorme…'),
          ),
          intro('2', 'Ganchos em aberto', 'O que ficou sem resposta.'),
          _NoteList(cid, 'thread', doneIcon: PxIcons.checkboxOn, openIcon: PxIcons.checkbox, hint: 'Novo gancho (ex.: quem enviou os recrutas?)'),
          intro('3', 'Segredos e pistas', 'O que o grupo pode descobrir.'),
          _NoteList(cid, 'secret', doneIcon: PxIcons.eye, openIcon: PxIcons.eyeClosed, hint: 'Novo segredo ou pista'),
          const SizedBox(height: 10),
          Align(alignment: Alignment.centerLeft, child: RuneButton(_suggesting ? 'Pensando…' : 'Sugerir com IA', icon: PxIcons.zap, tone: RuneTone.arcane, compact: true, onPressed: _suggesting ? null : _suggestSecrets)),
          const SizedBox(height: 22),
          Center(child: RuneButton('Copiar roteiro', icon: PxIcons.copy, onPressed: _copyAll)),
        ]),
      ),
    );
  }
}

class _NoteList extends ConsumerStatefulWidget {
  final String cid, kind, hint;
  final IconData doneIcon, openIcon;
  const _NoteList(this.cid, this.kind, {required this.doneIcon, required this.openIcon, required this.hint});
  @override
  ConsumerState<_NoteList> createState() => _NoteListState();
}

class _NoteListState extends ConsumerState<_NoteList> {
  final _c = TextEditingController();

  Future<void> _add() async {
    await ref.read(repoProvider).addNote(widget.cid, widget.kind, _c.text);
    _c.clear();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.rpg;
    final notes = ref.watch(notesProvider((widget.cid, widget.kind))).value ?? [];
    final repo = ref.read(repoProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (final n in notes)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: RpgCard(
            accent: n.status == 'done' ? p.emerald : null,
            padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
            child: Row(children: [
              GestureDetector(
                onTap: () => repo.setNoteStatus(n.id, n.status == 'done' ? 'open' : 'done'),
                child: Icon(n.status == 'done' ? widget.doneIcon : widget.openIcon, color: n.status == 'done' ? p.emerald : p.gold),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(n.body,
                    style: TextStyle(fontSize: 22, height: 1.1, color: n.status == 'done' ? p.muted : p.text, decoration: n.status == 'done' ? TextDecoration.lineThrough : null)),
              ),
              if (n.source == 'ai') Padding(padding: const EdgeInsets.only(right: 4), child: Text('IA', style: pxText(12, p.arcane))),
              IconButton(tooltip: 'Remover', icon: Icon(PxIcons.trash, color: p.muted), onPressed: () => repo.deleteNote(n.id)),
            ]),
          ),
        ),
      Row(children: [
        Expanded(child: TextField(controller: _c, onSubmitted: (_) => _add(), decoration: InputDecoration(hintText: widget.hint))),
        const SizedBox(width: 8),
        RuneButton('Add', icon: PxIcons.plus, compact: true, onPressed: _add),
      ]),
    ]);
  }
}
