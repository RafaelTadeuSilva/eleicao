import 'package:eleicao/src/features/cadastro/mapper/aluno_mapper_impl.dart';
import 'package:eleicao/src/features/cadastro/mapper/candidato_mapper_impl.dart';
import 'package:eleicao/src/features/cadastro/mapper/liberacao_urna_mapper_impl.dart';
import 'package:eleicao/src/features/cadastro/mapper/voto_mapper_impl.dart';
import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/models/aluno.dart';
import 'package:eleicao/src/models/candidato.dart';
import 'package:eleicao/src/models/liberacao_urna.dart';
import 'package:eleicao/src/models/voto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AlunoMapperImpl', () {
    final mapper = AlunoMapperImpl();

    test('ida e volta preserva os campos', () {
      final aluno = Aluno(id: '123', nome: 'Ana', turma: 1, titulo: 456);
      final copia = mapper.fromMap(mapper.toMap(aluno));
      expect(copia.id, '123');
      expect(copia.nome, 'Ana');
      expect(copia.turma, 1);
      expect(copia.titulo, 456);
    });

    test('converte id numérico (SQLite) para String', () {
      final aluno =
          mapper.fromMap({'id': 7, 'nome': 'B', 'turma': 0, 'titulo': 1});
      expect(aluno.id, '7');
    });
  });

  group('CandidatoMapperImpl', () {
    final mapper = CandidatoMapperImpl();

    test('ida e volta preserva os campos', () {
      final c = Candidato(
        id: '555_1',
        numero: 12,
        nome: 'Ana',
        nomeVice: 'Bia',
        urlImage: 'https://x/a.png',
        urlImageVice: 'https://x/b.png',
        cargo: Cargo.prefeito,
        partido: 'P',
        zone: 1,
      );
      final copia = mapper.fromMap(mapper.toMap(c));
      expect(copia.id, '555_1');
      expect(copia.matricula, '555');
      expect(copia.numero, 12);
      expect(copia.nome, 'Ana');
      expect(copia.nomeVice, 'Bia');
      expect(copia.urlImage, 'https://x/a.png');
      expect(copia.urlImageVice, 'https://x/b.png');
      expect(copia.cargo, Cargo.prefeito);
      expect(copia.zone, 1);
    });

    test('mapa incompleto usa valores padrão', () {
      final c = mapper.fromMap({'id': '42_4'});
      expect(c.matricula, '42');
      expect(c.numero, 0);
      expect(c.nome, '');
      expect(c.urlImage, '');
      expect(c.cargo, Cargo.presidente);
      expect(c.zone, 0);
    });

    test('matrícula explícita tem prioridade sobre o id', () {
      final c = mapper.fromMap({'id': 'abc', 'matricula': '999'});
      expect(c.matricula, '999');
    });
  });

  test('Candidato deriva a matrícula do id quando não informada', () {
    final c = Candidato(
      id: '321_2',
      numero: 1,
      nome: 'X',
      urlImage: '',
      cargo: Cargo.prefeito,
      partido: '',
      zone: 0,
    );
    expect(c.matricula, '321');
  });

  group('VotoMapperImpl', () {
    final mapper = VotoMapperImpl();

    test('toMap não inclui id (gerado pelo banco)', () {
      final map = mapper.toMap(
          Voto(id: 'x', cargo: 'Prefeito', matricula: '1', nome: 'A', zone: 1));
      expect(
          map, {'cargo': 'Prefeito', 'matricula': '1', 'nome': 'A', 'zone': 1});
    });

    test('fromMap lê todos os campos', () {
      final v = mapper.fromMap({
        'id': 'v1',
        'cargo': 'Prefeito',
        'matricula': '1',
        'nome': 'A',
        'zone': 0
      });
      expect(v.id, 'v1');
      expect(v.cargo, 'Prefeito');
      expect(v.zone, 0);
    });
  });

  group('LiberacaoUrnaMapperImpl', () {
    final mapper = LiberacaoUrnaMapperImpl();

    test('ida e volta preserva os campos e toMap não inclui id', () {
      final lib = LiberacaoUrna(
          id: 'l1',
          matricula: '10',
          nome: 'Ana',
          titulo: 99,
          turma: 1,
          urna: 3,
          status: 0);
      final map = mapper.toMap(lib);
      expect(map.containsKey('id'), isFalse);
      final copia = mapper.fromMap({...map, 'id': 'l1'});
      expect(copia.id, 'l1');
      expect(copia.matricula, '10');
      expect(copia.titulo, 99);
      expect(copia.urna, 3);
      expect(copia.status, 0);
    });
  });
}
