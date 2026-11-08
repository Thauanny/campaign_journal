
import 'package:flutter/material.dart';

import 'px_icons.dart';
import 'rpg_theme.dart';

const rpgSystems = [
  'D&D 5e',
  'Tormenta20',
  'Pathfinder 2e',
  'Call of Cthulhu',
  'Ordem Paranormal',
  'Vampiro: A Máscara',
  'Outro',
];

const kindLabels = {
  'npc': 'NPCs',
  'location': 'Locais',
  'quest': 'Missões',
  'item': 'Itens',
  'faction': 'Facções',
  'spell': 'Feitiços',
};
const kindSingular = {
  'npc': 'NPC',
  'location': 'Local',
  'quest': 'Missão',
  'item': 'Item',
  'faction': 'Facção',
  'spell': 'Feitiço',
};
const kindIcons = {
  'npc': PxIcons.user,
  'location': PxIcons.buildings,
  'quest': PxIcons.flag,
  'item': PxIcons.coin,
  'faction': PxIcons.shield,
  'spell': PxIcons.moonStars,
};

const sessionStatusLabels = {
  'recorded': 'Gravada',
  'processing': 'Processando',
  'review': 'Em revisão',
  'done': 'Concluída',
};

Color statusColor(BuildContext c, String status) {
  final p = c.rpg;
  return switch (status) {
    'recorded' => p.muted,
    'processing' => p.gold,
    'review' => p.arcane,
    'done' => p.emerald,
    _ => p.muted,
  };
}

// ───────────────────────── Fundo ─────────────────────────

/// Fundo do app: cor sólida e calma (sem ruído visual atrás do conteúdo).
class GameBackdrop extends StatelessWidget {
  final Widget child;
  const GameBackdrop({super.key, required this.child});
  @override
  Widget build(BuildContext context) => ColoredBox(color: context.rpg.bg, child: child);
}

// ───────────────────────── Janela estilo RPG de 32 bits ─────────────────────────

const _u = 2.0; // "pixel" da interface (fino: mais resolução)

/// Contorno com cantos em escada de 3 degraus (pixel art arredondado).
Path _stair(Rect r) {
  const u = _u;
  final l = r.left, t = r.top, rt = r.right, b = r.bottom;
  return Path()
    ..moveTo(l + 3 * u, t)
    ..lineTo(rt - 3 * u, t)
    ..lineTo(rt - 3 * u, t + u)
    ..lineTo(rt - u, t + u)
    ..lineTo(rt - u, t + 3 * u)
    ..lineTo(rt, t + 3 * u)
    ..lineTo(rt, b - 3 * u)
    ..lineTo(rt - u, b - 3 * u)
    ..lineTo(rt - u, b - u)
    ..lineTo(rt - 3 * u, b - u)
    ..lineTo(rt - 3 * u, b)
    ..lineTo(l + 3 * u, b)
    ..lineTo(l + 3 * u, b - u)
    ..lineTo(l + u, b - u)
    ..lineTo(l + u, b - 3 * u)
    ..lineTo(l, b - 3 * u)
    ..lineTo(l, t + 3 * u)
    ..lineTo(l + u, t + 3 * u)
    ..lineTo(l + u, t + u)
    ..lineTo(l + 3 * u, t + u)
    ..close();
}

