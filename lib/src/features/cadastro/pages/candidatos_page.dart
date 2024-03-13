import 'package:flutter/material.dart';

class CandidatosPage extends StatefulWidget {
  const CandidatosPage({super.key});

  @override
  State<CandidatosPage> createState() => _CandidatosPageState();
}

class _CandidatosPageState extends State<CandidatosPage> {
  final txtMatricula = TextEditingController();
  final txtNome = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: montaBody(),
    );
  }

  Widget montaBody() {
    return Form(
        child: Column(
      children: [
        TextFormField(
          controller: txtMatricula,
          decoration: InputDecoration(
              border: OutlineInputBorder(),
              suffixIcon:
                  IconButton(onPressed: () {}, icon: Icon(Icons.search))),
        ),
        TextFormField(
          controller: txtNome,
        ),
      ],
    ));
  }
}
