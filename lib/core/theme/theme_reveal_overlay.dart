import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart' show SchedulerBinding, TickerCanceled;
import 'package:newsly/core/theme/theme_reveal_controller.dart';
import 'package:newsly/core/utils/cubit/theme/theme_cubit.dart';

typedef ThemeSnapshotCapture = Future<ui.Image> Function(
  RenderRepaintBoundary boundary,
  double pixelRatio,
);

class ThemeRevealOverlay extends StatefulWidget {
  final ThemeRevealController controller;
  final Widget child;
  final ThemeSnapshotCapture? captureSnapshot;

  const ThemeRevealOverlay({
    super.key,
    required this.controller,
    required this.child,
    this.captureSnapshot,
  });

  @override
  State<ThemeRevealOverlay> createState() => _ThemeRevealOverlayState();
}

class _ThemeRevealOverlayState extends State<ThemeRevealOverlay>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const double _maxCapturePixelRatio = 2;
  static const double _maxCapturePixels = 8 * 1024 * 1024;

  final GlobalKey _captureKey = GlobalKey();

  late final AnimationController _animationController;
  late final Animation<double> _animation;
  late final ThemeRevealHandler _revealHandler = _revealTheme;

  ui.Image? _snapshot;
  Offset _origin = Offset.zero;
  ThemeCubit? _activeCubit;
  Future<void>? _themePersistence;
  Size? _transitionPhysicalSize;
  Size? _transitionBoundarySize;
  double? _transitionDevicePixelRatio;
  bool _isTransitioning = false;
  bool _skipAnimation = false;
  bool _themeChangeAttempted = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    WidgetsBinding.instance.addObserver(this);
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

  @override
  void didChangeMetrics() {
    if (!_isTransitioning || !mounted) {
      return;
    }

    final boundaryContext = _captureKey.currentContext;
    final view = View.of(boundaryContext ?? context);
    final renderObject = boundaryContext?.findRenderObject();
    final physicalSizeChanged = _transitionPhysicalSize != view.physicalSize;
    final devicePixelRatioChanged =
        _transitionDevicePixelRatio != view.devicePixelRatio;
    final boundarySizeChanged =
        _transitionBoundarySize != null &&
        renderObject is RenderBox &&
        renderObject.hasSize &&
        renderObject.size != _transitionBoundarySize;

    if (physicalSizeChanged || devicePixelRatioChanged || boundarySizeChanged) {
      _finishForEnvironmentChange();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _finishForEnvironmentChange();
    }
  }

  void _finishForEnvironmentChange() {
    if (!_isTransitioning || !mounted) return;

    _skipAnimation = true;
    try {
      _changeThemeOnce();
    } on Object catch (error) {
      debugPrint('Theme change failed: $error');
    }
    _animationController.stop(canceled: false);
  }

  void _changeThemeOnce() {
    if (_themeChangeAttempted) {
      return;
    }

    _themeChangeAttempted = true;
    final cubit = _activeCubit;
    if (cubit == null || cubit.isClosed) {
      return;
    }

    _themePersistence = cubit.changeTheme();
  }

  bool _shouldReduceMotion() {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final reduceMotion = WidgetsBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .reduceMotion;
    return disableAnimations || reduceMotion;
  }

  double _capturePixelRatio(Size size, double devicePixelRatio) {
    if (!size.width.isFinite ||
        !size.height.isFinite ||
        size.width <= 0 ||
        size.height <= 0 ||
        !devicePixelRatio.isFinite ||
        devicePixelRatio <= 0) {
      return 1;
    }

    final logicalPixelCount = size.width * size.height;
    if (!logicalPixelCount.isFinite || logicalPixelCount <= 0) return 1;

    final memoryBoundRatio = math.sqrt(_maxCapturePixels / logicalPixelCount);
    return math.min(
      devicePixelRatio,
      math.min(_maxCapturePixelRatio, memoryBoundRatio),
    );
  }

  Future<void> _revealTheme(Offset? globalOrigin) async {
    if (_isTransitioning || !mounted) return;

    _isTransitioning = true;
    _skipAnimation = false;
    _themeChangeAttempted = false;
    _themePersistence = null;
    _transitionPhysicalSize = null;
    _transitionBoundarySize = null;
    _transitionDevicePixelRatio = null;
    ui.Image? unownedImage;

    try {
      final cubit = ThemeCubit.get(context);
      _activeCubit = cubit;

      if (_shouldReduceMotion()) {
        _changeThemeOnce();
        return;
      }

      final boundaryContext = _captureKey.currentContext;
      final renderObject = boundaryContext?.findRenderObject();
      if (boundaryContext == null ||
          renderObject is! RenderRepaintBoundary ||
          !renderObject.attached ||
          !renderObject.hasSize) {
        _changeThemeOnce();
        return;
      }

      final captureSize = renderObject.size;
      final view = View.of(boundaryContext);
      final physicalSize = view.physicalSize;
      final devicePixelRatio = view.devicePixelRatio;
      _transitionPhysicalSize = physicalSize;
      _transitionDevicePixelRatio = devicePixelRatio;
      _transitionBoundarySize = captureSize;
      final pixelRatio = _capturePixelRatio(
        captureSize,
        devicePixelRatio,
      );
      final image =
          await (widget.captureSnapshot?.call(
                renderObject,
                pixelRatio,
              ) ??
              renderObject.toImage(pixelRatio: pixelRatio));
      unownedImage = image;

      if (!mounted) {
        _changeThemeOnce();
        return;
      }

      final currentRenderObject = _captureKey.currentContext
          ?.findRenderObject();
      final currentView = View.of(context);
      final viewResized = currentView.physicalSize != physicalSize;
      final devicePixelRatioChanged =
          currentView.devicePixelRatio != devicePixelRatio;
      final boundaryDetached = !renderObject.attached;
      final boundaryLostSize = !renderObject.hasSize;
      final boundaryResized =
          renderObject.hasSize && renderObject.size != captureSize;
      final boundaryReplaced = currentRenderObject != renderObject;
      if (_skipAnimation ||
          viewResized ||
          devicePixelRatioChanged ||
          boundaryDetached ||
          boundaryLostSize ||
          boundaryResized ||
          boundaryReplaced) {
        _changeThemeOnce();
        return;
      }

      final localOrigin = globalOrigin == null
          ? captureSize.center(Offset.zero)
          : renderObject.globalToLocal(globalOrigin);
      final origin = localOrigin.dx.isFinite && localOrigin.dy.isFinite
          ? localOrigin
          : captureSize.center(Offset.zero);
      setState(() {
        _snapshot = image;
        _origin = origin;
      });
      unownedImage = null;

      _changeThemeOnce();
      if (!_skipAnimation) {
        await _animationController.forward(from: 0).orCancel;
      }
    } on TickerCanceled {
      // The overlay was removed while its animation was running.
    } on Object catch (error) {
      debugPrint('Theme reveal failed: $error');
      try {
        _changeThemeOnce();
      } on Object catch (themeError) {
        debugPrint('Theme change failed: $themeError');
      }
    } finally {
      unownedImage?.dispose();
      if (mounted) {
        await _removeSnapshotAfterFrame();
        _isTransitioning = false;
        _activeCubit = null;
        _skipAnimation = false;
        _transitionPhysicalSize = null;
        _transitionBoundarySize = null;
        _transitionDevicePixelRatio = null;
      }
      await _awaitThemePersistence();
    }
  }

  Future<void> _awaitThemePersistence() async {
    final persistence = _themePersistence;
    if (persistence == null) return;

    try {
      await persistence;
    } on Object catch (error) {
      debugPrint('Theme persistence failed: $error');
    }
  }

  Future<void> _removeSnapshotAfterFrame() async {
    final image = _snapshot;
    if (image == null) return;

    setState(() => _snapshot = null);
    await _disposeAfterFrame(image);
  }

  Future<void> _disposeAfterFrame(ui.Image image) async {
    await SchedulerBinding.instance.endOfFrame;
    image.dispose();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.controller.detach(_revealHandler);
    _animationController.dispose();

    final image = _snapshot;
    _snapshot = null;
    if (image != null) unawaited(_disposeAfterFrame(image));

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
    final safeOrigin = origin.dx.isFinite && origin.dy.isFinite
        ? origin
        : size.center(Offset.zero);
    final farthestX = math.max(
      safeOrigin.dx.abs(),
      (size.width - safeOrigin.dx).abs(),
    );
    final farthestY = math.max(
      safeOrigin.dy.abs(),
      (size.height - safeOrigin.dy).abs(),
    );
    final maxRadius = math.sqrt(farthestX * farthestX + farthestY * farthestY);
    final radius = (maxRadius + 1) * animation.value;

    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size);

    if (radius > 0 && radius.isFinite) {
      path.addOval(Rect.fromCircle(center: safeOrigin, radius: radius));
    }

    return path;
  }

  @override
  bool shouldReclip(covariant _CircularRevealClipper oldClipper) =>
      origin != oldClipper.origin || animation != oldClipper.animation;
}
