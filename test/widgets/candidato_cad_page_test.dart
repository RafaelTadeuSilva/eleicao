import 'package:eleicao/src/features/cadastro/pages/candidato_cad_page.dart';
import 'package:eleicao/src/features/cadastro/widgets/foto_candidato_field.dart';
import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/injector.dart';
import 'package:eleicao/src/models/candidato.dart';
import 'package:material_ui/material_ui.dart';
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

  Cargo cargoNoCombo(WidgetTester tester) => tester
      .widget<DropdownButtonFormField<Cargo>>(
          find.byType(DropdownButtonFormField<Cargo>))
      .initialValue!;

  testWidgets('CandidatoCadPage só oferece os cargos do evento ativo',
      (tester) async {
    telaGrande(tester);
    await tester.pumpWidget(const MaterialApp(home: CandidatoCadPage()));
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byType(DropdownButtonFormField<Cargo>));
    await tester.pumpAndSettle();

    final opcoes = tester
        .widgetList<DropdownMenuItem<Cargo>>(
            find.byType(DropdownMenuItem<Cargo>))
        .map((i) => i.value)
        .toSet();
    expect(opcoes, {Cargo.presidente, Cargo.vereador});
  });

  testWidgets('CandidatoCadPage sugere o cargo do último candidato salvo',
      (tester) async {
    telaGrande(tester);
    await tester.pumpWidget(const MaterialApp(home: CandidatoCadPage()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(cargoNoCombo(tester), Cargo.presidente);

    await tester.tap(find.byType(DropdownButtonFormField<Cargo>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Vereador').last);
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome do Candidato'), 'Bruno');
    await tester.enterText(
        find.byWidgetPredicate((w) =>
            w is TextField &&
            (w.decoration?.labelText ?? '').startsWith('Número do Candidato')),
        '1234');
    await tester.runAsync(() async {
      await tester.tap(find.text('Salvar'));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    expect(find.text('Salvo sem foto. Adicione a foto depois; ela aparece '
        'em "Verificar candidatos".'), findsOneWidget);

    // Novo cadastro já abre no cargo usado por último.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(const MaterialApp(home: CandidatoCadPage()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(cargoNoCombo(tester), Cargo.vereador);
  });
}
