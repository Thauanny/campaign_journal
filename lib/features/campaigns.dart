import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers.dart';
import '../core/engines.dart';
import '../core/rpg_theme.dart';
import '../core/ui.dart';
import 'ai_screen.dart';
import 'quota_banner.dart';
import '../core/px_icons.dart';

/// Tela inicial: suas campanhas como cartões grandes, com a IA ativa à vista.
class CampaignsScreen extends ConsumerWidget {
  const CampaignsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.rpg;
    final list = ref.watch(campaignsProvider);
    final engine = engineById(ref.watch(engineProvider));
    // Primeira abertura: leva direto à escolha da IA.
    if (ref.read(settingsProvider).engine == null && !ref.read(settingsProvider).setupSeen) {
      ref.read(settingsProvider).setSetupSeen();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/ai');
      });
    }
    return Scaffold(
      appBar: GameBar(title: const Text('Diário da Campanha'), actions: [
        GestureDetector(
          onTap: () => context.go('/settings'),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              color: engine == null ? p.crimson : p.bgDeep,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(PxIcons.zap, size: 24, color: engine == null ? p.bgDeep : p.gold),
                const SizedBox(width: 6),
                Text((engine?.name ?? 'Escolher IA').toUpperCase(), style: pxText(12, engine == null ? p.bgDeep : p.text)),
              ]),
            ),
          ),
        ),
        IconButton(tooltip: 'Configurações', onPressed: () => context.go('/settings'), icon: const Icon(PxIcons.sliders)),
      ]),
      body: list.when(
        loading: () => const AppLoading(),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (cs) => MaxWidth(
          width: 820,
          ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 48), children: [
            const QuotaBanner(),
            const AiBanner(),
            if (cs.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: EmptyState(PxIcons.bookOpen, 'Sua primeira campanha', 'Crie uma campanha, depois registre as sessões: grave, importe áudio ou cole a transcrição.',
                    action: RuneButton('Criar campanha', icon: PxIcons.plus, onPressed: () => context.go('/campaign/new'))),
              )
            else ...[
              Row(children: [
                Expanded(child: Text('SUAS CAMPANHAS', style: pxText(16, p.gold))),
                RuneButton('Nova', icon: PxIcons.plus, compact: true, onPressed: () => context.go('/campaign/new')),
              ]),
              const SizedBox(height: 14),
              for (final c in cs) Padding(padding: const EdgeInsets.only(bottom: 12), child: _CampaignCard(c)),
            ],
          ]),
        ),
      ),
    );
  }
}

class _CampaignCard extends ConsumerWidget {
  final dynamic c;
  const _CampaignCard(this.c);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.rpg;
    final sessions = ref.watch(sessionsProvider(c.id)).value ?? [];
    final last = sessions.isEmpty ? null : sessions.first;
    final cover = c.coverPath as String?;
    final hasCover = cover != null && File(cover).existsSync();
    final toReview = sessions.where((s) => s.status == 'review').length;
    return RpgCard(
      onTap: () => context.go('/campaign/${c.id}'),
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        Container(
          width: 84, height: 84,
          color: p.bgDeep,
          child: hasCover ? Image.file(File(cover), fit: BoxFit.cover, filterQuality: FilterQuality.none) : Icon(PxIcons.bookOpen, size: 48, color: p.gold),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text((c.name as String).toUpperCase(), style: pxText(17, p.text)),
          const SizedBox(height: 4),
          Text(c.system as String, style: TextStyle(color: p.arcane, fontSize: 21)),
          const SizedBox(height: 6),
          Text(last == null ? 'Sem sessões ainda' : '${sessions.length} sessões · última em ${_d(last.date)}', style: TextStyle(color: p.muted, fontSize: 20)),
          if (toReview > 0) Padding(padding: const EdgeInsets.only(top: 6), child: Text('$toReview PARA REVISAR', style: pxText(12, p.arcane))),
        ])),
        Icon(PxIcons.chevronRight, color: p.gold),
      ]),
    );
  }
}

