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

FutureOr<TimedExecution<String>> timedStringLength(String inputString) =>
    ComposableTimer.fish(
      (String inputString) => ComposableTimer.run(
        'Calculating length',
        () => calculateLength(inputString),
      ),
      (int length) => ComposableTimer.run(
        'String conversion',
        () => stringify(length),
      ),
    )(inputString);

void main(List<String> arguments) async {
  final string = 'Hello, World!';
  final timedLength = await timedStringLength(string);
  print('$string length: ${timedLength.value}\n');
  print(timedLength.description);
  print('Took overall: ${timedLength.time} milliseconds');
}
