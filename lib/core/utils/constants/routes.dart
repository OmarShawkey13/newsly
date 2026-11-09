import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsly/core/di/injections.dart';
import 'package:newsly/features/home/presentation/logic/home_cubit.dart';
import 'package:newsly/features/home/presentation/screen/home_screen.dart';

class Routes {
  static const String home = '/home';

  static Map<String, WidgetBuilder> get routes => {
    home: (context) => BlocProvider(
      create: (context) => sl<HomeCubit>()..getTopHeadlines(),
      child: const HomeScreen(),
    ),
  };
}
