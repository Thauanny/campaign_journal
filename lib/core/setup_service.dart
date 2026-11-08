import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../ai/model_catalog.dart';
import 'settings.dart';

const geminiKeyUrl = 'https://aistudio.google.com/apikey';

bool get isDesktop => Platform.isMacOS || Platform.isWindows || Platform.isLinux;
bool get isMobile => Platform.isAndroid || Platform.isIOS;

/// No macOS, apps com App Sandbox não enxergam nem executam binários do
/// sistema (brew, ollama, whisper-cli, ffmpeg).
bool get isSandboxed =>
    Platform.isMacOS && Platform.environment.containsKey('APP_SANDBOX_CONTAINER_ID');

/// O app consegue procurar e executar ferramentas instaladas no computador?
bool get canRunTools => isDesktop && !isSandboxed;

/// Localiza executáveis. Apps de interface não herdam o PATH do terminal, então
/// procuramos também nas pastas padrão do Homebrew e afins.
class Tools {
  static List<String> get _dirs {
    final home = Platform.environment['HOME'] ?? '';
    final sep = Platform.isWindows ? ';' : ':';
    return [
      '/opt/homebrew/bin',
      '/usr/local/bin',
      '/usr/bin',
      '/Applications/Ollama.app/Contents/Resources',
      if (home.isNotEmpty) '$home/.local/bin',
      ...(Platform.environment['PATH'] ?? '').split(sep).where((e) => e.isNotEmpty),
    ];
  }

  static Map<String, String> get env => {
        ...Platform.environment,
        'PATH': _dirs.join(Platform.isWindows ? ';' : ':'),
      };

  static Future<String?> find(String name, {String? custom}) async {
    if (!canRunTools) return null;
    final exe = Platform.isWindows ? '$name.exe' : name;
    final candidates = [
      if (custom != null && custom.isNotEmpty) custom,
      for (final d in _dirs) p.join(d, exe),
    ];
    for (final c in candidates) {
      try {
        if (File(c).existsSync()) return c;
      } catch (_) {}
    }
    return null;
  }
}

enum ItemStatus { ok, missing, unavailable }

/// Uma "missão de preparação": algo que o app precisa para a IA gratuita local.
class SetupItem {
  final String id;
  final String title;
  final String why;
  final String? size;
  final ItemStatus status;
  final String? detail;

  /// Comando/passo manual quando o app não pode instalar sozinho.
  final String? manual;
  const SetupItem(this.id, this.title, this.why,
      {this.size, required this.status, this.detail, this.manual});
  bool get ok => status == ItemStatus.ok;
  bool get installable => status == ItemStatus.missing;
}

class SetupReport {
  final List<SetupItem> local;
  final bool geminiKey;
  final bool ollamaReady;
  final bool whisperReady;
  const SetupReport(this.local, this.geminiKey, this.ollamaReady, this.whisperReady);

  bool get textReady => ollamaReady || geminiKey;
  bool get audioReady => whisperReady || geminiKey;
  bool get ready => textReady && audioReady;
  List<SetupItem> get pendingLocal => local.where((i) => i.installable).toList();
}

class SetupException implements Exception {
  final String message;
  SetupException(this.message);
  @override
  String toString() => message;
}

typedef Prog = void Function(double? fraction, String line);

class OllamaStatus {
  final bool running;
  final bool hasModel;
  const OllamaStatus(this.running, this.hasModel);
  bool get ready => running && hasModel;
}

class SetupService {
  final Settings settings;
  final Dio dio;
  SetupService(this.settings, this.dio);

  static String _tag(String m) => m.contains(':') ? m : '$m:latest';

  Future<OllamaStatus> ollamaStatus() async {
    try {
      final r = await dio.get('${settings.ollamaUrl}/api/tags',
          options: Options(receiveTimeout: const Duration(seconds: 3), sendTimeout: const Duration(seconds: 3)));
      final names = [for (final m in (r.data['models'] as List? ?? const [])) (m['name'] ?? '').toString()];
      final want = _tag(settings.ollamaModel);
      return OllamaStatus(true, names.any((n) => n == want || n == settings.ollamaModel));
    } catch (_) {
      return const OllamaStatus(false, false);
    }
  }

  Future<Directory> _modelsDir() async {
    final dir = await getApplicationSupportDirectory();
    return Directory(p.join(dir.path, 'models'));
  }

  /// Caminho do modelo de voz ESCOLHIDO, se já estiver baixado ('' se não).
  Future<String> whisperModelPath() async {
    try {
      final f = File(p.join((await _modelsDir()).path, whisperFileName(settings.whisperName)));
      if (f.existsSync()) return f.path;
    } catch (_) {}
    return '';
  }

