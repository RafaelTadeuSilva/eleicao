import 'package:flutter/material.dart';

class EleitorPage extends StatelessWidget {
  const EleitorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 500,
          decoration: BoxDecoration(
              color: Colors.grey,
              border:
                  Border(bottom: BorderSide(color: Colors.black, width: 3))),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nome do aluno eleitor:'),
                Text('Eleitor 1'),
                Text('Série / Turma:'),
                Text('6º B'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
