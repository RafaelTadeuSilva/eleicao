import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/features/urna/functions/functions.dart';
import 'package:eleicao/src/features/urna/pages/proximo_eleitor_page.dart';
import 'package:eleicao/src/features/urna/state/votacao_state.dart';
import 'package:eleicao/src/injector.dart';
import 'package:eleicao/src/models/voto.dart';
import 'package:flutter/material.dart';

class VotacaoControl with ChangeNotifier {
  List<Voto> votoAtual = [];
  final zone = prefs.getInt('zone');

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
      buscaCandidato(numCandidato.value!, numSeqEleicao.value);
    }
    numCandidato.notifyListeners();
  }

  void buscaCandidato(int numCandidato, int seqEleicao) {
    candidatoAtual.value = listCandidato
        .where((e) => e.numero == numCandidato && e.cargo.codigo == seqEleicao)
        .firstOrNull;
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

  void confirma(BuildContext context) {
    if (candidatoAtual.value != null) {
      votoAtual.add(Voto(
        cargo: Cargo.values
            .firstWhere((e) => e.codigo == numSeqEleicao.value)
            .descricao,
        nome: candidatoAtual.value!.nome,
        matricula: candidatoAtual.value!.id,
        zone: zone!,
      ));
      corrige();
      numSeqEleicao.value++;
      if (numSeqEleicao.value > 1) {
        gravaVoto();
        fimVotacao(context);
      }
    }
    print(numSeqEleicao.value);
  }

  Future<void> gravaVoto() async {
    for (var voto in votoAtual) {
      await votoRepository.create(voto);
    }
    votoAtual.clear();
  }

  Future<void> fimVotacao(BuildContext context) async {
    numSeqEleicao.value = 1;
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Scaffold(
              body: Center(
                child: Text(
                  'FIM',
                  style: TextStyle(fontSize: 200),
                ),
              ),
            )));
    Future.delayed(Duration(seconds: 3)).whenComplete(
        () => Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => const ProximoEleitorPage(),
            )));
  }

  Future<void> carregaListaEleitores() async {
    final list = await alunoRepository.find({});
    listEleitor.clear();
    listEleitor.addAll(list);
  }

  Future<void> carregaListaCandidatos() async {
    final list = await candidatoRepository.find({});
    listCandidato.clear();
    final listFiltrada = list?.where((e) => e.zone == zone) ?? [];
    listCandidato.addAll(listFiltrada);
  }
}
