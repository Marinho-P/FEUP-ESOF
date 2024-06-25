import 'package:flutter/material.dart';

class BuildTextField extends StatelessWidget {
  final String hintText;
  final IconData? prefixIcon;
  final TextEditingController controller;
  final bool isObscure; // Added for more control over the obscureText property

  const BuildTextField({
    super.key,
    required this.hintText,
    this.prefixIcon,
    required this.controller,
    this.isObscure = false, // Default value set to false
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        hintText: hintText,

        hintStyle: TextStyle(color: Theme.of(context).colorScheme.secondary, fontFamily: 'Ruda'),
        prefixIcon: Icon(prefixIcon, color: Theme.of(context).colorScheme.secondary),
      ),
      style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontFamily: 'Ruda'),
    );
  }
}