  /// Nomes de modelos de voz já baixados.
  Future<Set<String>> whisperInstalled() async {
    final out = <String>{};
    try {
      final d = await _modelsDir();
      for (final w in whisperCatalog) {
        if (File(p.join(d.path, whisperFileName(w.id))).existsSync()) out.add(w.id);
      }
    } catch (_) {}
    return out;
  }

  Future<SetupReport> check() async {
    final key = await settings.apiKey('gemini');
    final st = await ollamaStatus();
    final items = <SetupItem>[];

    if (isDesktop) {
      final exec = canRunTools;
      final ollamaBin = exec ? await Tools.find('ollama') : null;
      final ffmpeg = exec ? await Tools.find('ffmpeg') : null;
      final whisperBin = exec ? await Tools.find('whisper-cli', custom: settings.whisperBinary) : null;
      final wModel = await whisperModelPath();

      items.add(SetupItem('ollama_bin', 'Ollama', 'Roda o modelo de IA que escreve resumos e extrai NPCs, locais e missões.',
          size: '~1 GB',
          status: (ollamaBin != null || st.running) ? ItemStatus.ok : (exec ? ItemStatus.missing : ItemStatus.unavailable),
          detail: exec ? null : 'O app está isolado pelo macOS (sandbox) e não consegue instalar programas sozinho.',
          manual: Platform.isMacOS ? 'brew install ollama' : (Platform.isWindows ? 'winget install Ollama.Ollama' : 'curl -fsSL https://ollama.com/install.sh | sh')));
      items.add(SetupItem('ollama_run', 'Ollama ligado', 'O Ollama precisa estar rodando em segundo plano para o app conversar com ele.',
          status: st.running ? ItemStatus.ok : ((ollamaBin != null && exec) ? ItemStatus.missing : ItemStatus.unavailable),
          detail: st.running ? null : 'Não encontrei o Ollama respondendo em ${settings.ollamaUrl}.',
          manual: 'ollama serve'));
      items.add(SetupItem('ollama_model', 'Modelo ${settings.ollamaModel}', 'O "cérebro" que lê a transcrição e escreve a crônica em português.',
          size: '~4,7 GB',
          status: st.hasModel ? ItemStatus.ok : (st.running ? ItemStatus.missing : ItemStatus.unavailable),
          detail: st.running ? null : 'Ligue o Ollama primeiro.',
          manual: 'ollama pull ${settings.ollamaModel}'));
      items.add(SetupItem('ffmpeg', 'ffmpeg', 'Converte o áudio gravado para o formato que o Whisper entende.',
          size: '~80 MB',
          status: ffmpeg != null ? ItemStatus.ok : (exec ? ItemStatus.missing : ItemStatus.unavailable),
          manual: Platform.isMacOS ? 'brew install ffmpeg' : (Platform.isWindows ? 'winget install Gyan.FFmpeg' : 'sudo apt install ffmpeg')));
      items.add(SetupItem('whisper_bin', 'Whisper (whisper.cpp)', 'Transforma sua gravação de voz em texto, no seu computador.',
          size: '~10 MB',
          status: whisperBin != null ? ItemStatus.ok : (exec && Platform.isMacOS ? ItemStatus.missing : ItemStatus.unavailable),
          manual: 'brew install whisper-cpp'));
      final wOpt = whisperCatalog.firstWhere((w) => w.id == settings.whisperName, orElse: () => whisperCatalog[2]);
      items.add(SetupItem('whisper_model', 'Modelo de voz (${wOpt.label})', 'Os "ouvidos" do Whisper, treinados em português.',
          size: wOpt.size,
          status: wModel.isNotEmpty ? ItemStatus.ok : ItemStatus.missing));
      final whisperReady = canRunTools && whisperBin != null && ffmpeg != null && wModel.isNotEmpty;
      return SetupReport(items, key != null, st.ready, whisperReady);
    }
    // Celular: só nuvem grátis, ou Ollama de outro computador na rede.
    return SetupReport(items, key != null, st.ready, false);
  }

  // ───────────── instalação ─────────────

