import 'package:eleicao/src/features/urna/enums/cargo.dart';

class Candidato {
  final String id;
  final String nome;
  final String urlImage;
  final Cargo cargo;
  final String partido;

  Candidato({
    required this.id,
    required this.nome,
    required this.urlImage,
    required this.cargo,
    required this.partido,
  });
}
