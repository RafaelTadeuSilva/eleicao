import 'package:eleicao/src/features/cadastro/mapper/candidato_mapper.dart';
import 'package:eleicao/src/features/cadastro/repositories/voto/voto_repository.dart';
import 'package:eleicao/src/models/voto.dart';
import 'package:eleicao/src/repositories/api_db.dart';

class VotoRepositoryImpl implements VotoRepository {
  final table = 'Votos2025';
  final ApiDb apiDb;
  final Mapper<Voto> mapper;

  VotoRepositoryImpl(this.apiDb, this.mapper);

  @override
  Future<String> create(Voto voto) {
    return apiDb.create(table, mapper.toMap(voto));
  }

  @override
  Future<List<Voto>> find(Map<String, dynamic> filter) async {
    final list = await apiDb.find(table, filter);
    return list.map((e) => mapper.fromMap(e)).toList();
  }
}
