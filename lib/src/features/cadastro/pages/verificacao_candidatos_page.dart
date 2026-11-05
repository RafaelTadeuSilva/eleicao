import 'package:eleicao/src/features/cadastro/controllers/candidato_control.dart';
import 'package:eleicao/src/features/cadastro/controllers/verificacao_candidatos.dart';
import 'package:eleicao/src/features/cadastro/pages/candidato_cad_page.dart';
import 'package:eleicao/src/features/cadastro/state/cadastro_state.dart';
import 'package:eleicao/src/features/urna/state/votacao_state.dart';
import 'package:eleicao/src/functions/image_helper.dart';
import 'package:flutter/material.dart';

/// Relatório de problemas no cadastro dos candidatos da eleição ativa.
/// Tocar num candidato abre o cadastro para corrigir; ao voltar, a análise
/// é refeita.
class VerificacaoCandidatosPage extends StatefulWidget {
  const VerificacaoCandidatosPage({super.key});

  @override
  State<VerificacaoCandidatosPage> createState() =>
      _VerificacaoCandidatosPageState();
}

class _VerificacaoCandidatosPageState extends State<VerificacaoCandidatosPage> {
  final control = CandidatoControl();
  ResultadoVerificacao? resultado;
  bool somenteSemFoto = false;

  @override
  void initState() {
    super.initState();
    verificar();
  }

  Future<void> verificar() async {
    final r = await control.verificarCandidatos();
    if (mounted) setState(() => resultado = r);
  }

  Future<void> abrirCadastro([String? id]) async {
    await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => CandidatoCadPage(id: id)));
    await verificar();
  }

  @override
  Widget build(BuildContext context) {
    final r = resultado;
    return Scaffold(
      appBar: AppBar(
        title: Text('Verificar Candidatos (${eventoAtualNome.value})'),
        actions: [
          IconButton(
            tooltip: 'Verificar novamente',
            icon: const Icon(Icons.refresh),
            onPressed: verificar,
          ),
        ],
      ),
      body: r == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(onRefresh: verificar, child: _corpo(r)),
    );
  }

  Widget _corpo(ResultadoVerificacao r) {
    final candidatos = somenteSemFoto
        ? r.candidatos.where((c) => c.semFoto).toList()
        : r.candidatos;

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        _resumo(r),
        if (r.semProblemas)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 64),
                SizedBox(height: 8),
                Text('Nenhum problema encontrado',
                    style: TextStyle(fontSize: 20)),
              ],
            ),
          ),
        if (r.cargosSemCandidato.isNotEmpty && !somenteSemFoto) ...[
          _titulo('Cargos sem candidato'),
          for (final p in r.cargosSemCandidato)
            Card(
              color: Colors.red.shade50,
              child: ListTile(
                leading: const Icon(Icons.error, color: Colors.red),
                title: Text(p.descricao),
                subtitle: const Text(
                    'O eleitor ficará travado nesta etapa. Toque para cadastrar.'),
                onTap: () => abrirCadastro(),
              ),
            ),
        ],
        if (candidatos.isNotEmpty) ...[
          _titulo(somenteSemFoto
              ? 'Candidatos sem foto (${candidatos.length})'
              : 'Candidatos com problemas (${candidatos.length})'),
          for (final c in candidatos) _itemCandidato(c),
        ] else if (somenteSemFoto)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('Todos os candidatos têm foto')),
          ),
      ],
    );
  }

  Widget _resumo(ResultadoVerificacao r) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Chip(
              avatar: const Icon(Icons.people, size: 18),
              label: Text('${r.totalCandidatos} candidatos'),
            ),
            Chip(
              avatar: const Icon(Icons.error, color: Colors.red, size: 18),
              label: Text('${r.totalErros} erros'),
            ),
            Chip(
              avatar: const Icon(Icons.warning, color: Colors.orange, size: 18),
              label: Text('${r.totalAvisos} avisos'),
            ),
            FilterChip(
              avatar: const Icon(Icons.no_photography, size: 18),
              label: Text('Só sem foto (${r.totalSemFoto})'),
              selected: somenteSemFoto,
              onSelected: (v) => setState(() => somenteSemFoto = v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _titulo(String texto) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 16, 4, 4),
        child: Text(texto,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      );

  Widget _itemCandidato(CandidatoComProblemas item) {
    final c = item.candidato;
    final foto = resolveImageProvider(c.urlImage);
    return Card(
      child: ListTile(
        onTap: () => abrirCadastro(c.id),
        leading: CircleAvatar(
          backgroundImage: foto,
          child: foto == null ? const Icon(Icons.person) : null,
        ),
        title: Text('${c.numero} - ${c.nome.isEmpty ? '(sem nome)' : c.nome}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${c.cargo.descricao} • ${zonaPorCodigo(c.zone).nome}'),
            for (final p in item.problemas)
              Row(
                children: [
                  Icon(
                    p.gravidade == Gravidade.erro ? Icons.error : Icons.warning,
                    size: 16,
                    color: p.gravidade == Gravidade.erro
                        ? Colors.red
                        : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Expanded(child: Text(p.descricao)),
                ],
              ),
          ],
        ),
        trailing: const Icon(Icons.edit),
      ),
    );
  }
}
