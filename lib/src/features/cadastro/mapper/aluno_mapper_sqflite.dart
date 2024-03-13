import 'package:eleicao/src/models/aluno.dart';

class AlunoMapperSqflite {
  static Map<String, dynamic> toMap(Aluno aluno) {
    return {
      'id': aluno.id,
      'nome': aluno.nome,
      'turma': aluno.turma,
      'titulo': aluno.titulo,
    };
  }

  static Aluno fromMap(Map<String, dynamic> map) {
    return Aluno(
        id: map['id'].toString(),
        nome: map['nome'],
        turma: map['turma'],
        titulo: map['titulo']);
  }
}
