import 'package:eleicao/src/features/cadastro/mapper/candidato_mapper.dart';
import 'package:eleicao/src/features/cadastro/repositories/liberacao_urna/liberacao_urna_repository.dart';
import 'package:eleicao/src/models/liberacao_urna.dart';
import 'package:eleicao/src/repositories/api_db.dart';

class LiberacaoUrnaRepositoryImpl implements LiberacaoUrnaRepository {
  final table = "LiberacaoUrna";
  final ApiDb apiDb;
  final Mapper<LiberacaoUrna> mapper;

  LiberacaoUrnaRepositoryImpl(this.apiDb, this.mapper);

  @override
  Future<void> registra(LiberacaoUrna libUrna) async {
    await apiDb.create(table, mapper.toMap(libUrna));
  }

  @override
  Future<LiberacaoUrna?> proximaLiberacao(int urna) async {
    return LiberacaoUrna(
        matricula: '0', nome: '', titulo: 0, turma: 0, urna: urna, status: 0);
    //será utilizado na votação de presidente
    // final list = await apiDb.find(table, {'urna': urna, 'status': 0});
    // if (list.isNotEmpty) {
    //   return mapper.fromMap(list.first);
    // }
    // return null;
  }

  @override
  Future<void> finalizaLiberacao(LiberacaoUrna libUrna) async {
    if (libUrna.id != null) {
      final map = {'status': 1};
      await apiDb.update(table, libUrna.id!, map);
    }
  }
}
