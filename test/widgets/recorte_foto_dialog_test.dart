import 'package:eleicao/src/features/cadastro/widgets/recorte_foto_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:material_ui/material_ui.dart';

void main() {
  final foto =
      Uint8List.fromList(img.encodeJpg(img.Image(width: 1200, height: 900)));

  Future<void> abrir(WidgetTester tester, Size janela) async {
    tester.view.physicalSize = janela;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => RecorteFotoDialog.show(context, foto),
            child: const Text('abrir'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('abrir'));
    await tester.pump();
    // A foto é decodificada num isolate: espera de verdade.
    for (var i = 0; i < 50 && find.byType(Slider).evaluate().isEmpty; i++) {
      await tester
          .runAsync(() => Future.delayed(const Duration(milliseconds: 100)));
      await tester.pump();
    }
    await tester.pump();
    expect(find.byType(Slider), findsOneWidget);
  }

  /// Moldura, zoom e botões visíveis, sem sobreposição e sem erro de layout.
  void conferirLayout(WidgetTester tester, Size janela) {
    final tela = Offset.zero & janela;
    bool dentro(Rect r) =>
        tela.contains(r.topLeft) &&
        tela.contains(r.bottomRight - const Offset(1, 1));
    final moldura = tester.getRect(find.byType(InteractiveViewer));
    final slider = tester.getRect(find.byType(Slider));
    for (final alvo in [
      find.byType(InteractiveViewer),
      find.byType(Slider),
      find.byTooltip('Centralizar'),
      find.text('Usar este enquadramento'),
      find.text('Cancelar'),
    ]) {
      final r = tester.getRect(alvo);
      expect(dentro(r), isTrue, reason: '$alvo fora da janela: $r');
    }
    expect(moldura.bottom, lessThanOrEqualTo(slider.top),
        reason: 'moldura $moldura sobre o zoom $slider');
    expect(moldura.width / moldura.height, closeTo(4 / 5, 0.01));
    expect(tester.takeException(), isNull);
  }

  for (final altura in [400.0, 450.0, 500.0, 600.0, 800.0, 1080.0]) {
    testWidgets('diálogo cabe numa janela de ${altura.toInt()} px',
        (tester) async {
      final janela = Size(1280, altura);
      await abrir(tester, janela);
      conferirLayout(tester, janela);
    });
  }

  testWidgets('diminuir a janela mantém o layout e o enquadramento',
      (tester) async {
    await abrir(tester, const Size(1280, 900));
    final grande = tester.getRect(find.byType(InteractiveViewer));

    // Aproxima a foto pela barra de zoom antes de diminuir a janela.
    final slider = tester.getRect(find.byType(Slider));
    await tester
        .tapAt(Offset(slider.left + slider.width * .5, slider.center.dy));
    await tester.pump();
    final zoomAntes = tester.widget<Slider>(find.byType(Slider)).value;
    expect(zoomAntes, greaterThan(2));

    const pequena = Size(1280, 450);
    tester.view.physicalSize = pequena;
    await tester.pump();
    await tester.pump();

    expect(tester.getRect(find.byType(InteractiveViewer)).height,
        lessThan(grande.height));
    conferirLayout(tester, pequena);
    expect(tester.widget<Slider>(find.byType(Slider)).value,
        closeTo(zoomAntes, 0.01));
  });
}
