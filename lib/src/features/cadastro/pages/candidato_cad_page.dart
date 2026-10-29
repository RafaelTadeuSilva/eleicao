import 'dart:io';

import 'package:eleicao/src/features/cadastro/controllers/candidato_control.dart';
import 'package:eleicao/src/features/cadastro/state/cadastro_state.dart';
import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/features/urna/state/votacao_state.dart';
import 'package:eleicao/src/functions/image_helper.dart';
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

  List<Cargo> get _cargosOrdenados {
    final ativos = Cargo.byModalidade(modalidadeEleicao.value);
    final outros =
        Cargo.values.where((c) => c.modalidade != modalidadeEleicao.value);
    return [...ativos, ...outros];
  }

  @override
  void initState() {
    final cargoInicial = Cargo.getCargoByCodigo(tipoEleicao.first);
    txtCargo.text = cargoInicial.descricao;
    showVice.value = cargoInicial.temVice;
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
    final cargoInicialCodigo = Cargo.getCargoByDescricao(txtCargo.text).codigo;
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
                      onSelected: (value) {
                        if (value == null) return;
                        final aluno = _listAlunos
                            .where((e) => e.nome.contains(value))
                            .firstOrNull;
                        if (aluno != null) {
                          txtNome.text = aluno.nome;
                          txtMatricula.text = aluno.id;
                          txtTurma.text = getTurmaById(aluno.turma).$2;
                        }
                      },
                      dropdownMenuEntries: _listAlunos
                          .map((e) => DropdownMenuEntry<String>(
                              value: e.nome, label: e.nome))
                          .toList()),
                  onFocusChange: (hasFocus) {
                    if (!hasFocus && _listAlunos.isNotEmpty) {
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
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      label: Text('Número do Candidato na Urna'),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Número é obrigatório';
                      }
                      if (int.tryParse(value) == null) return 'Número inválido';
                      return null;
                    }),
                const SizedBox(height: 10),
                Focus(
                  child: DropdownMenu<int>(
                      initialSelection: cargoInicialCodigo,
                      controller: txtCargo,
                      expandedInsets: EdgeInsets.zero,
                      label: const Text('Escolha o cargo / modalidade'),
                      enableFilter: true,
                      onSelected: (value) {
                        if (value == null) return;
                        final cargo = Cargo.getCargoByCodigo(value);
                        txtCargo.text = cargo.descricao;
                        showVice.value = cargo.temVice;
                      },
                      dropdownMenuEntries: _cargosOrdenados
                          .map((e) => DropdownMenuEntry(
                              value: e.codigo, label: e.descricao))
                          .toList()),
                  onFocusChange: (hasFocus) {
                    if (!hasFocus) {
                      final cargo = Cargo.values.firstWhere(
                          (e) => e.descricao.contains(txtCargo.text),
                          orElse: () => _cargosOrdenados.first);
                      txtCargo.text = cargo.descricao;
                      showVice.value = cargo.temVice;
                    }
                  },
                ),
                const SizedBox(height: 10),
                ValueListenableBuilder(
                  valueListenable: txtUrlImage,
                  builder: (context, value, child) => Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final (filepath, file) = await buscaImagem();
                          if (file != null) {
                            imageFile = file;
                            txtUrlImage.text = filepath;
                          }
                        },
                        child: Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            border: Border.all(),
                          ),
                          child: buildCandidatoPreviewImage(txtUrlImage.text),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () async {
                              final (filepath, file) = await buscaImagem();
                              if (file != null) {
                                imageFile = file;
                                txtUrlImage.text = filepath;
                              }
                            },
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Escolher Arquivo'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () =>
                                informarLinkImagem(txtUrlImage, 'Candidato'),
                            icon: const Icon(Icons.link),
                            label: const Text('Colar Link / Drive'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ValueListenableBuilder(
                    valueListenable: showVice,
                    builder: (context, value, child) {
                      return Visibility(
                        visible: value,
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
                            builder: (context, value, child) => Column(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    final (filepath, file) =
                                        await buscaImagem();
                                    if (file != null) {
                                      imageFileVice = file;
                                      txtUrlImageVice.text = filepath;
                                    }
                                  },
                                  child: Container(
                                    height: 200,
                                    width: 200,
                                    decoration: BoxDecoration(
                                      border: Border.all(),
                                    ),
                                    child: buildCandidatoPreviewImage(
                                        txtUrlImageVice.text),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () async {
                                        final (filepath, file) =
                                            await buscaImagem();
                                        if (file != null) {
                                          imageFileVice = file;
                                          txtUrlImageVice.text = filepath;
                                        }
                                      },
                                      icon: const Icon(Icons.photo_library),
                                      label:
                                          const Text('Escolher Arquivo Vice'),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () => informarLinkImagem(
                                          txtUrlImageVice, 'Vice'),
                                      icon: const Icon(Icons.link),
                                      label: const Text('Colar Link / Drive'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ]),
                      );
                    }),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton(
                        onPressed: salvar, child: const Text('Salvar')),
                    const SizedBox(width: 10),
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

  void informarLinkImagem(TextEditingController controller, String titulo) {
    final txtLink = TextEditingController(
      text: controller.text.startsWith('http') ? controller.text : '',
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Link da Foto ($titulo)'),
        content: TextField(
          controller: txtLink,
          decoration: const InputDecoration(
            labelText: 'Cole a URL da imagem ou link do Google Drive',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (txtLink.text.trim().isNotEmpty) {
                controller.text = normalizeImageUrl(txtLink.text.trim());
              }
              Navigator.of(context).pop();
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
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
          :matricula,
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
        showVice.value = cargo.temVice;
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
      if (!txtUrlImage.text.startsWith('http') &&
          !txtUrlImage.text.startsWith('data:image')) {
        remoteImagePath =
            await apiStorage.uploadFile(txtUrlImage.text, 'cand${txtId.text}');
      } else if (txtUrlImage.text.startsWith('http')) {
        remoteImagePath = normalizeImageUrl(txtUrlImage.text);
      }

      var remoteImageVicePath = txtUrlImageVice.text;
      if (txtUrlImageVice.text.isNotEmpty &&
          !txtUrlImageVice.text.startsWith('http') &&
          !txtUrlImageVice.text.startsWith('data:image')) {
        remoteImageVicePath = await apiStorage.uploadFile(
            txtUrlImageVice.text, 'cand${txtId.text}_vice');
      } else if (txtUrlImageVice.text.startsWith('http')) {
        remoteImageVicePath = normalizeImageUrl(txtUrlImageVice.text);
      }

      final cargoSelecionado = Cargo.getCargoByDescricao(txtCargo.text);
      final docId =
          widget.id ?? '${txtMatricula.text}_${cargoSelecionado.codigo}';

      final candidato = Candidato(
        id: docId,
        matricula: txtMatricula.text,
        numero: int.parse(txtId.text),
        nome: txtNome.text,
        nomeVice: txtNomeVice.text,
        cargo: cargoSelecionado,
        partido: '',
        urlImage: remoteImagePath,
        urlImageVice: remoteImageVicePath,
        zone: (getTurmaByName(txtTurma.text) ?? listTurmas.first).$1,
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
          if (success && mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    }
  }

  Future<(String, File?)> buscaImagem() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      return (result.files.single.path!, file);
    }
    return ("", null);
  }
}
