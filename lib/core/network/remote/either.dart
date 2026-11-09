/// A simple implementation of the Either monad for functional error handling.
/// [L] represents the Left side (usually a Failure), and [R] represents the Right side (usually a Success).
abstract class Either<L, R> {
  const Either();

  // ---------------------------------------------------------------------------
  // Core
  // ---------------------------------------------------------------------------

  /// Folds the Either into a single value of type [T].
  T fold<T>(T Function(L l) onLeft, T Function(R r) onRight);

  // ---------------------------------------------------------------------------
  // Factory constructors
  // ---------------------------------------------------------------------------

  /// Wraps [f] in a try/catch and returns [Right] on success or [Left] on error.
  static Either<E, R> tryCatch<E, R>(
    R Function() f,
    E Function(Object error, StackTrace stackTrace) onError,
  ) {
    try {
      return Right(f());
    } catch (e, s) {
      return Left(onError(e, s));
    }
  }

  // ---------------------------------------------------------------------------
  // Transformations
  // ---------------------------------------------------------------------------

  /// Maps the Right value to a new value.
  Either<L, T> map<T>(T Function(R r) f) =>
      fold((l) => Left<L, T>(l), (r) => Right<L, T>(f(r)));

  /// FlatMaps (chains) the Right value into a new Either.
  Either<L, T> flatMap<T>(Either<L, T> Function(R r) f) =>
      fold((l) => Left<L, T>(l), (r) => f(r));

  /// Maps the Left value to a new value.
  Either<T, R> leftMap<T>(T Function(L l) f) =>
      fold((l) => Left<T, R>(f(l)), (r) => Right<T, R>(r));

  /// Swaps Left and Right sides.
  Either<R, L> swap() => fold((l) => Right(l), (r) => Left(r));

  // ---------------------------------------------------------------------------
  // Side effects
  // ---------------------------------------------------------------------------

  /// Calls [onLeft] or [onRight] for side-effects without returning a value.
  void when({
    required void Function(L l) left,
    required void Function(R r) right,
  }) => fold(left, right);

  /// Calls [f] with the Right value if this is a [Right], then returns `this`.
  Either<L, R> tap(void Function(R r) f) {
    fold((_) {}, f);
    return this;
  }

  /// Calls [f] with the Left value if this is a [Left], then returns `this`.
  Either<L, R> tapLeft(void Function(L l) f) {
    fold(f, (_) {});
    return this;
  }

  // ---------------------------------------------------------------------------
  // Extraction
  // ---------------------------------------------------------------------------

  /// Returns true if this is a [Left].
  bool get isLeft => fold((_) => true, (_) => false);

  /// Returns true if this is a [Right].
  bool get isRight => fold((_) => false, (_) => true);

  /// Returns the Right value, or the result of [orElse] if this is a [Left].
  R getOrElse(R Function() orElse) => fold((_) => orElse(), (r) => r);

  /// Returns the Right value, or `null` if this is a [Left].
  R? getOrNull() => fold((_) => null, (r) => r);

  /// Returns the Left value, or `null` if this is a [Right].
  L? getLeftOrNull() => fold((l) => l, (_) => null);

  // ---------------------------------------------------------------------------
  // Object
  // ---------------------------------------------------------------------------

  @override
  String toString() => fold((l) => 'Left($l)', (r) => 'Right($r)');
}

// -----------------------------------------------------------------------------
// Concrete subclasses
// -----------------------------------------------------------------------------

/// Represents the Left side of an [Either] (typically a failure).
class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);

  @override
  T fold<T>(T Function(L l) onLeft, T Function(R r) onRight) => onLeft(value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Left<L, R> && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Left($value)';
}

/// Represents the Right side of an [Either] (typically a success).
class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);

  @override
  T fold<T>(T Function(L l) onLeft, T Function(R r) onRight) => onRight(value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Right<L, R> && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Right($value)';
}

// -----------------------------------------------------------------------------
// Top-level helpers
// -----------------------------------------------------------------------------

/// Creates a [Left] value.
Either<L, R> left<L, R>(L l) => Left<L, R>(l);

/// Creates a [Right] value.
Either<L, R> right<L, R>(R r) => Right<L, R>(r);
