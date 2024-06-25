import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final VoidCallback leftAction;
  final VoidCallback rightAction;
  final IconData? leftIcon;
  final IconData? rightIcon;
  final VoidCallback? onModalClosed; // New callback

  const CustomAppBar({
    super.key,
    required this.title,
    required this.leftAction,
    required this.rightAction,
    this.leftIcon,
    this.rightIcon,
    this.onModalClosed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          if (leftIcon != null)
            _buildIconButton(leftIcon!, leftAction, "LeftIcon",context),
          if (leftIcon == null)

            SizedBox(width: 35,height: 35,),

          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary, // Can be changed
              fontFamily: 'Comfortaa',
              fontSize: 27,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (rightIcon != null)
            _buildIconButton(rightIcon!, rightAction, "RightIcon",context),
          if (rightIcon == null)
            const SizedBox(width: 35,height: 35,),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap, String key,BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(

        onTap: () {
          onTap();
          onModalClosed?.call();
        },
        splashColor: Theme.of(context).colorScheme.tertiary.withOpacity(0.9),
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(

            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.4), // Background color
            borderRadius: BorderRadius.circular(30), // Border radius
          ),
          child: Icon(
            key: ValueKey(key),
            icon,

            color: Theme.of(context).colorScheme.onPrimary,
            size: 35,
          ),
        ),
      ),
    );
  }
}