import 'package:eleicao/src/models/voto.dart';

abstract class VotoRepository {
  Future<List<Voto>?> find(Map<String, dynamic> filter);
  Future<String> create(Voto candidato);
}
