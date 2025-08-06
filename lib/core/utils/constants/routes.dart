import 'package:flutter/material.dart';
import 'package:newsly/features/home/presentation/screen/home_screen.dart';

class Routes {
  static const String home = '/home';

  static Map<String, WidgetBuilder> get routes => {
    home: (context) => HomeScreen(),
  };
}
