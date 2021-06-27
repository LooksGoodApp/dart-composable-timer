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

/// Tuple wrapper used to provide a singe input to [fishTiming] and [fishMixed]
/// functions.
class TimerInput<A, B> {
  final FutureOr<B> Function(A input) fn;
  final String description;

  TimerInput(this.fn, this.description);
}

/// Timer's namespace. It is not intended to be implemented or extended.
///
/// Contains three static functions:
///
/// [run<T>]. Runs a timer on a given function with a given description.
/// [fish<A, B, C>]. Performs a Kleisli composition on two timer functions.
/// [identity<T>]. Returns an identity [TimedExecution<T>] instance.
abstract class ComposableTimer {
  
  static TimedExecution<T> _composeResult<T>(
          TimedExecution<dynamic> first, TimedExecution<T> second) =>
      TimedExecution(
        second.value,
        first.time + second.time,
        first.description + second.description,
      );

  static FutureOr<TimedExecution<B>> Function(A input) _timeInput<A, B>(
          TimerInput<A, B> input) =>
      (value) => run(input.description, () => input.fn(value));

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
        return _composeResult<C>(firstValue, await second(firstValue.value));
      };

  /// Composes two regular functions through the [TimerInput] tuple.
  ///
  /// Useful when there is a need to timed functions that were not intended to
  /// be timed.
  static FutureOr<TimedExecution<C>> Function(A) fishTiming<A, B, C>(
    TimerInput<A, B> first,
    TimerInput<B, C> second,
  ) =>
      fish<A, B, C>(_timeInput(first), _timeInput(second));

  /// Composes mixed timer functions.
  ///
  /// Useful for pipelining the [fishTimer(...)] functions without wrapping
  /// regular functions by hand.
  static FutureOr<TimedExecution<C>> Function(A) fishMixed<A, B, C>(
    FutureOr<TimedExecution<B>> Function(A) first,
    TimerInput<B, C> second,
  ) =>
      fish<A, B, C>(first, _timeInput(second));

  /// Returns an identity morphism with the given value of type [T]
  static TimedExecution<T> identity<T>(T value) => TimedExecution(value, 0, '');
}
