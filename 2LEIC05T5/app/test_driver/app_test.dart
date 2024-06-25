import 'dart:async';
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:gherkin/gherkin.dart';
import 'package:glob/glob.dart';
import 'steps/main_steps.dart';
import 'steps/see_page_steps.dart';


Future<void> main() {
  final config = FlutterTestConfiguration()
    ..features = [
      // Glob(r"test_driver/features/login.feature"),
      Glob(r"test_driver/features/main-page.feature"),
      Glob(r"test_driver/features/register.feature"),
    ]
    ..reporters = [
      ProgressReporter(),
      TestRunSummaryReporter(),
      JsonReporter(path: './report.json'),
      // StdoutReporter(),
    ]
    ..stepDefinitions = [
      seeLoginPage(),
      fillInField(),
      tapButton(),
      seeMainPage(),
      seeText(),
      onMainPage(),
    ]
    ..customStepParameterDefinitions = []
    ..restartAppBetweenScenarios = false
    ..flutterBuildTimeout = const Duration(minutes: 4)
    ..targetAppPath = "test_driver/app.dart";
  return GherkinRunner().execute(config);
}
