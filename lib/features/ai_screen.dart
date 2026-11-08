import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ai/capabilities.dart';
import '../ai/model_catalog.dart';
import '../ai/quota.dart';
import '../core/engines.dart';
import '../core/providers.dart';
import '../core/px_icons.dart';
import '../core/rpg_theme.dart';
import '../core/setup_service.dart';
import '../domain/models.dart' show ProcessingMode;
import '../core/ui.dart';

/// Situação das IAs: quais chaves existem e o que há de local.
class AiStatus {
  final Map<String, bool> keys;
  final SetupReport local;
  const AiStatus(this.keys, this.local);

  bool ready(String id) => switch (id) {
        'none' => true,
        'local' => local.ollamaReady,
        _ => keys[id] == true,
      };
}

final aiStatusProvider = FutureProvider.autoDispose<AiStatus>((ref) async {
  final s = ref.watch(settingsProvider);
  final keys = {for (final e in engines) if (e.keyProvider != null) e.id: await s.keyConfigured(e.keyProvider!)};
  final local = await ref.watch(setupServiceProvider).check();
  return AiStatus(keys, local);
});

String _q(String? back) => back == null ? '' : '?back=${Uri.encodeComponent(back)}';

// ───────────────────────── 1) Lista de IAs ─────────────────────────

/// Escolher IA — só a lista. Cada linha leva à tela daquela IA.
class AiScreen extends ConsumerWidget {
  final String? back;
  const AiScreen({super.key, this.back});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.rpg;
    final active = ref.watch(engineProvider);
    final st = ref.watch(aiStatusProvider).value;
    return Scaffold(
      appBar: GameBar(title: const Text('Escolher IA'), leading: BackButton(onPressed: () => context.go(back ?? '/'))),
      body: MaxWidth(
        width: 640,
        ListView(padding: const EdgeInsets.fromLTRB(16, 20, 16, 48), children: [
          Text('Qual IA vai cuidar da campanha?', style: pxText(16, p.text)),
          const SizedBox(height: 6),
          Text('A escolhida ouve o áudio, resume e responde perguntas. Dá para trocar a qualquer momento.', style: TextStyle(color: p.muted, fontSize: 21, height: 1.3)),
          _group(context, 'Grátis', engines.where((e) => e.free && e.id != 'none'), active, st),
          _group(context, 'Pagas', engines.where((e) => !e.free), active, st),
          _group(context, 'Sem IA', engines.where((e) => e.id == 'none'), active, st),
        ]),
      ),
    );
  }

  Widget _group(BuildContext context, String title, Iterable<EngineInfo> list, String? active, AiStatus? st) {
    final p = context.rpg;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(0, 24, 0, 10), child: Text(title.toUpperCase(), style: pxText(13, p.muted))),
      for (final e in list)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: RpgCard(
            accent: active == e.id ? p.emerald : null,
            onTap: () => context.go('/ai/${e.id}${_q(back)}'),
            padding: const EdgeInsets.all(8),
            child: Row(children: [
              Container(width: 48, height: 48, color: p.surface2, child: Icon(e.icon, color: p.gold, size: 36)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(((e.id == 'local' && isMobile) ? 'PC na rede' : e.name).toUpperCase(), style: pxText(15, p.text)),
                const SizedBox(height: 2),
                Text(e.maker, style: TextStyle(color: p.muted, fontSize: 19)),
              ])),
              if (active == e.id)
                _Chip('EM USO', p.emerald)
              else if (QuotaCenter.notice.value?.provider == e.id && !(QuotaCenter.notice.value!.expired(DateTime.now())))
                Text('Limite atingido', style: TextStyle(color: p.crimson, fontSize: 20))
              else if (st?.ready(e.id) == true)
                Text('Pronta', style: TextStyle(color: p.arcane, fontSize: 20)),
              const SizedBox(width: 8),
              Icon(PxIcons.chevronRight, color: p.muted),
            ]),
          ),
        ),
    ]);
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color bg;
  const _Chip(this.text, this.bg);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        color: bg,
        child: Text(text, style: pxText(11, onColor(bg))),
      );
}

