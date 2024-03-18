import 'package:eleicao/src/features/urna/state/votacao_state.dart';

int candidatoDigitos() =>
    switch (numSeqEleicao.value) { 1 => 1, 2 => 1, 3 => 1, _ => throw Error() };
