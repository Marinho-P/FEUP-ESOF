import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:gherkin/gherkin.dart';

StepDefinitionGeneric fillInField() {
  return when2<String, String, FlutterWorld>(
    'User fill in {string} {string}',
        (key, value, context) async {
      final field = find.byValueKey(key);
      await FlutterDriverUtils.enterText(
        context.world.driver,
        field,
        value,
      );
    },
  );
}

StepDefinitionGeneric tapButton() {
  return when1<String, FlutterWorld>(
    'User tap {string} button',
        (text, context) async {
      final loginButton = find.text(text);
      await FlutterDriverUtils.tap(context.world.driver, loginButton);
    },
  );
}

StepDefinitionGeneric seeText() {
  return then1<String, FlutterWorld>(
    'User will see {string}',
        (error, context) async {
      final finder = find.text(error);
      context.expectMatch(
        await FlutterDriverUtils.isPresent(context.world.driver, finder),
        true,
      );
    },
  );
}