import 'package:eleicao/src/features/cadastro/mapper/aluno_mapper_sqflite.dart';
import 'package:eleicao/src/features/cadastro/repositories/aluno_repository.dart';
import 'package:eleicao/src/models/aluno.dart';
import 'package:eleicao/src/repositories/local/api_db.dart';

class AlunoRepositorySqflite implements AlunoRepository {
  final table = 'Alunos';
  final ApiDb apidb;

  AlunoRepositorySqflite(this.apidb);

  @override
  Future<String> create(Aluno aluno) {
    return apidb.create(table, AlunoMapperSqflite.toMap(aluno));
  }

  @override
  Future<bool> delete(String id) {
    return apidb.delete(table, id);
  }

  @override
  Future<List<Aluno>> find(Map<String, dynamic> filter) async {
    final list = await apidb.find(table, filter);
    return list.map((e) => AlunoMapperSqflite.fromMap(e)).toList();
  }

  @override
  Future<Aluno> findOne(String id) async {
    final map = await apidb.findOne(table, id);
    return AlunoMapperSqflite.fromMap(map);
  }

  @override
  Future<bool> update(String id, Aluno aluno) {
    return apidb.update(table, aluno.id, AlunoMapperSqflite.toMap(aluno));
  }
}
