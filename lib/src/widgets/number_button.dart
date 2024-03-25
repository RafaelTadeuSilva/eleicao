// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class NumberButton extends StatelessWidget {
  const NumberButton(
      {super.key,
      required this.number,
      required this.onPressed,
      this.size = 60});
  final int number;
  final void Function(int) onPressed;
  final double size;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: const RoundedRectangleBorder(),
              backgroundColor: Colors.black,
              fixedSize: Size(size, size)),
          onPressed: () {
            onPressed(number);
          },
          child: Text(
            number.toString(),
            style: TextStyle(color: Colors.white, fontSize: size / 2),
          )),
    );
  }
}
