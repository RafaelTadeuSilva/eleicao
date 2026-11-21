import 'package:eleicao/src/models/aluno.dart';
import 'package:eleicao/src/models/candidato.dart';
import 'package:eleicao/src/models/zona.dart';
import 'package:material_ui/material_ui.dart';

/// Zonas eleitorais do evento ativo (atualizadas ao trocar de evento).
/// Sempre começa pela zona Geral (0).
final zonasEleitorais = ValueNotifier<List<Zona>>(const [Zona.geral]);

/// Zona com o nome exato informado.
Zona? zonaPorNome(String nome) =>
    zonasEleitorais.value.where((z) => z.nome == nome.trim()).firstOrNull;

/// Primeira zona cujo nome contém o texto (sem diferenciar maiúsculas).
Zona? buscaZonaPorNome(String texto) {
  final t = texto.trim().toLowerCase();
  return zonasEleitorais.value
      .where((z) => z.nome.toLowerCase().contains(t))
      .firstOrNull;
}

/// Zona pelo código; se não existir no evento ativo, devolve "Zona N" para
/// não quebrar telas com dados de outra configuração.
Zona zonaPorCodigo(int? codigo) {
  final c = codigo ?? Zona.geral.codigo;
  return zonasEleitorais.value.where((z) => z.codigo == c).firstOrNull ??
      (c == Zona.geral.codigo ? Zona.geral : Zona(c, 'Zona $c'));
}

final listAlunos = ValueNotifier(<Aluno>[]);

final listCandidatos = ValueNotifier(<Candidato>[]);

/// Cargo do último candidato salvo no cadastro, para sugerir o mesmo cargo
/// no próximo. Fica só em memória: volta a ser nulo ao reabrir o app.
int? ultimoCargoCadastrado;
