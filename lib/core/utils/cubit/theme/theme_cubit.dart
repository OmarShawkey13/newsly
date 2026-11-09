import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsly/core/models/translations.dart';
import 'package:newsly/core/network/local/cache_helper.dart';
import 'package:newsly/core/utils/cubit/theme/theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeInitialState());

  static ThemeCubit get(BuildContext context) => BlocProvider.of(context);

  bool _isDarkMode = false;
  static bool currentIsDarkMode = false;
  static TranslationModel? currentTranslation;

  Future<void> init({
    required bool isDark,
    required bool isArabic,
    required String translations,
  }) async {
    await changeTheme(fromShared: isDark);
    await changeLanguage(isArabic: isArabic, translations: translations);
  }

  bool get isDarkMode => _isDarkMode;

  Future<void> changeTheme({bool? fromShared}) async {
    _isDarkMode = fromShared ?? !_isDarkMode;
    currentIsDarkMode = _isDarkMode;
    emit(ThemeChangeThemeState());
    try {
      await CacheHelper.saveData(key: 'isDark', value: _isDarkMode);
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }

  bool _isArabicLang = false;
  TranslationModel? _translationModel;

  bool get isArabicLang => _isArabicLang;

  Future<void> changeLanguage({
    required bool isArabic,
    required String translations,
  }) async {
    try {
      if (_isArabicLang == isArabic && _translationModel != null) {
        currentTranslation = _translationModel;
        emit(ThemeLanguageUpdatedState());
        return;
      }
      emit(ThemeLanguageLoadingState());
      final model = TranslationModel.fromJson(json.decode(translations));
      _isArabicLang = isArabic;
      _translationModel = model;
      currentTranslation = model;
      emit(ThemeLanguageUpdatedState());
    } catch (e) {
      emit(ThemeLanguageErrorState('error_something_went_wrong'));
    }
  }

  Future<void> toggleLanguage() async {
    try {
      emit(ThemeLanguageLoadingState());
      final newLang = !_isArabicLang;
      final jsonString = await rootBundle.loadString(
        'assets/translations/${newLang ? 'ar' : 'en'}.json',
      );
      _translationModel = TranslationModel.fromJson(json.decode(jsonString));
      _isArabicLang = newLang;
      currentTranslation = _translationModel;
      await CacheHelper.saveData(key: 'isArabicLang', value: _isArabicLang);
      emit(ThemeLanguageUpdatedState());
    } catch (e) {
      emit(ThemeLanguageErrorState('error_something_went_wrong'));
    }
  }
}
