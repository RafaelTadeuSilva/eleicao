import 'package:eleicao/src/models/aluno.dart';
import 'package:eleicao/src/models/candidato.dart';
import 'package:flutter/material.dart';

final listTurmas = [
  (0, 'Geral'),
  (1, '1° Turma A'),
  (2, '1° Turma B'),
  (3, '1° Turma C'),
  (4, '2° Turma A'),
  (5, '2° Turma B'),
  (6, '2° Turma C'),
  (7, '3° Turma A'),
  (8, '3° Turma B'),
  (9, '4° Turma A'),
  (10, '4° Turma B'),
  (11, '4° Turma C'),
  (12, '5° Turma A'),
  (13, '5° Turma B'),
  (14, '5° Turma C'),
];

(int, String)? getTurmaByName(String name) =>
    listTurmas.where((e) => e.$2 == name).firstOrNull;

(int, String)? findTurmaByName(String name) =>
    listTurmas.where((e) => e.$2.contains(name)).firstOrNull;

(int, String) getTurmaById(int? id) => listTurmas.firstWhere((e) => e.$1 == id);

final listAlunos = ValueNotifier(<Aluno>[]);

final listCandidatos = ValueNotifier(<Candidato>[]);
// final alunoAtual = ValueNotifier<Aluno?>(null);
// final alunoAtual = ValueNotifier<Aluno?>(null);