/// Janela: sombra dura curta, borda de 2 px com cantos em escada, preenchimento
/// plano (ou degradê/brilho nos botões) e, opcionalmente, uma faixa colorida à
/// esquerda para indicar o tipo/estado sem poluir a moldura.
class _WinPainter extends CustomPainter {
  final Color top, bottom, border;
  final Color? stripe;
  final bool gloss, shadow;
  final Color shadowColor;
  _WinPainter(this.top, this.bottom, this.border, {this.stripe, this.gloss = false, this.shadow = true, this.shadowColor = const Color(0x40000000)});
  @override
  void paint(Canvas canvas, Size s) {
    final full = Offset.zero & s;
    if (shadow) canvas.drawPath(_stair(full.shift(const Offset(_u, _u * 1.5))), Paint()..color = shadowColor);
    canvas.drawPath(_stair(full), Paint()..color = border);
    final fillRect = full.deflate(_u);
    final fill = _stair(fillRect);
    canvas.drawPath(
        fill,
        Paint()
          ..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [top, bottom]).createShader(fillRect));
    canvas.save();
    canvas.clipPath(fill);
    if (gloss) {
      canvas.drawRect(Rect.fromLTWH(fillRect.left, fillRect.top, fillRect.width, fillRect.height * .45), Paint()..color = Colors.white.withValues(alpha: .28));
    }
    if (stripe != null) {
      canvas.drawRect(Rect.fromLTWH(fillRect.left, fillRect.top, _u * 2.5, fillRect.height), Paint()..color = stripe!);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WinPainter o) =>
      o.top != top || o.bottom != bottom || o.border != border || o.stripe != stripe || o.gloss != gloss || o.shadow != shadow || o.shadowColor != shadowColor;
}

Color _shadowOf(BuildContext c) => Theme.of(c).brightness == Brightness.dark ? const Color(0x80000000) : const Color(0x33101540);

/// Painel base do app. Borda neutra; [accent] vira uma faixa colorida à
/// esquerda; [fill] (pode ter transparência) é aplicado sobre a superfície.
class RpgCard extends StatefulWidget {
  final Widget child;
  final Color? accent;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? fill;
  final double cut; // mantido por compatibilidade
  const RpgCard({super.key, required this.child, this.accent, this.onTap, this.fill, this.cut = 0, this.padding = const EdgeInsets.all(16)});
  @override
  State<RpgCard> createState() => _RpgCardState();
}

class _RpgCardState extends State<RpgCard> {
  bool _hover = false, _down = false;
  @override
  Widget build(BuildContext context) {
    final p = context.rpg;
    final tappable = widget.onTap != null;
    final border = (_hover && tappable) ? p.gold : p.border;
    final fill = widget.fill == null ? p.surface : Color.alphaBlend(widget.fill!, p.surface);
    final extraLeft = widget.accent != null ? _u * 2.5 : 0.0;
    Widget body = Transform.translate(
      offset: Offset(0, _down ? 2 : 0),
      child: CustomPaint(
        painter: _WinPainter(fill, fill, border, stripe: widget.accent, shadow: !_down, shadowColor: _shadowOf(context)),
        child: Padding(padding: EdgeInsets.fromLTRB(_u * 1.5 + extraLeft, _u * 1.5, _u * 1.5, _u * 1.5).add(widget.padding), child: widget.child),
      ),
    );
    body = Padding(padding: const EdgeInsets.only(right: _u, bottom: _u * 1.5), child: body);
    if (!tappable) return body;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: widget.onTap,
        child: body,
      ),
    );
  }
}

/// Linha tracejada de pixels com um diamante no meio.
class OrnamentDivider extends StatelessWidget {
  final Color? color;
  const OrnamentDivider({super.key, this.color});
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 8,
        width: double.infinity,
        child: CustomPaint(painter: _DashPainter(color ?? context.rpg.border)),
      );
}

