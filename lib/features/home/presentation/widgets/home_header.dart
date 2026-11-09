import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsly/core/theme/colors.dart';
import 'package:newsly/core/theme/text_styles.dart';
import 'package:newsly/core/utils/cubit/theme/theme_cubit.dart';
import 'package:newsly/core/utils/cubit/theme/theme_state.dart';

class HomeHeader extends StatelessWidget implements PreferredSizeWidget {
  const HomeHeader({super.key});

  static const double toolbarHeight = 80;

  @override
  Size get preferredSize => const Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      buildWhen: (_, current) => current is ThemeChangeThemeState,
      builder: (context, _) => AppBar(
        toolbarHeight: toolbarHeight,
        automaticallyImplyLeading: false,
        backgroundColor: ColorsManager.currentScaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hello, Omar 👋',
              style: TextStylesManager.bold20.copyWith(
                color: ColorsManager.currentTextColor,
              ),
            ),
            Text(
              'Search Your Daily News',
              style: TextStylesManager.regular16.copyWith(
                color: ColorsManager.currentSubtitleColor,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              ColorsManager.isDark ? Icons.light_mode : Icons.dark_mode,
              color: ColorsManager.currentTextColor,
            ),
            onPressed: () => ThemeCubit.get(context).changeTheme(),
          ),
          const Padding(
            padding: EdgeInsetsDirectional.only(end: 16),
            child: CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage(
                'https://avatars.githubusercontent.com/u/81522507?v=4',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
