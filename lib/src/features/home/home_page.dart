import 'package:eleicao/src/features/cadastro/pages/lista_alunos_cad_page.dart';
import 'package:eleicao/src/features/cadastro/pages/lista_candidatos_cad_page.dart';
import 'package:eleicao/src/features/urna/pages/proximo_eleitor_page.dart';
import 'package:eleicao/src/injector.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final txtTerminal =
      TextEditingController(text: prefs.getInt('terminal').toString());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Urna Eletrônica'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: () => navigateToAlunos(context),
                child: const Text(
                  'Alunos',
                  style: TextStyle(fontSize: 25),
                )),
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: () => navigateToCandidatos(context),
                child: const Text(
                  'Candidatos',
                  style: TextStyle(fontSize: 25),
                )),
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: () => navigateToVotacao(context),
                child: const Text(
                  'Votação',
                  style: TextStyle(fontSize: 25),
                )),
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: () => changeTerminal(context),
                child: const Text(
                  'Terminal',
                  style: TextStyle(fontSize: 25),
                ))
          ],
        ),
      ),
    );
  }

  void navigateToAlunos(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const ListaAlunosCadPage(),
    ));
  }

  void navigateToCandidatos(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const ListaCandidatosCadPage(),
    ));
  }

  void navigateToVotacao(BuildContext context) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => const ProximoEleitorPage(),
    ));
  }

  void changeTerminal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mudar Terminal'),
        content: TextField(
          controller: txtTerminal,
        ),
        actions: [
          ElevatedButton(
              onPressed: () => setTerminal(context),
              child: const Text('Salvar'))
        ],
      ),
    );
  }

  void setTerminal(BuildContext context) {
    if (int.tryParse(txtTerminal.text) != null) {
      prefs.setInt('terminal', int.parse(txtTerminal.text));
      Navigator.of(context).pop();
    }
  }
}