class _DashPainter extends CustomPainter {
  final Color color;
  _DashPainter(this.color);
  @override
  void paint(Canvas canvas, Size s) {
    final paint = Paint()..color = color;
    for (var x = 0.0; x < s.width; x += 8) {
      canvas.drawRect(Rect.fromLTWH(x, 3, 4, 2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashPainter o) => o.color != color;
}

// ───────────────────────── Botões e barra ─────────────────────────

enum RuneTone { primary, ghost, danger, arcane }

/// Botão de arcade: bloco chapado com sombra dura que "afunda" ao apertar.
class RuneButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final RuneTone tone;
  final bool compact;
  const RuneButton(this.label, {super.key, this.icon, this.onPressed, this.tone = RuneTone.primary, this.compact = false});
  @override
  State<RuneButton> createState() => _RuneButtonState();
}

class _RuneButtonState extends State<RuneButton> {
  bool _hover = false, _down = false;
  @override
  Widget build(BuildContext context) {
    final p = context.rpg;
    final enabled = widget.onPressed != null;
    // Principal = dourado (único destaque da tela). Os demais são discretos.
    final (Color top, Color bottom, Color border, Color fg, bool glossy) = switch (widget.tone) {
      RuneTone.primary => (const Color(0xFFFFE08A), const Color(0xFFF2B53A), const Color(0xFF8A5A00), const Color(0xFF2A1A00), true),
      RuneTone.ghost => (p.surface2, p.surface2, p.border, p.text, false),
      RuneTone.danger => (p.crimson, p.crimson, Color.lerp(p.crimson, Colors.black, .4)!, onColor(p.crimson), false),
      RuneTone.arcane => (p.arcane, p.arcane, Color.lerp(p.arcane, Colors.black, .4)!, onColor(p.arcane), false),
    };
    final h = widget.compact ? 42.0 : 52.0;
    final lift = _hover && enabled ? .10 : 0.0;
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: widget.onPressed,
        child: Opacity(
          opacity: enabled ? 1 : .5,
          child: Padding(
            padding: const EdgeInsets.only(right: _u, bottom: _u * 1.5),
            child: Transform.translate(
              offset: Offset(0, _down ? _u : 0),
              child: CustomPaint(
                painter: _WinPainter(Color.lerp(top, Colors.white, lift)!, Color.lerp(bottom, Colors.white, lift)!, border, gloss: glossy, shadow: !_down, shadowColor: _shadowOf(context)),
                child: Container(
                  height: h,
                  padding: EdgeInsets.symmetric(horizontal: widget.compact ? 14 : 22),
                  child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                    if (widget.icon != null) ...[Icon(widget.icon, size: 24, color: fg), const SizedBox(width: 8)],
                    Flexible(child: Text(widget.label.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: pxText(widget.compact ? 13 : 15, fg))),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Barra de título: faixa lisa com filete embaixo (sem degradê).
/// Logo do projeto em pixel art (sem suavização, para manter os pixels nítidos).
class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 36});
  @override
  Widget build(BuildContext context) => Image.asset('assets/icon/logo_small.png', width: size, height: size, filterQuality: FilterQuality.none, semanticLabel: 'Diário da Campanha');
}

/// Carregamento de tela cheia: logo pulsando e barra de blocos.
class AppLoading extends StatelessWidget {
  const AppLoading({super.key});
  @override
  Widget build(BuildContext context) => const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          AppLogo(size: 96),
          SizedBox(height: 20),
          PxLoader(),
        ]),
      );
}

class GameBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  const GameBar({super.key, this.title, this.leading, this.actions});
  @override
  Size get preferredSize => const Size.fromHeight(68);
  @override
  Widget build(BuildContext context) {
    final p = context.rpg;
    Widget? lead = leading;
    if (lead is BackButton) {
      lead = _PxIconButton(PxIcons.arrowLeft, lead.onPressed ?? () => Navigator.maybePop(context));
    } else if (lead is SizedBox) {
      lead = null;
    }
    final label = title is Text ? ((title as Text).data ?? '') : '';
    return Container(
      decoration: BoxDecoration(color: p.surface, border: Border(bottom: BorderSide(color: p.border, width: 2))),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 66,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              if (lead != null) ...[lead, const SizedBox(width: 14)],
              const AppLogo(size: 36),
              const SizedBox(width: 10),
              Expanded(child: Text(label.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: pxText(20, p.text))),
              ...?actions,
            ]),
          ),
        ),
      ),
    );
  }
}

