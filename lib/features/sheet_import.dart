import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';

import '../ai/activity.dart';
import '../ai/capabilities.dart';
import '../ai/gemini_models.dart';
import '../ai/model_catalog.dart';
import '../ai/interfaces.dart';
import '../ai/vision.dart';
import '../core/engines.dart';
import '../core/providers.dart';
import '../core/rpg_theme.dart';
import '../core/ui.dart';
import '../data/database.dart';
import '../domain/models.dart';
import '../domain/sheet_parser.dart';
import '../core/px_icons.dart';

export '../domain/sheet_parser.dart' show sheetExtraToMap;

bool get _isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

class _Source {
  final String path;
  final bool isPdf;
  _Source(this.path, this.isPdf);
}

/// Importar ficha (OCR): PDF digital → camada de texto; escaneado/foto → OCR local
/// (ML Kit no celular, Tesseract no desktop se instalado) ou modelo com visão
/// quando há chave. Sempre passa pela conferência lado a lado.
/// Contexto de uma importação em lote: qual ficha é esta e como estão as outras.
/// [states]: 0 na fila, 1 lendo, 2 salva, 3 pulada.
class BatchInfo {
  final int index;
  final int total;
  final String name;
  final List<int> states;
  const BatchInfo(this.index, this.total, this.name, this.states);
}

class _BatchBanner extends StatelessWidget {
  final BatchInfo b;
  const _BatchBanner(this.b);
  @override
  Widget build(BuildContext context) {
    final p = context.rpg;
    Color c(int s) => switch (s) { 1 => p.gold, 2 => p.emerald, 3 => p.crimson, _ => p.border };
    return RpgCard(
      accent: p.gold,
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(PxIcons.copy, color: p.gold, size: 24),
          const SizedBox(width: 10),
          Text('FICHA ${b.index + 1} DE ${b.total}', style: pxText(15, p.text)),
          const Spacer(),
          Text('${b.states.where((s) => s == 2).length} salva(s)', style: TextStyle(fontSize: 20, color: p.emerald)),
        ]),
        const SizedBox(height: 4),
        Text(b.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 20, color: p.muted)),
        const SizedBox(height: 10),
        Row(children: [
          for (var i = 0; i < b.states.length; i++)
            Expanded(
              child: Container(
                height: 12,
                margin: EdgeInsets.only(right: i == b.states.length - 1 ? 0 : 4),
                decoration: BoxDecoration(color: c(b.states[i]), border: Border.all(color: p.bgDeep, width: 2)),
              ),
            ),
        ]),
        const SizedBox(height: 6),
        Text('Depois de salvar esta, a próxima abre sozinha.', style: TextStyle(fontSize: 18, color: p.muted)),
      ]),
    );
  }
}

class SheetImportScreen extends ConsumerStatefulWidget {
  final String campaignId;
  final String heroId;

  /// Arquivo já escolhido (usado ao importar várias fichas em sequência).
  final String? initialPath;
  final bool initialIsPdf;
  final BatchInfo? batch;
  const SheetImportScreen({super.key, required this.campaignId, required this.heroId, this.initialPath, this.initialIsPdf = false, this.batch});
  @override
  ConsumerState<SheetImportScreen> createState() => _SheetImportState();
}

