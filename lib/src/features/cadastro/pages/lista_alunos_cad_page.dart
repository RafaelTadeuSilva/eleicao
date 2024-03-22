import 'package:eleicao/src/features/cadastro/controllers/aluno_control.dart';
import 'package:eleicao/src/features/cadastro/pages/aluno_cad_page.dart';
import 'package:eleicao/src/features/cadastro/state/cadastro_state.dart';
import 'package:eleicao/src/models/aluno.dart';
import 'package:flutter/material.dart';

class ListaAlunosCadPage extends StatefulWidget {
  const ListaAlunosCadPage({super.key});

  @override
  State<ListaAlunosCadPage> createState() => _ListaAlunosCadPageState();
}

class _ListaAlunosCadPageState extends State<ListaAlunosCadPage> {
  late final AlunoControl control;

  @override
  void initState() {
    control = AlunoControl();
    control.listaAlunos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Lista de Alunos'),
        ),
        body: montaBody(),
        floatingActionButton: FloatingActionButton(
          onPressed: navigateToAlunoPage,
          child: const Icon(Icons.add),
        ));
  }

  Widget montaBody() {
    return ValueListenableBuilder(
      valueListenable: listAlunos,
      builder: (context, list, child) => ListView.builder(
        itemBuilder: (context, index) => montaItem(index, list),
        itemCount: list.length,
      ),
    );
  }

  Widget montaItem(int index, List<Aluno> list) {
    final Aluno(:id, :nome, :turma) = list[index];
    return Card(
      child: InkWell(
        onTap: () => navigateToAlunoPage(id),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                nome,
                style: const TextStyle(fontSize: 25),
              ),
              Text(
                getTurmaById(turma).$2,
                style: const TextStyle(fontSize: 25),
              )
            ],
          ),
        ),
      ),
    );
  }

  void navigateToAlunoPage([String? id]) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => AlunoCadPage(id: id)))
        .whenComplete(() => control.listaAlunos());
  }
}
