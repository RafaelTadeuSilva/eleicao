abstract class ApiDb {
  Future<Map<String, dynamic>> findOne(String table, String id);
  Future<List<Map<String, dynamic>>> find(
      String table, Map<String, dynamic> filter);
  Future<String> create(String table, Map<String, dynamic> map);
  Future<bool> update(String table, String id, Map<String, dynamic> map);
  Future<bool> delete(String table, String id);
}
