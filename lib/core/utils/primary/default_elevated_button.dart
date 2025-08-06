import 'package:flutter/material.dart';

class DefaultElevatedButton extends StatelessWidget {
  final Color? color;
  final void Function()? onPressed;
  final Widget? child;

  const DefaultElevatedButton({
    super.key,
    required this.color,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}
