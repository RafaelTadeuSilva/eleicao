import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eleicao/src/repositories/api_db.dart';

class FirestoreDb implements ApiDb {
  final db = FirebaseFirestore.instance;

  @override
  Future<String> create(String colName, Map<String, dynamic> map) async {
    if (map['id'] == null) {
      final doc = await db.collection(colName).add(map);
      return doc.id;
    }
    await db.collection(colName).doc(map['id']).set(map);
    return map['id'];
  }

  @override
  Future<bool> delete(String colName, String id) async {
    await db.collection(colName).doc(id).delete();
    return true;
  }

  @override
  Future<List<Map<String, dynamic>>> find(
      String colName, Map<String, dynamic> filter) async {
    final nome = filter['nome'] ?? '';
    final query = await db
        .collection(colName)
        .orderBy('nome')
        .startAt([nome]).endAt(['${nome}z']).get();
    final list = <Map<String, dynamic>>[];
    for (var e in query.docs) {
      list.add(e.data());
    }
    return list;
  }

  @override
  Future<Map<String, dynamic>> findOne(String colName, String id) async {
    final query = await db.collection(colName).doc(id).get();
    return query.data() ?? {};
  }

  @override
  Future<bool> update(
      String colName, String id, Map<String, dynamic> map) async {
    await db.collection(colName).doc(map['id']).set(map);
    return true;
  }
}
