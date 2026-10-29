import 'package:eleicao/src/features/cadastro/pages/lista_alunos_cad_page.dart';
import 'package:eleicao/src/features/cadastro/pages/lista_candidatos_cad_page.dart';
import 'package:eleicao/src/features/cadastro/state/cadastro_state.dart';
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
  Widget build(BuildContext context) {
    final terminalAtual = prefs.getInt('terminal') ?? 0;
    final zonaAtual = getTurmaById(prefs.getInt('zone') ?? 0).$2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Urna Eletrônica'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Configuração Atual da Urna',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                Text(
                  'Terminal: $terminalAtual',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 6),
                Text(
                  'Zona Eleitoral: $zonaAtual',
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
                          '${i + 1}º ${Cargo.getCargoByCodigo(tipoEleicao[i]).descricao}',
                        ),
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

  void navigateToVotacao(BuildContext context) {
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

  void changeTipoEleicao(BuildContext context) {
    var modalidadeSelecionada = modalidadeEleicao.value;
    var cargosSelecionados = List<int>.from(tipoEleicao);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final cargosDisponiveis =
                Cargo.byModalidade(modalidadeSelecionada);

            return AlertDialog(
              title: const Text('Configurar Tipo de Eleição'),
              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Modalidade da Eleição:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<TipoEleicaoModalidade>(
                        initialValue: modalidadeSelecionada,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: TipoEleicaoModalidade.values
                            .map((m) => DropdownMenuItem(
                                  value: m,
                                  child: Text(m.descricao),
                                ))
                            .toList(),
                        onChanged: (novaModalidade) {
                          if (novaModalidade != null &&
                              novaModalidade != modalidadeSelecionada) {
                            setModalState(() {
                              modalidadeSelecionada = novaModalidade;
                              final padrao =
                                  Cargo.byModalidade(novaModalidade);
                              cargosSelecionados = [padrao.first.codigo];
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Cargos/Modalidades (${cargosSelecionados.length}/10):',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () {
                                  setModalState(() {
                                    cargosSelecionados = cargosDisponiveis
                                        .take(10)
                                        .map((e) => e.codigo)
                                        .toList();
                                  });
                                },
                                child: const Text('Todos (máx 10)'),
                              ),
                              TextButton(
                                onPressed: () {
                                  setModalState(() {
                                    cargosSelecionados = [
                                      cargosDisponiveis.first.codigo
                                    ];
                                  });
                                },
                                child: const Text('Apenas 1º'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Text(
                        'Marque na ordem em que serão votados na urna (mínimo 1, máximo 10):',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      ...cargosDisponiveis.map((cargo) {
                        final indexOrdem =
                            cargosSelecionados.indexOf(cargo.codigo);
                        final selecionado = indexOrdem != -1;
                        return CheckboxListTile(
                          dense: true,
                          value: selecionado,
                          title: Text(cargo.descricao),
                          secondary: selecionado
                              ? CircleAvatar(
                                  radius: 14,
                                  child: Text(
                                    '${indexOrdem + 1}º',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                )
                              : null,
                          onChanged: (checked) {
                            setModalState(() {
                              if (checked == true) {
                                if (cargosSelecionados.length < 10) {
                                  cargosSelecionados.add(cargo.codigo);
                                }
                              } else {
                                if (cargosSelecionados.length > 1) {
                                  cargosSelecionados.remove(cargo.codigo);
                                }
                              }
                            });
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => salvarTipoEleicao(
                    context,
                    modalidadeSelecionada,
                    cargosSelecionados,
                  ),
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void changeZone(BuildContext context) {
    txtZone.text = getTurmaById(prefs.getInt('zone') ?? 0).$2;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mudar Zona Eleitoral'),
        content: DropdownMenu(
          dropdownMenuEntries: listTurmas
              .map((e) => DropdownMenuEntry(value: e.$1, label: e.$2))
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
      final zone = getTurmaByName(txtZone.text)?.$1 ?? 0;
      prefs.setInt('zone', zone);
      setState(() {});
      Navigator.of(context).pop();
    }
  }

  Future<void> salvarTipoEleicao(
    BuildContext context,
    TipoEleicaoModalidade modalidade,
    List<int> cargosSelecionados,
  ) async {
    await prefs.setInt('modalidade_eleicao', modalidade.codigo);
    await prefs.setStringList(
      'cargos_ativos',
      cargosSelecionados.map((e) => e.toString()).toList(),
    );
    aplicarConfigEleicao(
      modalidade: modalidade,
      codigosCargos: cargosSelecionados,
    );
    if (mounted) {
      setState(() {});
      Navigator.of(this.context).pop();
    }
  }
}
