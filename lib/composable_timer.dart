import 'dart:async';

class TimedExecution<T> {
  final T value;
  final int time;
  final String description;

  TimedExecution(this.value, this.time, this.description);
}

abstract class ComposableTimer {
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

  static TimedExecution<T> identity<T>(T value) =>
      TimedExecution(value, 0, '');
}
