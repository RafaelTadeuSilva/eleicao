import 'package:eleicao/src/features/urna/enums/cargo.dart';

class Voto {
  final String? id;
  final Cargo cargo;

  /// Id do documento do candidato. Vazio em votos antigos, gravados antes
  /// deste campo existir.
  final String candidatoId;
  final int numero;
  final String nome;

  /// Zona da urna em que o voto foi registrado.
  final int zone;

  Voto({
    this.id,
    required this.cargo,
    required this.candidatoId,
    required this.numero,
    required this.nome,
    required this.zone,
  });
}
