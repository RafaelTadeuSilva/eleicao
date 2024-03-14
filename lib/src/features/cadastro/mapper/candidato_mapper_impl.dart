import 'package:eleicao/src/features/cadastro/mapper/candidato_mapper.dart';
import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/models/candidato.dart';

class CandidatoMapperImpl implements Mapper<Candidato> {
  @override
  Candidato fromMap(Map<String, dynamic> map) {
    return Candidato(
        matricula: map['matricula'].toString(),
        id: map['id'].toString(),
        nome: map['nome'],
        urlImage: '',
        cargo: Cargo.prefeito,
        partido: '');
  }

  @override
  Map<String, dynamic> toMap(Candidato candidato) {
    return {
      'matricula': candidato.matricula,
      'id': candidato.id,
      'nome': candidato.nome,
      'urlImage': '',
      'cargo': candidato.cargo.codigo,
      'partido': ''
    };
  }
}
