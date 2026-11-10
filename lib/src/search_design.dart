import 'package:flutter/material.dart';

/// Visual design of the bar. Every design derives its colors from the
/// ambient [ColorScheme], so it matches your brand, light and dark.
enum AppBarSearchDesign {
  /// A regular Material [AppBar] — the 1.x look.
  classic,

  /// Material 3 search pill: the field opens in a rounded, filled capsule.
  pill,

  /// Frosted "liquid glass": translucent blurred bar over your content.
  /// Pair with `Scaffold(extendBodyBehindAppBar: true)`.
  glass,

  /// Vivid gradient bar with on-gradient text and a translucent field.
  gradient,

  /// Detached floating capsule with soft shadow, inset from the edges.
  floating,

  /// Command-palette style: an always-visible search trigger with a
  /// ⌘K / Ctrl K hint — ideal for desktop and web.
  spotlight,
}

/// Resolved colors and geometry for one design.
@immutable
class SearchDesignSpec {
  const SearchDesignSpec({
    required this.design,
    required this.foreground,
    required this.hint,
    required this.fieldFill,
    required this.fieldRadius,
    required this.toolbarHeight,
    this.background,
    this.gradient,
    this.blurSigma = 0,
    this.fieldBorder,
    this.fieldFocusBorder,
    this.margin = EdgeInsets.zero,
    this.barRadius,
    this.shadow,
    this.bottomBorder,
    this.capsule,
  });

  final AppBarSearchDesign design;
  final Color foreground;
  final Color hint;
  final Color fieldFill;
  final double fieldRadius;
  final double toolbarHeight;
  final Color? background;
  final Gradient? gradient;
  final double blurSigma;
  final Color? fieldBorder;
  final Color? fieldFocusBorder;
  final EdgeInsets margin;
  final BorderRadius? barRadius;
  final List<BoxShadow>? shadow;
  final Color? bottomBorder;

  /// Fill of the floating capsule (floating design only).
  final Color? capsule;

  /// Whether the search field is drawn inside its own filled shape.
  bool get filledField => fieldFill.a > 0;

  /// Default toolbar height per design (excludes floating margins).
  static double defaultToolbarHeight(AppBarSearchDesign d) => switch (d) {
    AppBarSearchDesign.classic => kToolbarHeight,
    AppBarSearchDesign.floating => 60,
    _ => 64,
  };

  /// Extra height around the toolbar (floating margins).
  static double verticalChrome(AppBarSearchDesign d) => d == AppBarSearchDesign.floating ? 16 : 0;

  static SearchDesignSpec resolve(
    AppBarSearchDesign design,
    ThemeData theme, {
    Color? backgroundColor,
    Color? foregroundColor,
    Gradient? gradient,
    double? toolbarHeight,
  }) {
    final cs = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final height = toolbarHeight ?? defaultToolbarHeight(design);
    final appBarBg = theme.appBarTheme.backgroundColor;
    final appBarFg = theme.appBarTheme.foregroundColor;

    switch (design) {
      case AppBarSearchDesign.classic:
        final fg = foregroundColor ?? appBarFg ?? cs.onSurface;
        return SearchDesignSpec(
          design: design,
          background: backgroundColor ?? appBarBg ?? cs.surface,
          foreground: fg,
          hint: cs.onSurfaceVariant,
          fieldFill: Colors.transparent,
          fieldRadius: 0,
          toolbarHeight: height,
        );
      case AppBarSearchDesign.pill:
        return SearchDesignSpec(
          design: design,
          background: backgroundColor ?? appBarBg ?? cs.surface,
          foreground: foregroundColor ?? appBarFg ?? cs.onSurface,
          hint: cs.onSurfaceVariant,
          fieldFill: cs.surfaceContainerHighest,
          fieldFocusBorder: cs.primary.withValues(alpha: 0.0),
          fieldRadius: 28,
          toolbarHeight: height,
        );
      case AppBarSearchDesign.glass:
        return SearchDesignSpec(
          design: design,
          background: (backgroundColor ?? cs.surface).withValues(alpha: dark ? 0.55 : 0.62),
          blurSigma: 22,
          foreground: foregroundColor ?? cs.onSurface,
          hint: cs.onSurfaceVariant,
          fieldFill: cs.onSurface.withValues(alpha: dark ? 0.10 : 0.06),
          fieldBorder: cs.onSurface.withValues(alpha: dark ? 0.14 : 0.08),
          fieldRadius: 22,
          bottomBorder: cs.outlineVariant.withValues(alpha: 0.45),
          toolbarHeight: height,
        );
      case AppBarSearchDesign.gradient:
        // Vivid by default: M3 tonal colors are deliberately muted, so lift
        // saturation and pin lightness for a bright, legible gradient.
        Color vivid(Color c, double hueShift) {
          final h = HSLColor.fromColor(c);
          return h
              .withHue((h.hue + hueShift) % 360)
              .withSaturation((h.saturation + 0.35).clamp(0.0, 0.95))
              .withLightness(dark ? 0.42 : 0.50)
              .toColor();
        }

        final g =
            gradient ??
            LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: [vivid(cs.primary, 0), vivid(cs.primary, 38), vivid(cs.tertiary, 18)],
            );
        final first = g.colors.first;
        final fg =
            foregroundColor ??
            (ThemeData.estimateBrightnessForColor(first) == Brightness.dark ? Colors.white : const Color(0xFF111318));
        return SearchDesignSpec(
          design: design,
          gradient: g,
          foreground: fg,
          hint: fg.withValues(alpha: 0.82),
          fieldFill: fg.withValues(alpha: 0.16),
          fieldBorder: fg.withValues(alpha: 0.24),
          fieldRadius: 22,
          toolbarHeight: height,
        );
      case AppBarSearchDesign.floating:
        return SearchDesignSpec(
          design: design,
          background: Colors.transparent,
          capsule: backgroundColor ?? (dark ? cs.surfaceContainerHigh : cs.surfaceContainerLowest),
          foreground: foregroundColor ?? cs.onSurface,
          hint: cs.onSurfaceVariant,
          fieldFill: Colors.transparent,
          fieldRadius: 0,
          margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          barRadius: BorderRadius.circular(height / 2),
          fieldBorder: cs.outlineVariant.withValues(alpha: dark ? 0.5 : 0.6),
          toolbarHeight: height,
        );
      case AppBarSearchDesign.spotlight:
        return SearchDesignSpec(
          design: design,
          background: backgroundColor ?? appBarBg ?? cs.surface,
          foreground: foregroundColor ?? appBarFg ?? cs.onSurface,
          hint: cs.onSurfaceVariant,
          fieldFill: cs.surfaceContainerHigh,
          fieldBorder: cs.outlineVariant.withValues(alpha: 0.7),
          fieldFocusBorder: cs.primary,
          fieldRadius: 14,
          bottomBorder: cs.outlineVariant.withValues(alpha: 0.5),
          toolbarHeight: height,
        );
    }
  }
}
