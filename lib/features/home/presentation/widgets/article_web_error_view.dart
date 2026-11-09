import 'package:flutter/material.dart';
import 'package:newsly/core/theme/colors.dart';
import 'package:newsly/core/theme/text_styles.dart';
import 'package:newsly/core/utils/constants/constants.dart';

class ArticleWebErrorView extends StatelessWidget {
  final bool hasAddress;
  final VoidCallback? onRetry;

  const ArticleWebErrorView({
    super.key,
    required this.hasAddress,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorsManager.currentColorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasAddress ? Icons.wifi_off_rounded : Icons.link_off_rounded,
              size: 44,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              appTranslation().get(
                hasAddress ? 'article_load_error' : 'article_invalid_url',
              ),
              textAlign: TextAlign.center,
              style: TextStylesManager.regular16.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              FilledButton.tonalIcon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(appTranslation().get('retry')),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
