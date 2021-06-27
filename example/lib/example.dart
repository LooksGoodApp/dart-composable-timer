import 'dart:async';

import 'package:composable_timer/composable_timer.dart';

int calculateLength(String string) {
  // do some expensive work
  List.generate(10000000, (i) => i).reduce((value, element) => value + element);
  return string.length;
}

Future<String> stringify(int number) async {
  // do some async work
  await Future.delayed(Duration(milliseconds: 200));
  return number.toString();
}

String sideEffects(String string) {
  // perform some side effects
  print('Hello from sideEffects!\n');
  List.generate(100000, (i) => i).reduce((value, element) => value + element);
  return string;
}

FutureOr<TimedExecution<String>> timedStringLength(String inputString) =>
    ComposableTimer.fishMixed(
      ComposableTimer.fishTiming(
        TimerInput(calculateLength, 'Calculating length'),
        TimerInput(stringify, 'String conversion'),
      ),
      TimerInput(sideEffects, 'Side effects')
    )(inputString);

void main(List<String> arguments) async {
  final string = 'Hello, World!';
  final timedLength = await timedStringLength(string);
  print('$string length: ${timedLength.value}\n');
  print(timedLength.log);
  print('Took overall: ${timedLength.duration.inMilliseconds} milliseconds');
}
