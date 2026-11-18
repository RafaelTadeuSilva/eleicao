import 'package:eleicao/src/features/urna/controllers/proximo_eleitor_control.dart';
import 'package:eleicao/src/features/urna/pages/votacao_page.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

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
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
    control.iniciar(() {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const VotacaoPage()));
    });
  }

  @override
  void dispose() {
    control.parar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Aguarde a liberação da urna',
          style: TextStyle(fontSize: 30),
        ),
      ),
    );
  }
}
