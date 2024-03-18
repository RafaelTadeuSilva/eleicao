import 'package:eleicao/src/features/urna/functions/functions.dart';
import 'package:eleicao/src/features/urna/state/votacao_state.dart';
import 'package:eleicao/src/injector.dart';
import 'package:flutter/material.dart';

class VotacaoControl with ChangeNotifier {
  VotacaoControl() {
    carregaListaEleitores();
    carregaListaCandidatos();
  }

  void carregaCandidato(int num) {
    final digitos = candidatoDigitos();
    if (numAtual.value < digitos) {
      numCandidato.value = int.parse('${numCandidato.value ?? ''}$num');
    }
    numAtual.value = numCandidato.value!.toString().length;
    if (numAtual.value == digitos) {
      buscaCandidato(numCandidato.value!);
    }
    numCandidato.notifyListeners();
  }

  void buscaCandidato(int numCandidato) {
    candidatoAtual.value =
        listCandidato.where((e) => e.numero == numCandidato).firstOrNull;
    if (candidatoAtual.value != null) {
      urlImageCandidato.value = candidatoAtual.value!.urlImage;
    }
  }

  void votoBranco() {
    // numCandidato.value = 'BRANCO';
    numAtual.value = 2;
  }

  void corrige() {
    numCandidato.value = null;
    numAtual.value = 0;
    urlImageCandidato.value = '';
    candidatoAtual.value = null;
  }

  void confirma() {}

  Future<void> carregaListaEleitores() async {
    final list = await alunoRepository.find({});
    listEleitor.clear();
    listEleitor.addAll(list);
  }

  Future<void> carregaListaCandidatos() async {
    final list = await candidatoRepository.find({});
    listCandidato.clear();
    listCandidato.addAll(list ?? []);
  }
}
