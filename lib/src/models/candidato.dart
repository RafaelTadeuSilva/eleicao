import 'package:eleicao/src/features/urna/enums/cargo.dart';

class Candidato {
  final String id;
  final int numero;
  final String nome;
  final String urlImage;
  final Cargo cargo;
  final String partido;

  Candidato({
    required this.id,
    required this.numero,
    required this.nome,
    required this.urlImage,
    required this.cargo,
    required this.partido,
  });
}
