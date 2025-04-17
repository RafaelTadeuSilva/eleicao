import 'dart:io';

import 'package:eleicao/src/features/cadastro/controllers/candidato_control.dart';
import 'package:eleicao/src/features/cadastro/state/cadastro_state.dart';
import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/injector.dart';
import 'package:eleicao/src/models/aluno.dart';
import 'package:eleicao/src/models/candidato.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class CandidatoCadPage extends StatefulWidget {
  const CandidatoCadPage({super.key, this.id});
  final String? id;

  @override
  State<CandidatoCadPage> createState() => _CandidatoCadPageState();
}

class _CandidatoCadPageState extends State<CandidatoCadPage> {
  final control = CandidatoControl();
  final txtMatricula = TextEditingController();
  final txtTurma = TextEditingController();
  final txtId = TextEditingController();
  final txtNome = TextEditingController();
  final txtNomeVice = TextEditingController();
  final txtCargo = TextEditingController();
  final txtUrlImage = TextEditingController();
  final txtUrlImageVice = TextEditingController();
  var imageFile = File('');
  var imageFileVice = File('');

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var ativaValidacaoForm = false;
  List<Aluno> get _listAlunos => listAlunos.value;

  var showVice = ValueNotifier(false);

  final focusAluno = FocusNode();

  @override
  void initState() {
    buscaCandidato(widget.id);
    focusAluno.requestFocus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Candidatos'),
      ),
      body: montaBody(),
    );
  }

  Widget montaBody() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
          key: _formKey,
          autovalidateMode: ativaValidacaoForm
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Focus(
                  child: DropdownMenu<String>(
                      focusNode: focusAluno,
                      controller: txtNome,
                      expandedInsets: EdgeInsets.zero,
                      label: const Text('Escolha o aluno'),
                      enableFilter: true,
                      onSelected: (value) => txtNome.text = _listAlunos
                          .firstWhere((e) => e.nome.contains(value!))
                          .nome,
                      dropdownMenuEntries: _listAlunos
                          .map((e) => DropdownMenuEntry<String>(
                              value: e.nome, label: e.nome))
                          .toList()),
                  onFocusChange: (hasFocus) {
                    if (!hasFocus) {
                      Future.delayed(Durations.medium1).whenComplete(() {
                        final Aluno(:id, :nome, :turma) = _listAlunos
                            .firstWhere((e) => e.nome.contains(txtNome.text),
                                orElse: () => _listAlunos.first);
                        txtNome.text = nome;
                        txtMatricula.text = id;
                        txtTurma.text = getTurmaById(turma).$2;
                      });
                    }
                  },
                ),
                const SizedBox(height: 10),

                // TextFormField(
                //   controller: txtNome,
                //   decoration: InputDecoration(
                //       enabled: false,
                //       label: const Text('Nome do aluno'),
                //       border: const OutlineInputBorder(),
                //       suffixIcon: IconButton(
                //           onPressed: () {}, icon: const Icon(Icons.search))),
                // ),
                TextFormField(
                    controller: txtMatricula,
                    decoration: const InputDecoration(
                      enabled: false,
                      label: Text('Matrícula aluno'),
                      border: OutlineInputBorder(),
                    )),
                const SizedBox(height: 10),
                TextFormField(
                    controller: txtTurma,
                    decoration: const InputDecoration(
                      enabled: false,
                      label: Text('Turma'),
                      border: OutlineInputBorder(),
                    )),
                const SizedBox(height: 10),
                TextFormField(
                    controller: txtId,
                    decoration: const InputDecoration(
                      label: Text('Número'),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return 'Número é obrigatório';
                      if (int.tryParse(value) == null) return 'Número inválido';
                      return null;
                    }),
                const SizedBox(height: 10),
                Focus(
                  child: DropdownMenu(
                      initialSelection: Cargo.vereador.codigo,
                      controller: txtCargo,
                      expandedInsets: EdgeInsets.zero,
                      label: const Text('Escolha o cargo'),
                      enableFilter: true,
                      onSelected: (value) {
                        txtCargo.text = Cargo.values
                            .firstWhere((e) => e.codigo == value)
                            .descricao;
                        showVice.value = value == Cargo.prefeito.codigo;
                      },
                      dropdownMenuEntries: Cargo.values
                          .map((e) => DropdownMenuEntry(
                              value: e.codigo, label: e.descricao))
                          .toList()),
                  onFocusChange: (hasFocus) {
                    if (!hasFocus) {
                      txtCargo.text = Cargo.values
                          .firstWhere(
                              (e) => e.descricao.contains(txtCargo.text),
                              orElse: () => Cargo.values.first)
                          .descricao;
                    }
                  },
                ),
                const SizedBox(height: 10),
                ValueListenableBuilder(
                  valueListenable: txtUrlImage,
                  builder: (context, value, child) => GestureDetector(
                    onTap: () async {
                      final (filepath, file) = await buscaImagem();
                      if (file != null) {
                        // setState(() {
                        imageFile = file;
                        txtUrlImage.text = filepath;
                        // });
                      }
                    },
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(),
                      ),
                      child: txtUrlImage.text.isEmpty
                          ? Image.asset('assets/images/candidato.png')
                          : txtUrlImage.text.contains('http')
                              ? Image.network(txtUrlImage.text)
                              : Image.file(imageFile),
                    ),
                  ),
                ),
                ValueListenableBuilder(
                    valueListenable: showVice,
                    builder: (context, value, child) {
                      return Visibility(
                        visible: txtCargo.text == Cargo.prefeito.descricao,
                        child: Column(children: [
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: txtNomeVice,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                label: Text('Nome do vice candidato')),
                          ),
                          const SizedBox(height: 10),
                          ValueListenableBuilder(
                            valueListenable: txtUrlImageVice,
                            builder: (context, value, child) => GestureDetector(
                              onTap: () async {
                                final (filepath, file) = await buscaImagem();
                                if (file != null) {
                                  // setState(() {
                                  imageFileVice = file;
                                  txtUrlImageVice.text = filepath;
                                  // });
                                }
                              },
                              child: Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  border: Border.all(),
                                ),
                                child: txtUrlImageVice.text.isEmpty
                                    ? Image.asset('assets/images/candidato.png')
                                    : txtUrlImageVice.text.contains('http')
                                        ? Image.network(txtUrlImageVice.text)
                                        : Image.file(imageFileVice),
                              ),
                            ),
                          ),
                        ]),
                      );
                    }),
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
          )),
    );
  }

  Future<void> buscaCandidato(String? idCandidato) async {
    await Future.delayed(Durations.short2);
    if (idCandidato != null) {
      final candidato = await control.getById(idCandidato);
      if (candidato != null) {
        final Candidato(
          :numero,
          :nome,
          :nomeVice,
          :cargo,
          id: matricula,
          :urlImage,
          :urlImageVice,
          :zone
        ) = candidato;
        txtId.text = numero.toString();
        txtNome.text = nome;
        txtNomeVice.text = nomeVice ?? '';
        txtCargo.text = cargo.descricao;
        txtMatricula.text = matricula;
        txtTurma.text = getTurmaById(zone).$2;
        txtUrlImage.text = urlImage;
        txtUrlImageVice.text = urlImageVice ?? '';
        showVice.value = cargo == Cargo.prefeito;
      }
    }
  }

  Future<void> salvar() async {
    if (_formKey.currentState!.validate()) {
      if (txtUrlImage.text.isEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            actions: [
              ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'))
            ],
            content: const Text('Imagem é obrigatória'),
          ),
        );
        return;
      }
      var remoteImagePath = txtUrlImage.text;
      if (!txtUrlImage.text.startsWith('http')) {
        // && !Platform.isMacOS) {
        remoteImagePath =
            await apiStorage.uploadFile(txtUrlImage.text, 'cand${txtId.text}');
      }
      var remoteImageVicePath = txtUrlImageVice.text;
      if (!txtUrlImageVice.text.startsWith('http')) {
        // && !Platform.isMacOS) {
        remoteImageVicePath = await apiStorage.uploadFile(
            txtUrlImageVice.text, 'cand${txtId.text}_vice');
      }
      final candidato = Candidato(
        numero: int.parse(txtId.text),
        nome: txtNome.text,
        nomeVice: txtNomeVice.text,
        cargo: Cargo.values.firstWhere((e) => e.descricao == txtCargo.text),
        id: txtMatricula.text,
        partido: '',
        urlImage: remoteImagePath,
        urlImageVice: remoteImageVicePath,
        zone: getTurmaByName(txtTurma.text)!.$1,
      );

      final success = switch (widget.id) {
        null => await control.create(candidato),
        _ => await control.update(candidato),
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

  Future<(String, File?)> buscaImagem() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      final file = File(result.files.single.path!);
      return (result.files.single.path!, file);
    }
    return ("", null);
  }
}
