import 'package:flutter/material.dart';

void showErrorMessage(BuildContext context, String text, {Duration duration = const Duration(seconds: 3), Color backgroundColor = const Color(0xFF0A2E36)}) {

  final snackBar = SnackBar(
    content: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
            fontFamily: 'Ruda'
        ),
    ),
    duration: duration,
    backgroundColor: backgroundColor,
    action: SnackBarAction(
      label: 'Dismiss',
      onPressed: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
