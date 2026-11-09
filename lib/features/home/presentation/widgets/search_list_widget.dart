import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsly/core/models/article_model.dart';
import 'package:newsly/core/theme/colors.dart';
import 'package:newsly/core/theme/text_styles.dart';
import 'package:newsly/core/utils/constants/constants.dart';
import 'package:newsly/core/utils/constants/primary/conditional_builder.dart';
import 'package:newsly/core/utils/constants/spacing.dart';
import 'package:newsly/core/utils/cubit/theme/theme_cubit.dart';
import 'package:newsly/core/utils/cubit/theme/theme_state.dart';
import 'package:newsly/features/home/presentation/logic/home_cubit.dart';
import 'package:newsly/features/home/presentation/logic/home_states.dart';
import 'package:newsly/features/home/presentation/widgets/loading_search_list_widget.dart';

class SearchListWidget extends StatelessWidget {
  const SearchListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      buildWhen: (_, current) => current is ThemeChangeThemeState,
      builder: (context, _) => BlocBuilder<HomeCubit, HomeStates>(
        buildWhen: (_, current) =>
            current is HomeLoadingState ||
            current is HomeErrorState ||
            current is HomeSuccessState,
        builder: (context, state) {
          final cubit = HomeCubit.get(context);
          final errorMessage = state is HomeErrorState ? state.error : null;

          return ConditionalBuilder(
            loadingState: state is HomeLoadingState,
            errorState: state is HomeErrorState,
            emptyState:
                state is HomeSuccessState &&
                (cubit.searchModel?.articles?.isEmpty ?? true),
            loadingBuilder: (_) => const LoadingSearchListWidget(),
            errorBuilder: (context) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  appTranslation().get(
                    errorMessage ?? 'error_something_went_wrong',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStylesManager.regular16.copyWith(
                    color: ColorsManager.currentTextColor,
                  ),
                ),
              ),
            ),
            emptyBuilder: (context) => Center(
              child: Text(
                appTranslation().get('empty_articles'),
                style: TextStylesManager.regular16.copyWith(
                  color: ColorsManager.currentSubtitleColor,
                ),
              ),
            ),
            successBuilder: (context) => ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final ArticleModel? article =
                    cubit.searchModel?.articles?[index];

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: ColorsManager.currentPrimaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(
                          imageUrl: article?.urlToImage ?? '',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.red,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                    horizontalSpace16,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article?.title ?? 'No Title',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStylesManager.regular16.copyWith(
                              color: ColorsManager.currentTextColor,
                            ),
                          ),
                          verticalSpace8,
                          Text(
                            article?.description?.trim() ?? 'No Description',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStylesManager.regular14.copyWith(
                              color: ColorsManager.currentSubtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              separatorBuilder: (context, index) => verticalSpace16,
              itemCount: cubit.searchModel?.articles?.length ?? 0,
            ),
          );
        },
      ),
    );
  }
}
