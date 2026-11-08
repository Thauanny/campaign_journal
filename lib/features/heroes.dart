import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers.dart';
import '../core/rpg_theme.dart';
import '../core/ui.dart';
import '../data/database.dart';
import '../data/repo_facts.dart';
import '../domain/hero_context.dart';
import '../domain/systems.dart';
import 'dart:convert';
import 'dart:io';
import 'sheet_import.dart';
import '../core/px_icons.dart';
import '../core/hero_icons.dart';

/// Heróis: cartões estilo ficha de personagem (classe, nível e itens).
class HeroesScreen extends ConsumerWidget {
  final String cid;
  const HeroesScreen(this.cid, {super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heroes = ref.watch(heroesProvider(cid));
    return Scaffold(
      appBar: GameBar(
        title: const Text('Heróis'),
        leading: BackButton(onPressed: () => context.go('/campaign/$cid')),
        actions: [
          if ((heroes.value ?? []).any((h) => (h.sheetPath ?? '').isNotEmpty))
            IconButton(tooltip: 'Reanalisar fichas', icon: const Icon(PxIcons.reload), onPressed: () => _reanalyzeAll(context, heroes.value!)),
          RuneButton('Novo', icon: PxIcons.userPlus, compact: true, onPressed: () => context.go('/campaign/$cid/heroes/start'))],
      ),
      body: heroes.when(
        loading: () => const AppLoading(),
        error: (e, _) => Center(child: Text('$e')),
        data: (hs) => hs.isEmpty
            ? EmptyState(PxIcons.users, 'Ninguém na mesa', 'Cadastre os heróis do grupo — ou importe a ficha em PDF ou foto.',
                action: RuneButton('Novo herói', icon: PxIcons.userPlus, onPressed: () => context.go('/campaign/$cid/heroes/start')))
            : MaxWidth(
                width: 900,
                LayoutBuilder(builder: (context, c) {
                  final cols = c.maxWidth >= 880 ? 2 : 1;
                  final w = (c.maxWidth - 32 - 12 * (cols - 1)) / cols;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
                    child: Wrap(spacing: 12, runSpacing: 12, children: [for (final h in hs) SizedBox(width: w, child: _HeroCard(cid, h))]),
                  );
                }),
              ),
      ),
    );
  }
}

extension on HeroesScreen {
  /// Passa por todas as fichas anexadas, uma de cada vez, para conferir o que mudou.
  Future<void> _reanalyzeAll(BuildContext context, List<Heroe> hs) async {
    final withSheet = [for (final h in hs) if ((h.sheetPath ?? '').isNotEmpty && File(h.sheetPath!).existsSync()) h];
    if (withSheet.isEmpty) {
      snack(context, 'Nenhuma ficha anexada encontrada.');
      return;
    }
    if (!await confirmDialog(context, 'Reanalisar fichas?', 'A IA lê de novo ${withSheet.length} ficha(s) anexada(s) e mostra o que mudou para você aceitar.', ok: 'Reanalisar')) return;
    for (final h in withSheet) {
      if (!context.mounted) return;
      final path = h.sheetPath!;
      await Navigator.of(context).push<bool>(MaterialPageRoute(
          builder: (_) => SheetImportScreen(campaignId: cid, heroId: h.id, initialPath: path, initialIsPdf: path.toLowerCase().endsWith('.pdf'))));
    }
  }
}