class _SheetImportState extends ConsumerState<SheetImportScreen> {
  _Source? _src;
  Uint8List? _preview;
  SheetFields? _f;
  bool _busy = false;
  String _status = '';
  String _method = '';
  Heroe? _hero;
  String _system = 'D&D 5e';
  List<FieldDiff> _diff = [];
  final Set<String> _accepted = {};
  final _ctl = <String, TextEditingController>{};

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _hero = await ref.read(repoProvider).hero(widget.heroId);
    _system = (await ref.read(repoProvider).campaign(widget.campaignId))?.system ?? 'D&D 5e';
    if (mounted) setState(() {});
    if (widget.initialPath != null && mounted) await _start(widget.initialPath!, widget.initialIsPdf);
  }

  /// Lê a ficha de um arquivo já escolhido.
  Future<void> _start(String path, bool pdf) async {
    setState(() { _src = _Source(path, pdf); _busy = true; _status = 'Lendo ficha…'; _f = null; });
    try {
      await _read();
    } catch (e) {
      if (mounted) snack(context, '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  TextEditingController _c(String k, String v) => _ctl.putIfAbsent(k, () => TextEditingController(text: v));

  Future<void> _pick(String kind) async {
    String? path;
    var pdf = false;
    if (kind == 'pdf') {
      final r = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
      path = r.isEmpty ? null : r.first.path;
      pdf = true;
    } else if (kind == 'gallery') {
      final r = await FilePicker.pickFiles(type: FileType.image);
      path = r.isEmpty ? null : r.first.path;
    } else {
      // Câmera. (Recorte/perspectiva automáticos: ver README — scanner de documento não incluído.)
      final x = await ImagePicker().pickImage(source: ImageSource.camera);
      path = x?.path;
    }
    if (path == null) return;
    await _start(path, pdf);
  }

  Future<List<Uint8List>> _renderPdfPages(String path) async {
    final doc = await PdfDocument.openFile(path);
    final out = <Uint8List>[];
    for (final pg in doc.pages.take(4)) {
      final img = await pg.render(fullWidth: pg.width * 2, fullHeight: pg.height * 2);
      if (img == null) continue;
      final ui.Image im = await img.createImage();
      final bd = await im.toByteData(format: ui.ImageByteFormat.png);
      img.dispose();
      if (bd != null) out.add(bd.buffer.asUint8List());
    }
    await doc.dispose();
    return out;
  }

  Future<String> _pdfText(String path) async {
    final doc = await PdfDocument.openFile(path);
    final b = StringBuffer();
    for (final pg in doc.pages) {
      final t = await pg.loadText();
      if (t != null) b.writeln(t.fullText);
    }
    await doc.dispose();
    return b.toString();
  }

  Future<String?> _ocrImage(String path) async {
    if (_isMobile) {
      final rec = TextRecognizer(script: TextRecognitionScript.latin);
      try {
        final r = await rec.processImage(InputImage.fromFilePath(path));
        return r.text;
      } finally {
        await rec.close();
      }
    }
    // Desktop: Tesseract (se instalado) com dados em português.
    try {
      final r = await Process.run('tesseract', [path, 'stdout', '-l', 'por']);
      if (r.exitCode == 0) return r.stdout.toString();
    } catch (_) {}
    return null;
  }

  /// IA com visão a usar: a escolhida em Configurações (se enxergar imagens) ou a
  /// primeira com chave entre Gemini, OpenAI e Claude. (Groq e a IA local não
  /// leem imagens aqui.)

  /// IAs que podem ler a imagem, na ordem: a escolhida primeiro, depois as outras com chave.
  Future<List<(String, String, String)>> _visionCandidates() async {
    final settings = ref.read(settingsProvider);
    final dio = ref.read(dioProvider);
    final eng = settings.engine;
    final order = <String>[if (eng != null && const {'gemini', 'groq', 'openai', 'claude'}.contains(eng)) eng, 'gemini', 'groq', 'openai', 'claude'];
    final out = <(String, String, String)>[];
    for (final pv in order.toSet()) {
      final k = await settings.apiKey(pv);
      if (k == null) continue;
      final caps = capsFromJson(settings.capsJson(pv));
      final cv = caps['vision'];
      if (cv != null && !cv.ok) {
        _skipped.add('${engineById(pv)?.name ?? pv}: ${cv.note}');
        continue; // a verificação da conta já mostrou que não lê imagens
      }
      final String? model;
      if (cv != null && cv.ok && cv.model != null) {
        model = cv.model;
      } else if (pv == 'gemini') {
        model = await resolveGeminiModel(dio, k, override: settings.modelFor('gemini'));
      } else if (pv == 'groq') {
        // O Groq só lê imagens se a conta tiver um modelo com visão na lista.
        model = await groqVisionModel(dio, k);
        if (model == null) _skipped.add('Groq: a sua conta não tem modelo que leia imagens');
      } else {
        model = (await settings.pricing()).defaultModel(ProcessingMode.balanced, pv);
      }
      if (model != null) out.add((pv, k, model));
    }
    return out;
  }

  final List<String> _skipped = [];

  /// Campos que são só os RÓTULOS do formulário ("PERSONAGEM", "CLASSE & NÍVEL"):
  /// em PDFs de formulário o que foi digitado não está na camada de texto.
  bool _labelSoup(SheetFields f) {
    const labels = ['PERSONAGEM', 'JOGADOR', 'ORIGEM', 'CLASSE', 'NÍVEL', 'NIVEL', 'DIVINDADE', 'RAÇA', 'RACA', 'MÁXIMOS', 'ATUAIS', 'ATAQUES'];
    int bad(String v) {
      final t = v.trim();
      if (t.isEmpty) return 0;
      final up = t.toUpperCase();
      final hits = labels.where(up.contains).length;
      return (t == up && t.length > 3) || hits >= 2 || (hits == 1 && t == up) ? 1 : 0;
    }
    final flagged = bad(f.name) + bad(f.player) + bad(f.race) + bad(f.heroClass);
    final noisyNotes = labels.where((l) => f.notes.toUpperCase().contains(l)).length >= 3;
    return flagged >= 1 || noisyNotes;
  }

  Future<void> _read() async {
    final src = _src!;

    // 1) As páginas como imagem (PDF renderizado ou a própria foto).
    List<Uint8List> pages = [];
    var pdfText = '';
    if (src.isPdf) {
      pages = await _renderPdfPages(src.path);
      if (pages.isNotEmpty) _preview = pages.first;
      pdfText = await _pdfText(src.path);
    } else {
      pages = [await File(src.path).readAsBytes()];
      _preview = pages.first;
    }

    // 2) IA com visão: lê a ficha como uma pessoa leria (melhor com fichas de formulário).
    //    Tenta a IA escolhida e, se falhar (limite, modelo indisponível), as outras com chave.
    SheetFields? result;
    final failures = <String>[];
    if (pages.isNotEmpty) {
      _skipped.clear();
      final dio = ref.read(dioProvider);
      for (final (provider, key, model) in await _visionCandidates()) {
        if (!mounted) return;
        setState(() => _status = 'Lendo a ficha com a IA ($provider)…');
        try {
          result = await readSheetWithVision(dio: dio, provider: provider, apiKey: key, model: model, pagesPng: pages, system: _system);
          _method = 'IA com visão ($provider · $model) — confira os campos antes de salvar';
          if (!result.isEmpty) break;
        } catch (e) {
          failures.add('$provider: ${e.toString().replaceFirst('Exception: ', '')}');
          if (mounted) snack(context, 'A IA ($provider) não conseguiu ler a ficha; tentando a próxima…');
        }
      }
      failures.addAll(_skipped);
    }

    // 3) Reserva: regras sobre o texto do PDF digital (podem errar em fichas de formulário).
    if ((result == null || result.isEmpty) && pdfText.trim().length > 80) {
      final byRules = parseSheetText(pdfText, _system);
      if (_labelSoup(byRules)) {
        // Só rótulos do formulário: melhor deixar vazio do que preencher com lixo.
        Activity.log('O texto do PDF só tem os rótulos do formulário; ignorado.');
      } else {
        result = byRules;
        _method = 'Regras sobre o texto do PDF (pode errar em fichas de formulário: confira tudo)';
      }
    }

    // 4) Reserva: OCR local (celular: ML Kit; desktop: Tesseract, se instalado).
    if (result == null || result.isEmpty) {
      String? text;
      if (src.isPdf) {
        final tmp = await getTemporaryDirectory();
        final sb = StringBuffer();
        for (var i = 0; i < pages.length; i++) {
          final f = File(p.join(tmp.path, 'ficha_$i.png'))..writeAsBytesSync(pages[i]);
          sb.writeln(await _ocrImage(f.path) ?? '');
        }
        text = sb.toString();
      } else {
        text = await _ocrImage(src.path);
      }
      if (text == null || text.trim().isEmpty) {
        throw ProviderException(_isMobile
            ? 'OCR não encontrou texto. Tente uma foto mais nítida/iluminada.'
            : 'Não consegui ler esta ficha. ${src.isPdf ? 'É um PDF de formulário preenchido: o que foi digitado não fica no texto do PDF, então só uma IA com visão consegue ler. ' : ''}'
                '${failures.isEmpty ? 'Nenhuma IA com visão está configurada (Gemini, Groq com modelo de visão, OpenAI ou Claude).' : 'Tentativas: ${failures.join(' · ')}'} '
                'Você pode preencher a ficha à mão ou tentar de novo mais tarde.');
      }
      result = parseSheetText(text, _system);
      _method = _isMobile ? 'OCR no aparelho (ML Kit)' : 'OCR local (Tesseract)';
    }
    _setResult(result);
  }

  void _setResult(SheetFields f) {
    _ctl.clear();
    final h = _hero;
    final hasData = h != null && (h.heroClass.isNotEmpty || h.race.isNotEmpty || h.extra != '{}');
    setState(() {
      _f = f;
      _diff = hasData
          ? diffSheet(
              name: h.name, player: h.player, heroClass: h.heroClass, race: h.race,
              level: h.level, story: h.story, extra: sheetExtraToMap(h.extra),
              items: const [], incoming: f)
          : [];
      _accepted..clear()..addAll(_diff.map((d) => d.field));
    });
  }

  Future<void> _save() async {
    final f = _f!;
    final repo = ref.read(repoProvider);
    final h = _hero!;
    final isReimport = _diff.isNotEmpty || (h.heroClass.isNotEmpty || h.race.isNotEmpty);
    // Cópia do arquivo original anexada ao herói.
    String? attached = h.sheetPath;
    if (_src != null) {
      final dir = await getApplicationDocumentsDirectory();
      final dest = Directory(p.join(dir.path, 'fichas', h.id))..createSync(recursive: true);
      final file = File(p.join(dest.path, '${DateTime.now().millisecondsSinceEpoch}${p.extension(_src!.path)}'));
      await File(_src!.path).copy(file.path);
      attached = file.path;
    }
    String pick(String field, String current, String edited) {
      if (!isReimport) return edited;
      return _accepted.contains(field) ? edited : current;
    }

    final extra = sheetExtraToMap(h.extra);
    if (!isReimport) {
      extra
        ..clear()
        ..addAll({for (final e in f.extra.entries) e.key: _c('x:${e.key}', e.value).text});
    } else {
      for (final e in f.extra.entries) {
        if (_accepted.contains('extra:${e.key}')) extra[e.key] = e.value;
      }
    }
    final lvl = int.tryParse(_c('level', '${f.level ?? ''}').text);
    // PV e XP conferidos saem de "extra" e vão para os campos próprios do herói.
    int? takeInt(String k) => int.tryParse((extra.remove(k) ?? '').trim());
    final hpMax = takeInt(kHpMaxKey), hpNow = takeInt(kHpNowKey), xpRead = takeInt(kXpKey);
    await repo.saveHero(HeroesCompanion(
      hpMax: hpMax == null ? const Value.absent() : Value(hpMax),
      hpCurrent: (hpNow ?? hpMax) == null ? const Value.absent() : Value(hpNow ?? hpMax),
      xp: xpRead == null ? const Value.absent() : Value(xpRead),
      id: Value(h.id), campaignId: Value(h.campaignId),
      name: Value(pick('name', h.name, _c('name', f.name).text).trim().isEmpty ? h.name : pick('name', h.name, _c('name', f.name).text)),
      player: Value(pick('player', h.player, _c('player', f.player).text)),
      heroClass: Value(pick('class', h.heroClass, _c('class', f.heroClass).text)),
      race: Value(pick('race', h.race, _c('race', f.race).text)),
      level: Value(isReimport ? (_accepted.contains('level') ? (lvl ?? h.level) : h.level) : (lvl ?? h.level)),
      story: Value(pick('story', h.story, _c('story', f.story).text)),
      // campos sem lugar no modelo vão para "notas"
      notes: Value([h.notes, if (_c('notes', f.notes).text.trim().isNotEmpty) _c('notes', f.notes).text.trim()].where((s) => s.isNotEmpty).join('\n\n')),
      sheetPath: Value(attached),
      extra: Value(jsonEncode(extra)),
    ));
    final existing = (await repo.db.select(repo.db.entities).get()).where((e) => e.kind == 'item' && e.ownerId == h.id).map((e) => e.name.toLowerCase()).toSet();
    for (final it in f.items) {
      final ok = !isReimport || _accepted.contains('item:$it');
      if (ok && !existing.contains(it.toLowerCase())) await repo.addHeroItem(h.campaignId, h.id, it);
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final f = _f;
    return Scaffold(
      appBar: GameBar(title: const Text('Importar ficha'), leading: BackButton(onPressed: () => Navigator.maybePop(context))),
      body: _hero == null
          ? const AppLoading()
          : MaxWidth(width: 1100, Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (widget.batch != null) ...[_BatchBanner(widget.batch!), const SizedBox(height: 12)],
                _top(context, f),
                if (f != null) ...[
                  const SizedBox(height: 8),
                  Text('Método: $_method — confira os campos antes de salvar.', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Expanded(child: LayoutBuilder(builder: (context, c) {
                    final img = _preview == null ? const Center(child: Text('Sem pré-visualização')) : InteractiveViewer(child: Image.memory(_preview!));
                    final form = _form(f);
                    return c.maxWidth > 700
                        ? Row(children: [Expanded(child: img), const VerticalDivider(), Expanded(child: form)])
                        : Column(children: [SizedBox(height: 220, child: img), const Divider(), Expanded(child: form)]);
                  })),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: FilledButton(onPressed: _save, child: Text(widget.batch == null ? 'Confirmar e salvar no herói' : 'Salvar e ir para a próxima'))),
                    if (widget.batch != null) ...[
                      const SizedBox(width: 10),
                      OutlinedButton(onPressed: () => Navigator.pop(context, false), child: const Text('Pular')),
                    ],
                  ]),
                ],
              ]),
            )),
    );
  }

  Widget _top(BuildContext context, SheetFields? f) {
    final pal = context.rpg;
    final supported = supportedSheetSystems.contains(_system);
    if (_src == null && !_busy) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('De onde vem a ficha?', style: pxText(15, pal.text)),
        const SizedBox(height: 10),
        MenuTile(PxIcons.file, 'PDF', 'Ficha digital ou escaneada', () => _pick('pdf'), color: pal.gold),
        const SizedBox(height: 10),
        MenuTile(PxIcons.imageGallery, 'Imagem da galeria', 'Foto ou captura da ficha', () => _pick('gallery'), color: pal.arcane),
        if (_isMobile) ...[
          const SizedBox(height: 10),
          MenuTile(PxIcons.camera, 'Câmera', 'Fotografe a ficha agora', () => _pick('camera'), color: pal.emerald),
        ],
        const SizedBox(height: 12),
        _systemChip(pal, supported),
      ]);
    }
    final name = _src == null ? '' : p.basename(_src!.path);
    final reading = _busy;
    Widget step(IconData icon, String label, int state) {
      // 0 = aguardando, 1 = em andamento, 2 = feito
      final c = state == 2 ? pal.emerald : state == 1 ? pal.gold : pal.muted;
      return Expanded(
        child: Column(children: [
          Container(
            width: 44,
            height: 44,
            color: c.withValues(alpha: 0.16),
            alignment: Alignment.center,
            child: state == 1 ? const PxLoader(blocks: 4, size: 6) : Icon(state == 2 ? PxIcons.check : icon, color: c, size: 26),
          ),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: c)),
        ]),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      RpgCard(
        padding: const EdgeInsets.all(10),
        child: Row(children: [
          Container(width: 48, height: 48, color: pal.surface2, child: Icon(_src?.isPdf == true ? PxIcons.fileAlt : PxIcons.image, color: pal.gold, size: 30)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: pxText(13, pal.text)),
            _systemChip(pal, supported),
          ])),
          if (!reading && widget.batch == null)
            IconButton(tooltip: 'Trocar arquivo', icon: Icon(PxIcons.reload, color: pal.gold), onPressed: () => setState(() { _src = null; _f = null; })),
        ]),
      ),
      if (reading) ...[
        const SizedBox(height: 12),
        RpgCard(
          accent: pal.gold,
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              step(PxIcons.file, 'Abrir arquivo', 2),
              step(PxIcons.zap, 'Ler com a IA', 1),
              step(PxIcons.scale, 'Conferir', 0),
            ]),
            const SizedBox(height: 10),
            Text(_status, style: TextStyle(fontSize: 21, color: pal.muted)),
          ]),
        ),
      ],
    ]);
  }

  Widget _systemChip(RpgPalette pal, bool supported) => Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(PxIcons.dice, size: 18, color: pal.arcane),
          const SizedBox(width: 6),
          Flexible(child: Text('$_system${supported ? '' : ' · sem modelo: o texto vai para "notas"'}', style: TextStyle(fontSize: 19, color: pal.arcane))),
        ]),
      );

  Widget _form(SheetFields f) {
    final reimport = _diff.isNotEmpty;
    if (reimport) {
      return ListView(children: [
        const Text('Reenvio: aceite ou recuse cada mudança.'),
        for (final d in _diff)
          CheckboxListTile(
            dense: true,
            value: _accepted.contains(d.field),
            onChanged: (v) => setState(() => v == true ? _accepted.add(d.field) : _accepted.remove(d.field)),
            title: Text(d.label),
            subtitle: Text('${d.oldValue.isEmpty ? '—' : d.oldValue}  →  ${d.newValue}'),
          ),
      ]);
    }
    Widget t(String k, String label, String v, {int lines = 1}) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TextField(controller: _c(k, v), maxLines: lines, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true)));
    return ListView(children: [
      t('name', 'Nome', f.name),
      t('player', 'Jogador', f.player),
      t('class', 'Classe', f.heroClass),
      t('race', 'Raça', f.race),
      t('level', 'Nível', '${f.level ?? ''}'),
      for (final e in f.extra.entries) t('x:${e.key}', e.key, e.value),
      if (f.items.isNotEmpty) Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text('Itens: ${f.items.join(', ')}')),
      t('story', 'História', f.story, lines: 3),
      t('notes', 'Notas (campos sem lugar no modelo)', f.notes, lines: 4),
    ]);
  }
}
