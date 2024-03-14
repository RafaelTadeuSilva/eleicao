import 'package:eleicao/src/models/aluno.dart';
import 'package:eleicao/src/models/candidato.dart';
import 'package:flutter/material.dart';

final listTurmas = [
  (1, '6° Turma A'),
  (2, '6° Turma B'),
  (3, '6° Turma C'),
  (4, '7° Turma A'),
  (5, '7° Turma B'),
  (6, '7° Turma C')
];

final listAlunos = ValueNotifier(<Aluno>[]);

final listCandidatos = ValueNotifier(<Candidato>[]);
// final alunoAtual = ValueNotifier<Aluno?>(null);
