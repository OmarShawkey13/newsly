import 'dart:ui' show Offset;

typedef ThemeRevealHandler = Future<void> Function(Offset? globalOrigin);

class ThemeRevealController {
  ThemeRevealHandler? _handler;

  bool get isAttached => _handler != null;

  void attach(ThemeRevealHandler handler) {
    _handler = handler;
  }

  void detach(ThemeRevealHandler handler) {
    if (identical(_handler, handler)) _handler = null;
  }

  Future<void> revealFrom(Offset? globalOrigin) async {
    final handler = _handler;
    if (handler != null) await handler(globalOrigin);
  }
}
