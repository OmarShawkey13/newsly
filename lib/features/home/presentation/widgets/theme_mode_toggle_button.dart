import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsly/core/di/injections.dart';
import 'package:newsly/core/theme/theme_reveal_controller.dart';
import 'package:newsly/core/utils/constants/constants.dart';
import 'package:newsly/core/utils/cubit/theme/theme_cubit.dart';
import 'package:newsly/core/utils/cubit/theme/theme_state.dart';

class ThemeModeToggleButton extends StatefulWidget {
  const ThemeModeToggleButton({super.key});

  @override
  State<ThemeModeToggleButton> createState() => _ThemeModeToggleButtonState();
}

class _ThemeModeToggleButtonState extends State<ThemeModeToggleButton> {
  final GlobalKey _buttonKey = GlobalKey();
  int? _activePointer;
  Offset? _pointerOrigin;

  void _handlePointerDown(PointerDownEvent event) {
    if (_activePointer != null) return;
    _activePointer = event.pointer;
    _pointerOrigin = event.position;
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (_activePointer != event.pointer) return;

    scheduleMicrotask(() {
      if (mounted && _activePointer == event.pointer) _clearPointer();
    });
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    if (_activePointer == event.pointer) _clearPointer();
  }

  void _clearPointer() {
    _activePointer = null;
    _pointerOrigin = null;
  }

  Offset? _buttonCenter() {
    final renderObject = _buttonKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox) return null;

    return renderObject.localToGlobal(renderObject.size.center(Offset.zero));
  }

  void _toggleTheme() {
    final revealController = sl<ThemeRevealController>();
    final origin = _pointerOrigin ?? _buttonCenter();
    _clearPointer();

    if (revealController.isAttached) {
      unawaited(revealController.revealFrom(origin));
      return;
    }

    unawaited(ThemeCubit.get(context).changeTheme());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      buildWhen: (_, current) =>
          current is ThemeChangeThemeState ||
          current is ThemeLanguageUpdatedState,
      builder: (context, _) => Listener(
        onPointerDown: _handlePointerDown,
        onPointerUp: _handlePointerUp,
        onPointerCancel: _handlePointerCancel,
        child: IconButton(
          key: _buttonKey,
          tooltip: appTranslation().get('toggle_theme'),
          onPressed: _toggleTheme,
          icon: Icon(
            ThemeCubit.get(context).isDarkMode
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
          ),
        ),
      ),
    );
  }
}
