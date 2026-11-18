import 'package:eleicao/src/features/cadastro/state/cadastro_state.dart';
import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/features/urna/state/votacao_state.dart';
import 'package:eleicao/src/models/aluno.dart';
import 'package:eleicao/src/models/evento_eleicao.dart';
import 'package:eleicao/src/models/zona.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    aplicarEventoEleicao(EventoEleicao.fromSufixo(sufixo: '2026'));
  });

  group('aplicarEventoEleicao', () {
    test('troca coleções ativas, modalidade e cargos', () {
      aplicarEventoEleicao(EventoEleicao.fromSufixo(
        sufixo: 'CIPA25',
        modalidade: TipoEleicaoModalidade.cipa,
        cargos: [11, 12],
      ));
      expect(eventoAtualId.value, 'CIPA25');
      expect(colecaoAlunosAtual.value, 'AlunosCIPA25');
      expect(colecaoCandidatosAtual.value, 'CandidatosCIPA25');
      expect(colecaoVotosAtual.value, 'VotosCIPA25');
      expect(colecaoLiberacaoAtual.value, 'LiberacaoUrnaCIPA25');
      expect(modalidadeEleicao.value, TipoEleicaoModalidade.cipa);
      expect(tipoEleicao, [11, 12]);
      expect(numSeqEleicao.value, 11);
      expect(zonasEleitorais.value, [Zona.geral]);
    });

    test('aplica as zonas do evento', () {
      aplicarEventoEleicao(EventoEleicao.fromSufixo(
          sufixo: 'z', zonas: const [Zona(1, 'Turma A')]));
      expect(zonasEleitorais.value, const [Zona.geral, Zona(1, 'Turma A')]);
      expect(eventoEleicaoAtual().zonas, zonasEleitorais.value);
    });

    test('limpa caches em memória do evento anterior', () {
      listAlunos.value = [Aluno(id: '1', nome: 'A', turma: 0, titulo: 1)];

      aplicarEventoEleicao(EventoEleicao.fromSufixo(sufixo: 'outro'));

      expect(listCandidato, isEmpty);
      expect(listAlunos.value, isEmpty);
      expect(listCandidatos.value, isEmpty);
    });
  });

  group('aplicarConfigEleicao', () {
    test('lista de cargos vazia usa o primeiro cargo da modalidade', () {
      aplicarConfigEleicao(
          modalidade: TipoEleicaoModalidade.esportes, codigosCargos: []);
      expect(tipoEleicao, [Cargo.futsalMasc.codigo]);
      expect(numSeqEleicao.value, Cargo.futsalMasc.codigo);
    });

    test('limita a 10 etapas de votação', () {
      final codigos = Cargo.byModalidade(TipoEleicaoModalidade.esportes)
          .map((c) => c.codigo);
      aplicarConfigEleicao(
        modalidade: TipoEleicaoModalidade.esportes,
        codigosCargos: [...codigos, ...codigos],
      );
      expect(tipoEleicao, hasLength(10));
    });

    test('mapaDigitos nulo preserva os dígitos atuais', () {
      aplicarConfigEleicao(
          modalidade: TipoEleicaoModalidade.politica,
          codigosCargos: [1],
          mapaDigitos: {1: 3});
      aplicarConfigEleicao(
          modalidade: TipoEleicaoModalidade.politica, codigosCargos: [1]);
      expect(digitosDoCargo(1), 3);
    });
  });

  test('digitosDoCargo usa configuração do evento ou o padrão do cargo', () {
    aplicarConfigEleicao(
        modalidade: TipoEleicaoModalidade.politica,
        codigosCargos: [1],
        mapaDigitos: {1: 5});
    expect(digitosDoCargo(1), 5);
    expect(digitosDoCargo(Cargo.cipaPresidente.codigo),
        Cargo.cipaPresidente.digitosPadrao);
  });

  test('eventoEleicaoAtual reflete o estado e retorna cópias das listas', () {
    final evento = eventoEleicaoAtual();
    expect(evento.id, '2026');
    expect(evento.cargos, tipoEleicao);

    evento.cargos.add(999);
    evento.digitosPorCargo[999] = 1;
    expect(tipoEleicao, isNot(contains(999)));
    expect(digitosPorCargo.containsKey(999), isFalse);
  });
}
