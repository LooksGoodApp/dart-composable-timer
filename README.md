# composable_timer

Composable function timer that uses Kleisli compositing

## Motivation

Pretty often functions need to be timed. Not less often, those time measurements need to have some label or description with them. 

This package provides set of helpers to do such a thing in a pure, boilerplate-free way using Monadic computation. But fear not! It is a very trivial application of such term and using this package is very straight-forward.

## Getting started

Down are listed all possible timing variations with examples.

### Single function timing

For simple single-function measurement, the `ComposableTimer.run(...)` function is used.

```dart
A fn(B input) => input.toA();

final input = B();
final timedToA = ComposableTimer.run('B to A conversion', () => fn(input));
```

`timedToA` variable will has a type `TimedExecution<A>`. This class holds three values: 

- `value` – input function's obtained value.
- `log` – formatted measurement description, it this case, `B to A conversion time: %number% milliseconds`
- `duration` – `Duration` object that tells how much time it took

### Multiple function timing

Usually, function timing is composed in some way. The ComposableTimer package provides three ways of composition.