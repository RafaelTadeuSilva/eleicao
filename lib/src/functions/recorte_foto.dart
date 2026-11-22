import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

import 'image_helper.dart';

/// Proporção (largura / altura) da foto do candidato: a mesma da moldura
/// da urna (4:5).
const proporcaoFotoCandidato = 4 / 5;

/// Tamanho (em pixels) da foto recortada gravada no banco. Pequeno o
/// bastante para caber em base64 no Firestore (~30-60 KB).
const larguraFotoCandidato = 400;
const alturaFotoCandidato = 500;

/// Maior lado da imagem exibida na tela de recorte. Fotos maiores são
/// reduzidas antes do recorte.
const ladoMaximoRecorte = 1600;

/// Foto pronta para o recorte: orientação EXIF aplicada e tamanho reduzido.
/// As coordenadas do recorte se referem a estes pixels.
class FotoPreparada {
  final Uint8List bytes;
  final int largura;
  final int altura;
  const FotoPreparada(this.bytes, this.largura, this.altura);

  Size get tamanho => Size(largura.toDouble(), altura.toDouble());
}

FotoPreparada? _preparar(Uint8List original) {
  final decodificada = img.decodeImage(original);
  if (decodificada == null) return null;
  var foto = img.bakeOrientation(decodificada);
  final maior = math.max(foto.width, foto.height);
  if (maior > ladoMaximoRecorte) {
    foto = foto.width >= foto.height
        ? img.copyResize(foto, width: ladoMaximoRecorte)
        : img.copyResize(foto, height: ladoMaximoRecorte);
  }
  return FotoPreparada(
    Uint8List.fromList(img.encodeJpg(foto, quality: 90)),
    foto.width,
    foto.height,
  );
}

/// Decodifica a foto (JPG, PNG, WEBP, BMP...) fora da thread da interface.
/// Devolve null se não for uma imagem reconhecida.
Future<FotoPreparada?> prepararFoto(Uint8List original) =>
    compute(_preparar, original);

class _PedidoRecorte {
  final Uint8List bytes;
  final int x, y, largura, altura, larguraFinal, alturaFinal;
  const _PedidoRecorte(this.bytes, this.x, this.y, this.largura, this.altura,
      this.larguraFinal, this.alturaFinal);
}

Uint8List _recortar(_PedidoRecorte p) {
  final foto = img.decodeImage(p.bytes)!;
  final recorte = img.copyCrop(
    foto,
    x: p.x,
    y: p.y,
    width: p.largura,
    height: p.altura,
  );
  final final_ = img.copyResize(
    recorte,
    width: p.larguraFinal,
    height: p.alturaFinal,
    interpolation: img.Interpolation.average,
  );
  return Uint8List.fromList(img.encodeJpg(final_, quality: 85));
}

/// Recorta o retângulo [recorte] (em pixels de [foto]) e redimensiona para
/// [largura]x[altura], em JPEG. Fotos menores que o tamanho final não são
/// ampliadas.
Future<Uint8List> gerarRecorte(
  FotoPreparada foto,
  Rect recorte, {
  int largura = larguraFotoCandidato,
  int altura = alturaFotoCandidato,
}) {
  final w = recorte.width.round().clamp(1, foto.largura).toInt();
  final h = recorte.height.round().clamp(1, foto.altura).toInt();
  final x = recorte.left.round().clamp(0, foto.largura - w).toInt();
  final y = recorte.top.round().clamp(0, foto.altura - h).toInt();
  final fator = math.min(1.0, w / largura);
  return compute(
    _recortar,
    _PedidoRecorte(
      foto.bytes,
      x,
      y,
      w,
      h,
      math.max(1, (largura * fator).round()),
      math.max(1, (altura * fator).round()),
    ),
  );
}

/// Escala horizontal da matriz. Não usa getMaxScaleOnAxis(), que também
/// considera o eixo Z.
double escalaDaMatriz(Matrix4 m) => m.storage[0];

/// Converte a posição/zoom da imagem na área de recorte (matriz do
/// InteractiveViewer, com a imagem em tamanho natural) no retângulo da
/// imagem visível dentro de [area].
Rect calcularRecorte(Matrix4 transformacao, Size area, Size imagem) {
  final escala = escalaDaMatriz(transformacao);
  final tx = transformacao.storage[12];
  final ty = transformacao.storage[13];
  final w = math.min(area.width / escala, imagem.width);
  final h = math.min(area.height / escala, imagem.height);
  final left = (-tx / escala).clamp(0.0, imagem.width - w);
  final top = (-ty / escala).clamp(0.0, imagem.height - h);
  return Rect.fromLTWH(left, top, w, h);
}

/// Escala que faz a [imagem] cobrir toda a [area].
double escalaParaCobrir(Size area, Size imagem) =>
    math.max(area.width / imagem.width, area.height / imagem.height);

/// Matriz que mostra a imagem com [escala] e deslocamento ([tx], [ty]),
/// ajustando o deslocamento para não deixar bordas vazias na [area].
/// O eixo Z recebe a mesma escala, como o InteractiveViewer faz no zoom.
Matrix4 matrizRecorte({
  required double escala,
  required double tx,
  required double ty,
  required Size area,
  required Size imagem,
}) {
  final minX = area.width - imagem.width * escala;
  final minY = area.height - imagem.height * escala;
  final x = tx.clamp(math.min(minX, 0.0), 0.0).toDouble();
  final y = ty.clamp(math.min(minY, 0.0), 0.0).toDouble();
  return Matrix4.diagonal3Values(escala, escala, escala)
    ..setTranslationRaw(x, y, 0);
}

/// Lê a foto atual (data URI, base64, URL ou arquivo local) para recortar.
Future<Uint8List?> carregarBytesFoto(String foto) async {
  final ref = foto.trim();
  if (ref.isEmpty) return null;
  try {
    if (ref.startsWith('data:image')) {
      final virgula = ref.indexOf(',');
      if (virgula == -1) return null;
      return base64Decode(ref.substring(virgula + 1));
    }
    if (ref.startsWith('base64:')) {
      return base64Decode(ref.substring('base64:'.length));
    }
    if (ref.startsWith('http')) {
      final resposta = await http
          .get(Uri.parse(normalizeImageUrl(ref)))
          .timeout(const Duration(seconds: 30));
      if (resposta.statusCode == 200 && resposta.bodyBytes.isNotEmpty) {
        return resposta.bodyBytes;
      }
      return null;
    }
    final arquivo = File(ref);
    if (await arquivo.exists()) return await arquivo.readAsBytes();
  } catch (e) {
    debugPrint('Erro ao carregar foto para recorte: $e');
  }
  return null;
}

/// JPEG em data URI, formato que o cadastro grava direto no banco.
String jpegDataUri(Uint8List bytes) =>
    'data:image/jpeg;base64,${base64Encode(bytes)}';
