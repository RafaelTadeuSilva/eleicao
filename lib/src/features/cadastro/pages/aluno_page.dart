import 'package:eleicao/src/features/cadastro/controllers/aluno_control.dart';
import 'package:eleicao/src/features/cadastro/state/cadastro_state.dart';
import 'package:eleicao/src/models/aluno.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AlunoPage extends StatefulWidget {
  const AlunoPage({super.key});

  @override
  State<AlunoPage> createState() => _AlunoPageState();
}

class _AlunoPageState extends State<AlunoPage> {
  final control = AlunoControl();
  final txtId = TextEditingController();
  final txtNome = TextEditingController();
  final idTurma = ValueNotifier<int?>(null);
  // final txtTurma = TextEditingController();
  final txtTitulo = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var failToSave = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Alunos'),
      ),
      body: montaBody(),
    );
  }

  Widget montaBody() {
    return Form(
      key: _formKey,
      autovalidateMode: failToSave
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextFormField(
                controller: txtId,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), label: Text('Matrícula')),
                textInputAction: TextInputAction.next,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.length != 4) return 'Matrícula deve ter 4 digitos';
                  return int.tryParse(value) == null
                      ? 'Digite apenas números'
                      : null;
                },
              ),
              const SizedBox(height: 5),
              TextFormField(
                  controller: txtNome,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text('Nome do Eleitor')),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.name,
                  validator: (value) => value!.length < 4
                      ? 'Nome deve ter mais de 4 caracteres'
                      : null),
              const SizedBox(height: 5),
              DropdownMenu(
                  expandedInsets: EdgeInsets.zero,
                  label: const Text('Escolha a turma'),
                  enableFilter: true,
                  onSelected: (value) => setState(() {
                        idTurma.value = value;
                      }),
                  dropdownMenuEntries: listTurmas
                      .map((e) => DropdownMenuEntry(value: e.$1, label: e.$2))
                      .toList()),
              // DropdownButtonFormField(items: montaItemsTurma, onChanged: ()=> ),
              const SizedBox(height: 5),
              TextFormField(
                controller: txtTitulo,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text('Título de Eleitor')),
                textInputAction: TextInputAction.next,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.length != 4) return 'Titulo deve ter 4 digitos';
                  return int.tryParse(value) == null
                      ? 'Digite apenas números'
                      : null;
                },
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  ElevatedButton(
                      onPressed: salvar, child: const Text('Salvar')),
                  ElevatedButton(
                      onPressed: Navigator.of(context).pop,
                      child: const Text('Cancelar'))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void salvar() {
    if (_formKey.currentState!.validate()) {
      final aluno = Aluno(
          id: txtId.text,
          nome: txtNome.text,
          titulo: int.parse(txtTitulo.text),
          turma: idTurma.value!);
      control.salvar(aluno);
    }
  }
}
