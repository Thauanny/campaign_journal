import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ai/quota.dart';
import 'app.dart';
import 'core/providers.dart';
import 'core/settings.dart';

/// Primeiro quadro imediato (logo sobre o fundo do app) enquanto o resto inicializa.
class _Boot extends StatelessWidget {
  const _Boot();
  @override
  Widget build(BuildContext context) => const Directionality(
        textDirection: TextDirection.ltr,
        child: ColoredBox(
          color: Color(0xFFEFF2FF),
          child: Center(child: Image(image: AssetImage('assets/icon/logo.png'), width: 128, height: 128, filterQuality: FilterQuality.none)),
        ),
      );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _Boot());
  // Necessário para abrir PDFs direto (sem o visualizador): define a pasta de cache.
  await pdfrxFlutterInitialize();
  final prefs = await SharedPreferences.getInstance();
  QuotaCenter.init(prefs);
  runApp(ProviderScope(
    overrides: [
      settingsProvider.overrideWithValue(
          // macOS: chaveiro tradicional — o "data protection keychain" exige
          // entitlement + assinatura de desenvolvedor (erro -34018).
          Settings(prefs, const FlutterSecureStorage(mOptions: MacOsOptions(usesDataProtectionKeychain: false)))),
    ],
    child: const CampaignJournalApp(),
  ));
}
