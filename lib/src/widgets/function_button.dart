// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class FunctionButton extends StatelessWidget {
  const FunctionButton(
      {super.key,
      required this.onPressed,
      required this.text,
      required this.backgroundColor,
      this.size = 60});
  final VoidCallback onPressed;
  final String text;
  final Color backgroundColor;
  final double size;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            fixedSize: Size(size * 2.5, size),
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder()),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.black,
            fontSize: size * .4,
          ),
        ),
      ),
    );
  }
}
