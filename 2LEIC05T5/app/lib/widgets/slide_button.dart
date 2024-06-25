import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';

class SlideBarController extends ValueNotifier<bool> {
  SlideBarController(super.value);
  void toggle() {
    value = !value;
  }
}

class SlideBar extends StatefulWidget {
  final String leftText;
  final String rightText;
  final SlideBarController? controller;
  final VoidCallback? onChange;

  const SlideBar({
    super.key,
    required this.leftText,
    required this.rightText,
    this.controller,
    this.onChange,
  });

  @override
  _SlideBarState createState() => _SlideBarState();
}

class _SlideBarState extends State<SlideBar> {
  @override
  Widget build(BuildContext context) {
    final controller = widget.controller ?? SlideBarController(false);

    return ValueListenableBuilder<bool>(
      valueListenable: controller,
      builder: (context, value, child) {
        return AnimatedToggleSwitch.size(
          textDirection: TextDirection.rtl,
          current: value ? 1 : 0,
          values: const [0, 1],
          indicatorSize: const Size.fromWidth(200),
          borderWidth: 1.0,
          iconOpacity: 0.9,
          selectedIconScale: 1.0,
          height: 50,
          iconAnimationType: AnimationType.onHover,
          styleAnimationType: AnimationType.onHover,
          style: ToggleStyle(

            borderColor: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(20.0),
            backgroundColor: Theme.of(context).colorScheme.primary,
            indicatorColor: Theme.of(context).colorScheme.secondary,
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                spreadRadius: 1,
                blurRadius: 2,
                offset: Offset(0, 1.5),
              ),
            ],
          ),
          customIconBuilder: (context, local, global) {
            final labels = [widget.rightText, widget.leftText];
            final text = labels[local.index];
            return Center(
              child: Text(
                text,
                style: TextStyle(
                  color: Color.lerp(
                    Theme.of(context).colorScheme.onPrimary,
                    Theme.of(context).colorScheme.onSecondary,
                    local.animationValue,
                  ),
                ),
              ),
            );
          },
          onChanged: (i) {
            if (widget.onChange != null) widget.onChange!();
            controller.toggle();
          },
        );
      },
    );
  }
}