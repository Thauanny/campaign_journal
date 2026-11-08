import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../ai/prompts.dart';
import '../core/providers.dart';
import '../core/rpg_theme.dart';
import '../core/ui.dart';
import 'ai_screen.dart';
import '../domain/ask.dart';
import '../domain/pipeline.dart';
import '../core/px_icons.dart';

/// Perguntas à campanha: "Quem era o ferreiro de Valdoria?" com citação da sessão.
class AskScreen extends ConsumerStatefulWidget {
  final String cid;
  const AskScreen(this.cid, {super.key});
  @override
  ConsumerState<AskScreen> createState() => _AskState();
}

class _AskState extends ConsumerState<AskScreen> {
  final _q = TextEditingController();
  bool _busy = false;
  String? _answer;
  List<Passage> _sources = [];

  Future<void> _ask() async {
    final q = _q.text.trim();
    if (q.isEmpty) return;
    setState(() { _busy = true; _answer = null; });
    try {
      final repo = ref.read(repoProvider);
      final sessions = await repo.sessionsOf(widget.cid);
      final segs = {for (final s in sessions) s.id: await repo.segmentsOf(s.id)};
      final ps = retrievePassages(q, sessions, segs);
      final ents = await repo.entitiesOf(widget.cid);
      if (ps.isEmpty) {
        setState(() { _answer = 'Não encontrei nada sobre isso nas transcrições.'; _sources = []; });
        return;
      }
      final model = await ref.read(factoryProvider).chatModel();
      final sys = (await repo.campaign(widget.cid))?.system ?? '';
      final (raw, u) = await model.complete(askSystem(system: sys), askUser(q, ps, ents));
      final pricing = await ref.read(settingsProvider).pricing();
      await repo.logUsage(widget.cid, model.id, 'ask', u, pricing.cost(model.label.replaceAll(RegExp(r'^.*\(|\)$'), ''), u.inputTokens, u.outputTokens));
      setState(() { _answer = (parseJsonObject(raw)?['answer'] ?? raw).toString(); _sources = ps; });
    } catch (e) {
      if (mounted) snack(context, '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.rpg;
    return Scaffold(
      appBar: GameBar(title: const Text('Perguntar à campanha'), leading: BackButton(onPressed: () => context.go('/campaign/${widget.cid}'))),
      body: MaxWidth(
        width: 820,
        ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 48), children: [
          const AiBanner(),
          Text('A IA ativa responde usando só o que está nas suas transcrições, e mostra os trechos usados.', style: TextStyle(color: p.muted, fontSize: 22, height: 1.1)),
          const SizedBox(height: 12),
          TextField(
            controller: _q,
            decoration: InputDecoration(hintText: 'Quem era o ferreiro de Valdoria?', suffixIcon: IconButton(icon: const Icon(PxIcons.forward), onPressed: _busy ? null : _ask)),
            onSubmitted: (_) => _ask(),
          ),
          const SizedBox(height: 10),
          RuneButton(_busy ? 'Procurando…' : 'Perguntar', icon: PxIcons.message, onPressed: _busy ? null : _ask),
          if (_busy) const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
          if (_answer != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: RpgCard(
                accent: p.emerald,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('RESPOSTA', style: pxText(12, p.emerald)),
                  const SizedBox(height: 8),
                  SelectableText(_answer!, style: const TextStyle(fontSize: 23, height: 1.2)),
                ]),
              ),
            ),
          if (_sources.isNotEmpty) ...[
            const SectionTitle('Trechos usados'),
            for (final s in _sources.take(6))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: RpgCard(
                  padding: const EdgeInsets.all(10),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('SESSÃO ${s.sessionNumber} · ${fmtClock(s.atMs)}', style: pxText(12, p.gold)),
                    const SizedBox(height: 4),
                    Text(s.text, maxLines: 4, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 21, height: 1.1)),
                  ]),
                ),
              ),
          ],
        ]),
      ),
    );
  }
}
