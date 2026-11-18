import 'package:eleicao/src/features/cadastro/state/cadastro_state.dart';
import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/features/urna/state/votacao_state.dart';
import 'package:eleicao/src/injector.dart';
import 'package:eleicao/src/models/evento_eleicao.dart';
import 'package:eleicao/src/models/zona.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_setup.dart';

void main() {
  setUp(() => resetAmbiente());

  test('evento ativo é salvo no aparelho e restaurado na próxima abertura',
      () async {
    final evento = EventoEleicao.fromSufixo(
      sufixo: 'Esportes',
      nome: 'Esportes 2026',
      modalidade: TipoEleicaoModalidade.esportes,
      cargos: [Cargo.futsalMasc.codigo, Cargo.voleiFem.codigo],
      digitosPorCargo: {Cargo.futsalMasc.codigo: 3},
      zonas: const [Zona(1, 'Turma: A'), Zona(2, 'Turma B')],
    );
    await salvarEventoEleicaoLocal(evento);

    // Simula outro estado em memória e uma nova abertura do app.
    aplicarEventoEleicao(eventoTeste());
    expect(zonasEleitorais.value, [Zona.geral]);
    await setTipoEleicao();

    expect(eventoAtualId.value, 'Esportes');
    expect(eventoAtualNome.value, 'Esportes 2026');
    expect(modalidadeEleicao.value, TipoEleicaoModalidade.esportes);
    expect(tipoEleicao, [Cargo.futsalMasc.codigo, Cargo.voleiFem.codigo]);
    expect(digitosDoCargo(Cargo.futsalMasc.codigo), 3);
    expect(colecaoVotosAtual.value, 'VotosEsportes');
    expect(zonasEleitorais.value,
        const [Zona.geral, Zona(1, 'Turma: A'), Zona(2, 'Turma B')]);
  });

  test('sem configuração salva usa o evento legado com zona Geral', () async {
    await prefs.clear();
    await setTipoEleicao();
    expect(eventoAtualId.value, '2026');
    expect(zonasEleitorais.value, [Zona.geral]);
    expect(prefs.getStringList('zonas'), ['0:Geral']);
  });
}
