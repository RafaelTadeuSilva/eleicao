import 'package:eleicao/src/features/urna/state/votacao_state.dart';

int candidatoDigitos() =>
    switch (numSeqEleicao.value) { 1 => 2, 2 => 2, 3 => 1, _ => throw Error() };
