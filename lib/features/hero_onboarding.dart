import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers.dart';
import '../core/px_icons.dart';
import '../core/rpg_theme.dart';
import '../core/ui.dart';
import '../domain/sheet_parser.dart';
import '../domain/systems.dart';
import 'sheet_batch.dart';

/// Cadastro guiado dos heróis (logo após criar a campanha, ou quando faltam).
/// A IA só entende bem a mesa se souber quem são os personagens dos jogadores.
class HeroOnboardingScreen extends ConsumerWidget {
  final String cid;
  const HeroOnboardingScreen(this.cid, {super.key});

  /// Escolhe uma ou várias fichas (PDF ou foto) e importa uma por vez: para cada
  /// arquivo cria um herói em branco, lê a ficha e abre a conferência.
  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final picked = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'webp']);
    final files = picked.where((f) => f.path != null).toList();
    if (files.isEmpty || !context.mounted) return;
    if (!context.mounted) return;
    await Navigator.of(context).push<void>(MaterialPageRoute(
        builder: (_) => SheetBatchScreen(cid, [
              for (final f in files) (name: f.name, path: f.path!, isPdf: (f.extension ?? f.path!.split('.').last).toLowerCase() == 'pdf'),
            ])));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.rpg;
    final camp = ref.watch(campaignProvider(cid)).value;
    final heroes = ref.watch(heroesProvider(cid)).value ?? [];
    final prof = profileFor(camp?.system ?? 'Outro');
    final back = Uri.encodeComponent('/campaign/$cid/heroes/start');
    final supported = supportedSheetSystems.contains(camp?.system);

    Widget option(IconData icon, String title, String sub, VoidCallback onTap) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: RpgCard(
            onTap: onTap,
            padding: const EdgeInsets.all(10),
            child: Row(children: [
              Container(width: 52, height: 52, color: p.surface2, child: Icon(icon, color: p.gold, size: 36)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title.toUpperCase(), style: pxText(15, p.text)),
                const SizedBox(height: 2),
                Text(sub, style: TextStyle(color: p.muted, fontSize: 20, height: 1.2)),
              ])),
              Icon(PxIcons.chevronRight, color: p.muted),
            ]),
          ),
        );

    return Scaffold(
      appBar: GameBar(title: const Text('Heróis da campanha'), leading: BackButton(onPressed: () => context.go('/campaign/$cid'))),
      body: MaxWidth(
        width: 640,
        ListView(padding: const EdgeInsets.fromLTRB(16, 20, 16, 48), children: [
          Text('Quem são os personagens?', style: pxText(16, p.text)),
          const SizedBox(height: 8),
          Text('A IA entende melhor a sessão quando conhece os heróis: nome do personagem, jogador, ${prof.classLabel.toLowerCase()} e ${prof.raceLabel.toLowerCase()}. '
              'Assim ela reconhece quem está falando, separa heróis de NPCs e anota o dano e o XP de cada um.', style: TextStyle(color: p.muted, fontSize: 21, height: 1.3)),
          const SizedBox(height: 6),
          Text('Sistema: ${prof.name}', style: TextStyle(color: p.gold, fontSize: 21)),
          const SizedBox(height: 20),
          option(PxIcons.userPlus, 'Criar ficha', 'Preencha à mão: ${prof.classLabel}, ${prof.raceLabel}, ${prof.levelLabel}, ${prof.hpLabel}…', () => context.go('/campaign/$cid/hero/new?back=$back')),
          option(PxIcons.camera, 'Importar fichas (foto ou PDF)', supported ? 'Escolha uma ou várias fichas de uma vez. Cada uma é lida por OCR e você confere antes de salvar.' : 'Lê o texto da ficha por OCR; como o ${prof.name} não tem leitura automática, você completa os campos.', () => _import(context, ref)),
          if (heroes.isNotEmpty) ...[
            SectionTitle('Cadastrados · ${heroes.length}'),
            for (final h in heroes)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: RpgCard(
                  accent: p.emerald,
                  onTap: () => context.go('/campaign/$cid/hero/${h.id}?back=$back'),
                  padding: const EdgeInsets.all(10),
                  child: Row(children: [
                    Icon(PxIcons.checkboxOn, color: p.emerald),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(h.name, style: const TextStyle(fontSize: 23)),
                      Text([if (h.player.isNotEmpty) h.player, h.heroClass, h.race].where((e) => e.isNotEmpty).join(' · '), style: TextStyle(color: p.muted, fontSize: 19)),
                    ])),
                  ]),
                ),
              ),
          ],
          const SizedBox(height: 22),
          Center(
            child: heroes.isEmpty
                ? RuneButton('Pular por agora', tone: RuneTone.ghost, onPressed: () async {
                    final ok = await confirmDialog(context, 'Seguir sem heróis?', 'Sem os heróis cadastrados a IA não reconhece os jogadores e pode tratar personagens como NPCs. Dá para cadastrar depois em Heróis.', ok: 'Pular');
                    if (ok && context.mounted) context.go('/campaign/$cid');
                  })
                : RuneButton('Concluir', icon: PxIcons.check, onPressed: () => context.go('/campaign/$cid')),
          ),
        ]),
      ),
    );
  }
}
