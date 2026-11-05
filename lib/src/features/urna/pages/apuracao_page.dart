import 'package:eleicao/src/features/cadastro/state/cadastro_state.dart';
import 'package:eleicao/src/features/urna/controllers/apuracao_control.dart';
import 'package:eleicao/src/features/urna/enums/cargo.dart';
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
  void initState() {
    super.initState();
    control.carregaApuracao();
  }

  void _filtrar({Cargo? cargo, int? zona}) {
    setState(() {});
    control.carregaApuracao(cargo: cargo, zona: zona);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apuração dos Votos (${colecaoVotosAtual.value})'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            icon: const Icon(Icons.refresh),
            onPressed: () => _filtrar(cargo: control.cargo, zona: control.zona),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            _filtros(),
            const SizedBox(height: 8),
            Expanded(child: _lista()),
          ],
        ),
      ),
      floatingActionButton: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ValueListenableBuilder(
            valueListenable: control.totalVotos,
            builder: (context, total, _) => Text('Total de votos: $total'),
          ),
        ),
      ),
    );
  }

  Widget _filtros() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<Cargo?>(
            initialValue: control.cargo,
            decoration: const InputDecoration(
              labelText: 'Cargo',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('Todos')),
              for (final c in control.cargosDisponiveis)
                DropdownMenuItem(value: c, child: Text(c.descricao)),
            ],
            onChanged: (c) => _filtrar(cargo: c, zona: control.zona),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButtonFormField<int?>(
            initialValue: control.zona,
            decoration: const InputDecoration(
              labelText: 'Zona eleitoral',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('Todas')),
              for (final z in zonasEleitorais.value)
                DropdownMenuItem(value: z.codigo, child: Text(z.nome)),
            ],
            onChanged: (z) => _filtrar(cargo: control.cargo, zona: z),
          ),
        ),
      ],
    );
  }

  Widget _lista() {
    return ValueListenableBuilder(
      valueListenable: control.resultados,
      builder: (context, resultados, _) {
        if (resultados.isEmpty) {
          return const Center(child: Text('Nenhum voto encontrado'));
        }
        final itens = <Widget>[];
        Cargo? cargoAnterior;
        for (final r in resultados) {
          if (r.cargo != cargoAnterior) {
            cargoAnterior = r.cargo;
            itens.add(Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 4),
              child: Text(
                r.cargo.descricao,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ));
          }
          itens.add(_item(r));
        }
        return ListView(children: itens);
      },
    );
  }

  Widget _item(ResultadoApuracao r) {
    return Card(
      color: r.vencedor
          ? (r.empate ? Colors.amber.shade100 : Colors.green.shade100)
          : null,
      child: ListTile(
        leading: r.vencedor
            ? Icon(r.empate ? Icons.balance : Icons.emoji_events,
                color: r.empate ? Colors.orange : Colors.green.shade800)
            : const SizedBox(width: 24),
        title:
            SelectableText(r.numero > 0 ? '${r.numero} - ${r.nome}' : r.nome),
        subtitle: r.vencedor ? Text(r.empate ? 'Empate' : 'Mais votado') : null,
        trailing: Text(
          '${r.votos}  (${r.percentual.toStringAsFixed(1)}%)',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
