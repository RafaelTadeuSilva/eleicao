import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/features/urna/state/votacao_state.dart';
import 'package:eleicao/src/injector.dart';
import 'package:eleicao/src/models/voto.dart';
import 'package:flutter/foundation.dart';

/// Totais de um candidato dentro de um cargo.
class ResultadoApuracao {
  final Cargo cargo;
  final String candidatoId;
  final String nome;
  final int numero;
  final int votos;

  /// Percentual sobre os votos do cargo (0 a 100) no filtro aplicado.
  final double percentual;

  /// Mais votado do cargo (em caso de empate, todos os empatados).
  final bool vencedor;
  final bool empate;

  const ResultadoApuracao({
    required this.cargo,
    required this.candidatoId,
    required this.nome,
    required this.numero,
    required this.votos,
    required this.percentual,
    required this.vencedor,
    required this.empate,
  });
}

class ApuracaoControl {
  final resultados = ValueNotifier(<ResultadoApuracao>[]);
  final totalVotos = ValueNotifier(0);

  /// Cargo filtrado; `null` = todos.
  Cargo? cargo;

  /// Zona filtrada; `null` = todas.
  int? zona;

  /// Cargos a oferecer no filtro: os do evento ativo, na ordem de votação.
  List<Cargo> get cargosDisponiveis =>
      tipoEleicao.map(Cargo.getCargoByCodigo).toList();

  Future<void> carregaApuracao({Cargo? cargo, int? zona}) async {
    this.cargo = cargo;
    this.zona = zona;

    final votos = await votoRepository.find(zona == null ? {} : {'zone': zona});
    final filtrados =
        cargo == null ? votos : votos.where((v) => v.cargo == cargo).toList();

    resultados.value = apurar(filtrados, ordemCargos: tipoEleicao);
    totalVotos.value = filtrados.length;
  }

  /// Agrupa os votos por cargo e candidato.
  ///
  /// O candidato é identificado pelo id do documento; votos antigos (sem id)
  /// são agrupados pelo nome. A lista vem ordenada pela [ordemCargos] e,
  /// dentro de cada cargo, do mais para o menos votado.
  @visibleForTesting
  static List<ResultadoApuracao> apurar(List<Voto> votos,
      {List<int> ordemCargos = const []}) {
    final grupos = <(Cargo, String), List<Voto>>{};
    for (final v in votos) {
      final chave = v.candidatoId.isNotEmpty ? v.candidatoId : 'nome:${v.nome}';
      grupos.putIfAbsent((v.cargo, chave), () => []).add(v);
    }

    final porCargo = <Cargo, List<(String, List<Voto>)>>{};
    grupos.forEach((k, lista) {
      porCargo.putIfAbsent(k.$1, () => []).add((k.$2, lista));
    });

    int ordem(Cargo c) {
      final i = ordemCargos.indexOf(c.codigo);
      return i == -1 ? ordemCargos.length + c.codigo : i;
    }

    final cargos = porCargo.keys.toList()
      ..sort((a, b) => ordem(a).compareTo(ordem(b)));

    final resultado = <ResultadoApuracao>[];
    for (final c in cargos) {
      final candidatos = porCargo[c]!
        ..sort((a, b) {
          final porVotos = b.$2.length.compareTo(a.$2.length);
          return porVotos != 0
              ? porVotos
              : a.$2.first.nome.compareTo(b.$2.first.nome);
        });
      final totalCargo =
          candidatos.fold<int>(0, (soma, e) => soma + e.$2.length);
      final maximo = candidatos.first.$2.length;
      final empatados = candidatos.where((e) => e.$2.length == maximo).length;

      for (final (_, lista) in candidatos) {
        final ultimo = lista.last; // dados mais recentes do candidato
        resultado.add(ResultadoApuracao(
          cargo: c,
          candidatoId: ultimo.candidatoId,
          nome: ultimo.nome,
          numero: ultimo.numero,
          votos: lista.length,
          percentual: lista.length * 100 / totalCargo,
          vencedor: lista.length == maximo,
          empate: lista.length == maximo && empatados > 1,
        ));
      }
    }
    return resultado;
  }
}
