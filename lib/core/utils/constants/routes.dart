import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsly/core/di/injections.dart';
import 'package:newsly/core/models/article_model.dart';
import 'package:newsly/features/home/presentation/logic/home_cubit.dart';
import 'package:newsly/features/home/presentation/screen/home_screen.dart';
import 'package:newsly/features/home/presentation/screen/article_website_screen.dart';

class Routes {
  static const String home = '/home';
  static const String articleWebsite = '/article';

  static Map<String, WidgetBuilder> get routes => {
    home: (context) => BlocProvider(
      create: (context) => sl<HomeCubit>()..getTopHeadlines(),
      child: const HomeScreen(),
    ),
    articleWebsite: (context) {
      final article = ModalRoute.of(context)?.settings.arguments;
      return ArticleWebsiteScreen(
        article: article is ArticleModel ? article : ArticleModel(),
      );
    },
  };
}