String _d(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

class CampaignFormScreen extends ConsumerStatefulWidget {
  final String? campaignId;
  const CampaignFormScreen({super.key, this.campaignId});
  @override
  ConsumerState<CampaignFormScreen> createState() => _CampaignFormState();
}

class _CampaignFormState extends ConsumerState<CampaignFormScreen> {
  final _name = TextEditingController();
  final _desc = TextEditingController();
  String _system = rpgSystems.first;
  final _otherSystem = TextEditingController();
  String? _cover;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    final id = widget.campaignId;
    if (id == null) {
      _loaded = true;
    } else {
      ref.read(repoProvider).campaign(id).then((c) {
        if (c == null || !mounted) return;
        setState(() {
          _name.text = c.name;
          _desc.text = c.description;
          // sistema fora da lista = "Outro" com o nome digitado
          if (rpgSystems.contains(c.system)) {
            _system = c.system;
          } else {
            _system = 'Outro';
            _otherSystem.text = c.system == 'Outro' ? '' : c.system;
          }
          _cover = c.coverPath;
          _loaded = true;
        });
      });
    }
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) return snack(context, 'Dê um nome à campanha.');
    final id = await ref.read(repoProvider).saveCampaign(
        id: widget.campaignId,
        name: _name.text.trim(),
        system: _system == 'Outro' && _otherSystem.text.trim().isNotEmpty ? _otherSystem.text.trim() : _system,
        description: _desc.text.trim(),
        coverPath: _cover);
    if (!mounted) return;
    // Campanha nova: o próximo passo é cadastrar os heróis (a IA precisa deles).
    context.go(widget.campaignId == null ? '/campaign/$id/heroes/start' : '/campaign/$id');
  }

  /// Limpar dados: mostra o que será apagado e pergunta se os heróis também vão.
  Future<void> _clearData() async {
    final id = widget.campaignId!;
    final repo = ref.read(repoProvider);
    final c = await repo.campaignCounts(id);
    if (!mounted) return;
    var withHeroes = false;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, set) {
        final p = ctx.rpg;
        return AlertDialog(
          title: const Text('LIMPAR DADOS?'),
          content: SizedBox(
            width: 460,
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Serão apagados: ${c.sessions} sessão(ões), ${c.entries} entrada(s) da enciclopédia, ganchos, segredos e o histórico de combate. A campanha continua.', style: const TextStyle(fontSize: 22, height: 1.25)),
              const SizedBox(height: 14),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => set(() => withHeroes = !withHeroes),
                child: Row(children: [
                  Icon(withHeroes ? PxIcons.checkboxOn : PxIcons.checkbox, color: withHeroes ? p.gold : p.muted),
                  const SizedBox(width: 10),
                  Expanded(child: Text('Apagar também os ${c.heroes} herói(s)', style: TextStyle(fontSize: 22, color: p.text))),
                ]),
              ),
              const SizedBox(height: 10),
              Text('Isso não pode ser desfeito.', style: TextStyle(fontSize: 20, color: p.crimson)),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCELAR')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('LIMPAR')),
          ],
        );
      }),
    );
    if (ok != true) return;
    await repo.clearCampaignData(id, deleteHeroes: withHeroes);
    if (mounted) snack(context, 'Dados da campanha apagados.');
  }

  /// Apagar a campanha toda: pede para digitar o nome, para evitar acidente.
  Future<void> _deleteCampaign() async {
    final name = _name.text.trim();
    final typed = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, set) {
        final match = typed.text.trim().toLowerCase() == name.toLowerCase();
        return AlertDialog(
          title: const Text('APAGAR CAMPANHA?'),
          content: SizedBox(
            width: 460,
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Tudo será apagado: sessões, transcrições, enciclopédia e heróis. Isso não pode ser desfeito.', style: TextStyle(fontSize: 22, height: 1.25)),
              const SizedBox(height: 12),
              Text('Digite o nome da campanha para confirmar: "$name"', style: TextStyle(fontSize: 20, color: ctx.rpg.muted)),
              const SizedBox(height: 8),
              TextField(controller: typed, onChanged: (_) => set(() {}), decoration: const InputDecoration(hintText: 'nome da campanha')),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCELAR')),
            FilledButton(onPressed: match ? () => Navigator.pop(ctx, true) : null, child: const Text('APAGAR')),
          ],
        );
      }),
    );
    if (ok != true) return;
    await ref.read(repoProvider).deleteCampaign(widget.campaignId!);
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: GameBar(
          title: Text(widget.campaignId == null ? 'Nova campanha' : 'Editar campanha'),
          leading: BackButton(onPressed: () => context.go(widget.campaignId == null ? '/' : '/campaign/${widget.campaignId}')),
          actions: [
            if (widget.campaignId != null)
              IconButton(
                  tooltip: 'Excluir campanha',
                  icon: const Icon(PxIcons.trash),
                  onPressed: () async {
                    final ok = await confirmDialog(context, 'Excluir campanha?',
                        'Sessões, transcrições e entidades serão apagadas do aparelho.',
                        ok: 'Excluir');
                    if (!ok) return;
                    await ref.read(repoProvider).deleteCampaign(widget.campaignId!);
                    if (context.mounted) context.go('/');
                  })
          ]),
      body: MaxWidth(
        width: 640,
        ListView(padding: const EdgeInsets.fromLTRB(16, 20, 16, 48), children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nome da campanha')),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
              initialValue: rpgSystems.contains(_system) ? _system : 'Outro',
              decoration: const InputDecoration(labelText: 'Sistema de RPG'),
              items: [for (final s in rpgSystems) DropdownMenuItem(value: s, child: Text(s))],
              onChanged: (v) => setState(() => _system = v!)),
          if (_system == 'Outro')
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: TextField(controller: _otherSystem, decoration: const InputDecoration(labelText: 'Qual sistema?', hintText: 'Ex.: Daggerheart, Shadowrun…')),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
                'O sistema define os campos da ficha dos heróis e ensina a IA o vocabulário da mesa (poderes, vida, recursos, condições), então a análise das sessões fica mais precisa.',
                style: TextStyle(color: context.rpg.muted, fontSize: 19, height: 1.3)),
          ),
          const SizedBox(height: 14),
          TextField(controller: _desc, maxLines: 3, decoration: const InputDecoration(labelText: 'Descrição (opcional)')),
          const SizedBox(height: 16),
          Row(children: [
            if (_cover != null && File(_cover!).existsSync())
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(border: Border.all(color: context.rpg.border, width: 2)),
                  child: Image.file(File(_cover!), fit: BoxFit.cover, filterQuality: FilterQuality.none),
                ),
              ),
            RuneButton(_cover == null ? 'Escolher capa (opcional)' : 'Trocar capa', icon: PxIcons.image, tone: RuneTone.ghost, compact: true, onPressed: () async {
              final r = await FilePicker.pickFiles(type: FileType.image);
              if (r.isNotEmpty && r.first.path != null) {
                setState(() => _cover = r.first.path);
              }
            }),
          ]),
          if (widget.campaignId == null)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text('Próximo passo: cadastrar os heróis e seus jogadores. O sistema escolhido define os campos da ficha.', style: TextStyle(color: context.rpg.muted, fontSize: 20, height: 1.3)),
            ),
          const SizedBox(height: 24),
          RuneButton(widget.campaignId == null ? 'Criar campanha' : 'Salvar', icon: PxIcons.check, onPressed: _save),
          if (widget.campaignId != null) ...[
            const SizedBox(height: 32),
            PxExpandable(
              title: 'Apagar dados',
              icon: PxIcons.trash,
              accent: context.rpg.crimson,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Limpar dados', style: pxText(14, context.rpg.text)),
                const SizedBox(height: 4),
                Text('Apaga as sessões, a enciclopédia, os ganchos e o histórico, mas mantém a campanha (e, se quiser, os heróis).', style: TextStyle(color: context.rpg.muted, fontSize: 20, height: 1.25)),
                const SizedBox(height: 10),
                RuneButton('Limpar dados', icon: PxIcons.trash, compact: true, tone: RuneTone.ghost, onPressed: _clearData),
                const SizedBox(height: 22),
                Text('Apagar a campanha inteira', style: pxText(14, context.rpg.text)),
                const SizedBox(height: 4),
                Text('Remove tudo: a campanha, as sessões, a enciclopédia e os heróis. Não dá para desfazer.', style: TextStyle(color: context.rpg.muted, fontSize: 20, height: 1.25)),
                const SizedBox(height: 10),
                RuneButton('Apagar campanha', icon: PxIcons.trash, compact: true, tone: RuneTone.danger, onPressed: _deleteCampaign),
              ]),
            ),
          ],
        ]),
      ),
    );
  }
}
