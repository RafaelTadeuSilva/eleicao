import 'package:eleicao/src/urna/pages/candidato_page.dart';
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
    return Scaffold(
      body: Row(
        children: [
          CandidatoPage(),
          TecladoWidget(
            onPressNumber: (p0) => debugPrint(p0.toString()),
          )
        ],
      ),
    );
  }
}
