import 'package:eleicao/src/features/urna/controllers/votacao_control.dart';
import 'package:eleicao/src/features/urna/pages/candidato_page.dart';
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
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CandidatoPage(),
              //desabilitado até a votação presidente camara
              //EleitorPage(),
              Text('Aperte a tecla:'),
              Text('VERDE para confirmar'),
              Text('LARANJA para corrigir'),
            ],
          ),
          TecladoWidget(control),
        ],
      ),
    ));
  }
}
