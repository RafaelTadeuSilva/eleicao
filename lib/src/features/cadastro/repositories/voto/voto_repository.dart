import 'package:eleicao/src/models/voto.dart';

abstract class VotoRepository {
  Future<List<Voto>> find(Map<String, dynamic> filter);
  Future<String> create(Voto voto);

  /// Grava todos os votos de um eleitor de forma atômica.
  Future<void> createAll(List<Voto> votos);
}
