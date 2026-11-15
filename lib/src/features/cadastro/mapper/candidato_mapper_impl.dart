import 'package:eleicao/src/features/cadastro/mapper/candidato_mapper.dart';
import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/models/candidato.dart';

class CandidatoMapperImpl implements Mapper<Candidato> {
  @override
  Candidato fromMap(Map<String, dynamic> map) {
    final rawId = map['id']?.toString() ?? '';
    final rawMatricula =
        map['matricula']?.toString() ?? rawId.split('_').first;
    return Candidato(
      id: rawId,
      matricula: rawMatricula,
      numero: map['numero'] ?? 0,
      nome: map['nome'] ?? '',
      nomeVice: map['nomeVice'],
      urlImage: map['urlImage'] ?? '',
      urlImageVice: map['urlImageVice'],
      cargo: Cargo.getCargoByCodigo(map['cargo'] ?? 1),
      partido: '',
      zone: map['zone'] ?? 0,
    );
  }

  @override
  Map<String, dynamic> toMap(Candidato candidato) {
    return {
      'id': candidato.id,
      'matricula': candidato.matricula,
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
