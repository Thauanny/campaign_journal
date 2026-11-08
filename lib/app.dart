import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/providers.dart';
import 'core/rpg_theme.dart';
import 'core/ui.dart';
import 'features/ask.dart';
import 'features/campaigns.dart';
import 'features/hub.dart';
import 'features/journey.dart';
import 'features/encyclopedia.dart';
import 'features/hero_onboarding.dart';
import 'features/heroes.dart';
import 'features/new_session.dart';
import 'features/prep.dart';
import 'features/tables.dart';
import 'features/recap.dart';
import 'features/processing.dart';
import 'features/recorder.dart';
import 'features/recordings.dart';
import 'features/review.dart';
import 'features/session_detail.dart';
import 'features/sessions.dart';
import 'features/settings_screen.dart';
import 'features/ai_screen.dart';

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => const CampaignsScreen(), routes: [
      GoRoute(path: 'settings', builder: (_, __) => const SettingsScreen()),
      GoRoute(path: 'ai', builder: (_, s) => AiScreen(back: s.uri.queryParameters['back']), routes: [
        GoRoute(path: ':id', builder: (_, s) => AiDetailScreen(s.pathParameters['id']!, back: s.uri.queryParameters['back']), routes: [
          GoRoute(path: 'models', builder: (_, s) => AiModelsScreen(s.pathParameters['id']!)),
        ]),
      ]),
      GoRoute(
          path: 'campaign/new',
          builder: (_, __) => const CampaignFormScreen()),
      GoRoute(path: 'campaign/:cid', builder: (_, s) => DashboardScreen(s.pathParameters['cid']!), routes: [
        GoRoute(path: 'edit', builder: (_, s) => CampaignFormScreen(campaignId: s.pathParameters['cid'])),
        GoRoute(path: 'ask', builder: (_, s) => AskScreen(s.pathParameters['cid']!)),
        GoRoute(path: 'heroes', builder: (_, s) => HeroesScreen(s.pathParameters['cid']!)),
        GoRoute(path: 'hero/:hid', builder: (_, s) => HeroFormScreen(s.pathParameters['cid']!, s.pathParameters['hid']!, back: s.uri.queryParameters['back'])),
        GoRoute(path: 'heroes/start', builder: (_, s) => HeroOnboardingScreen(s.pathParameters['cid']!)),
        GoRoute(path: 'journey', builder: (_, s) => JourneyScreen(s.pathParameters['cid']!)),
        GoRoute(path: 'prep', builder: (_, s) => PrepScreen(s.pathParameters['cid']!)),
        GoRoute(path: 'tables', builder: (_, s) => TablesScreen(s.pathParameters['cid']!)),
        GoRoute(path: 'recap', builder: (_, s) => RecapScreen(s.pathParameters['cid']!)),
        GoRoute(path: 'new', builder: (_, s) => NewSessionScreen(s.pathParameters['cid']!)),
        GoRoute(path: 'sessions', builder: (_, s) => SessionsScreen(s.pathParameters['cid']!)),
        GoRoute(path: 'encyclopedia', builder: (_, s) => EncyclopediaScreen(s.pathParameters['cid']!)),
        GoRoute(path: 'entity/:eid', builder: (_, s) => EntityScreen(s.pathParameters['cid']!, s.pathParameters['eid']!)),
        GoRoute(path: 'session/:sid', builder: (_, s) => SessionDetailScreen(s.pathParameters['cid']!, s.pathParameters['sid']!), routes: [
          GoRoute(path: 'recordings', builder: (_, s) => RecordingsScreen(s.pathParameters['cid']!, s.pathParameters['sid']!, fresh: s.uri.queryParameters['fresh'] == '1')),
          GoRoute(path: 'record', builder: (_, s) => RecorderScreen(s.pathParameters['cid']!, s.pathParameters['sid']!)),
          GoRoute(path: 'process', builder: (_, s) => ProcessingScreen(s.pathParameters['cid']!, s.pathParameters['sid']!, autostart: s.uri.queryParameters['go'] == '1')),
          GoRoute(path: 'review', builder: (_, s) => ReviewScreen(s.pathParameters['cid']!, s.pathParameters['sid']!)),
        ]),
      ]),
    ]),
  ],
);

class CampaignJournalApp extends ConsumerWidget {
  const CampaignJournalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = switch (ref.watch(themeModeProvider)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.dark,
    };
    return MaterialApp.router(
      title: 'Diário da Campanha',
      routerConfig: _router,
      theme: buildRpgTheme(Brightness.light),
      darkTheme: buildRpgTheme(Brightness.dark),
      themeMode: mode,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
        child: GameBackdrop(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}

class ThemeModeNotifier extends Notifier<String> {
  @override
  String build() => ref.read(settingsProvider).themeMode;
  void set(String v) {
    ref.read(settingsProvider).setThemeMode(v);
    state = v;
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, String>(ThemeModeNotifier.new);
