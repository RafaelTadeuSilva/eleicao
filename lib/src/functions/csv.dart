/// Leitura e geração de CSV (RFC 4180), com detecção do separador.
///
/// O Excel em português usa `;` como separador; arquivos de outras fontes
/// costumam usar `,`. Os dois são aceitos na leitura.
library;

/// Marca de ordem de bytes UTF-8: faz o Excel abrir o arquivo com acentos.
final bomUtf8 = String.fromCharCode(0xFEFF);

/// Uma linha de dados do CSV, com o número da linha no arquivo (1 = cabeçalho).
class LinhaCsv {
  final int numero;
  final List<String> campos;

  const LinhaCsv(this.numero, this.campos);
}

String gerarCsv(List<List<Object?>> linhas, {String separador = ';'}) {
  String campo(Object? valor) {
    final s = valor?.toString() ?? '';
    final precisaAspas = s.contains(separador) ||
        s.contains('"') ||
        s.contains('\n') ||
        s.contains('\r') ||
        s != s.trim();
    return precisaAspas ? '"${s.replaceAll('"', '""')}"' : s;
  }

  return '${linhas.map((l) => l.map(campo).join(separador)).join('\r\n')}\r\n';
}

/// Separador mais frequente na primeira linha (fora de aspas): `;`, `,` ou tab.
String detectarSeparador(String texto) {
  final contagem = {';': 0, ',': 0, '\t': 0};
  var entreAspas = false;
  for (final ch in texto.split('')) {
    if (ch == '"') entreAspas = !entreAspas;
    if (!entreAspas && (ch == '\n' || ch == '\r')) break;
    if (!entreAspas && contagem.containsKey(ch)) {
      contagem[ch] = contagem[ch]! + 1;
    }
  }
  final melhor = contagem.entries.reduce((a, b) => b.value > a.value ? b : a);
  return melhor.value == 0 ? ';' : melhor.key;
}

/// Lê o CSV e devolve as linhas não vazias (inclusive o cabeçalho), cada uma
/// com o número da linha onde começa no arquivo.
List<LinhaCsv> lerCsv(String texto, {String? separador}) {
  if (texto.startsWith(bomUtf8)) texto = texto.substring(1);
  final sep = separador ?? detectarSeparador(texto);

  final linhas = <LinhaCsv>[];
  var campos = <String>[];
  final atual = StringBuffer();
  var entreAspas = false;
  var linhaFisica = 1;
  var inicioLinha = 1;

  void fechaCampo() {
    campos.add(atual.toString());
    atual.clear();
  }

  void fechaLinha() {
    fechaCampo();
    if (campos.any((c) => c.trim().isNotEmpty)) {
      linhas.add(LinhaCsv(inicioLinha, campos));
    }
    campos = <String>[];
  }

  for (var i = 0; i < texto.length; i++) {
    final ch = texto[i];
    if (entreAspas) {
      if (ch == '"') {
        if (i + 1 < texto.length && texto[i + 1] == '"') {
          atual.write('"');
          i++;
        } else {
          entreAspas = false;
        }
      } else {
        if (ch == '\n') linhaFisica++;
        atual.write(ch);
      }
    } else if (ch == '"') {
      entreAspas = true;
    } else if (ch == sep) {
      fechaCampo();
    } else if (ch == '\r' || ch == '\n') {
      if (ch == '\r' && i + 1 < texto.length && texto[i + 1] == '\n') i++;
      fechaLinha();
      linhaFisica++;
      inicioLinha = linhaFisica;
    } else {
      atual.write(ch);
    }
  }
  if (atual.isNotEmpty || campos.isNotEmpty) fechaLinha();
  return linhas;
}

/// Nome de coluna normalizado: minúsculas, sem acentos, espaços viram `_`.
String normalizarCabecalho(String nome) {
  const de = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
  const para = 'aaaaaeeeeiiiiooooouuuucn';
  final buffer = StringBuffer();
  for (final ch in nome.trim().toLowerCase().split('')) {
    final i = de.indexOf(ch);
    buffer.write(i == -1 ? ch : para[i]);
  }
  return buffer.toString().replaceAll(RegExp(r'[\s\-]+'), '_');
}

/// CSV com cabeçalho, para acessar os campos pelo nome da coluna.
class TabelaCsv {
  final List<String> colunas;
  final List<LinhaCsv> linhas;

  TabelaCsv._(this.colunas, this.linhas);

  /// Interpreta [texto]; a primeira linha não vazia é o cabeçalho.
  factory TabelaCsv.ler(String texto) {
    final todas = lerCsv(texto);
    if (todas.isEmpty) return TabelaCsv._(const [], const []);
    return TabelaCsv._(
      todas.first.campos.map(normalizarCabecalho).toList(),
      todas.skip(1).toList(),
    );
  }

  bool temColuna(String nome) => colunas.contains(nome);

  /// Valor da coluna [nome] na [linha], sem espaços nas pontas ('' se a
  /// coluna não existir).
  String valor(LinhaCsv linha, String nome) {
    final i = colunas.indexOf(nome);
    if (i == -1 || i >= linha.campos.length) return '';
    return linha.campos[i].trim();
  }
}
