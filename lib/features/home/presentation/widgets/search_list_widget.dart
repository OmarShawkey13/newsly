import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsly/core/theme/colors.dart';
import 'package:newsly/core/theme/text_styles.dart';
import 'package:newsly/core/utils/constants/constants.dart';
import 'package:newsly/core/utils/constants/primary/conditional_builder.dart';
import 'package:newsly/core/utils/constants/spacing.dart';
import 'package:newsly/core/utils/cubit/theme/theme_cubit.dart';
import 'package:newsly/core/utils/cubit/theme/theme_state.dart';
import 'package:newsly/features/home/presentation/logic/home_cubit.dart';
import 'package:newsly/features/home/presentation/logic/home_states.dart';
import 'package:newsly/features/home/presentation/widgets/article_card.dart';
import 'package:newsly/features/home/presentation/widgets/loading_search_list_widget.dart';

class SearchListWidget extends StatelessWidget {
  const SearchListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      buildWhen: (_, current) =>
          current is ThemeChangeThemeState ||
          current is ThemeLanguageUpdatedState,
      builder: (context, _) => BlocBuilder<HomeCubit, HomeStates>(
        buildWhen: (_, current) =>
            current is HomeLoadingState ||
            current is HomeErrorState ||
            current is HomeSuccessState,
        builder: (context, state) {
          final cubit = HomeCubit.get(context);
          final articles = cubit.searchModel?.articles ?? const [];
          final errorMessage = state is HomeErrorState ? state.error : null;

          return ConditionalBuilder(
            loadingState: state is HomeLoadingState,
            errorState: state is HomeErrorState,
            emptyState: state is HomeSuccessState && articles.isEmpty,
            loadingBuilder: (_) => const LoadingSearchListWidget(),
            errorBuilder: (context) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_off_outlined,
                      size: 40,
                      color: ColorsManager.currentColorScheme.error,
                    ),
                    verticalSpace12,
                    Text(
                      appTranslation().get(
                        errorMessage ?? 'error_something_went_wrong',
                      ),
                      textAlign: TextAlign.center,
                      style: TextStylesManager.regular16.copyWith(
                        color: ColorsManager.currentTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            emptyBuilder: (context) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.newspaper_outlined,
                      size: 40,
                      color: ColorsManager.currentColorScheme.primary,
                    ),
                    verticalSpace12,
                    Text(
                      appTranslation().get('empty_articles'),
                      textAlign: TextAlign.center,
                      style: TextStylesManager.regular16.copyWith(
                        color: ColorsManager.currentSubtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            successBuilder: (context) => ListView.separated(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
              itemBuilder: (context, index) => ArticleCard(
                article: articles[index],
              ),
              separatorBuilder: (context, index) => verticalSpace12,
              itemCount: articles.length,
            ),
          );
        },
      ),
    );
  }
}
