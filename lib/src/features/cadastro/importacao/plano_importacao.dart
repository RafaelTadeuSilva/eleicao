import 'package:eleicao/src/functions/csv.dart';
import 'package:eleicao/src/models/zona.dart';

/// O que acontecerá com cada linha de uma planilha importada.
enum AcaoImportacao {
  criar('Novo'),
  atualizar('Alterado'),
  excluir('Excluído'),
  semAlteracao('Sem alteração');

  const AcaoImportacao(this.rotulo);
  final String rotulo;
}

/// Palavras aceitas na coluna `acao` para excluir um registro.
const palavrasExcluir = {'excluir', 'deletar', 'apagar', 'remover'};

class ItemImportacao<T> {
  /// Linha da planilha (1 = cabeçalho).
  final int linha;
  final AcaoImportacao acao;

  /// Registro a gravar (criar/atualizar) ou o existente (excluir).
  final T registro;

  /// Texto curto para identificar o registro (ex.: "12 - Ana (Prefeito)").
  final String descricao;

  /// Campos alterados (só para [AcaoImportacao.atualizar]).
  final List<String> alteracoes;

  const ItemImportacao({
    required this.linha,
    required this.acao,
    required this.registro,
    required this.descricao,
    this.alteracoes = const [],
  });
}

class MensagemImportacao {
  /// Linha da planilha; 0 quando se refere ao arquivo todo.
  final int linha;
  final String texto;

  const MensagemImportacao(this.linha, this.texto);

  @override
  String toString() => linha > 0 ? 'Linha $linha: $texto' : texto;
}

/// Resultado da análise de uma planilha, antes de gravar qualquer coisa.
///
/// Só pode ser aplicada se não houver [erros]: assim uma planilha com
/// problema não deixa o cadastro pela metade.
class PlanoImportacao<T> {
  final List<ItemImportacao<T>> itens;
  final List<MensagemImportacao> erros;
  final List<MensagemImportacao> avisos;

  const PlanoImportacao({
    required this.itens,
    this.erros = const [],
    this.avisos = const [],
  });

  Iterable<ItemImportacao<T>> porAcao(AcaoImportacao acao) =>
      itens.where((i) => i.acao == acao);

  int contar(AcaoImportacao acao) => porAcao(acao).length;

  /// Itens que mudam algo no banco.
  List<ItemImportacao<T>> get mudancas =>
      itens.where((i) => i.acao != AcaoImportacao.semAlteracao).toList();

  bool get podeAplicar => erros.isEmpty && mudancas.isNotEmpty;
}

/// Quantos itens foram gravados e o erro que interrompeu, se houve.
typedef ResultadoImportacao = ({int aplicados, Object? erro});

/// Zona informada numa planilha pelo código ou pelo nome (sem diferenciar
/// maiúsculas e acentos). Vazio = Geral; `null` se não existir em [zonas].
Zona? zonaDaPlanilha(String valor, List<Zona> zonas) {
  if (valor.isEmpty) return Zona.geral;
  final codigo = int.tryParse(valor);
  if (codigo != null) {
    return zonas.where((z) => z.codigo == codigo).firstOrNull;
  }
  final normalizado = normalizarCabecalho(valor);
  return zonas
      .where((z) => normalizarCabecalho(z.nome) == normalizado)
      .firstOrNull;
}

MensagemImportacao colunasAusentes(List<String> colunas) => MensagemImportacao(
    1,
    'Coluna(s) obrigatória(s) ausente(s): ${colunas.join(', ')}. '
    'Baixe a planilha pelo app para usar como modelo.');
