import 'package:eleicao/src/models/candidato.dart';

abstract class CandidatoRepository {
  Future<Candidato> findOne(String id);
  Future<List<Candidato>> find(Map<String, dynamic> filter);
  Future<String> create(Candidato candidato);
  Future<bool> update(String id, Candidato candidato);
  Future<bool> delete(String id);
}
