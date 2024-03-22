import 'package:eleicao/src/models/aluno.dart';
import 'package:eleicao/src/models/candidato.dart';
import 'package:flutter/material.dart';

final numAtual = ValueNotifier(0);
final tipoEleicao = <int>[2];
final numSeqEleicao = ValueNotifier(tipoEleicao.first);
final numCandidato = ValueNotifier<int?>(null);
final urlImageCandidato = ValueNotifier<String>('');
final eleitorAtual = ValueNotifier<Aluno?>(null);
final candidatoAtual = ValueNotifier<Candidato?>(null);
final listEleitor = <Aluno>[];
final listCandidato = <Candidato>[];
