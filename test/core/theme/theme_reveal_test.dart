import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:newsly/core/theme/theme_reveal_controller.dart';
import 'package:newsly/core/theme/theme_reveal_overlay.dart';
import 'package:newsly/core/utils/cubit/theme/theme_cubit.dart';
import 'package:newsly/core/utils/cubit/theme/theme_state.dart';
import 'package:newsly/features/home/presentation/widgets/theme_mode_toggle_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ThemeCubit cubit;
  late ThemeRevealController controller;
  late SharedPreferences preferences;

  setUp(() async {
    await GetIt.instance.reset();
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    GetIt.instance.registerSingleton<SharedPreferences>(preferences);
    controller = ThemeRevealController();
    GetIt.instance.registerSingleton<ThemeRevealController>(controller);
    cubit = ThemeCubit();
    await cubit.init(
      isDark: false,
      isArabic: false,
      translations: '{"toggle_theme":"Change appearance"}',
    );
  });

  tearDown(() async {
    await cubit.close();
    await GetIt.instance.reset();
  });

  test(
    'controller rejects overlapping reveals and releases its lock',
    () async {
      final completer = Completer<void>();
      var callCount = 0;
      controller.attach((_) async {
        callCount++;
        await completer.future;
      });

      final firstReveal = controller.revealFrom(const Offset(12, 18));
      expect(controller.isRevealing, isTrue);
      expect(await controller.revealFrom(const Offset(50, 50)), isFalse);

      completer.complete();
      expect(await firstReveal, isTrue);
      expect(callCount, 1);
      expect(controller.isRevealing, isFalse);
    },
  );

  test('controller detaches only the currently attached handler', () async {
    var firstCalls = 0;
    var secondCalls = 0;
    Future<void> firstHandler(Offset? _) async {
      firstCalls++;
    }

    Future<void> secondHandler(Offset? _) async {
      secondCalls++;
    }

    controller.attach(firstHandler);
    controller.attach(secondHandler);
    controller.detach(firstHandler);

    expect(controller.isAttached, isTrue);
    expect(await controller.revealFrom(null), isTrue);
    expect(firstCalls, 0);
    expect(secondCalls, 1);

    controller.detach(secondHandler);
    expect(controller.isAttached, isFalse);
    expect(await controller.revealFrom(null), isFalse);
  });

  testWidgets('light to dark captures once, reveals, and persists the theme', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var captureCount = 0;
    var captureRatio = 0.0;
    var imageSize = Size.zero;
    await tester.pumpWidget(
      _testApp(
        cubit: cubit,
        controller: controller,
        home: _brightnessLabel(),
        captureSnapshot: (boundary, pixelRatio) async {
          captureCount++;
          captureRatio = pixelRatio;
          final image = await boundary.toImage(pixelRatio: pixelRatio);
          imageSize = Size(image.width.toDouble(), image.height.toDouble());
          return image;
        },
      ),
    );
    await tester.pumpAndSettle();

    final transition = controller.revealFrom(const Offset(80, 120));
    await tester.pumpAndSettle();

    expect(await transition, isTrue);
    expect(captureCount, 1);
    expect(captureRatio, greaterThan(0));
    expect(captureRatio, 2);
    expect(imageSize.width, greaterThan(0));
    expect(imageSize.height, greaterThan(0));
    expect(
      imageSize.width * imageSize.height,
      lessThanOrEqualTo(8 * 1024 * 1024),
    );
    expect(cubit.isDarkMode, isTrue);
    expect(preferences.getBool('isDark'), isTrue);
    expect(find.text('dark'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dark to light reveals the final light theme', (tester) async {
    await cubit.changeTheme(fromShared: true);
    await tester.pumpWidget(
      _testApp(
        cubit: cubit,
        controller: controller,
        home: _brightnessLabel(),
        captureSnapshot: (boundary, pixelRatio) =>
            boundary.toImage(pixelRatio: pixelRatio),
      ),
    );
    await tester.pumpAndSettle();

    final transition = controller.revealFrom(const Offset(300, 700));
    await tester.pumpAndSettle();

    expect(await transition, isTrue);
    expect(cubit.isDarkMode, isFalse);
    expect(preferences.getBool('isDark'), isFalse);
    expect(find.text('light'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the theme button drives the circular reveal from its tap', (
    tester,
  ) async {
    final captureStarted = Completer<void>();
    var boundaryOrigin = Offset.zero;
    await tester.pumpWidget(
      _testApp(
        cubit: cubit,
        controller: controller,
        home: _toggleButtonHome(),
        captureSnapshot: (boundary, pixelRatio) async {
          boundaryOrigin = boundary.localToGlobal(Offset.zero);
          final image = await boundary.toImage(pixelRatio: pixelRatio);
          captureStarted.complete();
          return image;
        },
      ),
    );
    await tester.pumpAndSettle();

    final buttonRect = tester.getRect(find.byType(IconButton));
    final tapPosition = buttonRect.center + const Offset(3, 2);
    await tester.tapAt(tapPosition);
    await captureStarted.future;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));

    expect(find.byType(RawImage), findsOneWidget);
    final clipFinder = find.byType(ClipPath);
    final clipper = tester.widget<ClipPath>(clipFinder).clipper!;
    final path = clipper.getClip(tester.getSize(clipFinder));
    expect(path.contains(tapPosition - boundaryOrigin), isFalse);
    expect(cubit.isDarkMode, isTrue);

    await tester.pumpAndSettle();
    expect(find.byType(RawImage), findsNothing);
    expect(preferences.getBool('isDark'), isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('same-size metrics callbacks do not cancel the reveal', (
    tester,
  ) async {
    final captureStarted = Completer<void>();
    var boundaryOrigin = Offset.zero;
    await tester.pumpWidget(
      _testApp(
        cubit: cubit,
        controller: controller,
        home: _brightnessLabel(),
        captureSnapshot: (boundary, pixelRatio) async {
          boundaryOrigin = boundary.localToGlobal(Offset.zero);
          final image = await boundary.toImage(pixelRatio: pixelRatio);
          captureStarted.complete();
          return image;
        },
      ),
    );
    await tester.pumpAndSettle();

    const globalOrigin = Offset(40, 60);
    final transition = controller.revealFrom(globalOrigin);
    await tester.pump();
    await captureStarted.future;
    await tester.pump();
    expect(find.byType(RawImage), findsOneWidget);

    tester.binding.handleMetricsChanged();
    await tester.pump(const Duration(milliseconds: 120));

    final clipFinder = find.byType(ClipPath);
    final clipPath = tester
        .widget<ClipPath>(clipFinder)
        .clipper!
        .getClip(tester.getSize(clipFinder));
    expect(clipPath.contains(globalOrigin - boundaryOrigin), isFalse);
    expect(find.byType(RawImage), findsOneWidget);

    await tester.pumpAndSettle();
    expect(await transition, isTrue);
    expect(cubit.isDarkMode, isTrue);
    expect(find.byType(RawImage), findsNothing);
  });

  testWidgets('rapid reveal requests change the theme only once', (
    tester,
  ) async {
    final capture = Completer<ui.Image>();
    await tester.pumpWidget(
      _testApp(
        cubit: cubit,
        controller: controller,
        home: _brightnessLabel(),
        captureSnapshot: (_, _) => capture.future,
      ),
    );
    await tester.pumpAndSettle();

    final acceptedReveal = controller.revealFrom(const Offset(70, 90));
    final rejectedReveal = controller.revealFrom(const Offset(200, 400));
    expect(await rejectedReveal, isFalse);
    expect(cubit.isDarkMode, isFalse);

    capture.complete(await _createImage());
    await tester.pumpAndSettle();

    expect(await acceptedReveal, isTrue);
    expect(cubit.isDarkMode, isTrue);
    expect(preferences.getBool('isDark'), isTrue);
  });

  testWidgets('capture failure falls back to one normal theme change', (
    tester,
  ) async {
    var captureCount = 0;
    await tester.pumpWidget(
      _testApp(
        cubit: cubit,
        controller: controller,
        home: _brightnessLabel(),
        captureSnapshot: (_, _) async {
          captureCount++;
          throw StateError('capture failed');
        },
      ),
    );
    await tester.pumpAndSettle();

    final transition = controller.revealFrom(const Offset(60, 80));
    await tester.pumpAndSettle();

    expect(await transition, isTrue);
    expect(captureCount, 1);
    expect(cubit.isDarkMode, isTrue);
    expect(controller.isRevealing, isFalse);
    expect(find.byType(RawImage), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a missing overlay uses the regular accessible toggle callback', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        cubit: cubit,
        controller: controller,
        home: _toggleButtonHome(),
        showOverlay: false,
      ),
    );
    await tester.pumpAndSettle();

    tester.widget<IconButton>(find.byType(IconButton)).onPressed!.call();
    await tester.pumpAndSettle();

    expect(controller.isAttached, isFalse);
    expect(cubit.isDarkMode, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a reveal requested before layout falls back without capture', (
    tester,
  ) async {
    var captureCount = 0;
    await tester.pumpWidget(
      _testApp(
        cubit: cubit,
        controller: controller,
        home: _RevealOnInit(controller: controller),
        captureSnapshot: (_, _) async {
          captureCount++;
          return _createImage();
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(captureCount, 0);
    expect(cubit.isDarkMode, isTrue);
    expect(preferences.getBool('isDark'), isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tap origin is accurate and canceled coordinates are cleared', (
    tester,
  ) async {
    final origins = <Offset?>[];
    controller.attach((origin) async => origins.add(origin));
    await tester.pumpWidget(
      _testApp(
        cubit: cubit,
        controller: controller,
        home: _toggleButtonHome(),
        showOverlay: false,
      ),
    );
    await tester.pumpAndSettle();

    final button = find.byType(IconButton);
    final buttonRect = tester.getRect(button);
    final canceledTap = await tester.startGesture(
      buttonRect.center + const Offset(5, 4),
    );
    await canceledTap.cancel();
    await tester.pump();

    tester.widget<IconButton>(button).onPressed!.call();
    await tester.pumpAndSettle();
    expect(origins.last, buttonRect.center);

    final tapPosition = buttonRect.center + const Offset(-4, 3);
    await tester.tapAt(tapPosition);
    await tester.pumpAndSettle();
    expect(origins.last, tapPosition);

    tester.widget<IconButton>(button).onPressed!.call();
    await tester.pumpAndSettle();
    expect(origins.last, buttonRect.center);
  });

  testWidgets('reduced motion skips capture and switches immediately', (
    tester,
  ) async {
    var captureCount = 0;
    await tester.pumpWidget(
      _testApp(
        cubit: cubit,
        controller: controller,
        home: _brightnessLabel(),
        disableAnimations: true,
        captureSnapshot: (_, _) async {
          captureCount++;
          throw StateError('must not capture when motion is reduced');
        },
      ),
    );
    await tester.pumpAndSettle();

    final transition = controller.revealFrom(const Offset(60, 90));
    await tester.pumpAndSettle();

    expect(await transition, isTrue);
    expect(captureCount, 0);
    expect(cubit.isDarkMode, isTrue);
    expect(preferences.getBool('isDark'), isTrue);
    expect(find.byType(RawImage), findsNothing);
  });

  testWidgets(
    'disposal during capture still switches once and releases image',
    (
      tester,
    ) async {
      final capture = Completer<ui.Image>();
      final captureStarted = Completer<void>();
      await tester.pumpWidget(
        _testApp(
          cubit: cubit,
          controller: controller,
          home: _brightnessLabel(),
          captureSnapshot: (_, _) {
            captureStarted.complete();
            return capture.future;
          },
        ),
      );
      await tester.pumpAndSettle();

      final transition = controller.revealFrom(const Offset(40, 50));
      await captureStarted.future;
      await tester.pumpWidget(const SizedBox.shrink());
      capture.complete(await _createImage());

      expect(await transition, isTrue);
      expect(cubit.isDarkMode, isTrue);
      expect(controller.isAttached, isFalse);
      expect(controller.isRevealing, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('disposal during animation cancels cleanly', (tester) async {
    final image = await _createImage();
    await tester.pumpWidget(
      _testApp(
        cubit: cubit,
        controller: controller,
        home: _brightnessLabel(),
        captureSnapshot: (_, _) async => image,
      ),
    );
    await tester.pumpAndSettle();

    final transition = controller.revealFrom(const Offset(50, 70));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(RawImage), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    expect(await transition, isTrue);
    expect(cubit.isDarkMode, isTrue);
    expect(controller.isAttached, isFalse);
    expect(controller.isRevealing, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('backgrounding completes the reveal and removes the snapshot', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        cubit: cubit,
        controller: controller,
        home: _brightnessLabel(),
        captureSnapshot: (boundary, pixelRatio) =>
            boundary.toImage(pixelRatio: pixelRatio),
      ),
    );
    await tester.pumpAndSettle();

    final transition = controller.revealFrom(const Offset(40, 60));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(RawImage), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pumpAndSettle();
    expect(await transition, isTrue);
    expect(cubit.isDarkMode, isTrue);
    expect(find.byType(RawImage), findsNothing);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
  });

  testWidgets('clipper handles origins outside the viewport', (tester) async {
    tester.view.physicalSize = const Size(100, 100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final captureStarted = Completer<void>();
    await tester.pumpWidget(
      _testApp(
        cubit: cubit,
        controller: controller,
        home: _brightnessLabel(),
        captureSnapshot: (_, _) async {
          final image = await _createImage();
          captureStarted.complete();
          return image;
        },
      ),
    );
    await tester.pumpAndSettle();

    final transition = controller.revealFrom(const Offset(-20, 50));
    await tester.pump();
    await captureStarted.future;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byType(RawImage), findsOneWidget);
    final clipFinder = find.byType(ClipPath);
    final clipPath = tester
        .widget<ClipPath>(clipFinder)
        .clipper!
        .getClip(tester.getSize(clipFinder));
    expect(clipPath.contains(const Offset(1, 50)), isFalse);
    expect(clipPath.contains(const Offset(99, 50)), isTrue);

    await tester.pumpAndSettle();
    expect(await transition, isTrue);
    expect(find.byType(RawImage), findsNothing);
  });
}

Widget _testApp({
  required ThemeCubit cubit,
  required ThemeRevealController controller,
  required Widget home,
  ThemeSnapshotCapture? captureSnapshot,
  bool showOverlay = true,
  bool disableAnimations = false,
}) {
  return BlocProvider<ThemeCubit>.value(
    value: cubit,
    child: BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, _) => MaterialApp(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: cubit.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        themeAnimationDuration: Duration.zero,
        home: home,
        builder: (context, child) {
          final app = showOverlay
              ? ThemeRevealOverlay(
                  controller: controller,
                  captureSnapshot: captureSnapshot,
                  child: child!,
                )
              : child!;
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(disableAnimations: disableAnimations),
            child: app,
          );
        },
      ),
    ),
  );
}

Widget _brightnessLabel() => const Scaffold(
  body: Center(
    child: _BrightnessText(),
  ),
);

class _BrightnessText extends StatelessWidget {
  const _BrightnessText();

  @override
  Widget build(BuildContext context) => Text(
    Theme.of(context).brightness.name,
    key: const Key('brightness'),
  );
}

class _RevealOnInit extends StatefulWidget {
  final ThemeRevealController controller;

  const _RevealOnInit({required this.controller});

  @override
  State<_RevealOnInit> createState() => _RevealOnInitState();
}

class _RevealOnInitState extends State<_RevealOnInit> {
  @override
  void initState() {
    super.initState();
    unawaited(widget.controller.revealFrom(null));
  }

  @override
  Widget build(BuildContext context) => _brightnessLabel();
}

Widget _toggleButtonHome() => const Scaffold(
  appBar: _ThemeButtonAppBar(),
  body: SizedBox.expand(),
);

class _ThemeButtonAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _ThemeButtonAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
    actions: const [ThemeModeToggleButton()],
  );
}

Future<ui.Image> _createImage() async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  canvas.drawColor(Colors.blue, BlendMode.src);
  final picture = recorder.endRecording();
  try {
    return await picture.toImage(4, 4);
  } finally {
    picture.dispose();
  }
}
