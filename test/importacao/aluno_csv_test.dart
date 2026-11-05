import 'package:eleicao/src/features/cadastro/importacao/aluno_csv.dart';
import 'package:eleicao/src/features/cadastro/importacao/plano_importacao.dart';
import 'package:eleicao/src/functions/csv.dart';
import 'package:eleicao/src/models/aluno.dart';
import 'package:eleicao/src/models/zona.dart';
import 'package:flutter_test/flutter_test.dart';

const zonas = [Zona.geral, Zona(1, 'Turma A')];
final existentes = [
  Aluno(id: '1001', nome: 'Ana', turma: 1, titulo: 555),
  Aluno(id: '1002', nome: 'Bruno', turma: 0, titulo: 666),
];

PlanoImportacao<Aluno> planejar(String csv) =>
    AlunoCsv.planejar(csv, existentes: existentes, zonas: zonas);

List<String> erros(PlanoImportacao p) =>
    p.erros.map((e) => e.toString()).toList();

void main() {
  test('exportar e reenviar sem mudanças', () {
    final csv = AlunoCsv.exportar(existentes, zonas: zonas);
    expect(lerCsv(csv)[1].campos, ['1001', 'Ana', '1', 'Turma A', '555', '']);
    final plano = planejar(csv);
    expect(plano.erros, isEmpty);
    expect(plano.contar(AcaoImportacao.semAlteracao), 2);
  });

  test('matrícula nova cria, existente atualiza, EXCLUIR exclui', () {
    final plano = planejar('matricula;nome;turma;titulo;acao\n'
        '1003;Caio;Turma A;777;\n'
        '1001;Ana Maria;1;555;\n'
        '1002;;;;excluir');
    expect(plano.erros, isEmpty);
    expect(plano.itens.map((i) => i.acao), [
      AcaoImportacao.criar,
      AcaoImportacao.atualizar,
      AcaoImportacao.excluir,
    ]);
    expect(plano.itens[0].registro.turma, 1);
    expect(plano.itens[1].alteracoes, ['nome: Ana → Ana Maria']);
  });

  test('erros de matrícula, título e turma', () {
    final plano = planejar('matricula;nome;turma;titulo\n'
        '12;Ana;0;1\n'
        '1004;Eva;0;abc\n'
        '1005;Gil;Turma Z;9\n'
        '1006;Ivo;0;10\n'
        '1006;Ivo;0;10\n'
        '1007;Lia;0;555\n'
        '1009;;0;11\n'
        '1010;Rui;0;12;excluir');
    expect(erros(plano), [
      'Linha 2: matrícula "12" inválida: use 4 dígitos',
      'Linha 3: título "abc" inválido',
      'Linha 4: turma "Turma Z" não existe nesta eleição',
      'Linha 6: matrícula 1006 repetida (também na linha 5)',
      'Linha 8: nome não informado',
      'Linha 7: título 555 já pertence a "Ana"',
    ]);
  });

  test('colunas obrigatórias', () {
    expect(erros(planejar('nome;turma\nAna;0')).single, contains('matricula'));
    expect(erros(planejar('matricula;turma\n1003;0')).single,
        contains('nome, titulo'));
  });

  test('planilha só com exclusões precisa apenas de matrícula e acao', () {
    final plano = planejar('matricula;acao\n1001;EXCLUIR\n1002;excluir');
    expect(plano.erros, isEmpty);
    expect(plano.contar(AcaoImportacao.excluir), 2);
  });
}
