import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsly/core/theme/colors.dart';
import 'package:newsly/core/theme/text_styles.dart';
import 'package:newsly/core/utils/constants/spacing.dart';
import 'package:newsly/core/utils/cubit/theme/theme_cubit.dart';
import 'package:newsly/core/utils/cubit/theme/theme_state.dart';
import 'package:skeletonizer/skeletonizer.dart';

class LoadingSearchListWidget extends StatelessWidget {
  const LoadingSearchListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      buildWhen: (_, current) => current is ThemeChangeThemeState,
      builder: (context, _) => Skeletonizer(
        enabled: true,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Skeleton.leaf(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: ColorsManager.currentPrimaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              horizontalSpace16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStylesManager.regular16,
                    ),
                    verticalSpace8,
                    Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStylesManager.regular14.copyWith(
                        color: ColorsManager.currentTextColor.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          separatorBuilder: (context, index) => verticalSpace16,
          itemCount: 10,
        ),
      ),
    );
  }
}
