import 'package:eleicao/main.dart';
import 'package:eleicao/src/features/cadastro/state/cadastro_state.dart';
import 'package:eleicao/src/models/aluno.dart';
import 'package:flutter/material.dart';

class AlunoControl with ChangeNotifier {
  Future<void> listaAlunos() async {
    listAlunos.value = await alunoRepository.find({});
    listAlunos.notifyListeners();
  }

  void salvar(Aluno aluno) async {
    alunoRepository.create(aluno);
  }
}
