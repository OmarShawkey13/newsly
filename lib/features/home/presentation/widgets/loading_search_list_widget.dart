import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsly/core/theme/colors.dart';
import 'package:newsly/core/theme/text_styles.dart';
import 'package:newsly/core/utils/constants/constants.dart';
import 'package:newsly/core/utils/constants/spacing.dart';
import 'package:newsly/core/utils/cubit/theme/theme_cubit.dart';
import 'package:newsly/core/utils/cubit/theme/theme_state.dart';
import 'package:skeletonizer/skeletonizer.dart';

class LoadingSearchListWidget extends StatelessWidget {
  const LoadingSearchListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      buildWhen: (_, current) =>
          current is ThemeChangeThemeState ||
          current is ThemeLanguageUpdatedState,
      builder: (context, _) => Skeletonizer(
        enabled: true,
        child: ListView.separated(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 20),
          itemBuilder: (context, index) => Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeleton.leaf(
                    child: Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        color: ColorsManager
                            .currentColorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                  horizontalSpace12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appTranslation().get('untitled_article'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStylesManager.semiBold16,
                        ),
                        verticalSpace8,
                        Text(
                          appTranslation().get('no_description'),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStylesManager.regular13.copyWith(
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
            ),
          ),
          separatorBuilder: (context, index) => verticalSpace16,
          itemCount: 8,
        ),
      ),
    );
  }
}
