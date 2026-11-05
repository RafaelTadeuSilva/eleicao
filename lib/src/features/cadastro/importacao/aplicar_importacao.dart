import 'package:eleicao/src/features/cadastro/importacao/plano_importacao.dart';

/// Grava as mudanças de [plano] uma a uma. Se uma gravação falhar, para e
/// informa quantas já foram aplicadas (a planilha pode ser reenviada: o que
/// já foi gravado aparece como "sem alteração").
Future<ResultadoImportacao> aplicarPlano<T>(
  PlanoImportacao<T> plano, {
  required Future<void> Function(T registro) criar,
  required Future<void> Function(T registro) atualizar,
  required Future<void> Function(T registro) excluir,
}) async {
  if (plano.erros.isNotEmpty) {
    return (aplicados: 0, erro: StateError('A planilha tem erros'));
  }
  var aplicados = 0;
  try {
    for (final item in plano.mudancas) {
      switch (item.acao) {
        case AcaoImportacao.criar:
          await criar(item.registro);
        case AcaoImportacao.atualizar:
          await atualizar(item.registro);
        case AcaoImportacao.excluir:
          await excluir(item.registro);
        case AcaoImportacao.semAlteracao:
          continue;
      }
      aplicados++;
    }
    return (aplicados: aplicados, erro: null);
  } catch (e) {
    return (aplicados: aplicados, erro: e);
  }
}
