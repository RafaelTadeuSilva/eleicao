import 'package:eleicao/src/features/urna/controllers/votacao_control.dart';
import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/features/urna/state/votacao_state.dart';
import 'package:eleicao/src/functions/audio_player.dart';
import 'package:eleicao/src/injector.dart';
import 'package:eleicao/src/models/candidato.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_setup.dart';

Future<void> cadastraCandidatos() async {
  Future<void> c(String id, String nome, int numero, Cargo cargo,
          {int zone = 0}) =>
      candidatoRepository.create(Candidato(
          id: id,
          numero: numero,
          nome: nome,
          urlImage: 'https://x/$id.png',
          urlImageVice: cargo.temVice ? 'https://x/vice.png' : null,
          cargo: cargo,
          zone: zone));

  await c('100_1', 'Ana', 12, Cargo.presidente);
  await c('200_4', 'Bruno', 1234, Cargo.vereador);
  await c('400_4', 'Diego', 12, Cargo.vereador); // mesmo número, outro cargo
  await c('500_1', 'Eva', 45, Cargo.presidente, zone: 1);
}

Future<VotacaoControl> criaControl() async {
  final control = VotacaoControl();
  await control.carregaListaCandidatos();
  return control;
}

void digita(VotacaoControl control, String numeros) {
  for (final d in numeros.split('')) {
    control.carregaCandidato(int.parse(d));
  }
}

void main() {
  setUp(() async {
    await resetAmbiente();
    await cadastraCandidatos();
  });

  group('digitação do número', () {
    test('acumula dígitos e toca o som da tecla', () async {
      final control = await criaControl();
      digita(control, '1');
      expect(numCandidato.value, 1);
      expect(numAtual.value, 1);
      expect(candidatoAtual.value, isNull);
      expect(fakeSound.played, [AudioFiles.tecla]);
    });

    test('ao completar os dígitos do cargo busca o candidato', () async {
      final control = await criaControl();
      digita(control, '12');
      expect(candidatoAtual.value?.nome, 'Ana');
      expect(urlImageCandidato.value, 'https://x/100_1.png');
    });

    test('não confunde candidatos de cargos diferentes com mesmo número',
        () async {
      final control = await criaControl();
      digita(control, '12');
      expect(candidatoAtual.value?.cargo, Cargo.presidente);
    });

    test('dígitos além do limite do cargo são ignorados', () async {
      final control = await criaControl();
      digita(control, '129');
      expect(numCandidato.value, 12);
      expect(candidatoAtual.value?.nome, 'Ana');
      expect(fakeSound.played, hasLength(2));
    });

    test(
      'numAtual não ultrapassa a quantidade de dígitos do cargo',
      () async {
        final control = await criaControl();
        digita(control, '129');
        expect(numAtual.value, 2);
      },
    );

    test('número inexistente não seleciona candidato', () async {
      final control = await criaControl();
      digita(control, '99');
      expect(numAtual.value, 2);
      expect(candidatoAtual.value, isNull);
    });

    test('corrige limpa número, imagem e candidato', () async {
      final control = await criaControl();
      digita(control, '12');
      control.corrige();
      expect(numCandidato.value, isNull);
      expect(numAtual.value, 0);
      expect(candidatoAtual.value, isNull);
      expect(urlImageCandidato.value, '');
      expect(urlImageVice.value, '');
    });
  });

  group('zona eleitoral', () {
    test('urna da zona Geral só enxerga candidatos da zona Geral', () async {
      final control = await criaControl();
      expect(
          listCandidato.map((e) => e.nome).toSet(), {'Ana', 'Bruno', 'Diego'});
      digita(control, '45');
      expect(candidatoAtual.value, isNull);
    });

    test('urna da zona N enxerga candidatos da zona Geral e da zona N',
        () async {
      await prefs.setInt('zone', 1);
      final control = await criaControl();
      expect(listCandidato.map((e) => e.nome).toSet(),
          {'Ana', 'Bruno', 'Diego', 'Eva'});
      digita(control, '45');
      expect(candidatoAtual.value?.nome, 'Eva');
    });

    test('urna de outra zona não enxerga candidatos da zona 1', () async {
      await prefs.setInt('zone', 2);
      await criaControl();
      expect(listCandidato.map((e) => e.nome), isNot(contains('Eva')));
    });

    test('cargosSemCandidato aponta cargos que travariam o eleitor', () async {
      final todos = await candidatoRepository.find({});
      final cargos = [Cargo.presidente.codigo, Cargo.vereador.codigo];

      expect(VotacaoControl.cargosSemCandidato(todos, 0, cargos), isEmpty);
      expect(
          VotacaoControl.cargosSemCandidato(
              todos, 0, [...cargos, Cargo.prefeito.codigo]),
          [Cargo.prefeito]);

      final soZona1 = todos.where((c) => c.zone == 1).toList();
      expect(VotacaoControl.cargosSemCandidato(soZona1, 0, cargos),
          [Cargo.presidente, Cargo.vereador]);
      expect(VotacaoControl.cargosSemCandidato(soZona1, 1, cargos),
          [Cargo.vereador]);
    });
  });

  group('confirmação e gravação', () {
    late BuildContext ctx;

    Future<void> montaTela(WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (context) {
          ctx = context;
          return const SizedBox();
        }),
      ));
    }

    testWidgets('confirmar sem candidato não avança nem grava', (tester) async {
      late VotacaoControl control;
      await tester.runAsync(() async => control = await criaControl());
      await montaTela(tester);

      digita(control, '99');
      control.confirma(ctx);

      expect(control.etapaIndex, 0);
      expect(control.votoAtual, isEmpty);
    });

    testWidgets('percorre todas as etapas, grava os votos e exibe FIM',
        (tester) async {
      late VotacaoControl control;
      await tester.runAsync(() async => control = await criaControl());
      await montaTela(tester);

      // Etapa 1: presidente
      digita(control, '12');
      control.confirma(ctx);
      expect(control.etapaIndex, 1);
      expect(numSeqEleicao.value, Cargo.vereador.codigo);
      expect(numCandidato.value, isNull, reason: 'deve limpar para a etapa 2');
      expect(control.votoAtual, hasLength(1));

      // Etapa 2: vereador
      digita(control, '1234');
      control.confirma(ctx);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('FIM'), findsOneWidget);
      expect(fakeSound.played.last, AudioFiles.confirma);
      expect(control.etapaIndex, 0);
      expect(numSeqEleicao.value, Cargo.presidente.codigo);

      final votos = (await tester.runAsync(
          () => firestore.collection(colecaoVotosAtual.value).get()))!;
      final gravados = votos.docs.map((d) => d.data()).toList()
        ..sort((a, b) => (a['nome'] as String).compareTo(b['nome']));
      expect(gravados, [
        {
          'cargo': Cargo.presidente.codigo,
          'cargoDescricao': 'Presidente da Câmara',
          'candidatoId': '100_1',
          'numero': 12,
          'nome': 'Ana',
          'zone': 0
        },
        {
          'cargo': Cargo.vereador.codigo,
          'cargoDescricao': 'Vereador',
          'candidatoId': '200_4',
          'numero': 1234,
          'nome': 'Bruno',
          'zone': 0
        },
      ]);
      expect(control.votoAtual, isEmpty);

      // Desmonta a árvore antes do timer de 3s que levaria à próxima tela.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 3));
    });
  });
}