class _HeroCard extends ConsumerWidget {
  final String cid;
  final Heroe h;
  const _HeroCard(this.cid, this.h);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.rpg;
    final items = ref.watch(heroItemsProvider(h.id)).value ?? [];
    final ex = sheetExtraToMap(h.extra);
    String? pick(List<String> keys) {
      for (final e in ex.entries) {
        if (keys.contains(e.key.toLowerCase()) && e.value.trim().isNotEmpty) return e.value;
      }
      return null;
    }
    final chips = <(IconData, String, String, Color)>[
      (PxIcons.trophy, 'XP', '${h.xp}', p.gold),
      if (pick(['pm', 'pe', 'mana']) != null) (PxIcons.zap, 'PM', pick(['pm', 'pe', 'mana'])!, p.arcane),
      if (pick(['ca', 'defesa']) != null) (PxIcons.shield, 'DEF', pick(['ca', 'defesa'])!, p.kind('faction')),
      if (pick(['san']) != null) (PxIcons.eye, 'SAN', pick(['san'])!, p.kind('npc')),
      (PxIcons.archive, 'ITENS', '${items.length}', p.kind('item')),
    ];
    return RpgCard(
      onTap: () => context.go('/campaign/$cid/hero/${h.id}'),
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(children: [
            Container(width: 56, height: 56, color: p.arcane.withValues(alpha: 0.18), alignment: Alignment.center, child: Icon(PxIcons.user, size: 36, color: p.arcane)),
            Transform.translate(
              offset: const Offset(0, -8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                color: p.gold,
                child: Text('NV ${h.level}', style: pxText(13, onColor(p.gold))),
              ),
            ),
          ]),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(h.name.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: pxText(16, p.text))),
              Icon(PxIcons.edit, size: 22, color: p.gold),
            ]),
            if ([h.race, h.heroClass].any((s) => s.isNotEmpty))
              Text([h.race, h.heroClass].where((s) => s.isNotEmpty).join(' · '), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: p.arcane, fontSize: 21)),
            if (h.player.isNotEmpty)
              Row(children: [
                Icon(PxIcons.gamepad, size: 20, color: p.muted),
                const SizedBox(width: 6),
                Expanded(child: Text(h.player, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: p.muted, fontSize: 19))),
              ]),
          ])),
        ]),
        const SizedBox(height: 8),
        HpBar(h),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final c in chips)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: c.$4.withValues(alpha: 0.16),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(c.$1, size: 20, color: c.$4),
                const SizedBox(width: 6),
                Text('${c.$2} ${c.$3}', style: pxText(13, p.text)),
              ]),
            ),
        ]),
        if (items.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(spacing: 10, runSpacing: 4, children: [
            for (final it in items.take(4))
              Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(itemIcon(it.name), size: 20, color: p.kind('item')),
                const SizedBox(width: 4),
                ConstrainedBox(constraints: const BoxConstraints(maxWidth: 150), child: Text(it.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 19, color: p.muted))),
              ]),
            if (items.length > 4) Text('+${items.length - 4}', style: TextStyle(fontSize: 19, color: p.muted)),
          ]),
        ],
      ]),
    );
  }
}

/// Ficha enxuta: jogador, classe, raça, nível, história, inventário.
class HeroFormScreen extends ConsumerStatefulWidget {
  final String cid;
  final String hid;
  final String? back;
  const HeroFormScreen(this.cid, this.hid, {super.key, this.back});
  @override
  ConsumerState<HeroFormScreen> createState() => _HeroFormState();
}

