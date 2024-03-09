import 'package:eleicao/src/urna/controller/votacao_control.dart';
import 'package:eleicao/src/urna/pages/candidato_page.dart';
import 'package:eleicao/src/urna/pages/eleitor_page.dart';
import 'package:eleicao/src/widgets/teclado_widget.dart';
import 'package:flutter/material.dart';

class VotacaoPage extends StatefulWidget {
  const VotacaoPage({super.key});

  @override
  State<VotacaoPage> createState() => _VotacaoPageState();
}

class _VotacaoPageState extends State<VotacaoPage> {
  late final VotacaoControl control;
  @override
  void initState() {
    control = VotacaoControl();
    super.initState();
  }

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
          TecladoWidget(control),
        ],
      ),
    ));
  }
}
