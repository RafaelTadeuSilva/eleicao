import 'package:eleicao/src/features/cadastro/state/cadastro_state.dart';
import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/models/aluno.dart';
import 'package:eleicao/src/models/candidato.dart';
import 'package:eleicao/src/models/evento_eleicao.dart';
import 'package:flutter/material.dart';

final numAtual = ValueNotifier(0);
final modalidadeEleicao =
    ValueNotifier<TipoEleicaoModalidade>(TipoEleicaoModalidade.politica);
final tipoEleicao = <int>[4];
final digitosPorCargo = <int, int>{};
final numSeqEleicao = ValueNotifier(tipoEleicao.first);
final numCandidato = ValueNotifier<int?>(null);
final urlImageCandidato = ValueNotifier<String>('');
final urlImageVice = ValueNotifier<String>('');
final eleitorAtual = ValueNotifier<Aluno?>(null);
final candidatoAtual = ValueNotifier<Candidato?>(null);
final listEleitor = <Aluno>[];
final listCandidato = <Candidato>[];
final listApuracao = ValueNotifier(<(String, int)>[]);

// Estado das coleções / evento ativo
final eventoAtualId = ValueNotifier<String>('2026');
final eventoAtualNome = ValueNotifier<String>('Eleição 2026');
final colecaoAlunosAtual = ValueNotifier<String>('Alunos2026');
final colecaoCandidatosAtual = ValueNotifier<String>('Candidatos2026');
final colecaoVotosAtual = ValueNotifier<String>('Votos2026');
final colecaoLiberacaoAtual = ValueNotifier<String>('LiberacaoUrna2026');

int digitosDoCargo(int codigoCargo) {
  return digitosPorCargo[codigoCargo] ??
      Cargo.getCargoByCodigo(codigoCargo).digitosPadrao;
}

EventoEleicao eventoEleicaoAtual() {
  return EventoEleicao(
    id: eventoAtualId.value,
    nome: eventoAtualNome.value,
    colecaoAlunos: colecaoAlunosAtual.value,
    colecaoCandidatos: colecaoCandidatosAtual.value,
    colecaoVotos: colecaoVotosAtual.value,
    colecaoLiberacao: colecaoLiberacaoAtual.value,
    modalidade: modalidadeEleicao.value,
    cargos: List<int>.from(tipoEleicao),
    digitosPorCargo: Map<int, int>.from(digitosPorCargo),
  );
}

void aplicarConfigEleicao({
  required TipoEleicaoModalidade modalidade,
  required List<int> codigosCargos,
  Map<int, int>? mapaDigitos,
}) {
  modalidadeEleicao.value = modalidade;
  if (mapaDigitos != null) {
    digitosPorCargo
      ..clear()
      ..addAll(mapaDigitos);
  }
  tipoEleicao.clear();
  if (codigosCargos.isEmpty) {
    final padrao = Cargo.byModalidade(modalidade).first.codigo;
    tipoEleicao.add(padrao);
  } else {
    tipoEleicao.addAll(codigosCargos.take(10));
  }
  numSeqEleicao.value = tipoEleicao.first;
}

void aplicarEventoEleicao(EventoEleicao evento) {
  eventoAtualId.value = evento.id;
  eventoAtualNome.value = evento.nome;
  colecaoAlunosAtual.value = evento.colecaoAlunos;
  colecaoCandidatosAtual.value = evento.colecaoCandidatos;
  colecaoVotosAtual.value = evento.colecaoVotos;
  colecaoLiberacaoAtual.value = evento.colecaoLiberacao;
  aplicarConfigEleicao(
    modalidade: evento.modalidade,
    codigosCargos: evento.cargos,
    mapaDigitos: evento.digitosPorCargo,
  );

  // Limpa caches em memória para forçar recarregamento da nova coleção
  listEleitor.clear();
  listCandidato.clear();
  listAlunos.value = [];
  listCandidatos.value = [];
  listApuracao.value = [];
}
