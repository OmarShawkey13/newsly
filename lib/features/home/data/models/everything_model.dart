import 'package:newsly/features/home/data/models/article_model.dart';

class EverythingModel {
  final String? status;
  final int? totalResults;
  final List<ArticleModel>? articles;

  EverythingModel({
    this.status,
    this.totalResults,
    this.articles,
  });

  // Create a EverythingModel instance from a Map (e.g., from database query)
  factory EverythingModel.fromMap(Map<String, dynamic> map) {
    return EverythingModel(
      status: map['status'] as String?,
      totalResults: map['totalResults'] as int?,
      articles: map['articles'] != null
          ? (map['articles'] as List<dynamic>?)?.map((article) => ArticleModel.fromMap(article as Map<String, dynamic>)).toList()
          : null,
    );
  }
}