class _PxIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _PxIconButton(this.icon, this.onTap);
  @override
  Widget build(BuildContext context) {
    final p = context.rpg;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 44, height: 44,
          child: CustomPaint(
            painter: _WinPainter(p.surface2, p.surface2, p.border, shadow: false),
            child: Icon(icon, color: p.text, size: 24),
          ),
        ),
      ),
    );
  }
}

/// Abas: a selecionada em dourado; as outras lisas, com texto legível.
class GameTabs extends StatelessWidget {
  final List<(IconData, String)> tabs;
  const GameTabs(this.tabs, {super.key});
  @override
  Widget build(BuildContext context) {
    final p = context.rpg;
    final ctl = DefaultTabController.of(context);
    return AnimatedBuilder(
      animation: ctl.animation!,
      builder: (_, __) {
        final cur = ctl.index;
        return Row(children: [
          for (var i = 0; i < tabs.length; i++)
            Expanded(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => ctl.animateTo(i),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: CustomPaint(
                      painter: i == cur
                          ? _WinPainter(const Color(0xFFFFE08A), const Color(0xFFF2B53A), const Color(0xFF8A5A00), gloss: true, shadow: false)
                          : _WinPainter(p.surface, p.surface, p.border, shadow: false),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(tabs[i].$1, size: 24, color: i == cur ? const Color(0xFF2A1A00) : p.text),
                          const SizedBox(height: 4),
                          Text(tabs[i].$2.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: pxText(12, i == cur ? const Color(0xFF2A1A00) : p.text)),
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ]);
      },
    );
  }
}

// ───────────────────────── Peças de informação ─────────────────────────

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip(this.status, {super.key});
  @override
  Widget build(BuildContext context) {
    final col = statusColor(context, status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      color: col,
      child: Text((sessionStatusLabels[status] ?? status).toUpperCase(), style: pxText(11, onColor(col))),
    );
  }
}

/// Indicador numérico: rótulo legível em cima e número GRANDE em cor de texto
/// (alto contraste). A cor do tipo aparece só na faixa lateral e no ícone.
class StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const StatTile(this.icon, this.value, this.label, this.color, {super.key});
  @override
  Widget build(BuildContext context) {
    final p = context.rpg;
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 132),
      child: RpgCard(
        accent: color,
        padding: const EdgeInsets.fromLTRB(8, 6, 10, 6),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(width: 6),
            Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 19, color: p.muted))),
          ]),
          const SizedBox(height: 2),
          Text(value, style: pxText(30, p.text)),
        ]),
      ),
    );
  }
}

/// Barra de progresso em blocos.
class XpBar extends StatelessWidget {
  final double value;
  final Color? color;
  final double height;
  const XpBar(this.value, {super.key, this.color, this.height = 14});
  @override
  Widget build(BuildContext context) {
    final p = context.rpg;
    final c = color ?? p.gold;
    const segs = 20;
    final filled = (value.clamp(0.0, 1.0) * segs).round();
    return Container(
      height: height + 10,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: p.bgDeep, border: Border.all(color: p.border, width: 2)),
      child: Row(children: [
        for (var i = 0; i < segs; i++)
          Expanded(child: Container(margin: const EdgeInsets.only(right: 2), color: i < filled ? c : p.surface2)),
      ]),
    );
  }
}

/// Selo de tipo (NPC, Local, Missão…): cor chapada com texto de contraste.
class KindBadge extends StatelessWidget {
  final String kind;
  final String? label;
  const KindBadge(this.kind, {super.key, this.label});
  @override
  Widget build(BuildContext context) {
    final c = context.rpg.kind(kind);
    final fg = onColor(c);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: c,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(kindIcons[kind], size: 24, color: fg),
        const SizedBox(width: 4),
        Text((label ?? kindSingular[kind] ?? kind).toUpperCase(), style: pxText(11, fg)),
      ]),
    );
  }
}