// ───────────────────────── 2) Configurar uma IA ─────────────────────────

/// Tela de UMA IA: só o próximo passo. Detalhes e extras ficam escondidos.
class AiDetailScreen extends ConsumerStatefulWidget {
  final String id;
  final String? back;
  const AiDetailScreen(this.id, {super.key, this.back});
  @override
  ConsumerState<AiDetailScreen> createState() => _AiDetailState();
}

class _AiDetailState extends ConsumerState<AiDetailScreen> {
  Future<void> _use(EngineInfo e) async {
    await ref.read(settingsProvider).setEngine(e.id);
    ref.read(engineProvider.notifier).set(e.id);
    if (!mounted) return;
    snack(context, '${e.name} agora é a IA da campanha.');
    context.go(widget.back ?? '/settings');
  }

  void _refresh() => ref.invalidate(aiStatusProvider);

  @override
  Widget build(BuildContext context) {
    final p = context.rpg;
    final e = engineById(widget.id);
    if (e == null) return const Scaffold(body: EmptyState(PxIcons.alert, 'IA não encontrada', ''));
    final st = ref.watch(aiStatusProvider).value;
    final active = ref.watch(engineProvider) == e.id;
    final ready = st?.ready(e.id) == true;
    final name = (e.id == 'local' && isMobile) ? 'PC na rede' : e.name;

    Widget body;
    if (e.needsKey && !ready) {
      body = _KeyForm(e, onSaved: _refresh);
    } else if (e.id == 'local') {
      body = isMobile ? _RemoteOllama(onChanged: _refresh) : _LocalSetup(report: st?.local, onChanged: _refresh);
    } else {
      body = const SizedBox.shrink();
    }

    return Scaffold(
      appBar: GameBar(title: Text(name), leading: BackButton(onPressed: () => context.go('/ai${_q(widget.back)}'))),
      body: MaxWidth(
        width: 640,
        ListView(padding: const EdgeInsets.fromLTRB(16, 20, 16, 48), children: [
          Row(children: [
            Container(width: 56, height: 56, color: p.surface2, child: Icon(e.icon, color: p.gold, size: 40)),
            const SizedBox(width: 14),
            Expanded(child: Text(e.blurb, style: TextStyle(fontSize: 22, color: p.text, height: 1.25))),
          ]),
          const SizedBox(height: 22),
          body,
          if (ready || e.id == 'none') ...[
            if (e.needsKey) _KeyReady(e, onRemoved: _refresh),
            if (e.id == 'none')
              Text('Sem IA, só dá para usar texto colado. O resumo é uma seleção de frases e as descobertas saem pouco confiáveis.', style: TextStyle(fontSize: 21, color: p.muted, height: 1.3)),
            const SizedBox(height: 22),
            Center(
              child: active
                  ? Row(mainAxisSize: MainAxisSize.min, children: [Icon(PxIcons.checkboxOn, color: p.emerald), const SizedBox(width: 8), Text('ESTA É A IA EM USO', style: pxText(14, p.emerald))])
                  : RuneButton('Usar esta IA', icon: PxIcons.check, onPressed: () => _use(e)),
            ),
          ],
          // Detalhes só quando pedidos (revelação progressiva)
          const SizedBox(height: 28),
          PxExpandable(
            title: 'Sobre esta IA',
            icon: PxIcons.infoBox,
            flat: true,
            child: Builder(builder: (context) {
              final caps = capsFromJson(ref.read(settingsProvider).capsJson(e.id));
              // Pontos fortes: os fixos + o que o teste da conta confirmou.
              final pros = <String>[
                ...e.pros,
                for (final k in const ['vision', 'document'])
                  if (caps[k]?.ok == true && !e.pros.any((t) => t.toLowerCase().contains(k == 'vision' ? 'imagem' : 'pdf'))) k == 'vision' ? 'Lê imagens (fichas em foto)' : 'Lê PDF',
              ];
              // Limitações: as fixas + o que o teste da conta mostrou que NÃO funciona.
              final cons = <String>[
                ...e.cons,
                for (final k in capKeys)
                  if (caps[k] != null && !caps[k]!.ok) const {'text': 'Não gera texto nesta conta', 'voice': 'Não transcreve voz nesta conta', 'vision': 'Não lê imagens nesta conta', 'document': 'Não lê PDF nesta conta'}[k]!,
              ];
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _Group('PONTOS FORTES', PxIcons.check, p.emerald, pros),
                if (cons.isNotEmpty) ...[const SizedBox(height: 16), _Group('LIMITAÇÕES', PxIcons.alert, p.crimson, cons)],
              ]);
            }),
          ),
        ]),
      ),
    );
  }
}

