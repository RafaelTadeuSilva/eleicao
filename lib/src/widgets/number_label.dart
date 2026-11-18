import 'dart:async';

import 'package:material_ui/material_ui.dart';

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
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Durations.short4, (timer) {
      visible.value = widget.shouldBlink ? !visible.value : true;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    visible.dispose();
    super.dispose();
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
            width: 80,
            height: 80,
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
                  fontSize: 60,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
