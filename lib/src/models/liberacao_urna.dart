class LiberacaoUrna {
  final String? id;
  final String matricula;
  final String nome;
  final int titulo;
  final int turma;
  final int urna;
  final int status;

  LiberacaoUrna(
      {this.id,
      required this.matricula,
      required this.nome,
      required this.titulo,
      required this.turma,
      required this.urna,
      required this.status});
}
