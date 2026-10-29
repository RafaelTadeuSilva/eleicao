import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:eleicao/src/functions/image_helper.dart';
import 'package:eleicao/src/repositories/api_storage.dart';

class ApiStorageBase64 implements ApiStorage {
  @override
  Future<String> uploadFile(String origem, String destino) async {
    final trimmed = origem.trim();
    if (trimmed.isEmpty) return '';

    // Se já for Base64 ou URL externa (http/https/Google Drive), apenas normaliza
    if (trimmed.startsWith('data:image') || trimmed.startsWith('base64:')) {
      return trimmed;
    }
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return normalizeImageUrl(trimmed);
    }

    try {
      final file = File(trimmed);
      if (!await file.exists()) {
        return '';
      }

      final originalBytes = await file.readAsBytes();

      // Redimensiona a imagem para largura de 320px para ficar leve (~30-50KB) no Firestore
      final codec = await ui.instantiateImageCodec(
        originalBytes,
        targetWidth: 320,
      );
      final frame = await codec.getNextFrame();
      final byteData = await frame.image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      frame.image.dispose();

      if (byteData != null) {
        final resizedBytes = byteData.buffer.asUint8List();
        return 'data:image/png;base64,${base64Encode(resizedBytes)}';
      }

      return 'data:image/jpeg;base64,${base64Encode(originalBytes)}';
    } catch (e) {
      return '';
    }
  }
}

