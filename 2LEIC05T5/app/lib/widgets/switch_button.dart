import 'package:flutter/material.dart';

class SwitchButton extends StatefulWidget {
  final bool initialValue; // Accepts the initial value as a parameter
  final ValueChanged<bool> onChanged; // Callback function to notify the parent widget about value changes
  final Widget Function(bool)? buildIcon;
  final double distance;
  final String text;
  // Optional function to build the icon based on the current value
  const SwitchButton({super.key, 
    required this.text,
    required this.initialValue,
    required this.onChanged,
    this.buildIcon,
    required this.distance,
  }); // Constructor to initialize the value

  @override
  _SwitchButtonState createState() => _SwitchButtonState();
}

class _SwitchButtonState extends State<SwitchButton> {
  late bool isOn; // Variable to track the state of the switch
  Color originalColor = const Color(0xFFD0FCB3);
  @override
  void initState() {
    super.initState();
    // Initialize the state with the initial value passed from the parent widget
    isOn = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    originalColor = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        if (widget.buildIcon != null)
          widget.buildIcon!(isOn),
        if(widget.text.isNotEmpty)
          const SizedBox(width: 50,),
          Text(
            widget.text,
            style: const TextStyle(
                fontSize: 20.0, fontWeight: FontWeight.w500),
          ),
        SizedBox(width: widget.distance,),
        Switch(

          activeColor: Theme.of(context).colorScheme.secondary,
          activeTrackColor: Color.fromRGBO(
            (originalColor.red * 0.8).round(),
            (originalColor.green * 0.8).round(),
            (originalColor.blue * 0.8).round(),
            1,
          ),
          value: isOn,
          onChanged: (newValue) {
            setState(() {
              isOn = newValue; // Update the state of the switch
              widget.onChanged(isOn); // Notify the parent widget about the value change
            });
          },
        ),
      ],
    );
  }
}