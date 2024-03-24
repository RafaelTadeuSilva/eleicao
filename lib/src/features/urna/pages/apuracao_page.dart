import 'package:eleicao/src/features/cadastro/state/cadastro_state.dart';
import 'package:eleicao/src/features/urna/controllers/apuracao_control.dart';
import 'package:eleicao/src/features/urna/state/votacao_state.dart';
import 'package:flutter/material.dart';

class ApuracaoPage extends StatefulWidget {
  const ApuracaoPage({super.key});

  @override
  State<ApuracaoPage> createState() => _ApuracaoPageState();
}

class _ApuracaoPageState extends State<ApuracaoPage> {
  final control = ApuracaoControl();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apuração dos Votos'),
      ),
      body: montaBody(),
    );
  }

  Widget montaBody() {
    return Padding(
      padding: EdgeInsets.only(bottom: 8, left: 8, right: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  color: Colors.white,
                  width: 300,
                  child: DropdownMenu(
                    expandedInsets: EdgeInsets.all(10),
                    dropdownMenuEntries: listTurmas
                        .map((e) => DropdownMenuEntry(label: e.$2, value: e.$1))
                        .toList(),
                    initialSelection: 0,
                    hintText: 'Escolha a Zona Eleitoral',
                    controller: control.txtZonaEleitoral,
                    onSelected: control.carregaApuracao,
                  ),
                ),
              ),
            ],
          ),
          ValueListenableBuilder(
            valueListenable: listApuracao,
            builder: (context, value, child) {
              return Expanded(
                child: ListView.builder(
                    itemBuilder: montaItem, itemCount: value.length),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget? montaItem(BuildContext context, int index) {
    final item = listApuracao.value[index];
    return ListTile(
      tileColor: index % 2 == 0 ? Colors.grey[200] : null,
      title: Text(item.$1),
      trailing: Text(item.$2.toString()),
    );
  }
}
