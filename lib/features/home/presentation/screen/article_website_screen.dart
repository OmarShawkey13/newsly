import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsly/core/models/article_model.dart';
import 'package:newsly/core/theme/colors.dart';
import 'package:newsly/core/utils/cubit/theme/theme_cubit.dart';
import 'package:newsly/core/utils/cubit/theme/theme_state.dart';
import 'package:newsly/features/home/presentation/widgets/article_web_app_bar.dart';
import 'package:newsly/features/home/presentation/widgets/article_web_error_view.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ArticleWebsiteScreen extends StatefulWidget {
  final ArticleModel article;

  const ArticleWebsiteScreen({super.key, required this.article});

  @override
  State<ArticleWebsiteScreen> createState() => _ArticleWebsiteScreenState();
}

class _ArticleWebsiteScreenState extends State<ArticleWebsiteScreen> {
  final WebViewController _controller = WebViewController();
  int _progress = 0;
  bool _hasError = false;
  Uri? _articleUri;

  @override
  void initState() {
    super.initState();
    _articleUri = _parseArticleUri(widget.article.url);
    if (_articleUri == null) {
      _hasError = true;
    } else {
      unawaited(_loadArticle(_articleUri!));
    }
  }

  Uri? _parseArticleUri(String? value) {
    final uri = Uri.tryParse(value?.trim() ?? '');
    if (uri == null ||
        uri.host.isEmpty ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      return null;
    }
    return uri;
  }

  Future<void> _loadArticle(Uri uri) async {
    if (mounted) {
      setState(() {
        _progress = 0;
        _hasError = false;
      });
    }

    try {
      await _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await _controller.setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) setState(() => _progress = progress);
          },
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _progress = 0;
                _hasError = false;
              });
            }
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _progress = 100);
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == true && mounted) {
              setState(() => _hasError = true);
            }
          },
          onNavigationRequest: (request) {
            final nextUri = Uri.tryParse(request.url);
            final allowed =
                nextUri != null &&
                (nextUri.scheme == 'https' || nextUri.scheme == 'http');
            return allowed
                ? NavigationDecision.navigate
                : NavigationDecision.prevent;
          },
        ),
      );
      await _controller.loadRequest(uri);
    } on Object {
      if (mounted) setState(() => _hasError = true);
    }
  }

  void _retry() {
    final uri = _articleUri;
    if (uri != null) unawaited(_loadArticle(uri));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      buildWhen: (_, current) =>
          current is ThemeChangeThemeState ||
          current is ThemeLanguageUpdatedState,
      builder: (context, _) {
        final colorScheme = ColorsManager.currentColorScheme;
        final title = widget.article.title?.trim();

        return Scaffold(
          appBar: ArticleWebAppBar(
            title: title?.isNotEmpty == true ? title! : null,
            host: _articleUri?.host,
            onReload: _articleUri == null ? null : _retry,
          ),
          body: Column(
            children: [
              if (!_hasError && _progress < 100)
                LinearProgressIndicator(
                  value: _progress == 0 ? null : _progress / 100,
                  minHeight: 2,
                  backgroundColor: colorScheme.surfaceContainerHigh,
                ),
              Expanded(
                child: _hasError
                    ? ArticleWebErrorView(
                        hasAddress: _articleUri != null,
                        onRetry: _articleUri == null ? null : _retry,
                      )
                    : WebViewWidget(controller: _controller),
              ),
            ],
          ),
        );
      },
    );
  }
}
