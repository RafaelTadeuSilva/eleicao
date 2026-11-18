import 'package:eleicao/src/features/cadastro/pages/candidato_cad_page.dart';
import 'package:eleicao/src/features/cadastro/pages/lista_candidatos_cad_page.dart';
import 'package:eleicao/src/features/cadastro/pages/verificacao_candidatos_page.dart';
import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/features/urna/state/votacao_state.dart';
import 'package:eleicao/src/injector.dart';
import 'package:eleicao/src/models/candidato.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_setup.dart';

void main() {
  setUp(() => resetAmbiente()); // evento: presidente (2 díg.), vereador (4)

  void telaGrande(WidgetTester tester) {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  /// Deixa as operações do Firestore falso e os timers da tela terminarem.
  Future<void> aguarda(WidgetTester tester) async {
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<String> cria(WidgetTester tester, String nome, int numero,
      {Cargo cargo = Cargo.presidente, String foto = ''}) async {
    late String id;
    await tester.runAsync(() async {
      id = await candidatoRepository.create(Candidato(
          numero: numero, nome: nome, urlImage: foto, cargo: cargo, zone: 0));
    });
    return id;
  }

  testWidgets('cadastro de candidato aceita salvar sem foto', (tester) async {
    telaGrande(tester);
    await tester.pumpWidget(const MaterialApp(home: CandidatoCadPage()));
    await aguarda(tester);

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome do Candidato'), 'Ana');
    await tester.enterText(
        find.byWidgetPredicate((w) =>
            w is TextField &&
            (w.decoration?.labelText ?? '').startsWith('Número do Candidato')),
        '12');
    await tester.tap(find.text('Salvar'));
    await aguarda(tester);

    expect(find.text('Imagem é obrigatória'), findsNothing);
    expect(find.textContaining('Salvo sem foto'), findsOneWidget);

    final docs = await tester.runAsync(
        () => firestore.collection(colecaoCandidatosAtual.value).get());
    expect(docs!.docs, hasLength(1));
    expect(docs.docs.single.data()['nome'], 'Ana');
    expect(docs.docs.single.data()['urlImage'], '');
  });

  testWidgets('relatório lista candidatos sem foto e cargos sem candidato',
      (tester) async {
    telaGrande(tester);
    await cria(tester, 'Ana', 12, foto: 'https://x/ana.png');
    await cria(tester, 'Bruno', 13);

    await tester
        .pumpWidget(const MaterialApp(home: VerificacaoCandidatosPage()));
    await aguarda(tester);

    expect(find.text('2 candidatos'), findsOneWidget);
    expect(find.text('Só sem foto (1)'), findsOneWidget);
    expect(find.text('13 - Bruno'), findsOneWidget);
    expect(find.text('Sem foto'), findsOneWidget);
    expect(find.text('12 - Ana'), findsNothing, reason: 'Ana está completa');
    expect(find.text('Cargos sem candidato'), findsOneWidget);
    expect(find.textContaining('Vereador: nenhum candidato'), findsOneWidget);

    await tester.tap(find.text('Só sem foto (1)'));
    await tester.pump();
    expect(find.text('Cargos sem candidato'), findsNothing);
    expect(find.text('Candidatos sem foto (1)'), findsOneWidget);
  });

  testWidgets('tocar no candidato abre o cadastro dele para corrigir',
      (tester) async {
    telaGrande(tester);
    await cria(tester, 'Bruno', 13);
    await tester
        .pumpWidget(const MaterialApp(home: VerificacaoCandidatosPage()));
    await aguarda(tester);

    await tester.tap(find.text('13 - Bruno'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await aguarda(tester);

    expect(find.byType(CandidatoCadPage), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Bruno'), findsOneWidget);
  });

  testWidgets('sem problemas mostra mensagem de tudo certo', (tester) async {
    telaGrande(tester);
    await cria(tester, 'Ana', 12, foto: 'https://x/a.png');
    await cria(tester, 'Bia', 1234,
        cargo: Cargo.vereador, foto: 'https://x/b.png');

    await tester
        .pumpWidget(const MaterialApp(home: VerificacaoCandidatosPage()));
    await aguarda(tester);

    expect(find.text('Nenhum problema encontrado'), findsOneWidget);
  });

  testWidgets('lista de candidatos mostra contador e alerta por candidato',
      (tester) async {
    telaGrande(tester);
    await cria(tester, 'Ana', 12, foto: 'https://x/ana.png');
    await cria(tester, 'Bruno', 13);
    await cria(tester, 'Bia', 1234,
        cargo: Cargo.vereador, foto: 'https://x/b.png');

    await tester.pumpWidget(const MaterialApp(home: ListaCandidatosCadPage()));
    await aguarda(tester);

    expect(find.text('Verificar'), findsOneWidget);
    expect(find.descendant(of: find.byType(Badge), matching: find.text('1')),
        findsOneWidget);
    expect(find.byIcon(Icons.warning), findsOneWidget,
        reason: 'só Bruno (sem foto) tem alerta');

    await tester.tap(find.text('Verificar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await aguarda(tester);
    expect(find.byType(VerificacaoCandidatosPage), findsOneWidget);
  });
}
