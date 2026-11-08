import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers.dart';
import '../core/rpg_theme.dart';
import '../core/ui.dart';
import '../data/database.dart';
import '../data/repo_facts.dart';
import '../domain/locate.dart';
import '../domain/spell_detector.dart' show isHeroName, heroKeys;
import '../domain/pipeline.dart';
import '../core/px_icons.dart';

/// Revisão: cada sugestão é uma "descoberta" a julgar. Princípio: um cartão =
/// uma decisão; Aceitar é a ação principal, o resto fica num menu.
class ReviewScreen extends ConsumerStatefulWidget {
  final String cid;
  final String sid;
  const ReviewScreen(this.cid, this.sid, {super.key});
  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  String? _kind; // tipo de entidade, ou 'fact' para combate

  @override
  Widget build(BuildContext context) {
    final cid = widget.cid, sid = widget.sid;
    final p = context.rpg;
    final pending = ref.watch(pendingMentionsProvider(sid)).value ?? [];
    final all = ref.watch(sessionMentionsProvider(sid)).value ?? [];
    final segs = ref.watch(segmentsProvider(sid)).value ?? [];
    final facts = ref.watch(factsProvider(sid)).value ?? [];
    final heroes = ref.watch(heroesProvider(cid)).value ?? [];
    final pendingFacts = facts.where((f) => f.status == 'suggested').toList();
    final ents = {for (final e in ref.watch(allEntitiesProvider(cid)).value ?? <Entity>[]) e.id: e};
    final repo = ref.read(repoProvider);

    final counts = <String, int>{};
    for (final m in pending) {
      final k = ents[m.entityId]?.kind;
      if (k != null) counts[k] = (counts[k] ?? 0) + 1;
    }
    final mentionsShown = _kind == 'fact' ? <Mention>[] : (_kind == null ? pending : pending.where((m) => ents[m.entityId]?.kind == _kind).toList());
    final factsShown = (_kind == null || _kind == 'fact') ? pendingFacts : <Fact>[];
    final total = all.length + facts.length;
    final left = pending.length + pendingFacts.length;
    final done = total - left;
    final chipCount = counts.length + (pendingFacts.isEmpty ? 0 : 1);

    Future<void> finish() async {
      await repo.confirmEvents(sid);
      await repo.setSessionStatus(sid, 'done');
      if (context.mounted) context.go('/campaign/$cid/session/$sid');
    }

    return Scaffold(
      appBar: GameBar(
        title: const Text('Revisão'),
        leading: BackButton(onPressed: () => context.go('/campaign/$cid/session/$sid')),
        actions: [
          if (left > 0)
            RuneButton('Aceitar tudo', compact: true, tone: RuneTone.ghost, onPressed: () async {
              if (!await confirmDialog(context, 'Aceitar tudo?', 'Todas as $left descobertas e fatos viram parte da campanha, e o dano, a cura e o XP são aplicados às fichas dos heróis.', ok: 'Aceitar tudo')) return;
              await repo.confirmAll(sid);
              if (context.mounted) context.go('/campaign/$cid/session/$sid');
            }),
        ],
      ),
      body: MaxWidth(
        width: 760,
        Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(left == 0 ? 'TUDO JULGADO' : '$left POR JULGAR', style: pxText(15, p.text))),
                Text('$done de $total', style: TextStyle(color: p.muted, fontSize: 21)),
              ]),
              const SizedBox(height: 8),
              XpBar(total == 0 ? 1 : done / total, height: 10),
              if (left > 0 && chipCount > 1) ...[
                const SizedBox(height: 14),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    PxChoice('Todas', _kind == null, () => setState(() => _kind = null)),
                    for (final k in kindLabels.keys)
                      if ((counts[k] ?? 0) > 0) PxChoice('${kindLabels[k]} ${counts[k]}', _kind == k, () => setState(() => _kind = _kind == k ? null : k), icon: kindIcons[k], color: p.kind(k)),
                    if (pendingFacts.isNotEmpty) PxChoice('Combate ${pendingFacts.length}', _kind == 'fact', () => setState(() => _kind = _kind == 'fact' ? null : 'fact'), icon: PxIcons.alert, color: p.crimson),
                  ]),
                ),
              ],
              if (_kind != null && mentionsShown.length + factsShown.length > 1)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () async {
                      for (final m in mentionsShown) {
                        await repo.confirmMention(m.id);
                      }
                      for (final f in factsShown) {
                        await repo.confirmFact(f.id);
                      }
                      setState(() => _kind = null);
                    },
                    child: Text('ACEITAR OS ${mentionsShown.length + factsShown.length} VISÍVEIS'),
                  ),
                ),
            ]),
          ),
          Expanded(
            child: left == 0
                ? EmptyState(PxIcons.trophy, 'Nada pendente', 'Tudo foi julgado.', action: RuneButton('Concluir revisão', icon: PxIcons.check, onPressed: finish))
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 48),
                    children: [
                      for (final m in mentionsShown) Padding(padding: const EdgeInsets.only(bottom: 12), child: _MentionCard(cid, m, segs)),
                      if (factsShown.isNotEmpty) ...[
                        if (mentionsShown.isNotEmpty) const SectionTitle('Combate e recompensas'),
                        for (final f in factsShown) Padding(padding: const EdgeInsets.only(bottom: 12), child: _FactCard(f, heroes)),
                      ],
                    ],
                  ),
          ),
        ]),
      ),
    );
  }
}

