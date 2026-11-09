import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:newsly/core/network/remote/api_endpoints.dart';
import 'package:newsly/core/theme/theme_reveal_controller.dart';
import 'package:newsly/core/utils/cubit/theme/theme_cubit.dart';
import 'package:newsly/features/home/presentation/logic/home_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> initInjections() async {
  sl.registerLazySingleton(() => ThemeRevealController());
  sl.registerFactory(() => HomeCubit());
  sl.registerFactory(() => ThemeCubit());

  final sharedPref = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPref);

  sl.registerLazySingleton(
    () => Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    ),
  );
}
