import 'package:eleicao/src/models/liberacao_urna.dart';

abstract class LiberacaoUrnaRepository {
  Future<void> registra(LiberacaoUrna libUrna);
  Future<LiberacaoUrna?> proximaLiberacao(int urna);
  Future<void> finalizaLiberacao(LiberacaoUrna libUrna);
}
