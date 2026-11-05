import 'package:eleicao/src/features/cadastro/importacao/plano_importacao.dart';
import 'package:eleicao/src/functions/csv.dart';
import 'package:eleicao/src/models/aluno.dart';
import 'package:eleicao/src/models/zona.dart';

/// Planilha de alunos (eleitores).
///
/// A matrícula é a chave: matrícula nova cria o aluno, matrícula existente
/// atualiza, e `acao` = EXCLUIR exclui. Alunos fora da planilha não mudam.
/// `turma` aceita o código ou o nome da zona.
class AlunoCsv {
  static const colunas = [
    'matricula',
    'nome',
    'turma',
    'turma_nome',
    'titulo',
    'acao'
  ];

  static String exportar(List<Aluno> alunos, {required List<Zona> zonas}) {
    String nomeZona(int codigo) =>
        zonas.where((z) => z.codigo == codigo).firstOrNull?.nome ?? '';
    final ordenados = [...alunos]..sort((a, b) => a.nome.compareTo(b.nome));
    return gerarCsv([
      colunas,
      for (final a in ordenados)
        [a.id, a.nome, a.turma, nomeZona(a.turma), a.titulo, ''],
    ]);
  }

  static PlanoImportacao<Aluno> planejar(
    String texto, {
    required List<Aluno> existentes,
    required List<Zona> zonas,
  }) {
    final tabela = TabelaCsv.ler(texto);
    final erros = <MensagemImportacao>[];
    final itens = <ItemImportacao<Aluno>>[];

    if (tabela.colunas.isEmpty) {
      return const PlanoImportacao(
          itens: [], erros: [MensagemImportacao(0, 'Arquivo vazio')]);
    }
    if (!tabela.temColuna('matricula')) {
      return PlanoImportacao(itens: const [], erros: [
        colunasAusentes(const ['matricula'])
      ]);
    }
    // Exclusões só precisam da matrícula.
    final faltando =
        ['nome', 'titulo'].where((c) => !tabela.temColuna(c)).toList();
    var avisouColunas = false;

    final porId = {for (final a in existentes) a.id: a};
    final matriculas = <String, int>{};

    for (final linha in tabela.linhas) {
      String v(String coluna) => tabela.valor(linha, coluna);
      void erro(String texto) =>
          erros.add(MensagemImportacao(linha.numero, texto));

      final matricula = v('matricula');
      if (!RegExp(r'^\d{4}$').hasMatch(matricula)) {
        erro('matrícula "$matricula" inválida: use 4 dígitos');
        continue;
      }
      final repetida = matriculas[matricula];
      if (repetida != null) {
        erro('matrícula $matricula repetida (também na linha $repetida)');
        continue;
      }
      matriculas[matricula] = linha.numero;
      final atual = porId[matricula];

      if (palavrasExcluir.contains(normalizarCabecalho(v('acao')))) {
        if (atual == null) {
          erro('matrícula $matricula não existe para ser excluída');
        } else {
          itens.add(ItemImportacao(
              linha: linha.numero,
              acao: AcaoImportacao.excluir,
              registro: atual,
              descricao: _descricao(atual)));
        }
        continue;
      }

      if (faltando.isNotEmpty) {
        if (!avisouColunas) {
          avisouColunas = true;
          erros.add(colunasAusentes(faltando));
        }
        continue;
      }

      final errosAntes = erros.length;
      final nome = v('nome');
      if (nome.isEmpty) erro('nome não informado');
      final titulo = int.tryParse(v('titulo'));
      if (titulo == null) erro('título "${v('titulo')}" inválido');
      final zona = zonaDaPlanilha(v('turma'), zonas);
      if (zona == null) erro('turma "${v('turma')}" não existe nesta eleição');
      if (erros.length > errosAntes) continue;

      final novo = Aluno(
          id: matricula, nome: nome, turma: zona!.codigo, titulo: titulo!);
      if (atual == null) {
        itens.add(ItemImportacao(
            linha: linha.numero,
            acao: AcaoImportacao.criar,
            registro: novo,
            descricao: _descricao(novo)));
      } else {
        final alteracoes = [
          if (atual.nome != novo.nome) 'nome: ${atual.nome} → ${novo.nome}',
          if (atual.turma != novo.turma)
            'turma: ${atual.turma} → ${novo.turma}',
          if (atual.titulo != novo.titulo)
            'título: ${atual.titulo} → ${novo.titulo}',
        ];
        itens.add(ItemImportacao(
            linha: linha.numero,
            acao: alteracoes.isEmpty
                ? AcaoImportacao.semAlteracao
                : AcaoImportacao.atualizar,
            registro: novo,
            descricao: _descricao(novo),
            alteracoes: alteracoes));
      }
    }

    erros.addAll(_titulosDuplicados(itens, existentes));
    return PlanoImportacao(itens: itens, erros: erros);
  }

  /// O título identifica o eleitor na liberação da urna: não pode repetir.
  static List<MensagemImportacao> _titulosDuplicados(
      List<ItemImportacao<Aluno>> itens, List<Aluno> existentes) {
    final tocados = {for (final i in itens) i.registro.id};
    final gravados =
        itens.where((i) => i.acao != AcaoImportacao.excluir).toList();
    final finais = [
      ...existentes.where((a) => !tocados.contains(a.id)),
      ...gravados.map((i) => i.registro),
    ];
    return [
      for (final item in gravados)
        if (item.acao != AcaoImportacao.semAlteracao)
          if (finais
                  .where((a) =>
                      a.id != item.registro.id &&
                      a.titulo == item.registro.titulo)
                  .firstOrNull
              case final outro?)
            MensagemImportacao(item.linha,
                'título ${item.registro.titulo} já pertence a "${outro.nome}"'),
    ];
  }

  static String _descricao(Aluno a) => '${a.id} - ${a.nome}';
}
