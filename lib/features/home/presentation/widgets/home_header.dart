import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsly/core/theme/colors.dart';
import 'package:newsly/core/theme/text_styles.dart';
import 'package:newsly/core/utils/constants/constants.dart';
import 'package:newsly/core/utils/cubit/theme/theme_cubit.dart';
import 'package:newsly/core/utils/cubit/theme/theme_state.dart';

class HomeHeader extends StatelessWidget implements PreferredSizeWidget {
  const HomeHeader({super.key});

  static const double toolbarHeight = 84;

  @override
  Size get preferredSize => const Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      buildWhen: (_, current) =>
          current is ThemeChangeThemeState ||
          current is ThemeLanguageUpdatedState,
      builder: (context, _) => AppBar(
        toolbarHeight: toolbarHeight,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              appTranslation().get('home_title'),
              style: TextStylesManager.bold22.copyWith(
                color: ColorsManager.currentTextColor,
              ),
            ),
            Text(
              appTranslation().get('home_subtitle'),
              style: TextStylesManager.regular14.copyWith(
                color: ColorsManager.currentSubtitleColor,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: appTranslation().get('toggle_language'),
            onPressed: () => ThemeCubit.get(context).toggleLanguage(),
            icon: const Icon(Icons.translate_rounded),
          ),
          IconButton(
            tooltip: appTranslation().get('toggle_theme'),
            onPressed: () => ThemeCubit.get(context).changeTheme(),
            icon: Icon(
              ColorsManager.isDark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
          ),
          const Padding(
            padding: EdgeInsetsDirectional.only(start: 4, end: 16),
            child: Icon(Icons.newspaper_rounded, size: 26),
          ),
        ],
      ),
    );
  }
}
