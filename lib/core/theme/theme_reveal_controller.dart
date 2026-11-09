import 'dart:ui' show Offset;

typedef ThemeRevealHandler = Future<void> Function(Offset? globalOrigin);

class ThemeRevealController {
  ThemeRevealHandler? _handler;
  bool _isRevealing = false;

  bool get isAttached => _handler != null;
  bool get isRevealing => _isRevealing;

  void attach(ThemeRevealHandler handler) {
    _handler = handler;
  }

  void detach(ThemeRevealHandler handler) {
    final matches = identical(_handler, handler);
    if (matches) _handler = null;
  }

  Future<bool> revealFrom(Offset? globalOrigin) async {
    final handler = _handler;
    if (handler == null || _isRevealing) return false;

    _isRevealing = true;
    try {
      await handler(globalOrigin);
      return true;
    } finally {
      _isRevealing = false;
    }
  }
}
