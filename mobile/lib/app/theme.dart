import 'package:flutter/material.dart';

/// Clinical-grade theming.
///
/// Goals (per PRD §UX + AGENTS.md §Accessibility):
///  * High contrast for surgical lighting glare.
///  * Minimum 44pt touch targets — nurses wear gloves.
///  * Text scales to 200% without breaking layouts.
///  * Material 3 with restrained palette; clinical, not playful.
class AppTheme {
  const AppTheme._();

  /// 4.5:1 contrast against white background.
  static const Color _brandPrimary = Color(0xFF005A7A);

  /// Highlight for confirmed / high-confidence events.
  static const Color _signalGreen = Color(0xFF1E7F3F);

  /// Yellow warning band (medium confidence).
  static const Color _signalAmber = Color(0xFFB75D00);

  /// Red rejection / low confidence — 4.5:1 against white.
  static const Color _signalRed = Color(0xFFB3261E);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: _brandPrimary).copyWith(
      error: _signalRed,
      tertiary: _signalGreen,
      secondary: _signalAmber,
    );
    return _build(scheme, Brightness.light);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _brandPrimary,
      brightness: Brightness.dark,
    ).copyWith(
      error: _signalRed,
      tertiary: _signalGreen,
      secondary: _signalAmber,
    );
    return _build(scheme, Brightness.dark);
  }

  static ThemeData _build(ColorScheme scheme, Brightness brightness) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      brightness: brightness,
    );

    return base.copyWith(
      // 44pt minimum across all standard buttons.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),

      textTheme: base.textTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
    );
  }

  /// Confidence color helper. Used by event cards.
  static Color confidenceColor(
    BuildContext context, {
    required double confidence,
  }) {
    final scheme = Theme.of(context).colorScheme;
    if (confidence >= 0.9) return scheme.tertiary;
    if (confidence >= 0.7) return scheme.secondary;
    return scheme.error;
  }
}
