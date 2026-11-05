import 'dart:async';

import 'package:eleicao/src/features/urna/state/votacao_state.dart';
import 'package:eleicao/src/injector.dart';
import 'package:eleicao/src/models/aluno.dart';

/// Consulta periodicamente se a urna foi liberada para o próximo eleitor.
class ProximoEleitorControl {
  ProximoEleitorControl({this.intervalo = const Duration(seconds: 3)});

  final Duration intervalo;
  Timer? _timer;
  bool _consultando = false;

  bool get ativo => _timer != null;

  /// Inicia a consulta; [onLiberada] é chamado uma única vez quando a urna
  /// for liberada. Chamar novamente reinicia a consulta.
  void iniciar(void Function() onLiberada) {
    parar();
    _timer = Timer.periodic(intervalo, (_) async {
      if (_consultando) return;
      _consultando = true;
      try {
        final urna = prefs.getInt('terminal') ?? 0;
        final proxEleitor =
            await liberacaoUrnaRepository.proximaLiberacao(urna);
        if (proxEleitor == null || !ativo) return;
        parar();
        eleitorAtual.value = Aluno(
            id: proxEleitor.matricula,
            nome: proxEleitor.nome,
            turma: proxEleitor.turma,
            titulo: proxEleitor.titulo);
        await liberacaoUrnaRepository.finalizaLiberacao(proxEleitor);
        onLiberada();
      } finally {
        _consultando = false;
      }
    });
  }

  void parar() {
    _timer?.cancel();
    _timer = null;
  }
}
