import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:newsly/core/models/article_model.dart';
import 'package:newsly/core/theme/colors.dart';
import 'package:newsly/core/theme/text_styles.dart';
import 'package:newsly/core/utils/constants/constants.dart';
import 'package:newsly/core/utils/constants/spacing.dart';

class ArticleCard extends StatelessWidget {
  final ArticleModel article;

  const ArticleCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final imageUrl = article.urlToImage?.trim() ?? '';
    final colorScheme = ColorsManager.currentColorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 112,
                height: 112,
                color: colorScheme.surfaceContainerHighest,
                child: imageUrl.isEmpty
                    ? Icon(
                        Icons.article_outlined,
                        color: colorScheme.onSurfaceVariant,
                        size: 32,
                      )
                    : CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.broken_image_outlined,
                          color: colorScheme.error,
                          size: 32,
                        ),
                      ),
              ),
            ),
            horizontalSpace12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title?.trim().isNotEmpty == true
                        ? article.title!.trim()
                        : appTranslation().get('untitled_article'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStylesManager.bold16.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  verticalSpace8,
                  Text(
                    article.description?.trim().isNotEmpty == true
                        ? article.description!.trim()
                        : appTranslation().get('no_description'),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStylesManager.regular14.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
