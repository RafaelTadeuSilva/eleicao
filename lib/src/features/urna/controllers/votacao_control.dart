import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/features/urna/functions/functions.dart';
import 'package:eleicao/src/features/urna/state/votacao_state.dart';
import 'package:eleicao/src/injector.dart';
import 'package:eleicao/src/models/candidato.dart';
import 'package:flutter/material.dart';

class VotacaoControl with ChangeNotifier {
  VotacaoControl() {
    carregaListaEleitores();
    carregaListaCandidatos();
  }

  void carregaCandidato(int num) {
    final digitos = candidatoDigitos();
    if (numAtual.value < digitos) {
      numCandidato.value = '${numCandidato.value}$num';
    }
    numAtual.value = numCandidato.value.length;
    if (numAtual.value == digitos) {
      buscaCandidato(numCandidato.value);
      urlImageCandidato.value =
          candidatoAtual.value!.urlImage; //'assets/images/candidato.png';
    }
    numCandidato.notifyListeners();
  }

  void buscaCandidato(String numCandidato) {
    candidatoAtual.value = listCandidato.firstWhere((e) => e.id == numCandidato,
        orElse: () => Candidato(
            matricula: '',
            id: '',
            nome: 'CANDIDATO INVÁLIDO',
            cargo: Cargo.prefeito,
            partido: '',
            urlImage: ''));
  }

  void votoBranco() {
    numCandidato.value = 'BRANCO';
    numAtual.value = 2;
  }

  void corrige() {
    numCandidato.value = '';
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
    listCandidato.addAll(list);
  }
}
