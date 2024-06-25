

import 'package:app/theme/theme_provider.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

import 'package:provider/provider.dart';
import '../screens/main_screen.dart';


class CustomDatePicker extends StatefulWidget {
  final DateTime date;
  final ValueChanged<DateTime> onChanged;
  const CustomDatePicker({
    required this.date,
    required this.onChanged,
    super.key,
  });

  @override
  CustomDatePickerState createState() => CustomDatePickerState();
}

class CustomDatePickerState extends State<CustomDatePicker> {
  late DateTime selectedDateTime;

  @override
  void initState(){
    selectedDateTime = widget.date;
    DateTime firstDate = DateTime.now();
    if (selectedDateTime.isBefore(firstDate)) {
      selectedDateTime = firstDate;
    }
  }

  showDatePicker() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final currentMode = themeProvider.seeMode();
    ThemeData datePickerTheme;
    if(currentMode == 'light'){
      datePickerTheme = ThemeData(
        primarySwatch: Colors.green,
        dialogBackgroundColor: Colors.green.shade50,
        colorScheme: ColorScheme.light(
          primary: Colors.green.shade800, // header background color
          onPrimary: Colors.white, // header text color
          onSurface: Colors.green.shade900, // body text color
        ),
      );
    }else {
      datePickerTheme = ThemeData(
        primarySwatch: Colors.green, // A darker shade of green
        dialogBackgroundColor: Theme.of(context).colorScheme.primary, // A dark gray color for the dialog background
        colorScheme: ColorScheme.dark(
          primary: Colors.green.shade900, // A darker shade of green for header background color
          onPrimary: Colors.white, // White text color for header text
          onSurface: Colors.green.shade800, // A slightly lighter shade of green for body text color
        ),
      );
    }


    DateTime? dateTime = await showOmniDateTimePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
      is24HourMode: true,
      isShowSeconds: false,
      minutesInterval: 1,
      secondsInterval: 1,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      constraints: const BoxConstraints(
        maxWidth: 350,
        maxHeight: 650,
      ),
      transitionBuilder: (context, anim1, anim2, child) {
        return Theme(
          data: datePickerTheme, // Apply the theme to the picker
          child: FadeTransition(
            opacity: anim1.drive(Tween(begin: 0.0, end: 1.0)),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: true,
      selectableDayPredicate: (dateTime) {
        // Disable 25th Feb 2023
        if (dateTime == DateTime(2023, 2, 25)) {
          return false;
        } else {
          return true;
        }
      },
    );

    if(dateTime != null){
      setState(() {
        selectedDateTime = dateTime;
        widget.onChanged(dateTime);
      });
    }
  }
    @override
    Widget build(BuildContext context) {
      return GestureDetector(
        onTap: showDatePicker,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Container(
            height: 63,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: Theme.of(context).colorScheme.onPrimary, // Adjust the color and opacity as needed
                width: 1, // Adjust the width as needed
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.calendar_today_outlined),
                ),
                const SizedBox(width: 8),
                Text(
                  "Event starts ${selectedDateTime.day.toString().padLeft(2, '0')}/${selectedDateTime.month.toString().padLeft(2, '0')}/${selectedDateTime.year} at ${selectedDateTime.hour.toString().padLeft(2, '0')}:${selectedDateTime.minute.toString().padLeft(2, '0')}",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }