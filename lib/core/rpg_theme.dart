import 'package:flutter/material.dart';

/// Paleta "8 bits" (baseada na Sweetie-16): fundo azul-noite, painéis em
/// ardósia, texto claro e cores chapadas para cada tipo de coisa.
@immutable
class RpgPalette extends ThemeExtension<RpgPalette> {
  final Color bg, bgDeep, surface, surface2, border, gold, goldDim, arcane, emerald, crimson;
  final Color text, muted;
  final Map<String, Color> kinds;
  const RpgPalette({
    required this.bg,
    required this.bgDeep,
    required this.surface,
    required this.surface2,
    required this.border,
    required this.gold,
    required this.goldDim,
    required this.arcane,
    required this.emerald,
    required this.crimson,
    required this.text,
    required this.muted,
    required this.kinds,
  });

  // Regras de cor: superfícies neutras e calmas; UM destaque (dourado) para
  // ação principal; cores semânticas só em selos pequenos e ícones. Todo texto
  // tem contraste mínimo 4,5:1 sobre a superfície (verificado em teste).
  static const dark = RpgPalette(
    bg: Color(0xFF0E1128),
    bgDeep: Color(0xFF080A1A),
    surface: Color(0xFF191E3B),
    surface2: Color(0xFF252C57),
    border: Color(0xFF3A4380),
    gold: Color(0xFFFFD166),
    goldDim: Color(0xFFB88A1E),
    arcane: Color(0xFF7CC4FF),
    emerald: Color(0xFF7EE0A1),
    crimson: Color(0xFFFF8A8A),
    text: Color(0xFFF3F5FF),
    muted: Color(0xFFAAB2DC),
    kinds: {
      'npc': Color(0xFF7CC4FF),
      'location': Color(0xFF7EE0A1),
      'quest': Color(0xFFFFD166),
      'item': Color(0xFFFFA36B),
      'faction': Color(0xFFFF9BD2),
      'spell': Color(0xFFC3A6FF),
    },
  );

  static const light = RpgPalette(
    bg: Color(0xFFEFF2FF),
    bgDeep: Color(0xFFE1E6FA),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFE9EDFF),
    border: Color(0xFFAEB8E6),
    gold: Color(0xFF8A5100),
    goldDim: Color(0xFFB87310),
    arcane: Color(0xFF1B4FA8),
    emerald: Color(0xFF16703A),
    crimson: Color(0xFFB3261E),
    text: Color(0xFF11153A),
    muted: Color(0xFF454E7E),
    kinds: {
      'npc': Color(0xFF1B4FA8),
      'location': Color(0xFF16703A),
      'quest': Color(0xFF8A5100),
      'item': Color(0xFFA8410E),
      'faction': Color(0xFF9A1F63),
      'spell': Color(0xFF5A2DC4),
    },
  );

  Color kind(String k) => kinds[k] ?? arcane;

  @override
  RpgPalette copyWith() => this;
  @override
  RpgPalette lerp(ThemeExtension<RpgPalette>? other, double t) => this;
}

extension RpgContext on BuildContext {
  RpgPalette get rpg => Theme.of(this).extension<RpgPalette>() ?? RpgPalette.dark;
}

/// Cor de texto legível sobre um fundo [bg] (escuro sobre claro e vice-versa).
Color onColor(Color bg) {
  const dark = Color(0xFF14172E), light = Color(0xFFFFFFFF);
  return contrastRatio(dark, bg) >= contrastRatio(light, bg) ? dark : light;
}

/// Razão de contraste WCAG entre duas cores (>= 4.5 para texto normal).
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + .05) / (lo + .05);
}

/// Texto de título/rótulo: Pixelify Sans em negrito, com sombra preta quando o
/// texto é claro (efeito de menu de jogo dos anos 2000).
TextStyle pxText(double size, Color color, {FontWeight weight = FontWeight.w700, double spacing = .5, double? height}) {
  // Piso de legibilidade: rótulos pequenos nunca ficam abaixo de ~13 px na tela.
  final fs = size < 13 ? 15.0 : size * 1.12;
  return TextStyle(
    fontFamily: 'Pixelify',
    fontSize: fs,
    color: color,
    fontWeight: weight,
    letterSpacing: spacing,
    height: height ?? 1.25,
    shadows: null,
  );
}

const _sq = RoundedRectangleBorder();

