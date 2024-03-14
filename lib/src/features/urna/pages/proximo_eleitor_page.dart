import 'package:eleicao/src/features/home/home_page.dart';
import 'package:eleicao/src/features/urna/controllers/proximo_eleitor_control.dart';
import 'package:flutter/material.dart';

class ProximoEleitorPage extends StatefulWidget {
  const ProximoEleitorPage({super.key});

  @override
  State<ProximoEleitorPage> createState() => _ProximoEleitorPageState();
}

class _ProximoEleitorPageState extends State<ProximoEleitorPage> {
  final control = ProximoEleitorControl();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    control.buscaProximoEleitor(context);
    return Scaffold(
      body: InkWell(
          onLongPress: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) {
                control.stopTimer();
                return HomePage();
              },
            ));
          },
          child: const Center(
              child: Text(
            'Aguarde a liberação da urna',
            style: TextStyle(fontSize: 30),
          ))),
    );
  }
}
