import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers.dart';
import '../core/px_icons.dart';
import '../core/rpg_theme.dart';
import '../core/ui.dart';
import '../data/database.dart';
import '../data/repo_facts.dart';
import '../domain/pipeline.dart' show fmtClock;

/// Um ponto da linha do tempo (de uma sessão ou da campanha inteira).
class TItem {
  final int? atMs;

  /// event | start | end | session | damage | heal | xp | condition | loot | tipo da entidade
  final String type;
  final String title;
  final String? sub;
  final String? entityId;
  final String? sessionId;
  final bool confirmed;

  /// Feitiços e fatos: hero | enemy | ''.
  final String side;
  const TItem(this.atMs, this.type, this.title, this.sub, this.entityId, this.confirmed, {this.side = '', this.sessionId});
}

const _combat = {'damage', 'heal', 'xp', 'condition', 'loot'};
const _frame = {'start', 'end', 'session'};

/// Monta os pontos de uma sessão. [seen] controla "primeira aparição": NPCs,
/// locais, missões, itens e facções aparecem só na primeira vez; feitiços, cada uso.
List<TItem> timelineItems({
  required List<Event> events,
  required List<Mention> mentions,
  required List<Fact> facts,
  required Map<String, Entity> ents,
  required Set<String> seen,
}) {
  final items = <TItem>[
    for (final e in events) TItem(e.atMs, 'event', e.text_, null, null, e.review == 'confirmed'),
  ];
  final sorted = [...mentions]..sort((a, b) => (a.atMs ?? 1 << 40).compareTo(b.atMs ?? 1 << 40));
  for (final m in sorted) {
    final e = ents[m.entityId];
    if (e == null || e.ownerId != null) continue;
    if (e.kind != 'spell' && !seen.add(e.id)) continue;
    final title = switch (e.kind) {
      'npc' => 'Encontraram ${e.name}',
      'location' => 'Chegaram em ${e.name}',
      'quest' => 'Missão: ${e.name}',
      'item' => 'Obtiveram ${e.name}',
      'faction' => 'Facção: ${e.name}',
      _ => e.name,
    };
    final spellSub = [
      if (m.detail.isNotEmpty) m.detail.replaceFirst('Lançado por ', ''),
      if (m.target.isNotEmpty) '→ ${m.target}',
      if (m.result.isNotEmpty) '(${m.result})',
    ].join(' ');
    final sub = e.kind == 'spell' ? (spellSub.isEmpty ? null : spellSub) : (e.description.isEmpty ? null : e.description);
    items.add(TItem(m.atMs, e.kind, title, sub, e.id, m.status == 'confirmed' || e.review == 'confirmed', side: m.side));
  }
  for (final f in facts) {
    items.add(TItem(f.atMs, f.kind, factTitle(f), null, null, f.status == 'confirmed', side: f.side));
  }
  items.sort((a, b) => (a.atMs ?? 1 << 40).compareTo(b.atMs ?? 1 << 40));
  return items;
}

// ───────────────────────── Linha do tempo (visual) ─────────────────────────

class TimelineList extends StatefulWidget {
  final String cid;
  final List<TItem> items;
  const TimelineList({super.key, required this.cid, required this.items});
  @override
  State<TimelineList> createState() => _TimelineListState();
}

