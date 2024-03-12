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
          onPressed: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => AlunoPage())),
        ));
  }

  Widget montaBody() {
    return ValueListenableBuilder(
      valueListenable: listAlunos,
      builder: (context, list, child) => ListView.builder(
        itemBuilder: (context, index) {
          final Aluno(:nome) = list[index];
          return Text(nome);
        },
        itemCount: list.length,
      ),
    );
  }
}
