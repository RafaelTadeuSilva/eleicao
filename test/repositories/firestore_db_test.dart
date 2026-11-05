import 'package:eleicao/src/repositories/remote/firestore_db.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FirestoreDb db;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    db = FirestoreDb(db: firestore);
    for (final p in [
      {'nome': 'Ana', 'zone': 0, 'cargo': 1, 'numero': 10},
      {'nome': 'Érica', 'zone': 1, 'cargo': 1, 'numero': 20},
      {'nome': 'Bruno', 'zone': 1, 'cargo': 4, 'numero': 10},
      {'nome': 'Ícaro', 'zone': 0, 'cargo': 4, 'numero': 30},
    ]) {
      await firestore.collection('T').add(p);
    }
  });

  List<String> nomes(List<Map<String, dynamic>> l) =>
      l.map((e) => e['nome'] as String).toList();

  test('sem filtros retorna todos ordenados por nome, inclusive acentuados',
      () async {
    expect(nomes(await db.find('T', {})), ['Ana', 'Bruno', 'Érica', 'Ícaro']);
  });

  test('filtro de nome usa prefixo', () async {
    expect(nomes(await db.find('T', {'nome': 'É'})), ['Érica']);
  });

  test('aplica qualquer filtro de igualdade e combina vários', () async {
    expect(nomes(await db.find('T', {'numero': 10})).toSet(), {'Ana', 'Bruno'});
    expect(nomes(await db.find('T', {'numero': 10, 'zone': 1})), ['Bruno']);
    expect(nomes(await db.find('T', {'cargo': 4, 'zone': 0})), ['Ícaro']);
  });

  test('valores nulos ou vazios são ignorados', () async {
    expect(await db.find('T', {'zone': null, 'titulo': ''}), hasLength(4));
  });

  test('inclui o id do documento em cada resultado', () async {
    final lista = await db.find('T', {'numero': 30});
    final doc = await firestore.collection('T').doc(lista.first['id']).get();
    expect(doc.data()!['nome'], 'Ícaro');
  });

  test('create com id usa o id informado; sem id gera automaticamente',
      () async {
    expect(await db.create('X', {'id': 'abc', 'nome': 'A'}), 'abc');
    final gerado = await db.create('X', {'nome': 'B'});
    expect(gerado, isNot('abc'));
    expect((await db.findOne('X', gerado))['nome'], 'B');
  });

  test('createAll grava todos os documentos de uma vez', () async {
    await db.createAll('V', [
      {'nome': 'A', 'zone': 0},
      {'nome': 'B', 'zone': 1},
      {'id': 'fixo', 'nome': 'C', 'zone': 1},
    ]);
    final snap = await firestore.collection('V').get();
    expect(snap.docs.map((d) => d.data()['nome']).toSet(), {'A', 'B', 'C'});
    expect((await firestore.collection('V').doc('fixo').get()).exists, isTrue);
    expect(snap.docs.every((d) => !d.data().containsKey('id')), isTrue);
  });

  test('create com id vazio também gera id automático', () async {
    final id = await db.create('X', {'id': '', 'nome': 'A'});
    expect(id, isNotEmpty);
    final doc = await firestore.collection('X').doc(id).get();
    expect(doc.data()!.containsKey('id'), isFalse);
  });
}