/// Bloco de pontos (fortes ou limitações): título pequeno e uma linha com ícone por ponto.
class _Group extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;
  const _Group(this.title, this.icon, this.color, this.items);
  @override
  Widget build(BuildContext context) {
    final p = context.rpg;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: pxText(12, color)),
      const SizedBox(height: 6),
      for (final t in items)
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(padding: const EdgeInsets.only(top: 2), child: Icon(icon, size: 20, color: color)),
            const SizedBox(width: 10),
            Expanded(child: Text(t, style: TextStyle(fontSize: 21, height: 1.2, color: p.text))),
          ]),
        ),
    ]);
  }
}

// ── chave de API: 2 passos curtos ──

class _KeyForm extends ConsumerStatefulWidget {
  final EngineInfo e;
  final VoidCallback onSaved;
  const _KeyForm(this.e, {required this.onSaved});
  @override
  ConsumerState<_KeyForm> createState() => _KeyFormState();
}

class _KeyFormState extends ConsumerState<_KeyForm> {
  final _key = TextEditingController();
  bool _show = false;
  String? _err;

  Future<void> _open() async {
    final url = widget.e.keyUrl!;
    final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication).catchError((_) => false);
    if (!ok && mounted) {
      await Clipboard.setData(ClipboardData(text: url));
      if (mounted) snack(context, 'Link copiado: $url');
    }
  }

  Future<void> _paste() async {
    final d = await Clipboard.getData('text/plain');
    if (d?.text != null) setState(() => _key.text = d!.text!.trim());
  }

  Future<void> _save() async {
    setState(() => _err = null);
    try {
      await ref.read(settingsProvider).setApiKey(widget.e.keyProvider!, _key.text.trim());
      _key.clear();
      widget.onSaved();
    } catch (err) {
      if (mounted) setState(() => _err = err.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.rpg;
    final e = widget.e;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _Num(1, 'Pegue a chave${e.free ? ' (grátis)' : ''}', Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Entre em ${e.keyLabel} e crie uma chave de API.', style: const TextStyle(fontSize: 21, height: 1.25)),
        const SizedBox(height: 10),
        RuneButton('Abrir ${e.keyLabel}', icon: PxIcons.externalLink, compact: true, tone: RuneTone.ghost, onPressed: _open),
      ])),
      const SizedBox(height: 18),
      _Num(2, 'Cole a chave aqui', Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: TextField(
              controller: _key,
              obscureText: !_show,
              autocorrect: false,
              enableSuggestions: false,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(hintText: 'cole a chave', suffixIcon: IconButton(icon: Icon(_show ? PxIcons.eyeClosed : PxIcons.eye), onPressed: () => setState(() => _show = !_show))),
            ),
          ),
          const SizedBox(width: 8),
          RuneButton('Colar', icon: PxIcons.clipboard, compact: true, tone: RuneTone.ghost, onPressed: _paste),
        ]),
        const SizedBox(height: 12),
        RuneButton('Salvar chave', icon: PxIcons.save, onPressed: _key.text.trim().length > 20 ? _save : null),
        if (_err != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(_err!, style: TextStyle(color: p.crimson, fontSize: 21, height: 1.25))),
      ])),
    ]);
  }
}

