import 'package:eleicao/src/features/cadastro/mapper/mapper.dart';
import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/models/candidato.dart';

class CandidatoMapperImpl implements Mapper<Candidato> {
  @override
  Candidato fromMap(Map<String, dynamic> map) {
    return Candidato(
      id: map['id']?.toString() ?? '',
      numero: map['numero'] ?? 0,
      nome: map['nome'] ?? '',
      nomeVice: map['nomeVice'],
      urlImage: map['urlImage'] ?? '',
      urlImageVice: map['urlImageVice'],
      cargo: Cargo.getCargoByCodigo(map['cargo'] ?? 1),
      zone: map['zone'] ?? 0,
    );
  }

  /// Não inclui o `id`: ele é a chave do documento, não um campo.
  @override
  Map<String, dynamic> toMap(Candidato candidato) {
    return {
      'numero': candidato.numero,
      'nome': candidato.nome,
      'nomeVice': candidato.nomeVice,
      'urlImage': candidato.urlImage,
      'urlImageVice': candidato.urlImageVice,
      'cargo': candidato.cargo.codigo,
      'zone': candidato.zone,
    };
  }
}