/// Fato de combate: dano, cura, XP, condição ou saque. Aceitar aplica à ficha do herói.
class _FactCard extends ConsumerWidget {
  final Fact f;
  final List<Heroe> heroes;
  const _FactCard(this.f, this.heroes);

  String _title() => factTitle(f);

  /// "Bram: PV 20 → 12" se o alvo é um herói com PV cadastrado.
  String? _preview() {
    if (f.amount == null || (f.kind != 'damage' && f.kind != 'heal' && f.kind != 'xp')) return null;
    final t = f.target.toLowerCase();
    if (f.kind == 'xp') {
      final all = t.isEmpty || const {'grupo', 'o grupo', 'todos', 'party'}.contains(t);
      final hs = all ? heroes : heroes.where((h) => isHeroName(f.target, heroKeys([h.name, h.player]))).toList();
      return hs.isEmpty ? null : 'Soma +${f.amount} XP a ${hs.length == 1 ? hs.first.name : '${hs.length} heróis'}';
    }
    for (final h in heroes) {
      if (!isHeroName(f.target, heroKeys([h.name, h.player]))) continue;
      if (h.hpCurrent == null) return '${h.name}: sem PV cadastrado (cadastre na ficha)';
      final next = f.kind == 'damage' ? (h.hpCurrent! - f.amount!).clamp(0, 1 << 30) : (h.hpCurrent! + f.amount!).clamp(0, h.hpMax ?? (1 << 30));
      return '${h.name}: PV ${h.hpCurrent} → $next';
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.rpg;
    final repo = ref.read(repoProvider);
    final color = switch (f.kind) { 'damage' => p.crimson, 'heal' => p.emerald, 'xp' => p.gold, 'condition' => p.arcane, _ => p.kind('item') };
    final icon = switch (f.kind) { 'damage' => PxIcons.alert, 'heal' => PxIcons.heart, 'xp' => PxIcons.trophy, 'condition' => PxIcons.infoBox, _ => PxIcons.coin };
    final preview = _preview();
    return RpgCard(
      accent: color,
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 48, height: 48, color: Color.alphaBlend(color.withValues(alpha: .14), p.surface), child: Icon(icon, color: color, size: 36)),
          const SizedBox(width: 12),
          Expanded(child: Text(_title(), style: TextStyle(fontSize: 23, height: 1.25, color: p.text))),
          if (f.side == 'hero' || f.side == 'enemy')
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), color: f.side == 'hero' ? p.arcane : p.crimson, child: Text(f.side == 'hero' ? 'HERÓI' : 'INIMIGO', style: pxText(11, onColor(f.side == 'hero' ? p.arcane : p.crimson)))),
        ]),
        if (preview != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(preview, style: TextStyle(color: p.gold, fontSize: 21))),
        if (f.quote.isNotEmpty)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: p.bgDeep, border: Border(left: BorderSide(color: p.gold, width: 4))),
            child: Text('${f.atMs != null ? '${fmtClock(f.atMs!)}  ' : ''}"${f.quote}"', maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 21, height: 1.3, color: p.text)),
          ),
        const SizedBox(height: 12),
        Row(children: [
          RuneButton('Aceitar', icon: PxIcons.check, compact: true, onPressed: () => repo.confirmFact(f.id)),
          const SizedBox(width: 6),
          TextButton(onPressed: () => repo.discardFact(f.id), child: Text('DESCARTAR', style: pxText(13, p.crimson))),
        ]),
      ]),
    );
  }
}

