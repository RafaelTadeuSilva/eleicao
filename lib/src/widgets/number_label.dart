import 'package:flutter/material.dart';

class NumberLabel extends StatelessWidget {
  const NumberLabel({
    super.key,
    required this.lbNum1,
  });

  final ValueNotifier<String> lbNum1;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(),
              top: BorderSide(),
              left: BorderSide(),
              right: BorderSide())),
      child: Center(
        child: Text(
          lbNum1.value,
          style: TextStyle(
            height: 0.1,
            fontSize: 90,
          ),
        ),
      ),
    );
  }
}
