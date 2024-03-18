import 'package:eleicao/src/features/cadastro/mapper/candidato_mapper.dart';
import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/models/candidato.dart';

class CandidatoMapperImpl implements Mapper<Candidato> {
  @override
  Candidato fromMap(Map<String, dynamic> map) {
    return Candidato(
        id: map['id'],
        numero: map['numero'],
        nome: map['nome'],
        urlImage: map['urlImage'],
        cargo: Cargo.values.firstWhere((e) => e.codigo == map['cargo']),
        partido: '');
  }

  @override
  Map<String, dynamic> toMap(Candidato candidato) {
    return {
      'id': candidato.id,
      'numero': candidato.numero,
      'nome': candidato.nome,
      'urlImage': candidato.urlImage,
      'cargo': candidato.cargo.codigo,
      'partido': ''
    };
  }
}
