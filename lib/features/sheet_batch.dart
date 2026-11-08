import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import '../core/px_icons.dart';
import '../core/rpg_theme.dart';
import '../core/ui.dart';
import '../data/database.dart';
import '../data/repository.dart';
import 'sheet_import.dart';

enum _St { waiting, reading, saved, skipped }

class _Job {
  final String name;
  final String path;
  final bool isPdf;
  _St st = _St.waiting;
  String? heroName;
  _Job(this.name, this.path, this.isPdf);
}

/// Fila de fichas: mostra quantas são, qual está sendo lida, quais já foram
/// salvas e quais foram puladas (com opção de tentar de novo).
class SheetBatchScreen extends ConsumerStatefulWidget {
  final String cid;
  final List<({String name, String path, bool isPdf})> files;
  const SheetBatchScreen(this.cid, this.files, {super.key});
  @override
  ConsumerState<SheetBatchScreen> createState() => _SheetBatchState();
}

class _SheetBatchState extends ConsumerState<SheetBatchScreen> {
  late final List<_Job> _jobs = [for (final f in widget.files) _Job(f.name, f.path, f.isPdf)];
  bool _busy = false;
  bool _stop = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runQueue());
  }

  int get _done => _jobs.where((j) => j.st == _St.saved || j.st == _St.skipped).length;

  /// Percorre as fichas que ainda esperam, uma de cada vez.
  Future<void> _runQueue() async {
    if (_busy) return;
    _busy = true;
    _stop = false;
    for (final j in _jobs.where((j) => j.st == _St.waiting).toList()) {
      if (!mounted || _stop) break;
      await _run(j);
      if (!mounted) return;
      // Dá um respiro para ver o resultado antes da próxima.
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _run(_Job j) async {
    final repo = ref.read(repoProvider);
    setState(() => j.st = _St.reading);
    final id = await repo.saveHero(HeroesCompanion.insert(id: newId(), campaignId: widget.cid, name: 'Novo herói'));
    if (!mounted) return;
    final changed = await Navigator.of(context).push<bool>(MaterialPageRoute(
        builder: (_) => SheetImportScreen(
            campaignId: widget.cid,
            heroId: id,
            initialPath: j.path,
            initialIsPdf: j.isPdf,
            batch: BatchInfo(_jobs.indexOf(j), _jobs.length, j.name, [for (final x in _jobs) x.st.index]))));
    final h = await repo.hero(id);
    if (changed == true) {
      j.heroName = h?.name;
      if (mounted) setState(() => j.st = _St.saved);
    } else {
      // Desistiu ou a leitura falhou: não deixa ficha vazia.
      if (h != null && h.name == 'Novo herói' && h.heroClass.isEmpty && h.race.isEmpty) await repo.deleteHero(id);
      if (mounted) setState(() => j.st = _St.skipped);
    }
  }

  Future<void> _retry(_Job j) async {
    if (_busy) return;
    setState(() {
      j.st = _St.waiting;
      _busy = true;
    });
    await _run(j);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.rpg;
    final total = _jobs.length;
    final saved = _jobs.where((j) => j.st == _St.saved).length;
    final skipped = _jobs.where((j) => j.st == _St.skipped).length;
    final finished = _done == total;
    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: GameBar(title: const Text('Importando fichas'), leading: _busy ? const SizedBox() : const BackButton()),
        body: MaxWidth(
          width: 640,
          ListView(padding: const EdgeInsets.all(16), children: [
            RpgCard(
              accent: finished ? p.emerald : p.gold,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(finished ? 'FILA CONCLUÍDA' : 'FICHA ${(_done + 1).clamp(1, total)} DE $total', style: pxText(15, p.text)),
                const SizedBox(height: 10),
                XpBar(_done / total, color: finished ? p.emerald : p.gold),
                const SizedBox(height: 10),
                Wrap(spacing: 14, runSpacing: 6, children: [
                  _count(PxIcons.checkDouble, '$saved salva(s)', p.emerald),
                  _count(PxIcons.hourglass, '${total - _done} na fila', p.muted),
                  if (skipped > 0) _count(PxIcons.alert, '$skipped pulada(s)', p.crimson),
                ]),
              ]),
            ),
            const SizedBox(height: 16),
            for (var i = 0; i < _jobs.length; i++) _row(p, i, _jobs[i]),
            const SizedBox(height: 16),
            if (_busy && !finished)
              RuneButton('Parar depois desta', tone: RuneTone.ghost, compact: true, onPressed: () => setState(() => _stop = true))
            else if (!_busy && !finished)
              RuneButton('Continuar fila', icon: PxIcons.play, onPressed: _runQueue)
            else if (finished)
              RuneButton('Concluir', icon: PxIcons.check, onPressed: () => Navigator.of(context).pop()),
          ]),
        ),
      ),
    );
  }

  Widget _count(IconData i, String t, Color c) => Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(i, size: 20, color: c),
        const SizedBox(width: 6),
        Text(t, style: TextStyle(fontSize: 21, color: c)),
      ]);

  Widget _row(RpgPalette p, int i, _Job j) {
    final (icon, color, label) = switch (j.st) {
      _St.waiting => (PxIcons.hourglass, p.muted, 'Na fila'),
      _St.reading => (PxIcons.zap, p.gold, 'Lendo e conferindo…'),
      _St.saved => (PxIcons.checkDouble, p.emerald, 'Salva${j.heroName != null ? ' como ${j.heroName}' : ''}'),
      _St.skipped => (PxIcons.alert, p.crimson, 'Pulada — nada foi salvo'),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RpgCard(
        accent: j.st == _St.waiting ? null : color,
        padding: const EdgeInsets.all(10),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            color: color.withValues(alpha: 0.16),
            alignment: Alignment.center,
            child: j.st == _St.reading ? const PxLoader(blocks: 4, size: 6) : Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${i + 1}. ${j.name}', maxLines: 1, overflow: TextOverflow.ellipsis, style: pxText(13, p.text)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 20, color: color)),
          ])),
          Icon(j.isPdf ? PxIcons.fileAlt : PxIcons.image, color: p.muted, size: 22),
          if (j.st == _St.skipped && !_busy)
            IconButton(tooltip: 'Tentar de novo', icon: Icon(PxIcons.reload, color: p.gold), onPressed: () => _retry(j)),
        ]),
      ),
    );
  }
}