  Future<void> install(String id, Prog prog) async {
    switch (id) {
      case 'ollama_bin':
        return _pkg(prog, brew: 'ollama', winget: 'Ollama.Ollama', manualUrl: 'https://ollama.com/download');
      case 'ffmpeg':
        return _pkg(prog, brew: 'ffmpeg', winget: 'Gyan.FFmpeg', manualUrl: 'https://ffmpeg.org/download.html');
      case 'whisper_bin':
        return _pkg(prog, brew: 'whisper-cpp', manualUrl: 'https://github.com/ggml-org/whisper.cpp');
      case 'ollama_run':
        return _startOllama(prog);
      case 'ollama_model':
        return pullModel(prog);
      case 'whisper_model':
        return _downloadWhisper(prog);
    }
    throw SetupException('Passo desconhecido: $id');
  }

  Future<void> _pkg(Prog prog, {String? brew, String? winget, required String manualUrl}) async {
    if (!canRunTools) throw SetupException('Este app não pode instalar programas sozinho aqui. Use o comando manual.');
    late String exe;
    late List<String> args;
    if (Platform.isMacOS && brew != null) {
      final b = await Tools.find('brew');
      if (b == null) {
        throw SetupException('Homebrew não encontrado. Instale-o em brew.sh (um comando no Terminal) ou baixe direto: $manualUrl');
      }
      exe = b;
      args = ['install', brew];
    } else if (Platform.isWindows && winget != null) {
      exe = 'winget';
      args = ['install', '-e', '--id', winget, '--accept-source-agreements', '--accept-package-agreements'];
    } else {
      throw SetupException('Neste sistema a instalação é manual: $manualUrl');
    }
    prog(null, '\$ $exe ${args.join(' ')}');
    final proc = await Process.start(exe, args, environment: Tools.env);
    void pipe(Stream<List<int>> s) => s.transform(utf8.decoder).transform(const LineSplitter()).listen((l) {
          if (l.trim().isNotEmpty) prog(null, l);
        });
    pipe(proc.stdout);
    pipe(proc.stderr);
    final code = await proc.exitCode;
    if (code != 0) throw SetupException('A instalação falhou (código $code). Veja o registro acima.');
  }

  Future<void> _startOllama(Prog prog) async {
    if ((await ollamaStatus()).running) return;
    final bin = await Tools.find('ollama');
    if (bin == null) throw SetupException('Ollama não está instalado ainda.');
    prog(null, '\$ ollama serve');
    await Process.start(bin, ['serve'], mode: ProcessStartMode.detached, environment: Tools.env);
    for (var i = 0; i < 30; i++) {
      await Future.delayed(const Duration(milliseconds: 700));
      prog(i / 30, 'Aguardando o Ollama acordar…');
      if ((await ollamaStatus()).running) return;
    }
    throw SetupException('O Ollama não respondeu em ${settings.ollamaUrl}.');
  }

  /// Baixa o modelo pela API do Ollama — funciona até num servidor remoto.
  Future<void> pullModel(Prog prog) async {
    final model = settings.ollamaModel;
    try {
      final r = await dio.post<ResponseBody>('${settings.ollamaUrl}/api/pull',
          data: {'name': model, 'stream': true},
          options: Options(responseType: ResponseType.stream, receiveTimeout: Duration.zero));
      await for (final line in r.data!.stream.cast<List<int>>().transform(utf8.decoder).transform(const LineSplitter())) {
        if (line.trim().isEmpty) continue;
        final j = jsonDecode(line) as Map;
        if (j['error'] != null) throw SetupException('Ollama: ${j['error']}');
        final total = (j['total'] as num?)?.toDouble();
        final done = (j['completed'] as num?)?.toDouble();
        prog(total != null && total > 0 && done != null ? done / total : null, '${j['status']}');
      }
    } on DioException catch (e) {
      throw SetupException('Não consegui falar com o Ollama em ${settings.ollamaUrl}: ${e.message}');
    }
  }

  Future<void> _downloadWhisper(Prog prog) async {
    final name = settings.whisperName;
    final models = await _modelsDir()
      ..createSync(recursive: true);
    final dest = p.join(models.path, whisperFileName(name));
    final tmp = '$dest.part';
    prog(0, 'Baixando ${whisperFileName(name)}…');
    try {
      await dio.download(whisperDownloadUrl(name), tmp,
          options: Options(receiveTimeout: Duration.zero),
          onReceiveProgress: (r, t) {
        if (t > 0) prog(r / t, 'Baixando modelo de voz… ${(r / 1048576).round()} / ${(t / 1048576).round()} MB');
      });
    } on DioException catch (e) {
      throw SetupException('Falha no download: ${e.message}');
    }
    await File(tmp).rename(dest);
    await settings.setWhisperModelPath(dest);
    final wb = await Tools.find('whisper-cli');
    if (wb != null) await settings.setWhisperBinary(wb);
  }
}
