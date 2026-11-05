import 'package:eleicao/src/features/cadastro/controllers/candidato_control.dart';
import 'package:eleicao/src/features/urna/controllers/votacao_control.dart';
import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/models/candidato.dart';
import 'package:eleicao/src/models/zona.dart';

/// Erro: atrapalha a votação ou a apuração. Aviso: deve ser revisado, mas
/// não impede a eleição (ex.: candidato sem foto).
enum Gravidade { erro, aviso }

enum TipoProblema {
  nomeVazio(Gravidade.erro),
  digitosInvalidos(Gravidade.erro),
  numeroDuplicado(Gravidade.erro),
  semFoto(Gravidade.aviso),
  viceSemNome(Gravidade.aviso),
  viceSemFoto(Gravidade.aviso),
  cargoForaDoEvento(Gravidade.aviso),
  zonaInexistente(Gravidade.aviso);

  const TipoProblema(this.gravidade);
  final Gravidade gravidade;
}

class ProblemaCandidato {
  final TipoProblema tipo;
  final String descricao;

  const ProblemaCandidato(this.tipo, this.descricao);

  Gravidade get gravidade => tipo.gravidade;
}

class CandidatoComProblemas {
  final Candidato candidato;
  final List<ProblemaCandidato> problemas;

  const CandidatoComProblemas(this.candidato, this.problemas);

  bool get temErro => problemas.any((p) => p.gravidade == Gravidade.erro);
  bool get semFoto => problemas.any((p) =>
      p.tipo == TipoProblema.semFoto || p.tipo == TipoProblema.viceSemFoto);
}

/// Cargo do evento sem nenhum candidato visível nas urnas de uma zona: o
/// eleitor ficaria travado nessa etapa (não há voto em branco).
class CargoSemCandidato {
  final Cargo cargo;
  final Zona zona;

  const CargoSemCandidato(this.cargo, this.zona);

  String get descricao =>
      '${cargo.descricao}: nenhum candidato para as urnas da zona ${zona.nome}';
}

class ResultadoVerificacao {
  final int totalCandidatos;

  /// Só os candidatos com algum problema; erros primeiro.
  final List<CandidatoComProblemas> candidatos;
  final List<CargoSemCandidato> cargosSemCandidato;

  const ResultadoVerificacao({
    required this.totalCandidatos,
    required this.candidatos,
    required this.cargosSemCandidato,
  });

  int get totalErros =>
      cargosSemCandidato.length +
      candidatos.fold(
          0,
          (soma, c) =>
              soma +
              c.problemas.where((p) => p.gravidade == Gravidade.erro).length);

  int get totalAvisos => candidatos.fold(
      0,
      (soma, c) =>
          soma +
          c.problemas.where((p) => p.gravidade == Gravidade.aviso).length);

  int get totalSemFoto => candidatos.where((c) => c.semFoto).length;

  bool get semProblemas => candidatos.isEmpty && cargosSemCandidato.isEmpty;

  /// Problemas por id de candidato (para marcar itens em listas).
  Map<String, CandidatoComProblemas> get porId =>
      {for (final c in candidatos) c.candidato.id: c};
}

/// Analisa os candidatos de um evento procurando erros de cadastro.
class VerificacaoCandidatos {
  /// [cargos] são os cargos do evento (na ordem de votação), [digitosDoCargo]
  /// a quantidade de dígitos configurada para cada cargo e [zonas] as zonas
  /// do evento.
  static ResultadoVerificacao verificar(
    List<Candidato> candidatos, {
    required List<int> cargos,
    required int Function(int codigoCargo) digitosDoCargo,
    required List<Zona> zonas,
  }) {
    final codigosZonas = zonas.map((z) => z.codigo).toSet();
    final comProblemas = <CandidatoComProblemas>[];

    for (final c in candidatos) {
      final problemas = <ProblemaCandidato>[];

      if (c.nome.trim().isEmpty) {
        problemas.add(const ProblemaCandidato(
            TipoProblema.nomeVazio, 'Nome não informado'));
      }

      final digitos = digitosDoCargo(c.cargo.codigo);
      if (c.numero.toString().length != digitos) {
        problemas.add(ProblemaCandidato(TipoProblema.digitosInvalidos,
            'Número ${c.numero} não tem os $digitos dígitos do cargo; não pode ser digitado na urna'));
      }

      final duplicado = CandidatoControl.numeroDuplicado(candidatos,
          numero: c.numero, cargo: c.cargo, zone: c.zone, ignorarId: c.id);
      if (duplicado != null) {
        problemas.add(ProblemaCandidato(TipoProblema.numeroDuplicado,
            'Número ${c.numero} também usado por "${duplicado.nome}" no mesmo cargo'));
      }

      if (c.urlImage.trim().isEmpty) {
        problemas
            .add(const ProblemaCandidato(TipoProblema.semFoto, 'Sem foto'));
      }

      if (c.cargo.temVice) {
        if ((c.nomeVice ?? '').trim().isEmpty) {
          problemas.add(const ProblemaCandidato(
              TipoProblema.viceSemNome, 'Vice sem nome'));
        }
        if ((c.urlImageVice ?? '').trim().isEmpty) {
          problemas.add(const ProblemaCandidato(
              TipoProblema.viceSemFoto, 'Vice sem foto'));
        }
      }

      if (!cargos.contains(c.cargo.codigo)) {
        problemas.add(ProblemaCandidato(TipoProblema.cargoForaDoEvento,
            'Cargo "${c.cargo.descricao}" não faz parte desta eleição; não aparece na votação'));
      }

      if (!codigosZonas.contains(c.zone)) {
        problemas.add(ProblemaCandidato(TipoProblema.zonaInexistente,
            'Zona ${c.zone} não existe nesta eleição'));
      }

      if (problemas.isNotEmpty) {
        comProblemas.add(CandidatoComProblemas(c, problemas));
      }
    }

    int ordemCargo(Cargo cargo) {
      final i = cargos.indexOf(cargo.codigo);
      return i == -1 ? cargos.length + cargo.codigo : i;
    }

    comProblemas.sort((a, b) {
      if (a.temErro != b.temErro) return a.temErro ? -1 : 1;
      final porCargo = ordemCargo(a.candidato.cargo)
          .compareTo(ordemCargo(b.candidato.cargo));
      if (porCargo != 0) return porCargo;
      return a.candidato.numero.compareTo(b.candidato.numero);
    });

    return ResultadoVerificacao(
      totalCandidatos: candidatos.length,
      candidatos: comProblemas,
      cargosSemCandidato: _cargosSemCandidato(candidatos, cargos, zonas),
    );
  }

  /// Com apenas a zona Geral, verifica a Geral. Com zonas de turma, as urnas
  /// ficam nessas zonas, então verifica cada uma delas (cada urna vê os
  /// candidatos da Geral e da própria zona).
  static List<CargoSemCandidato> _cargosSemCandidato(
      List<Candidato> candidatos, List<int> cargos, List<Zona> zonas) {
    final zonasDeUrna =
        zonas.length <= 1 ? zonas : zonas.where((z) => !z.isGeral).toList();
    return [
      for (final zona in zonasDeUrna)
        for (final cargo in VotacaoControl.cargosSemCandidato(
            candidatos, zona.codigo, cargos))
          CargoSemCandidato(cargo, zona),
    ];
  }
}
