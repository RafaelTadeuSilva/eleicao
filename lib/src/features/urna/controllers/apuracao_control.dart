import 'package:eleicao/src/features/urna/state/votacao_state.dart';
import 'package:eleicao/src/injector.dart';
import 'package:flutter/material.dart';

class ApuracaoControl extends ChangeNotifier {
  final txtZonaEleitoral = TextEditingController();
  final totalVotos = ValueNotifier(0);
  Future<void> carregaApuracao(int? value) async {
    listApuracao.value.clear();
    totalVotos.value = 0;
    final list = (await votoRepository.find({'zone': value ?? 0})) ?? [];
    Map<String, int> map = {};
    for (var voto in list) {
      map.update('${voto.nome} - ${voto.cargo}', (value) => value + 1,
          ifAbsent: () => 1);
    }
    map.forEach((key, value) => listApuracao.value.add((key, value)));
    listApuracao.value.sort((a, b) => b.$1.compareTo(a.$1));
    listApuracao.value.sort((a, b) => b.$2.compareTo(a.$2));
    totalVotos.value = list.length;
    listApuracao.notifyListeners();
  }
}