class _HeroFormState extends ConsumerState<HeroFormScreen> {
  final _c = {for (final k in ['name', 'player', 'cls', 'race', 'story', 'notes']) k: TextEditingController()};
  final _level = TextEditingController(text: '1');
  final _aliases = TextEditingController();
  // Campos vindos da ficha importada (atributos etc.), todos editáveis.
  final Map<String, TextEditingController> _sx = {};
  Set<String> _sxOrig = {};
  final _newKey = TextEditingController();
  final _newVal = TextEditingController();
  final _ex = {for (final k in allExtraKeys) k: TextEditingController()};
  SystemProfile _prof = profileFor('Outro');
  final _hp = TextEditingController();
  final _hpMax = TextEditingController();
  final _xp = TextEditingController(text: '0');
  final _item = TextEditingController();
  String? _id;
  Heroe? _hero;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    ref.read(repoProvider).campaign(widget.cid).then((c) {
      if (c != null && mounted) setState(() => _prof = profileFor(c.system));
    });
    if (widget.hid == 'new') {
      _loaded = true;
    } else {
      _id = widget.hid;
      _load();
    }
  }

  Future<void> _load() async {
    final h = await ref.read(repoProvider).hero(widget.hid);
    if (h == null || !mounted) return;
    setState(() {
      _hero = h;
      _c['name']!.text = h.name;
      _c['player']!.text = h.player;
      _c['cls']!.text = h.heroClass;
      _c['race']!.text = h.race;
      _c['story']!.text = h.story;
      _c['notes']!.text = h.notes;
      _level.text = '${h.level}';
      _hp.text = h.hpCurrent?.toString() ?? '';
      _hpMax.text = h.hpMax?.toString() ?? '';
      _xp.text = '${h.xp}';
      final f = heroFields(h);
      _aliases.text = f['apelidos'] ?? '';
      for (final k in allExtraKeys) {
        _ex[k]!.text = f[k] ?? '';
      }
      for (final c in _sx.values) {
        c.dispose();
      }
      _sx.clear();
      for (final e in f.entries) {
        if (e.key == 'apelidos' || allExtraKeys.contains(e.key)) continue;
        _sx[e.key] = TextEditingController(text: e.value);
      }
      _sxOrig = _sx.keys.toSet();
      _loaded = true;
    });
  }

  /// Mantém o que veio da ficha importada e atualiza apelidos e campos do sistema.
  String _extraJson() {
    final m = <String, String>{...(_hero == null ? <String, String>{} : heroFields(_hero!))};
    void put(String k, String v) {
      final t = v.trim();
      if (t.isEmpty) {
        m.remove(k);
      } else {
        m[k] = t;
      }
    }
    for (final k in _sxOrig) {
      m.remove(k);
    }
    for (final e in _sx.entries) {
      put(e.key, e.value.text);
    }
    put('apelidos', _aliases.text);
    for (final e in _prof.extras) {
      put(e.key, _ex[e.key]!.text);
    }
    return jsonEncode(m);
  }

  HeroesCompanion _companion() => HeroesCompanion(
        id: _id == null ? const Value.absent() : Value(_id!),
        campaignId: Value(widget.cid),
        name: Value(_c['name']!.text.trim()),
        player: Value(_c['player']!.text.trim()),
        heroClass: Value(_c['cls']!.text.trim()),
        race: Value(_c['race']!.text.trim()),
        level: Value(int.tryParse(_level.text) ?? 1),
        story: Value(_c['story']!.text.trim()),
        notes: Value(_c['notes']!.text.trim()),
        sheetPath: Value(_hero?.sheetPath),
        extra: Value(_extraJson()),
        hpCurrent: Value(int.tryParse(_hp.text.trim())),
        hpMax: Value(int.tryParse(_hpMax.text.trim())),
        xp: Value(int.tryParse(_xp.text.trim()) ?? 0),
      );

  Future<bool> _save({bool leave = true}) async {
    if (_c['name']!.text.trim().isEmpty) {
      snack(context, 'Informe o nome do herói.');
      return false;
    }
    _id = await ref.read(repoProvider).saveHero(_companion());
    if (leave && mounted) context.go(widget.back ?? '/campaign/${widget.cid}/heroes');
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final items = _id == null ? <Entity>[] : (ref.watch(heroItemsProvider(_id!)).value ?? []);
    Widget field(String k, String label, {int lines = 1}) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(controller: _c[k], maxLines: lines, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder())));
    return Scaffold(
      appBar: GameBar(
          title: Text(widget.hid == 'new' ? 'Novo herói' : 'Herói'),
          leading: BackButton(onPressed: () => context.go(widget.back ?? '/campaign/${widget.cid}/heroes')),
          actions: [
            if (_id != null)
              IconButton(
                  tooltip: 'Excluir',
                  icon: const Icon(PxIcons.trash),
                  onPressed: () async {
                    if (!await confirmDialog(context, 'Excluir herói?', 'Isso também remove os itens dele.', ok: 'Excluir')) return;
                    await ref.read(repoProvider).deleteHero(_id!);
                    if (context.mounted) context.go(widget.back ?? '/campaign/${widget.cid}/heroes');
                  }),
          ]),
      body: MaxWidth(
        width: 640,
        ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 48), children: [
          // ── essencial: o que a IA precisa para reconhecer o personagem ──
          Text('${_prof.name}: ${_prof.tip}', style: TextStyle(color: context.rpg.muted, fontSize: 20, height: 1.3)),
          const SizedBox(height: 16),
          field('name', 'Nome do personagem'),
          field('player', 'Jogador (quem fala por ele na mesa)'),
          Row(children: [
            Expanded(child: field('cls', _prof.classLabel)),
            const SizedBox(width: 12),
            Expanded(child: field('race', _prof.raceLabel)),
          ]),
          Row(children: [
            SizedBox(width: 150, child: Padding(padding: const EdgeInsets.only(bottom: 12), child: TextField(controller: _level, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: _prof.levelLabel)))),
          ]),
          const SizedBox(height: 4),
          // ── o resto fica recolhido (revelação progressiva) ──
          PxExpandable(
            title: 'Apelidos',
            icon: PxIcons.user,
            hint: _aliases.text.trim().isEmpty ? null : _aliases.text.trim(),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              TextField(controller: _aliases, onChanged: (_) => setState(() {}), decoration: const InputDecoration(labelText: 'Separe por vírgula')),
              const SizedBox(height: 6),
              Text('Como o personagem é chamado na mesa. A IA usa isso para reconhecê-lo.', style: TextStyle(color: context.rpg.muted, fontSize: 19)),
            ]),
          ),
          const SizedBox(height: 12),
          PxExpandable(
            title: 'Vida e experiência',
            icon: PxIcons.heart,
            initiallyOpen: _hp.text.isNotEmpty || _hpMax.text.isNotEmpty,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: TextField(controller: _hp, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: '${_prof.hpLabel} atuais'))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _hpMax, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: '${_prof.hpLabel} máximos'))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _xp, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'XP'))),
              ]),
              const SizedBox(height: 8),
              Text('Dano, cura e XP confirmados na revisão de uma sessão são aplicados aqui.', style: TextStyle(color: context.rpg.muted, fontSize: 19, height: 1.25)),
            ]),
          ),
          if (_prof.extras.isNotEmpty) ...[
            const SizedBox(height: 12),
            PxExpandable(
              title: 'Campos de ${_prof.name}',
              icon: PxIcons.sliders,
              child: Wrap(spacing: 12, runSpacing: 12, children: [
                for (final e in _prof.extras) SizedBox(width: 280, child: TextField(controller: _ex[e.key], decoration: InputDecoration(labelText: e.label, prefixIcon: Icon(statIcon(e.key))))),
              ]),
            ),
          ],
          const SizedBox(height: 12),
          PxExpandable(
            title: 'História e notas',
            icon: PxIcons.scriptText,
            child: Column(children: [
              TextField(controller: _c['story'], maxLines: 4, decoration: const InputDecoration(labelText: 'História')),
              const SizedBox(height: 12),
              TextField(controller: _c['notes'], maxLines: 3, decoration: const InputDecoration(labelText: 'Notas (campos da ficha sem lugar próprio)')),
            ]),
          ),
          const SizedBox(height: 12),
          PxExpandable(
            title: 'Dados da ficha',
            icon: PxIcons.sliders,
            hint: _sx.isEmpty ? null : '${_sx.length} campos',
            initiallyOpen: _sx.isNotEmpty,
            child: _sheetEditor(),
          ),
          const SizedBox(height: 12),
          PxExpandable(
            title: 'Inventário',
            icon: PxIcons.archive,
            hint: items.isEmpty ? null : '${items.length} itens',
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (_id == null) Text('Salve o herói para adicionar itens.', style: TextStyle(color: context.rpg.muted, fontSize: 20)),
              for (final it in items)
                Row(children: [
                  Icon(itemIcon(it.name), size: 26, color: context.rpg.kind('item')),
                  const SizedBox(width: 10),
                  Expanded(child: Text(it.name, style: const TextStyle(fontSize: 22))),
                  IconButton(tooltip: 'Editar', icon: const Icon(PxIcons.edit), onPressed: () => _renameItem(it)),
                  IconButton(icon: const Icon(PxIcons.close), onPressed: () => ref.read(repoProvider).deleteEntity(it.id)),
                ]),
              if (_id != null)
                Row(children: [
                  Expanded(child: TextField(controller: _item, decoration: const InputDecoration(labelText: 'Novo item'), onSubmitted: (_) => _addItem())),
                  IconButton(onPressed: _addItem, icon: const Icon(PxIcons.plus)),
                ]),
            ]),
          ),
          if (_id != null && _hero != null) ...[const SizedBox(height: 12), _HeroHistory(widget.cid, _hero!)],
          // ── ações ──
          const SizedBox(height: 24),
          Wrap(spacing: 12, runSpacing: 12, children: [
            RuneButton('Salvar', icon: PxIcons.save, onPressed: _save),
            // Atualizar: a ficha de papel mudou → nova foto/PDF, mostra o que mudou e aplica.
            if (_id != null)
              RuneButton('Atualizar pela ficha', icon: PxIcons.camera, tone: RuneTone.ghost, onPressed: () => _updateFromSheet(null)),
            if (_id != null && (_hero?.sheetPath ?? '').isNotEmpty && File(_hero!.sheetPath!).existsSync())
              RuneButton('Reanalisar ficha anexada', icon: PxIcons.reload, tone: RuneTone.ghost, onPressed: () => _updateFromSheet(_hero!.sheetPath)),
          ]),
        ]),
      ),
    );
  }

  Future<void> _updateFromSheet(String? path) async {
    if (!await _save(leave: false)) return;
    if (!mounted) return;
    final changed = await Navigator.of(context).push<bool>(MaterialPageRoute(
        builder: (_) => SheetImportScreen(
            campaignId: widget.cid,
            heroId: _id!,
            initialPath: path,
            initialIsPdf: path != null && path.toLowerCase().endsWith('.pdf'))));
    if (changed == true) _load();
  }

  Future<void> _renameItem(Entity it) async {
    final c = TextEditingController(text: it.name);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('EDITAR ITEM'),
        content: TextField(controller: c, autofocus: true, decoration: const InputDecoration(labelText: 'Nome do item')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCELAR')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('SALVAR')),
        ],
      ),
    );
    if (ok == true && c.text.trim().isNotEmpty) await ref.read(repoProvider).renameEntity(it.id, c.text.trim());
  }

  /// Atributos e demais dados da ficha: todos editáveis, com ícone; dá para remover e adicionar.
  Widget _sheetEditor() {
    final p = context.rpg;
    final attrs = _sx.entries.where((e) => isAttribute(e.key)).toList();
    final others = _sx.entries.where((e) => !isAttribute(e.key)).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (_sx.isEmpty) Text('Nenhum dado extra. Importe uma ficha ou adicione campos abaixo.', style: TextStyle(color: p.muted, fontSize: 20)),
      if (attrs.isNotEmpty)
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final e in attrs)
            Container(
              width: 96,
              padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
              color: p.arcane.withValues(alpha: 0.14),
              child: Column(children: [
                Icon(statIcon(e.key), size: 24, color: p.arcane),
                Text(e.key.toUpperCase(), style: pxText(12, p.muted)),
                TextField(controller: e.value, textAlign: TextAlign.center, style: pxText(18, p.text), decoration: const InputDecoration(isDense: true)),
              ]),
            ),
        ]),
      if (attrs.isNotEmpty && others.isNotEmpty) const SizedBox(height: 12),
      for (final e in others)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: [
            Expanded(child: TextField(controller: e.value, decoration: InputDecoration(labelText: e.key, prefixIcon: Icon(statIcon(e.key))))),
            IconButton(tooltip: 'Remover campo', icon: const Icon(PxIcons.close), onPressed: () => setState(() => _sx.remove(e.key)?.dispose())),
          ]),
        ),
      const SizedBox(height: 8),
      Text('Adicionar campo', style: pxText(13, p.muted)),
      const SizedBox(height: 6),
      Row(children: [
        Expanded(flex: 2, child: TextField(controller: _newKey, decoration: const InputDecoration(labelText: 'Nome (ex.: FOR)'))),
        const SizedBox(width: 8),
        Expanded(child: TextField(controller: _newVal, decoration: const InputDecoration(labelText: 'Valor'))),
        IconButton(
          tooltip: 'Adicionar',
          icon: const Icon(PxIcons.plus),
          onPressed: () {
            final k = _newKey.text.trim();
            if (k.isEmpty || _sx.containsKey(k) || k == 'apelidos' || allExtraKeys.contains(k)) return;
            setState(() => _sx[k] = TextEditingController(text: _newVal.text.trim()));
            _newKey.clear();
            _newVal.clear();
          },
        ),
      ]),
    ]);
  }

  Future<void> _addItem() async {
    final n = _item.text.trim();
    if (n.isEmpty || _id == null) return;
    await ref.read(repoProvider).addHeroItem(widget.cid, _id!, n);
    _item.clear();
  }
}