class _TimelineListState extends State<TimelineList> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final p = context.rpg;
    final items = widget.items;
    final types = <String, int>{};
    for (final i in items) {
      if (!_frame.contains(i.type)) types[i.type] = (types[i.type] ?? 0) + 1;
    }
    final combatCount = items.where((i) => _combat.contains(i.type)).length;
    bool keep(TItem i) => _frame.contains(i.type) || _filter == 'all' || (_filter == 'combat' ? _combat.contains(i.type) : i.type == _filter);
    final shown = items.where(keep).toList();

    Color colorOf(String t) => switch (t) {
          'event' => p.gold, 'start' => p.emerald, 'end' => p.arcane, 'session' => p.arcane,
          'damage' => p.crimson, 'heal' => p.emerald, 'xp' => p.gold, 'condition' => p.arcane, 'loot' => p.kind('item'),
          _ => p.kind(t),
        };
    IconData iconOf(String t) => switch (t) {
          'event' => PxIcons.flag, 'start' => PxIcons.play, 'end' => PxIcons.trophy, 'session' => PxIcons.bookOpen,
          'damage' => PxIcons.alert, 'heal' => PxIcons.heart, 'xp' => PxIcons.trophy, 'condition' => PxIcons.infoBox, 'loot' => PxIcons.coin,
          _ => kindIcons[t] ?? PxIcons.zap,
        };
    String labelOf(String t) => t == 'event' ? 'Marcos' : (kindLabels[t] ?? t);

    return MaxWidth(
      width: 760,
      ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 40), children: [
        Wrap(children: [
          PxChoice('Tudo ${items.where((i) => !_frame.contains(i.type)).length}', _filter == 'all', () => setState(() => _filter = 'all')),
          for (final t in ['event', ...kindLabels.keys])
            if ((types[t] ?? 0) > 0) PxChoice('${labelOf(t)} ${types[t]}', _filter == t, () => setState(() => _filter = _filter == t ? 'all' : t), icon: iconOf(t), color: colorOf(t)),
          if (combatCount > 0) PxChoice('Combate $combatCount', _filter == 'combat', () => setState(() => _filter = _filter == 'combat' ? 'all' : 'combat'), icon: PxIcons.alert, color: p.crimson),
        ]),
        const SizedBox(height: 14),
        for (var i = 0; i < shown.length; i++)
          IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              SizedBox(
                width: 56,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, right: 8),
                  child: Text(shown[i].type == 'session' ? '' : (shown[i].atMs == null ? '--:--' : fmtClock(shown[i].atMs!)), textAlign: TextAlign.right, style: pxText(12, p.muted)),
                ),
              ),
              SizedBox(
                width: 44,
                child: Column(children: [
                  Container(width: 4, height: 6, color: i == 0 ? Colors.transparent : p.border),
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: shown[i].type == 'session'
                          ? colorOf('session')
                          : (shown[i].confirmed ? Color.alphaBlend(colorOf(shown[i].type).withValues(alpha: .18), p.surface) : p.surface),
                      border: Border.all(color: shown[i].confirmed ? colorOf(shown[i].type) : p.border, width: 3),
                    ),
                    child: Icon(iconOf(shown[i].type), size: 24, color: shown[i].type == 'session' ? onColor(colorOf('session')) : (shown[i].confirmed ? colorOf(shown[i].type) : p.muted)),
                  ),
                  Expanded(child: Container(width: 4, color: i == shown.length - 1 ? Colors.transparent : p.border)),
                ]),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10, left: 6),
                  child: RpgCard(
                    accent: shown[i].side == 'enemy' ? p.crimson : colorOf(shown[i].type),
                    onTap: shown[i].entityId != null
                        ? () => context.go('/campaign/${widget.cid}/entity/${shown[i].entityId}')
                        : (shown[i].type == 'session' && shown[i].sessionId != null ? () => context.go('/campaign/${widget.cid}/session/${shown[i].sessionId}') : null),
                    fill: shown[i].type == 'session' ? colorOf('session').withValues(alpha: .08) : null,
                    padding: const EdgeInsets.all(8),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(shown[i].type == 'session' ? shown[i].title.toUpperCase() : shown[i].title, style: shown[i].type == 'session' ? pxText(15, p.text) : TextStyle(fontSize: 22, height: 1.25, color: p.text)),
                      if (shown[i].sub != null)
                        Padding(padding: const EdgeInsets.only(top: 3), child: Text(shown[i].sub!, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 19, height: 1.2, color: shown[i].type == 'spell' ? colorOf('spell') : p.muted))),
                      if (shown[i].type == 'spell' && (shown[i].side == 'hero' || shown[i].side == 'enemy'))
                        Padding(padding: const EdgeInsets.only(top: 4), child: Text(shown[i].side == 'hero' ? 'FEITIÇO DOS HERÓIS' : 'FEITIÇO DOS INIMIGOS', style: pxText(11, shown[i].side == 'hero' ? p.arcane : p.crimson))),
                      if (!shown[i].confirmed && !_frame.contains(shown[i].type)) Padding(padding: const EdgeInsets.only(top: 4), child: Text('A REVISAR', style: pxText(11, p.muted))),
                    ]),
                  ),
                ),
              ),
            ]),
          ),
      ]),
    );
  }
}

