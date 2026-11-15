import 'dart:io';

import 'package:eleicao/src/features/cadastro/controllers/candidato_control.dart';
import 'package:eleicao/src/features/cadastro/state/cadastro_state.dart';
import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/features/urna/state/votacao_state.dart';
import 'package:eleicao/src/functions/image_helper.dart';
import 'package:eleicao/src/injector.dart';
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
  final txtId = TextEditingController();
  final txtNome = TextEditingController();
  final txtNomeVice = TextEditingController();
  final txtUrlImage = TextEditingController();
  final txtUrlImageVice = TextEditingController();

  late Cargo cargoSelecionado;
  int zoneSelecionada = 0;

  var imageFile = File('');
  var imageFileVice = File('');

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var ativaValidacaoForm = false;

  final showVice = ValueNotifier(false);
  final focusNome = FocusNode();

  List<Cargo> get _cargosOrdenados {
    final ativos = Cargo.byModalidade(modalidadeEleicao.value);
    final outros =
        Cargo.values.where((c) => c.modalidade != modalidadeEleicao.value);
    return [...ativos, ...outros];
  }

  @override
  void initState() {
    super.initState();
    cargoSelecionado = Cargo.getCargoByCodigo(tipoEleicao.first);
    showVice.value = cargoSelecionado.temVice;
    control.listaCandidatos();
    buscaCandidato(widget.id);
    focusNome.requestFocus();
  }

  @override
  void dispose() {
    txtId.dispose();
    txtNome.dispose();
    txtNomeVice.dispose();
    txtUrlImage.dispose();
    txtUrlImageVice.dispose();
    focusNome.dispose();
    super.dispose();
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
      padding: const EdgeInsets.all(12.0),
      child: Form(
        key: _formKey,
        autovalidateMode: ativaValidacaoForm
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                focusNode: focusNome,
                controller: txtNome,
                decoration: const InputDecoration(
                  labelText: 'Nome do Candidato',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o nome do candidato';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: txtId,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText:
                      'Número do Candidato na Urna (${digitosDoCargo(cargoSelecionado.codigo)} dígitos)',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Número é obrigatório';
                  }
                  final texto = value.trim();
                  final numero = int.tryParse(texto);
                  if (numero == null) {
                    return 'Número inválido';
                  }
                  final digitosEsperados =
                      digitosDoCargo(cargoSelecionado.codigo);
                  if (texto.length != digitosEsperados) {
                    return 'Para ${cargoSelecionado.descricao}, informe $digitosEsperados dígitos';
                  }
                  final duplicado = listCandidatos.value.where((c) {
                    if (widget.id != null && c.id == widget.id) return false;
                    final mesmoCargo = c.cargo.codigo == cargoSelecionado.codigo;
                    final mesmoNumero = c.numero == numero;
                    final mesmaZona = c.zone == 0 ||
                        zoneSelecionada == 0 ||
                        c.zone == zoneSelecionada;
                    return mesmoCargo && mesmoNumero && mesmaZona;
                  }).firstOrNull;
                  if (duplicado != null) {
                    return 'Número $numero já pertence a "${duplicado.nome}" em ${cargoSelecionado.descricao}';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Cargo>(
                key: ValueKey(cargoSelecionado),
                initialValue: cargoSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Cargo / Modalidade',
                  border: OutlineInputBorder(),
                ),
                items: _cargosOrdenados
                    .map(
                      (c) => DropdownMenuItem<Cargo>(
                        value: c,
                        child: Text(c.descricao),
                      ),
                    )
                    .toList(),
                onChanged: (novoCargo) {
                  if (novoCargo == null) return;
                  setState(() {
                    cargoSelecionado = novoCargo;
                    showVice.value = novoCargo.temVice;
                  });
                  if (ativaValidacaoForm) {
                    _formKey.currentState?.validate();
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                key: ValueKey(zoneSelecionada),
                initialValue: zoneSelecionada,
                decoration: const InputDecoration(
                  labelText: 'Turma / Zona Eleitoral',
                  border: OutlineInputBorder(),
                ),
                items: listTurmas
                    .map(
                      (t) => DropdownMenuItem<int>(
                        value: t.$1,
                        child: Text(t.$2),
                      ),
                    )
                    .toList(),
                onChanged: (novaZona) {
                  if (novaZona == null) return;
                  setState(() {
                    zoneSelecionada = novaZona;
                  });
                  if (ativaValidacaoForm) {
                    _formKey.currentState?.validate();
                  }
                },
              ),
              const SizedBox(height: 12),
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
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: txtNomeVice,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Nome do Vice-Candidato',
                          ),
                        ),
                        const SizedBox(height: 10),
                        ValueListenableBuilder(
                          valueListenable: txtUrlImageVice,
                          builder: (context, value, child) => Column(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  final (filepath, file) = await buscaImagem();
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
                                    label: const Text('Escolher Arquivo Vice'),
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
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: salvar,
                    child: const Text('Salvar'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: Navigator.of(context).pop,
                    child: const Text('Cancelar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
      if (candidato != null && mounted) {
        final Candidato(
          :numero,
          :nome,
          :nomeVice,
          :cargo,
          :urlImage,
          :urlImageVice,
          :zone
        ) = candidato;
        setState(() {
          txtId.text = numero.toString();
          txtNome.text = nome;
          txtNomeVice.text = nomeVice ?? '';
          cargoSelecionado = cargo;
          zoneSelecionada = zone;
          txtUrlImage.text = urlImage;
          txtUrlImageVice.text = urlImageVice ?? '';
          showVice.value = cargo.temVice;
        });
      }
    }
  }

  Future<void> salvar() async {
    setState(() {
      ativaValidacaoForm = true;
    });
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final numeroCand = int.parse(txtId.text.trim());

    // Verifica no banco de dados se já existe candidato com o mesmo número neste cargo
    final duplicado = await control.verificarNumeroDuplicado(
      numero: numeroCand,
      cargo: cargoSelecionado,
      zone: zoneSelecionada,
      ignorarId: widget.id,
    );

    if (duplicado != null) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Número já cadastrado'),
          content: Text(
            'Já existe o candidato "${duplicado.nome}" cadastrado com o número $numeroCand para ${cargoSelecionado.descricao}. Escolha outro número.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (txtUrlImage.text.isEmpty) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
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
          await apiStorage.uploadFile(txtUrlImage.text, 'cand$numeroCand');
    } else if (txtUrlImage.text.startsWith('http')) {
      remoteImagePath = normalizeImageUrl(txtUrlImage.text);
    }

    var remoteImageVicePath = txtUrlImageVice.text;
    if (txtUrlImageVice.text.isNotEmpty &&
        !txtUrlImageVice.text.startsWith('http') &&
        !txtUrlImageVice.text.startsWith('data:image')) {
      remoteImageVicePath = await apiStorage.uploadFile(
          txtUrlImageVice.text, 'cand${numeroCand}_vice');
    } else if (txtUrlImageVice.text.startsWith('http')) {
      remoteImageVicePath = normalizeImageUrl(txtUrlImageVice.text);
    }

    final docId = widget.id ?? '${cargoSelecionado.codigo}_$numeroCand';

    final candidato = Candidato(
      id: docId,
      matricula: numeroCand.toString(),
      numero: numeroCand,
      nome: txtNome.text.trim(),
      nomeVice: txtNomeVice.text.trim(),
      cargo: cargoSelecionado,
      partido: '',
      urlImage: remoteImagePath,
      urlImageVice: remoteImageVicePath,
      zone: zoneSelecionada,
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
              child: const Text('OK'),
            ),
          ],
          content: Text(
            success ? 'Salvo com sucesso' : 'Erro ao salvar',
          ),
        ),
      ).whenComplete(() {
        if (success && mounted) {
          Navigator.of(context).pop();
        }
      });
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
    return ('', null);
  }
}
