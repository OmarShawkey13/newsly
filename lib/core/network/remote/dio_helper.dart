import 'package:dio/dio.dart';
import 'package:newsly/core/di/injections.dart';
import 'package:newsly/core/error/failures.dart';
import 'package:newsly/core/network/remote/api_endpoints.dart';
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
      final queryParameters = <String, dynamic>{...?query};
      if (search != null) queryParameters['q'] = search;

      final Response response = await getDio().get(
        url,
        queryParameters: queryParameters,
        options: Options(
          headers: {
            'X-Api-Key': apiKey,
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );
      return Right(response);
    } on DioException catch (error) {
      final msg = _parseError(error);
      return Left(ServerFailure(msg));
    } catch (_) {
      return const Left(ServerFailure('error_something_went_wrong'));
    }
  }

  static String _parseError(DioException error) {
    final response = error.response;
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'error_request_timeout';
    }
    if (response == null) return 'error_no_response';

    if (response.data is Map) {
      final map = response.data as Map;
      final code = map['code']?.toString();
      final codeMessage = _messageForApiCode(code);
      if (codeMessage != null) return codeMessage;

      if (map['errors'] is List && map['errors'].isNotEmpty) {
        final message = map['errors'].first.toString();
        if (_isTranslationKey(message)) return message;
      }
      if (map['message'] != null) {
        final message = map['message'].toString();
        if (_isTranslationKey(message)) return message;
      }
    }

    switch (response.statusCode) {
      case 400:
        return 'error_invalid_request';
      case 401:
        return 'error_api_key_invalid';
      case 429:
        return 'error_rate_limited';
      default:
        if ((response.statusCode ?? 0) >= 500) {
          return 'error_server_unavailable';
        }
        return 'error_something_went_wrong';
    }
  }

  static String? _messageForApiCode(String? code) {
    return switch (code) {
      'apiKeyDisabled' => 'error_api_key_disabled',
      'apiKeyExhausted' => 'error_api_key_exhausted',
      'apiKeyInvalid' => 'error_api_key_invalid',
      'apiKeyMissing' => 'error_api_key_missing',
      'parameterInvalid' => 'error_invalid_request',
      'parametersMissing' => 'error_parameters_missing',
      'rateLimited' => 'error_rate_limited',
      'sourcesTooMany' => 'error_sources_too_many',
      'sourceDoesNotExist' => 'error_source_not_found',
      'unexpectedError' => 'error_server_unavailable',
      _ => null,
    };
  }

  static bool _isTranslationKey(String value) {
    return value.startsWith('error_') ||
        value == 'unsupported_platform' ||
        value == 'download_success' ||
        value == 'apply';
  }
}
