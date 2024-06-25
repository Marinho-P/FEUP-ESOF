import 'package:app/resources/storage_methods.dart';
import 'package:app/screens/main_screen.dart';
import 'package:app/widgets/app_bar.dart';
import 'package:app/widgets/confirm_action.dart';
import 'package:flutter/material.dart';

import '../model/event.dart';
import '../resources/firestore_methods.dart';

class EvaluateEventScreen extends StatefulWidget {
   final Event event;
   const EvaluateEventScreen({super.key, required this.event});

  @override
  EvaluateEventScreenState createState() => EvaluateEventScreenState();
}

class EvaluateEventScreenState extends State<EvaluateEventScreen> {
  int _currentValue = 3;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          const SizedBox(height: 50),
          Expanded(
            child: Container(
              decoration:  BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(56),
                  topRight: Radius.circular(56),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  CustomAppBar(
                      title: 'CleanCity',
                      leftIcon: Icons.arrow_back_ios_new_rounded,
                      leftAction: () async {
                        Navigator.pop(
                          context,
                        );
                      },
                      rightAction: () {}),
                  const SizedBox(
                    height: 15,
                  ),
                   Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Final Results",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontFamily: 'Comfortaa',
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 70,
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image(
                        image: AssetImage("lib/assets/trash_man.png"),
                        width: 150,
                        height: 150,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                   Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Trash Collected:",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontFamily: 'Comfortaa',
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${_currentValue == 1 ? '< $_currentValue' : _currentValue == 50 ? '> $_currentValue' : _currentValue} KG",
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Slider(
                          value: _currentValue.toDouble(),
                          min: 1,
                          max: 50,
                          divisions: 49,

                          thumbColor: Theme.of(context).colorScheme.secondary,
                          inactiveColor: Colors.white, // Can be changed

                          activeColor: Colors.white,
                          onChanged: (value) {
                            setState(() {
                              _currentValue = value.round();
                            });
                          }),
                    ],
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "< 1 KG",
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(width: 100,),
                      Text(
                        "> 50 KG",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 200,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 170,
                        height: 60,
                        child: OutlinedButton(
                          onPressed: () async {
                            Navigator.pop(
                              context,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side:  BorderSide(
                                  color: Theme.of(context).colorScheme.secondary, width: 2),
                            ),
                            fixedSize: const Size(100, 50),
                          ),
                          child:  Text(
                            "Cancel",

                            style: TextStyle(color: Theme.of(context).colorScheme.secondary),

                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 170,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: ()  {
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return ConfirmBox(
                                    leftTap: () {
                                      try {
                                         StorageMethods().updateStatisticsAfterEvent(widget.event, _currentValue.toDouble());
                                         FireStoreMethods().removeEvent(widget.event);

                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const MainScreen(),
                                          ),
                                              (route) => false,
                                        );
                                      } catch (e) {
                                        // Handle exceptions, e.g., show an error dialog
                                        print('Error in updating or removing event: $e');
                                      }
                                    },
                                  );
                                });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:Theme.of(context).colorScheme.secondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            fixedSize: const Size(100, 50),
                          ),
                          child: Text(
                            'Submit',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
