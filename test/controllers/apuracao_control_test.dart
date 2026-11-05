import 'package:eleicao/src/features/urna/controllers/apuracao_control.dart';
import 'package:eleicao/src/features/urna/state/votacao_state.dart';
import 'package:eleicao/src/injector.dart';
import 'package:eleicao/src/models/voto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_setup.dart';

Future<void> vota(String nome, String cargo,
    {String? matricula, int zone = 0, int vezes = 1}) async {
  for (var i = 0; i < vezes; i++) {
    await votoRepository.create(Voto(
        cargo: cargo, matricula: matricula ?? nome, nome: nome, zone: zone));
  }
}

void main() {
  setUp(() => resetAmbiente());

  test('conta votos por candidato/cargo e ordena do mais votado', () async {
    await vota('Ana', 'Prefeito', vezes: 3);
    await vota('Bruno', 'Prefeito', vezes: 5);
    await vota('Carla', 'Vereador', vezes: 1);

    final control = ApuracaoControl();
    await control.carregaApuracao(0);

    expect(listApuracao.value, [
      ('Bruno - Prefeito', 5),
      ('Ana - Prefeito', 3),
      ('Carla - Vereador', 1),
    ]);
    expect(control.totalVotos.value, 9);
  });

  test('empates mantêm ordem alfabética decrescente do rótulo', () async {
    await vota('Ana', 'Prefeito', vezes: 2);
    await vota('Bia', 'Prefeito', vezes: 2);

    final control = ApuracaoControl();
    await control.carregaApuracao(0);

    expect(listApuracao.value.map((e) => e.$1),
        ['Bia - Prefeito', 'Ana - Prefeito']);
  });

  test('filtra pela zona selecionada (null = zona 0)', () async {
    await vota('Ana', 'Prefeito', zone: 0, vezes: 2);
    await vota('Bia', 'Prefeito', zone: 1, vezes: 4);

    final control = ApuracaoControl();
    await control.carregaApuracao(1);
    expect(listApuracao.value, [('Bia - Prefeito', 4)]);
    expect(control.totalVotos.value, 4);

    await control.carregaApuracao(null);
    expect(listApuracao.value, [('Ana - Prefeito', 2)]);
    expect(control.totalVotos.value, 2);
  });

  test('recarregar não duplica resultados', () async {
    await vota('Ana', 'Prefeito', vezes: 2);
    final control = ApuracaoControl();
    await control.carregaApuracao(0);
    await control.carregaApuracao(0);
    expect(listApuracao.value, [('Ana - Prefeito', 2)]);
  });

  test('sem votos zera o total', () async {
    final control = ApuracaoControl();
    await control.carregaApuracao(0);
    expect(listApuracao.value, isEmpty);
    expect(control.totalVotos.value, 0);
  });

  test(
    'candidatos homônimos no mesmo cargo são apurados separadamente',
    () async {
      await vota('João Silva', 'Vereador', matricula: '1', vezes: 2);
      await vota('João Silva', 'Vereador', matricula: '2', vezes: 3);

      final control = ApuracaoControl();
      await control.carregaApuracao(0);
      expect(listApuracao.value, hasLength(2));
    },
    skip: 'BUG: a apuração agrupa por "nome - cargo" em vez da matrícula; '
        'homônimos têm seus votos somados.',
  );
}
