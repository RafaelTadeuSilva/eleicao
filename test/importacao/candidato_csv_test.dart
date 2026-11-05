import 'package:eleicao/src/features/cadastro/importacao/candidato_csv.dart';
import 'package:eleicao/src/features/cadastro/importacao/plano_importacao.dart';
import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/functions/csv.dart';
import 'package:eleicao/src/models/candidato.dart';
import 'package:eleicao/src/models/zona.dart';
import 'package:flutter_test/flutter_test.dart';

const turmaA = Zona(1, '1º Ano A');
const zonas = [Zona.geral, turmaA];
final cargos = [Cargo.prefeito.codigo, Cargo.vereador.codigo];

final existentes = [
  Candidato(
      id: 'p1',
      numero: 12,
      nome: 'Ana',
      nomeVice: 'Bia',
      urlImage: 'data:image/png;base64,AAAA',
      urlImageVice: 'https://x/bia.png',
      cargo: Cargo.prefeito,
      zone: 0),
  Candidato(
      id: 'v1',
      numero: 1234,
      nome: 'Caio',
      urlImage: '',
      cargo: Cargo.vereador,
      zone: 1),
];

PlanoImportacao<Candidato> planejar(String csv, {List<Candidato>? base}) =>
    CandidatoCsv.planejar(
      csv,
      existentes: base ?? existentes,
      cargos: cargos,
      digitosDoCargo: (c) => Cargo.getCargoByCodigo(c).digitosPadrao,
      zonas: zonas,
    );

String exportar() =>
    CandidatoCsv.exportar(existentes, cargos: cargos, zonas: zonas);

const cabecalho = 'id;numero;nome;cargo;zona;nome_vice;foto;foto_vice;acao';

List<String> erros(PlanoImportacao p) =>
    p.erros.map((e) => e.toString()).toList();