class _MentionCard extends ConsumerWidget {
  final String cid;
  final Mention m;
  final List<Segment> segs;
  const _MentionCard(this.cid, this.m, this.segs);

  /// Trecho real (pela citação/nome) e as falas ao redor.
  (List<Segment>, Segment?) _context(Entity e) {
    if (segs.isEmpty) return (const [], null);
    final aliases = e.aliases.split(',').map((a) => a.trim()).where((a) => a.isNotEmpty).toList();
    final hit = locateMention(segs, quote: m.quote, name: e.name, aliases: aliases, atMs: m.atMs);
    if (hit == null) return (const [], null);
    final idx = segs.indexWhere((s) => s.id == hit.id);
    return (segs.sublist((idx - 1).clamp(0, segs.length), (idx + 2).clamp(0, segs.length)), hit);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final e = ref.watch(entityProvider(m.entityId)).value;
    if (e == null) return const SizedBox.shrink();
    final p = context.rpg;
    final kc = p.kind(e.kind);
    final repo = ref.read(repoProvider);
    final (ctx, hit) = _context(e);
    final isNew = e.review == 'suggested';
    return RpgCard(
      accent: kc,
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          KindAvatar(e.kind, size: 48),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(e.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: pxText(16, p.text)),
            const SizedBox(height: 6),
            KindBadge(e.kind, label: isNew ? 'Novo ${kindSingular[e.kind]}' : (m.proposedField.isNotEmpty ? 'Mudança' : (e.kind == 'spell' ? 'Novo uso' : 'Apareceu de novo'))),
            if (!isNew) Padding(padding: const EdgeInsets.only(top: 4), child: Text('Já está na enciclopédia', style: TextStyle(color: p.muted, fontSize: 19))),
          ])),
        ]),
        if (e.description.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 10), child: Text(e.description, maxLines: 4, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 22, height: 1.3))),
        if (m.detail.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(spacing: 8, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
              if (m.side == 'hero' || m.side == 'enemy')
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), color: m.side == 'hero' ? p.arcane : p.crimson, child: Text(m.side == 'hero' ? 'DOS HERÓIS' : 'DOS INIMIGOS', style: pxText(11, onColor(m.side == 'hero' ? p.arcane : p.crimson)))),
              Text(m.detail, style: TextStyle(color: kc, fontSize: 22)),
              if (m.target.isNotEmpty) Text('→ ${m.target}', style: TextStyle(color: p.text, fontSize: 22)),
              if (m.result.isNotEmpty) Text('(${m.result})', style: TextStyle(color: p.muted, fontSize: 21)),
            ]),
          ),
        if (m.proposedField.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('${m.proposedField == 'attr' ? 'Atributo' : 'Status'}: ${(m.proposedField == 'attr' ? e.attr : e.status).isEmpty ? '—' : (m.proposedField == 'attr' ? e.attr : e.status)}  →  ${m.proposedValue}',
                style: TextStyle(color: p.gold, fontSize: 21)),
          ),
        const SizedBox(height: 12),
        _QuoteBox(ctx: ctx, hit: hit, fallback: m.quote, atMs: m.atMs),
        const SizedBox(height: 14),
        Row(children: [
          RuneButton('Aceitar', icon: PxIcons.check, compact: true, onPressed: () => repo.confirmMention(m.id)),
          const SizedBox(width: 6),
          TextButton(onPressed: () => repo.discardMention(m.id), child: Text('DESCARTAR', style: pxText(13, p.crimson))),
          const Spacer(),
          PopupMenuButton<String>(
            tooltip: 'Mais',
            icon: Icon(PxIcons.moreHorizontal, color: p.text),
            onSelected: (v) => v == 'edit' ? _edit(context, ref, e) : _merge(context, ref, e),
            itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('Editar')), PopupMenuItem(value: 'merge', child: Text('Mesclar com outra entrada'))],
          ),
        ]),
      ]),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, Entity e) async {
    final name = TextEditingController(text: e.name);
    final desc = TextEditingController(text: e.description);
    final status = TextEditingController(text: m.proposedField == 'status' ? m.proposedValue : e.status);
    var kind = e.kind;
    final ok = await showDialog<bool>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, set) => AlertDialog(
          title: const Text('Editar sugestão'),
          content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Nome')),
            DropdownButtonFormField<String>(initialValue: kind, decoration: const InputDecoration(labelText: 'Tipo'), items: [for (final k in kindSingular.entries) DropdownMenuItem(value: k.key, child: Text(k.value))], onChanged: (v) => set(() => kind = v!)),
            TextField(controller: status, decoration: const InputDecoration(labelText: 'Status / atitude')),
            TextField(controller: desc, maxLines: 3, decoration: const InputDecoration(labelText: 'Descrição')),
          ])),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Salvar'))],
        )));
    if (ok != true) return;
    final repo = ref.read(repoProvider);
    final newStatus = status.text.trim();
    await repo.db.transaction(() async {
      if (e.review == 'suggested') {
        // entidade ainda é só sugestão: aplica direto
        await repo.saveEntity(EntitiesCompanion(id: Value(e.id), campaignId: Value(e.campaignId), kind: Value(kind), name: Value(name.text.trim()), description: Value(desc.text.trim()), status: Value(newStatus)));
      } else {
        await repo.saveEntity(EntitiesCompanion(id: Value(e.id), campaignId: Value(e.campaignId), kind: Value(e.kind), name: Value(name.text.trim()), description: Value(desc.text.trim())));
        await (repo.db.update(repo.db.mentions)..where((x) => x.id.equals(m.id))).write(MentionsCompanion(proposedField: Value(newStatus.isEmpty ? '' : 'status'), proposedValue: Value(newStatus)));
      }
    });
  }

  Future<void> _merge(BuildContext context, WidgetRef ref, Entity e) async {
    final repo = ref.read(repoProvider);
    final all = (await repo.entitiesOf(cid)).where((x) => x.id != e.id && x.kind == e.kind).toList()..sort((a, b) => a.name.compareTo(b.name));
    if (!context.mounted) return;
    if (all.isEmpty) return snack(context, 'Não há outra entidade do mesmo tipo para mesclar.');
    final target = await showDialog<Entity>(context: context, builder: (ctx) => SimpleDialog(
          title: Text('Mesclar "${e.name}" com…'),
          children: [for (final x in all) SimpleDialogOption(onPressed: () => Navigator.pop(ctx, x), child: Text('${x.name}${x.review == 'suggested' ? '  (sugerido)' : ''}'))],
        ));
    if (target != null) await repo.mergeEntities(e.id, target.id);
  }
}

