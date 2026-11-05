import 'dart:convert';

import 'package:eleicao/src/features/cadastro/importacao/arquivo_csv.dart';
import 'package:eleicao/src/functions/csv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('gerarCsv / lerCsv', () {
    test('ida e volta com aspas, separador, quebra de linha e espaços', () {
      final linhas = [
        ['id', 'nome', 'obs'],
        ['1', 'Ana; Maria', 'disse "oi"'],
        ['2', 'Bruno', 'linha 1\nlinha 2'],
        ['3', ' com espaço ', ''],
      ];
      final csv = gerarCsv(linhas);
      final lidas = lerCsv(csv);
      expect(lidas.map((l) => l.campos), linhas);
    });

    test('usa ; por padrão e CRLF entre linhas', () {
      expect(
          gerarCsv([
            ['a', 'b'],
            [1, null]
          ]),
          'a;b\r\n1;\r\n');
    });

    test('detecta vírgula e tab como separador', () {
      expect(lerCsv('a,b\n1,2').last.campos, ['1', '2']);
      expect(lerCsv('a\tb\n1\t2').last.campos, ['1', '2']);
      expect(detectarSeparador('"x;y",b,c\n'), ',');
    });

    test('ignora BOM e linhas vazias, mantendo o número da linha', () {
      final lidas = lerCsv('${bomUtf8}a;b\n\n1;2\n;\n"x\ny";3\n4;5');
      expect(lidas.map((l) => l.numero), [1, 3, 5, 7]);
      expect(lidas.first.campos, ['a', 'b']);
      expect(lidas[2].campos, ['x\ny', '3']);
    });
  });

  test('normalizarCabecalho tira acentos, maiúsculas e espaços', () {
    expect(normalizarCabecalho(' Número '), 'numero');
    expect(normalizarCabecalho('Nome do Vice'), 'nome_do_vice');
    expect(normalizarCabecalho('AÇÃO'), 'acao');
  });

  test('TabelaCsv acessa campos pelo nome da coluna', () {
    final t = TabelaCsv.ler('Número;Nome\n12; Ana \n13');
    expect(t.colunas, ['numero', 'nome']);
    expect(t.valor(t.linhas[0], 'nome'), 'Ana');
    expect(t.valor(t.linhas[1], 'nome'), '', reason: 'campo faltando');
    expect(t.valor(t.linhas[0], 'inexistente'), '');
  });

  group('ArquivoCsv', () {
    test('codifica em UTF-8 com BOM e decodifica de volta', () {
      final bytes = ArquivoCsv.codificar('nome\nJoão');
      expect(bytes.take(3), [0xEF, 0xBB, 0xBF]);
      expect(ArquivoCsv.decodificar(bytes), 'nome\nJoão');
    });

    test('aceita arquivo salvo pelo Excel em Latin-1', () {
      expect(ArquivoCsv.decodificar(latin1.encode('nome\nJoão')), 'nome\nJoão');
    });
  });
}
