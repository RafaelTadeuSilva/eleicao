import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/models/evento_eleicao.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EventoEleicao.fromSufixo', () {
    test('gera nome e coleções a partir do sufixo', () {
      final e = EventoEleicao.fromSufixo(sufixo: ' 2027 ');
      expect(e.id, '2027');
      expect(e.nome, 'Eleição 2027');
      expect(e.colecaoAlunos, 'Alunos2027');
      expect(e.colecaoCandidatos, 'Candidatos2027');
      expect(e.colecaoVotos, 'Votos2027');
      expect(e.colecaoLiberacao, 'LiberacaoUrna2027');
    });

    test('sufixo vazio usa 2026', () {
      final e = EventoEleicao.fromSufixo(sufixo: '   ');
      expect(e.id, '2026');
      expect(e.colecaoVotos, 'Votos2026');
    });

    test('respeita nomes de coleção informados e ignora valores em branco', () {
      final e = EventoEleicao.fromSufixo(
        sufixo: 'X',
        nome: ' Grêmio ',
        colecaoAlunos: ' MeusAlunos ',
        colecaoVotos: '  ',
      );
      expect(e.nome, 'Grêmio');
      expect(e.colecaoAlunos, 'MeusAlunos');
      expect(e.colecaoVotos, 'VotosX');
    });

    test('sem cargos usa o primeiro cargo da modalidade', () {
      expect(
        EventoEleicao.fromSufixo(
                sufixo: 'a', modalidade: TipoEleicaoModalidade.cipa)
            .cargos,
        [Cargo.cipaRepresentante.codigo],
      );
      expect(
        EventoEleicao.fromSufixo(sufixo: 'a', cargos: []).cargos,
        [Cargo.presidente.codigo],
      );
    });

    test('preenche dígitos padrão da modalidade e limita entre 1 e 6', () {
      final e = EventoEleicao.fromSufixo(
        sufixo: 'a',
        digitosPorCargo: {Cargo.vereador.codigo: 9, Cargo.presidente.codigo: 0},
      );
      expect(e.digitosPorCargo[Cargo.vereador.codigo], 6);
      expect(e.digitosPorCargo[Cargo.presidente.codigo], 1);
      expect(e.digitosPorCargo[Cargo.deputadoEstadual.codigo], 5);
      expect(e.digitosPorCargo.keys,
          containsAll(Cargo.byModalidade(TipoEleicaoModalidade.politica).map((c) => c.codigo)));
    });
  });

  group('EventoEleicao toMap/fromMap', () {
    test('ida e volta preserva todos os campos', () {
      final original = EventoEleicao.fromSufixo(
        sufixo: 'RT',
        nome: 'Round trip',
        modalidade: TipoEleicaoModalidade.esportes,
        cargos: [20, 23],
        digitosPorCargo: {20: 3},
      );
      final copia = EventoEleicao.fromMap(original.toMap());
      expect(copia.id, original.id);
      expect(copia.nome, original.nome);
      expect(copia.colecaoAlunos, original.colecaoAlunos);
      expect(copia.colecaoCandidatos, original.colecaoCandidatos);
      expect(copia.colecaoVotos, original.colecaoVotos);
      expect(copia.colecaoLiberacao, original.colecaoLiberacao);
      expect(copia.modalidade, original.modalidade);
      expect(copia.cargos, original.cargos);
      expect(copia.digitosPorCargo, original.digitosPorCargo);
    });

    test('toMap serializa chaves de dígitos como String (exigência do Firestore)',
        () {
      final map = EventoEleicao.fromSufixo(sufixo: 'a').toMap();
      final digitos = map['digitos_por_cargo'] as Map;
      expect(digitos.keys.every((k) => k is String), isTrue);
    });

    test('fromMap tolera valores como String e itens inválidos', () {
      final e = EventoEleicao.fromMap({
        'id': 99,
        'modalidade': '2',
        'cargos': ['11', 'abc', 12],
        'digitos_por_cargo': {'11': '3', 'x': 2, '12': 10},
      });
      expect(e.id, '99');
      expect(e.modalidade, TipoEleicaoModalidade.cipa);
      expect(e.cargos, [11, 12]);
      expect(e.digitosPorCargo, {11: 3, 12: 6});
    });

    test('fromMap de mapa vazio usa valores padrão', () {
      final e = EventoEleicao.fromMap({});
      expect(e.id, '2026');
      expect(e.nome, 'Eleição 2026');
      expect(e.modalidade, TipoEleicaoModalidade.politica);
      expect(e.cargos, [Cargo.presidente.codigo]);
      expect(e.colecaoAlunos, 'Alunos2026');
    });
  });
}
