import 'package:eleicao/src/features/cadastro/pages/lista_alunos_cad_page.dart';
import 'package:eleicao/src/features/cadastro/pages/lista_candidatos_cad_page.dart';
import 'package:eleicao/src/features/cadastro/state/cadastro_state.dart';
import 'package:eleicao/src/features/urna/pages/apuracao_page.dart';
import 'package:eleicao/src/features/urna/pages/liberacao_urna_page.dart';
import 'package:eleicao/src/features/urna/pages/proximo_eleitor_page.dart';
import 'package:eleicao/src/features/urna/state/votacao_state.dart';
import 'package:eleicao/src/injector.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final txtTerminal = TextEditingController();
  final txtZone = TextEditingController();
  final txtTipoEleicao = TextEditingController();

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
                onPressed: () => navigateToLiberacao(context),
                child: const Text(
                  'Liberação',
                  style: TextStyle(fontSize: 25),
                )),
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: () => navigateToApuracao(context),
                child: const Text(
                  'Apuração',
                  style: TextStyle(fontSize: 25),
                )),
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: () => changeTerminal(context),
                child: const Text(
                  'Terminal',
                  style: TextStyle(fontSize: 25),
                )),
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: () => changeZone(context),
                child: const Text(
                  'Zona Eleitoral',
                  style: TextStyle(fontSize: 25),
                )),
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: () => changeTipoEleicao(context),
                child: const Text(
                  'Tipo de Eleição',
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

  void navigateToLiberacao(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const LiberacaoUrnaPage(),
    ));
  }

  void navigateToApuracao(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const ApuracaoPage(),
    ));
  }

  void changeTerminal(BuildContext context) {
    txtTerminal.text = prefs.getInt('terminal').toString();
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

  void changeTipoEleicao(BuildContext context) {
    txtTipoEleicao.text = prefs.getInt('tipoeleicao').toString();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mudar Tipo Eleição, 1-Presidencia, 2-Vereador'),
        content: TextField(
          controller: txtTipoEleicao,
        ),
        actions: [
          ElevatedButton(
              onPressed: () => setTipoEleicao(context),
              child: const Text('Salvar'))
        ],
      ),
    );
  }

  void changeZone(BuildContext context) {
    txtZone.text = prefs.getInt('zone').toString();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mudar Zona Eleitoral'),
        content: DropdownMenu(
          dropdownMenuEntries: listTurmas
              .map((e) => DropdownMenuEntry(value: e.$1, label: e.$2))
              .toList(),
          controller: txtZone,
        ),
        actions: [
          ElevatedButton(
              onPressed: () => setZone(context), child: const Text('Salvar'))
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

  void setZone(BuildContext context) {
    if (txtZone.text.isNotEmpty) {
      final zone = getTurmaByName(txtZone.text)?.$1 ?? 0;
      prefs.setInt('zone', zone);
      Navigator.of(context).pop();
    }
  }

  void setTipoEleicao(BuildContext context) {
    if (int.tryParse(txtTipoEleicao.text) != null) {
      prefs.setInt('tipoeleicao', int.parse(txtTipoEleicao.text));
      tipoEleicao.clear();

      if (txtTipoEleicao.text == '1') {
        tipoEleicao.add(1);
        tipoEleicao.add(2);
      } else {
        tipoEleicao.add(4);
      }

      //tipoEleicao.add(int.tryParse(txtTipoEleicao.text) ?? 1);
      Navigator.of(context).pop();
    }
  }
}
