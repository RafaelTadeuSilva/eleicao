import 'package:eleicao/main.dart';
import 'package:eleicao/src/features/cadastro/state/cadastro_state.dart';
import 'package:eleicao/src/models/aluno.dart';
import 'package:flutter/material.dart';

class AlunoControl with ChangeNotifier {
  Future<void> listaAlunos() async {
    listAlunos.value = await alunoRepository.find({});
    listAlunos.notifyListeners();
  }

  Future<Aluno> getById(String id) async {
    return await alunoRepository.findOne(id);
  }

  Future<bool> create(Aluno aluno) async {
    final result = await alunoRepository.create(aluno);
    return result.isNotEmpty;
  }

  Future<bool> update(Aluno aluno) async {
    return await alunoRepository.update(aluno.id, aluno);
  }
}
