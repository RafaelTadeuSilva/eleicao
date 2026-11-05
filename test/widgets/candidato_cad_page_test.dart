import 'package:eleicao/src/features/cadastro/pages/candidato_cad_page.dart';
import 'package:eleicao/src/features/cadastro/widgets/foto_candidato_field.dart';
import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/injector.dart';
import 'package:eleicao/src/models/candidato.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_setup.dart';

void main() {
  setUp(() => resetAmbiente());

  void telaGrande(WidgetTester tester) {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('FotoCandidatoField: link do Drive é normalizado no controller',
      (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: FotoCandidatoField(controller: controller, titulo: 'Vice'),
      ),
    ));

    await tester.tap(find.text('Colar Link / Drive'));
    await tester.pumpAndSettle();
    expect(find.text('Link da Foto (Vice)'), findsOneWidget);

    await tester.enterText(
        find.byType(TextField), 'https://drive.google.com/file/d/ABC/view');
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(controller.text, 'https://lh3.googleusercontent.com/d/ABC');
  });

  testWidgets('CandidatoCadPage carrega um candidato existente para edição',
      (tester) async {
    telaGrande(tester);
    late String id;
    await tester.runAsync(() async {
      id = await candidatoRepository.create(Candidato(
          numero: 12,
          nome: 'Ana',
          urlImage: '',
          cargo: Cargo.presidente,
          zone: 0));
    });

    await tester.pumpWidget(MaterialApp(home: CandidatoCadPage(id: id)));
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump();

    expect(find.widgetWithText(TextFormField, 'Ana'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '12'), findsOneWidget);
    expect(find.byType(FotoCandidatoField), findsOneWidget,
        reason: 'presidente não tem vice, então só a foto do candidato');
  });

  testWidgets('CandidatoCadPage valida quantidade de dígitos do cargo',
      (tester) async {
    telaGrande(tester);
    await tester.pumpWidget(const MaterialApp(home: CandidatoCadPage()));
    await tester.pump(const Duration(milliseconds: 100));

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome do Candidato'), 'Ana');
    await tester.enterText(
        find.byWidgetPredicate((w) =>
            w is TextField &&
            (w.decoration?.labelText ?? '').startsWith('Número do Candidato')),
        '123');
    await tester.tap(find.text('Salvar'));
    await tester.pump();

    expect(find.text('Para Presidente da Câmara, informe 2 dígitos'),
        findsOneWidget);
  });
}
