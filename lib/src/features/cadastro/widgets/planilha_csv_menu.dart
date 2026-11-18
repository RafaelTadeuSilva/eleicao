import 'package:eleicao/src/features/cadastro/importacao/arquivo_csv.dart';
import 'package:eleicao/src/features/cadastro/importacao/plano_importacao.dart';
import 'package:eleicao/src/features/cadastro/widgets/previa_importacao_dialog.dart';
import 'package:material_ui/material_ui.dart';

/// Menu "Planilha" com as opções de baixar e enviar CSV de um cadastro.
///
/// Fluxo do envio: escolhe o arquivo → analisa ([planejar]) → mostra a
/// prévia → se confirmado, grava ([aplicar]) → [aoConcluir].
class PlanilhaCsvMenu<T> extends StatelessWidget {
  const PlanilhaCsvMenu({
    super.key,
    required this.nomeArquivo,
    required this.exportar,
    required this.planejar,
    required this.aplicar,
    this.aoConcluir,
    this.abrirArquivo = ArquivoCsv.abrir,
    this.salvarArquivo = ArquivoCsv.salvar,
  });

  final String nomeArquivo;
  final Future<String> Function() exportar;
  final Future<PlanoImportacao<T>> Function(String texto) planejar;
  final Future<ResultadoImportacao> Function(PlanoImportacao<T> plano) aplicar;
  final VoidCallback? aoConcluir;

  /// Substituíveis em testes.
  final Future<String?> Function() abrirArquivo;
  final Future<String?> Function(String nome, String csv) salvarArquivo;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Planilha (CSV)',
      icon: const Icon(Icons.table_view),
      onSelected: (opcao) =>
          opcao == 'baixar' ? baixar(context) : enviar(context),
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'baixar',
          child: ListTile(
            leading: Icon(Icons.download),
            title: Text('Baixar planilha (CSV)'),
            subtitle: Text('Para editar no Excel e enviar de volta'),
          ),
        ),
        PopupMenuItem(
          value: 'enviar',
          child: ListTile(
            leading: Icon(Icons.upload),
            title: Text('Enviar planilha (CSV)'),
            subtitle: Text('Cria, altera ou exclui (coluna acao = EXCLUIR)'),
          ),
        ),
      ],
    );
  }

  void _avisar(BuildContext context, String texto) =>
      ScaffoldMessenger.maybeOf(context)
          ?.showSnackBar(SnackBar(content: Text(texto)));

  Future<void> baixar(BuildContext context) async {
    try {
      final caminho = await salvarArquivo(nomeArquivo, await exportar());
      if (caminho != null && context.mounted) {
        _avisar(context, 'Planilha salva em $caminho');
      }
    } catch (e) {
      if (context.mounted) _avisar(context, 'Erro ao salvar a planilha: $e');
    }
  }

  Future<void> enviar(BuildContext context) async {
    final String? texto;
    try {
      texto = await abrirArquivo();
    } catch (e) {
      if (context.mounted) _avisar(context, 'Erro ao abrir o arquivo: $e');
      return;
    }
    if (texto == null || !context.mounted) return;

    final plano = await planejar(texto);
    if (!context.mounted) return;
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => PreviaImportacaoDialog(plano: plano),
    );
    if (confirmado != true || !context.mounted) return;

    final resultado = await aplicar(plano);
    aoConcluir?.call();
    if (!context.mounted) return;
    _avisar(
        context,
        resultado.erro == null
            ? 'Planilha aplicada: ${resultado.aplicados} alteração(ões).'
            : 'Importação interrompida após ${resultado.aplicados} '
                'alteração(ões): ${resultado.erro}. Envie a planilha de novo '
                'para concluir.');
  }
}
