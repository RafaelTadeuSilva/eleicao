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

    test('ida e volta preserva os campos (id vem da chave do documento)', () {
      final c = Candidato(
        id: 'doc1',
        numero: 12,
        nome: 'Ana',
        nomeVice: 'Bia',
        urlImage: 'https://x/a.png',
        urlImageVice: 'https://x/b.png',
        cargo: Cargo.prefeito,
        zone: 1,
      );
      final map = mapper.toMap(c);
      expect(map.containsKey('id'), isFalse);
      expect(map.containsKey('matricula'), isFalse);
      expect(map.containsKey('partido'), isFalse);

      final copia = mapper.fromMap({...map, 'id': 'doc1'});
      expect(copia.id, 'doc1');
      expect(copia.numero, 12);
      expect(copia.nome, 'Ana');
      expect(copia.nomeVice, 'Bia');
      expect(copia.urlImage, 'https://x/a.png');
      expect(copia.urlImageVice, 'https://x/b.png');
      expect(copia.cargo, Cargo.prefeito);
      expect(copia.zone, 1);
    });

    test('mapa incompleto usa valores padrão', () {
      final c = mapper.fromMap({});
      expect(c.id, '');
      expect(c.numero, 0);
      expect(c.nome, '');
      expect(c.urlImage, '');
      expect(c.cargo, Cargo.presidente);
      expect(c.zone, 0);
    });

    test('documentos antigos com matrícula e partido continuam legíveis', () {
      final c = mapper.fromMap({
        'id': '4_1234',
        'matricula': '1234',
        'partido': '',
        'numero': 1234,
        'nome': 'Velho',
        'cargo': 4,
      });
      expect(c.id, '4_1234');
      expect(c.numero, 1234);
      expect(c.cargo, Cargo.vereador);
    });
  });

  test('Candidato novo tem id vazio (gerado pelo banco ao salvar)', () {
    final c = Candidato(
        numero: 1, nome: 'X', urlImage: '', cargo: Cargo.prefeito, zone: 0);
    expect(c.id, '');
  });

  group('VotoMapperImpl', () {
    final mapper = VotoMapperImpl();

    test('toMap grava código e descrição do cargo, sem id', () {
      final map = mapper.toMap(Voto(
          id: 'x',
          cargo: Cargo.prefeito,
          candidatoId: 'c1',
          numero: 12,
          nome: 'A',
          zone: 1));
      expect(map, {
        'cargo': 2,
        'cargoDescricao': 'Prefeito',
        'candidatoId': 'c1',
        'numero': 12,
        'nome': 'A',
        'zone': 1,
      });
    });

    test('ida e volta preserva os campos', () {
      final v = mapper.fromMap({
        ...mapper.toMap(Voto(
            cargo: Cargo.vereador,
            candidatoId: 'c9',
            numero: 1234,
            nome: 'B',
            zone: 2)),
        'id': 'v1',
      });
      expect(v.id, 'v1');
      expect(v.cargo, Cargo.vereador);
      expect(v.candidatoId, 'c9');
      expect(v.numero, 1234);
      expect(v.nome, 'B');
      expect(v.zone, 2);
    });

    test('lê votos antigos (cargo como descrição, sem candidatoId)', () {
      final v = mapper.fromMap({
        'id': 'v1',
        'cargo': 'Prefeito',
        'matricula': '1',
        'nome': 'A',
        'zone': 0
      });
      expect(v.cargo, Cargo.prefeito);
      expect(v.candidatoId, '');
      expect(v.numero, 0);
      expect(v.nome, 'A');
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
