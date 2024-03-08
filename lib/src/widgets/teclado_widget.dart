// ignore_for_file: prefer_const_constructors

import 'package:eleicao/src/urna/state/votacao_state.dart';
import 'package:eleicao/src/widgets/function_button.dart';
import 'package:eleicao/src/widgets/number_button.dart';
import 'package:flutter/material.dart';

class TecladoWidget extends StatelessWidget {
  const TecladoWidget({super.key, required this.onPressNumber});
  final void Function(int) onPressNumber;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      color: Colors.grey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text('Colégio Santa Teresinha'),
          Text('Eleição da Michelândia'),
          Padding(
            padding: EdgeInsets.only(left: 20),
            child: Table(
              defaultColumnWidth: FixedColumnWidth(70),
              children: [
                TableRow(children: [
                  NumberButton(number: 1, onPressed: onPressNumber),
                  NumberButton(number: 2, onPressed: onPressNumber),
                  NumberButton(number: 3, onPressed: onPressNumber),
                ]),
                TableRow(children: [
                  NumberButton(number: 4, onPressed: onPressNumber),
                  NumberButton(number: 5, onPressed: onPressNumber),
                  NumberButton(number: 6, onPressed: onPressNumber),
                ]),
                TableRow(children: [
                  NumberButton(number: 7, onPressed: onPressNumber),
                  NumberButton(number: 8, onPressed: onPressNumber),
                  NumberButton(number: 9, onPressed: onPressNumber),
                ]),
                TableRow(children: [
                  Container(),
                  NumberButton(number: 0, onPressed: onPressNumber),
                  Container(),
                ]),
              ],
            ),
          ),
          Row(
            children: [
              FunctionButton(
                onPressed: () {},
                backgroundColor: Colors.white,
                text: 'BRANCO',
              ),
              FunctionButton(
                onPressed: () {
                  numCandidato.value = '';
                  numAtual.value = 0;
                  urlImageCandidato.value = '';
                },
                backgroundColor: Colors.orange,
                text: 'CORRIGE',
              ),
              FunctionButton(
                onPressed: () {},
                backgroundColor: Colors.green,
                text: 'CONFIRMA',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
