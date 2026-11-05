import 'package:eleicao/src/features/cadastro/controllers/candidato_control.dart';
import 'package:eleicao/src/features/cadastro/state/cadastro_state.dart';
import 'package:eleicao/src/features/cadastro/widgets/foto_candidato_field.dart';
import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/features/urna/state/votacao_state.dart';
import 'package:eleicao/src/functions/image_helper.dart';
import 'package:eleicao/src/injector.dart';
import 'package:eleicao/src/models/candidato.dart';
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
                  final duplicado = CandidatoControl.numeroDuplicado(
                    listCandidatos.value,
                    numero: numero,
                    cargo: cargoSelecionado,
                    zone: zoneSelecionada,
                    ignorarId: widget.id,
                  );
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
                items: zonasEleitorais.value
                    .map(
                      (t) => DropdownMenuItem<int>(
                        value: t.codigo,
                        child: Text(t.nome),
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
              FotoCandidatoField(
                controller: txtUrlImage,
                titulo: 'Candidato',
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
                        FotoCandidatoField(
                          controller: txtUrlImageVice,
                          titulo: 'Vice',
                          rotuloArquivo: 'Escolher Arquivo Vice',
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

    // Foto é opcional: vazia, o candidato é salvo sem foto e aparece no
    // relatório "Verificar Candidatos".
    var remoteImagePath = txtUrlImage.text.trim();
    if (remoteImagePath.startsWith('http')) {
      remoteImagePath = normalizeImageUrl(remoteImagePath);
    } else if (remoteImagePath.isNotEmpty &&
        !remoteImagePath.startsWith('data:image')) {
      remoteImagePath =
          await apiStorage.uploadFile(remoteImagePath, 'cand$numeroCand');
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

    final candidato = Candidato(
      id: widget.id ?? '', // vazio: o Firebase gera o id
      numero: numeroCand,
      nome: txtNome.text.trim(),
      nomeVice: txtNomeVice.text.trim(),
      cargo: cargoSelecionado,
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
            !success
                ? 'Erro ao salvar'
                : txtUrlImage.text.trim().isEmpty
                    ? 'Salvo sem foto. Adicione a foto depois; ela aparece '
                        'em "Verificar candidatos".'
                    : 'Salvo com sucesso',
          ),
        ),
      ).whenComplete(() {
        if (success && mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }
}