/// Ícone do tipo num "slot" simples.
class KindAvatar extends StatelessWidget {
  final String kind;
  final double size;
  const KindAvatar(this.kind, {super.key, this.size = 48});
  @override
  Widget build(BuildContext context) {
    final p = context.rpg;
    final c = p.kind(kind);
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: Color.alphaBlend(c.withValues(alpha: .14), p.surface), border: Border.all(color: c, width: 2)),
      child: Icon(kindIcons[kind], color: c, size: size >= 44 ? 36 : 24),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const SectionTitle(this.text, {super.key, this.trailing});
  @override
  Widget build(BuildContext context) {
    final p = context.rpg;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 28, 0, 12),
      child: Row(children: [
        Text(text.toUpperCase(), style: pxText(15, p.text)),
        const SizedBox(width: 14),
        const Expanded(child: OrnamentDivider()),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ]),
    );
  }
}

/// Estado vazio: ícone, título e uma frase.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Widget? action;
  const EmptyState(this.icon, this.title, this.body, {super.key, this.action});
  @override
  Widget build(BuildContext context) {
    final p = context.rpg;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 88, height: 88, decoration: BoxDecoration(color: p.surface2, border: Border.all(color: p.border, width: 2)), child: Icon(icon, color: p.gold, size: 48)),
            const SizedBox(height: 20),
            Text(title.toUpperCase(), textAlign: TextAlign.center, style: pxText(16, p.text)),
            const SizedBox(height: 10),
            Text(body, textAlign: TextAlign.center, style: TextStyle(color: p.muted, fontSize: 21, height: 1.3)),
            if (action != null) ...[const SizedBox(height: 20), action!],
          ]),
        ),
      ),
    );
  }
}

void snack(BuildContext context, String msg) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

Future<bool> confirmDialog(BuildContext context, String title, String body, {String ok = 'Confirmar'}) async {
  final r = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
            title: Text(title.toUpperCase()),
            content: Text(body, style: const TextStyle(fontSize: 22, height: 1.1)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('CANCELAR')),
              FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(ok.toUpperCase())),
            ],
          ));
  return r ?? false;
}

/// Limita a largura em telas largas (desktop).
class MaxWidth extends StatelessWidget {
  final Widget child;
  final double width;
  const MaxWidth(this.child, {super.key, this.width = 900});
  @override
  Widget build(BuildContext context) => Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(constraints: BoxConstraints(maxWidth: width), child: child));
}

/// Botão de filtro (selecionável). Selecionado = dourado; senão, liso e legível.
class PxChoice extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;
  final IconData? icon;
  const PxChoice(this.label, this.selected, this.onTap, {super.key, this.color, this.icon});
  @override
  Widget build(BuildContext context) {
    final p = context.rpg;
    final fg = selected ? const Color(0xFF2A1A00) : p.text;
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 6),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFF2B53A) : p.surface,
              border: Border.all(color: selected ? const Color(0xFF8A5A00) : p.border, width: 2),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (icon != null) ...[Icon(icon, size: 24, color: selected ? fg : (color ?? p.text)), const SizedBox(width: 6)],
              Text(label.toUpperCase(), style: pxText(12, fg)),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Bloco de menu: ícone à esquerda, título e uma linha de apoio.
class MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;
  final VoidCallback onTap;
  final Color? color;
  final String? badge;
  const MenuTile(this.icon, this.title, this.sub, this.onTap, {super.key, this.color, this.badge});
  @override
  Widget build(BuildContext context) {
    final p = context.rpg;
    final c = color ?? p.gold;
    return RpgCard(
      onTap: onTap,
      padding: const EdgeInsets.all(8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(width: 48, height: 48, color: Color.alphaBlend(c.withValues(alpha: .14), p.surface2), child: Icon(icon, color: c, size: 36)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: pxText(14, p.text)),
          const SizedBox(height: 2),
          Text(sub, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: p.muted, fontSize: 18, height: 1.15)),
        ])),
        if (badge != null) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), color: p.gold, child: Text(badge!, style: pxText(12, onColor(p.gold)))),
      ]),
    );
  }
}

