import 'package:eleicao/src/features/cadastro/mapper/candidato_mapper.dart';
import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/models/candidato.dart';

class CandidatoMapperImpl implements Mapper<Candidato> {
  @override
  Candidato fromMap(Map<String, dynamic> map) {
    return Candidato(
      id: map['id'].toString(),
      numero: map['numero'],
      nome: map['nome'],
      nomeVice: map['nomeVice'],
      urlImage: map['urlImage'],
      urlImageVice: map['urlImageVice'],
      cargo: Cargo.getCargoByCodigo(map['codigo'] ?? 1),
      partido: '',
      zone: map['zone'],
    );
  }

  @override
  Map<String, dynamic> toMap(Candidato candidato) {
    return {
      'id': candidato.id,
      'numero': candidato.numero,
      'nome': candidato.nome,
      'nomeVice': candidato.nomeVice,
      'urlImage': candidato.urlImage,
      'urlImageVice': candidato.urlImageVice,
      'cargo': candidato.cargo.codigo,
      'partido': '',
      'zone': candidato.zone,
    };
  }
}
