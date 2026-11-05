/// Zona eleitoral de um evento.
///
/// A zona 0 ([geral]) vale para todas as urnas (ex.: presidente, eleito por
/// todas as turmas). As demais zonas representam uma turma específica: a urna
/// configurada na zona N mostra os candidatos da zona 0 e da zona N.
class Zona {
  final int codigo;
  final String nome;

  const Zona(this.codigo, this.nome);

  static const geral = Zona(0, 'Geral');

  bool get isGeral => codigo == geral.codigo;

  /// Garante a zona Geral como primeira, remove códigos repetidos e nomes
  /// vazios e ordena pelo código.
  static List<Zona> normalizar(Iterable<Zona> zonas) {
    final porCodigo = <int, Zona>{geral.codigo: geral};
    for (final z in zonas) {
      final nome = z.nome.trim();
      if (z.codigo <= 0 || nome.isEmpty) continue;
      porCodigo.putIfAbsent(z.codigo, () => Zona(z.codigo, nome));
    }
    return porCodigo.values.toList()
      ..sort((a, b) => a.codigo.compareTo(b.codigo));
  }

  /// Próximo código livre para uma nova zona.
  static int proximoCodigo(Iterable<Zona> zonas) =>
      zonas.fold(0, (maior, z) => z.codigo > maior ? z.codigo : maior) + 1;

  Map<String, dynamic> toMap() => {'codigo': codigo, 'nome': nome};

  static Zona? fromMap(Object? map) {
    if (map is! Map) return null;
    final codigo = map['codigo'] is int
        ? map['codigo'] as int
        : int.tryParse(map['codigo']?.toString() ?? '');
    final nome = map['nome']?.toString() ?? '';
    if (codigo == null) return null;
    return Zona(codigo, nome);
  }

  @override
  bool operator ==(Object other) =>
      other is Zona && other.codigo == codigo && other.nome == nome;

  @override
  int get hashCode => Object.hash(codigo, nome);

  @override
  String toString() => 'Zona($codigo, $nome)';
}
