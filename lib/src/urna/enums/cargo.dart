enum Cargo {
  branco(-1, 'Branco'),
  nulo(0, 'Nulo'),
  prefeito(1, 'Prefeito'),
  vereador(2, 'Vereador'),
  senador(3, 'Senador');

  const Cargo(this.codigo, this.descricao);
  final int codigo;
  final String descricao;
}
