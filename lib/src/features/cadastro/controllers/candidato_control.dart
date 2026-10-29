import 'package:eleicao/src/features/cadastro/state/cadastro_state.dart';
import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/injector.dart';
import 'package:eleicao/src/models/candidato.dart';
import 'package:flutter/material.dart';

class CandidatoControl extends ChangeNotifier {
  CandidatoControl();

  Future<void> listaCandidatos() async {
    listCandidatos.value = await candidatoRepository.find({}) ?? [];
    listCandidatos.notifyListeners();
  }

  Future<Candidato?> getById(String id) async {
    return await candidatoRepository.findOne(id);
  }

  Future<Candidato?> getByNumero(int numero) async {
    final list = await candidatoRepository.find({'numero': numero});
    return list?.firstOrNull;
  }

  Future<Candidato?> verificarNumeroDuplicado({
    required int numero,
    required Cargo cargo,
    required int zone,
    String? ignorarId,
  }) async {
    final todos = await candidatoRepository.find({}) ?? [];
    listCandidatos.value = todos;
    return todos.where((c) {
      if (ignorarId != null && c.id == ignorarId) return false;
      final mesmoCargo = c.cargo.codigo == cargo.codigo;
      final mesmoNumero = c.numero == numero;
      final mesmaZona = c.zone == 0 || zone == 0 || c.zone == zone;
      return mesmoCargo && mesmoNumero && mesmaZona;
    }).firstOrNull;
  }

  Future<bool> create(Candidato candidato) async {
    final result = await candidatoRepository.create(candidato);
    return result.isNotEmpty;
  }

  Future<bool> update(Candidato candidato) async {
    return await candidatoRepository.update(candidato.id, candidato);
  }

  Future<bool> delete(String id) async {
    final removed = await candidatoRepository.delete(id);
    if (removed) {
      await listaCandidatos();
    }
    return removed;
  }
}
