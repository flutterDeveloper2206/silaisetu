import 'package:flutter/material.dart';

/// Shared spacing / radii so every screen aligns the same way.
class SsLayout {
  static const double pageH = 16;
  static const double pageV = 12;
  static const double section = 16;
  static const double item = 12;
  static const double tight = 8;
  static const double radius = 18;
  static const double radiusSm = 12;
  static const double bottomNavClearance = 110;
  static const double fabClearance = 88;

  static const EdgeInsets pagePadding =
      EdgeInsets.fromLTRB(pageH, pageV, pageH, pageV);

  static EdgeInsets pagePaddingBottom([double bottom = bottomNavClearance]) =>
      EdgeInsets.fromLTRB(pageH, pageV, pageH, bottom);

  static const EdgeInsets listPadding =
      EdgeInsets.fromLTRB(pageH, 4, pageH, fabClearance);

  static const EdgeInsets formPadding =
      EdgeInsets.fromLTRB(pageH, pageV, pageH, 32);

  static const EdgeInsets tilePadding =
      EdgeInsets.symmetric(horizontal: 14, vertical: 4);

  /// Primary text on surface backgrounds.
  static Color title(ColorScheme s) => s.onSurface;

  /// Secondary / supporting text — readable on light & dark.
  static Color body(ColorScheme s) => s.onSurface.withValues(alpha: 0.68);

  /// Subtle muted text (hints, captions).
  static Color muted(ColorScheme s) => s.onSurface.withValues(alpha: 0.52);

  /// Text on dark/ink gradient surfaces.
  static Color onInk = Colors.white;
  static Color onInkBody = Colors.white.withValues(alpha: 0.78);
  static Color onInkMuted = Colors.white.withValues(alpha: 0.58);

  static TextStyle titleStyle(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Theme.of(context).textTheme.titleMedium!.copyWith(
          color: title(s),
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        );
  }

  static TextStyle bodyStyle(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: body(s),
          height: 1.35,
        );
  }

  static TextStyle captionStyle(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Theme.of(context).textTheme.bodySmall!.copyWith(
          color: muted(s),
          height: 1.3,
        );
  }
}
