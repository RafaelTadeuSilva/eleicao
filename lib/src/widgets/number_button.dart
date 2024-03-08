// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class NumberButton extends StatelessWidget {
  const NumberButton(
      {super.key, required this.number, required this.onPressed});
  final int number;
  final void Function(int) onPressed;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: const RoundedRectangleBorder(),
              backgroundColor: Colors.black,
              fixedSize: const Size(60, 55)),
          onPressed: () => onPressed(number),
          child: Text(
            number.toString(),
            style: TextStyle(color: Colors.white, fontSize: 20),
          )),
    );
  }
}