// ───────────────────────── Aba "Jornada" de UMA sessão ─────────────────────────

class SessionTimelineTab extends ConsumerWidget {
  final String cid;
  final String sid;
  const SessionTimelineTab(this.cid, this.sid, {super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final evs = ref.watch(eventsProvider(sid)).value ?? [];
    final ms = ref.watch(sessionMentionsProvider(sid)).value ?? [];
    final facts = ref.watch(factsProvider(sid)).value ?? [];
    final ents = {for (final e in ref.watch(allEntitiesProvider(cid)).value ?? <Entity>[]) e.id: e};
    final session = ref.watch(sessionProvider(sid)).value;
    final segs = ref.watch(segmentsProvider(sid)).value ?? [];

    final items = timelineItems(events: evs, mentions: ms, facts: facts, ents: ents, seen: <String>{});
    if (items.isEmpty) {
      return const EmptyState(PxIcons.timeline, 'Jornada em branco', 'Marcos, personagens, locais e feitiços aparecem aqui, na ordem em que aconteceram, depois do processamento.');
    }
    var endMs = (session?.durationSec ?? 0) * 1000;
    for (final sg in segs) {
      if (sg.endMs > endMs) endMs = sg.endMs;
    }
    for (final i in items) {
      if ((i.atMs ?? 0) > endMs) endMs = i.atMs!;
    }
    final total = endMs <= 0 ? null : '${(endMs / 60000).round().clamp(1, 100000)} min no total';
    return TimelineList(cid: cid, items: [
      const TItem(0, 'start', 'Início da sessão', null, null, true),
      ...items,
      TItem(endMs, 'end', 'Fim da sessão', total, null, true),
    ]);
  }
}

// ───────────────────────── Jornada da CAMPANHA inteira ─────────────────────────

/// Todas as sessões em ordem, cada uma como um marco com seus pontos dentro.
/// NPCs, locais, missões e itens aparecem só na primeira vez em que surgem na campanha.
final journeyProvider = FutureProvider.autoDispose.family<List<TItem>, String>((ref, cid) async {
  ref.watch(sessionsProvider(cid));
  ref.watch(allEntitiesProvider(cid));
  final repo = ref.read(repoProvider);
  final db = repo.db;
  final sessions = await repo.sessionsOf(cid); // já em ordem crescente
  final ents = {for (final e in await repo.entitiesOf(cid)) e.id: e};
  final seen = <String>{};
  final out = <TItem>[];
  for (final s in sessions) {
    final d = s.date;
    final date = '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    out.add(TItem(null, 'session', 'Sessão ${s.number}', [date, if (s.shortSummary.isNotEmpty) s.shortSummary].join(' · '), null, true, sessionId: s.id));
    out.addAll(timelineItems(
      events: await (db.select(db.events)..where((e) => e.sessionId.equals(s.id))).get(),
      mentions: await (db.select(db.mentions)..where((m) => m.sessionId.equals(s.id))).get(),
      facts: await (db.select(db.facts)..where((f) => f.sessionId.equals(s.id))).get(),
      ents: ents,
      seen: seen,
    ));
  }
  return out;
});

class JourneyScreen extends ConsumerWidget {
  final String cid;
  const JourneyScreen(this.cid, {super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(journeyProvider(cid));
    return Scaffold(
      appBar: GameBar(title: const Text('Jornada da campanha'), leading: BackButton(onPressed: () => context.go('/campaign/$cid'))),
      body: items.when(
        loading: () => const AppLoading(),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) => list.isEmpty
            ? EmptyState(PxIcons.timeline, 'A jornada ainda não começou', 'Cada sessão processada entra aqui, em ordem, com os marcos, personagens, locais, feitiços e combates.',
                action: RuneButton('Nova sessão', icon: PxIcons.plus, onPressed: () => context.go('/campaign/$cid/new')))
            : TimelineList(cid: cid, items: list),
      ),
    );
  }
}
