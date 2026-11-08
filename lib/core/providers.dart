import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ai/activity.dart';
import '../ai/factory.dart';
import '../data/database.dart';
import '../data/repo_facts.dart';
import '../data/repo_notes.dart';
import '../data/repository.dart';
import '../domain/models.dart';
import '../domain/pipeline.dart';
import 'recorder_service.dart';
import 'settings.dart';
import 'setup_service.dart';

final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
final repoProvider = Provider<Repository>((ref) => Repository(ref.watch(dbProvider)));

/// Sobrescrito no main() depois de carregar SharedPreferences.
final settingsProvider = Provider<Settings>((ref) => throw UnimplementedError());

final dioProvider = Provider<Dio>((ref) => Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(minutes: 5))));

final factoryProvider = Provider<ProviderFactory>(
    (ref) => ProviderFactory(ref.watch(settingsProvider), ref.watch(dioProvider)));

final processorProvider = Provider<SessionProcessor>((ref) => SessionProcessor(
    ref.watch(repoProvider), ref.watch(settingsProvider), ref.watch(factoryProvider)));

// ---- streams do banco ----
final campaignsProvider = StreamProvider<List<Campaign>>(
    (ref) => ref.watch(repoProvider).watchCampaigns());
final campaignProvider = StreamProvider.family<Campaign?, String>(
    (ref, id) => ref.watch(repoProvider).watchCampaign(id));
final heroesProvider = StreamProvider.family<List<Heroe>, String>(
    (ref, cid) => ref.watch(repoProvider).watchHeroes(cid));
final sessionsProvider = StreamProvider.family<List<Session>, String>(
    (ref, cid) => ref.watch(repoProvider).watchSessions(cid));
final sessionProvider = StreamProvider.family<Session?, String>(
    (ref, id) => ref.watch(repoProvider).watchSession(id));
final audiosProvider = StreamProvider.family<List<Audio>, String>(
    (ref, sid) => ref.watch(repoProvider).watchAudios(sid));
final segmentsProvider = StreamProvider.family<List<Segment>, String>(
    (ref, sid) => ref.watch(repoProvider).watchSegments(sid));
final pendingMentionsProvider = StreamProvider.family<List<Mention>, String>(
    (ref, sid) => ref.watch(repoProvider).watchPendingMentions(sid));
final sessionMentionsProvider = StreamProvider.family<List<Mention>, String>(
    (ref, sid) => ref.watch(repoProvider).watchMentionsOfSession(sid));
final eventsProvider = StreamProvider.family<List<Event>, String>(
    (ref, sid) => ref.watch(repoProvider).watchEvents(sid));
final spentProvider = StreamProvider.family<double, String>(
    (ref, cid) => ref.watch(repoProvider).watchSpent(cid));
final historyProvider = StreamProvider.family<List<EntityHistoryData>, String>(
    (ref, cid) => ref.watch(repoProvider).watchHistory(cid));

/// Entidades confirmadas de uma campanha; `(campaignId, kind?)`.
final entitiesProvider =
    StreamProvider.family<List<Entity>, (String, String?)>((ref, a) =>
        ref.watch(repoProvider).watchEntities(a.$1, kind: a.$2));
final entityProvider = StreamProvider.family<Entity?, String>(
    (ref, id) => ref.watch(repoProvider).watchEntity(id));
final entityMentionsProvider = StreamProvider.family<List<Mention>, String>(
    (ref, id) => ref.watch(repoProvider).watchMentionsOfEntity(id));
final heroItemsProvider = StreamProvider.family<List<Entity>, String>(
    (ref, id) => ref.watch(repoProvider).watchHeroItems(id));

// ---- gravador ----
class RecorderNotifier extends Notifier<RecorderState> {
  RecorderService? _svc;
  @override
  RecorderState build() {
    ref.onDispose(() => _svc?.dispose());
    return RecorderState.idle;
  }

  RecorderService get svc =>
      _svc ??= RecorderService(ref.read(repoProvider), (s) => state = s);
}

final recorderProvider =
    NotifierProvider<RecorderNotifier, RecorderState>(RecorderNotifier.new);

/// Progresso de processamento por sessão, com o registro ao vivo do que a IA faz.
class ProcessingState {
  final String step;
  final double fraction;
  final String detail;
  final String? error;
  final bool running;
  final DateTime? startedAt;
  final DateTime? stepStartedAt;

  /// Quanto tempo cada etapa já levou (etapas concluídas).
  final Map<String, Duration> stepTimes;
  final List<(DateTime, String)> log;
  const ProcessingState(this.step, this.fraction, this.detail,
      {this.error, this.running = false, this.startedAt, this.stepStartedAt, this.stepTimes = const {}, this.log = const []});

