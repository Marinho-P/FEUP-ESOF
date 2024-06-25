import 'dart:core';

import 'package:flutter/material.dart';

class CustomSwitchController extends ValueNotifier<bool> {
  CustomSwitchController(super.value);
  void toggle() {
    value = !value;
  }
}

class CustomSwitch extends StatefulWidget {
  final CustomSwitchController controller;

  const CustomSwitch({super.key, required this.controller});
  @override
  CustomSwitchState createState() => CustomSwitchState();
}

class CustomSwitchState extends State<CustomSwitch> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: widget.controller,
        builder: (context, value, child) {
          return Switch(

              activeColor: Theme.of(context).colorScheme.secondary,
              activeTrackColor: Theme.of(context).colorScheme.primary,
              value: widget.controller.value,
              onChanged: (changed) {
                setState(() {
                  widget.controller.toggle();
                });
              });
        });
  }
}
