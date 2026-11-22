import 'package:eleicao/src/functions/recorte_foto.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  const area = Size(280, 350); // 4:5

  group('matrizRecorte / calcularRecorte', () {
    test('foto paisagem centralizada recorta o meio em 4:5', () {
      const imagem = Size(1000, 500);
      final escala = escalaParaCobrir(area, imagem); // 0.7
      final m = matrizRecorte(
        escala: escala,
        tx: (area.width - imagem.width * escala) / 2,
        ty: 0,
        area: area,
        imagem: imagem,
      );
      final r = calcularRecorte(m, area, imagem);
      expect(r.height, closeTo(500, 0.01));
      expect(r.width, closeTo(400, 0.01));
      expect(r.left, closeTo(300, 0.01));
      expect(r.width / r.height, closeTo(proporcaoFotoCandidato, 0.001));
    });

    test('deslocamento é limitado para não deixar borda vazia', () {
      const imagem = Size(800, 1000);
      final escala = escalaParaCobrir(area, imagem) * 2;
      final m = matrizRecorte(
        escala: escala,
        tx: 500, // arrastou demais para a direita
        ty: -99999, // e demais para cima
        area: area,
        imagem: imagem,
      );
      final r = calcularRecorte(m, area, imagem);
      expect(r.left, 0);
      expect(r.bottom, closeTo(imagem.height, 0.01));
      expect(r.width, closeTo(400, 0.01));
      expect(r.height, closeTo(500, 0.01));
    });
  });

  test('gerarRecorte produz JPEG 400x500', () async {
    final origem = img.Image(width: 1200, height: 900);
    final foto = await prepararFoto(img.encodePng(origem));
    expect(foto, isNotNull);
    final bytes =
        await gerarRecorte(foto!, const Rect.fromLTWH(100, 0, 720, 900));
    final saida = img.decodeJpg(bytes)!;
    expect(saida.width, larguraFotoCandidato);
    expect(saida.height, alturaFotoCandidato);
    expect(jpegDataUri(bytes), startsWith('data:image/jpeg;base64,'));
  });

  test('carregarBytesFoto lê data URI', () async {
    final uri = jpegDataUri(img.encodeJpg(img.Image(width: 4, height: 5)));
    final bytes = await carregarBytesFoto(uri);
    expect(img.decodeJpg(bytes!)!.width, 4);
  });
}
