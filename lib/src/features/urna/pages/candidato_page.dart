// ignore_for_file: prefer_const_constructors

import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/features/urna/functions/functions.dart';
import 'package:eleicao/src/features/urna/state/votacao_state.dart';
import 'package:eleicao/src/widgets/number_label.dart';
import 'package:flutter/material.dart';

class CandidatoPage extends StatefulWidget {
  const CandidatoPage({super.key, this.id});
  final String? id;
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
          const emBranco = false; // numCandidato.value == "BRANCO";
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
                      children: [
                        ValueListenableBuilder(
                          valueListenable: numSeqEleicao,
                          builder: (context, value, child) => Text(
                            Cargo.values
                                .firstWhere((e) => e.codigo == value)
                                .descricao
                                .toUpperCase(),
                            style: TextStyle(fontSize: 25),
                          ),
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
                            builder: (context, value, child) {
                              final nome = numberCandidato == null
                                  ? ''
                                  : value?.nome == null
                                      ? 'CANDIDATO INVÁLIDO'
                                      : value!.nome;
                              return SizedBox(
                                width: 200,
                                height: 60,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    softWrap: true,
                                    nome,
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                    // Visibility(
                    //   visible: !emBranco,
                    //   child: Row(
                    //     children: [
                    //       Text('Partido:'),
                    //       SizedBox(width: 10),
                    //       ValueListenableBuilder(
                    //         valueListenable: candidatoAtual,
                    //         builder: (context, value, child) => Text(
                    //           value?.partido ?? '',
                    //           style: TextStyle(fontSize: 25),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
                Spacer(),
                ValueListenableBuilder(
                  valueListenable: urlImageCandidato,
                  builder: (context, value, child) {
                    return Container(
                      decoration: BoxDecoration(
                          image: urlImageCandidato.value == ''
                              ? null
                              : DecorationImage(
                                  image: NetworkImage(urlImageCandidato.value)),
                          border: Border.all()),
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

  Widget montaNumeros(int? numCandidato) {
    final digitos = candidatoDigitos();
    final listNumberLabel = <Widget>[];

    final numbers = numCandidato?.toString().split('') ?? [''];
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
