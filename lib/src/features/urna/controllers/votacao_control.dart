import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/features/urna/functions/functions.dart';
import 'package:eleicao/src/features/urna/pages/proximo_eleitor_page.dart';
import 'package:eleicao/src/features/urna/state/votacao_state.dart';
import 'package:eleicao/src/functions/audio_player.dart';
import 'package:eleicao/src/injector.dart';
import 'package:eleicao/src/models/voto.dart';
import 'package:flutter/material.dart';

class VotacaoControl with ChangeNotifier {
  List<Voto> votoAtual = [];
  final zone = prefs.getInt('zone');
  int etapaIndex = 0;

  VotacaoControl() {
    etapaIndex = 0;
    if (tipoEleicao.isEmpty) {
      tipoEleicao.add(Cargo.byModalidade(modalidadeEleicao.value).first.codigo);
    }
    numSeqEleicao.value = tipoEleicao.first;
    corrige();
    carregaListaEleitores();
    carregaListaCandidatos();
  }

  void carregaCandidato(int num) {
    final digitos = candidatoDigitos();
    final displayedNumbers = '${numCandidato.value ?? ''}$num';
    if (numAtual.value < digitos) {
      numCandidato.value = int.parse(displayedNumbers);
      AudioFiles.tecla.play();
    }
    numAtual.value = displayedNumbers.length;
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
      urlImageVice.value = candidatoAtual.value!.urlImageVice ?? '';
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
    urlImageVice.value = '';
    candidatoAtual.value = null;
  }

  void confirma(BuildContext context) {
    if (candidatoAtual.value != null) {
      votoAtual.add(Voto(
        cargo: Cargo.getCargoByCodigo(numSeqEleicao.value).descricao,
        nome: candidatoAtual.value!.nome,
        matricula: candidatoAtual.value!.matricula,
        zone: zone ?? 0,
      ));
      corrige();
      etapaIndex++;
      if (etapaIndex < tipoEleicao.length) {
        numSeqEleicao.value = tipoEleicao[etapaIndex];
      } else {
        etapaIndex = 0;
        gravaVoto();
        fimVotacao(context);
      }
    }
  }

  Future<void> gravaVoto() async {
    final votosParaGravar = List<Voto>.from(votoAtual);
    votoAtual.clear();
    for (var voto in votosParaGravar) {
      await votoRepository.create(voto);
    }
  }

  Future<void> fimVotacao(BuildContext context) async {
    etapaIndex = 0;
    numSeqEleicao.value = tipoEleicao.first;
    AudioFiles.confirma.play();
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const Scaffold(
              body: Center(
                child: Text(
                  'FIM',
                  style: TextStyle(fontSize: 200),
                ),
              ),
            )));
    Future.delayed(const Duration(seconds: 3)).whenComplete(() {
      if (!context.mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const ProximoEleitorPage(),
      ));
    });
  }

  Future<void> carregaListaEleitores() async {
    final list = await alunoRepository.find({});
    listEleitor.clear();
    listEleitor.addAll(list);
  }

  Future<void> carregaListaCandidatos() async {
    final list = await candidatoRepository.find({});
    listCandidato.clear();
    if (zone == 0) {
      listCandidato.addAll(list ?? []);
      return;
    }
    final listFiltrada = list?.where((e) => e.zone == zone) ?? [];
    listCandidato.addAll(listFiltrada);
  }
}
