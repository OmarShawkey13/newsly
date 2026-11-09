import 'package:flutter/material.dart';
import 'package:newsly/core/utils/cubit/theme/theme_cubit.dart';

class ColorsManager {
  static const Color brandSeed = Color(0xFF315F9F);

  static final ColorScheme lightColorScheme = ColorScheme.fromSeed(
    seedColor: brandSeed,
    brightness: Brightness.light,
  );

  static final ColorScheme darkColorScheme = ColorScheme.fromSeed(
    seedColor: brandSeed,
    brightness: Brightness.dark,
  );

  static bool get isDark => ThemeCubit.currentIsDarkMode;

  static ColorScheme get currentColorScheme =>
      isDark ? darkColorScheme : lightColorScheme;

  static Color get currentTextColor => currentColorScheme.onSurface;
  static Color get currentSubtitleColor => currentColorScheme.onSurfaceVariant;
}
