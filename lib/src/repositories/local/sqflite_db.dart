import 'package:eleicao/src/repositories/api_db.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqfliteDb implements ApiDb {
  static Future<Database> createDatabase() async {
    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'demo.db');

// Delete the database
    // await deleteDatabase(path);

// open the database
    Database database = await openDatabase(path, version: 3,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute(
          'CREATE TABLE Alunos (id INTEGER PRIMARY KEY, nome TEXT, turma INTEGER, titulo INTEGER)');
      await db.execute(
          'CREATE TABLE Candidatos (id INTEGER PRIMARY KEY, nome TEXT, urlImage TEXT, cargo INTEGER, partido TEXT)');
    });
    return database;
  }

  final Database db;

  SqfliteDb({required this.db});

  @override
  Future<String> create(String table, Map<String, dynamic> map) async {
    final id = await db.insert(table, map,
        conflictAlgorithm: ConflictAlgorithm.replace);
    return id.toString();
  }

  @override
  Future<bool> delete(String table, String id) async {
    final count = await db.delete(table, where: 'id = ?', whereArgs: [id]);
    return count == 1;
  }

  @override
  Future<List<Map<String, dynamic>>> find(
      String table, Map<String, dynamic> filter) async {
    final nome = filter['nome'] ?? '';
    return await db.query(table,
        where: 'nome LIKE ?', whereArgs: ['$nome%'], orderBy: 'nome');
  }

  @override
  Future<Map<String, dynamic>> findOne(String table, String id) async {
    final list = await db.query(table, where: 'id = ?', whereArgs: [id]);
    return switch (list.length) {
      > 0 => list.first,
      _ => {},
    };
  }

  @override
  Future<bool> update(String table, String id, Map<String, dynamic> map) async {
    final count = await db.update(table, map, where: 'id = ?', whereArgs: [id]);
    return count == 1;
  }
}
