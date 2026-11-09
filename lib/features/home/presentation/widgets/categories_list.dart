import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsly/core/utils/constants/constants.dart';
import 'package:newsly/core/utils/constants/spacing.dart';
import 'package:newsly/core/utils/cubit/theme/theme_cubit.dart';
import 'package:newsly/core/utils/cubit/theme/theme_state.dart';
import 'package:newsly/features/home/logic/home_categories.dart';
import 'package:newsly/features/home/presentation/logic/home_cubit.dart';
import 'package:newsly/features/home/presentation/logic/home_states.dart';

class CategoriesList extends StatelessWidget {
  const CategoriesList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      buildWhen: (_, current) =>
          current is ThemeChangeThemeState ||
          current is ThemeLanguageUpdatedState,
      builder: (context, _) => BlocBuilder<HomeCubit, HomeStates>(
        buildWhen: (_, current) => current is ChangeSelectedIndexState,
        builder: (context, _) {
          final cubit = HomeCubit.get(context);

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                horizontalSpace20,
                ...categories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final category = entry.value;

                  return Row(
                    children: [
                      ChoiceChip(
                        label: Text(
                          appTranslation().get(
                            'category_${category.toLowerCase()}',
                          ),
                        ),
                        selected: cubit.selectedIndex == index,
                        onSelected: (_) => cubit.selectedIndex = index,
                      ),
                      if (index != categories.length - 1) horizontalSpace8,
                    ],
                  );
                }),
                horizontalSpace20,
              ],
            ),
          );
        },
      ),
    );
  }
}
