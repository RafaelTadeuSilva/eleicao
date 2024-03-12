import 'package:eleicao/src/features/urna/state/votacao_state.dart';
import 'package:flutter/material.dart';

class EleitorPage extends StatelessWidget {
  const EleitorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 500,
          decoration: const BoxDecoration(
              color: Colors.grey,
              border:
                  Border(bottom: BorderSide(color: Colors.black, width: 3))),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: ValueListenableBuilder(
                valueListenable: eleitorAtual,
                builder: (context, value, child) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Nome do aluno eleitor:'),
                        Text(value!.nome),
                        const Text('Série / Turma:'),
                        Text(value.turma),
                      ],
                    )),
          ),
        ),
      ],
    );
  }
}
