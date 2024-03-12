import 'package:eleicao/src/features/cadastro/pages/lista_alunos_page.dart';
import 'package:eleicao/src/features/urna/controllers/proximo_eleitor_control.dart';
import 'package:flutter/material.dart';

class ProximoEleitorPage extends StatefulWidget {
  const ProximoEleitorPage({super.key});

  @override
  State<ProximoEleitorPage> createState() => _ProximoEleitorPageState();
}

class _ProximoEleitorPageState extends State<ProximoEleitorPage> {
  late final ProximoEleitorControl control;

  @override
  void initState() {
    control = ProximoEleitorControl(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InkWell(
          onLongPress: () =>
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) {
                  control.timer.cancel();
                  return ListaAlunosPage();
                },
              )),
          child: const Center(
              child: Text(
            'Aguarde a liberação da urna',
            style: TextStyle(fontSize: 30),
          ))),
    );
  }
}
