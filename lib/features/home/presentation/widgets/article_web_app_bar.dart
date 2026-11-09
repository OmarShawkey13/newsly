import 'package:flutter/material.dart';
import 'package:newsly/core/theme/colors.dart';
import 'package:newsly/core/theme/text_styles.dart';
import 'package:newsly/core/utils/constants/constants.dart';

class ArticleWebAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? host;
  final VoidCallback? onReload;

  const ArticleWebAppBar({
    super.key,
    required this.title,
    required this.host,
    required this.onReload,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorsManager.currentColorScheme;
    return AppBar(
      titleSpacing: 8,
      actions: [
        IconButton(
          tooltip: appTranslation().get('browser_reload'),
          onPressed: onReload,
          icon: const Icon(Icons.refresh_rounded),
        ),
        const SizedBox(width: 8),
      ],
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title?.isNotEmpty == true
                ? title!
                : appTranslation().get('article_page'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStylesManager.semiBold16.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          if (host?.isNotEmpty == true)
            Text(
              host!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStylesManager.regular12.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}
