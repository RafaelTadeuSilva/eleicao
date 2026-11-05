import 'package:eleicao/src/features/cadastro/repositories/liberacao_urna/liberacao_urna_repository.dart';
import 'package:eleicao/src/features/urna/controllers/proximo_eleitor_control.dart';
import 'package:eleicao/src/features/urna/state/votacao_state.dart';
import 'package:eleicao/src/models/liberacao_urna.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_setup.dart';

/// Repositório controlável: só libera depois de [liberarApos] consultas.
class LiberacaoFake implements LiberacaoUrnaRepository {
  int consultas = 0;
  int liberarApos = 1;
  final finalizadas = <LiberacaoUrna>[];
  int? urnaConsultada;

  @override
  Future<LiberacaoUrna?> proximaLiberacao(int urna) async {
    urnaConsultada = urna;
    consultas++;
    if (consultas < liberarApos) return null;
    return LiberacaoUrna(
        id: 'l1', matricula: '0', nome: 'Eleitor', titulo: 0, turma: 0, urna: urna, status: 0);
  }

  @override
  Future<void> finalizaLiberacao(LiberacaoUrna libUrna) async =>
      finalizadas.add(libUrna);

  @override
  Future<void> registra(LiberacaoUrna libUrna) async {}
}

void main() {
  final fake = LiberacaoFake();

  setUp(() async {
    await resetAmbiente(terminal: 7, liberacaoUrna: fake);
    fake
      ..consultas = 0
      ..liberarApos = 1
      ..finalizadas.clear();
  });

  testWidgets('libera uma única vez, finaliza a liberação e para o timer',
      (tester) async {
    final control = ProximoEleitorControl();
    var chamadas = 0;
    control.iniciar(() => chamadas++);

    await tester.pump(const Duration(seconds: 2));
    expect(fake.consultas, 0);

    await tester.pump(const Duration(seconds: 1));
    expect(chamadas, 1);
    expect(fake.urnaConsultada, 7);
    expect(fake.finalizadas.single.id, 'l1');
    expect(eleitorAtual.value?.nome, 'Eleitor');
    expect(control.ativo, isFalse);

    await tester.pump(const Duration(seconds: 9));
    expect(chamadas, 1);
    expect(fake.consultas, 1);
  });

  testWidgets('continua consultando enquanto não há liberação',
      (tester) async {
    fake.liberarApos = 3;
    final control = ProximoEleitorControl();
    var chamadas = 0;
    control.iniciar(() => chamadas++);

    await tester.pump(const Duration(seconds: 6));
    expect(fake.consultas, 2);
    expect(chamadas, 0);

    await tester.pump(const Duration(seconds: 3));
    expect(chamadas, 1);
  });

  testWidgets('parar cancela as consultas', (tester) async {
    fake.liberarApos = 100;
    final control = ProximoEleitorControl();
    control.iniciar(() {});
    await tester.pump(const Duration(seconds: 3));
    control.parar();
    await tester.pump(const Duration(seconds: 30));
    expect(fake.consultas, 1);
  });
}
