import 'package:eleicao/src/models/aluno.dart';

abstract class AlunoMapper {
  Map<String, dynamic> toMap(Aluno aluno);
  Aluno fromMap(Map<String, dynamic> map);
}
