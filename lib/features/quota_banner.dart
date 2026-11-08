import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../ai/quota.dart';
import '../core/providers.dart';
import '../core/px_icons.dart';
import '../core/rpg_theme.dart';
import '../core/ui.dart';

/// Aviso fixo de limite de uso da IA, com a hora em que deve voltar a liberar.
/// Fica na tela inicial e nas campanhas; some sozinho quando o horário passa.
class QuotaBanner extends ConsumerStatefulWidget {
  const QuotaBanner({super.key});
  @override
  ConsumerState<QuotaBanner> createState() => _QuotaBannerState();
}

class _QuotaBannerState extends ConsumerState<QuotaBanner> {
  Timer? _t;

  @override
  void initState() {
    super.initState();
    // atualiza a contagem regressiva e remove o aviso quando expira
    _t = Timer.periodic(const Duration(seconds: 20), (_) {
      final n = QuotaCenter.notice.value;
      if (n != null && n.expired(DateTime.now())) {
        QuotaCenter.clear();
      } else if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.rpg;
    final active = ref.watch(engineProvider);
    return ValueListenableBuilder<QuotaNotice?>(
      valueListenable: QuotaCenter.notice,
      builder: (context, n, _) {
        // Só avisa da IA que está em uso: o limite de outra IA não atrapalha agora.
        if (n == null || n.expired(DateTime.now()) || n.provider != active) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: RpgCard(
            accent: p.crimson,
            padding: const EdgeInsets.all(10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(PxIcons.hourglass, color: p.crimson),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('LIMITE DE USO DA IA', style: pxText(12, p.crimson)),
                const SizedBox(height: 4),
                Text(quotaMessage(n), style: const TextStyle(fontSize: 21, height: 1.25)),
              ])),
              const SizedBox(width: 10),
              RuneButton('Trocar IA', compact: true, tone: RuneTone.ghost, onPressed: () => context.go('/ai')),
            ]),
          ),
        );
      },
    );
  }
}
