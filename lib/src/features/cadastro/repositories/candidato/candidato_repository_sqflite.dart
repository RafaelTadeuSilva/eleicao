import 'package:eleicao/src/features/cadastro/mapper/candidato_mapper.dart';
import 'package:eleicao/src/features/cadastro/repositories/candidato/candidato_repository.dart';
import 'package:eleicao/src/models/candidato.dart';
import 'package:eleicao/src/repositories/api_db.dart';

class CandidatoRepositorySqflite implements CandidatoRepository {
  final table = 'Candidatos';
  final ApiDb apiDb;
  final Mapper<Candidato> mapper;
  CandidatoRepositorySqflite(this.apiDb, this.mapper);

  @override
  Future<String> create(Candidato aluno) {
    return apiDb.create(table, mapper.toMap(aluno));
  }

  @override
  Future<bool> delete(String id) {
    return apiDb.delete(table, id);
  }

  @override
  Future<List<Candidato>> find(Map<String, dynamic> filter) async {
    final list = await apiDb.find(table, filter);
    return list.map((e) => mapper.fromMap(e)).toList();
  }

  @override
  Future<Candidato> findOne(String id) async {
    final map = await apiDb.findOne(table, id);
    return mapper.fromMap(map);
  }

  @override
  Future<bool> update(String id, Candidato aluno) {
    return apiDb.update(table, aluno.id, mapper.toMap(aluno));
  }
}
