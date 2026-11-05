import 'package:eleicao/src/features/cadastro/state/cadastro_state.dart';
import 'package:eleicao/src/models/zona.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Zona.normalizar', () {
    test('lista vazia vira apenas a zona Geral', () {
      expect(Zona.normalizar([]), [Zona.geral]);
    });

    test('garante Geral primeiro, ordena, remove repetidos e nomes vazios', () {
      final zonas = Zona.normalizar(const [
        Zona(2, ' 2º Ano '),
        Zona(1, '1º Ano'),
        Zona(2, 'duplicada'),
        Zona(3, '   '),
        Zona(0, 'Outro nome para Geral'),
        Zona(-1, 'negativa'),
      ]);
      expect(zonas, const [Zona.geral, Zona(1, '1º Ano'), Zona(2, '2º Ano')]);
    });
  });

  test('proximoCodigo usa o maior código + 1', () {
    expect(Zona.proximoCodigo([Zona.geral]), 1);
    expect(
        Zona.proximoCodigo(const [Zona.geral, Zona(5, 'x'), Zona(2, 'y')]), 6);
  });

  test('toMap/fromMap', () {
    const z = Zona(3, 'Turma C');
    expect(Zona.fromMap(z.toMap()), z);
    expect(Zona.fromMap({'codigo': '4', 'nome': 'X'}), const Zona(4, 'X'));
    expect(Zona.fromMap({'nome': 'sem código'}), isNull);
    expect(Zona.fromMap('inválido'), isNull);
  });

  group('helpers de zona do evento ativo', () {
    setUp(() {
      zonasEleitorais.value = const [
        Zona.geral,
        Zona(1, '1º Ano A'),
        Zona(2, '1º Ano B'),
      ];
    });

    test('zonaPorCodigo encontra a zona ou devolve um nome genérico', () {
      expect(zonaPorCodigo(2).nome, '1º Ano B');
      expect(zonaPorCodigo(null), Zona.geral);
      expect(zonaPorCodigo(9).nome, 'Zona 9');
    });

    test('zonaPorNome exige o nome exato', () {
      expect(zonaPorNome('1º Ano A')?.codigo, 1);
      expect(zonaPorNome('1º Ano'), isNull);
    });

    test('buscaZonaPorNome procura por trecho, sem diferenciar maiúsculas', () {
      expect(buscaZonaPorNome('ano b')?.codigo, 2);
      expect(buscaZonaPorNome('xyz'), isNull);
    });
  });
}
