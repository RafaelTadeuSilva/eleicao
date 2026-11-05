import 'package:eleicao/src/features/cadastro/pages/lista_alunos_cad_page.dart';
import 'package:eleicao/src/features/cadastro/pages/lista_candidatos_cad_page.dart';
import 'package:eleicao/src/features/cadastro/state/cadastro_state.dart';
import 'package:eleicao/src/features/home/widgets/evento_eleicao_dialog.dart';
import 'package:eleicao/src/features/urna/controllers/votacao_control.dart';
import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/features/urna/pages/apuracao_page.dart';
import 'package:eleicao/src/features/urna/pages/liberacao_urna_page.dart';
import 'package:eleicao/src/features/urna/pages/proximo_eleitor_page.dart';
import 'package:eleicao/src/features/urna/state/votacao_state.dart';
import 'package:eleicao/src/injector.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final txtTerminal = TextEditingController();
  final txtZone = TextEditingController();

  @override
  void dispose() {
    txtTerminal.dispose();
    txtZone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final terminalAtual = prefs.getInt('terminal') ?? 0;
    final zonaAtual = zonaPorCodigo(prefs.getInt('zone') ?? 0).nome;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Urna Eletrônica'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Configuração Atual da Urna',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => changeTipoEleicao(context),
                      icon: const Icon(Icons.settings),
                      label: const Text('Trocar / Criar Eleição'),
                    ),
                  ],
                ),
                const Divider(),
                Text(
                  'Evento / Eleição: ${eventoAtualNome.value} (${eventoAtualId.value})',
                  style: const TextStyle(
                      fontSize: 19, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Chip(
                      avatar: const Icon(Icons.people, size: 18),
                      label: Text('Alunos: ${colecaoAlunosAtual.value}'),
                    ),
                    Chip(
                      avatar: const Icon(Icons.person_pin, size: 18),
                      label:
                          Text('Candidatos: ${colecaoCandidatosAtual.value}'),
                    ),
                    Chip(
                      avatar: const Icon(Icons.how_to_vote, size: 18),
                      label: Text('Votos: ${colecaoVotosAtual.value}'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Terminal: $terminalAtual  |  Zona Eleitoral: $zonaAtual',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 6),
                Text(
                  'Modalidade: ${modalidadeEleicao.value.descricao}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  'Etapas de Votação (${tipoEleicao.length} ${tipoEleicao.length == 1 ? "cargo" : "cargos"}):',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    for (int i = 0; i < tipoEleicao.length; i++)
                      Chip(
                        label: Text(
                          '${i + 1}º ${Cargo.getCargoByCodigo(tipoEleicao[i]).descricao} (${digitosDoCargo(tipoEleicao[i])} díg.)',
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => changeZone(context),
                      icon: const Icon(Icons.location_on_outlined),
                      label: const Text('Mudar Zona Eleitoral'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => changeTerminal(context),
                      icon: const Icon(Icons.computer),
                      label: const Text('Mudar Terminal'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => navigateToVotacao(context),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Iniciar Urna (Votação)'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: () => navigateToAlunos(context),
                child: const Text(
                  'Alunos',
                  style: TextStyle(fontSize: 25),
                )),
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: () => navigateToCandidatos(context),
                child: const Text(
                  'Candidatos',
                  style: TextStyle(fontSize: 25),
                )),
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: () => navigateToVotacao(context),
                child: const Text(
                  'Votação',
                  style: TextStyle(fontSize: 25),
                )),
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: () => navigateToLiberacao(context),
                child: const Text(
                  'Liberação',
                  style: TextStyle(fontSize: 25),
                )),
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: () => navigateToApuracao(context),
                child: const Text(
                  'Apuração',
                  style: TextStyle(fontSize: 25),
                )),
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: () => changeTerminal(context),
                child: const Text(
                  'Terminal',
                  style: TextStyle(fontSize: 25),
                )),
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: () => changeZone(context),
                child: const Text(
                  'Zona Eleitoral',
                  style: TextStyle(fontSize: 25),
                )),
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: () => changeTipoEleicao(context),
                child: const Text(
                  'Tipo de Eleição',
                  style: TextStyle(fontSize: 25),
                ))
          ],
        ),
      ),
    );
  }

  void navigateToAlunos(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const ListaAlunosCadPage(),
    ));
  }

  void navigateToCandidatos(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const ListaCandidatosCadPage(),
    ));
  }

  /// Antes de abrir a urna, confere se todos os cargos têm candidato
  /// visível na zona deste aparelho; sem isso o eleitor ficaria travado.
  Future<void> navigateToVotacao(BuildContext context) async {
    final zona = prefs.getInt('zone') ?? 0;
    final candidatos = await candidatoRepository.find({});
    final faltando =
        VotacaoControl.cargosSemCandidato(candidatos, zona, tipoEleicao);
    if (!context.mounted) return;

    if (faltando.isNotEmpty) {
      final continuar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cargos sem candidatos nesta urna'),
          content: Text(
            'Zona da urna: ${zonaPorCodigo(zona).nome}\n\n'
            'Não há candidatos visíveis para:\n'
            '${faltando.map((c) => '• ${c.descricao}').join('\n')}\n\n'
            'O eleitor não conseguirá concluir o voto. Verifique a zona '
            'desta urna e o cadastro dos candidatos.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Iniciar mesmo assim'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Voltar'),
            ),
          ],
        ),
      );
      if (continuar != true || !context.mounted) return;
    }

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => const ProximoEleitorPage(),
    ));
  }

  void navigateToLiberacao(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const LiberacaoUrnaPage(),
    ));
  }

  void navigateToApuracao(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const ApuracaoPage(),
    ));
  }

  void changeTerminal(BuildContext context) {
    txtTerminal.text = prefs.getInt('terminal').toString();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mudar Terminal'),
        content: TextField(
          controller: txtTerminal,
          keyboardType: TextInputType.number,
        ),
        actions: [
          ElevatedButton(
              onPressed: () => setTerminal(context),
              child: const Text('Salvar'))
        ],
      ),
    );
  }

  Future<void> changeTipoEleicao(BuildContext context) async {
    final eventosSalvos = await eventoEleicaoRepository.findAll();
    if (!context.mounted) return;
    await showDialog<bool>(
      context: context,
      builder: (_) => EventoEleicaoDialog(eventosSalvos: eventosSalvos),
    );
    if (mounted) setState(() {});
  }

  void changeZone(BuildContext context) {
    txtZone.text = zonaPorCodigo(prefs.getInt('zone') ?? 0).nome;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mudar Zona Eleitoral'),
        content: DropdownMenu(
          dropdownMenuEntries: zonasEleitorais.value
              .map((e) => DropdownMenuEntry(value: e.codigo, label: e.nome))
              .toList(),
          controller: txtZone,
        ),
        actions: [
          ElevatedButton(
              onPressed: () => setZone(context), child: const Text('Salvar'))
        ],
      ),
    );
  }

  void setTerminal(BuildContext context) {
    if (int.tryParse(txtTerminal.text) != null) {
      prefs.setInt('terminal', int.parse(txtTerminal.text));
      setState(() {});
      Navigator.of(context).pop();
    }
  }

  void setZone(BuildContext context) {
    if (txtZone.text.isNotEmpty) {
      final zone = zonaPorNome(txtZone.text)?.codigo ?? 0;
      prefs.setInt('zone', zone);
      setState(() {});
      Navigator.of(context).pop();
    }
  }
}