ThemeData buildRpgTheme(Brightness b) {
  final p = b == Brightness.dark ? RpgPalette.dark : RpgPalette.light;
  final onGold = b == Brightness.dark ? const Color(0xFF2A1A00) : const Color(0xFFFFF7E0);
  final scheme = ColorScheme(
    brightness: b,
    primary: p.gold,
    onPrimary: onGold,
    secondary: p.arcane,
    onSecondary: p.bgDeep,
    tertiary: p.emerald,
    onTertiary: p.bgDeep,
    error: p.crimson,
    onError: p.bgDeep,
    surface: p.surface,
    onSurface: p.text,
    surfaceContainerHighest: p.surface2,
    outline: p.border,
    outlineVariant: p.border,
  );
  const List<Shadow>? _sh = null;
  final base = ThemeData(brightness: b, useMaterial3: true, colorScheme: scheme, fontFamily: 'Pixelify');
  final body = base.textTheme.apply(bodyColor: p.text, displayColor: p.text);
  final text = body.copyWith(
    bodyLarge: body.bodyLarge?.copyWith(fontSize: 22, height: 1.35, shadows: _sh),
    bodyMedium: body.bodyMedium?.copyWith(fontSize: 20, height: 1.35, shadows: _sh),
    bodySmall: body.bodySmall?.copyWith(fontSize: 18, height: 1.3, shadows: _sh),
    headlineMedium: pxText(34, p.text),
    headlineSmall: pxText(28, p.text),
    titleLarge: pxText(24, p.text),
    titleMedium: pxText(20, p.text),
    titleSmall: pxText(16, p.text),
    labelLarge: pxText(16, p.text),
    labelMedium: pxText(14, p.text),
    labelSmall: pxText(12, p.muted),
  );
  BorderSide line([Color? c, double w = 3]) => BorderSide(color: c ?? p.border, width: w);
  OutlineInputBorder field(Color c) => OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: line(c));
  return base.copyWith(
    extensions: [p],
    scaffoldBackgroundColor: Colors.transparent,
    canvasColor: p.surface,
    dividerColor: p.border,
    splashFactory: NoSplash.splashFactory,
    highlightColor: p.gold.withValues(alpha: .08),
    hoverColor: p.gold.withValues(alpha: .08),
    textTheme: text,
    primaryTextTheme: text,
    iconTheme: IconThemeData(color: p.text, size: 24),
    cardTheme: CardThemeData(color: p.surface, elevation: 0, margin: EdgeInsets.zero, shape: _sq.copyWith(side: line())),
    listTileTheme: ListTileThemeData(iconColor: p.gold, shape: _sq),
    dividerTheme: DividerThemeData(color: p.border, space: 1, thickness: 3),
    filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
            backgroundColor: p.gold,
            foregroundColor: onGold,
            shape: _sq.copyWith(side: line(p.goldDim)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            textStyle: pxText(16, onGold))),
    outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
            foregroundColor: p.text,
            side: line(),
            shape: _sq,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            textStyle: pxText(16, p.text))),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: p.gold, shape: _sq, textStyle: pxText(14, p.gold))),
    iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(foregroundColor: p.gold, shape: _sq)),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.gold, foregroundColor: onGold, shape: _sq.copyWith(side: line(p.goldDim)), extendedTextStyle: pxText(16, onGold)),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.bgDeep,
      labelStyle: TextStyle(color: p.muted, fontSize: 20),
      hintStyle: TextStyle(color: p.muted.withValues(alpha: .7), fontSize: 20),
      border: field(p.border),
      enabledBorder: field(p.border),
      focusedBorder: field(p.gold),
    ),
    chipTheme: base.chipTheme.copyWith(backgroundColor: p.surface2, side: line(), shape: _sq, labelStyle: pxText(14, p.text)),
    dialogTheme: DialogThemeData(backgroundColor: p.surface, shape: _sq.copyWith(side: line(p.gold, 4)), titleTextStyle: pxText(18, p.gold)),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: p.surface, shape: _sq.copyWith(side: line(p.gold, 4))),
    snackBarTheme: SnackBarThemeData(
        backgroundColor: p.surface2,
        contentTextStyle: TextStyle(color: p.text, fontSize: 20),
        behavior: SnackBarBehavior.floating,
        shape: _sq.copyWith(side: line(p.gold))),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: p.gold),
    popupMenuTheme: PopupMenuThemeData(color: p.surface2, shape: _sq.copyWith(side: line(p.gold)), textStyle: TextStyle(color: p.text, fontSize: 22)),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        shape: _sq,
        side: line(),
        selectedBackgroundColor: p.gold,
        selectedForegroundColor: onGold,
        foregroundColor: p.muted,
        textStyle: pxText(14, p.text),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? p.gold : p.muted),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? p.goldDim : p.surface2),
      trackOutlineColor: WidgetStateProperty.all(p.border),
    ),
  );
}
