import 'package:eleicao/src/urna/pages/candidato_page.dart';
import 'package:eleicao/src/urna/pages/eleitor_page.dart';
import 'package:eleicao/src/urna/state/votacao_state.dart';
import 'package:eleicao/src/widgets/teclado_widget.dart';
import 'package:flutter/material.dart';

class VotacaoPage extends StatefulWidget {
  const VotacaoPage({super.key});

  @override
  State<VotacaoPage> createState() => _VotacaoPageState();
}

class _VotacaoPageState extends State<VotacaoPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CandidatoPage(),
              EleitorPage(),
            ],
          ),
          TecladoWidget(onPressNumber: carregaCandidato),
        ],
      ),
    ));
  }

  void carregaCandidato(int num) {
    numCandidato.value = '${numCandidato.value}$num';
    numAtual.value = numCandidato.value.length;
    if (numCandidato.value.length == 5) {
      urlImageCandidato.value = 'assets/images/candidato.png';
    }
    numCandidato.notifyListeners();
  }
}
