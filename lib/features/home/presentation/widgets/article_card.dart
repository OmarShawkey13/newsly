import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:newsly/core/models/article_model.dart';
import 'package:newsly/core/theme/colors.dart';
import 'package:newsly/core/theme/text_styles.dart';
import 'package:newsly/core/utils/constants/constants.dart';
import 'package:newsly/core/utils/constants/routes.dart';
import 'package:newsly/core/utils/constants/spacing.dart';
import 'package:newsly/core/utils/extensions/context_extension.dart';

class ArticleCard extends StatelessWidget {
  final ArticleModel article;

  const ArticleCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final imageUrl = article.urlToImage?.trim() ?? '';
    final colorScheme = ColorsManager.currentColorScheme;
    final uri = Uri.tryParse(article.url?.trim() ?? '');
    final canOpenArticle =
        uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty;

    return Card(
      child: InkWell(
        onTap: canOpenArticle
            ? () => context.push(Routes.articleWebsite, arguments: article)
            : null,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: 104,
                  height: 104,
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
                      style: TextStylesManager.semiBold16.copyWith(
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
                      style: TextStylesManager.regular13.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
