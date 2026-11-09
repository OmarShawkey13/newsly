import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart' show TickerCanceled;
import 'package:newsly/core/theme/theme_reveal_controller.dart';
import 'package:newsly/core/utils/cubit/theme/theme_cubit.dart';

class ThemeRevealOverlay extends StatefulWidget {
  final ThemeRevealController controller;
  final Widget child;

  const ThemeRevealOverlay({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  State<ThemeRevealOverlay> createState() => _ThemeRevealOverlayState();
}

class _ThemeRevealOverlayState extends State<ThemeRevealOverlay>
    with SingleTickerProviderStateMixin {
  final GlobalKey _captureKey = GlobalKey();

  late final AnimationController _animationController;
  late final Animation<double> _animation;
  late final ThemeRevealHandler _revealHandler = _revealTheme;

  ui.Image? _snapshot;
  Offset _origin = Offset.zero;
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    widget.controller.attach(_revealHandler);
  }

  @override
  void didUpdateWidget(covariant ThemeRevealOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.detach(_revealHandler);
      widget.controller.attach(_revealHandler);
    }
  }

  Future<void> _revealTheme(Offset? globalOrigin) async {
    if (_isTransitioning || !mounted) return;

    _isTransitioning = true;
    ui.Image? capturedImage;
    var imageStored = false;
    var themeChanged = false;

    try {
      final boundaryContext = _captureKey.currentContext;
      final renderObject = boundaryContext?.findRenderObject();

      if (boundaryContext == null || renderObject is! RenderRepaintBoundary) {
        ThemeCubit.get(context).changeTheme();
        themeChanged = true;
        return;
      }

      final image = await renderObject.toImage(
        pixelRatio: View.of(boundaryContext).devicePixelRatio,
      );
      capturedImage = image;

      if (!mounted) return;

      final origin = globalOrigin == null
          ? renderObject.size.center(Offset.zero)
          : renderObject.globalToLocal(globalOrigin);

      setState(() {
        _snapshot = image;
        _origin = origin;
      });
      imageStored = true;

      ThemeCubit.get(context).changeTheme();
      themeChanged = true;
      await _animationController.forward(from: 0).orCancel;
    } on TickerCanceled {
      // The overlay was removed while its animation was running.
    } on Object catch (error) {
      debugPrint('Theme reveal failed: $error');
      if (!themeChanged && mounted) {
        ThemeCubit.get(context).changeTheme();
        themeChanged = true;
      }
    } finally {
      if (mounted) {
        final imageToDispose = imageStored ? _snapshot : capturedImage;
        setState(() {
          if (imageStored) _snapshot = null;
          _isTransitioning = false;
        });
        imageToDispose?.dispose();
      } else if (!imageStored) {
        capturedImage?.dispose();
      }
    }
  }

  @override
  void dispose() {
    widget.controller.detach(_revealHandler);
    _animationController.dispose();
    _snapshot?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(key: _captureKey, child: widget.child),
        if (_snapshot case final snapshot?)
          Positioned.fill(
            child: ClipPath(
              clipBehavior: Clip.antiAlias,
              clipper: _CircularRevealClipper(
                origin: _origin,
                animation: _animation,
              ),
              child: RawImage(image: snapshot, fit: BoxFit.fill),
            ),
          ),
      ],
    );
  }
}

class _CircularRevealClipper extends CustomClipper<Path> {
  final Offset origin;
  final Animation<double> animation;

  _CircularRevealClipper({required this.origin, required this.animation})
    : super(reclip: animation);

  @override
  Path getClip(Size size) {
    final farthestX = math.max(origin.dx, size.width - origin.dx);
    final farthestY = math.max(origin.dy, size.height - origin.dy);
    final maxRadius = math.sqrt(farthestX * farthestX + farthestY * farthestY);
    final radius = (maxRadius + 1) * animation.value;

    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size);

    if (radius > 0) {
      path.addOval(Rect.fromCircle(center: origin, radius: radius));
    }

    return path;
  }

  @override
  bool shouldReclip(covariant _CircularRevealClipper oldClipper) =>
      origin != oldClipper.origin || animation != oldClipper.animation;
}
