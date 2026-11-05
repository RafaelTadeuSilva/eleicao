import 'package:eleicao/src/features/urna/controllers/votacao_control.dart';
import 'package:eleicao/src/features/urna/state/votacao_state.dart';
import 'package:eleicao/src/injector.dart';
import 'package:eleicao/src/models/candidato.dart';
import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/widgets/function_button.dart';
import 'package:eleicao/src/widgets/number_button.dart';
import 'package:eleicao/src/widgets/number_label.dart';
import 'package:eleicao/src/widgets/teclado_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_setup.dart';

Widget app(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  setUp(() => resetAmbiente());

  testWidgets('NumberButton exibe o número e o envia ao ser tocado',
      (tester) async {
    int? recebido;
    await tester.pumpWidget(
        app(NumberButton(number: 7, onPressed: (n) => recebido = n)));
    expect(find.text('7'), findsOneWidget);
    await tester.tap(find.byType(NumberButton));
    expect(recebido, 7);
  });

  testWidgets('FunctionButton exibe o texto e dispara o callback',
      (tester) async {
    var tocou = false;
    await tester.pumpWidget(app(FunctionButton(
        onPressed: () => tocou = true,
        text: 'CONFIRMA',
        backgroundColor: Colors.green)));
    await tester.tap(find.text('CONFIRMA'));
    expect(tocou, isTrue);
  });

  testWidgets('TecladoWidget: digitar, corrigir e ver o candidato selecionado',
      (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    late VotacaoControl control;
    await tester.runAsync(() async {
      await candidatoRepository.create(Candidato(
          id: '1_1',
          numero: 12,
          nome: 'Ana',
          urlImage: '',
          cargo: Cargo.presidente,
          zone: 0));
      control = VotacaoControl();
      await control.carregaListaCandidatos();
    });

    await tester.pumpWidget(app(TecladoWidget(control)));
    expect(find.text('Geral'), findsOneWidget, reason: 'zona 0');
    expect(find.text('Colégio Santa Teresinha'), findsOneWidget);
    expect(find.text(eventoAtualNome.value), findsOneWidget,
        reason: 'nome da eleição vem do evento ativo');

    await tester.tap(find.widgetWithText(NumberButton, '1'));
    await tester.tap(find.widgetWithText(NumberButton, '2'));
    expect(numCandidato.value, 12);
    expect(candidatoAtual.value?.nome, 'Ana');

    await tester.tap(find.text('CORRIGE'));
    expect(numCandidato.value, isNull);
    expect(candidatoAtual.value, isNull);
  });

  testWidgets(
    'NumberLabel não deixa timers ativos após ser descartado',
    (tester) async {
      await tester.pumpWidget(app(const NumberLabel(lbNum: '1')));
      await tester.pumpWidget(const SizedBox());
    },
  );
}
