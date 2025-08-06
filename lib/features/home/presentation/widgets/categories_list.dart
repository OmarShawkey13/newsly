import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsly/core/theme/colors.dart';
import 'package:newsly/core/theme/text_styles.dart';
import 'package:newsly/core/utils/constants/spacing.dart';
import 'package:newsly/features/home/presentation/logic/home_cubit.dart';
import 'package:newsly/features/home/presentation/logic/home_states.dart';

List<String> categories = [
  'Business',
  'Entertainment',
  'Health',
  'Science',
  'Sports',
  'Technology',
];

class CategoriesList extends StatelessWidget {
  const CategoriesList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeStates>(
      buildWhen: (previous, current) {
        return current is ChangeSelectedIndexState;
      },
      builder: (context, state) {
        final cubit = HomeCubit.get(context);
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              horizontalSpace16,
              ...categories.map(
                (category) {
                  return Row(
                    children: [
                      ChoiceChip(
                        label: Text(
                          category,
                          style: TextStylesManager.regular16(context).copyWith(
                            color:
                                cubit.selectedIndex ==
                                    categories.indexOf(category)
                                ? ColorsManager.chipSelectedText
                                : (cubit.isDark
                                      ? ColorsManager.chipTextDark
                                      : ColorsManager.chipTextLight),
                          ),
                        ),
                        showCheckmark: false,
                        selected:
                            cubit.selectedIndex == categories.indexOf(category),
                        onSelected: (_) {
                          cubit.selectedIndex = categories.indexOf(category);
                        },
                        selectedColor: cubit.isDark
                            ? ColorsManager.chipSelectedBackgroundDark
                            : ColorsManager.chipSelectedBackgroundLight,
                        backgroundColor: cubit.isDark
                            ? ColorsManager.chipBackgroundDark
                            : ColorsManager.chipBackgroundLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                      ),
                      if (categories.indexOf(category) != categories.length - 1)
                        horizontalSpace8,
                    ],
                  );
                },
              ),
              horizontalSpace16,
            ],
          ),
        );
      },
    );
  }
}