/// Pontos de vida do herói: barra, número e ajuste rápido (−1 / +1).
class HpBar extends ConsumerWidget {
  final Heroe h;
  const HpBar(this.h, {super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.rpg;
    final repo = ref.read(repoProvider);
    if (h.hpMax == null && h.hpCurrent == null) {
      return Row(children: [
        Expanded(child: Text('PV não cadastrados', style: TextStyle(color: p.muted, fontSize: 19))),
        if (h.xp > 0) Text('XP ${h.xp}', style: TextStyle(color: p.muted, fontSize: 19)),
      ]);
    }
    final cur = h.hpCurrent ?? h.hpMax ?? 0;
    final max = h.hpMax ?? cur;
    final ratio = max <= 0 ? 0.0 : (cur / max).clamp(0.0, 1.0);
    final color = ratio > .5 ? p.emerald : (ratio > .25 ? p.gold : p.crimson);
    Widget step(IconData i, int d) => GestureDetector(
          onTap: () => repo.adjustHp(h.id, d),
          child: Container(width: 30, height: 30, color: p.surface2, child: Icon(i, size: 24, color: p.text)),
        );
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text('PV $cur/$max', style: pxText(12, color)),
        const Spacer(),
        Text('XP ${h.xp}', style: TextStyle(color: p.muted, fontSize: 19)),
      ]),
      const SizedBox(height: 4),
      Row(children: [
        step(PxIcons.minus, -1),
        const SizedBox(width: 6),
        Expanded(child: XpBar(ratio, color: color, height: 8)),
        const SizedBox(width: 6),
        step(PxIcons.plus, 1),
      ]),
    ]);
  }
}


