import 'package:eleicao/src/features/cadastro/controllers/verificacao_candidatos.dart';
import 'package:eleicao/src/features/cadastro/state/cadastro_state.dart';
import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/features/urna/state/votacao_state.dart';
import 'package:eleicao/src/injector.dart';
import 'package:eleicao/src/models/candidato.dart';
import 'package:flutter/material.dart';

class CandidatoControl extends ChangeNotifier {
  CandidatoControl();

  Future<void> listaCandidatos() async {
    listCandidatos.value = await candidatoRepository.find({});
    listCandidatos.notifyListeners();
  }

  Future<Candidato?> getById(String id) async {
    return await candidatoRepository.findOne(id);
  }

  Future<Candidato?> getByNumero(int numero) async {
    final list = await candidatoRepository.find({'numero': numero});
    return list.firstOrNull;
  }

  Future<Candidato?> verificarNumeroDuplicado({
    required int numero,
    required Cargo cargo,
    required int zone,
    String? ignorarId,
  }) async {
    final todos = await candidatoRepository.find({});
    listCandidatos.value = todos;
    return numeroDuplicado(todos,
        numero: numero, cargo: cargo, zone: zone, ignorarId: ignorarId);
  }

  /// Candidato que conflita com o número informado: mesmo cargo e número,
  /// em zonas que aparecem juntas em alguma urna (mesma zona, ou uma delas
  /// é a Geral, que aparece em todas).
  static Candidato? numeroDuplicado(
    Iterable<Candidato> candidatos, {
    required int numero,
    required Cargo cargo,
    required int zone,
    String? ignorarId,
  }) {
    return candidatos.where((c) {
      if (ignorarId != null && c.id == ignorarId) return false;
      final mesmaZona = c.zone == 0 || zone == 0 || c.zone == zone;
      return c.cargo == cargo && c.numero == numero && mesmaZona;
    }).firstOrNull;
  }

  Future<bool> create(Candidato candidato) async {
    final result = await candidatoRepository.create(candidato);
    return result.isNotEmpty;
  }

  Future<bool> update(Candidato candidato) async {
    return await candidatoRepository.update(candidato.id, candidato);
  }

  /// Carrega os candidatos da eleição ativa e procura problemas de cadastro
  /// (sem foto, número duplicado, dígitos errados etc.).
  Future<ResultadoVerificacao> verificarCandidatos() async {
    await listaCandidatos();
    return VerificacaoCandidatos.verificar(
      listCandidatos.value,
      cargos: tipoEleicao,
      digitosDoCargo: digitosDoCargo,
      zonas: zonasEleitorais.value,
    );
  }

  Future<bool> delete(String id) async {
    final removed = await candidatoRepository.delete(id);
    if (removed) {
      await listaCandidatos();
    }
    return removed;
  }
}
