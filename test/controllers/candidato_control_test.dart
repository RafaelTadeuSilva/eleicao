import 'package:eleicao/src/features/cadastro/controllers/candidato_control.dart';
import 'package:eleicao/src/features/cadastro/state/cadastro_state.dart';
import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/models/candidato.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_setup.dart';

Candidato candidato(String id, String nome, int numero,
        {Cargo cargo = Cargo.prefeito, int zone = 0}) =>
    Candidato(
        id: id,
        numero: numero,
        nome: nome,
        urlImage: '',
        cargo: cargo,
        partido: '',
        zone: zone);

void main() {
  late CandidatoControl control;

  setUp(() async {
    await resetAmbiente();
    control = CandidatoControl();
  });

  test('create e listaCandidatos atualizam o estado', () async {
    expect(await control.create(candidato('1_2', 'Ana', 10)), isTrue);
    await control.listaCandidatos();
    expect(listCandidatos.value.map((e) => e.nome), ['Ana']);
  });

  test('update altera o candidato pelo id', () async {
    await control.create(candidato('1_2', 'Ana', 10));
    await control.update(candidato('1_2', 'Ana Paula', 11));
    final c = await control.getById('1_2');
    expect(c!.nome, 'Ana Paula');
    expect(c.numero, 11);
  });

  test('delete remove e recarrega a lista', () async {
    await control.create(candidato('1_2', 'Ana', 10));
    await control.create(candidato('2_2', 'Bia', 11));
    await control.listaCandidatos();

    expect(await control.delete('1_2'), isTrue);
    expect(listCandidatos.value.map((e) => e.nome), ['Bia']);
  });

  group('verificarNumeroDuplicado', () {
    setUp(() async {
      await control.create(candidato('1_2', 'Ana', 10, zone: 1));
      await control
          .create(candidato('2_4', 'Bia', 10, cargo: Cargo.vereador, zone: 1));
    });

    test('encontra mesmo número, cargo e zona', () async {
      final dup = await control.verificarNumeroDuplicado(
          numero: 10, cargo: Cargo.prefeito, zone: 1);
      expect(dup?.nome, 'Ana');
    });

    test('mesmo número em outro cargo não é duplicado', () async {
      final dup = await control.verificarNumeroDuplicado(
          numero: 10, cargo: Cargo.governador, zone: 1);
      expect(dup, isNull);
    });

    test('mesmo número em outra zona não é duplicado', () async {
      await control.create(candidato('3_2', 'Caio', 20, zone: 1));
      final dup = await control.verificarNumeroDuplicado(
          numero: 20, cargo: Cargo.prefeito, zone: 2);
      expect(dup, isNull);
    });

    test('zona 0 conflita com qualquer zona', () async {
      final dup = await control.verificarNumeroDuplicado(
          numero: 10, cargo: Cargo.prefeito, zone: 0);
      expect(dup?.nome, 'Ana');
    });

    test('ignora o próprio candidato na edição', () async {
      final dup = await control.verificarNumeroDuplicado(
          numero: 10, cargo: Cargo.prefeito, zone: 1, ignorarId: '1_2');
      expect(dup, isNull);
    });
  });

  test(
    'getByNumero retorna o candidato com o número informado',
    () async {
      await control.create(candidato('1_2', 'Ana', 10));
      await control.create(candidato('2_2', 'Bia', 20));
      expect((await control.getByNumero(20))?.nome, 'Bia');
    },
  );
}