/// Trecho original: mostra só a fala certa; o contexto abre sob demanda.
class _QuoteBox extends StatefulWidget {
  final List<Segment> ctx;
  final Segment? hit;
  final String fallback;
  final int? atMs;
  const _QuoteBox({required this.ctx, required this.hit, required this.fallback, required this.atMs});
  @override
  State<_QuoteBox> createState() => _QuoteBoxState();
}

class _QuoteBoxState extends State<_QuoteBox> {
  bool _open = false;
  @override
  Widget build(BuildContext context) {
    final p = context.rpg;
    final hit = widget.hit;
    final text = hit?.text_ ?? (widget.fallback.isEmpty ? 'Sem citação.' : widget.fallback);
    final at = hit?.startMs ?? widget.atMs;
    final others = widget.ctx.where((s) => hit == null || s.id != hit.id).toList();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: p.bgDeep, border: Border(left: BorderSide(color: p.gold, width: 4))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('TRECHO${at != null ? ' · ${fmtClock(at)}' : ''}', style: pxText(11, p.muted)),
        const SizedBox(height: 6),
        if (_open)
          for (final s in widget.ctx)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(s.text_, style: TextStyle(fontSize: 21, height: 1.3, color: hit != null && s.id == hit.id ? p.text : p.muted, fontWeight: hit != null && s.id == hit.id ? FontWeight.w700 : FontWeight.w400)),
            )
        else
          Text('"$text"', maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 22, height: 1.3, color: p.text)),
        if (others.isNotEmpty)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(_open ? 'OCULTAR CONTEXTO' : 'VER CONTEXTO', style: pxText(11, p.gold)),
                const SizedBox(width: 6),
                Icon(_open ? PxIcons.chevronUp : PxIcons.chevronDown, size: 24, color: p.gold),
              ]),
            ),
          ),
      ]),
    );
  }
}
