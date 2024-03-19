import 'package:eleicao/src/features/urna/enums/cargo.dart';

class Candidato {
  final String id;
  final int numero;
  final String nome;
  final String? nomeVice;
  final String urlImage;
  final String? urlImageVice;
  final Cargo cargo;
  final String partido;

  Candidato({
    required this.id,
    required this.numero,
    required this.nome,
    this.nomeVice,
    required this.urlImage,
    this.urlImageVice,
    required this.cargo,
    required this.partido,
  });
}
