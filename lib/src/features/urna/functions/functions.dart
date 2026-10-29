import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/features/urna/state/votacao_state.dart';

int candidatoDigitos() => Cargo.getCargoByCodigo(numSeqEleicao.value).digitos;
