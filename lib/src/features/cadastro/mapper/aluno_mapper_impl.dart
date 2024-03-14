import 'package:eleicao/src/features/cadastro/mapper/aluno_mapper.dart';
import 'package:eleicao/src/models/aluno.dart';

class AlunoMapperImpl implements AlunoMapper {
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
