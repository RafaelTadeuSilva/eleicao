import 'dart:convert';
import 'dart:io';

import 'package:eleicao/src/functions/image_helper.dart';
import 'package:eleicao/src/repositories/storage/api_storage_base64.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeImageUrl', () {
    test('converte link /file/d/ do Google Drive em link direto', () {
      expect(
        normalizeImageUrl(
            'https://drive.google.com/file/d/AbC_12-x/view?usp=sharing'),
        'https://lh3.googleusercontent.com/d/AbC_12-x',
      );
    });

    test('converte links open?id= e uc?export=view&id=', () {
      expect(normalizeImageUrl('https://drive.google.com/open?id=XYZ'),
          'https://lh3.googleusercontent.com/d/XYZ');
      expect(
          normalizeImageUrl('https://drive.google.com/uc?export=view&id=XYZ'),
          'https://lh3.googleusercontent.com/d/XYZ');
    });

    test('mantém outras URLs, apenas removendo espaços', () {
      expect(normalizeImageUrl('  https://site.com/foto.png '),
          'https://site.com/foto.png');
    });
  });

  group('resolveImageProvider', () {
    final pngBase64 = base64Encode([137, 80, 78, 71]);

    test('retorna null para valores nulos ou vazios', () {
      expect(resolveImageProvider(null), isNull);
      expect(resolveImageProvider('   '), isNull);
    });

    test('data URI e prefixo base64: viram MemoryImage', () {
      expect(resolveImageProvider('data:image/png;base64,$pngBase64'),
          isA<MemoryImage>());
      expect(resolveImageProvider('base64:$pngBase64'), isA<MemoryImage>());
    });

    test('base64 inválido retorna null', () {
      expect(resolveImageProvider('data:image/png;base64,%%%'), isNull);
      expect(resolveImageProvider('base64:%%%'), isNull);
    });

    test('URL HTTP vira NetworkImage com link normalizado', () {
      final provider =
          resolveImageProvider('https://drive.google.com/open?id=ABC');
      expect(provider, isA<NetworkImage>());
      expect((provider as NetworkImage).url,
          'https://lh3.googleusercontent.com/d/ABC');
    });

    test('arquivo local existente vira FileImage; inexistente retorna null',
        () async {
      final dir = await Directory.systemTemp.createTemp('eleicao_test');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/foto.png')..writeAsBytesSync([1, 2, 3]);

      expect(resolveImageProvider(file.path), isA<FileImage>());
      expect(resolveImageProvider('${dir.path}/nao_existe.png'), isNull);
    });
  });

  group('ApiStorageBase64.uploadFile', () {
    final storage = ApiStorageBase64();

    test('origem vazia retorna vazio', () async {
      expect(await storage.uploadFile('  ', 'x'), '');
    });

    test('data URI e base64 são mantidos como estão', () async {
      expect(await storage.uploadFile('data:image/png;base64,AAA', 'x'),
          'data:image/png;base64,AAA');
      expect(await storage.uploadFile('base64:AAA', 'x'), 'base64:AAA');
    });

    test('URL externa é normalizada', () async {
      expect(
          await storage.uploadFile(
              'https://drive.google.com/file/d/ID1/view', 'x'),
          'https://lh3.googleusercontent.com/d/ID1');
    });

    test('arquivo inexistente retorna vazio', () async {
      expect(await storage.uploadFile('Z:/nao/existe.png', 'x'), '');
    });
  });
}
