enum TipoEleicaoModalidade {
  politica(1, 'Política'),
  cipa(2, 'CIPA'),
  esportes(3, 'Esportes - Melhores Jogadores');

  const TipoEleicaoModalidade(this.codigo, this.descricao);
  final int codigo;
  final String descricao;

  static TipoEleicaoModalidade getByCodigo(int? codigo) =>
      TipoEleicaoModalidade.values.firstWhere(
        (e) => e.codigo == codigo,
        orElse: () => TipoEleicaoModalidade.politica,
      );
}

enum Cargo {
  // Política
  presidente(
    1,
    'Presidente da Câmara',
    TipoEleicaoModalidade.politica,
    digitosPadrao: 2,
  ),
  prefeito(
    2,
    'Prefeito',
    TipoEleicaoModalidade.politica,
    temVice: true,
    digitosPadrao: 2,
  ),
  senador(
    3,
    'Senador',
    TipoEleicaoModalidade.politica,
    digitosPadrao: 3,
  ),
  vereador(
    4,
    'Vereador',
    TipoEleicaoModalidade.politica,
    digitosPadrao: 4,
  ),
  deputadoEstadual(
    5,
    'Deputado Estadual',
    TipoEleicaoModalidade.politica,
    digitosPadrao: 5,
  ),
  deputadoFederal(
    6,
    'Deputado Federal',
    TipoEleicaoModalidade.politica,
    digitosPadrao: 4,
  ),
  governador(
    7,
    'Governador',
    TipoEleicaoModalidade.politica,
    temVice: true,
    digitosPadrao: 2,
  ),

  // CIPA
  cipaRepresentante(10, 'Representante da CIPA', TipoEleicaoModalidade.cipa),
  cipaPresidente(11, 'Presidente da CIPA', TipoEleicaoModalidade.cipa),
  cipaVicePresidente(12, 'Vice-Presidente da CIPA', TipoEleicaoModalidade.cipa),
  cipaSecretario(13, 'Secretário da CIPA', TipoEleicaoModalidade.cipa),
  cipaSuplente(14, 'Suplente da CIPA', TipoEleicaoModalidade.cipa),

  // Esportes (Até 10 modalidades)
  futsal(20, 'Melhor Jogador - Futsal', TipoEleicaoModalidade.esportes),
  futebol(21, 'Melhor Jogador - Futebol', TipoEleicaoModalidade.esportes),
  handebol(22, 'Melhor Jogador - Handebol', TipoEleicaoModalidade.esportes),
  volei(23, 'Melhor Jogador - Vôlei', TipoEleicaoModalidade.esportes),
  basquete(24, 'Melhor Jogador - Basquete', TipoEleicaoModalidade.esportes),
  queimada(25, 'Melhor Jogador - Queimada', TipoEleicaoModalidade.esportes),
  tenisDeMesa(
      26, 'Melhor Jogador - Tênis de Mesa', TipoEleicaoModalidade.esportes),
  xadrez(27, 'Melhor Jogador - Xadrez', TipoEleicaoModalidade.esportes),
  atletismo(28, 'Melhor Jogador - Atletismo', TipoEleicaoModalidade.esportes),
  natacao(29, 'Melhor Jogador - Natação', TipoEleicaoModalidade.esportes);

  const Cargo(
    this.codigo,
    this.descricao,
    this.modalidade, {
    this.temVice = false,
    this.digitosPadrao = 2,
  });

  final int codigo;
  final String descricao;
  final TipoEleicaoModalidade modalidade;
  final bool temVice;
  final int digitosPadrao;

  static Cargo getCargoByCodigo(int codigo) => Cargo.values.firstWhere(
        (e) => e.codigo == codigo,
        orElse: () => Cargo.vereador,
      );

  static Cargo getCargoByDescricao(String descricao) =>
      Cargo.values.firstWhere(
        (e) => e.descricao == descricao,
        orElse: () => Cargo.vereador,
      );

  static List<Cargo> byModalidade(TipoEleicaoModalidade modalidade) =>
      Cargo.values.where((e) => e.modalidade == modalidade).toList();
}
