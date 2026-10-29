import 'package:eleicao/src/features/cadastro/pages/lista_alunos_cad_page.dart';
import 'package:eleicao/src/features/cadastro/pages/lista_candidatos_cad_page.dart';
import 'package:eleicao/src/features/cadastro/state/cadastro_state.dart';
import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/features/urna/pages/apuracao_page.dart';
import 'package:eleicao/src/features/urna/pages/liberacao_urna_page.dart';
import 'package:eleicao/src/features/urna/pages/proximo_eleitor_page.dart';
import 'package:eleicao/src/features/urna/state/votacao_state.dart';
import 'package:eleicao/src/injector.dart';
import 'package:eleicao/src/models/evento_eleicao.dart';
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
    final zonaAtual = getTurmaById(prefs.getInt('zone') ?? 0).$2;

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

  Future<void> changeTipoEleicao(BuildContext context) async {
    final eventosSalvos = await eventoEleicaoRepository.findAll();
    if (!context.mounted) return;

    const novoEventoKey = '__NOVO_EVENTO__';
    var itemSelecionadoKey = eventoAtualId.value;
    if (!eventosSalvos.any((e) => e.id == itemSelecionadoKey)) {
      itemSelecionadoKey = eventosSalvos.first.id;
    }

    final txtSufixo = TextEditingController(text: eventoAtualId.value);
    final txtNomeEvento = TextEditingController(text: eventoAtualNome.value);
    final txtColAlunos = TextEditingController(text: colecaoAlunosAtual.value);
    final txtColCandidatos =
        TextEditingController(text: colecaoCandidatosAtual.value);
    final txtColVotos = TextEditingController(text: colecaoVotosAtual.value);
    final txtColLiberacao =
        TextEditingController(text: colecaoLiberacaoAtual.value);

    var modalidadeSelecionada = modalidadeEleicao.value;
    var cargosSelecionados = List<int>.from(tipoEleicao);
    final mapaDigitosSelecionados = <int, int>{
      for (final c in Cargo.values) c.codigo: digitosDoCargo(c.codigo),
    };
    var salvando = false;

    void preencherComEvento(EventoEleicao ev) {
      txtSufixo.text = ev.id;
      txtNomeEvento.text = ev.nome;
      txtColAlunos.text = ev.colecaoAlunos;
      txtColCandidatos.text = ev.colecaoCandidatos;
      txtColVotos.text = ev.colecaoVotos;
      txtColLiberacao.text = ev.colecaoLiberacao;
      modalidadeSelecionada = ev.modalidade;
      cargosSelecionados = List<int>.from(ev.cargos);
      for (final c in Cargo.values) {
        mapaDigitosSelecionados[c.codigo] =
            ev.digitosPorCargo[c.codigo] ?? c.digitosPadrao;
      }
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final cargosDisponiveis =
                Cargo.byModalidade(modalidadeSelecionada);

            return AlertDialog(
              title: const Text('Configurar Evento e Tipo de Eleição'),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '1. Escolher Eleição / Evento (coleção Eleicoes):',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        key: ValueKey(itemSelecionadoKey),
                        initialValue: itemSelecionadoKey,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: [
                          ...eventosSalvos.map(
                            (ev) => DropdownMenuItem<String>(
                              value: ev.id,
                              child: Text('${ev.nome} (${ev.id})'),
                            ),
                          ),
                          const DropdownMenuItem<String>(
                            value: novoEventoKey,
                            child: Text(
                              '+ Criar Novo Evento / Eleição...',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (valor) {
                          if (valor == null) return;
                          setModalState(() {
                            itemSelecionadoKey = valor;
                            if (valor == novoEventoKey) {
                              txtSufixo.text = '';
                              txtNomeEvento.text = '';
                              txtColAlunos.text = 'Alunos2026';
                              txtColCandidatos.text = 'Candidatos';
                              txtColVotos.text = 'Votos';
                              txtColLiberacao.text = 'LiberacaoUrna';
                            } else {
                              final escolhido = eventosSalvos
                                  .firstWhere((e) => e.id == valor);
                              preencherComEvento(escolhido);
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: txtSufixo,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Sufixo / Código (ex: Esportes2026)',
                                isDense: true,
                              ),
                              onChanged: (val) {
                                final limpo = val.trim();
                                setModalState(() {
                                  if (txtNomeEvento.text.isEmpty ||
                                      txtNomeEvento.text
                                          .startsWith('Eleição ')) {
                                    txtNomeEvento.text = 'Eleição $limpo';
                                  }
                                  txtColCandidatos.text = 'Candidatos$limpo';
                                  txtColVotos.text = 'Votos$limpo';
                                  txtColLiberacao.text = 'LiberacaoUrna$limpo';
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: txtNomeEvento,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Nome do Evento (ex: Esportes 2026)',
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: const Text(
                          'Coleções do Firebase deste Evento',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'Alunos: ${txtColAlunos.text} | Candidatos: ${txtColCandidatos.text} | Votos: ${txtColVotos.text}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        children: [
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: txtColAlunos,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Coleção de Alunos',
                                    isDense: true,
                                  ),
                                  onChanged: (_) => setModalState(() {}),
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () {
                                  setModalState(() {
                                    txtColAlunos.text = 'Alunos2026';
                                  });
                                },
                                child: const Text('Usar Alunos2026'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: txtColCandidatos,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Coleção de Candidatos',
                                    isDense: true,
                                  ),
                                  onChanged: (_) => setModalState(() {}),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: txtColVotos,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Coleção de Votos',
                                    isDense: true,
                                  ),
                                  onChanged: (_) => setModalState(() {}),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: txtColLiberacao,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Coleção de Liberação de Urna',
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                      ),
                      const Divider(),
                      const Text(
                        '2. Modalidade da Eleição:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<TipoEleicaoModalidade>(
                        key: ValueKey(modalidadeSelecionada),
                        initialValue: modalidadeSelecionada,
                        decoration: const InputDecoration(
                          labelText: 'Modalidade',
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
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '3. Cargos e Dígitos (${cargosSelecionados.length}/10):',
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
                        'Marque os cargos na ordem de votação e escolha quantos dígitos cada cargo terá na urna:',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(height: 4),
                      ...cargosDisponiveis.map((cargo) {
                        final indexOrdem =
                            cargosSelecionados.indexOf(cargo.codigo);
                        final selecionado = indexOrdem != -1;
                        final digitosCargo =
                            mapaDigitosSelecionados[cargo.codigo] ??
                                cargo.digitosPadrao;
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Checkbox(
                            value: selecionado,
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
                          ),
                          title: Row(
                            children: [
                              if (selecionado) ...[
                                CircleAvatar(
                                  radius: 12,
                                  child: Text(
                                    '${indexOrdem + 1}º',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Expanded(child: Text(cargo.descricao)),
                            ],
                          ),
                          trailing: DropdownButton<int>(
                            value: digitosCargo,
                            underline: const SizedBox.shrink(),
                            items: const [2, 3, 4, 5]
                                .map(
                                  (d) => DropdownMenuItem<int>(
                                    value: d,
                                    child: Text('$d díg.'),
                                  ),
                                )
                                .toList(),
                            onChanged: (novoDig) {
                              if (novoDig != null) {
                                setModalState(() {
                                  mapaDigitosSelecionados[cargo.codigo] =
                                      novoDig;
                                });
                              }
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: salvando
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                OutlinedButton(
                  onPressed: salvando
                      ? null
                      : () async {
                          final evento = EventoEleicao.fromSufixo(
                            sufixo: txtSufixo.text,
                            nome: txtNomeEvento.text,
                            colecaoAlunos: txtColAlunos.text,
                            colecaoCandidatos: txtColCandidatos.text,
                            colecaoVotos: txtColVotos.text,
                            colecaoLiberacao: txtColLiberacao.text,
                            modalidade: modalidadeSelecionada,
                            cargos: cargosSelecionados,
                            digitosPorCargo: mapaDigitosSelecionados,
                          );
                          await salvarEventoEleicaoLocal(evento);
                          if (mounted) {
                            setState(() {});
                          }
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                          }
                        },
                  child: const Text('Apenas Ativar neste Aparelho'),
                ),
                ElevatedButton(
                  onPressed: salvando
                      ? null
                      : () async {
                          setModalState(() => salvando = true);
                          final evento = EventoEleicao.fromSufixo(
                            sufixo: txtSufixo.text,
                            nome: txtNomeEvento.text,
                            colecaoAlunos: txtColAlunos.text,
                            colecaoCandidatos: txtColCandidatos.text,
                            colecaoVotos: txtColVotos.text,
                            colecaoLiberacao: txtColLiberacao.text,
                            modalidade: modalidadeSelecionada,
                            cargos: cargosSelecionados,
                            digitosPorCargo: mapaDigitosSelecionados,
                          );
                          await eventoEleicaoRepository.save(evento);
                          await salvarEventoEleicaoLocal(evento);
                          if (mounted) {
                            setState(() {});
                          }
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                          }
                        },
                  child: Text(
                      salvando ? 'Salvando...' : 'Salvar no Firebase e Ativar'),
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
}
