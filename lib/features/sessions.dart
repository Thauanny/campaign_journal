import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers.dart';
import '../core/px_icons.dart';
import '../core/rpg_theme.dart';
import '../core/ui.dart';
import '../data/repo_facts.dart';

/// Lista de sessões: cartões com número grande, data, estado e resumo.
class SessionsScreen extends ConsumerWidget {
  final String cid;
  const SessionsScreen(this.cid, {super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.rpg;
    final sessions = ref.watch(sessionsProvider(cid));
    return Scaffold(
      appBar: GameBar(
        title: const Text('Sessões'),
        leading: BackButton(onPressed: () => context.go('/campaign/$cid')),
        actions: [RuneButton('Nova', icon: PxIcons.plus, compact: true, onPressed: () => context.go('/campaign/$cid/new'))],
      ),
      body: sessions.when(
        loading: () => const AppLoading(),
        error: (e, _) => Center(child: Text('$e')),
        data: (ss) => ss.isEmpty
            ? EmptyState(PxIcons.bookOpen, 'Nenhuma sessão ainda', 'Registre a primeira: cole a transcrição, importe o áudio ou grave a mesa.',
                action: RuneButton('Nova sessão', icon: PxIcons.plus, onPressed: () => context.go('/campaign/$cid/new')))
            : MaxWidth(
                width: 820,
                ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
                  itemCount: ss.length,
                  itemBuilder: (_, i) {
                    final s = ss[i];
                    final d = s.date;
                    final date = '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
                    final sc = statusColor(context, s.status);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: RpgCard(
                        accent: s.status == 'review' ? p.arcane : null,
                        onTap: () => context.go('/campaign/$cid/session/${s.id}'),
                        padding: const EdgeInsets.all(12),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Container(
                            width: 64, height: 64,
                            color: sc,
                            alignment: Alignment.center,
                            child: Text('${s.number}', style: pxText(26, p.bgDeep)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Expanded(child: Text('SESSÃO ${s.number}', style: pxText(15, p.text))),
                              StatusChip(s.status),
                              PopupMenuButton<String>(
                                tooltip: 'Mais',
                                icon: Icon(PxIcons.moreHorizontal, color: p.text),
                                onSelected: (v) async {
                                  if (v != 'delete') return;
                                  if (ref.read(processingProvider)[s.id]?.running ?? false) {
                                    snack(context, 'Esta sessão está sendo processada. Espere terminar.');
                                    return;
                                  }
                                  if (!await confirmDeleteSession(context, ref, s.id, s.number)) return;
                                  if (context.mounted) snack(context, 'Sessão ${s.number} excluída.');
                                },
                                itemBuilder: (_) => const [PopupMenuItem(value: 'delete', child: Text('Excluir sessão'))],
                              ),
                            ]),
                            const SizedBox(height: 4),
                            Text('$date${s.durationSec > 0 ? ' · ${(s.durationSec / 60).round()} min' : ''}', style: TextStyle(color: p.muted, fontSize: 19)),
                            const SizedBox(height: 6),
                            Text(s.shortSummary.isEmpty ? 'Sem resumo ainda.' : s.shortSummary, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 21, height: 1.1, color: s.shortSummary.isEmpty ? p.muted : p.text)),
                          ])),
                        ]),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}


/// Pergunta o que apagar junto com a sessão e executa. Devolve true se apagou.
Future<bool> confirmDeleteSession(BuildContext context, WidgetRef ref, String sessionId, int number) async {
  final repo = ref.read(repoProvider);
  final pv = await repo.deletionPreview(sessionId);
  if (!context.mounted) return false;
  var delEntities = pv.exclusive.isNotEmpty;
  var revert = pv.appliedFacts > 0;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(builder: (ctx, set) {
      final p = ctx.rpg;
      Widget opt(bool v, String title, String sub, void Function(bool) f) => Padding(
            padding: const EdgeInsets.only(top: 14),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => set(() => f(!v)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(v ? PxIcons.checkboxOn : PxIcons.checkbox, color: v ? p.gold : p.muted),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: TextStyle(fontSize: 22, color: p.text)),
                  Text(sub, style: TextStyle(fontSize: 19, color: p.muted, height: 1.2)),
                ])),
              ]),
            ),
          );
      return AlertDialog(
        title: Text('EXCLUIR SESSÃO $number?'),
        content: SizedBox(
          width: 460,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('O áudio, a transcrição, o resumo e a linha do tempo desta sessão serão apagados. Isso não pode ser desfeito.', style: TextStyle(fontSize: 22, height: 1.25)),
            if (pv.exclusive.isNotEmpty)
              opt(delEntities, 'Apagar também ${pv.exclusive.length} descoberta(s) que só aparecem nesta sessão',
                  pv.exclusive.take(4).map((e) => e.name).join(', ') + (pv.exclusive.length > 4 ? '…' : ''), (v) => delEntities = v),
            if (pv.appliedFacts > 0)
              opt(revert, 'Desfazer o dano, a cura e o XP aplicados aos heróis', '${pv.appliedFacts} registro(s) de combate desta sessão', (v) => revert = v),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCELAR')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('EXCLUIR')),
        ],
      );
    }),
  );
  if (ok != true) return false;
  await repo.deleteSession(sessionId, deleteExclusiveEntities: delEntities, revertFacts: revert);
  return true;
}
