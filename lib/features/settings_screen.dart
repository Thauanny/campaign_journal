import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app.dart';
import '../core/providers.dart';
import '../core/px_icons.dart';
import '../core/rpg_theme.dart';
import '../core/ui.dart';
import 'ai_screen.dart';

/// Configurações: 1) IA que vale para toda a campanha, 2) privacidade,
/// 3) aparência (e, só com IA paga, os modelos).
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsState();
}

class _SettingsState extends ConsumerState<SettingsScreen> {
  late final _extractModel = TextEditingController(text: ref.read(settingsProvider).modelFor('extract') ?? '');
  late final _summarizeModel = TextEditingController(text: ref.read(settingsProvider).modelFor('summarize') ?? '');

  @override
  Widget build(BuildContext context) {
    final s = ref.read(settingsProvider);
    final theme = ref.watch(themeModeProvider);
    ref.watch(engineProvider);
    final paid = s.engineIsPaid;
    return Scaffold(
      appBar: GameBar(title: const Text('Configurações'), leading: BackButton(onPressed: () => context.go('/'))),
      body: MaxWidth(
        width: 860,
        ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 48), children: [
          const SectionTitle('Inteligência artificial'),
          const ActiveAiCard(),
          const SectionTitle('Privacidade'),
          RpgCard(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Apagar o áudio depois de transcrever', style: TextStyle(fontSize: 24)),
              subtitle: const Text('A transcrição e o resumo continuam salvos.', style: TextStyle(fontSize: 20)),
              value: s.deleteAudioAfter,
              onChanged: (v) async { await s.setDeleteAudioAfter(v); setState(() {}); },
            ),
          ),
          const SectionTitle('Aparência'),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'dark', label: Text('ESCURO')),
              ButtonSegment(value: 'light', label: Text('CLARO')),
            ],
            selected: {theme == 'light' ? 'light' : 'dark'},
            onSelectionChanged: (v) => ref.read(themeModeProvider.notifier).set(v.first),
          ),
          // Só faz sentido para IAs pagas (OpenAI/Claude), que têm vários modelos por preço.
          // O Ollama (modelo e endereço) fica na tela da IA Local.
          if (paid) ...[
            const SizedBox(height: 22),
            PxExpandable(
              title: 'Modelos da IA paga',
              icon: PxIcons.sliders,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Deixe vazio para usar o modelo padrão.', style: TextStyle(color: context.rpg.muted, fontSize: 20)),
                const SizedBox(height: 10),
                TextField(controller: _extractModel, decoration: const InputDecoration(labelText: 'Extração'), onChanged: (v) => s.setModelFor('extract', v.trim())),
                const SizedBox(height: 10),
                TextField(controller: _summarizeModel, decoration: const InputDecoration(labelText: 'Resumo'), onChanged: (v) => s.setModelFor('summarize', v.trim())),
              ]),
            ),
          ],
        ]),
      ),
    );
  }
}