class _Num extends StatelessWidget {
  final int n;
  final String title;
  final Widget child;
  const _Num(this.n, this.title, this.child);
  @override
  Widget build(BuildContext context) {
    final p = context.rpg;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 32, height: 32, color: p.gold, alignment: Alignment.center, child: Text('$n', style: pxText(14, onColor(p.gold)))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title.toUpperCase(), style: pxText(13, p.text)),
        const SizedBox(height: 8),
        child,
      ])),
    ]);
  }
}

/// Chave já salva: mensagem curta + 3 ações discretas.
class _KeyReady extends ConsumerWidget {
  final EngineInfo e;
  final VoidCallback onRemoved;
  const _KeyReady(this.e, {required this.onRemoved});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.rpg;
    final needsModels = e.id == 'gemini' || e.id == 'groq';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(PxIcons.lock, color: p.emerald),
        const SizedBox(width: 10),
        Expanded(child: Text('Chave salva neste aparelho.', style: TextStyle(fontSize: 22, color: p.text))),
      ]),
      const SizedBox(height: 10),
      Wrap(spacing: 4, runSpacing: 0, children: [
        if (needsModels) TextButton(onPressed: () => context.go('/ai/${e.id}/models'), child: const Text('ESCOLHER MODELO')),
        TextButton(
            onPressed: () async {
              await ref.read(settingsProvider).setApiKey(e.keyProvider!, null);
              await ref.read(settingsProvider).setCapsJson(e.id, null);
              onRemoved();
            },
            child: Text('REMOVER CHAVE', style: pxText(13, p.crimson))),
      ]),
      const SizedBox(height: 14),
      CapsCard(e, onChanged: onRemoved),
    ]);
  }
}

/// Verificação da conta: busca os modelos disponíveis e testa texto, voz, imagem e
/// documento de uma vez. Roda sozinha ao salvar a chave e fica guardada.
class CapsCard extends ConsumerStatefulWidget {
  final EngineInfo e;
  final VoidCallback? onChanged;
  const CapsCard(this.e, {this.onChanged, super.key});
  @override
  ConsumerState<CapsCard> createState() => _CapsCardState();
}

class _CapsCardState extends ConsumerState<CapsCard> {
  Map<String, CapResult> _caps = {};
  bool _running = false;
  String _step = '';

  @override
  void initState() {
    super.initState();
    _caps = capsFromJson(ref.read(settingsProvider).capsJson(widget.e.id));
    if (_caps.isEmpty) WidgetsBinding.instance.addPostFrameCallback((_) => _scan());
  }

  Future<void> _scan() async {
    if (_running) return;
    final s = ref.read(settingsProvider);
    final e = widget.e;
    final key = await s.apiKey(e.keyProvider!);
    if (key == null || !mounted) return;
    setState(() { _running = true; _step = 'Começando…'; });
    String? paid;
    if (e.id == 'claude') {
      try { paid = (await s.pricing()).defaultModel(ProcessingMode.balanced, 'claude'); } catch (_) {}
    }
    final r = await scanCapabilities(
      dio: ref.read(dioProvider), engine: e.id, key: key,
      chosenText: s.modelFor(e.id), chosenVoice: s.modelFor('${e.id}_audio'), paidModel: paid,
      onStep: (t) { if (mounted) setState(() => _step = t); },
    );
    await s.setCapsJson(e.id, capsToJson(r));
    if (mounted) setState(() { _caps = r; _running = false; });
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.rpg;
    return RpgCard(
      accent: _caps.isEmpty ? p.gold : (_caps.values.every((c) => c.ok) ? p.emerald : p.gold),
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(PxIcons.search, color: p.gold, size: 24),
          const SizedBox(width: 8),
          Expanded(child: Text('TESTES DA CONTA', style: pxText(13, p.text))),
          if (_running) const PxLoader(blocks: 4, size: 6) else TextButton(onPressed: _scan, child: Text(_running ? 'TESTANDO…' : 'TESTAR TUDO')),
        ]),
        if (_running) Padding(padding: const EdgeInsets.only(top: 6), child: Text('Testando: $_step…', style: TextStyle(fontSize: 20, color: p.muted))),
        if (!_running && _caps.isEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text('Testa de uma vez texto, voz, imagem e documento (PDF).', style: TextStyle(fontSize: 20, color: p.muted))),
        for (final k in capKeys)
          if (_caps[k] != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(_caps[k]!.ok ? PxIcons.checkDouble : PxIcons.alert, size: 22, color: _caps[k]!.ok ? p.emerald : p.crimson),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${capLabels[k]}${_caps[k]!.model != null ? ' · ${_caps[k]!.model}' : ''}', style: TextStyle(fontSize: 21, color: p.text)),
                  Text(_caps[k]!.note, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 18, color: _caps[k]!.ok ? p.muted : p.crimson, height: 1.2)),
                ])),
              ]),
            ),
      ]),
    );
  }
}

