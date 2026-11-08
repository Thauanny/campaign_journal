import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers.dart';
import '../core/rpg_theme.dart';
import '../core/ui.dart';
import '../data/database.dart';
import '../data/repo_notes.dart';
import '../data/repository.dart';
import '../domain/pipeline.dart';
import '../core/px_icons.dart';

/// Tela 9 — Enciclopédia: NPCs, locais, missões, itens e facções, com busca e filtros.
class EncyclopediaScreen extends ConsumerStatefulWidget {
  final String cid;
  const EncyclopediaScreen(this.cid, {super.key});
  @override
  ConsumerState<EncyclopediaScreen> createState() => _EncState();
}

class _EncState extends ConsumerState<EncyclopediaScreen> {
  String? _kind;
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final p = context.rpg;
    final everything = ref.watch(entitiesProvider((widget.cid, null))).value ?? [];
    final base = _kind == null ? everything : everything.where((e) => e.kind == _kind).toList();
    final list = _q.isEmpty
        ? base
        : base.where((e) => '${e.name} ${e.aliases} ${e.description}'.toLowerCase().contains(_q.toLowerCase())).toList();
    final pending = everything.where((e) => e.review == 'suggested').length;
    return Scaffold(
      appBar: GameBar(
        title: const Text('Enciclopédia'),
        leading: BackButton(onPressed: () => context.go('/campaign/${widget.cid}')),
        actions: [RuneButton('Nova', icon: PxIcons.plus, compact: true, onPressed: _add)],
      ),
      body: MaxWidth(
        width: 980,
        Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: TextField(decoration: const InputDecoration(prefixIcon: Icon(PxIcons.search), hintText: 'Buscar NPC, local, missão…'), onChanged: (v) => setState(() => _q = v.trim())),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(children: [
                PxChoice('Todos · ${everything.length}', _kind == null, () => setState(() => _kind = null)),
                for (final k in kindLabels.entries)
                  PxChoice('${k.value} · ${everything.where((e) => e.kind == k.key).length}', _kind == k.key, () => setState(() => _kind = _kind == k.key ? null : k.key), color: p.kind(k.key), icon: kindIcons[k.key]),
              ]),
            ),
          ),
          if (pending > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Text('$pending entrada(s) sugerida(s) ainda não confirmadas (marcadas com ?).', style: TextStyle(color: p.gold, fontSize: 19)),
            ),
          Expanded(
            child: list.isEmpty
                ? const EmptyState(PxIcons.map, 'Nada por aqui', 'Confirme descobertas na revisão de uma sessão ou crie uma entrada à mão.')
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 48),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 470, mainAxisExtent: 128, crossAxisSpacing: 12, mainAxisSpacing: 12),
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final e = list[i];
                      return RpgCard(
                        accent: e.review == 'confirmed' ? p.kind(e.kind) : p.border,
                        onTap: () => context.go('/campaign/${widget.cid}/entity/${e.id}'),
                        padding: const EdgeInsets.all(10),
                        child: Row(children: [
                          KindAvatar(e.kind, size: 52),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text('${e.name}${e.review == 'suggested' ? ' ?' : ''}'.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: pxText(14, p.text)),
                            Text([kindSingular[e.kind]!, if (e.status.isNotEmpty) e.status, if (e.attr.isNotEmpty) e.attr].join(' · '), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: p.kind(e.kind), fontSize: 19)),
                            if (e.description.isNotEmpty) Text(e.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: p.muted, fontSize: 19, height: 1.05)),
                          ])),
                        ]),
                      );
                    }),
          ),
        ]),
      ),
    );
  }

  Future<void> _add() async {
    final name = TextEditingController();
    var kind = _kind ?? 'npc';
    final ok = await showDialog<bool>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, set) => AlertDialog(
          title: const Text('Nova entrada'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, autofocus: true, decoration: const InputDecoration(labelText: 'Nome')),
            DropdownButtonFormField<String>(initialValue: kind, items: [for (final k in kindSingular.entries) DropdownMenuItem(value: k.key, child: Text(k.value))], onChanged: (v) => set(() => kind = v!)),
          ]),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Criar'))],
        )));
    if (ok != true || name.text.trim().isEmpty) return;
    final id = await ref.read(repoProvider).saveEntity(EntitiesCompanion.insert(id: newId(), campaignId: widget.cid, kind: kind, name: name.text.trim(), review: const Value('confirmed')));
    if (mounted) context.go('/campaign/${widget.cid}/entity/$id');
  }
}

