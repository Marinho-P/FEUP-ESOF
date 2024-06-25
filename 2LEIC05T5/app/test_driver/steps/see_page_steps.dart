import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:gherkin/gherkin.dart';


StepDefinitionGeneric seeLoginPage() {
  return given<FlutterWorld>(
    'User on the login page',
        (context) async {
      final start = find.text('Get Started');
      final isStart = await FlutterDriverUtils.isPresent(context.world.driver, start);
      if(isStart){
        final goToLogin = find.text('Get Started');
        await FlutterDriverUtils.tap(context.world.driver, goToLogin);
      }
      final register = find.text('Register');
      final isRegister = await FlutterDriverUtils.isPresent(context.world.driver, register);
      if(isRegister){
        final goToLogin = find.text('Back');
        await FlutterDriverUtils.tap(context.world.driver, goToLogin);
      }
      await Future.delayed(const Duration(seconds: 1));
      final mainPage = find.byValueKey("MenuIconButton");
      final isMainPage = await FlutterDriverUtils.isPresent(context.world.driver, mainPage);
      if(isMainPage){
        // TODO logout
        final targetButtonFinder = find.byValueKey("MenuIconButton");
        await FlutterDriverUtils.tap(context.world.driver, targetButtonFinder);
      }
      final loginButton = find.text('Sign In');
      context.expectMatch(
        await FlutterDriverUtils.isPresent(context.world.driver, loginButton),
        true,
      );
    },
  );
}

StepDefinitionGeneric onMainPage() {
  return given<FlutterWorld>(
    'User on main page',
        (context) async {
          final start = find.text('Get Started');
          final isStart = await FlutterDriverUtils.isPresent(context.world.driver, start);
          if(isStart){
            final goToLogin = find.text('Get Started');
            await FlutterDriverUtils.tap(context.world.driver, goToLogin);
          }
          final register = find.text('Register');
          final isRegister = await FlutterDriverUtils.isPresent(context.world.driver, register);
          if(isRegister){
            final goToLogin = find.text('Back');
            await FlutterDriverUtils.tap(context.world.driver, goToLogin);
          }
          await Future.delayed(const Duration(seconds: 1));
          final mainPage = find.byValueKey("MenuIconButton");
          final isMainPage = await FlutterDriverUtils.isPresent(context.world.driver, mainPage);
          if(isMainPage){
            // TODO logout
            final targetButtonFinder = find.byValueKey("MenuIconButton");
            await FlutterDriverUtils.tap(context.world.driver, targetButtonFinder);
          }
          final field1 = find.byValueKey('EmailTextField');
          await FlutterDriverUtils.enterText(
            context.world.driver,
            field1,
            'mansur@gmail.com',
          );
          final field2 = find.byValueKey("PasswordTextField");
          await FlutterDriverUtils.enterText(
            context.world.driver,
            field2,
            'qwerty',
          );
          final loginButton = find.text('Sign In');
          await FlutterDriverUtils.tap(context.world.driver, loginButton);
          final mainPage2 = find.byValueKey("MenuIconButton");
          context.expectMatch(
            await FlutterDriverUtils.isPresent(context.world.driver, mainPage2),
            true,
          );
    },
  );
}

StepDefinitionGeneric seeMainPage() {
  return then<FlutterWorld>(
    'User will be redirected to main page',
        (context) async {
      await Future.delayed(const Duration(seconds: 2));
      final finder = find.byValueKey("AppBarMainScreen");
      context.expectMatch(
        await FlutterDriverUtils.isPresent(context.world.driver, finder),
        true,
      );
    },
  );
}