// ── IA local: um botão e uma barra ──

class _LocalSetup extends ConsumerStatefulWidget {
  final SetupReport? report;
  final VoidCallback onChanged;
  const _LocalSetup({required this.report, required this.onChanged});
  @override
  ConsumerState<_LocalSetup> createState() => _LocalSetupState();
}

class _LocalSetupState extends ConsumerState<_LocalSetup> {
  String? _running;
  double? _fraction;
  String _line = '';
  String? _error;

  static const _order = ['ollama_bin', 'ollama_run', 'ollama_model', 'ffmpeg', 'whisper_bin', 'whisper_model'];

  Future<bool> _runOne(SetupItem it) async {
    setState(() { _running = it.id; _fraction = null; _error = null; _line = ''; });
    try {
      await ref.read(setupServiceProvider).install(it.id, (f, l) {
        if (mounted) setState(() { if (f != null) _fraction = f; _line = l; });
      });
      return true;
    } catch (e) {
      if (mounted) setState(() => _error = '${it.title}: $e');
      return false;
    } finally {
      if (mounted) setState(() => _running = null);
      widget.onChanged();
    }
  }

  Future<void> _runAll() async {
    final svc = ref.read(setupServiceProvider);
    for (final id in _order) {
      final rep = await svc.check();
      final it = rep.local.firstWhere((i) => i.id == id);
      if (!it.installable) continue;
      if (!await _runOne(it)) return;
    }
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.rpg;
    final r = widget.report;
    if (r == null) return const Center(child: Padding(padding: EdgeInsets.all(24), child: PxLoader()));
    final missing = r.local.where((i) => !i.ok).toList();
    final busy = _running != null;
    final cmds = [for (final i in missing) if (i.manual != null && i.id != 'whisper_model') i.manual!];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (r.ollamaReady && missing.isEmpty)
        Row(children: [Icon(PxIcons.checkboxOn, color: p.emerald), const SizedBox(width: 10), Text('Tudo instalado.', style: const TextStyle(fontSize: 22))])
      else ...[
        Text(missing.isEmpty ? 'Falta ligar o Ollama.' : 'Faltam ${missing.length} item(ns) para rodar no seu computador.', style: const TextStyle(fontSize: 22, height: 1.25)),
        const SizedBox(height: 14),
        if (canRunTools)
          RuneButton(busy ? 'Preparando…' : 'Preparar tudo', icon: PxIcons.download, onPressed: busy ? null : _runAll)
        else ...[
          Text('O macOS isolou este app e ele não pode instalar programas sozinho. Copie os comandos e rode no Terminal.', style: TextStyle(fontSize: 20, color: p.muted, height: 1.25)),
          const SizedBox(height: 10),
          if (cmds.isNotEmpty)
            RuneButton('Copiar comandos', icon: PxIcons.copy, compact: true, tone: RuneTone.ghost, onPressed: () {
              Clipboard.setData(ClipboardData(text: cmds.join('\n')));
              snack(context, 'Comandos copiados.');
            }),
        ],
      ],
      if (busy) ...[
        const SizedBox(height: 16),
        Text('${r.local.firstWhere((i) => i.id == _running).title}…'.toUpperCase(), style: pxText(12, p.gold)),
        const SizedBox(height: 8),
        XpBar(_fraction ?? .08),
        if (_line.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text(_line, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: p.muted, fontSize: 19))),
      ],
      if (_error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_error!, style: TextStyle(color: p.crimson, fontSize: 21, height: 1.25))),
      const SizedBox(height: 10),
      Wrap(children: [
        TextButton(onPressed: () => context.go('/ai/local/models'), child: const Text('ESCOLHER MODELOS')),
        TextButton(onPressed: widget.onChanged, child: const Text('VERIFICAR DE NOVO')),
      ]),
      PxExpandable(
        title: 'Itens a instalar',
        icon: PxIcons.list,
        flat: true,
        hint: '${r.local.where((i) => i.ok).length}/${r.local.length}',
        child: Column(children: [
        for (final it in r.local)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Icon(it.ok ? PxIcons.checkboxOn : PxIcons.checkbox, color: it.ok ? p.emerald : p.muted),
              const SizedBox(width: 10),
              Expanded(child: Text('${it.title}${it.size != null && !it.ok ? '  (${it.size})' : ''}', style: TextStyle(fontSize: 21, color: it.ok ? p.muted : p.text))),
              if (it.installable) RuneButton('Instalar', compact: true, tone: RuneTone.ghost, onPressed: busy ? null : () => _runOne(it)),
            ]),
          ),
        ]),
      ),
    ]);
  }
}

