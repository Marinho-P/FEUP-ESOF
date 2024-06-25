import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTimePicker extends StatefulWidget {
    final Duration durationFinal;
    final ValueChanged<Duration> onChanged;
    const CustomTimePicker({
    required this.durationFinal,
      required this.onChanged,
    super.key,
  });

  @override
  _CustomTimePickerState createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {

  late Duration duration;

  @override
  void initState() {
    super.initState();
    duration = widget.durationFinal;
    print("duration: $duration");
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));

    return 'Duration of the event $hours:$minutes';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showTimePicker(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Container(
          height: 63,
          decoration: BoxDecoration(
            border: Border.all(color:Theme.of(context).colorScheme.onPrimary,width: 1),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.access_time),
              ),
              const SizedBox(width: 8),
                Text(
                  formatDuration(duration),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
            ],
          ),
        ),
      )
    );
  }

  void _showTimePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {}, // Prevents closing the dialog when tapping inside
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.height * 0.4,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(

                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.hm,
                  initialTimerDuration: duration,
                  onTimerDurationChanged: (newDuration) {
                    setState(() {
                      duration = newDuration;
                      widget.onChanged(newDuration);
                    });
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}