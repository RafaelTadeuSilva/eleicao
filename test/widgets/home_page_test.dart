import 'package:eleicao/src/features/cadastro/state/cadastro_state.dart';
import 'package:eleicao/src/features/home/home_page.dart';
import 'package:eleicao/src/features/home/widgets/evento_eleicao_dialog.dart';
import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/features/urna/state/votacao_state.dart';
import 'package:eleicao/src/injector.dart';
import 'package:eleicao/src/models/evento_eleicao.dart';
import 'package:eleicao/src/models/zona.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_setup.dart';

void main() {
  setUp(() => resetAmbiente());

  void telaGrande(WidgetTester tester) {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('HomePage mostra a configuração atual da urna', (tester) async {
    telaGrande(tester);
    await tester.pumpWidget(const MaterialApp(home: HomePage()));

    expect(find.text('Urna Eletrônica'), findsOneWidget);
    expect(find.textContaining(eventoAtualNome.value), findsOneWidget);
    expect(find.textContaining('Zona Eleitoral: Geral'), findsOneWidget);
    expect(find.textContaining('Presidente da Câmara'), findsOneWidget);
    expect(find.textContaining('Vereador'), findsOneWidget);
  });

  group('EventoEleicaoDialog', () {
    Future<void> abre(WidgetTester tester) async {
      telaGrande(tester);
      late List eventos;
      await tester.runAsync(
          () async => eventos = await eventoEleicaoRepository.findAll());
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EventoEleicaoDialog(eventosSalvos: eventos.cast()),
        ),
      ));
    }

    testWidgets('exibe as quatro seções com os dados do evento ativo',
        (tester) async {
      await abre(tester);
      expect(find.text('1. Escolher Eleição / Evento (coleção Eleicoes):'),
          findsOneWidget);
      expect(find.text('2. Modalidade da Eleição:'), findsOneWidget);
      expect(find.textContaining('3. Cargos e Dígitos (2/10)'), findsOneWidget);
      expect(find.text('4. Zonas Eleitorais:'), findsOneWidget);
      expect(find.text('0 - Geral'), findsOneWidget);
    });

    testWidgets('adiciona zona e ativa o evento só neste aparelho',
        (tester) async {
      await abre(tester);

      await tester.enterText(
          find.widgetWithText(TextField, 'Nova zona (ex: 1º Ano A)'),
          '1º Ano A');
      await tester.tap(find.text('Adicionar'));
      await tester.pump();
      expect(find.text('1 - 1º Ano A'), findsOneWidget);

      await tester.runAsync(() async {
        await tester.tap(find.text('Apenas Ativar neste Aparelho'));
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      expect(zonasEleitorais.value, const [Zona.geral, Zona(1, '1º Ano A')]);
      expect(prefs.getStringList('zonas'), ['0:Geral', '1:1º Ano A']);
      expect(tipoEleicao, [Cargo.presidente.codigo, Cargo.vereador.codigo]);
      final noFirebase =
          await tester.runAsync(() => firestore.collection('Eleicoes').get());
      expect(noFirebase!.docs, isEmpty);
    });

    testWidgets('a zona Geral não pode ser removida', (tester) async {
      await abre(tester);
      final chipGeral =
          tester.widget<Chip>(find.widgetWithText(Chip, '0 - Geral'));
      expect(chipGeral.onDeleted, isNull);
    });

    testWidgets('Salvar no Firebase grava o evento na coleção Eleicoes',
        (tester) async {
      await abre(tester);
      await tester.runAsync(() async {
        await tester.tap(find.text('Salvar no Firebase e Ativar'));
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      final doc = await tester.runAsync(() =>
          firestore.collection('Eleicoes').doc(eventoAtualId.value).get());
      expect(doc!.exists, isTrue);
      expect(doc.data()!['zonas'], [
        {'codigo': 0, 'nome': 'Geral'}
      ]);
    });

    Future<void> selecionaNovoEvento(WidgetTester tester) async {
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('+ Criar Novo Evento / Eleição...').last);
      await tester.pumpAndSettle();
    }

    Future<void> tocaSalvar(WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.tap(find.text('Salvar no Firebase e Ativar'));
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();
    }

    final campoCodigo =
        find.widgetWithText(TextField, 'Sufixo / Código (ex: Esportes2026)');

    testWidgets('novo evento sem código não sobrescreve o evento 2026',
        (tester) async {
      await abre(tester);
      await selecionaNovoEvento(tester);
      await tocaSalvar(tester);

      expect(find.text('Informe o Sufixo / Código do evento.'), findsOneWidget);
      final docs =
          await tester.runAsync(() => firestore.collection('Eleicoes').get());
      expect(docs!.docs, isEmpty);
      expect(eventoAtualId.value, 'Teste');
    });

    testWidgets('novo evento com código já existente é recusado',
        (tester) async {
      await abre(tester);
      await selecionaNovoEvento(tester);
      await tester.enterText(campoCodigo, '2025');
      await tocaSalvar(tester);

      expect(find.textContaining('Já existe um evento com o código "2025"'),
          findsOneWidget);
      final docs =
          await tester.runAsync(() => firestore.collection('Eleicoes').get());
      expect(docs!.docs, isEmpty);
    });

    testWidgets('novo evento com código inédito é salvo ao lado dos demais',
        (tester) async {
      await tester.runAsync(() => eventoEleicaoRepository
          .save(EventoEleicao.fromSufixo(sufixo: 'CIPA')));
      await abre(tester);
      await selecionaNovoEvento(tester);
      await tester.enterText(campoCodigo, 'Esportes');
      await tocaSalvar(tester);

      final ids = await tester.runAsync(() async =>
          (await eventoEleicaoRepository.findAll()).map((e) => e.id).toList());
      expect(ids, containsAll(['CIPA', 'Esportes', '2026', '2025']));
    });
  });
}
