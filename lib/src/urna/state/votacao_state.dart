import 'package:eleicao/src/urna/enums/cargo.dart';
import 'package:eleicao/src/urna/models/aluno.dart';
import 'package:eleicao/src/urna/models/candidato.dart';
import 'package:flutter/material.dart';

final numAtual = ValueNotifier(0);
final numSeqEleicao = ValueNotifier(1);
final numCandidato = ValueNotifier<String>('');
final urlImageCandidato = ValueNotifier<String>('');
final eleitorAtual =
    ValueNotifier(Aluno(id: '10', nome: 'Aluno10', turma: '6º C'));
final candidatoAtual = ValueNotifier<Candidato?>(null);
final listCandidato = <Candidato>[
  Candidato(
      id: '11',
      nome: 'Aluno1',
      urlImage: 'assets/images/candidato.png',
      cargo: Cargo.prefeito,
      partido: 'Chapa1'),
  Candidato(
      id: '12',
      nome: 'Aluno2',
      urlImage: 'assets/images/candidato.png',
      cargo: Cargo.prefeito,
      partido: 'Chapa2'),
  Candidato(
      id: '13',
      nome: 'Aluno3',
      urlImage: 'assets/images/candidato.png',
      cargo: Cargo.prefeito,
      partido: 'Chapa2'),
  Candidato(
      id: '1111',
      nome: 'Aluno11',
      urlImage: 'assets/images/candidato.png',
      cargo: Cargo.senador,
      partido: 'Chapa1'),
  Candidato(
      id: '1112',
      nome: 'Aluno12',
      urlImage: 'assets/images/candidato.png',
      cargo: Cargo.senador,
      partido: 'Chapa2'),
  Candidato(
      id: '1113',
      nome: 'Aluno13',
      urlImage: 'assets/images/candidato.png',
      cargo: Cargo.senador,
      partido: 'Chapa3'),
  Candidato(
      id: '11111',
      nome: 'Aluno111',
      urlImage: 'assets/images/candidato.png',
      cargo: Cargo.vereador,
      partido: 'Chapa1'),
  Candidato(
      id: '11112',
      nome: 'Aluno112',
      urlImage: 'assets/images/candidato.png',
      cargo: Cargo.vereador,
      partido: 'Chapa2'),
  Candidato(
      id: '11113',
      nome: 'Aluno113',
      urlImage: 'assets/images/candidato.png',
      cargo: Cargo.vereador,
      partido: 'Chapa3'),
];
// final lbNum1 = ValueNotifier('');
// final lbNum2 = ValueNotifier('');
// final lbNum3 = ValueNotifier('');
// final lbNum4 = ValueNotifier('');
// final lbNum5 = ValueNotifier('');
