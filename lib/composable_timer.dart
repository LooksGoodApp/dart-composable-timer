class TimerM<T> {
  final T value;
  final String log;
  final Duration duration;

  TimerM._(this.value, this.log, this.duration);

  static TimerM<T> identity<T>(T value) => TimerM._(value, '', Duration());

  /// Times a given function with description
  static TimerM<T> run<T>(String description, T Function() fn) {
    final stopwatch = Stopwatch()..start();
    final value = fn();
    return _formatOutput(value, description, stopwatch);
  }

  /// Times a given async function with description
  static Future<TimerM<T>> runAsync<T>(
      String description, Future<T> Function() fn) async {
    final stopwatch = Stopwatch()..start();
    final value = await fn();
    return _formatOutput(value, description, stopwatch);
  }

  /// Creates an instance of the [TimerM] based on a Stopwatch with
  /// a given description
  static TimerM<T> _formatOutput<T>(
          T value, String description, Stopwatch stopwatch) =>
      TimerM._(
        value,
        '$description took ${stopwatch.elapsedMilliseconds} milliseconds\n',
        stopwatch.elapsed,
      );

  /// Composes two instances of the [TimerM]
  TimerM<Z> _composeResult<Z>(TimerM<dynamic> first, TimerM<Z> second) =>
      TimerM._(
        second.value,
        first.log + second.log,
        first.duration + second.duration,
      );

  /// Takes a single function that takes a value of type [T] and
  /// returns an instance of the [TimerM] by composing its result
  /// with a current instance
  TimerM<Z> flatMap<Z>(TimerM<Z> Function(T value) f) =>
      _composeResult(this, f(value));

  /// Takes a function that returns a regular value and returns an instance of
  /// the [TimerM] by using the [identity] function
  TimerM<Z> map<Z>(Z Function(T value) f) =>
      flatMap((value) => identity(f(value)));

  /// Takes a function that returns a regular value and returns an instance of
  /// the [TimerM] by using the [run] function
  TimerM<Z> mapTiming<Z>(String description, Z Function(T value) f) =>
      flatMap((value) => run(description, () => f(value)));

  /// Async version of the [flatMap]
  Future<TimerM<Z>> asyncFlatMap<Z>(
          Future<TimerM<Z>> Function(T value) f) async =>
      _composeResult(this, await f(value));

  /// Async version of the [map]
  Future<TimerM<Z>> asyncMap<Z>(Future<Z> Function(T value) f) async =>
      asyncFlatMap((value) async => identity(await f(value)));

  /// Async version of the [mapTiming]
  Future<TimerM<Z>> asyncMapTiming<Z>(
          String description, Future<Z> Function(T value) f) =>
      asyncFlatMap((value) => runAsync(description, () => f(value)));
}

/// Provides the same functions as the [TimerM] class, but for the
/// [Future<TimerM>]. Used for chaining expressions after using any of the
/// [async] functions on the original class.
extension AsyncFlatMap<T> on Future<TimerM<T>> {
  Future<TimerM<Z>> flatMap<Z>(TimerM<Z> Function(T value) f) async =>
      (await this).flatMap(f);

  Future<TimerM<Z>> map<Z>(Z Function(T value) f) async =>
      (await this).flatMap((value) => TimerM.identity(f(value)));

  Future<TimerM<Z>> mapTiming<Z>(String description, Z Function(T value) f) =>
      flatMap((value) => TimerM.run(description, () => f(value)));

  Future<TimerM<Z>> asyncFlatMap<Z>(
      Future<TimerM<Z>> Function(T value) f) async {
    final awaited = await this;
    final result = await f(awaited.value);
    return awaited.flatMap((_) => result);
  }

  Future<TimerM<Z>> asyncMap<Z>(Future<Z> Function(T value) f) =>
      asyncFlatMap((value) async => TimerM.identity(await f(value)));

  Future<TimerM<Z>> asyncMapTiming<Z>(
          String description, Future<Z> Function(T value) f) =>
      asyncFlatMap((value) => TimerM.runAsync(description, () => f(value)));
}
