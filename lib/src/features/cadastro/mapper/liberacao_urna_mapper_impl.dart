import 'package:eleicao/src/features/cadastro/mapper/candidato_mapper.dart';
import 'package:eleicao/src/models/liberacao_urna.dart';

class LiberacaoUrnaMapperImpl implements Mapper<LiberacaoUrna> {
  @override
  LiberacaoUrna fromMap(Map<String, dynamic> map) {
    return LiberacaoUrna(
        id: map['id'],
        matricula: map['matricula'],
        nome: map['nome'],
        titulo: map['titulo'],
        turma: map['turma'],
        urna: map['urna'],
        status: map['status']);
  }

  @override
  Map<String, dynamic> toMap(LiberacaoUrna libUrna) {
    return {
      'matricula': libUrna.matricula,
      'nome': libUrna.nome,
      'titulo': libUrna.titulo,
      'turma': libUrna.turma,
      'urna': libUrna.urna,
      'status': libUrna.status,
    };
  }
}
