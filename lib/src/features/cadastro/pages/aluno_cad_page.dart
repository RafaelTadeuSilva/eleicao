import 'package:eleicao/src/features/cadastro/controllers/aluno_control.dart';
import 'package:eleicao/src/features/cadastro/state/cadastro_state.dart';
import 'package:eleicao/src/models/aluno.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AlunoCadPage extends StatefulWidget {
  const AlunoCadPage({super.key, this.id});

  final String? id;
  @override
  State<AlunoCadPage> createState() => _AlunoCadPageState();
}

class _AlunoCadPageState extends State<AlunoCadPage> {
  final control = AlunoControl();
  final txtId = TextEditingController();
  final txtNome = TextEditingController();
  final txtTurma = TextEditingController();
  final txtTitulo = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var ativaValidacaoForm = false;

  @override
  void initState() {
    buscaAluno(widget.id);

    super.initState();
  }

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
      autovalidateMode: ativaValidacaoForm
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextFormField(
                autofocus: true,
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
              Focus(
                child: DropdownMenu(
                    controller: txtTurma,
                    expandedInsets: EdgeInsets.zero,
                    label: const Text('Escolha a turma'),
                    enableFilter: true,
                    onSelected: (value) =>
                        txtTurma.text = getTurmaById(value).$2,
                    dropdownMenuEntries: listTurmas
                        .map((e) => DropdownMenuEntry(value: e.$1, label: e.$2))
                        .toList()),
                onFocusChange: (hasFocus) {
                  if (!hasFocus) {
                    txtTurma.text =
                        (findTurmaByName(txtTurma.text) ?? listTurmas.first).$2;
                  }
                },
              ),
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
                  return int.tryParse(value!) == null
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

  Future<void> salvar() async {
    if (_formKey.currentState!.validate()) {
      final aluno = Aluno(
        id: txtId.text,
        nome: txtNome.text,
        titulo: int.parse(txtTitulo.text),
        turma: (getTurmaByName(txtTurma.text) ?? listTurmas.first).$1,
      );

      final success = switch (widget.id) {
        null => await control.create(aluno),
        _ => await control.update(aluno),
      };

      if (mounted) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                    actions: [
                      ElevatedButton(
                          autofocus: true,
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'))
                    ],
                    content: Text(
                      success ? 'Salvo com sucesso' : 'Erro ao salvar',
                    ))).whenComplete(() {
          if (success) {
            Navigator.of(context).pop();
          }
        });
      }
    }
  }

  Future<void> buscaAluno(String? idAluno) async {
    await Future.delayed(Durations.short2);
    if (idAluno != null) {
      final Aluno(:id, :nome, :turma, :titulo) = await control.getById(idAluno);
      txtId.text = id;
      txtNome.text = nome;
      txtTurma.text = getTurmaById(turma).$2;
      txtTitulo.text = titulo.toString();
    }
  }
}
