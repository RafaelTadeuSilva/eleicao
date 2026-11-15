import 'package:eleicao/src/features/cadastro/repositories/evento_eleicao/evento_eleicao_repository.dart';
import 'package:eleicao/src/features/urna/state/votacao_state.dart';
import 'package:eleicao/src/models/evento_eleicao.dart';
import 'package:eleicao/src/repositories/api_db.dart';

class EventoEleicaoRepositoryImpl implements EventoEleicaoRepository {
  final String table = 'Eleicoes';
  final ApiDb apiDb;

  EventoEleicaoRepositoryImpl(this.apiDb);

  @override
  Future<List<EventoEleicao>> findAll() async {
    final eventos = <EventoEleicao>[];
    try {
      final list = await apiDb.find(table, {});
      eventos.addAll(list.map(EventoEleicao.fromMap));
    } catch (_) {
      // Se falhar ou estiver offline, mantém pelo menos o evento atual
    }

    // Garante que o evento ativo atual esteja sempre na lista
    final atual = eventoEleicaoAtual();
    if (!eventos.any((e) => e.id == atual.id)) {
      eventos.insert(0, atual);
    }

    // Garante opções padrões 2026 e 2025 caso ainda não estejam salvas
    if (!eventos.any((e) => e.id == '2026')) {
      eventos.add(EventoEleicao.fromSufixo(
        sufixo: '2026',
        nome: 'Eleição 2026',
      ));
    }
    if (!eventos.any((e) => e.id == '2025')) {
      eventos.add(EventoEleicao.fromSufixo(
        sufixo: '2025',
        nome: 'Eleição 2025',
      ));
    }

    return eventos;
  }

  @override
  Future<EventoEleicao?> findOne(String id) async {
    try {
      final map = await apiDb.findOne(table, id);
      if (map.isEmpty) return null;
      return EventoEleicao.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String> save(EventoEleicao evento) async {
    return await apiDb.create(table, evento.toMap());
  }

  @override
  Future<bool> delete(String id) async {
    return await apiDb.delete(table, id);
  }
}

