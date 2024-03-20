import 'package:eleicao/src/features/urna/controllers/liberacao_urna_control.dart';
import 'package:flutter/material.dart';

class LiberacaoUrnaPage extends StatefulWidget {
  const LiberacaoUrnaPage({super.key});

  @override
  State<LiberacaoUrnaPage> createState() => _LiberacaoUrnaPageState();
}

class _LiberacaoUrnaPageState extends State<LiberacaoUrnaPage> {
  final control = LiberacaoUrnaControl();
  final focusUrna = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liberação Eleitor por Urna'),
      ),
      body: montaBody(),
    );
  }

  Widget montaBody() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            autofocus: true,
            focusNode: focusUrna,
            controller: control.txtUrna,
            decoration: const InputDecoration(
                label: Text('Escolha a Urna'), border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: control.txtTituloEleitor,
            decoration: const InputDecoration(
                label: Text('Titulo de Eleitor'), border: OutlineInputBorder()),
            onChanged: control.buscaEleitor,
          ),
          const SizedBox(height: 10),
          TextField(
            readOnly: true,
            canRequestFocus: false,
            controller: control.txtNome,
            decoration: const InputDecoration(
                label: Text('Nome'), border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          TextField(
            readOnly: true,
            canRequestFocus: false,
            controller: control.txtMatricula,
            decoration: const InputDecoration(
                label: Text('Matricula'), border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          TextField(
            readOnly: true,
            canRequestFocus: false,
            controller: control.txtTurma,
            decoration: const InputDecoration(
                label: Text('Turma'), border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton(
                  onPressed: confirmar, child: const Text('Confirmar'))
            ],
          )
        ],
      ),
    );
  }

  Future<void> confirmar() async {
    await control.confirmar();
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  control.limpaCampos();
                  focusUrna.requestFocus();
                },
                child: const Text('OK'))
          ],
          content: const Text('Confirmado com sucesso'),
        ),
      );
    }
  }
}
