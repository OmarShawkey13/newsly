import 'package:flutter/material.dart';
import 'package:newsly/core/theme/colors.dart';
import 'package:newsly/core/theme/text_styles.dart';

class ThemesManager {
  static ThemeData lightTheme(BuildContext context) => ThemeData(
    useMaterial3: true,
    primaryColor: ColorsManager.primaryColor,
    scaffoldBackgroundColor: ColorsManager.scaffoldBackgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: ColorsManager.primaryColor,
      titleTextStyle: TextStylesManager.bold20(context).copyWith(
        color: ColorsManager.textColorDark,
      ),
      iconTheme: const IconThemeData(color: ColorsManager.textColorDark),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStylesManager.regular14(context).copyWith(
        color: ColorsManager.textColor,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorsManager.cardColor,
        foregroundColor: ColorsManager.textColor,
        textStyle: TextStylesManager.bold14(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ColorsManager.whiteColor,
      hintStyle: TextStylesManager.regular12(context).copyWith(
        color: ColorsManager.subtitleColor,
      ),
      labelStyle: TextStylesManager.regular14(context).copyWith(
        color: ColorsManager.textColor,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ColorsManager.gray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: ColorsManager.primaryColor,
          width: 2,
        ),
      ),
    ),
  );

  static ThemeData darkTheme(BuildContext context) => ThemeData(
    useMaterial3: true,
    primaryColor: ColorsManager.primaryDarkColor,
    scaffoldBackgroundColor: ColorsManager.scaffoldDarkBackgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: ColorsManager.primaryDarkColor,
      titleTextStyle: TextStylesManager.bold20(context).copyWith(
        color: ColorsManager.textColorDark,
      ),
      iconTheme: const IconThemeData(color: ColorsManager.textColorDark),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStylesManager.regular14(context).copyWith(
        color: ColorsManager.textColorDark,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorsManager.cardColorDark,
        foregroundColor: ColorsManager.textColorDark,
        textStyle: TextStylesManager.bold14(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ColorsManager.primaryDarkColor.withValues(alpha: 0.1),
      hintStyle: TextStylesManager.regular12(context).copyWith(
        color: ColorsManager.subtitleColorDark,
      ),
      labelStyle: TextStylesManager.regular14(context).copyWith(
        color: ColorsManager.textColorDark,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ColorsManager.darkGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: ColorsManager.primaryDarkColor,
          width: 2,
        ),
      ),
    ),
  );
}
