import 'package:eleicao/src/features/cadastro/state/cadastro_state.dart';
import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/features/urna/state/votacao_state.dart';
import 'package:eleicao/src/injector.dart';
import 'package:eleicao/src/models/evento_eleicao.dart';
import 'package:eleicao/src/models/zona.dart';
import 'package:material_ui/material_ui.dart';

/// Diálogo para escolher, criar ou editar o evento (eleição) ativo:
/// coleções do Firebase, modalidade, cargos/dígitos e zonas eleitorais.
///
/// Fecha retornando `true` quando um evento foi ativado.
class EventoEleicaoDialog extends StatefulWidget {
  const EventoEleicaoDialog({super.key, required this.eventosSalvos});

  final List<EventoEleicao> eventosSalvos;

  @override
  State<EventoEleicaoDialog> createState() => _EventoEleicaoDialogState();
}

class _EventoEleicaoDialogState extends State<EventoEleicaoDialog> {
  static const novoEventoKey = '__NOVO_EVENTO__';

  List<EventoEleicao> get eventosSalvos => widget.eventosSalvos;

  late String itemSelecionadoKey;
  final txtSufixo = TextEditingController(text: eventoAtualId.value);
  final txtNomeEvento = TextEditingController(text: eventoAtualNome.value);
  final txtColAlunos = TextEditingController(text: colecaoAlunosAtual.value);
  final txtColCandidatos =
      TextEditingController(text: colecaoCandidatosAtual.value);
  final txtColVotos = TextEditingController(text: colecaoVotosAtual.value);
  final txtColLiberacao =
      TextEditingController(text: colecaoLiberacaoAtual.value);
  final txtNovaZona = TextEditingController();

  var modalidadeSelecionada = modalidadeEleicao.value;
  var cargosSelecionados = List<int>.from(tipoEleicao);
  final mapaDigitosSelecionados = <int, int>{
    for (final c in Cargo.values) c.codigo: digitosDoCargo(c.codigo),
  };
  var zonasSelecionadas = List<Zona>.from(zonasEleitorais.value);
  var salvando = false;

  @override
  void initState() {
    super.initState();
    itemSelecionadoKey = eventoAtualId.value;
    if (!eventosSalvos.any((e) => e.id == itemSelecionadoKey)) {
      itemSelecionadoKey = eventosSalvos.first.id;
    }
  }

