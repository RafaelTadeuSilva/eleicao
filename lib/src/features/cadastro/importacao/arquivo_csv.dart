import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:eleicao/src/functions/csv.dart';
import 'package:file_picker/file_picker.dart';

/// Leitura e gravação de arquivos CSV escolhidos pelo usuário.
class ArquivoCsv {
  /// UTF-8 com BOM, para o Excel reconhecer os acentos.
  static Uint8List codificar(String csv) =>
      Uint8List.fromList(utf8.encode('$bomUtf8$csv'));

  /// Aceita UTF-8 (com ou sem BOM) e, como alternativa, o formato do Excel
  /// "CSV (separado por vírgulas)", que grava em Windows-1252/Latin-1.
  static String decodificar(List<int> bytes) {
    String texto;
    try {
      texto = utf8.decode(bytes);
    } on FormatException {
      texto = latin1.decode(bytes);
    }
    return texto.startsWith(bomUtf8) ? texto.substring(1) : texto;
  }

  /// Abre o diálogo de salvar; retorna o caminho escolhido ou null.
  static Future<String?> salvar(String nomeArquivo, String csv) {
    return FilePicker.platform.saveFile(
      dialogTitle: 'Salvar planilha',
      fileName: nomeArquivo,
      type: FileType.custom,
      allowedExtensions: const ['csv'],
      bytes: codificar(csv),
    );
  }

  /// Abre o diálogo para escolher um CSV; retorna o texto ou null.
  static Future<String?> abrir() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Enviar planilha',
      type: FileType.custom,
      allowedExtensions: const ['csv', 'txt'],
      withData: true,
    );
    final arquivo = result?.files.single;
    if (arquivo == null) return null;
    final bytes = arquivo.bytes ??
        (arquivo.path != null ? await File(arquivo.path!).readAsBytes() : null);
    return bytes == null ? null : decodificar(bytes);
  }
}
