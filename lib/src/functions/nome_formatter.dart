import 'package:flutter/services.dart';

/// Formata nomes digitados ou colados: troca `_` por espaço e converte
/// tudo para maiúsculas. Mantém a posição do cursor, pois as trocas não
/// alteram o tamanho do texto.
class NomeInputFormatter extends TextInputFormatter {
  const NomeInputFormatter();

  static String formatar(String texto) =>
      texto.replaceAll('_', ' ').toUpperCase();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final texto = formatar(newValue.text);
    if (texto.length != newValue.text.length) {
      // toUpperCase pode mudar o tamanho (ex.: 'ß' → 'SS'); cursor no fim.
      return TextEditingValue(
        text: texto,
        selection: TextSelection.collapsed(offset: texto.length),
      );
    }
    return newValue.copyWith(text: texto);
  }
}
