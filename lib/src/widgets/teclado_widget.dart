// ignore_for_file: prefer_const_constructors

import 'package:eleicao/src/features/urna/controllers/votacao_control.dart';
import 'package:eleicao/src/widgets/function_button.dart';
import 'package:eleicao/src/widgets/number_button.dart';
import 'package:flutter/material.dart';

class TecladoWidget extends StatelessWidget {
  const TecladoWidget(
    this.control, {
    super.key,
  });
  final VotacaoControl control;
  // final void Function(int) onPressNumber;
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
            padding: EdgeInsets.only(left: 30),
            child: Table(
              defaultColumnWidth: FixedColumnWidth(70),
              children: [
                TableRow(children: [
                  NumberButton(number: 1, onPressed: control.carregaCandidato),
                  NumberButton(number: 2, onPressed: control.carregaCandidato),
                  NumberButton(number: 3, onPressed: control.carregaCandidato),
                ]),
                TableRow(children: [
                  NumberButton(number: 4, onPressed: control.carregaCandidato),
                  NumberButton(number: 5, onPressed: control.carregaCandidato),
                  NumberButton(number: 6, onPressed: control.carregaCandidato),
                ]),
                TableRow(children: [
                  NumberButton(number: 7, onPressed: control.carregaCandidato),
                  NumberButton(number: 8, onPressed: control.carregaCandidato),
                  NumberButton(number: 9, onPressed: control.carregaCandidato),
                ]),
                TableRow(children: [
                  Container(),
                  NumberButton(number: 0, onPressed: control.carregaCandidato),
                  Container(),
                ]),
              ],
            ),
          ),
          Row(
            children: [
              // FunctionButton(
              //   onPressed: control.votoBranco,
              //   backgroundColor: Colors.white,
              //   text: 'BRANCO',
              // ),
              FunctionButton(
                onPressed: control.corrige,
                backgroundColor: Colors.orange,
                text: 'CORRIGE',
              ),
              FunctionButton(
                onPressed: () => control.confirma(context),
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
