import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

import '../core/providers.dart';
import '../core/px_icons.dart';
import '../core/rpg_theme.dart';
import '../core/ui.dart';
import '../domain/transcript_import.dart';
import 'ai_screen.dart';
import 'audio_import.dart';

/// Nova sessão: três caminhos diretos — colar texto, importar áudio ou gravar.
/// Colar o texto não passa pela tela de gravação.
class NewSessionScreen extends ConsumerStatefulWidget {
  final String cid;
  const NewSessionScreen(this.cid, {super.key});
  @override
  ConsumerState<NewSessionScreen> createState() => _NewSessionState();
}

class _NewSessionState extends ConsumerState<NewSessionScreen> {
  final _text = TextEditingController();
  bool _busy = false;
  int _clipChars = 0;

  @override
  void initState() {
    super.initState();
    // Se já há um texto grande copiado, oferece usá-lo com um toque.
    Clipboard.getData('text/plain').then((d) {
      final n = d?.text?.length ?? 0;
      if (mounted && n > 200) setState(() => _clipChars = n);
    });
  }

  int get _chunks => parseTranscriptText(_text.text).length;

  Future<void> _pasteClipboard() async {
    final d = await Clipboard.getData('text/plain');
    if (d?.text != null) setState(() { _text.text = d!.text!; _clipChars = 0; });
  }

  Future<void> _pickFile() async {
    final f = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['txt', 'srt', 'vtt', 'md']);
    if (f.isNotEmpty && f.first.path != null) {
      final t = await File(f.first.path!).readAsString();
      setState(() => _text.text = t);
    }
  }

  Future<void> _createFromText() async {
    final segs = parseTranscriptText(_text.text);
    if (segs.isEmpty) return;
    setState(() => _busy = true);
    final repo = ref.read(repoProvider);
    final sid = await repo.createSession(widget.cid);
    await repo.importTranscript(sid, segs, replace: true);
    if (mounted) context.go('/campaign/${widget.cid}/session/$sid/process?go=1');
  }

  Future<void> _importAudio() async {
    setState(() => _busy = true);
    final repo = ref.read(repoProvider);
    final sid = await repo.createSession(widget.cid);
    final n = await importAudioFiles(context, ref, sid);
    if (!mounted) return;
    if (n == 0) {
      await repo.deleteSession(sid); // nada escolhido: não deixa sessão vazia
      setState(() => _busy = false);
      return;
    }
    context.go('/campaign/${widget.cid}/session/$sid/process?go=1');
  }

  Future<void> _record() async {
    setState(() => _busy = true);
    final sid = await ref.read(repoProvider).createSession(widget.cid);
    if (mounted) context.go('/campaign/${widget.cid}/session/$sid/record');
  }

  @override
  Widget build(BuildContext context) {
    final p = context.rpg;
    final engine = ref.watch(engineProvider);
    return Scaffold(
      appBar: GameBar(title: const Text('Nova sessão'), leading: BackButton(onPressed: () => context.go('/campaign/${widget.cid}'))),
      body: MaxWidth(
        width: 760,
        ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 48), children: [
          const AiBanner(back: null),
          Text('COMO VOCÊ QUER REGISTRAR A SESSÃO?', style: pxText(14, p.gold)),
          const SizedBox(height: 14),
          // ── Colar texto (aberto por padrão: é o caminho mais rápido) ──
          RpgCard(
            accent: p.gold,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(PxIcons.clipboard, color: p.gold, size: 36),
                const SizedBox(width: 12),
                Expanded(child: Text('COLAR TEXTO', style: pxText(16, p.text))),
                Text('MAIS RÁPIDO', style: pxText(10, p.emerald)),
              ]),
              const SizedBox(height: 8),
              Text('Já tem a transcrição? Cole aqui. Aceita “[mm:ss] Fulano: fala”, SRT, VTT ou texto corrido.', style: TextStyle(fontSize: 22, color: p.muted, height: 1.05)),
              if (_clipChars > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: RuneButton('Usar texto copiado ($_clipChars letras)', icon: PxIcons.clipboard, tone: RuneTone.arcane, compact: true, onPressed: _pasteClipboard),
                ),
              const SizedBox(height: 10),
              TextField(
                controller: _text,
                minLines: 6,
                maxLines: 12,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(hintText: 'Cole a transcrição aqui…'),
              ),
              const SizedBox(height: 10),
              Wrap(spacing: 10, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: [
                RuneButton('Colar', icon: PxIcons.clipboard, tone: RuneTone.ghost, compact: true, onPressed: _pasteClipboard),
                RuneButton('Abrir arquivo', icon: PxIcons.upload, tone: RuneTone.ghost, compact: true, onPressed: _pickFile),
                Text(_text.text.trim().isEmpty ? '' : '${_chunks} trecho(s)', style: TextStyle(fontSize: 22, color: p.gold)),
              ]),
              const SizedBox(height: 14),
              RuneButton(_busy ? 'Criando…' : (engine == null ? 'Criar sessão' : 'Criar e processar'),
                  icon: PxIcons.zap, onPressed: (_chunks == 0 || _busy) ? null : _createFromText),
            ]),
          ),
          const SizedBox(height: 14),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: _Option(PxIcons.upload, 'Importar áudio', 'Escolha um ou mais arquivos (mp3, m4a, wav…).', _busy ? null : _importAudio)),
            const SizedBox(width: 12),
            Expanded(child: _Option(PxIcons.audioDevice, 'Gravar agora', 'Grave a mesa ao vivo, com marcadores.', _busy ? null : _record)),
          ]),
        ]),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  final IconData icon;
  final String title, sub;
  final VoidCallback? onTap;
  const _Option(this.icon, this.title, this.sub, this.onTap);
  @override
  Widget build(BuildContext context) {
    final p = context.rpg;
    return RpgCard(
      onTap: onTap,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: p.gold, size: 36),
        const SizedBox(height: 10),
        Text(title.toUpperCase(), style: pxText(14, p.text)),
        const SizedBox(height: 6),
        Text(sub, style: TextStyle(fontSize: 21, color: p.muted, height: 1.05)),
      ]),
    );
  }
}
