import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsly/core/di/injections.dart';
import 'package:newsly/core/network/local/cache_helper.dart';
import 'package:newsly/core/theme/theme.dart';
import 'package:newsly/core/theme/theme_reveal_controller.dart';
import 'package:newsly/core/theme/theme_reveal_overlay.dart';
import 'package:newsly/core/utils/constants/routes.dart';
import 'package:newsly/core/utils/constants/my_bloc_observer.dart';
import 'package:newsly/core/utils/cubit/theme/theme_cubit.dart';
import 'package:newsly/core/utils/cubit/theme/theme_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initInjections();
  Bloc.observer = MyBlocObserver();
  final bool isDark = await CacheHelper.getData(key: 'isDark') ?? false;
  final bool isArabic = CacheHelper.getData(key: 'isArabicLang') ?? false;
  final String translations = await rootBundle.loadString(
    'assets/translations/${isArabic ? 'ar' : 'en'}.json',
  );
  runApp(
    MyApp(
      isDark: isDark,
      isArabic: isArabic,
      translations: translations,
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isDark;
  final bool isArabic;
  final String translations;

  const MyApp({
    super.key,
    required this.isDark,
    required this.isArabic,
    required this.translations,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ThemeCubit>()
        ..init(
          isDark: isDark,
          isArabic: isArabic,
          translations: translations,
        ),
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            routes: Routes.routes,
            initialRoute: Routes.home,
            debugShowCheckedModeBanner: false,
            theme: ThemesManager.lightTheme,
            darkTheme: ThemesManager.darkTheme,
            themeMode: ThemeCubit.get(context).isDarkMode ? .dark : .light,
            themeAnimationDuration: Duration.zero,
            builder: (context, child) {
              return ThemeRevealOverlay(
                controller: sl<ThemeRevealController>(),
                child: Directionality(
                  textDirection: ThemeCubit.get(context).isArabicLang
                      ? .rtl
                      : .ltr,
                  child: child!,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
