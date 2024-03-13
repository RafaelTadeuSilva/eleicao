import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eleicao/src/repositories/api_db.dart';

class FirestoreDb implements ApiDb {
  final table = 'Alunos';
  final db = FirebaseFirestore.instance;

  @override
  Future<String> create(String table, Map<String, dynamic> map) async {
    await db.collection(table).doc(map['id']).set(map);
    return map['id'];
  }

  @override
  Future<bool> delete(String table, String id) async {
    await db.collection(table).doc(id).delete();
    return true;
  }

  @override
  Future<List<Map<String, dynamic>>> find(
      String table, Map<String, dynamic> filter) async {
    final nome = filter['nome'] ?? '';
    final query = await db
        .collection(table)
        .orderBy('nome')
        .startAt([nome]).endAt(['${nome}a']).get();
    final list = <Map<String, dynamic>>[];
    for (var e in query.docs) {
      list.add(e.data());
    }
    return list;
  }

  @override
  Future<Map<String, dynamic>> findOne(String table, String id) {
    // TODO: implement findOne
    throw UnimplementedError();
  }

  @override
  Future<bool> update(String table, String id, Map<String, dynamic> map) {
    // TODO: implement update
    throw UnimplementedError();
  }
}
