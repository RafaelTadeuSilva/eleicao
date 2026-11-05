abstract class ApiDb {
  Future<Map<String, dynamic>> findOne(String table, String id);
  Future<List<Map<String, dynamic>>> find(
      String table, Map<String, dynamic> filter);

  /// Cria um documento. Sem `id` (ou com id vazio) o banco gera um.
  Future<String> create(String table, Map<String, dynamic> map);

  /// Cria vários documentos de forma atômica: ou todos são gravados ou
  /// nenhum é.
  Future<void> createAll(String table, List<Map<String, dynamic>> maps);
  Future<bool> update(String table, String id, Map<String, dynamic> map);
  Future<bool> delete(String table, String id);
}
