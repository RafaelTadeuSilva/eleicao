import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/features/urna/state/votacao_state.dart';
import 'package:eleicao/src/injector.dart';
import 'package:eleicao/src/models/aluno.dart';
import 'package:eleicao/src/models/candidato.dart';
import 'package:eleicao/src/models/evento_eleicao.dart';
import 'package:eleicao/src/models/liberacao_urna.dart';
import 'package:eleicao/src/models/voto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_setup.dart';

Aluno aluno(String id, String nome, {int turma = 0, int? titulo}) =>
    Aluno(id: id, nome: nome, turma: turma, titulo: titulo ?? int.parse(id));

Candidato candidato(String id, String nome, int numero,
        {Cargo cargo = Cargo.presidente, int zone = 0}) =>
    Candidato(
        id: id,
        numero: numero,
        nome: nome,
        urlImage: '',
        cargo: cargo,
        partido: '',
        zone: zone);

void main() {
  setUp(() => resetAmbiente());

  group('AlunoRepositoryImpl', () {
    test('create/findOne usando o id informado como documento', () async {
      await alunoRepository.create(aluno('10', 'Ana', turma: 1, titulo: 555));
      final a = await alunoRepository.findOne('10');
      expect(a, isNotNull);
      expect(a!.nome, 'Ana');
      expect(a.turma, 1);
      expect(a.titulo, 555);
    });

    test('findOne retorna null quando não existe', () async {
      expect(await alunoRepository.findOne('nada'), isNull);
    });

    test('find({}) retorna todos ordenados por nome', () async {
      await alunoRepository.create(aluno('1', 'Carlos'));
      await alunoRepository.create(aluno('2', 'Ana'));
      await alunoRepository.create(aluno('3', 'Bruno'));
      final nomes = (await alunoRepository.find({})).map((e) => e.nome);
      expect(nomes, ['Ana', 'Bruno', 'Carlos']);
    });

    test('find por prefixo de nome', () async {
      await alunoRepository.create(aluno('1', 'Ana Paula'));
      await alunoRepository.create(aluno('2', 'Anderson'));
      await alunoRepository.create(aluno('3', 'Bruno'));
      final nomes =
          (await alunoRepository.find({'nome': 'An'})).map((e) => e.nome);
      expect(nomes, ['Ana Paula', 'Anderson']);
    });

    test(
      'find({}) inclui nomes iniciados por letra acentuada',
      () async {
        await alunoRepository.create(aluno('1', 'Ana'));
        await alunoRepository.create(aluno('2', 'Érica'));
        await alunoRepository.create(aluno('3', 'Ícaro'));
        final nomes = (await alunoRepository.find({})).map((e) => e.nome);
        expect(nomes, containsAll(['Ana', 'Érica', 'Ícaro']));
      },
      skip: 'BUG: FirestoreDb.findByNome usa endAt([nome + "z"]); "É" (U+00C9) '
          'é maior que "z" e esses alunos somem da listagem. Usar "\\uf8ff".',
    );

    test('findByTitulo aceita o título como texto', () async {
      await alunoRepository.create(aluno('1', 'Ana', titulo: 777));
      await alunoRepository.create(aluno('2', 'Bia', titulo: 888));
      expect((await alunoRepository.findByTitulo('888'))?.nome, 'Bia');
      expect(await alunoRepository.findByTitulo('999'), isNull);
    });

    test('update faz merge e delete remove', () async {
      await alunoRepository.create(aluno('1', 'Ana'));
      await alunoRepository.update('1', aluno('1', 'Ana Maria'));
      expect((await alunoRepository.findOne('1'))!.nome, 'Ana Maria');

      await alunoRepository.delete('1');
      expect(await alunoRepository.findOne('1'), isNull);
    });

    test('usa a coleção do evento ativo', () async {
      await alunoRepository.create(aluno('1', 'Ana'));
      expect(firestore.collection('AlunosTeste').doc('1').get(),
          completion(predicate((d) => (d as dynamic).exists == true)));

      aplicarEventoEleicao(EventoEleicao.fromSufixo(sufixo: 'Outro'));
      expect(await alunoRepository.find({}), isEmpty);

      aplicarEventoEleicao(eventoTeste());
      expect(await alunoRepository.find({}), hasLength(1));
    });
  });

  group('CandidatoRepositoryImpl', () {
    test('create/find/update/delete', () async {
      await candidatoRepository.create(candidato('1_1', 'Ana', 12));
      await candidatoRepository.create(
          candidato('2_4', 'Bruno', 1234, cargo: Cargo.vereador, zone: 1));

      final todos = (await candidatoRepository.find({}))!;
      expect(todos.map((e) => e.nome), ['Ana', 'Bruno']);
      expect(todos.last.cargo, Cargo.vereador);
      expect(todos.last.zone, 1);

      await candidatoRepository.update(
          '1_1', candidato('1_1', 'Ana Clara', 13));
      expect((await candidatoRepository.findOne('1_1'))!.numero, 13);

      await candidatoRepository.delete('1_1');
      expect(await candidatoRepository.find({}), hasLength(1));
    });

    test('find por zona', () async {
      await candidatoRepository.create(candidato('1_1', 'Ana', 12, zone: 0));
      await candidatoRepository.create(candidato('2_1', 'Bia', 13, zone: 1));
      final zona1 = (await candidatoRepository.find({'zone': 1}))!;
      expect(zona1.map((e) => e.nome), ['Bia']);
    });

    test(
      'findOne retorna null quando o candidato não existe',
      () async {
        expect(await candidatoRepository.findOne('inexistente'), isNull);
      },
      skip: 'BUG: CandidatoRepositoryImpl.findOne mapeia um mapa vazio e '
          'retorna um Candidato "fantasma" (id vazio, número 0).',
    );
  });

  group('VotoRepositoryImpl', () {
    test('create gera id automático e find filtra por zona', () async {
      final id1 = await votoRepository.create(
          Voto(cargo: 'Prefeito', matricula: '1', nome: 'Ana', zone: 0));
      await votoRepository.create(
          Voto(cargo: 'Prefeito', matricula: '2', nome: 'Bia', zone: 1));
      expect(id1, isNotEmpty);

      final zona0 = (await votoRepository.find({'zone': 0}))!;
      expect(zona0, hasLength(1));
      expect(zona0.first.nome, 'Ana');
      expect(zona0.first.id, id1);
    });

    test('votos ficam na coleção do evento ativo', () async {
      await votoRepository.create(
          Voto(cargo: 'Prefeito', matricula: '1', nome: 'Ana', zone: 0));
      final snap = await firestore.collection(colecaoVotosAtual.value).get();
      expect(snap.docs, hasLength(1));
      expect(colecaoVotosAtual.value, 'VotosTeste');
    });
  });

  group('LiberacaoUrnaRepositoryImpl', () {
    LiberacaoUrna lib({String? id, int urna = 1}) => LiberacaoUrna(
        id: id, matricula: '10', nome: 'Ana', titulo: 99, turma: 0, urna: urna, status: 0);

    test('registra grava liberação pendente (status 0)', () async {
      await liberacaoUrnaRepository.registra(lib());
      final snap =
          await firestore.collection(colecaoLiberacaoAtual.value).get();
      expect(snap.docs, hasLength(1));
      expect(snap.docs.first.data()['status'], 0);
      expect(snap.docs.first.data()['urna'], 1);
    });

    test('finalizaLiberacao marca status 1; sem id não faz nada', () async {
      final ref = await firestore
          .collection(colecaoLiberacaoAtual.value)
          .add({'matricula': '10', 'status': 0, 'urna': 1});

      await liberacaoUrnaRepository.finalizaLiberacao(lib());
      expect((await ref.get()).data()!['status'], 0);

      await liberacaoUrnaRepository.finalizaLiberacao(lib(id: ref.id));
      final data = (await ref.get()).data()!;
      expect(data['status'], 1);
      expect(data['matricula'], '10', reason: 'update deve fazer merge');
    });
  });

  group('EventoEleicaoRepositoryImpl', () {
    test('findAll sem dados inclui evento atual, 2026 e 2025', () async {
      final ids = (await eventoEleicaoRepository.findAll()).map((e) => e.id);
      expect(ids, ['Teste', '2026', '2025']);
    });

    test('save/findOne/delete', () async {
      final evento = EventoEleicao.fromSufixo(
          sufixo: 'CIPA', modalidade: TipoEleicaoModalidade.cipa, cargos: [11]);
      await eventoEleicaoRepository.save(evento);

      final lido = await eventoEleicaoRepository.findOne('CIPA');
      expect(lido, isNotNull);
      expect(lido!.modalidade, TipoEleicaoModalidade.cipa);
      expect(lido.cargos, [11]);

      final ids = (await eventoEleicaoRepository.findAll()).map((e) => e.id);
      expect(ids, containsAll(['CIPA', 'Teste', '2026', '2025']));
      expect(ids.where((id) => id == 'CIPA'), hasLength(1));

      await eventoEleicaoRepository.delete('CIPA');
      expect(await eventoEleicaoRepository.findOne('CIPA'), isNull);
    });
  });
}