/// Carregando em 8 bits: uma fileira de blocos que "corre" e deixa rastro.
class PxLoader extends StatefulWidget {
  final Color? color;
  final int blocks;
  final double size;
  const PxLoader({super.key, this.color, this.blocks = 8, this.size = 12});
  @override
  State<PxLoader> createState() => _PxLoaderState();
}

class _PxLoaderState extends State<PxLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.rpg;
    final col = widget.color ?? p.gold;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final head = _c.value * widget.blocks;
        return Row(mainAxisSize: MainAxisSize.min, children: [
          for (var i = 0; i < widget.blocks; i++)
            Builder(builder: (_) {
              var d = (head - i) % widget.blocks; // distância atrás da cabeça
              if (d < 0) d += widget.blocks;
              final a = (1 - d / 4).clamp(.15, 1.0);
              return Container(
                width: widget.size, height: widget.size,
                margin: EdgeInsets.only(right: widget.size / 4),
                color: col.withValues(alpha: a),
              );
            }),
        ]);
      },
    );
  }
}

/// Cursor piscante de terminal.
class BlinkCursor extends StatefulWidget {
  final Color color;
  const BlinkCursor({super.key, required this.color});
  @override
  State<BlinkCursor> createState() => _BlinkCursorState();
}

class _BlinkCursorState extends State<BlinkCursor> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(opacity: _c.drive(CurveTween(curve: const Threshold(.5))), child: Container(width: 10, height: 16, color: widget.color));
}

/// Bloco expansível padrão do app: título + SETA clara (▼ aberto/▲ fechado).
/// [preview] aparece (2–3 linhas) enquanto está fechado. [flat] = sem moldura.
class PxExpandable extends StatefulWidget {
  final String title;
  final IconData? icon;
  final Widget child;
  final bool initiallyOpen;
  final String? preview;
  final String? hint; // texto curto à direita (ex.: "3 itens")
  final bool flat;
  final Color? accent;
  const PxExpandable({super.key, required this.title, required this.child, this.icon, this.initiallyOpen = false, this.preview, this.hint, this.flat = false, this.accent});
  @override
  State<PxExpandable> createState() => _PxExpandableState();
}

class _PxExpandableState extends State<PxExpandable> {
  late bool _open = widget.initiallyOpen;
  @override
  Widget build(BuildContext context) {
    final p = context.rpg;
    final header = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _open = !_open),
        child: Row(children: [
          if (widget.icon != null) ...[Icon(widget.icon, size: 24, color: widget.accent ?? p.gold), const SizedBox(width: 10)],
          Expanded(child: Text(widget.title.toUpperCase(), style: pxText(14, p.text))),
          if (widget.hint != null) Padding(padding: const EdgeInsets.only(right: 10), child: Text(widget.hint!, style: TextStyle(color: p.muted, fontSize: 19))),
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(color: p.surface2, border: Border.all(color: p.border, width: 2)),
            child: Icon(_open ? PxIcons.chevronUp : PxIcons.chevronDown, size: 24, color: p.text),
          ),
        ]),
      ),
    );
    final body = AnimatedSize(
      duration: const Duration(milliseconds: 180),
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: _open || widget.preview != null ? 12 : 0),
        child: _open
            ? widget.child
            : (widget.preview == null ? const SizedBox(width: double.infinity) : Text(widget.preview!, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(color: p.muted, fontSize: 21, height: 1.3))),
      ),
    );
    final col = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [header, body]);
    if (widget.flat) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(border: Border(top: BorderSide(color: p.border, width: 2))),
        child: col,
      );
    }
    return RpgCard(accent: widget.accent, padding: const EdgeInsets.all(12), child: col);
  }
}
