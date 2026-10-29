import 'package:eleicao/src/features/cadastro/controllers/candidato_control.dart';
import 'package:eleicao/src/features/cadastro/pages/candidato_cad_page.dart';
import 'package:eleicao/src/features/cadastro/state/cadastro_state.dart';
import 'package:eleicao/src/models/candidato.dart';
import 'package:flutter/material.dart';

class ListaCandidatosCadPage extends StatefulWidget {
  const ListaCandidatosCadPage({super.key});

  @override
  State<ListaCandidatosCadPage> createState() => _ListaCandidatosCadPageState();
}

class _ListaCandidatosCadPageState extends State<ListaCandidatosCadPage> {
  late final CandidatoControl control;

  @override
  void initState() {
    control = CandidatoControl();
    control.listaCandidatos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Lista de Candidatos'),
        ),
        body: montaBody(),
        floatingActionButton: FloatingActionButton(
          onPressed: navigateToCandidatoPage,
          child: const Icon(Icons.add),
        ));
  }

  Widget montaBody() {
    return ValueListenableBuilder(
      valueListenable: listCandidatos,
      builder: (context, list, child) => ListView.builder(
        itemBuilder: (context, index) => montaItem(index, list),
        itemCount: list.length,
      ),
    );
  }

  Widget montaItem(int index, List<Candidato> list) {
    final Candidato(:id, :numero, :nome, :cargo) = list[index];
    return Card(
      child: InkWell(
        onTap: () => navigateToCandidatoPage(id),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '$numero - $nome',
                  style: const TextStyle(fontSize: 22),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                cargo.descricao,
                style: const TextStyle(fontSize: 20, color: Colors.black87),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => confirmarExclusao(id, nome, cargo.descricao),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void confirmarExclusao(String id, String nome, String cargoDesc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Candidato'),
        content: Text('Deseja remover $nome ($cargoDesc)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await control.delete(id);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void navigateToCandidatoPage([String? id]) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => CandidatoCadPage(id: id)))
        .whenComplete(() => control.listaCandidatos());
  }
}
