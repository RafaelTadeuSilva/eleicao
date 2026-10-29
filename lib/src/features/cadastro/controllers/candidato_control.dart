import 'package:eleicao/src/features/cadastro/controllers/aluno_control.dart';
import 'package:eleicao/src/features/cadastro/state/cadastro_state.dart';
import 'package:eleicao/src/injector.dart';
import 'package:eleicao/src/models/candidato.dart';
import 'package:flutter/material.dart';

class CandidatoControl extends ChangeNotifier {
  CandidatoControl() {
    AlunoControl().listaAlunos();
  }

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
