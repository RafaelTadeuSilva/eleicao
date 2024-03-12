import 'package:eleicao/src/features/urna/state/votacao_state.dart';

int candidatoDigitos() =>
    switch (numSeqEleicao.value) { 1 => 2, 2 => 4, 3 => 5, _ => throw Error() };
