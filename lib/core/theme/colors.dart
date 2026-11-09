import 'package:flutter/material.dart';
import 'package:newsly/core/utils/cubit/theme/theme_cubit.dart';

class ColorsManager {
  static bool get isDark => ThemeCubit.currentIsDarkMode;

  // Primary Colors
  static const Color primaryColor = Color(0xFF1A73E8); // News blue
  static const Color primaryDarkColor = Color(0xFF0D47A1); // Darker news blue
  static Color get currentPrimaryColor =>
      isDark ? primaryDarkColor : primaryColor;

  // Backgrounds
  static const Color scaffoldBackgroundColor = Color(0xFFF9F9F9);
  static const Color scaffoldDarkBackgroundColor = Color(0xFF121212);
  static Color get currentScaffoldBackgroundColor =>
      isDark ? scaffoldDarkBackgroundColor : scaffoldBackgroundColor;

  // Cards
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color cardColorDark = Color(0xFF1E1E1E);

  // Text
  static const Color textColor = Color(0xFF202124);
  static const Color textColorDark = Color(0xFFE8EAED);
  static Color get currentTextColor => isDark ? textColorDark : textColor;

  // Subtitles
  static const Color subtitleColor = Color(0xFF5F6368);
  static const Color subtitleColorDark = Color(0xFFB0B0B0);
  static Color get currentSubtitleColor =>
      isDark ? subtitleColorDark : subtitleColor;

  // Neutrals
  static const Color gray = Color(0xFF9E9E9E);
  static const Color darkGray = Color(0xFF616161);
  static const Color lightGray = Color(0xFFEEEEEE);

  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color blackColor = Color(0xFF000000);

  // Search Bar Colors
  static const Color searchBackground = Color(
    0xFFF1F3F4,
  ); // Light theme background
  static const Color searchBackgroundDark = Color(
    0xFF1C1C1E,
  ); // Dark theme background
  static Color get currentSearchBackgroundColor =>
      isDark ? searchBackgroundDark : searchBackground;

  static const Color searchBorder = Color(0xFFCED4DA);
  static const Color searchBorderDark = Color(0xFF2C2C2E);
  static Color get currentSearchBorderColor =>
      isDark ? searchBorderDark : searchBorder;

  static const Color searchIconColor = Color(0xFF5F6368);
  static const Color searchIconColorDark = Color(0xFFB0B0B0);
  static Color get currentSearchIconColor =>
      isDark ? searchIconColorDark : searchIconColor;

  static const Color searchHintText = Color(0xFF9E9E9E);
  static const Color searchHintTextDark = Color(0xFF8E8E93);
  static Color get currentSearchHintColor =>
      isDark ? searchHintTextDark : searchHintText;

  // Chips
  static const Color chipBackgroundLight = Color(0xFFE0E0E0); // Light gray
  static const Color chipBackgroundDark = Color(0xFF2C2C2E); // Dark gray
  static Color get currentChipBackgroundColor =>
      isDark ? chipBackgroundDark : chipBackgroundLight;

  static const Color chipSelectedBackgroundLight = primaryColor;
  static const Color chipSelectedBackgroundDark = primaryDarkColor;
  static Color get currentChipSelectedBackgroundColor =>
      isDark ? chipSelectedBackgroundDark : chipSelectedBackgroundLight;

  static const Color chipTextLight = textColor;
  static const Color chipTextDark = textColorDark;
  static Color get currentChipTextColor =>
      isDark ? chipTextDark : chipTextLight;

  static const Color chipSelectedText = whiteColor;
}
