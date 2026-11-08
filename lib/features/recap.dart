import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/px_icons.dart';
import '../core/rpg_theme.dart';
import '../core/ui.dart';
import '../domain/exporter.dart';
import 'export_actions.dart';

/// Recap para os jogadores: texto pronto para colar no Discord/WhatsApp, sem
/// segredos nem notas do mestre.
class RecapScreen extends ConsumerStatefulWidget {
  final String cid;
  const RecapScreen(this.cid, {super.key});
  @override
  ConsumerState<RecapScreen> createState() => _RecapState();
}

class _RecapState extends ConsumerState<RecapScreen> {
  int _last = 3;
  String? _md;
  ExportData? _data;

  @override
  void initState() {
    super.initState();
    loadExportData(ref, widget.cid).then((d) {
      if (mounted) setState(() { _data = d; _md = playerRecapMarkdown(d, last: _last); });
    });
  }

  void _setLast(int n) => setState(() { _last = n; _md = playerRecapMarkdown(_data!, last: n); });

  @override
  Widget build(BuildContext context) {
    final p = context.rpg;
    return Scaffold(
      appBar: GameBar(title: const Text('Recap dos jogadores'), leading: BackButton(onPressed: () => context.go('/campaign/${widget.cid}'))),
      body: MaxWidth(
        width: 820,
        ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 48), children: [
          Text('Um resumo do que o grupo já viveu — sem segredos, ganchos ou notas de preparação.', style: TextStyle(color: p.muted, fontSize: 22, height: 1.1)),
          const SizedBox(height: 14),
          Wrap(children: [
            for (final (n, l) in [(1, 'Última sessão'), (3, 'Últimas 3'), (5, 'Últimas 5'), (0, 'Todas')]) PxChoice(l, _last == n, _data == null ? () {} : () => _setLast(n)),
          ]),
          const SizedBox(height: 10),
          if (_md == null) const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())) else ...[
            RpgCard(child: SelectableText(_md!, style: const TextStyle(fontSize: 21, height: 1.2))),
            const SizedBox(height: 16),
            Wrap(spacing: 12, runSpacing: 12, children: [
              RuneButton('Copiar texto', icon: PxIcons.copy, onPressed: () {
                Clipboard.setData(ClipboardData(text: _md!));
                snack(context, 'Recap copiado.');
              }),
              RuneButton('Para Discord', icon: PxIcons.message, tone: RuneTone.arcane, onPressed: () {
                // Discord: títulos viram negrito e o texto respeita o limite de 2000 caracteres
                final t = _md!.replaceAllMapped(RegExp(r'^#+\s*(.*)$', multiLine: true), (m) => '**${m[1]}**');
                Clipboard.setData(ClipboardData(text: t.length > 1900 ? '${t.substring(0, 1900)}…' : t));
                snack(context, 'Copiado em formato Discord.');
              }),
            ]),
          ],
        ]),
      ),
    );
  }
}
