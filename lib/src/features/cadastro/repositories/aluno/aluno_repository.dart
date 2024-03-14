import 'package:eleicao/src/models/aluno.dart';

abstract class AlunoRepository {
  Future<Aluno> findOne(String id);
  Future<List<Aluno>> find(Map<String, dynamic> filter);
  Future<String> create(Aluno aluno);
  Future<bool> update(String id, Aluno aluno);
  Future<bool> delete(String id);
}
