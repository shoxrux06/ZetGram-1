import 'package:flutter/material.dart';

const String kMono = 'PlexMono';

/// The app's colour tokens, mirrored from the web version for light and dark.
@immutable
class Palette extends ThemeExtension<Palette> {
  const Palette({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.ink,
    required this.muted,
    required this.line,
    required this.accent,
    required this.accentInk,
    required this.accentSoft,
    required this.known,
    required this.knownSoft,
    required this.learn,
    required this.learnSoft,
    required this.shadow,
  });

  final Color bg;
  final Color surface;
  final Color surface2;
  final Color ink;
  final Color muted;
  final Color line;
  final Color accent;
  final Color accentInk;
  final Color accentSoft;
  final Color known;
  final Color knownSoft;
  final Color learn;
  final Color learnSoft;
  final Color shadow;

  static const light = Palette(
    bg: Color(0xFFECEFF3),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF4F6F9),
    ink: Color(0xFF121A23),
    muted: Color(0xFF5A6674),
    line: Color(0xFFD3DAE2),
    accent: Color(0xFF2E4FD8),
    accentInk: Color(0xFFFFFFFF),
    accentSoft: Color(0xFFE0E6FB),
    known: Color(0xFF15784A),
    knownSoft: Color(0xFFDAF0E3),
    learn: Color(0xFFA85606),
    learnSoft: Color(0xFFFAE8D0),
    shadow: Color(0x38121A23),
  );

  static const dark = Palette(
    bg: Color(0xFF0E131A),
    surface: Color(0xFF161D26),
    surface2: Color(0xFF1C2531),
    ink: Color(0xFFE5EAF1),
    muted: Color(0xFF93A0AF),
    line: Color(0xFF2A3542),
    accent: Color(0xFF8197FF),
    accentInk: Color(0xFF0B1020),
    accentSoft: Color(0xFF232D52),
    known: Color(0xFF53C98D),
    knownSoft: Color(0xFF16352A),
    learn: Color(0xFFF2A851),
    learnSoft: Color(0xFF3A2913),
    shadow: Color(0x99000000),
  );


  @override
  Palette copyWith({
    Color? bg,
    Color? surface,
    Color? surface2,
    Color? ink,
    Color? muted,
    Color? line,
    Color? accent,
    Color? accentInk,
    Color? accentSoft,
    Color? known,
    Color? knownSoft,
    Color? learn,
    Color? learnSoft,
    Color? shadow,
  }) =>
      Palette(
        bg: bg ?? this.bg,
        surface: surface ?? this.surface,
        surface2: surface2 ?? this.surface2,
        ink: ink ?? this.ink,
        muted: muted ?? this.muted,
        line: line ?? this.line,
        accent: accent ?? this.accent,
        accentInk: accentInk ?? this.accentInk,
        accentSoft: accentSoft ?? this.accentSoft,
        known: known ?? this.known,
        knownSoft: knownSoft ?? this.knownSoft,
        learn: learn ?? this.learn,
        learnSoft: learnSoft ?? this.learnSoft,
        shadow: shadow ?? this.shadow,
      );

  @override
  Palette lerp(Palette? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return Palette(
      bg: l(bg, other.bg),
      surface: l(surface, other.surface),
      surface2: l(surface2, other.surface2),
      ink: l(ink, other.ink),
      muted: l(muted, other.muted),
      line: l(line, other.line),
      accent: l(accent, other.accent),
      accentInk: l(accentInk, other.accentInk),
      accentSoft: l(accentSoft, other.accentSoft),
      known: l(known, other.known),
      knownSoft: l(knownSoft, other.knownSoft),
      learn: l(learn, other.learn),
      learnSoft: l(learnSoft, other.learnSoft),
      shadow: l(shadow, other.shadow),
    );
  }
}

ThemeData buildTheme(Palette p, Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: p.accent, brightness: brightness).copyWith(
    primary: p.accent,
    onPrimary: p.accentInk,
    surface: p.surface,
    onSurface: p.ink,
    outline: p.line,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: p.bg,
    canvasColor: p.surface,
    dividerColor: p.line,
    extensions: [p],
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: p.ink,
      contentTextStyle: TextStyle(color: p.bg, fontSize: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: p.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: p.line),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.bg,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: p.line,
    ),
    dialogTheme: DialogThemeData(backgroundColor: p.surface, surfaceTintColor: Colors.transparent),
  );
}

extension PaletteX on BuildContext {
  Palette get palette => Theme.of(this).extension<Palette>()!;
}
