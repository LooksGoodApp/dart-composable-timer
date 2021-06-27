# composable_timer

Composable function timer that uses Kleisli composition

## Motivation

Pretty often functions need to be timed. Not less often, those time measurements need to have some label or description with them. 

This package provides set of helpers to do such a thing in a pure, boilerplate-free way using Monadic computation. But fear not! It is a very trivial application of such term and using this package is very straight-forward.

## Getting started

Down are listed all possible timing variations with examples.

### Single function timing

For simple single-function measurement, the `ComposableTimer.run(...)` function is used.

```dart
B fn(A input) => input.toB();

final input = A();
final timedToA = ComposableTimer.run('A to B conversion', () => fn(input));

```

`timedToA` variable will has a type `TimedExecution<B>`. This class holds three values: 

- `value` – input function's obtained value.
- `log` – formatted measurement description, it this case, `A to B conversion time: %number% milliseconds`
- `duration` – `Duration` object that tells how much time it took

### Timing composition

Usually, function timing is composed in some way. The ComposableTimer package provides three ways of composition.

#### Fish

`ComposableTimer.fish(...)` composes two timed functions and returns another function with fused outputs. Intended for functions that already return a `TimedExecution<T>`. The most simplest form of timer composition.

```dart
B fn1(A input) => input.toB();

C fn2(B input) => input.toC();

final composedFunction = ComposableTimer.fish(
  (A a) => ComposableTimer.run('A to B', () => fn1(a)),
  (B b) => ComposableTimer.run('B to C', () => fn2(b)),
);

```

The resulting function would take argument of type `A` and return a `FutureOr<TimedExecution<C>>`.

#### Fish Timing

`ComposableTimer.fishTiming(...)` composes two regular functions that were not intended to be timed and return regular values.

```dart
B fn1(A input) => input.toB();

C fn2(B input) => input.toC();

final composedFunction = ComposableTimer.fishTiming(
  TimerInput(fn1, 'A to B'),
  TimerInput(fn2, 'B to C'),
);

```

#### Fish Mixed

`ComposableTimer.fishMixed(...)` is a combination of the two previous functions. It allows composing non-timer functions further, while having the `fisTiming(...)` API.

```dart
B fn1(A input) => input.toB();

C fn2(B input) => input.toC();

X fn3(C input) => input.toX();

final composedFunction = ComposableTimer.fishMixed(
  ComposableTimer.fishTiming(
    TimerInput(fn1, 'A to B'),
    TimerInput(fn2, 'B to C'),
  ),
  TimerInput(fn3, 'C to X'),
);

```