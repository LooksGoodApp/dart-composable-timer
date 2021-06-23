import 'dart:async';

/// Timer result type.
///
/// Contains given function return, time it took to execute it and a formatted
/// description with time, such as:
///
/// `Rocket flight time: 274 milliseconds`
class TimedExecution<T> {
  final T value;
  final int time;
  final String description;

  TimedExecution(this.value, this.time, this.description);
}

/// Timer's namespace. It is not intended to be implemented or extended.
///
/// Contains three static functions:
///
/// [run<T>]. Runs a timer on a given function with a given description.
/// [fish<A, B, C>]. Performs a Kleisli composition on two timer functions.
/// [identity<T>]. Returns an identity [TimedExecution<T>] instance.
abstract class ComposableTimer {

  /// Runs a timer on a given function, returning its output, time it took 
  /// and formatted description. 
  /// 
  /// Can be composed using the [fish<A, B, C>] function.
  static FutureOr<TimedExecution<T>> run<T>(
      String description, FutureOr<T> Function() fn) async {
    final stopwatch = Stopwatch()..start();
    final value = await fn();
    return TimedExecution(
      value,
      stopwatch.elapsedMilliseconds,
      '$description time: ${stopwatch.elapsedMilliseconds} milliseconds\n',
    );
  }

  /// Composes two [run<T>] functions, returning another function. 
  /// 
  /// For `fish<A, B, C>`, their composition has the following types:
  /// 
  /// `(A -> B) -> (B -> C) -> (A -> C)`
  static FutureOr<TimedExecution<C>> Function(A) fish<A, B, C>(
          FutureOr<TimedExecution<B>> Function(A) first,
          FutureOr<TimedExecution<C>> Function(B) second) =>
      (A input) async {
        final firstValue = await first(input);
        final secondValue = await second(firstValue.value);
        return TimedExecution(
          secondValue.value,
          firstValue.time + secondValue.time,
          firstValue.description + secondValue.description,
        );
      };

  /// Returns an identity morphism with the given value of type [T]
  static TimedExecution<T> identity<T>(T value) => TimedExecution(value, 0, '');
}
