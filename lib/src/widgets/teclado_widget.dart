import 'package:flutter/material.dart';

class TecladoWidget extends StatefulWidget {
  const TecladoWidget({super.key});

  @override
  State<TecladoWidget> createState() => _TecladoWidgetState();
}

class _TecladoWidgetState extends State<TecladoWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Nome da Escola'),
        Text('Colégio Santa Teresinha'),
        Text('Descrição da Votação'),
        Text('Eleição da Michelândia'),
        Table(
          children: [
            TableRow(
                children: [ElevatedButton(onPressed: null, child: Text('1'))])
          ],
        )
      ],
    );
  }
}
