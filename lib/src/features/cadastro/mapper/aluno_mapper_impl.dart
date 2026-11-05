import 'package:eleicao/src/features/cadastro/mapper/mapper.dart';
import 'package:eleicao/src/models/aluno.dart';

class AlunoMapperImpl implements Mapper<Aluno> {
  @override
  Aluno fromMap(Map<String, dynamic> map) {
    return Aluno(
        id: map['id'].toString(),
        nome: map['nome'],
        turma: map['turma'],
        titulo: map['titulo']);
  }

  @override
  Map<String, dynamic> toMap(Aluno aluno) {
    return {
      'id': aluno.id,
      'nome': aluno.nome,
      'turma': aluno.turma,
      'titulo': aluno.titulo,
    };
  }
}
