import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/engines.dart';
import '../core/providers.dart';
import '../core/px_icons.dart';
import '../core/rpg_theme.dart';
import '../core/ui.dart';
import 'ai_screen.dart';
import 'quota_banner.dart';
import 'export_actions.dart';

/// Painel da campanha. Princípio: só o essencial na primeira tela — 3 números,
/// a ação principal, um aviso (se houver) e o menu. O resto fica em "Mais".
class DashboardScreen extends ConsumerWidget {
  final String cid;
  const DashboardScreen(this.cid, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.rpg;
    final camp = ref.watch(campaignProvider(cid)).value;
    final sessions = ref.watch(sessionsProvider(cid)).value ?? [];
    final heroes = ref.watch(heroesProvider(cid)).value ?? [];
    final ents = ref.watch(entitiesProvider((cid, null))).value ?? [];
    final threads = (ref.watch(notesProvider((cid, 'thread'))).value ?? []).where((n) => n.status == 'open').length;
    final orphans = ref.watch(orphanEntitiesProvider(cid)).value ?? [];
    final engine = engineById(ref.watch(engineProvider));
    if (camp == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final toReview = sessions.where((s) => s.status == 'review').toList();
    final withRecap = sessions.where((s) => s.previouslyOn.isNotEmpty).toList();
    final prev = withRecap.isEmpty ? null : withRecap.first;

    return Scaffold(
      appBar: GameBar(
        title: Text(camp.name),
        leading: BackButton(onPressed: () => context.go('/')),
        actions: [
          GestureDetector(
            onTap: () => context.go('/settings'),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                color: engine == null ? p.crimson : p.surface2,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(PxIcons.zap, size: 24, color: engine == null ? onColor(p.crimson) : p.gold),
                  const SizedBox(width: 6),
                  Text((engine?.name ?? 'Sem IA').toUpperCase(), style: pxText(12, engine == null ? onColor(p.crimson) : p.text)),
                ]),
              ),
            ),
          ),
          IconButton(tooltip: 'Editar campanha', onPressed: () => context.go('/campaign/$cid/edit'), icon: const Icon(PxIcons.edit)),
        ],
      ),
      body: MaxWidth(
        width: 720,
        ListView(padding: const EdgeInsets.fromLTRB(16, 20, 16, 48), children: [
          const QuotaBanner(),
          const AiBanner(),
          if (heroes.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: RpgCard(
                accent: p.gold,
                padding: const EdgeInsets.all(10),
                child: Row(children: [
                  Expanded(child: Text('Cadastre os heróis para a IA reconhecer os jogadores.', style: const TextStyle(fontSize: 22, height: 1.2))),
                  const SizedBox(width: 10),
                  RuneButton('Cadastrar', compact: true, onPressed: () => context.go('/campaign/$cid/heroes/start')),
                ]),
              ),
            ),
          if (orphans.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: RpgCard(
                accent: p.crimson,
                padding: const EdgeInsets.all(10),
                child: Row(children: [
                  Expanded(child: Text('${orphans.length} ${orphans.length == 1 ? 'entrada da enciclopédia não aparece' : 'entradas da enciclopédia não aparecem'} em nenhuma sessão.', style: const TextStyle(fontSize: 22, height: 1.2))),
                  const SizedBox(width: 10),
                  RuneButton('Limpar', compact: true, tone: RuneTone.ghost, onPressed: () => _cleanOrphans(context, ref, orphans)),
                ]),
              ),
            ),
          // 1) três números
          Row(children: [
            Expanded(child: StatTile(PxIcons.bookOpen, '${sessions.length}', 'Sessões', p.arcane)),
            const SizedBox(width: 10),
            Expanded(child: StatTile(PxIcons.map, '${ents.where((e) => e.review == 'confirmed').length}', 'Na enciclopédia', p.emerald)),
            const SizedBox(width: 10),
            Expanded(child: StatTile(PxIcons.users, '${heroes.length}', 'Heróis', p.gold)),
          ]),
          const SizedBox(height: 22),
          // 2) ação principal
          Align(alignment: Alignment.centerLeft, child: RuneButton('Nova sessão', icon: PxIcons.plus, onPressed: () => context.go('/campaign/$cid/new'))),
          // 3) um aviso, só se houver algo a fazer
          if (toReview.isNotEmpty) ...[
            const SizedBox(height: 20),
            RpgCard(
              accent: p.arcane,
              onTap: () => context.go('/campaign/$cid/session/${toReview.first.id}/review'),
              padding: const EdgeInsets.all(10),
              child: Row(children: [
                Expanded(child: Text('Sessão ${toReview.first.number} aguarda revisão', style: const TextStyle(fontSize: 22))),
                Icon(PxIcons.chevronRight, color: p.muted),
              ]),
            ),
          ],
          // 4) recap, resumido
          if (prev != null) ...[
            const SizedBox(height: 20),
            RpgCard(
              onTap: () => _showRecap(context, prev.number, prev.previouslyOn),
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('ANTERIORMENTE EM…', style: pxText(12, p.muted)),
                const SizedBox(height: 6),
                Text(prev.previouslyOn, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 22, height: 1.3)),
              ]),
            ),
          ],
          // 5) menu
          const SizedBox(height: 28),
          LayoutBuilder(builder: (context, c) {
            final cols = c.maxWidth > 560 ? 2 : 1;
            final tiles = <Widget>[
              MenuTile(PxIcons.bookOpen, 'Sessões', '${sessions.length} registradas', () => context.go('/campaign/$cid/sessions'), color: p.arcane),
              MenuTile(PxIcons.timeline, 'Jornada', 'A história da campanha', () => context.go('/campaign/$cid/journey'), color: p.gold),
              MenuTile(PxIcons.map, 'Enciclopédia', 'NPCs, locais, missões', () => context.go('/campaign/$cid/encyclopedia'), color: p.emerald),
              MenuTile(PxIcons.users, 'Heróis', 'Quem está na mesa', () => context.go('/campaign/$cid/heroes')),
              MenuTile(PxIcons.message, 'Perguntar', 'Pergunte à campanha', () => context.go('/campaign/$cid/ask'), color: p.arcane),
              MenuTile(PxIcons.scriptText, 'Planejar sessão', threads == 0 ? 'Ganchos e segredos' : '$threads gancho(s) em aberto', () => context.go('/campaign/$cid/prep'), badge: threads == 0 ? null : '$threads'),
              MenuTile(PxIcons.moreHorizontal, 'Mais', 'Ideias, recap, exportar', () => _more(context, ref)),
            ];
            final rows = <Widget>[];
            for (var i = 0; i < tiles.length; i += cols) {
              final chunk = tiles.sublist(i, (i + cols).clamp(0, tiles.length));
              rows.add(IntrinsicHeight(
                child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  for (var j = 0; j < cols; j++) ...[
                    if (j > 0) const SizedBox(width: 12),
                    Expanded(child: j < chunk.length ? chunk[j] : const SizedBox.shrink()),
                  ],
                ]),
              ));
            }
            return Column(children: [
              for (var i = 0; i < rows.length; i++) ...[if (i > 0) const SizedBox(height: 12), rows[i]],
            ]);
          }),
        ]),
      ),
    );
  }

  /// Mostra o que seria apagado e só apaga se você confirmar.
  Future<void> _cleanOrphans(BuildContext context, WidgetRef ref, List<dynamic> orphans) async {
    final names = orphans.map((e) => '${e.name}').take(10).join(', ') + (orphans.length > 10 ? '…' : '');
    final ok = await confirmDialog(
        context,
        'Apagar ${orphans.length} entrada(s)?',
        'Elas não aparecem em nenhuma sessão: costumam ser restos de sessões apagadas, mas também podem ter sido criadas por você na enciclopédia.\n\n$names\n\nIsso não pode ser desfeito.',
        ok: 'Apagar');
    if (!ok) return;
    final repo = ref.read(repoProvider);
    for (final e in orphans) {
      await repo.deleteEntity(e.id as String);
    }
    if (context.mounted) snack(context, '${orphans.length} entrada(s) apagada(s).');
  }

  void _showRecap(BuildContext context, int n, String text) {
    final p = context.rpg;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('ANTERIORMENTE EM… (SESSÃO $n)', style: pxText(13, p.muted)),
            const SizedBox(height: 12),
            Flexible(child: SingleChildScrollView(child: SelectableText(text, style: const TextStyle(fontSize: 23, height: 1.35)))),
            const SizedBox(height: 16),
            RuneButton('Copiar', icon: PxIcons.copy, compact: true, tone: RuneTone.ghost, onPressed: () {
              Clipboard.setData(ClipboardData(text: text));
              Navigator.pop(ctx);
              snack(context, 'Copiado.');
            }),
          ]),
        ),
      ),
    );
  }

  void _more(BuildContext context, WidgetRef ref) {
    final p = context.rpg;
    Widget row(IconData i, String t, String sub, VoidCallback f) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: MenuTile(i, t, sub, f),
        );
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            row(PxIcons.dice, 'Gerador de ideias', 'Sorteie nomes de NPC, tavernas, rumores, encontros e tesouros para improvisar', () { Navigator.pop(ctx); context.go('/campaign/$cid/tables'); }),
            row(PxIcons.eye, 'Recap para jogadores', 'Resumo para enviar ao grupo, sem os segredos do mestre', () { Navigator.pop(ctx); context.go('/campaign/$cid/recap'); }),
            row(PxIcons.upload, 'Exportar', 'Salvar a campanha em Markdown, PDF ou Obsidian', () { Navigator.pop(ctx); showExportSheet(context, ref, cid); }),
            Align(alignment: Alignment.centerRight, child: Text('Toque fora para fechar', style: TextStyle(color: p.muted, fontSize: 18))),
          ]),
        ),
      ),
    );
  }
}
