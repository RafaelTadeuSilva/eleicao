import 'package:eleicao/src/models/aluno.dart';
import 'package:eleicao/src/models/candidato.dart';
import 'package:flutter/material.dart';

final listTurmas = [
  (1, '1° Turma A'),
  (2, '1° Turma B'),
  (3, '1° Turma C'),
  (4, '2° Turma A'),
  (5, '2° Turma B'),
  (6, '3° Turma A'),
  (7, '3° Turma B'),
  (8, '4° Turma A'),
  (9, '4° Turma B'),
  (10, '4° Turma C'),
  (11, '5° Turma A'),
  (12, '5° Turma B')
];

final listAlunos = ValueNotifier(<Aluno>[]);

final listCandidatos = ValueNotifier(<Candidato>[]);
// final alunoAtual = ValueNotifier<Aluno?>(null);
// final alunoAtual = ValueNotifier<Aluno?>(null);