  @override
  void dispose() {
    for (final c in [
      txtSufixo,
      txtNomeEvento,
      txtColAlunos,
      txtColCandidatos,
      txtColVotos,
      txtColLiberacao,
      txtNovaZona,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void preencherComEvento(EventoEleicao ev) {
    txtSufixo.text = ev.id;
    txtNomeEvento.text = ev.nome;
    txtColAlunos.text = ev.colecaoAlunos;
    txtColCandidatos.text = ev.colecaoCandidatos;
    txtColVotos.text = ev.colecaoVotos;
    txtColLiberacao.text = ev.colecaoLiberacao;
    modalidadeSelecionada = ev.modalidade;
    cargosSelecionados = List<int>.from(ev.cargos);
    zonasSelecionadas = List<Zona>.from(ev.zonas);
    for (final c in Cargo.values) {
      mapaDigitosSelecionados[c.codigo] =
          ev.digitosPorCargo[c.codigo] ?? c.digitosPadrao;
    }
  }

  EventoEleicao montaEvento() => EventoEleicao.fromSufixo(
        sufixo: txtSufixo.text,
        nome: txtNomeEvento.text,
        colecaoAlunos: txtColAlunos.text,
        colecaoCandidatos: txtColCandidatos.text,
        colecaoVotos: txtColVotos.text,
        colecaoLiberacao: txtColLiberacao.text,
        modalidade: modalidadeSelecionada,
        cargos: cargosSelecionados,
        digitosPorCargo: mapaDigitosSelecionados,
        zonas: zonasSelecionadas,
      );

  /// O código (sufixo) é o id do documento na coleção Eleicoes; repetir o
  /// código de outro evento sobrescreveria esse evento no Firebase.
  /// Retorna a mensagem de erro, ou `null` se o código é válido.
  String? validarCodigo() {
    final codigo = txtSufixo.text.trim();
    if (codigo.isEmpty) {
      return 'Informe o Sufixo / Código do evento.';
    }
    if (codigo.contains('/')) {
      return 'O código do evento não pode conter "/".';
    }
    final editandoMesmoEvento =
        itemSelecionadoKey != novoEventoKey && codigo == itemSelecionadoKey;
    if (!editandoMesmoEvento && eventosSalvos.any((e) => e.id == codigo)) {
      return 'Já existe um evento com o código "$codigo". '
          'Selecione-o na lista para editá-lo ou use outro código.';
    }
    return null;
  }

  /// Ativa o evento neste aparelho e, se [salvarNoFirebase], grava também
  /// na coleção Eleicoes. Em caso de erro, mantém o diálogo aberto.
  Future<void> ativar({required bool salvarNoFirebase}) async {
    final erro = validarCodigo();
    if (erro != null) {
      ScaffoldMessenger.maybeOf(context)
          ?.showSnackBar(SnackBar(content: Text(erro)));
      return;
    }
    setState(() => salvando = true);
    final evento = montaEvento();
    try {
      if (salvarNoFirebase) {
        await eventoEleicaoRepository.save(evento);
      }
      await salvarEventoEleicaoLocal(evento);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => salvando = false);
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text('Erro ao salvar o evento: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cargosDisponiveis = Cargo.byModalidade(modalidadeSelecionada);

    return AlertDialog(
      title: const Text('Configurar Evento e Tipo de Eleição'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...secaoEvento(),
              const Divider(),
              ...secaoModalidade(),
              ...secaoCargos(cargosDisponiveis),
              const Divider(),
              ...secaoZonas(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: salvando ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        Tooltip(
          message: 'Não grava no Firebase: o evento não aparecerá na lista '
              'depois que outro evento for ativado.',
          child: OutlinedButton(
            onPressed: salvando ? null : () => ativar(salvarNoFirebase: false),
            child: const Text('Apenas Ativar neste Aparelho'),
          ),
        ),
        ElevatedButton(
          onPressed: salvando ? null : () => ativar(salvarNoFirebase: true),
          child: Text(salvando ? 'Salvando...' : 'Salvar no Firebase e Ativar'),
        ),
      ],
    );
  }

  /// 1. Escolha do evento, código/nome e coleções do Firebase.
  List<Widget> secaoEvento() {
    return [
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
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          setState(() {
            itemSelecionadoKey = valor;
            if (valor == novoEventoKey) {
              txtSufixo.text = '';
              txtNomeEvento.text = '';
              txtColAlunos.text = 'Alunos2026';
              txtColCandidatos.text = 'Candidatos';
              txtColVotos.text = 'Votos';
              txtColLiberacao.text = 'LiberacaoUrna';
              zonasSelecionadas = [Zona.geral];
            } else {
              final escolhido = eventosSalvos.firstWhere((e) => e.id == valor);
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
                setState(() {
                  if (txtNomeEvento.text.isEmpty ||
                      txtNomeEvento.text.startsWith('Eleição ')) {
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
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  setState(() {
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
                  onChanged: (_) => setState(() {}),
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
                  onChanged: (_) => setState(() {}),
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
    ];
  }

  /// 2. Modalidade (política, CIPA, esportes).
  List<Widget> secaoModalidade() {
    return [
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
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            setState(() {
              modalidadeSelecionada = novaModalidade;
              final padrao = Cargo.byModalidade(novaModalidade);
              cargosSelecionados = [padrao.first.codigo];
            });
          }
        },
      ),
    ];
  }

  /// 3. Cargos na ordem de votação e dígitos de cada um.
  List<Widget> secaoCargos(List<Cargo> cargosDisponiveis) {
    return [
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
                  setState(() {
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
                  setState(() {
                    cargosSelecionados = [cargosDisponiveis.first.codigo];
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
        final indexOrdem = cargosSelecionados.indexOf(cargo.codigo);
        final selecionado = indexOrdem != -1;
        final digitosCargo =
            mapaDigitosSelecionados[cargo.codigo] ?? cargo.digitosPadrao;
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: Checkbox(
            value: selecionado,
            onChanged: (checked) {
              setState(() {
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
                setState(() {
                  mapaDigitosSelecionados[cargo.codigo] = novoDig;
                });
              }
            },
          ),
        );
      }),
    ];
  }

  /// 4. Zonas eleitorais do evento.
  List<Widget> secaoZonas() {
    return [
      const Text(
        '4. Zonas Eleitorais:',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const Text(
        'Candidatos da zona Geral aparecem em todas as urnas; '
        'os de outra zona (ex.: uma turma) só nas urnas daquela zona.',
        style: TextStyle(fontSize: 12, color: Colors.black54),
      ),
      const SizedBox(height: 6),
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final z in zonasSelecionadas)
            Chip(
              label: Text('${z.codigo} - ${z.nome}'),
              onDeleted: z.isGeral
                  ? null
                  : () => setState(() => zonasSelecionadas =
                      zonasSelecionadas.where((e) => e != z).toList()),
            ),
        ],
      ),
      const SizedBox(height: 6),
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: txtNovaZona,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Nova zona (ex: 1º Ano A)',
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () {
              final nome = txtNovaZona.text.trim();
              if (nome.isEmpty) return;
              setState(() {
                zonasSelecionadas = Zona.normalizar([
                  ...zonasSelecionadas,
                  Zona(Zona.proximoCodigo(zonasSelecionadas), nome),
                ]);
                txtNovaZona.clear();
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Adicionar'),
          ),
        ],
      ),
    ];
  }
}