class _RemoteOllama extends ConsumerStatefulWidget {
  final VoidCallback onChanged;
  const _RemoteOllama({required this.onChanged});
  @override
  ConsumerState<_RemoteOllama> createState() => _RemoteOllamaState();
}

class _RemoteOllamaState extends ConsumerState<_RemoteOllama> {
  late final _url = TextEditingController(text: ref.read(settingsProvider).ollamaUrl);
  OllamaStatus? _st;
  bool _busy = false;
  double? _frac;
  String? _err;

  Future<void> _check() async {
    setState(() { _busy = true; _err = null; });
    await ref.read(settingsProvider).setOllamaUrl(_url.text);
    final st = await ref.read(setupServiceProvider).ollamaStatus();
    if (mounted) setState(() { _st = st; _busy = false; });
    widget.onChanged();
  }

  Future<void> _pull() async {
    setState(() { _busy = true; _err = null; });
    try {
      await ref.read(setupServiceProvider).pullModel((f, l) { if (mounted) setState(() => _frac = f ?? _frac); });
    } catch (e) {
      _err = '$e';
    }
    await _check();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.rpg;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('No computador, inicie o Ollama com OLLAMA_HOST=0.0.0.0 e informe o IP dele (mesmo Wi-Fi).', style: TextStyle(fontSize: 21, color: p.muted, height: 1.25)),
      const SizedBox(height: 12),
      TextField(controller: _url, keyboardType: TextInputType.url, autocorrect: false, decoration: const InputDecoration(hintText: 'http://192.168.0.12:11434')),
      const SizedBox(height: 12),
      RuneButton(_busy ? 'Verificando…' : 'Verificar conexão', icon: PxIcons.server, onPressed: _busy ? null : _check),
      if (_st != null && !_st!.running) Padding(padding: const EdgeInsets.only(top: 10), child: Text('Não consegui conectar. Confira o IP, o Wi-Fi e o OLLAMA_HOST.', style: TextStyle(color: p.crimson, fontSize: 21))),
      if (_st?.running == true && !_st!.hasModel) ...[
        const SizedBox(height: 14),
        if (_busy && _frac != null) XpBar(_frac!),
        RuneButton('Baixar modelo no computador', icon: PxIcons.download, compact: true, tone: RuneTone.ghost, onPressed: _busy ? null : _pull),
      ],
      if (_err != null) Text(_err!, style: TextStyle(color: p.crimson, fontSize: 21)),
    ]);
  }
}

