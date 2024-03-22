enum Cargo {
  // branco(-1, 'Branco'),
  // nulo(0, 'Nulo'),
  presidente(1, 'Presidente da Câmara'),
  // prefeito(1, 'Prefeito'),
  vereador(2, 'Vereador'),
  // senador(3, 'Senador')
  ;

  const Cargo(this.codigo, this.descricao);
  final int codigo;
  final String descricao;

  static Cargo getCargoByCodigo(int codigo) =>
      Cargo.values.firstWhere((e) => e.codigo == codigo);
}
