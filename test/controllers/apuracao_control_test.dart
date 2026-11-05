import 'package:eleicao/src/features/urna/controllers/apuracao_control.dart';
import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/features/urna/state/votacao_state.dart';
import 'package:eleicao/src/injector.dart';
import 'package:eleicao/src/models/voto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_setup.dart';

Future<void> vota(String nome, Cargo cargo,
    {String? candidatoId, int numero = 0, int zone = 0, int vezes = 1}) async {
  await votoRepository.createAll([
    for (var i = 0; i < vezes; i++)
      Voto(
          cargo: cargo,
          candidatoId: candidatoId ?? 'id-$nome',
          numero: numero,
          nome: nome,
          zone: zone),
  ]);
}

List<(String, int)> resumo(ApuracaoControl c) =>
    c.resultados.value.map((r) => (r.nome, r.votos)).toList();

void main() {
  late ApuracaoControl control;

  setUp(() async {
    await resetAmbiente(); // evento de teste: presidente, vereador
    control = ApuracaoControl();
  });

  test('conta votos por candidato, ordenando cargos e mais votados', () async {
    await vota('Carla', Cargo.vereador, vezes: 1);
    await vota('Ana', Cargo.presidente, vezes: 3);
    await vota('Bruno', Cargo.presidente, vezes: 5);

    await control.carregaApuracao();

    expect(control.resultados.value.map((r) => (r.cargo, r.nome, r.votos)), [
      (Cargo.presidente, 'Bruno', 5),
      (Cargo.presidente, 'Ana', 3),
      (Cargo.vereador, 'Carla', 1),
    ]);
    expect(control.totalVotos.value, 9);
  });

  test('marca o vencedor de cada cargo e calcula o percentual', () async {
    await vota('Ana', Cargo.presidente, vezes: 1);
    await vota('Bruno', Cargo.presidente, vezes: 3);
    await vota('Carla', Cargo.vereador, vezes: 2);

    await control.carregaApuracao();
    final r = {for (final x in control.resultados.value) x.nome: x};

    expect(r['Bruno']!.vencedor, isTrue);
    expect(r['Bruno']!.empate, isFalse);
    expect(r['Bruno']!.percentual, 75);
    expect(r['Ana']!.vencedor, isFalse);
    expect(r['Ana']!.percentual, 25);
    expect(r['Carla']!.vencedor, isTrue, reason: 'vencedor por cargo');
    expect(r['Carla']!.percentual, 100);
  });

  test('empate no primeiro lugar marca todos os empatados', () async {
    await vota('Bia', Cargo.presidente, vezes: 2);
    await vota('Ana', Cargo.presidente, vezes: 2);
    await vota('Caio', Cargo.presidente, vezes: 1);

    await control.carregaApuracao();

    expect(resumo(control), [('Ana', 2), ('Bia', 2), ('Caio', 1)]);
    final vencedores =
        control.resultados.value.where((r) => r.vencedor).map((r) => r.nome);
    expect(vencedores, ['Ana', 'Bia']);
    expect(control.resultados.value.first.empate, isTrue);
  });

  test('filtro por cargo mostra só aquele cargo e seu total', () async {
    await vota('Ana', Cargo.presidente, vezes: 2);
    await vota('Carla', Cargo.vereador, vezes: 4);

    await control.carregaApuracao(cargo: Cargo.vereador);

    expect(resumo(control), [('Carla', 4)]);
    expect(control.totalVotos.value, 4);
    expect(control.cargo, Cargo.vereador);
  });

  test('filtro por zona (null = todas)', () async {
    await vota('Ana', Cargo.presidente, zone: 0, vezes: 2);
    await vota('Ana', Cargo.presidente, zone: 1, vezes: 1);
    await vota('Bia', Cargo.presidente, zone: 1, vezes: 4);

    await control.carregaApuracao(zona: 1);
    expect(resumo(control), [('Bia', 4), ('Ana', 1)]);

    await control.carregaApuracao(zona: 0);
    expect(resumo(control), [('Ana', 2)]);

    await control.carregaApuracao();
    expect(resumo(control), [('Bia', 4), ('Ana', 3)]);
    expect(control.totalVotos.value, 7);
  });

  test('candidatos homônimos no mesmo cargo são apurados separadamente',
      () async {
    await vota('João Silva', Cargo.vereador,
        candidatoId: 'a', numero: 1111, vezes: 2);
    await vota('João Silva', Cargo.vereador,
        candidatoId: 'b', numero: 2222, vezes: 3);

    await control.carregaApuracao();

    expect(control.resultados.value.map((r) => (r.numero, r.votos)),
        [(2222, 3), (1111, 2)]);
  });

  test(
      'votos antigos (sem candidatoId, cargo como texto) são agrupados pelo nome',
      () async {
    final col = firestore.collection(colecaoVotosAtual.value);
    for (var i = 0; i < 2; i++) {
      await col.add(
          {'cargo': 'Vereador', 'matricula': '1', 'nome': 'Velho', 'zone': 0});
    }
    await vota('Novo', Cargo.vereador);

    await control.carregaApuracao(cargo: Cargo.vereador);

    expect(resumo(control), [('Velho', 2), ('Novo', 1)]);
  });

  test('recarregar não duplica resultados; sem votos zera o total', () async {
    await control.carregaApuracao();
    expect(control.resultados.value, isEmpty);
    expect(control.totalVotos.value, 0);

    await vota('Ana', Cargo.presidente, vezes: 2);
    await control.carregaApuracao();
    await control.carregaApuracao();
    expect(resumo(control), [('Ana', 2)]);
  });

  test('cargosDisponiveis segue os cargos do evento na ordem de votação', () {
    expect(control.cargosDisponiveis, [Cargo.presidente, Cargo.vereador]);
  });
}
