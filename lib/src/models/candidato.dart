import 'package:eleicao/src/features/urna/enums/cargo.dart';

class Candidato {
  /// Id do documento no banco. Vazio para candidatos ainda não salvos
  /// (o Firebase gera o id automaticamente).
  final String id;
  final int numero;
  final String nome;
  final String? nomeVice;
  final String urlImage;
  final String? urlImageVice;
  final Cargo cargo;

  /// Zona eleitoral: 0 = Geral (aparece em todas as urnas).
  final int zone;

  Candidato({
    this.id = '',
    required this.numero,
    required this.nome,
    this.nomeVice,
    required this.urlImage,
    this.urlImageVice,
    required this.cargo,
    required this.zone,
  });
}
