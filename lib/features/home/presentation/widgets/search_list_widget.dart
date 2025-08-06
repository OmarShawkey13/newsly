import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsly/core/theme/colors.dart';
import 'package:newsly/core/theme/text_styles.dart';
import 'package:newsly/core/utils/constants/spacing.dart';
import 'package:newsly/features/home/data/models/article_model.dart';
import 'package:newsly/features/home/presentation/logic/home_cubit.dart';
import 'package:newsly/features/home/presentation/logic/home_states.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SearchListWidget extends StatelessWidget {
  const SearchListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeStates>(
      buildWhen: (previous, current) {
        return current is HomeLoadingState ||
            current is HomeErrorState ||
            current is HomeSuccessState;
      },
      builder: (context, state) {
        final cubit = HomeCubit.get(context);

        if (state is HomeLoadingState) {
          return const LoadingSearchListWidget();
        }

        if (state is HomeErrorState) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                state.error,
                textAlign: TextAlign.center,
                style: TextStylesManager.regular16(context).copyWith(
                  color: cubit.isDark
                      ? ColorsManager.textColorDark
                      : ColorsManager.textColor,
                ),
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemBuilder: (context, index) {
            final ArticleModel? article = cubit.searchModel?.articles?[index];

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120.0,
                  height: 120.0,
                  decoration: BoxDecoration(
                    color: cubit.isDark
                        ? ColorsManager.primaryDarkColor
                        : ColorsManager.primaryColor,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
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
                        style: TextStylesManager.regular16(context).copyWith(
                          color: cubit.isDark
                              ? ColorsManager.textColorDark
                              : ColorsManager.textColor,
                        ),
                      ),
                      verticalSpace8,
                      Text(
                        article?.description?.trim() ?? 'No Description',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStylesManager.regular14(context).copyWith(
                          color: cubit.isDark
                              ? ColorsManager.subtitleColorDark
                              : ColorsManager.subtitleColor,
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
        );
      },
    );
  }
}

class LoadingSearchListWidget extends StatelessWidget {
  const LoadingSearchListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemBuilder: (context, index) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Skeleton.leaf(
                child: Container(
                  width: 120.0,
                  height: 120.0,
                  decoration: BoxDecoration(
                    color: ColorsManager.primaryColor,
                    borderRadius: BorderRadius.circular(20.0),
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
                      style: TextStylesManager.regular16(context),
                    ),
                    verticalSpace8,
                    Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStylesManager.regular14(context).copyWith(
                        color: ColorsManager.textColor.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        separatorBuilder: (context, index) {
          return verticalSpace16;
        },
        itemCount: 10,
      ),
    );
  }
}
