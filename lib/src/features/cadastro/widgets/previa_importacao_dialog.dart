import 'package:eleicao/src/features/cadastro/importacao/plano_importacao.dart';
import 'package:material_ui/material_ui.dart';

/// Mostra o que a planilha vai mudar antes de gravar. Fecha retornando
/// `true` quando o usuário confirma.
class PreviaImportacaoDialog extends StatelessWidget {
  const PreviaImportacaoDialog({super.key, required this.plano});

  final PlanoImportacao<Object?> plano;

  @override
  Widget build(BuildContext context) {
    final temErros = plano.erros.isNotEmpty;
    return AlertDialog(
      title: Text(temErros
          ? 'Planilha com erros — nada foi gravado'
          : 'Prévia da importação'),
      content: SizedBox(
        width: 560,
        child: ListView(
          shrinkWrap: true,
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final acao in AcaoImportacao.values)
                  Chip(label: Text('${acao.rotulo}: ${plano.contar(acao)}')),
                if (temErros)
                  Chip(
                    backgroundColor: Colors.red.shade100,
                    label: Text('Erros: ${plano.erros.length}'),
                  ),
              ],
            ),
            if (temErros) ...[
              _titulo('Corrija a planilha e envie novamente:'),
              for (final e in plano.erros)
                _mensagem(e.toString(), Icons.error, Colors.red),
            ] else if (!plano.podeAplicar)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Nenhuma alteração encontrada na planilha.'),
              ),
            if (plano.avisos.isNotEmpty) ...[
              _titulo('Avisos'),
              for (final a in plano.avisos)
                _mensagem(a.toString(), Icons.warning, Colors.orange),
            ],
            if (!temErros)
              for (final acao in [
                AcaoImportacao.criar,
                AcaoImportacao.atualizar,
                AcaoImportacao.excluir,
              ])
                if (plano.contar(acao) > 0) ...[
                  _titulo('${acao.rotulo}s (${plano.contar(acao)})'),
                  for (final item in plano.porAcao(acao))
                    ListTile(
                      dense: true,
                      leading: Icon(_icone(acao), color: _cor(acao)),
                      title: Text(item.descricao),
                      subtitle: item.alteracoes.isEmpty
                          ? Text('Linha ${item.linha}')
                          : Text('Linha ${item.linha}: '
                              '${item.alteracoes.join('; ')}'),
                    ),
                ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(temErros || !plano.podeAplicar ? 'Fechar' : 'Cancelar'),
        ),
        if (plano.podeAplicar)
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Aplicar ${plano.mudancas.length} alteração(ões)'),
          ),
      ],
    );
  }

  Widget _titulo(String texto) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: Text(texto, style: const TextStyle(fontWeight: FontWeight.bold)),
      );

  Widget _mensagem(String texto, IconData icone, Color cor) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icone, size: 18, color: cor),
            const SizedBox(width: 6),
            Expanded(child: Text(texto)),
          ],
        ),
      );

  IconData _icone(AcaoImportacao acao) => switch (acao) {
        AcaoImportacao.criar => Icons.add_circle,
        AcaoImportacao.atualizar => Icons.edit,
        AcaoImportacao.excluir => Icons.delete,
        AcaoImportacao.semAlteracao => Icons.check,
      };

  Color _cor(AcaoImportacao acao) => switch (acao) {
        AcaoImportacao.criar => Colors.green,
        AcaoImportacao.atualizar => Colors.blue,
        AcaoImportacao.excluir => Colors.red,
        AcaoImportacao.semAlteracao => Colors.grey,
      };
}
