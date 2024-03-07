import 'package:eleicao/src/widgets/teclado_widget.dart';
import 'package:flutter/material.dart';

class VereadorPage extends StatefulWidget {
  const VereadorPage({super.key});

  @override
  State<VereadorPage> createState() => _VereadorPageState();
}

class _VereadorPageState extends State<VereadorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 500,
          ),
          TecladoWidget()
        ],
      ),
    );
  }
}
