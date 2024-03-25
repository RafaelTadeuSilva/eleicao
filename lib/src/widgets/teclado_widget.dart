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
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final buttonHeight = height * .15;
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
                  defaultColumnWidth: FixedColumnWidth(width * .09 * 3),
                  children: [
                    TableRow(children: [
                      NumberButton(
                        number: 1,
                        onPressed: control.carregaCandidato,
                        size: buttonHeight,
                      ),
                      NumberButton(
                        number: 2,
                        onPressed: control.carregaCandidato,
                        size: buttonHeight,
                      ),
                      NumberButton(
                        number: 3,
                        onPressed: control.carregaCandidato,
                        size: buttonHeight,
                      ),
                    ]),
                    TableRow(children: [
                      NumberButton(
                        number: 4,
                        onPressed: control.carregaCandidato,
                        size: buttonHeight,
                      ),
                      NumberButton(
                        number: 5,
                        onPressed: control.carregaCandidato,
                        size: buttonHeight,
                      ),
                      NumberButton(
                        number: 6,
                        onPressed: control.carregaCandidato,
                        size: buttonHeight,
                      ),
                    ]),
                    TableRow(children: [
                      NumberButton(
                        number: 7,
                        onPressed: control.carregaCandidato,
                        size: buttonHeight,
                      ),
                      NumberButton(
                        number: 8,
                        onPressed: control.carregaCandidato,
                        size: buttonHeight,
                      ),
                      NumberButton(
                        number: 9,
                        onPressed: control.carregaCandidato,
                        size: buttonHeight,
                      ),
                    ]),
                    TableRow(children: [
                      Container(),
                      NumberButton(
                        number: 0,
                        onPressed: control.carregaCandidato,
                        size: buttonHeight,
                      ),
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
                  Flexible(
                    child: FunctionButton(
                      onPressed: control.corrige,
                      backgroundColor: Colors.orange,
                      text: 'CORRIGE',
                      size: buttonHeight,
                    ),
                  ),
                  Expanded(
                      child: FunctionButton(
                    onPressed: () => control.confirma(context),
                    backgroundColor: Colors.green,
                    text: 'CONFIRMA',
                    size: buttonHeight,
                  )),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
