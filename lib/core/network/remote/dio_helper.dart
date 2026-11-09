import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:newsly/core/di/injections.dart';
import 'package:newsly/core/error/failures.dart';
import 'package:newsly/core/network/remote/either.dart';

class DioHelper {
  static Dio getDio() => sl<Dio>();

  static Future<Either<Failure, Response>> getData({
    required String url,
    Map<String, dynamic>? query,
    String? search,
    String? token,
  }) async {
    try {
      final Response response = await getDio().get(
        url,
        queryParameters: {'q': search, ...?query},
        options: Options(
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
        ),
      );
      return Right(response);
    } on DioException catch (error) {
      final msg = _parseError(error);
      return Left(ServerFailure(msg));
    } catch (e) {
      debugPrint('DioHelper.get error: $e');
      return const Left(ServerFailure('error_something_went_wrong'));
    }
  }

  static String _parseError(DioException error) {
    final response = error.response;
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'error_request_timeout';
    }
    if (response == null) return 'error_no_response';

    if (response.data is Map) {
      final map = response.data as Map;
      if (map['errors'] is List && map['errors'].isNotEmpty) {
        final message = map['errors'].first.toString();
        if (_isTranslationKey(message)) return message;
      }
      if (map['message'] != null) {
        final message = map['message'].toString();
        if (_isTranslationKey(message)) return message;
      }
    }

    if ((response.statusCode ?? 0) >= 500) {
      return 'error_server_unavailable';
    }
    return 'error_something_went_wrong';
  }

  static bool _isTranslationKey(String value) {
    return value.startsWith('error_') ||
        value == 'unsupported_platform' ||
        value == 'download_success' ||
        value == 'apply';
  }
}
