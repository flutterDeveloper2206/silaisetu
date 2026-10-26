import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// SilaiSetu visual system — monochrome with soft ink gradients & glass opacity.
class AppColors {
  static const ink = Color(0xFF0B0B0C);
  static const inkSoft = Color(0xFF1C1C1E);
  static const paper = Color(0xFFF7F6F3);
  static const paperElevated = Color(0xFFFFFFFF);
  static const mist = Color(0xFFE8E6E1);
  static const charcoal = Color(0xFF3A3A3C);
  static const accentWarm = Color(0xFFC4A574); // subtle tailor-gold accent
  static const accentCool = Color(0xFF6B7C85); // slate stitch accent
}

class SsGradients extends ThemeExtension<SsGradients> {
  const SsGradients({
    required this.hero,
    required this.card,
    required this.accentCard,
    required this.navGlow,
    required this.scaffoldWash,
  });

  final Gradient hero;
  final Gradient card;
  final Gradient accentCard;
  final Gradient navGlow;
  final Gradient scaffoldWash;

  static SsGradients light() => SsGradients(
        hero: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF141416),
            Color(0xFF2A2A2E),
            Color(0xFF1A1A1C),
          ],
          stops: [0.0, 0.55, 1.0],
        ),
        card: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.92),
            AppColors.mist.withValues(alpha: 0.75),
            Colors.white.withValues(alpha: 0.88),
          ],
        ),
        accentCard: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.ink.withValues(alpha: 0.95),
            AppColors.charcoal.withValues(alpha: 0.9),
            AppColors.inkSoft.withValues(alpha: 0.92),
          ],
        ),
        navGlow: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: 0.85),
          ],
        ),
        scaffoldWash: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF7F6F3),
            Color(0xFFEFEDE8),
            Color(0xFFF7F6F3),
          ],
        ),
      );

  static SsGradients dark() => SsGradients(
        hero: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A1C),
            Color(0xFF2C2C30),
            Color(0xFF121214),
          ],
        ),
        card: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF222226).withValues(alpha: 0.92),
            const Color(0xFF18181B).withValues(alpha: 0.88),
            const Color(0xFF25252A).withValues(alpha: 0.9),
          ],
        ),
        accentCard: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.14),
            Colors.white.withValues(alpha: 0.06),
            AppColors.accentWarm.withValues(alpha: 0.12),
          ],
        ),
        navGlow: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.0),
            Colors.black.withValues(alpha: 0.55),
          ],
        ),
        scaffoldWash: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0E0E10),
            Color(0xFF141418),
            Color(0xFF0E0E10),
          ],
        ),
      );

  @override
  SsGradients copyWith({
    Gradient? hero,
    Gradient? card,
    Gradient? accentCard,
    Gradient? navGlow,
    Gradient? scaffoldWash,
  }) {
    return SsGradients(
      hero: hero ?? this.hero,
      card: card ?? this.card,
      accentCard: accentCard ?? this.accentCard,
      navGlow: navGlow ?? this.navGlow,
      scaffoldWash: scaffoldWash ?? this.scaffoldWash,
    );
  }

  @override
  SsGradients lerp(ThemeExtension<SsGradients>? other, double t) {
    if (other is! SsGradients) return this;
    return t < 0.5 ? this : other;
  }
}

extension SsThemeX on BuildContext {
  SsGradients get gradients =>
      Theme.of(this).extension<SsGradients>() ?? SsGradients.light();
}

class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.light(
      primary: AppColors.ink,
      onPrimary: AppColors.paperElevated,
      secondary: AppColors.charcoal,
      onSecondary: AppColors.paper,
      tertiary: AppColors.accentWarm,
      onTertiary: AppColors.ink,
      surface: AppColors.paper,
      onSurface: AppColors.ink,
      surfaceContainerHighest: AppColors.mist,
      outline: AppColors.charcoal.withValues(alpha: 0.2),
      error: const Color(0xFFB91C1C),
    );
    return _base(scheme, Brightness.light, SsGradients.light());
  }

  static ThemeData dark() {
    final scheme = ColorScheme.dark(
      primary: AppColors.paperElevated,
      onPrimary: AppColors.ink,
      secondary: const Color(0xFFD4D4D8),
      onSecondary: AppColors.ink,
      tertiary: AppColors.accentWarm,
      onTertiary: AppColors.ink,
      surface: const Color(0xFF0E0E10),
      onSurface: const Color(0xFFF4F4F5),
      surfaceContainerHighest: const Color(0xFF1C1C20),
      outline: Colors.white.withValues(alpha: 0.14),
      error: const Color(0xFFF87171),
    );
    return _base(scheme, Brightness.dark, SsGradients.dark());
  }

  static ThemeData _base(
    ColorScheme scheme,
    Brightness brightness,
    SsGradients gradients,
  ) {
    final baseText = brightness == Brightness.dark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;
    final text = GoogleFonts.dmSansTextTheme(baseText).apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: text,
      extensions: [gradients],
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scheme.surface.withValues(alpha: 0.94),
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: scheme.onSurface),
        actionsIconTheme: IconThemeData(color: scheme.onSurface),
        titleTextStyle: GoogleFonts.fraunces(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
          letterSpacing: -0.3,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: scheme.surface.withValues(alpha: 0.92),
        indicatorColor: scheme.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: scheme.onSurface.withValues(alpha: selected ? 1 : 0.55),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: scheme.onSurface.withValues(alpha: selected ? 1 : 0.55),
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface.withValues(alpha: 0.7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(64, 52),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle:
              GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          minimumSize: const Size(64, 52),
          side: BorderSide(color: scheme.outline),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.72),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outline.withValues(alpha: 0.35),
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.primary,
        contentTextStyle: TextStyle(color: scheme.onPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
