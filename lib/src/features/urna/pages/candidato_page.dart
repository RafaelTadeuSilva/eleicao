// ignore_for_file: prefer_const_constructors

import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/features/urna/functions/functions.dart';
import 'package:eleicao/src/features/urna/state/votacao_state.dart';
import 'package:eleicao/src/models/candidato.dart';
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
      decoration: BoxDecoration(
          color: Colors.grey,
          border: Border(bottom: BorderSide(color: Colors.black, width: 3))),
      child: body(),
    );
  }

  Widget body() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.constrainWidth();

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
                          style: TextStyle(fontSize: 40),
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
                                style: TextStyle(fontSize: 28),
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
                              Text(
                                'Nome:',
                                style: TextStyle(fontSize: 25),
                              ),
                              SizedBox(width: 10),
                              ValueListenableBuilder(
                                valueListenable: candidatoAtual,
                                builder: (context, value, child) {
                                  final nome = numberCandidato == null
                                      ? ''
                                      : value?.nome == null
                                          ? 'CANDIDATO INVÁLIDO'
                                          : value!.nome;
                                  return ConstrainedBox(
                                    constraints: BoxConstraints(
                                        minHeight: 80, maxWidth: width * .4),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        softWrap: true,
                                        nome,
                                        style: TextStyle(fontSize: 25),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: !emBranco,
                          child: candidatoAtual.value?.nomeVice == null
                              ? Container()
                              : Row(
                                  children: [
                                    Text(
                                      'Vice:',
                                      style: TextStyle(fontSize: 25),
                                    ),
                                    SizedBox(width: 10),
                                    ValueListenableBuilder(
                                      valueListenable: candidatoAtual,
                                      builder: (context, value, child) {
                                        final nome = numberCandidato == null
                                            ? ''
                                            : value?.nomeVice ?? '';
                                        return ConstrainedBox(
                                          constraints: BoxConstraints(
                                              minHeight: 80,
                                              maxWidth: width * .4),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              softWrap: true,
                                              nome,
                                              style: TextStyle(fontSize: 25),
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
                          width: width * .4,
                          height: width * .5,
                          decoration: BoxDecoration(
                              image: urlImageCandidato.value == ''
                                  ? null
                                  : imageCandidato(candidatoAtual.value),
                              border: Border.all()),
                        );
                      },
                    ),
                  ],
                ),
              );
            });
      },
    );
  }

  DecorationImage imageCandidato(Candidato? value) {
    final isPrefeito =
        switch (value?.cargo) { Cargo.prefeito => true, _ => false };

    return DecorationImage(
        fit: BoxFit.none,
        scale: 3,
        alignment: !isPrefeito ? Alignment.topCenter : Alignment.center,
        image: NetworkImage(urlImageCandidato.value));
  }

  Widget montaNumeros(int? numCandidato) {
    final digitos = candidatoDigitos();
    final listNumberLabel = <Widget>[];

    final numbers =
        numCandidato?.toString().padLeft(numAtual.value, '0').split('') ?? [''];

    for (int i = 0; i < digitos; i++) {
      listNumberLabel.add(NumberLabel(
        lbNum: numbers.elementAtOrNull(i) ?? '',
        shouldBlink: numAtual.value == i,
      ));
    }
    return Row(
      children: [
        Text(
          'Número:',
          style: TextStyle(fontSize: 25),
        ),
        SizedBox(width: 10),
        ...listNumberLabel
      ],
    );
  }
}
