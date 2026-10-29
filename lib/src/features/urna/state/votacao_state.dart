import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/models/aluno.dart';
import 'package:eleicao/src/models/candidato.dart';
import 'package:flutter/material.dart';

final numAtual = ValueNotifier(0);
final modalidadeEleicao =
    ValueNotifier<TipoEleicaoModalidade>(TipoEleicaoModalidade.politica);
final tipoEleicao = <int>[4];
final numSeqEleicao = ValueNotifier(tipoEleicao.first);
final numCandidato = ValueNotifier<int?>(null);
final urlImageCandidato = ValueNotifier<String>('');
final urlImageVice = ValueNotifier<String>('');
final eleitorAtual = ValueNotifier<Aluno?>(null);
final candidatoAtual = ValueNotifier<Candidato?>(null);
final listEleitor = <Aluno>[];
final listCandidato = <Candidato>[];
final listApuracao = ValueNotifier(<(String, int)>[]);

void aplicarConfigEleicao({
  required TipoEleicaoModalidade modalidade,
  required List<int> codigosCargos,
}) {
  modalidadeEleicao.value = modalidade;
  tipoEleicao.clear();
  if (codigosCargos.isEmpty) {
    final padrao = Cargo.byModalidade(modalidade).first.codigo;
    tipoEleicao.add(padrao);
  } else {
    tipoEleicao.addAll(codigosCargos.take(10));
  }
  numSeqEleicao.value = tipoEleicao.first;
}
