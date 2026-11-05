import 'package:eleicao/src/features/cadastro/controllers/verificacao_candidatos.dart';
import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/models/candidato.dart';
import 'package:eleicao/src/models/zona.dart';
import 'package:flutter_test/flutter_test.dart';

Candidato cand(
  String id, {
  String nome = 'Fulano',
  int numero = 12,
  Cargo cargo = Cargo.presidente,
  int zone = 0,
  String foto = 'https://x/foto.png',
  String? nomeVice,
  String? fotoVice,
}) =>
    Candidato(
      id: id,
      numero: numero,
      nome: nome,
      urlImage: foto,
      cargo: cargo,
      zone: zone,
      nomeVice: nomeVice,
      urlImageVice: fotoVice,
    );

/// Evento: presidente (2 dígitos) e vereador (4 dígitos), só zona Geral.
ResultadoVerificacao verificar(List<Candidato> candidatos,
        {List<int>? cargos, List<Zona> zonas = const [Zona.geral]}) =>
    VerificacaoCandidatos.verificar(
      candidatos,
      cargos: cargos ?? [Cargo.presidente.codigo, Cargo.vereador.codigo],
      digitosDoCargo: (c) => Cargo.getCargoByCodigo(c).digitosPadrao,
      zonas: zonas,
    );

Set<TipoProblema> tipos(ResultadoVerificacao r, String id) =>
    r.porId[id]?.problemas.map((p) => p.tipo).toSet() ?? {};

void main() {
  final completos = [
    cand('p1', numero: 12),
    cand('v1', numero: 1234, cargo: Cargo.vereador),
  ];

  test('cadastro completo não tem problemas', () {
    final r = verificar(completos);
    expect(r.semProblemas, isTrue);
    expect(r.totalCandidatos, 2);
    expect(r.totalErros, 0);
    expect(r.totalAvisos, 0);
  });

  test('candidato sem foto gera aviso', () {
    final r = verificar([...completos, cand('p2', numero: 13, foto: ' ')]);
    expect(tipos(r, 'p2'), {TipoProblema.semFoto});
    expect(r.porId['p2']!.semFoto, isTrue);
    expect(r.porId['p2']!.temErro, isFalse);
    expect(r.totalSemFoto, 1);
    expect(r.totalAvisos, 1);
    expect(r.totalErros, 0);
  });

  test('cargo com vice: vice sem nome e sem foto', () {
    final r = verificar(
      [cand('pf', cargo: Cargo.prefeito, nomeVice: '', fotoVice: null)],
      cargos: [Cargo.prefeito.codigo],
    );
    expect(
        tipos(r, 'pf'), {TipoProblema.viceSemNome, TipoProblema.viceSemFoto});
    expect(r.porId['pf']!.semFoto, isTrue,
        reason: 'falta de foto do vice também conta como "sem foto"');
  });

  test('cargo sem vice não cobra dados do vice', () {
    final r = verificar([cand('p1', nomeVice: null, fotoVice: null)],
        cargos: [Cargo.presidente.codigo]);
    expect(r.semProblemas, isTrue);
  });

  test('número com quantidade de dígitos errada é erro', () {
    final r = verificar(
        [...completos, cand('v2', numero: 123, cargo: Cargo.vereador)]);
    expect(tipos(r, 'v2'), {TipoProblema.digitosInvalidos});
    expect(r.porId['v2']!.temErro, isTrue);
  });

  test('número duplicado no mesmo cargo marca os dois candidatos', () {
    final r = verificar([
      ...completos,
      cand('p2', nome: 'Outro', numero: 12),
    ]);
    expect(tipos(r, 'p1'), {TipoProblema.numeroDuplicado});
    expect(tipos(r, 'p2'), {TipoProblema.numeroDuplicado});
    expect(r.porId['p1']!.problemas.single.descricao, contains('Outro'));
  });

  test('mesmo número em zonas de turma diferentes não é duplicado', () {
    final zonas = [Zona.geral, const Zona(1, 'A'), const Zona(2, 'B')];
    final r = verificar([
      cand('p1'),
      cand('va', numero: 1234, cargo: Cargo.vereador, zone: 1),
      cand('vb', numero: 1234, cargo: Cargo.vereador, zone: 2),
    ], zonas: zonas);
    expect(r.semProblemas, isTrue);
  });

  test('nome vazio é erro', () {
    final r = verificar([...completos, cand('p2', nome: ' ', numero: 13)]);
    expect(tipos(r, 'p2'), {TipoProblema.nomeVazio});
  });

  test('cargo fora do evento e zona inexistente geram aviso', () {
    final r = verificar([
      ...completos,
      cand('g1',
          cargo: Cargo.governador, numero: 40, nomeVice: 'V', fotoVice: 'x'),
      cand('p2', numero: 13, zone: 7),
    ]);
    expect(tipos(r, 'g1'), {TipoProblema.cargoForaDoEvento});
    expect(tipos(r, 'p2'), {TipoProblema.zonaInexistente});
  });

  group('cargos sem candidato', () {
    test('com só a zona Geral, verifica a Geral', () {
      final r = verificar([cand('p1')]);
      expect(r.cargosSemCandidato.map((c) => (c.cargo, c.zona)),
          [(Cargo.vereador, Zona.geral)]);
      expect(r.totalErros, 1);
      expect(r.semProblemas, isFalse);
    });

    test('com zonas de turma, verifica cada turma (Geral + turma)', () {
      const a = Zona(1, 'Turma A');
      const b = Zona(2, 'Turma B');
      final r = verificar([
        cand('p1'), // presidente na Geral: vale para todas
        cand('va', numero: 1234, cargo: Cargo.vereador, zone: 1),
      ], zonas: [
        Zona.geral,
        a,
        b
      ]);

      expect(r.cargosSemCandidato.map((c) => (c.cargo, c.zona)),
          [(Cargo.vereador, b)]);
      expect(r.cargosSemCandidato.single.descricao, contains('Turma B'));
    });
  });

  test('ordena candidatos com erro primeiro, depois por cargo e número', () {
    final r = verificar([
      cand('v-semfoto', numero: 1000, cargo: Cargo.vereador, foto: ''),
      cand('p-semfoto', numero: 20, foto: ''),
      cand('p-digitos', numero: 5),
      cand('p-semfoto2', numero: 11, foto: ''),
    ]);
    expect(r.candidatos.map((c) => c.candidato.id),
        ['p-digitos', 'p-semfoto2', 'p-semfoto', 'v-semfoto']);
  });
}
