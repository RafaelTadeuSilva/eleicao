import 'package:eleicao/src/features/cadastro/mapper/mapper.dart';
import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/models/voto.dart';

class VotoMapperImpl implements Mapper<Voto> {
  /// Aceita votos antigos, em que `cargo` era a descrição (String) e não
  /// havia `candidatoId`/`numero`.
  @override
  Voto fromMap(Map<String, dynamic> map) {
    final cargo = map['cargo'];
    return Voto(
      id: map['id']?.toString(),
      cargo: cargo is int
          ? Cargo.getCargoByCodigo(cargo)
          : Cargo.getCargoByDescricao(cargo?.toString() ?? ''),
      candidatoId: map['candidatoId']?.toString() ?? '',
      numero: map['numero'] ?? 0,
      nome: map['nome'] ?? '',
      zone: map['zone'] ?? 0,
    );
  }

  @override
  Map<String, dynamic> toMap(Voto voto) {
    return {
      'cargo': voto.cargo.codigo,
      'cargoDescricao': voto.cargo.descricao,
      'candidatoId': voto.candidatoId,
      'numero': voto.numero,
      'nome': voto.nome,
      'zone': voto.zone,
    };
  }
}
