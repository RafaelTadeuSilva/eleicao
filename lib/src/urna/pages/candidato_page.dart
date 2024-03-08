// ignore_for_file: prefer_const_constructors

import 'package:eleicao/src/urna/state/votacao_state.dart';
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
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        children: [
          ValueListenableBuilder(
            valueListenable: numCandidato,
            builder: (context, value, child) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SEU VOTO PARA',
                  style: TextStyle(fontSize: 25),
                ),
                Row(
                  children: [
                    SizedBox(width: 60),
                    Text(
                      'PREFEITO',
                      style: TextStyle(fontSize: 25),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Text('Número:'),
                    SizedBox(width: 10),
                    NumberLabel(
                      lbNum:
                          numCandidato.value.split('').elementAtOrNull(0) ?? '',
                      shouldBlink: numAtual.value == 0,
                    ),
                    NumberLabel(
                      lbNum:
                          numCandidato.value.split('').elementAtOrNull(1) ?? '',
                      shouldBlink: numAtual.value == 1,
                    ),
                    NumberLabel(
                      lbNum:
                          numCandidato.value.split('').elementAtOrNull(2) ?? '',
                      shouldBlink: numAtual.value == 2,
                    ),
                    NumberLabel(
                      lbNum:
                          numCandidato.value.split('').elementAtOrNull(3) ?? '',
                      shouldBlink: numAtual.value == 3,
                    ),
                    NumberLabel(
                      lbNum:
                          numCandidato.value.split('').elementAtOrNull(4) ?? '',
                      shouldBlink: numAtual.value == 4,
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Text('Nome:'),
                    SizedBox(width: 10),
                    Text(
                      'Aluno 1',
                      style: TextStyle(fontSize: 25),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Text('Partido:'),
                    SizedBox(width: 10),
                    Text(
                      'Partido 1',
                      style: TextStyle(fontSize: 25),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Spacer(),
          ValueListenableBuilder(
            valueListenable: urlImageCandidato,
            builder: (context, value, child) => Container(
              decoration: BoxDecoration(
                  image: urlImageCandidato.value == ''
                      ? null
                      : DecorationImage(
                          image: AssetImage(urlImageCandidato.value)),
                  border: Border(
                      bottom: BorderSide(width: 1),
                      left: BorderSide(width: 1),
                      top: BorderSide(width: 1),
                      right: BorderSide(width: 1))),
              width: 180,
              height: 200,
            ),
          ),
        ],
      ),
    );
  }
}
