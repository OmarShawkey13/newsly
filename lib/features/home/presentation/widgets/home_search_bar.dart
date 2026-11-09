import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsly/core/theme/colors.dart';
import 'package:newsly/core/theme/text_styles.dart';
import 'package:newsly/core/utils/cubit/theme/theme_cubit.dart';
import 'package:newsly/core/utils/cubit/theme/theme_state.dart';
import 'package:newsly/features/home/presentation/logic/home_cubit.dart';
import 'package:newsly/features/home/presentation/logic/home_states.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      buildWhen: (_, current) => current is ThemeChangeThemeState,
      builder: (context, _) => BlocBuilder<HomeCubit, HomeStates>(
        buildWhen: (_, current) =>
            current is HomeSearchInputChangedState ||
            current is HomeSearchClearedState,
        builder: (context, _) {
          final cubit = HomeCubit.get(context);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SearchBar(
              controller: cubit.searchController,
              textStyle: WidgetStatePropertyAll(
                TextStylesManager.regular18(context).copyWith(
                  color: ColorsManager.currentTextColor,
                ),
              ),
              onChanged: cubit.searchNewsDebounced,
              overlayColor: const WidgetStatePropertyAll(Colors.transparent),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              backgroundColor: WidgetStatePropertyAll(
                ColorsManager.currentSearchBackgroundColor,
              ),
              elevation: const WidgetStatePropertyAll(0),
              hintStyle: WidgetStatePropertyAll(
                TextStylesManager.regular18(context).copyWith(
                  color: ColorsManager.currentSearchHintColor,
                ),
              ),
              hintText: 'Search articles...',
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                  side: BorderSide(
                    color: ColorsManager.currentSearchBorderColor,
                  ),
                ),
              ),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 12),
              ),
              leading: Icon(
                Icons.search,
                color: ColorsManager.currentSearchIconColor,
              ),
              trailing: cubit.searchController.text.isEmpty
                  ? null
                  : [
                      IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: ColorsManager.currentSearchIconColor,
                        ),
                        onPressed: cubit.clearSearch,
                      ),
                    ],
            ),
          );
        },
      ),
    );
  }
}
