import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

/// Converte links de compartilhamento do Google Drive em links diretos de imagem.
String normalizeImageUrl(String url) {
  final trimmed = url.trim();
  // Formato: https://drive.google.com/file/d/FILE_ID/view?usp=sharing
  final fileDRegex = RegExp(r'drive\.google\.com\/file\/d\/([a-zA-Z0-9_-]+)');
  final matchFileD = fileDRegex.firstMatch(trimmed);
  if (matchFileD != null) {
    final fileId = matchFileD.group(1);
    return 'https://lh3.googleusercontent.com/d/$fileId';
  }

  // Formato: https://drive.google.com/open?id=FILE_ID ou uc?id=FILE_ID
  final idParamRegex = RegExp(r'drive\.google\.com\/.*[?&]id=([a-zA-Z0-9_-]+)');
  final matchIdParam = idParamRegex.firstMatch(trimmed);
  if (matchIdParam != null) {
    final fileId = matchIdParam.group(1);
    return 'https://lh3.googleusercontent.com/d/$fileId';
  }

  return trimmed;
}

/// Retorna o [ImageProvider] adequado para Base64 (Firestore), URL HTTP/Google Drive ou Arquivo Local.
ImageProvider? resolveImageProvider(String? source) {
  if (source == null || source.trim().isEmpty) {
    return null;
  }

  final value = source.trim();

  if (value.startsWith('data:image')) {
    final commaIndex = value.indexOf(',');
    if (commaIndex != -1 && commaIndex + 1 < value.length) {
      try {
        final bytes = base64Decode(value.substring(commaIndex + 1));
        return MemoryImage(bytes);
      } catch (_) {
        return null;
      }
    }
  }

  if (value.startsWith('base64:')) {
    try {
      final bytes = base64Decode(value.substring('base64:'.length));
      return MemoryImage(bytes);
    } catch (_) {
      return null;
    }
  }

  if (value.startsWith('http://') || value.startsWith('https://')) {
    return NetworkImage(normalizeImageUrl(value));
  }

  final file = File(value);
  if (file.existsSync()) {
    return FileImage(file);
  }

  return null;
}

/// Widget de pré-visualização da foto do candidato com fallback seguro.
Widget buildCandidatoPreviewImage(String? source) {
  final provider = resolveImageProvider(source);
  if (provider == null) {
    return Image.asset('assets/images/candidato.png');
  }
  return Image(
    image: provider,
    fit: BoxFit.contain,
    errorBuilder: (context, error, stackTrace) =>
        Image.asset('assets/images/candidato.png'),
  );
}