void main() {
  group('exportar', () {
    test('gera cabeçalho e uma linha por candidato, na ordem dos cargos', () {
      final linhas = lerCsv(exportar());
      expect(linhas.first.campos, CandidatoCsv.colunas);
      expect(linhas[1].campos, [
        'p1',
        '12',
        'Ana',
        '2',
        'Prefeito',
        '0',
        'Geral',
        'Bia',
        CandidatoCsv.marcadorFotoNoApp,
        'https://x/bia.png',
        '',
      ]);
      expect(linhas[2].campos.take(7),
          ['v1', '1234', 'Caio', '4', 'Vereador', '1', '1º Ano A']);
    });

    test('reenviar a planilha baixada não muda nada', () {
      final plano = planejar(exportar());
      expect(plano.erros, isEmpty);
      expect(plano.contar(AcaoImportacao.semAlteracao), 2);
      expect(plano.podeAplicar, isFalse);
    });
  });

  group('importar', () {
    test('id vazio cria candidato; aceita cargo e zona por nome', () {
      final plano = planejar('$cabecalho\n;5678;Duda;vereador;1º ano a;;;;');
      expect(plano.erros, isEmpty);
      final item = plano.itens.single;
      expect(item.acao, AcaoImportacao.criar);
      expect(item.linha, 2);
      expect(item.registro.id, '');
      expect(item.registro.cargo, Cargo.vereador);
      expect(item.registro.zone, 1);
      expect(item.registro.urlImage, '', reason: 'sem foto é permitido');
    });

    test('zona vazia é Geral', () {
      final plano = planejar('numero;nome;cargo\n13;Eva;2');
      expect(plano.itens.single.registro.zone, 0);
    });

    test('id existente atualiza e lista os campos alterados', () {
      final plano = planejar('$cabecalho\np1;12;Ana Paula;2;0;Bia;;;');
      final item = plano.itens.single;
      expect(item.acao, AcaoImportacao.atualizar);
      expect(item.alteracoes, ['nome: Ana → Ana Paula']);
      expect(item.registro.urlImage, 'data:image/png;base64,AAAA',
          reason: 'foto vazia mantém a atual');
      expect(item.registro.urlImageVice, 'https://x/bia.png');
    });

    test('link de foto troca a foto (e normaliza Google Drive)', () {
      final plano = planejar(
          '$cabecalho\nv1;1234;Caio;4;1;;https://drive.google.com/file/d/XYZ/view;;');
      final item = plano.itens.single;
      expect(item.registro.urlImage, 'https://lh3.googleusercontent.com/d/XYZ');
      expect(item.alteracoes, ['foto alterada']);
    });

    test('acao EXCLUIR exclui pelo id; demais colunas são ignoradas', () {
      final plano = planejar('id;acao\nv1;Excluir');
      expect(plano.erros, isEmpty);
      expect(plano.itens.single.acao, AcaoImportacao.excluir);
      expect(plano.itens.single.registro.nome, 'Caio');
    });

    test('candidatos fora da planilha não são excluídos', () {
      final plano = planejar('$cabecalho\n;5678;Duda;4;1;;;;');
      expect(plano.contar(AcaoImportacao.excluir), 0);
    });

    test('cargo fora da eleição gera aviso, não erro', () {
      final plano = planejar('numero;nome;cargo\n123;Gil;3');
      expect(plano.erros, isEmpty);
      expect(plano.avisos.single.texto, contains('Senador'));
    });

    test('aceita planilha separada por vírgula', () {
      final plano = planejar('numero,nome,cargo,zona\n5678,Duda,4,1');
      expect(plano.erros, isEmpty);
      expect(plano.itens.single.acao, AcaoImportacao.criar);
    });
  });

  group('erros bloqueiam a planilha inteira', () {
    test('colunas obrigatórias ausentes', () {
      expect(
          erros(planejar('id;nome\n;Ana')).single, contains('numero, cargo'));
      expect(planejar('').erros.single.texto, 'Arquivo vazio');
      expect(planejar('id;acao\nv1;excluir').erros, isEmpty,
          reason: 'exclusão só precisa de id');
    });

    test('valores inválidos informam a linha', () {
      final plano = planejar('$cabecalho\n'
          ';abc;Ana;2;0;;;;\n'
          ';14;;2;0;;;;\n'
          ';15;Eva;Rei;0;;;;\n'
          ';16;Gil;2;9;;;;\n'
          ';17;Ivo;2;0;;foto.png;;\n'
          ';123;Lia;2;0;;;;');
      expect(erros(plano), [
        'Linha 2: número "abc" inválido',
        'Linha 3: nome não informado',
        'Linha 4: cargo "Rei" não reconhecido',
        'Linha 5: zona "9" não existe nesta eleição',
        'Linha 6: foto "foto.png" inválida: use um link http(s) ou deixe vazio',
        'Linha 7: número 123 deve ter 2 dígitos para Prefeito',
      ]);
      expect(plano.podeAplicar, isFalse);
    });

    test('id desconhecido, id repetido e exclusão sem id', () {
      final plano = planejar('$cabecalho\n'
          'zzz;12;Ana;2;0;;;;\n'
          'p1;12;Ana;2;0;Bia;;;\n'
          'p1;12;Ana;2;0;Bia;;;\n'
          ';;;;;;;;EXCLUIR');
      expect(erros(plano), [
        'Linha 2: id "zzz" não existe nesta eleição. Para criar um candidato novo, deixe a coluna id vazia',
        'Linha 4: id "p1" repetido (também na linha 3)',
        'Linha 5: para excluir, informe o id do candidato',
      ]);
    });

    test('número repetido com candidato existente ou dentro da planilha', () {
      final plano = planejar('$cabecalho\n'
          ';12;Outro;2;0;;;;\n'
          ';5678;X;4;1;;;;\n'
          ';5678;Y;4;1;;;;');
      expect(erros(plano), [
        'Linha 2: número 12 de Prefeito já pertence a "Ana"',
        'Linha 3: número 5678 de Vereador já pertence a "Y"',
        'Linha 4: número 5678 de Vereador já pertence a "X"',
      ]);
    });

    test('número liberado por exclusão na mesma planilha pode ser reusado', () {
      final plano = planejar('$cabecalho\n'
          'p1;;;;;;;;excluir\n'
          ';12;Nova;2;0;;;;');
      expect(plano.erros, isEmpty);
      expect(plano.contar(AcaoImportacao.excluir), 1);
      expect(plano.contar(AcaoImportacao.criar), 1);
    });

    test('mesmo número em turmas diferentes é permitido', () {
      final plano =
          planejar('$cabecalho\n;1234;Outro;4;2;;;;', base: existentes);
      expect(erros(plano).single, contains('zona "2"'),
          reason: 'turma 2 não existe nesta eleição');
    });
  });
}
