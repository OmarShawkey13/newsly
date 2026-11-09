import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsly/core/theme/colors.dart';
import 'package:newsly/core/theme/text_styles.dart';
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
      buildWhen: (_, current) => current is ThemeChangeThemeState,
      builder: (context, _) => BlocBuilder<HomeCubit, HomeStates>(
        buildWhen: (_, current) => current is ChangeSelectedIndexState,
        builder: (context, _) {
          final cubit = HomeCubit.get(context);

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                horizontalSpace16,
                ...categories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final category = entry.value;
                  final isSelected = cubit.selectedIndex == index;

                  return Row(
                    children: [
                      ChoiceChip(
                        label: Text(
                          category,
                          style: TextStylesManager.regular16.copyWith(
                            color: isSelected
                                ? ColorsManager.chipSelectedText
                                : ColorsManager.currentChipTextColor,
                          ),
                        ),
                        showCheckmark: false,
                        selected: isSelected,
                        onSelected: (_) => cubit.selectedIndex = index,
                        selectedColor:
                            ColorsManager.currentChipSelectedBackgroundColor,
                        backgroundColor:
                            ColorsManager.currentChipBackgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      if (index != categories.length - 1) horizontalSpace8,
                    ],
                  );
                }),
                horizontalSpace16,
              ],
            ),
          );
        },
      ),
    );
  }
}
