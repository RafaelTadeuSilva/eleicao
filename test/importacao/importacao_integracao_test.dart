import 'package:eleicao/src/features/cadastro/controllers/aluno_control.dart';
import 'package:eleicao/src/features/cadastro/controllers/candidato_control.dart';
import 'package:eleicao/src/features/cadastro/importacao/aplicar_importacao.dart';
import 'package:eleicao/src/features/cadastro/importacao/plano_importacao.dart';
import 'package:eleicao/src/features/cadastro/widgets/planilha_csv_menu.dart';
import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/functions/csv.dart';
import 'package:eleicao/src/injector.dart';
import 'package:eleicao/src/models/aluno.dart';
import 'package:eleicao/src/models/candidato.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_setup.dart';

void main() {
  setUp(() => resetAmbiente()); // evento: presidente (2 díg.), vereador (4)

  test('candidatos: baixar, editar no "Excel" e enviar de volta', () async {
    final control = CandidatoControl();
    await candidatoRepository.create(Candidato(
        numero: 12,
        nome: 'Ana',
        urlImage: '',
        cargo: Cargo.presidente,
        zone: 0));
    await candidatoRepository.create(Candidato(
        numero: 1234,
        nome: 'Bruno',
        urlImage: '',
        cargo: Cargo.vereador,
        zone: 0));
    final [ana, bruno] = await candidatoRepository.find({});

    // Simula a edição: muda o nome da Ana, exclui o Bruno e inclui a Carla
    // (sem id e sem foto).
    final linhas =
        lerCsv(await control.exportarCsv()).map((l) => [...l.campos]).toList();
    final colunas = linhas.first;
    List<String> linhaDe(String nome) =>
        linhas.firstWhere((l) => l[colunas.indexOf('nome')] == nome);
    linhaDe('Ana')[colunas.indexOf('nome')] = 'Ana Paula';
    linhaDe('Bruno')[colunas.indexOf('acao')] = 'EXCLUIR';
    linhas.add([
      for (final c in colunas)
        switch (c) {
          'numero' => '5678',
          'nome' => 'Carla',
          'cargo' => 'Vereador',
          _ => '',
        }
    ]);
    final editado = gerarCsv(linhas);

    final plano = await control.planejarImportacao(editado);
    expect(plano.erros, isEmpty, reason: plano.erros.join('\n'));
    expect(plano.contar(AcaoImportacao.atualizar), 1);
    expect(plano.contar(AcaoImportacao.excluir), 1);
    expect(plano.contar(AcaoImportacao.criar), 1);

    final resultado = await control.aplicarImportacao(plano);
    expect(resultado.erro, isNull);
    expect(resultado.aplicados, 3);

    final finais = await candidatoRepository.find({});
    expect(finais.map((c) => c.nome).toSet(), {'Ana Paula', 'Carla'});
    expect(finais.firstWhere((c) => c.nome == 'Ana Paula').id, ana.id);
    expect(finais.any((c) => c.id == bruno.id), isFalse);
    expect(finais.firstWhere((c) => c.nome == 'Carla').id, isNotEmpty,
        reason: 'id gerado pelo Firebase');

    // Uma nova planilha baixada já reflete tudo: reenviá-la não muda nada.
    final novaPlanilha =
        await control.planejarImportacao(await control.exportarCsv());
    expect(novaPlanilha.erros, isEmpty);
    expect(novaPlanilha.podeAplicar, isFalse);

    // Reenviar por engano o arquivo editado é bloqueado: o Bruno já não
    // existe e a Carla (sem id) duplicaria o número 5678.
    final repetido = await control.planejarImportacao(editado);
    expect(repetido.podeAplicar, isFalse);
    expect(repetido.erros.map((e) => e.texto), [
      contains('não existe nesta eleição'),
      contains('já pertence a "Carla"'),
    ]);
  });

  test('alunos: importar cria, altera e exclui pela matrícula', () async {
    final control = AlunoControl();
    await alunoRepository
        .create(Aluno(id: '1001', nome: 'Ana', turma: 0, titulo: 1));
    await alunoRepository
        .create(Aluno(id: '1002', nome: 'Bia', turma: 0, titulo: 2));

    final plano =
        await control.planejarImportacao('matricula;nome;turma;titulo;acao\n'
            '1001;Ana Maria;0;1;\n'
            '1002;;;;excluir\n'
            '1003;Caio;Geral;3;');
    expect(plano.erros, isEmpty);
    final resultado = await control.aplicarImportacao(plano);
    expect(resultado.aplicados, 3);

    final alunos = await alunoRepository.find({});
    expect(alunos.map((a) => '${a.id}:${a.nome}').toList(),
        ['1001:Ana Maria', '1003:Caio']);
  });

  test('aplicarPlano não grava nada se houver erros e para no 1º erro',
      () async {
    const comErro =
        PlanoImportacao<int>(itens: [], erros: [MensagemImportacao(2, 'x')]);
    var chamadas = 0;
    Future<void> conta(int _) async => chamadas++;
    final r1 = await aplicarPlano(comErro,
        criar: conta, atualizar: conta, excluir: conta);
    expect(r1.aplicados, 0);
    expect(r1.erro, isNotNull);
    expect(chamadas, 0);

    const plano = PlanoImportacao<int>(itens: [
      ItemImportacao(
          linha: 2, acao: AcaoImportacao.criar, registro: 1, descricao: 'a'),
      ItemImportacao(
          linha: 3, acao: AcaoImportacao.criar, registro: 2, descricao: 'b'),
      ItemImportacao(
          linha: 4, acao: AcaoImportacao.criar, registro: 3, descricao: 'c'),
    ]);
    final r2 = await aplicarPlano(plano, criar: (n) async {
      if (n == 2) throw Exception('sem rede');
    }, atualizar: conta, excluir: conta);
    expect(r2.aplicados, 1);
    expect(r2.erro.toString(), contains('sem rede'));
  });

  group('PlanilhaCsvMenu', () {
    Future<void> monta(WidgetTester tester,
        {required String arquivo, List<String>? salvos}) async {
      final control = CandidatoControl();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          appBar: AppBar(actions: [
            PlanilhaCsvMenu(
              nomeArquivo: 'candidatos.csv',
              exportar: control.exportarCsv,
              planejar: control.planejarImportacao,
              aplicar: control.aplicarImportacao,
              abrirArquivo: () async => arquivo,
              salvarArquivo: (nome, csv) async {
                salvos?.addAll([nome, csv]);
                return 'C:/tmp/$nome';
              },
            ),
          ]),
        ),
      ));
    }

    Future<void> escolhe(WidgetTester tester, String opcao) async {
      await tester.tap(find.byIcon(Icons.table_view));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await tester.tap(find.text(opcao));
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();
    }

    testWidgets('baixar entrega o CSV para salvar e avisa o caminho',
        (tester) async {
      final salvos = <String>[];
      await monta(tester, arquivo: '', salvos: salvos);
      await escolhe(tester, 'Baixar planilha (CSV)');

      expect(salvos.first, 'candidatos.csv');
      expect(salvos.last, startsWith('id;numero;nome;cargo'));
      expect(
          find.text('Planilha salva em C:/tmp/candidatos.csv'), findsOneWidget);
    });

    testWidgets('enviar mostra a prévia e só grava ao confirmar',
        (tester) async {
      await monta(tester, arquivo: 'numero;nome;cargo\n12;Ana;1\n1234;Bruno;4');
      await escolhe(tester, 'Enviar planilha (CSV)');

      expect(find.text('Prévia da importação'), findsOneWidget);
      expect(find.text('Novo: 2'), findsOneWidget);
      expect(find.text('12 - Ana (Presidente da Câmara)'), findsOneWidget);
      var docs = await tester.runAsync(() => candidatoRepository.find({}));
      expect(docs, isEmpty, reason: 'nada gravado antes de confirmar');

      await tester.runAsync(() async {
        await tester.tap(find.text('Aplicar 2 alteração(ões)'));
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      docs = await tester.runAsync(() => candidatoRepository.find({}));
      expect(docs!.map((c) => c.nome), ['Ana', 'Bruno']);
      expect(find.text('Planilha aplicada: 2 alteração(ões).'), findsOneWidget);
    });

    testWidgets('planilha com erro mostra os erros e não deixa aplicar',
        (tester) async {
      await monta(tester, arquivo: 'numero;nome;cargo\n123;Ana;1');
      await escolhe(tester, 'Enviar planilha (CSV)');

      expect(
          find.text('Planilha com erros — nada foi gravado'), findsOneWidget);
      expect(
          find.text(
              'Linha 2: número 123 deve ter 2 dígitos para Presidente da Câmara'),
          findsOneWidget);
      expect(find.textContaining('Aplicar'), findsNothing);
    });
  });
}
