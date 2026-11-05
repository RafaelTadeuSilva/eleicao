import 'package:eleicao/src/features/cadastro/importacao/aluno_csv.dart';
import 'package:eleicao/src/features/cadastro/importacao/aplicar_importacao.dart';
import 'package:eleicao/src/features/cadastro/importacao/plano_importacao.dart';
import 'package:eleicao/src/features/cadastro/state/cadastro_state.dart';
import 'package:eleicao/src/injector.dart';
import 'package:eleicao/src/models/aluno.dart';
import 'package:flutter/material.dart';

class AlunoControl with ChangeNotifier {
  Future<void> listaAlunos() async {
    listAlunos.value = await alunoRepository.find({});
    listAlunos.notifyListeners();
  }

  Future<Aluno> getById(String id) async {
    final aluno = await alunoRepository.findOne(id);
    return aluno!;
  }

  Future<bool> create(Aluno aluno) async {
    final result = await alunoRepository.create(aluno);
    return result.isNotEmpty;
  }

  Future<bool> update(Aluno aluno) async {
    return await alunoRepository.update(aluno.id, aluno);
  }

  /// Planilha CSV com os alunos da eleição ativa.
  Future<String> exportarCsv() async => AlunoCsv.exportar(
        await alunoRepository.find({}),
        zonas: zonasEleitorais.value,
      );

  /// Analisa a planilha contra os alunos atuais, sem gravar nada.
  Future<PlanoImportacao<Aluno>> planejarImportacao(String csv) async =>
      AlunoCsv.planejar(
        csv,
        existentes: await alunoRepository.find({}),
        zonas: zonasEleitorais.value,
      );

  Future<ResultadoImportacao> aplicarImportacao(
      PlanoImportacao<Aluno> plano) async {
    final resultado = await aplicarPlano(
      plano,
      criar: alunoRepository.create,
      atualizar: (a) => alunoRepository.update(a.id, a),
      excluir: (a) => alunoRepository.delete(a.id),
    );
    await listaAlunos();
    return resultado;
  }
}
