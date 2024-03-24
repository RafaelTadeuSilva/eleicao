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

  Future<QuerySnapshot<Map<String, dynamic>>> findByNome(
      String colName, String nome) {
    return db
        .collection(colName)
        .orderBy('nome')
        .startAt([nome]).endAt(['${nome}z']).get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> findByTitulo(
      String colName, String value) {
    return db
        .collection(colName)
        .where('titulo', isEqualTo: int.parse(value))
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> findByZone(
      String colName, String value) {
    return db
        .collection(colName)
        .where('zone', isEqualTo: int.parse(value))
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> findByUrnaStatus(
      String colName, String urna, String status) {
    return db
        .collection(colName)
        .where('urna', isEqualTo: int.parse(urna))
        .where('status', isEqualTo: int.parse(status))
        .get();
  }

  @override
  Future<List<Map<String, dynamic>>> find(
      String colName, Map<String, dynamic> filter) async {
    final String nome = filter['nome'] ?? '';
    final String titulo = filter['titulo'] ?? '';
    final String urna = filter['urna']?.toString() ?? '';
    final String status = filter['status']?.toString() ?? '';
    final String zone = filter['zone']?.toString() ?? '';
    QuerySnapshot<Map<String, dynamic>> query;

    if (titulo.isNotEmpty && int.tryParse(titulo) != null) {
      query = await findByTitulo(colName, titulo);
    } else if (zone.isNotEmpty && int.tryParse(zone) != null) {
      query = await findByZone(colName, zone);
    } else if (urna.isNotEmpty &&
        int.tryParse(urna) != null &&
        status.isNotEmpty &&
        int.tryParse(status) != null) {
      query = await findByUrnaStatus(colName, urna, status);
    } else {
      query = await findByNome(colName, nome);
    }

    final list = <Map<String, dynamic>>[];
    for (var e in query.docs) {
      final map = e.data();
      if (!map.containsKey('id')) {
        map['id'] = e.id;
      }
      list.add(map);
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
    await db.collection(colName).doc(id).set(map, SetOptions(merge: true));
    return true;
  }
}
