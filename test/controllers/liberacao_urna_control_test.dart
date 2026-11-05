import 'package:eleicao/src/features/cadastro/state/cadastro_state.dart';
import 'package:eleicao/src/features/urna/controllers/liberacao_urna_control.dart';
import 'package:eleicao/src/features/urna/state/votacao_state.dart';
import 'package:eleicao/src/injector.dart';
import 'package:eleicao/src/models/aluno.dart';
import 'package:eleicao/src/models/zona.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_setup.dart';

void main() {
  late LiberacaoUrnaControl control;

  setUp(() async {
    await resetAmbiente();
    control = LiberacaoUrnaControl();
    zonasEleitorais.value = [Zona.geral, const Zona(1, '1º Ano A')];
    await alunoRepository
        .create(Aluno(id: '2024001', nome: 'Ana', turma: 1, titulo: 555));
  });

  test('buscaEleitor preenche nome, matrícula e turma pelo título', () async {
    await control.buscaEleitor('555');
    expect(control.txtNome.text, 'Ana');
    expect(control.txtMatricula.text, '2024001');
    expect(control.txtTurma.text, '1º Ano A');
  });

  test('buscaEleitor com título desconhecido ou vazio limpa os campos',
      () async {
    await control.buscaEleitor('555');
    await control.buscaEleitor('999');
    expect(control.txtNome.text, isEmpty);
    expect(control.txtMatricula.text, isEmpty);

    await control.buscaEleitor('555');
    await control.buscaEleitor('');
    expect(control.txtNome.text, isEmpty);
  });

  test('confirmar registra liberação pendente para a urna', () async {
    control.txtTituloEleitor.text = '555';
    control.txtUrna.text = '3';
    await control.buscaEleitor('555');
    await control.confirmar();

    final snap = await firestore.collection(colecaoLiberacaoAtual.value).get();
    expect(snap.docs, hasLength(1));
    expect(snap.docs.first.data(), {
      'matricula': '2024001',
      'nome': 'Ana',
      'titulo': 555,
      'turma': 1,
      'urna': 3,
      'status': 0,
    });
  });

  test('confirmar com título ou urna inválidos lança FormatException',
      () async {
    control.txtTituloEleitor.text = 'abc';
    control.txtUrna.text = '1';
    expect(control.confirmar(), throwsFormatException);
  });

  test('limpaCampos zera o formulário', () async {
    control.txtUrna.text = '1';
    control.txtTituloEleitor.text = '555';
    await control.buscaEleitor('555');
    control.limpaCampos();
    for (final t in [
      control.txtUrna,
      control.txtTituloEleitor,
      control.txtNome,
      control.txtMatricula,
      control.txtTurma
    ]) {
      expect(t.text, isEmpty);
    }
  });
}
