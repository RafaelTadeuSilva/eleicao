// ignore_for_file: prefer_const_constructors

import 'package:eleicao/src/features/urna/functions/functions.dart';
import 'package:eleicao/src/features/urna/state/votacao_state.dart';
import 'package:eleicao/src/widgets/number_label.dart';
import 'package:flutter/material.dart';

class CandidatoPage extends StatefulWidget {
  const CandidatoPage({super.key});

  @override
  State<CandidatoPage> createState() => _CandidatoPageState();
}

class _CandidatoPageState extends State<CandidatoPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      decoration: BoxDecoration(
          color: Colors.grey,
          border: Border(bottom: BorderSide(color: Colors.black, width: 3))),
      child: body(),
    );
  }

  Widget body() {
    return ValueListenableBuilder(
        valueListenable: numCandidato,
        builder: (context, numberCandidato, child) {
          final emBranco = numCandidato.value == "BRANCO";
          return Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SEU VOTO PARA',
                      style: TextStyle(fontSize: 25),
                    ),
                    Row(
                      children: const [
                        SizedBox(width: 60),
                        Text(
                          'PREFEITO',
                          style: TextStyle(fontSize: 25),
                        ),
                      ],
                    ),
                    Visibility(
                      visible: emBranco,
                      child: Column(
                        children: const [
                          SizedBox(height: 25),
                          Text(
                            'VOTO EM BRANCO',
                            style: TextStyle(fontSize: 45),
                          ),
                          SizedBox(height: 24),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                    Visibility(
                      visible: !emBranco,
                      child: montaNumeros(numberCandidato),
                    ),
                    SizedBox(height: 5),
                    Visibility(
                      visible: !emBranco,
                      child: Row(
                        children: [
                          Text('Nome:'),
                          SizedBox(width: 10),
                          ValueListenableBuilder(
                            valueListenable: candidatoAtual,
                            builder: (context, value, child) => Text(
                              value?.nome ?? '',
                              style: TextStyle(fontSize: 25),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                    Visibility(
                      visible: !emBranco,
                      child: Row(
                        children: [
                          Text('Partido:'),
                          SizedBox(width: 10),
                          ValueListenableBuilder(
                            valueListenable: candidatoAtual,
                            builder: (context, value, child) => Text(
                              value?.partido ?? '',
                              style: TextStyle(fontSize: 25),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Spacer(),
                ValueListenableBuilder(
                  valueListenable: urlImageCandidato,
                  builder: (context, value, child) {
                    return emBranco
                        ? Container()
                        : Container(
                            decoration: BoxDecoration(
                                image: urlImageCandidato.value == ''
                                    ? null
                                    : DecorationImage(
                                        image: AssetImage(
                                            urlImageCandidato.value)),
                                border: Border(
                                    bottom: BorderSide(width: 1),
                                    left: BorderSide(width: 1),
                                    top: BorderSide(width: 1),
                                    right: BorderSide(width: 1))),
                            width: 180,
                            height: 200,
                          );
                  },
                ),
              ],
            ),
          );
        });
  }

  Widget montaNumeros(String numCandidato) {
    final digitos = candidatoDigitos();
    final listNumberLabel = <Widget>[];
    final numbers = numCandidato.split('');
    for (int i = 0; i < digitos; i++) {
      listNumberLabel.add(NumberLabel(
        lbNum: numbers.elementAtOrNull(i) ?? '',
        shouldBlink: numAtual.value == i,
      ));
    }
    return Row(
      children: [Text('Número:'), SizedBox(width: 10), ...listNumberLabel],
    );
  }
}
