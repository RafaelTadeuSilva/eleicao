import 'package:eleicao/src/models/evento_eleicao.dart';

abstract interface class EventoEleicaoRepository {
  Future<List<EventoEleicao>> findAll();
  Future<EventoEleicao?> findOne(String id);
  Future<String> save(EventoEleicao evento);
  Future<bool> delete(String id);
}

