import 'package:eleicao/src/features/cadastro/mapper/candidato_mapper.dart';
import 'package:eleicao/src/models/voto.dart';

class VotoMapperImpl implements Mapper<Voto> {
  @override
  Voto fromMap(Map<String, dynamic> map) {
    return Voto(
      id: map['id'].toString(),
      matricula: map['matricula'],
      nome: map['nome'],
      cargo: map['cargo'],
    );
  }

  @override
  Map<String, dynamic> toMap(Voto voto) {
    return {
      'cargo': voto.cargo,
      'matricula': voto.matricula,
      'nome': voto.nome,
    };
  }
}
