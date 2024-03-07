// ignore_for_file: prefer_const_constructors

import 'package:eleicao/src/widgets/number_label.dart';
import 'package:eleicao/src/widgets/teclado_widget.dart';
import 'package:flutter/material.dart';

class CandidatoPage extends StatefulWidget {
  const CandidatoPage({super.key});

  @override
  State<CandidatoPage> createState() => _CandidatoPageState();
}

class _CandidatoPageState extends State<CandidatoPage> {
  // final txtNum1 = TextEditingController();
  // final txtNum2 = TextEditingController();
  // final txtNum3 = TextEditingController();
  // final txtNum4 = TextEditingController();
  // final txtNum5 = TextEditingController();
  final lbNum1 = ValueNotifier('1');
  final lbNum2 = ValueNotifier(' ');
  final lbNum3 = ValueNotifier(' ');
  final lbNum4 = ValueNotifier(' ');
  final lbNum5 = ValueNotifier(' ');

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      width: 600,
      height: 600,
      child: body(),
    );
  }

  Widget body() {
    return Column(
      children: [
        Text('SEU VOTO PARA'),
        Text('PREFEITO'),
        Row(
          children: [
            Text('Número:'),
            NumberLabel(lbNum1: lbNum1),
            NumberLabel(lbNum1: lbNum2),
            NumberLabel(lbNum1: lbNum3),
            NumberLabel(lbNum1: lbNum4),
            NumberLabel(lbNum1: lbNum5),
          ],
        ),
      ],
    );
  }
}
