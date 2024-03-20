import 'dart:async';

import 'package:eleicao/src/features/urna/pages/votacao_page.dart';
import 'package:eleicao/src/features/urna/state/votacao_state.dart';
import 'package:eleicao/src/injector.dart';
import 'package:eleicao/src/models/aluno.dart';
import 'package:flutter/material.dart';

class ProximoEleitorControl {
  late Timer timer;

  void stopTimer() {
    timer.cancel();
  }

  void buscaProximoEleitor(BuildContext context) {
    timer = Timer.periodic(const Duration(seconds: 2), (_) async {
      final urna = prefs.getInt('terminal');
      await liberacaoUrnaRepository
          .proximaLiberacao(urna ?? 0)
          .then((proxEleitor) {
        if (proxEleitor != null) {
          eleitorAtual.value = Aluno(
              id: proxEleitor.matricula,
              nome: proxEleitor.nome,
              turma: proxEleitor.turma,
              titulo: proxEleitor.titulo);

          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) {
              timer.cancel();
              liberacaoUrnaRepository.finalizaLiberacao(proxEleitor);
              return const VotacaoPage();
            },
          ));
        }
      });
    });
  }
}
