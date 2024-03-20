import 'package:eleicao/src/features/cadastro/mapper/aluno_mapper.dart';
import 'package:eleicao/src/features/cadastro/repositories/aluno/aluno_repository.dart';
import 'package:eleicao/src/models/aluno.dart';
import 'package:eleicao/src/repositories/api_db.dart';

class AlunoRepositoryImpl implements AlunoRepository {
  final table = 'Alunos';
  final ApiDb apiDb;
  final AlunoMapper mapper;

  AlunoRepositoryImpl(this.apiDb, this.mapper);

  @override
  Future<String> create(Aluno aluno) {
    return apiDb.create(table, mapper.toMap(aluno));
  }

  @override
  Future<bool> delete(String id) {
    return apiDb.delete(table, id);
  }

  @override
  Future<List<Aluno>> find(Map<String, dynamic> filter) async {
    final list = await apiDb.find(table, filter);
    return list.map((e) => mapper.fromMap(e)).toList();
  }

  @override
  Future<Aluno?> findOne(String id) async {
    final map = await apiDb.findOne(table, id);
    if (map.isEmpty) return null;
    return mapper.fromMap(map);
  }

  @override
  Future<bool> update(String id, Aluno aluno) async {
    return await apiDb.update(table, id, mapper.toMap(aluno));
  }

  @override
  Future<Aluno?> findByTitulo(String titulo) async {
    final map = await apiDb.find(table, {'titulo': titulo});
    if (map.isEmpty) return null;
    return mapper.fromMap(map.first);
  }
}