const _statusOptions = {
  'npc': ['aliado', 'neutro', 'inimigo'],
  'quest': ['ativa', 'concluída', 'falhou'],
};

/// Ficha de uma entidade: dados, histórico por sessão e citações (com horário).
class EntityScreen extends ConsumerStatefulWidget {
  final String cid;
  final String eid;
  const EntityScreen(this.cid, this.eid, {super.key});
  @override
  ConsumerState<EntityScreen> createState() => _EntityState();
}

class _EntityState extends ConsumerState<EntityScreen> {
  Future<void> _edit(Entity e) async {
    final name = TextEditingController(text: e.name);
    final aliases = TextEditingController(text: e.aliases);
    final desc = TextEditingController(text: e.description);
    final attr = TextEditingController(text: e.attr);
    final giver = TextEditingController(text: e.giver);
    final reward = TextEditingController(text: e.reward);
    var status = e.status;
    final opts = _statusOptions[e.kind];
    final ok = await showDialog<bool>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, set) => AlertDialog(
          title: Text('Editar ${kindSingular[e.kind]}'),
          content: SizedBox(width: 400, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Nome')),
            TextField(controller: aliases, decoration: const InputDecoration(labelText: 'Apelidos (vírgula)')),
            if (opts != null)
              DropdownButtonFormField<String>(initialValue: opts.contains(status) ? status : null, decoration: const InputDecoration(labelText: 'Status'), items: [for (final o in opts) DropdownMenuItem(value: o, child: Text(o))], onChanged: (v) => set(() => status = v ?? '')),
            TextField(controller: attr, decoration: InputDecoration(labelText: switch (e.kind) { 'npc' => 'Vivo ou morto', 'location' => 'Tipo (cidade, masmorra)', 'item' => 'Raridade', _ => 'Atributo' })),
            if (e.kind == 'quest') ...[
              TextField(controller: giver, decoration: const InputDecoration(labelText: 'Quem deu')),
              TextField(controller: reward, decoration: const InputDecoration(labelText: 'Recompensa')),
            ],
            TextField(controller: desc, maxLines: 4, decoration: const InputDecoration(labelText: 'Descrição')),
          ]))),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Salvar'))],
        )));
    if (ok != true) return;
    await ref.read(repoProvider).saveEntity(EntitiesCompanion(
        id: Value(e.id), campaignId: Value(e.campaignId), kind: Value(e.kind),
        name: Value(name.text.trim()), aliases: Value(aliases.text.trim()),
        description: Value(desc.text.trim()), status: Value(status), attr: Value(attr.text.trim()),
        giver: Value(giver.text.trim()), reward: Value(reward.text.trim()),
        review: const Value('confirmed')));
  }

  static const _labels = ['vive em', 'fica em', 'lidera', 'serve a', 'aliado de', 'inimigo de', 'dono de', 'deu a missão', 'pertence a', 'está em'];

  Future<void> _addRelation(Entity e) async {
    final others = (await ref.read(repoProvider).entitiesOf(widget.cid)).where((x) => x.id != e.id).toList()..sort((a, b) => a.name.compareTo(b.name));
    if (!mounted) return;
    if (others.isEmpty) return snack(context, 'Crie outras entradas para poder ligá-las.');
    String? target = others.first.id;
    final label = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, set) => AlertDialog(
          title: const Text('NOVA LIGAÇÃO'),
          content: SizedBox(width: 420, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(e.name, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 8),
            Wrap(children: [for (final l in _labels) PxChoice(l, label.text == l, () => set(() => label.text = l))]),
            TextField(controller: label, onChanged: (_) => set(() {}), decoration: const InputDecoration(labelText: 'Relação (ex.: vive em)')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: target,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Com'),
              items: [for (final o in others) DropdownMenuItem(value: o.id, child: Text('${o.name}  (${kindSingular[o.kind]})', overflow: TextOverflow.ellipsis))],
              onChanged: (v) => set(() => target = v),
            ),
          ]))),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCELAR')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('LIGAR'))],
        )));
    if (ok == true && target != null) await ref.read(repoProvider).addRelation(widget.cid, e.id, target!, label.text);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.rpg;
    final e = ref.watch(entityProvider(widget.eid)).value;
    if (e == null) return const Scaffold(body: EmptyState(PxIcons.map, 'Entrada não encontrada', 'Ela pode ter sido excluída ou mesclada.'));
    final mentions = ref.watch(entityMentionsProvider(widget.eid)).value ?? [];
    final sessions = ref.watch(sessionsProvider(widget.cid)).value ?? [];
    final hist = ref.watch(historyProvider(widget.cid)).value ?? [];
    final mine = hist.where((h) => h.entityId == e.id).toList();
    final allEnts = {for (final x in ref.watch(entitiesProvider((widget.cid, null))).value ?? <Entity>[]) x.id: x};
    final rels = (ref.watch(relationsProvider(widget.cid)).value ?? []).where((r) => r.fromId == e.id || r.toId == e.id).toList();
    String sn(String sid) => 'Sessão ${sessions.where((s) => s.id == sid).firstOrNull?.number ?? '?'}';
    final kc = p.kind(e.kind);
    return Scaffold(
      appBar: GameBar(
        title: Text(e.name),
        leading: BackButton(onPressed: () => context.go('/campaign/${widget.cid}/encyclopedia')),
        actions: [
          IconButton(icon: const Icon(PxIcons.edit), onPressed: () => _edit(e)),
          IconButton(icon: const Icon(PxIcons.trash), onPressed: () async {
            if (!await confirmDialog(context, 'Excluir "${e.name}"?', 'Menções, ligações e histórico também serão removidos.', ok: 'Excluir')) return;
            await ref.read(repoProvider).deleteEntity(e.id);
            if (context.mounted) context.go('/campaign/${widget.cid}/encyclopedia');
          }),
        ],
      ),
      body: MaxWidth(
        width: 820,
        ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 48), children: [
          RpgCard(
            accent: kc,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                KindAvatar(e.kind, size: 64),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(e.name.toUpperCase(), style: pxText(20, p.text)),
                  const SizedBox(height: 6),
                  Wrap(spacing: 8, runSpacing: 6, children: [
                    KindBadge(e.kind),
                    if (e.status.isNotEmpty) _Tag(e.status, kc),
                    if (e.attr.isNotEmpty) _Tag(e.attr, p.muted),
                    if (e.review == 'suggested') _Tag('não confirmada', p.gold),
                  ]),
                ])),
              ]),
              if (e.aliases.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 12), child: Text('Também conhecido como: ${e.aliases}', style: TextStyle(color: p.muted, fontSize: 21))),
              if (e.giver.isNotEmpty) Text('Quem deu: ${e.giver}', style: const TextStyle(fontSize: 21)),
              if (e.reward.isNotEmpty) Text('Recompensa: ${e.reward}', style: const TextStyle(fontSize: 21)),
              if (e.description.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 12), child: Text(e.description, style: const TextStyle(fontSize: 22, height: 1.2))),
              if (e.kind == 'spell') Builder(builder: (_) {
                final uses = mentions.where((m) => m.status == 'confirmed').toList();
                final by = <String, int>{};
                for (final m in uses) {
                  final who = m.detail.replaceFirst('Lançado por ', '');
                  if (who.isNotEmpty) by[who] = (by[who] ?? 0) + 1;
                }
                final byHero = uses.where((m) => m.side == 'hero').length, byEnemy = uses.where((m) => m.side == 'enemy').length;
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('USOS REGISTRADOS: ${uses.length}', style: pxText(14, p.text)),
                    if (byHero + byEnemy > 0) Padding(padding: const EdgeInsets.only(top: 4), child: Text('Dos heróis: $byHero  ·  Dos inimigos: $byEnemy', style: TextStyle(color: p.muted, fontSize: 21))),
                    if (by.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Wrap(spacing: 8, runSpacing: 6, children: [for (final c in by.entries) _Tag('${c.key} ×${c.value}', kc)])),
                  ]),
                );
              }),
            ]),
          ),
          SectionTitle('Ligações · ${rels.length}', trailing: RuneButton('Ligar', icon: PxIcons.plus, compact: true, tone: RuneTone.ghost, onPressed: () => _addRelation(e))),
          if (rels.isEmpty) Text('Ligue esta entrada a outras: onde vive, a quem serve, quem a contratou…', style: TextStyle(color: p.muted, fontSize: 21, height: 1.1)),
          for (final r in rels)
            Builder(builder: (_) {
              final out = r.fromId == e.id;
              final other = allEnts[out ? r.toId : r.fromId];
              if (other == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: RpgCard(
                  accent: p.kind(other.kind),
                  onTap: () => context.go('/campaign/${widget.cid}/entity/${other.id}'),
                  padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
                  child: Row(children: [
                    KindAvatar(other.kind, size: 40),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(out ? '${r.label.isEmpty ? 'ligado a' : r.label} →' : '← ${r.label.isEmpty ? 'ligado a' : r.label}', style: TextStyle(color: p.gold, fontSize: 19)),
                      Text(other.name.toUpperCase(), style: pxText(13, p.text)),
                    ])),
                    IconButton(tooltip: 'Remover ligação', icon: Icon(PxIcons.close, color: p.muted), onPressed: () => ref.read(repoProvider).deleteRelation(r.id)),
                  ]),
                ),
              );
            }),
          const SectionTitle('Histórico por sessão'),
          if (mine.isEmpty) Text('Sem mudanças registradas.', style: TextStyle(color: p.muted, fontSize: 21)),
          for (final h in mine)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(PxIcons.timeline, color: p.gold),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(h.field == 'criada' ? 'Apareceu pela primeira vez' : '${h.field}: ${h.oldValue.isEmpty ? '—' : h.oldValue} → ${h.newValue}', style: const TextStyle(fontSize: 22)),
                  Text(sn(h.sessionId), style: TextStyle(color: p.muted, fontSize: 19)),
                ])),
              ]),
            ),
          SectionTitle(e.kind == 'spell' ? 'Cada uso' : 'Citações'),
          if (mentions.where((m) => m.status == 'confirmed').isEmpty) Text('Sem citações confirmadas.', style: TextStyle(color: p.muted, fontSize: 21)),
          for (final m in mentions.where((m) => m.status == 'confirmed'))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: RpgCard(
                onTap: () => context.go('/campaign/${widget.cid}/session/${m.sessionId}'),
                padding: const EdgeInsets.all(10),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${sn(m.sessionId)}${m.atMs != null ? ' · ${fmtClock(m.atMs!)}' : ''}'.toUpperCase(), style: pxText(12, p.gold)),
                  if (m.detail.isNotEmpty)
                    Text('${m.side == 'enemy' ? '[inimigo] ' : (m.side == 'hero' ? '[herói] ' : '')}${m.detail}${m.target.isEmpty ? '' : ' → ${m.target}'}${m.result.isEmpty ? '' : ' (${m.result})'}', style: TextStyle(color: m.side == 'enemy' ? p.crimson : kc, fontSize: 21)),
                  const SizedBox(height: 4),
                  Text(m.quote.isEmpty ? '(sem trecho)' : '"${m.quote}"', style: const TextStyle(fontSize: 21, height: 1.1)),
                ]),
              ),
            ),
        ]),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color color;
  const _Tag(this.text, this.color);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(border: Border.all(color: color, width: 2)),
        child: Text(text.toUpperCase(), style: pxText(12, color)),
      );
}