// ───────────────────────── 3) Escolher modelo ─────────────────────────

class AiModelsScreen extends ConsumerStatefulWidget {
  final String id;
  const AiModelsScreen(this.id, {super.key});
  @override
  ConsumerState<AiModelsScreen> createState() => _AiModelsState();
}

class _AiModelsState extends ConsumerState<AiModelsScreen> {
  Future<List<ModelOption>>? _text, _audio;
  Set<String> _ollama = {}, _whisper = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final dio = ref.read(dioProvider);
    final s = ref.read(settingsProvider);
    final e = engineById(widget.id)!;
    Future<List<ModelOption>> go(Future<List<ModelOption>> Function(String key) f) async {
      final key = await s.apiKey(e.keyProvider ?? '');
      return key == null ? [] : f(key);
    }
    if (widget.id == 'gemini') {
      _text = go((k) => listGeminiModels(dio, k));
    } else if (widget.id == 'groq') {
      _text = go((k) => listGroqModels(dio, k, audio: false));
      _audio = go((k) => listGroqModels(dio, k, audio: true));
    } else if (widget.id == 'local') {
      ollamaInstalled(dio, s.ollamaUrl).then((o) => mounted ? setState(() => _ollama = o) : null);
      ref.read(setupServiceProvider).whisperInstalled().then((w) => mounted ? setState(() => _whisper = w) : null);
    }
  }

  Widget _row(BuildContext context, {required String title, required bool selected, required VoidCallback onTap, String? chip, Color? chipColor, String? sub}) {
    final p = context.rpg;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RpgCard(
        accent: selected ? p.gold : null,
        onTap: onTap,
        padding: const EdgeInsets.all(8),
        child: Row(children: [
          Icon(selected ? PxIcons.checkboxOn : PxIcons.checkbox, color: selected ? p.gold : p.muted),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 22, color: p.text)),
            if (sub != null) Text(sub, style: TextStyle(fontSize: 19, color: p.muted)),
          ])),
          if (chip != null) _Chip(chip, chipColor ?? p.emerald),
        ]),
      ),
    );
  }

  /// [defaultFirst]: sem escolha, o padrão é o primeiro da lista (marcado como "Padrão").
  Widget _cloudList(BuildContext context, String title, Future<List<ModelOption>>? fut, String key, {String? autoSub, bool defaultFirst = false}) {
    final p = context.rpg;
    final s = ref.read(settingsProvider);
    final current = s.modelFor(key);
    final none = current == null || current.isEmpty;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(0, 20, 0, 10), child: Text(title.toUpperCase(), style: pxText(13, p.muted))),
      FutureBuilder<List<ModelOption>>(
        future: fut,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) return const Padding(padding: EdgeInsets.all(16), child: PxLoader());
          if (snap.hasError) return Text('Não consegui listar os modelos agora.', style: TextStyle(color: p.crimson, fontSize: 21));
          final list = snap.data ?? const <ModelOption>[];
          return Column(children: [
            if (autoSub != null) _row(context, title: 'Automático', sub: autoSub, selected: none, onTap: () async { await s.setModelFor(key, null); setState(() {}); }),
            for (var i = 0; i < list.length; i++)
              _row(context, title: list[i].id,
                  sub: (defaultFirst && i == 0) ? 'Padrão — primeiro da lista' : null,
                  selected: current == list[i].id || (none && defaultFirst && i == 0),
                  chip: list[i].level == FreeLevel.free ? 'GRÁTIS' : null,
                  onTap: () async { await s.setModelFor(key, list[i].id); setState(() {}); }),
          ]);
        },
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.rpg;
    final s = ref.read(settingsProvider);
    final e = engineById(widget.id)!;
    Widget content;
    if (widget.id == 'local') {
      bool has(String id) => _ollama.contains(id) || _ollama.contains('$id:latest');
      content = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(0, 20, 0, 10), child: Text('TEXTO (OLLAMA)', style: pxText(13, p.muted))),
        for (final m in ollamaCatalog)
          _row(context, title: m.label, sub: '${m.size}${has(m.id) ? ' · instalado' : ''}', selected: s.ollamaModel == m.id,
              onTap: () async { await s.setOllamaModel(m.id); setState(() {}); ref.invalidate(aiStatusProvider); }),
        if (!isMobile) ...[
          Padding(padding: const EdgeInsets.fromLTRB(0, 24, 0, 10), child: Text('VOZ (WHISPER)', style: pxText(13, p.muted))),
          for (final m in whisperCatalog)
            _row(context, title: m.label, sub: '${m.size}${_whisper.contains(m.id) ? ' · instalado' : ''}', selected: s.whisperName == m.id,
                onTap: () async { await s.setWhisperName(m.id); setState(() {}); ref.invalidate(aiStatusProvider); }),
        ],
        const SizedBox(height: 12),
        Text('O modelo escolhido é baixado ao tocar em "Preparar tudo".', style: TextStyle(fontSize: 20, color: p.muted)),
      ]);
    } else if (widget.id == 'gemini') {
      content = _cloudList(context, 'Modelo', _text, 'gemini', autoSub: 'Sempre o Flash atual (recomendado)');
    } else {
      content = Column(children: [
        _cloudList(context, 'Texto', _text, 'groq', defaultFirst: true),
        _cloudList(context, 'Voz', _audio, 'groq_audio', defaultFirst: true),
      ]);
    }
    return Scaffold(
      appBar: GameBar(title: const Text('Escolher modelo'), leading: BackButton(onPressed: () => context.go('/ai/${e.id}'))),
      body: MaxWidth(
        width: 640,
        ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 48), children: [
          if (widget.id != 'local') Padding(padding: const EdgeInsets.only(top: 16), child: Text('GRÁTIS = usa o plano gratuito, com limite diário.', style: TextStyle(color: p.muted, fontSize: 20))),
          content,
          if (widget.id != 'local') ...[const SizedBox(height: 24), CapsCard(e)],
        ]),
      ),
    );
  }
}

