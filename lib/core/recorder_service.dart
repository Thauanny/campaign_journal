import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../data/repository.dart';

enum RecState { idle, recording, paused }

class RecorderState {
  final RecState state;
  final Duration elapsed;
  final double level; // 0..1
  final List<int> bookmarksSec;
  final int blocks;
  final String? error;
  const RecorderState(this.state, this.elapsed, this.level, this.bookmarksSec,
      this.blocks, [this.error]);
  static const idle = RecorderState(RecState.idle, Duration.zero, 0, [], 0);
}

/// Grava em blocos (padrão 5 min) para não perder tudo se algo falhar.
/// Cada bloco fechado é registrado no banco na hora (resiliência a crash).
class RecorderService {
  final Repository repo;
  final AudioRecorder _rec = AudioRecorder();
  final void Function(RecorderState) onChange;
  RecorderService(this.repo, this.onChange);

  Duration blockLength = const Duration(minutes: 5);
  String? _sessionId;
  String? _currentPath;
  DateTime? _blockStart;
  Duration _blockAccum = Duration.zero; // tempo acumulado do bloco (pausas)
  Duration _total = Duration.zero;
  Timer? _ticker;
  StreamSubscription<Amplitude>? _ampSub;
  double _level = 0;
  int _blocks = 0;
  final List<int> _bookmarks = [];
  RecState _state = RecState.idle;

  void _emit([String? error]) => onChange(RecorderState(
      _state, _elapsed, _level, List.unmodifiable(_bookmarks), _blocks, error));

  Duration get _elapsed =>
      _total +
      _blockAccum +
      (_state == RecState.recording && _blockStart != null
          ? DateTime.now().difference(_blockStart!)
          : Duration.zero);

  Future<bool> hasPermission() => _rec.hasPermission();

  /// Espaço livre mínimo recomendado para ~1h de AAC mono (~30 MB): avisa abaixo disso.
  Future<bool> lowStorage() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final r = await Process.run('df', ['-k', dir.path]);
      final lines = r.stdout.toString().trim().split('\n');
      final cols = lines.last.split(RegExp(r'\s+'));
      final freeKb = int.tryParse(cols[3]) ?? 1 << 40;
      return freeKb < 200 * 1024;
    } catch (_) {
      return false; // sem como medir (ex.: Windows): não bloqueia
    }
  }

  Future<void> start(String sessionId) async {
    if (!await _rec.hasPermission()) {
      _emit('Sem permissão de microfone.');
      return;
    }
    _sessionId = sessionId;
    _total = Duration.zero;
    _blockAccum = Duration.zero;
    _blocks = 0;
    _bookmarks.clear();
    await WakelockPlus.enable(); // segue gravando com a tela ligada/apagada
    await _startBlock();
    _state = RecState.recording;
    _ticker = Timer.periodic(const Duration(milliseconds: 500), (_) => _tick());
    _ampSub = _rec.onAmplitudeChanged(const Duration(milliseconds: 200)).listen((a) {
      // dBFS (-60..0) -> 0..1
      _level = ((a.current + 60) / 60).clamp(0.0, 1.0);
    });
    _emit();
  }

  Future<void> _startBlock() async {
    final dir = await getApplicationDocumentsDirectory();
    final audioDir = Directory(p.join(dir.path, 'audio', _sessionId!));
    await audioDir.create(recursive: true);
    _currentPath = p.join(audioDir.path, 'bloco_${_blocks + 1}.m4a');
    await _rec.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          numChannels: 1,
          sampleRate: 16000,
          bitRate: 48000,
          androidConfig: AndroidRecordConfig(
              service: AndroidService(
                  title: 'Gravando sessão', content: 'Diário da Campanha')),
        ),
        path: _currentPath!);
    _blockStart = DateTime.now();
    _blockAccum = Duration.zero;
  }

  Future<void> _closeBlock() async {
    final path = await _rec.stop();
    final len = _blockAccum +
        (_blockStart != null && _state == RecState.recording
            ? DateTime.now().difference(_blockStart!)
            : Duration.zero);
    if (path != null && File(path).existsSync() && len.inSeconds > 0) {
      await repo.addAudio(_sessionId!, path, durationSec: len.inSeconds);
      _blocks++;
      _total += len;
    }
    _blockAccum = Duration.zero;
    _blockStart = null;
  }

  Future<void> _tick() async {
    if (_state == RecState.recording) {
      final cur = _blockAccum + DateTime.now().difference(_blockStart!);
      if (cur >= blockLength) {
        await _closeBlock();
        await _startBlock();
      }
    }
    _emit();
  }

  Future<void> pause() async {
    if (_state != RecState.recording) return;
    _blockAccum += DateTime.now().difference(_blockStart!);
    await _rec.pause();
    _state = RecState.paused;
    _emit();
  }

  Future<void> resume() async {
    if (_state != RecState.paused) return;
    await _rec.resume();
    _blockStart = DateTime.now();
    _state = RecState.recording;
    _emit();
  }

  /// Marca momento importante com um toque (segundos desde o início).
  void bookmark() {
    _bookmarks.add(_elapsed.inSeconds);
    _emit();
  }

  Future<List<int>> stop() async {
    _ticker?.cancel();
    await _ampSub?.cancel();
    await _closeBlock();
    await WakelockPlus.disable();
    final marks = List<int>.from(_bookmarks);
    _state = RecState.idle;
    _level = 0;
    _emit();
    return marks;
  }

  Future<void> dispose() async {
    _ticker?.cancel();
    await _ampSub?.cancel();
    await _rec.dispose();
  }
}
