import 'dart:async';

import 'package:eleicao/src/features/urna/pages/votacao_page.dart';
import 'package:eleicao/src/features/urna/state/votacao_state.dart';
import 'package:eleicao/src/models/aluno.dart';
import 'package:flutter/material.dart';

class ProximoEleitorControl {
  late Timer timer;

  void stopTimer() {
    timer.cancel();
  }

  void buscaProximoEleitor(BuildContext context) {
    timer = Timer.periodic(const Duration(seconds: 2), (_) {
      eleitorAtual.value =
          Aluno(id: '10', nome: 'Aluno10', turma: 1, titulo: 1);
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) {
          timer.cancel();
          return const VotacaoPage();
        },
      ));
    });
  }
}
