import 'package:eleicao/src/features/cadastro/controllers/aluno_control.dart';
import 'package:eleicao/src/features/cadastro/pages/aluno_page.dart';
import 'package:eleicao/src/features/cadastro/state/cadastro_state.dart';
import 'package:eleicao/src/models/aluno.dart';
import 'package:flutter/material.dart';

class ListaAlunosPage extends StatefulWidget {
  const ListaAlunosPage({super.key});

  @override
  State<ListaAlunosPage> createState() => _ListaAlunosPageState();
}

class _ListaAlunosPageState extends State<ListaAlunosPage> {
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
          title: Text('Lista de Alunos'),
        ),
        body: montaBody(),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: navigateToAlunoPage,
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
                style: TextStyle(fontSize: 25),
              ),
              Text(
                listTurmas.firstWhere((element) => element.$1 == turma).$2,
                style: TextStyle(fontSize: 25),
              )
            ],
          ),
        ),
      ),
    );
  }

  void navigateToAlunoPage([String? id]) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => AlunoPage(id: id)))
        .whenComplete(() => control.listaAlunos());
  }
}