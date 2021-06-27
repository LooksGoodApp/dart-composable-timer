import 'dart:async';

typedef TimedFunction<A, B> = FutureOr<TimedExecution<B>> Function(A);

/// Timer result type.
///
/// Contains given function return, time it took to execute it and a formatted
/// description with time, such as:
///
/// `Rocket flight time: 274 milliseconds`
class TimedExecution<T> {
  final T value;
  final String log;
  final Duration duration;

  TimedExecution(this.value, this.log, this.duration);
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
        first.log + second.log,
        first.duration + second.duration,
      );

  static TimedFunction<A, B> _timeInput<A, B>(TimerInput<A, B> input) =>
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
      '$description time: ${stopwatch.elapsedMilliseconds} milliseconds\n',
      stopwatch.elapsed,
    );
  }

  /// Composes two [run<T>] functions, returning another function.
  ///
  /// For `fish<A, B, C>`, their composition has the following types:
  ///
  /// `(A -> B) -> (B -> C) -> (A -> C)`
  static TimedFunction<A, C> fish<A, B, C>(
    TimedFunction<A, B> first,
    TimedFunction<B, C> second,
  ) =>
      (A input) async {
        final firstValue = await first(input);
        return _composeResult<C>(firstValue, await second(firstValue.value));
      };

  /// Composes two regular functions through the [TimerInput] tuple.
  ///
  /// Useful when there is a need to timed functions that were not intended to
  /// be timed.
  static TimedFunction<A, C> fishTiming<A, B, C>(
    TimerInput<A, B> first,
    TimerInput<B, C> second,
  ) =>
      fish<A, B, C>(_timeInput(first), _timeInput(second));

  /// Composes mixed timer functions.
  ///
  /// Useful for pipelining the [fishTimer(...)] functions without wrapping
  /// regular functions by hand.
  static TimedFunction<A, C> fishMixed<A, B, C>(
    TimedFunction<A, B> first,
    TimerInput<B, C> second,
  ) =>
      fish<A, B, C>(first, _timeInput(second));

  /// Returns an identity morphism with the given value of type [T]
  static FutureOr<TimedExecution<T>> identity<T>(T value) =>
      TimedExecution(value, '', Duration());
}
