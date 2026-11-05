import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TipoEleicaoModalidade', () {
    test('getByCodigo retorna a modalidade correspondente', () {
      expect(
          TipoEleicaoModalidade.getByCodigo(1), TipoEleicaoModalidade.politica);
      expect(TipoEleicaoModalidade.getByCodigo(2), TipoEleicaoModalidade.cipa);
      expect(
          TipoEleicaoModalidade.getByCodigo(3), TipoEleicaoModalidade.esportes);
    });

    test('getByCodigo usa política como fallback para código inválido ou nulo',
        () {
      expect(TipoEleicaoModalidade.getByCodigo(99),
          TipoEleicaoModalidade.politica);
      expect(TipoEleicaoModalidade.getByCodigo(null),
          TipoEleicaoModalidade.politica);
    });
  });

  group('Cargo', () {
    test('códigos são únicos', () {
      final codigos = Cargo.values.map((e) => e.codigo).toList();
      expect(codigos.toSet().length, codigos.length);
    });

    test('getCargoByCodigo encontra cargo e usa vereador como fallback', () {
      expect(Cargo.getCargoByCodigo(2), Cargo.prefeito);
      expect(Cargo.getCargoByCodigo(20), Cargo.futsal);
      expect(Cargo.getCargoByCodigo(-1), Cargo.vereador);
    });

    test('getCargoByDescricao encontra cargo e usa vereador como fallback', () {
      expect(Cargo.getCargoByDescricao('Prefeito'), Cargo.prefeito);
      expect(Cargo.getCargoByDescricao('inexistente'), Cargo.vereador);
    });

    test('byModalidade separa os cargos por modalidade', () {
      expect(Cargo.byModalidade(TipoEleicaoModalidade.politica), hasLength(7));
      expect(Cargo.byModalidade(TipoEleicaoModalidade.cipa), hasLength(5));
      expect(Cargo.byModalidade(TipoEleicaoModalidade.esportes), hasLength(10));
      for (final m in TipoEleicaoModalidade.values) {
        expect(Cargo.byModalidade(m).every((c) => c.modalidade == m), isTrue);
      }
    });

    test('apenas prefeito e governador possuem vice', () {
      final comVice = Cargo.values.where((c) => c.temVice).toSet();
      expect(comVice, {Cargo.prefeito, Cargo.governador});
    });

    test('dígitos padrão ficam entre 1 e 6', () {
      for (final c in Cargo.values) {
        expect(c.digitosPadrao, inInclusiveRange(1, 6), reason: c.name);
      }
      expect(Cargo.presidente.digitosPadrao, 2);
      expect(Cargo.vereador.digitosPadrao, 4);
      expect(Cargo.deputadoEstadual.digitosPadrao, 5);
    });
  });
}
