import 'package:eleicao/src/features/urna/controllers/votacao_control.dart';
import 'package:eleicao/src/features/urna/pages/candidato_page.dart';
import 'package:eleicao/src/widgets/teclado_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

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
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Row(
        children: [
          const Flexible(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: CandidatoPage()),
                //desabilitado até a votação presidente camara
                //EleitorPage(),

                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        'Aperte a tecla:',
                        style: TextStyle(fontSize: 30),
                      ),
                      Text(
                        'VERDE para confirmar',
                        style: TextStyle(fontSize: 30),
                      ),
                      Text(
                        'LARANJA para corrigir',
                        style: TextStyle(fontSize: 30),
                      ),
                      //para tirar print pro video
                      // SizedBox(
                      //   height: 50,
                      // ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Flexible(flex: 2, child: TecladoWidget(control)),
        ],
      ),
    ));
  }
}