// ───────────────────────── Peças usadas por outras telas ─────────────────────────

/// Cartão da IA ativa (Configurações): uma linha e um botão.
class ActiveAiCard extends ConsumerWidget {
  const ActiveAiCard({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.rpg;
    final e = engineById(ref.watch(engineProvider));
    return RpgCard(
      accent: e == null ? p.crimson : p.emerald,
      padding: const EdgeInsets.all(10),
      child: Row(children: [
        Container(width: 48, height: 48, color: p.surface2, child: Icon(e?.icon ?? PxIcons.alert, color: p.gold, size: 36)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('IA DA CAMPANHA', style: pxText(11, p.muted)),
          const SizedBox(height: 2),
          Text((e?.name ?? 'Nenhuma').toUpperCase(), style: pxText(16, p.text)),
        ])),
        RuneButton('Trocar', compact: true, tone: RuneTone.ghost, onPressed: () => context.go('/ai')),
      ]),
    );
  }
}

/// Aviso curto: aparece quando não há IA ativa ou ela precisa de configuração.
class AiBanner extends ConsumerWidget {
  final String? back;
  const AiBanner({super.key, this.back});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(engineProvider);
    final st = ref.watch(aiStatusProvider).value;
    if (active != null && (st == null || st.ready(active))) return const SizedBox.shrink();
    final p = context.rpg;
    final act = engineById(active);
    final msg = act == null ? 'Escolha uma IA para transcrever e resumir.' : '${act.name} precisa de configuração.';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: RpgCard(
        accent: p.gold,
        padding: const EdgeInsets.all(10),
        child: Row(children: [
          Expanded(child: Text(msg, style: const TextStyle(fontSize: 22, height: 1.2))),
          const SizedBox(width: 10),
          RuneButton('Configurar', compact: true, onPressed: () => context.go(back == null ? '/ai' : '/ai?back=${Uri.encodeComponent(back!)}')),
        ]),
      ),
    );
  }
}
