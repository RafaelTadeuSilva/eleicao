// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class FunctionButton extends StatelessWidget {
  const FunctionButton(
      {super.key,
      required this.onPressed,
      required this.text,
      required this.backgroundColor});
  final VoidCallback onPressed;
  final String text;
  final Color backgroundColor;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            fixedSize: Size(110, 60),
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder()),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
