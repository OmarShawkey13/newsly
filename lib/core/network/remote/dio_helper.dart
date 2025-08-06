import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:newsly/core/network/remote/api_endpoints.dart';

class DioHelper {
  static Dio? dio;

  static void init() {
    if (dio != null) {
      return;
    }

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
      ),
    );
  }

  static Dio getDio() {
    if (dio != null) {
      return dio!;
    }
    init();
    return dio!;
  }

  static Future<Either<String, Response>> getData({
    required String url,
    Map<String, dynamic>? query,
    String? search,
  }) async {
    try {
      final Response response = await getDio().get(
        url,
        queryParameters: {
          if(search != null) 'q': search,
          ...?query,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
          },
        ),
      );
      return Right(response);
    } on DioException catch (error) {
      return Left(
        error.response?.data['errors']?.first ?? 'Something went wrong',
      );
    } catch (e) {
      debugPrint('DioHelper.get error: $e');
      return const Left('something went wrong, please try again later');
    }
  }
}