  ProcessingState copy({String? step, double? fraction, String? detail, String? error, bool? running, DateTime? stepStartedAt, Map<String, Duration>? stepTimes, List<(DateTime, String)>? log}) =>
      ProcessingState(step ?? this.step, fraction ?? this.fraction, detail ?? this.detail,
          error: error ?? this.error,
          running: running ?? this.running,
          startedAt: startedAt,
          stepStartedAt: stepStartedAt ?? this.stepStartedAt,
          stepTimes: stepTimes ?? this.stepTimes,
          log: log ?? this.log);
}

class ProcessingNotifier extends Notifier<Map<String, ProcessingState>> {
  @override
  Map<String, ProcessingState> build() => {};

  Future<void> run(String sessionId, ProcessingMode mode) async {
    final started = DateTime.now();
    var cur = ProcessingState('config', 0, 'Iniciando…', running: true, startedAt: started, stepStartedAt: started, log: [(started, 'Começando o processamento.')]);
    void set(ProcessingState s) {
      cur = s;
      state = {...state, sessionId: s};
    }

    void addLog(String m) => set(cur.copy(log: [...cur.log, (DateTime.now(), m)]));
    final sub = Activity.stream.listen(addLog);
    set(cur);
    try {
      await ref.read(processorProvider).process(sessionId, mode, (step, f, d) {
        final now = DateTime.now();
        if (step != cur.step) {
          final took = now.difference(cur.stepStartedAt ?? now);
          set(ProcessingState(step, f, d,
              running: true, startedAt: started, stepStartedAt: now, stepTimes: {...cur.stepTimes, cur.step: took}, log: cur.log));
        } else {
          set(cur.copy(fraction: f, detail: d));
        }
      });
      final now = DateTime.now();
      set(ProcessingState('done', 1, 'Pronto para revisão.',
          startedAt: started, stepStartedAt: now, stepTimes: {...cur.stepTimes, cur.step: now.difference(cur.stepStartedAt ?? now)}, log: [...cur.log, (now, 'Concluído em ${now.difference(started).inSeconds}s.')]));
    } catch (e) {
      // Mantém a etapa em que parou para a tela mostrar onde falhou.
      set(ProcessingState(cur.step, cur.fraction, '', error: e.toString(), startedAt: started, stepStartedAt: cur.stepStartedAt, stepTimes: cur.stepTimes, log: [...cur.log, (DateTime.now(), 'Erro: $e')]));
    } finally {
      await sub.cancel();
    }
  }
}

final processingProvider =
    NotifierProvider<ProcessingNotifier, Map<String, ProcessingState>>(
        ProcessingNotifier.new);

final setupServiceProvider = Provider<SetupService>(
    (ref) => SetupService(ref.watch(settingsProvider), ref.watch(dioProvider)));

/// Relatório do que falta para a IA gratuita; use `ref.invalidate` para reler.
final setupReportProvider = FutureProvider.autoDispose<SetupReport>(
    (ref) => ref.watch(setupServiceProvider).check());

/// IA ativa (observável): trocar aqui atualiza banners e telas.
class EngineNotifier extends Notifier<String?> {
  @override
  String? build() => ref.read(settingsProvider).engine;
  void set(String v) => state = v;
}

final engineProvider = NotifierProvider<EngineNotifier, String?>(EngineNotifier.new);

final notesProvider = StreamProvider.family<List<Note>, (String, String)>(
    (ref, a) => ref.watch(repoProvider).watchNotes(a.$1, a.$2));
final relationsProvider = StreamProvider.family<List<Relation>, String>(
    (ref, cid) => ref.watch(repoProvider).watchRelations(cid));

/// Todas as entidades da campanha, confirmadas e sugeridas.
final allEntitiesProvider = StreamProvider.family<List<Entity>, String>(
    (ref, cid) => ref.watch(repoProvider).watchAllEntities(cid));

/// Fatos de combate da sessão (dano, cura, XP, condições…).
final factsProvider = StreamProvider.family<List<Fact>, String>(
    (ref, sid) => ref.watch(repoProvider).watchFacts(sid));

/// Entradas da enciclopédia que não aparecem em nenhuma sessão.
final orphanEntitiesProvider = FutureProvider.autoDispose.family<List<Entity>, String>((ref, cid) async {
  ref.watch(allEntitiesProvider(cid));
  ref.watch(sessionsProvider(cid));
  return ref.read(repoProvider).orphanEntities(cid);
});
