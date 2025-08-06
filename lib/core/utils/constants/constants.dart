import 'package:flutter/material.dart';

String? token = '';

double getResponsiveSize({
  required BuildContext context,
  required double size,
}) {
  final width = MediaQuery.of(context).size.width;
  return (size * width) / 411.0;
}
