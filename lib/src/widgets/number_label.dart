import 'dart:async';

import 'package:flutter/material.dart';

class NumberLabel extends StatefulWidget {
  const NumberLabel({
    super.key,
    this.shouldBlink = false,
    required this.lbNum,
  });

  final String lbNum;
  final bool shouldBlink;
  @override
  State<NumberLabel> createState() => _NumberLabelState();
}

class _NumberLabelState extends State<NumberLabel> {
  final visible = ValueNotifier(true);
  @override
  void initState() {
    Timer.periodic(Durations.short4, (timer) {
      if (widget.shouldBlink) {
        visible.value = !visible.value;
      } else {
        visible.value = true;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: ValueListenableBuilder(
        valueListenable: visible,
        builder: (context, value, child) => Visibility(
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          visible: visible.value,
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(),
                    top: BorderSide(),
                    left: BorderSide(),
                    right: BorderSide())),
            child: Center(
              child: Text(
                widget.lbNum,
                style: const TextStyle(
                  height: 0.1,
                  fontSize: 40,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
