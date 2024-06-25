import 'package:flutter/material.dart';

class ConfirmBox extends StatelessWidget {
  final VoidCallback leftTap;
  const ConfirmBox({super.key, required this.leftTap});

  void _closeBox(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.primary,
      content: Column(mainAxisSize: MainAxisSize.min, children: [
         Text(
          "Are you sure?",
          style: TextStyle(
            fontSize: 24,
            fontFamily: "Comfortaa",
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: 10,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () {
                _closeBox(context);
                leftTap();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side:  BorderSide(color: Theme.of(context).colorScheme.secondary, width: 2),
                ),
                fixedSize: const Size(100, 50),
              ),
              child:  Text(
                "Yes",
                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                _closeBox(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                fixedSize: const Size(100, 50),
              ),
              child:  Text(
                "No",
                style: TextStyle(color: Theme.of(context).colorScheme.onSecondary), // Can be changed
              ),
            ),
          ],
        ),
      ]),
    );
  }
}
