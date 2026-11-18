import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/features/urna/functions/functions.dart';
import 'package:eleicao/src/features/urna/pages/proximo_eleitor_page.dart';
import 'package:eleicao/src/features/urna/state/votacao_state.dart';
import 'package:eleicao/src/functions/audio_player.dart';
import 'package:eleicao/src/injector.dart';
import 'package:eleicao/src/models/candidato.dart';
import 'package:eleicao/src/models/voto.dart';
import 'package:material_ui/material_ui.dart';

class VotacaoControl with ChangeNotifier {
  List<Voto> votoAtual = [];
  final zone = prefs.getInt('zone');
  int etapaIndex = 0;

  VotacaoControl() {
    etapaIndex = 0;
    if (tipoEleicao.isEmpty) {
      tipoEleicao.add(Cargo.byModalidade(modalidadeEleicao.value).first.codigo);
    }
    numSeqEleicao.value = tipoEleicao.first;
    corrige();
    carregaListaCandidatos();
  }

  void carregaCandidato(int num) {
    final digitos = candidatoDigitos();
    if (numAtual.value >= digitos) return;
    numCandidato.value = int.parse('${numCandidato.value ?? ''}$num');
    numAtual.value++;
    AudioFiles.tecla.play();
    if (numAtual.value == digitos) {
      buscaCandidato(numCandidato.value!, numSeqEleicao.value);
    }
    numCandidato.notifyListeners();
  }

  void buscaCandidato(int numCandidato, int seqEleicao) {
    candidatoAtual.value = listCandidato
        .where((e) => e.numero == numCandidato && e.cargo.codigo == seqEleicao)
        .firstOrNull;
    if (candidatoAtual.value != null) {
      urlImageCandidato.value = candidatoAtual.value!.urlImage;
      urlImageVice.value = candidatoAtual.value!.urlImageVice ?? '';
    }
  }

  void corrige() {
    numCandidato.value = null;
    numAtual.value = 0;
    urlImageCandidato.value = '';
    urlImageVice.value = '';
    candidatoAtual.value = null;
  }

  void confirma(BuildContext context) {
    if (candidatoAtual.value != null) {
      final candidato = candidatoAtual.value!;
      votoAtual.add(Voto(
        cargo: candidato.cargo,
        candidatoId: candidato.id,
        numero: candidato.numero,
        nome: candidato.nome,
        zone: zone ?? 0,
      ));
      etapaIndex++;
      if (etapaIndex < tipoEleicao.length) {
        numSeqEleicao.value = tipoEleicao[etapaIndex];
        corrige();
      } else {
        etapaIndex = 0;
        corrige();
        gravaVoto();
        fimVotacao(context);
      }
    }
  }

  /// Grava todos os votos do eleitor de uma vez (atômico: ou grava todos
  /// os cargos ou nenhum). Não bloqueia a urna: com o Firestore offline a
  /// gravação fica pendente localmente e é enviada quando a rede voltar.
  Future<void> gravaVoto() async {
    final votosParaGravar = List<Voto>.from(votoAtual);
    votoAtual.clear();
    if (votosParaGravar.isEmpty) return;
    try {
      await votoRepository.createAll(votosParaGravar);
    } catch (e, s) {
      debugPrint('Erro ao gravar votos: $e');
      debugPrintStack(stackTrace: s);
    }
  }

  Future<void> fimVotacao(BuildContext context) async {
    etapaIndex = 0;
    numSeqEleicao.value = tipoEleicao.first;
    AudioFiles.confirma.play();
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const Scaffold(
              body: Center(
                child: Text(
                  'FIM',
                  style: TextStyle(fontSize: 200),
                ),
              ),
            )));
    Future.delayed(const Duration(seconds: 3)).whenComplete(() {
      if (!context.mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const ProximoEleitorPage(),
      ));
    });
  }

  /// Carrega os candidatos visíveis nesta urna: os da zona Geral (0) e os
  /// da zona configurada no aparelho.
  Future<void> carregaListaCandidatos() async {
    final list = await candidatoRepository.find({});
    listCandidato
      ..clear()
      ..addAll(candidatosDaUrna(list, zone ?? 0));
  }

  static Iterable<Candidato> candidatosDaUrna(
          Iterable<Candidato> candidatos, int zonaUrna) =>
      candidatos.where((c) => c.zone == 0 || c.zone == zonaUrna);

  /// Cargos do evento sem nenhum candidato visível na urna. Se houver
  /// algum, o eleitor ficaria travado nessa etapa (não há voto em branco).
  static List<Cargo> cargosSemCandidato(
      Iterable<Candidato> candidatos, int zonaUrna, List<int> cargos) {
    final visiveis = candidatosDaUrna(candidatos, zonaUrna)
        .map((c) => c.cargo.codigo)
        .toSet();
    return [
      for (final c in cargos)
        if (!visiveis.contains(c)) Cargo.getCargoByCodigo(c)
    ];
  }
}