/// Últimos fatos que afetaram este herói (dano, cura, XP).
class _HeroHistory extends ConsumerWidget {
  final String cid;
  final Heroe h;
  const _HeroHistory(this.cid, this.h);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.rpg;
    return FutureBuilder<List<Fact>>(
      future: ref.read(repoProvider).factsAbout(cid, h),
      builder: (context, snap) {
        final facts = (snap.data ?? []).take(8).toList();
        if (facts.isEmpty) return const SizedBox.shrink();
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('Histórico'),
          for (final f in facts)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                Icon(f.kind == 'heal' ? PxIcons.heart : (f.kind == 'xp' ? PxIcons.trophy : PxIcons.alert), size: 24, color: f.kind == 'damage' ? p.crimson : p.emerald),
                const SizedBox(width: 10),
                Expanded(child: Text(f.kind == 'damage' ? 'Sofreu ${f.amount ?? '?'} de dano${f.actor.isEmpty ? '' : ' de ${f.actor}'}' : (f.kind == 'heal' ? 'Recuperou ${f.amount ?? '?'} PV' : (f.kind == 'xp' ? 'Ganhou ${f.amount ?? '?'} XP' : f.text_)), style: const TextStyle(fontSize: 21))),
              ]),
            ),
        ]);
      },
    );
  }
}
