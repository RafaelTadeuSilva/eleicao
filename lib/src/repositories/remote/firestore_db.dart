import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eleicao/src/repositories/api_db.dart';

class FirestoreDb implements ApiDb {
  final FirebaseFirestore db;

  /// [db] permite injetar uma instância alternativa (ex.: fake em testes).
  FirestoreDb({FirebaseFirestore? db}) : db = db ?? FirebaseFirestore.instance;

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

  /// Busca documentos de [colName].
  ///
  /// - Sem filtros de igualdade: ordena por `nome` e filtra pelo prefixo
  ///   `filter['nome']` (vazio = todos).
  /// - Com filtros de igualdade (qualquer outra chave com valor não vazio):
  ///   aplica todos com `isEqualTo` e ignora `nome`. Os valores devem ter o
  ///   mesmo tipo gravado no banco (ex.: int para `zone`, `titulo`, `numero`).
  @override
  Future<List<Map<String, dynamic>>> find(
      String colName, Map<String, dynamic> filter) async {
    final igualdade = <String, Object>{
      for (final e in filter.entries)
        if (e.key != 'nome' && e.value != null && e.value.toString().isNotEmpty)
          e.key: e.value as Object,
    };

    Query<Map<String, dynamic>> query = db.collection(colName);
    if (igualdade.isEmpty) {
      final String nome = filter['nome']?.toString() ?? '';
      // \uf8ff fica acima de qualquer letra (inclusive acentuadas), então o
      // intervalo cobre todos os nomes que começam com o prefixo.
      query = query.orderBy('nome').startAt([nome]).endAt(['$nome\uf8ff']);
    } else {
      igualdade.forEach((campo, valor) {
        query = query.where(campo, isEqualTo: valor);
      });
    }

    final snapshot = await query.get();
    return [
      for (final doc in snapshot.docs) {...doc.data(), 'id': doc.id},
    ];
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
