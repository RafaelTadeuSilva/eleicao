import 'package:eleicao/src/urna/enums/cargo.dart';
import 'package:eleicao/src/urna/functions/functions.dart';
import 'package:eleicao/src/urna/models/candidato.dart';
import 'package:eleicao/src/urna/state/votacao_state.dart';

class VotacaoControl {
  void carregaCandidato(int num) {
    final digitos = candidatoDigitos();
    if (numAtual.value < digitos) {
      numCandidato.value = '${numCandidato.value}$num';
    }
    numAtual.value = numCandidato.value.length;
    if (numAtual.value == digitos) {
      urlImageCandidato.value = 'assets/images/candidato.png';
      buscaCandidato(numCandidato.value);
    }
    numCandidato.notifyListeners();
  }

  void buscaCandidato(String numCandidato) {
    candidatoAtual.value = listCandidato.firstWhere((e) => e.id == numCandidato,
        orElse: () => Candidato(
            id: '',
            nome: 'VOTO NULO',
            cargo: Cargo.nulo,
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
}
