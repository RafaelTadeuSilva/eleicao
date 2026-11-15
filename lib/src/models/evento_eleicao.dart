import 'package:eleicao/src/features/urna/enums/cargo.dart';

class EventoEleicao {
  final String id;
  final String nome;
  final String colecaoAlunos;
  final String colecaoCandidatos;
  final String colecaoVotos;
  final String colecaoLiberacao;
  final TipoEleicaoModalidade modalidade;
  final List<int> cargos;
  final Map<int, int> digitosPorCargo;

  const EventoEleicao({
    required this.id,
    required this.nome,
    required this.colecaoAlunos,
    required this.colecaoCandidatos,
    required this.colecaoVotos,
    required this.colecaoLiberacao,
    required this.modalidade,
    required this.cargos,
    this.digitosPorCargo = const {},
  });

  factory EventoEleicao.fromSufixo({
    required String sufixo,
    String? nome,
    String? colecaoAlunos,
    String? colecaoCandidatos,
    String? colecaoVotos,
    String? colecaoLiberacao,
    TipoEleicaoModalidade modalidade = TipoEleicaoModalidade.politica,
    List<int>? cargos,
    Map<int, int>? digitosPorCargo,
  }) {
    final chaveLimpa = sufixo.trim().isEmpty ? '2026' : sufixo.trim();
    final cargosPadrao = cargos != null && cargos.isNotEmpty
        ? cargos
        : [Cargo.byModalidade(modalidade).first.codigo];
    final mapaDigitos = <int, int>{};
    for (final c in Cargo.byModalidade(modalidade)) {
      mapaDigitos[c.codigo] =
          (digitosPorCargo?[c.codigo] ?? c.digitosPadrao).clamp(1, 6);
    }
    if (digitosPorCargo != null) {
      digitosPorCargo.forEach((k, v) {
        mapaDigitos[k] = v.clamp(1, 6);
      });
    }

    return EventoEleicao(
      id: chaveLimpa,
      nome: (nome != null && nome.trim().isNotEmpty)
          ? nome.trim()
          : 'Eleição $chaveLimpa',
      colecaoAlunos: (colecaoAlunos != null && colecaoAlunos.trim().isNotEmpty)
          ? colecaoAlunos.trim()
          : 'Alunos$chaveLimpa',
      colecaoCandidatos:
          (colecaoCandidatos != null && colecaoCandidatos.trim().isNotEmpty)
              ? colecaoCandidatos.trim()
              : 'Candidatos$chaveLimpa',
      colecaoVotos: (colecaoVotos != null && colecaoVotos.trim().isNotEmpty)
          ? colecaoVotos.trim()
          : 'Votos$chaveLimpa',
      colecaoLiberacao:
          (colecaoLiberacao != null && colecaoLiberacao.trim().isNotEmpty)
              ? colecaoLiberacao.trim()
              : 'LiberacaoUrna$chaveLimpa',
      modalidade: modalidade,
      cargos: cargosPadrao,
      digitosPorCargo: mapaDigitos,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'colecao_alunos': colecaoAlunos,
      'colecao_candidatos': colecaoCandidatos,
      'colecao_votos': colecaoVotos,
      'colecao_liberacao': colecaoLiberacao,
      'modalidade': modalidade.codigo,
      'cargos': cargos,
      'digitos_por_cargo':
          digitosPorCargo.map((k, v) => MapEntry(k.toString(), v)),
    };
  }

  factory EventoEleicao.fromMap(Map<String, dynamic> map) {
    final id = (map['id'] ?? '2026').toString();
    final modalidade = TipoEleicaoModalidade.getByCodigo(
      map['modalidade'] is int
          ? map['modalidade'] as int
          : int.tryParse(map['modalidade']?.toString() ?? '1') ?? 1,
    );
    final rawCargos = map['cargos'];
    final cargos = <int>[];
    if (rawCargos is List) {
      for (final item in rawCargos) {
        final parsed = item is int ? item : int.tryParse(item.toString());
        if (parsed != null) {
          cargos.add(parsed);
        }
      }
    }
    if (cargos.isEmpty) {
      cargos.add(Cargo.byModalidade(modalidade).first.codigo);
    }

    final mapaDigitos = <int, int>{};
    final rawDigitosMap = map['digitos_por_cargo'];
    if (rawDigitosMap is Map) {
      rawDigitosMap.forEach((key, value) {
        final k = int.tryParse(key.toString());
        final v = value is int ? value : int.tryParse(value.toString());
        if (k != null && v != null) {
          mapaDigitos[k] = v.clamp(1, 6);
        }
      });
    }

    return EventoEleicao(
      id: id,
      nome: (map['nome'] ?? 'Eleição $id').toString(),
      colecaoAlunos: (map['colecao_alunos'] ?? 'Alunos$id').toString(),
      colecaoCandidatos:
          (map['colecao_candidatos'] ?? 'Candidatos$id').toString(),
      colecaoVotos: (map['colecao_votos'] ?? 'Votos$id').toString(),
      colecaoLiberacao:
          (map['colecao_liberacao'] ?? 'LiberacaoUrna$id').toString(),
      modalidade: modalidade,
      cargos: cargos,
      digitosPorCargo: mapaDigitos,
    );
  }
}
