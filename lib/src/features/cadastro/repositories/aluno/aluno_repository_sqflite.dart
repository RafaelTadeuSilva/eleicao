import 'package:eleicao/src/features/cadastro/mapper/aluno_mapper_sqflite.dart';
import 'package:eleicao/src/features/cadastro/repositories/aluno/aluno_repository.dart';
import 'package:eleicao/src/models/aluno.dart';
import 'package:eleicao/src/repositories/api_db.dart';

class AlunoRepositorySqflite implements AlunoRepository {
  final table = 'Alunos';
  final ApiDb apiDb;

  AlunoRepositorySqflite(this.apiDb);

  @override
  Future<String> create(Aluno aluno) {
    return apiDb.create(table, AlunoMapperSqflite.toMap(aluno));
  }

  @override
  Future<bool> delete(String id) {
    return apiDb.delete(table, id);
  }

  @override
  Future<List<Aluno>> find(Map<String, dynamic> filter) async {
    final list = await apiDb.find(table, filter);
    return list.map((e) => AlunoMapperSqflite.fromMap(e)).toList();
  }

  @override
  Future<Aluno> findOne(String id) async {
    final map = await apiDb.findOne(table, id);
    return AlunoMapperSqflite.fromMap(map);
  }

  @override
  Future<bool> update(String id, Aluno aluno) {
    return apiDb.update(table, aluno.id, AlunoMapperSqflite.toMap(aluno));
  }

  @override
  Future<Aluno?> findByTitulo(String titulo) {
    // TODO: implement findByTitulo
    throw UnimplementedError();
  }
}
