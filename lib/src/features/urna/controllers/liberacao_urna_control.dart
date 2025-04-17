import 'package:eleicao/src/features/cadastro/state/cadastro_state.dart';
import 'package:eleicao/src/injector.dart';
import 'package:eleicao/src/models/liberacao_urna.dart';
import 'package:flutter/material.dart';

class LiberacaoUrnaControl {
  final txtTituloEleitor = TextEditingController();
  final txtNome = TextEditingController();
  final txtMatricula = TextEditingController();
  final txtTurma = TextEditingController();
  final txtUrna = TextEditingController();

  Future<void> confirmar() async {
    final titulo = int.parse(txtTituloEleitor.text);
    final urna = int.parse(txtUrna.text);
    final turma = (getTurmaByName(txtTurma.text) ?? listTurmas.first).$1;

    final libUrna = LiberacaoUrna(
      titulo: titulo,
      matricula: txtMatricula.text,
      nome: txtNome.text,
      turma: turma,
      urna: urna,
      status: 0,
    );
    await liberacaoUrnaRepository.registra(libUrna);
  }

  Future<void> buscaEleitor(String value) async {
    if (value.isNotEmpty) {
      final aluno = await alunoRepository.findByTitulo(value);
      if (aluno != null) {
        txtNome.text = aluno.nome;
        txtMatricula.text = aluno.id;
        txtTurma.text = getTurmaById(aluno.turma).$2;
        return;
      }
    }
    limpaEleitor();
  }

  void limpaCampos() {
    txtUrna.clear();
    txtTituloEleitor.clear();
    limpaEleitor();
  }

  void limpaEleitor() {
    txtNome.clear();
    txtMatricula.clear();
    txtTurma.clear();
  }
}
