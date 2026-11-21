import 'package:eleicao/src/features/cadastro/state/cadastro_state.dart';
import 'package:eleicao/src/features/cadastro/mapper/aluno_mapper_impl.dart';
import 'package:eleicao/src/features/cadastro/mapper/candidato_mapper_impl.dart';
import 'package:eleicao/src/features/cadastro/mapper/liberacao_urna_mapper_impl.dart';
import 'package:eleicao/src/features/cadastro/mapper/voto_mapper_impl.dart';
import 'package:eleicao/src/features/cadastro/repositories/aluno/aluno_repository_impl.dart';
import 'package:eleicao/src/features/cadastro/repositories/candidato/candidato_repository_impl.dart';
import 'package:eleicao/src/features/cadastro/repositories/evento_eleicao/evento_eleicao_repository_impl.dart';
import 'package:eleicao/src/features/cadastro/repositories/liberacao_urna/liberacao_urna_repository.dart';
import 'package:eleicao/src/features/cadastro/repositories/liberacao_urna/liberacao_urna_repository_impl.dart';
import 'package:eleicao/src/features/cadastro/repositories/voto/voto_repository_impl.dart';
import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/features/urna/state/votacao_state.dart';
import 'package:eleicao/src/functions/audio_player.dart';
import 'package:eleicao/src/injector.dart';
import 'package:eleicao/src/models/evento_eleicao.dart';
import 'package:eleicao/src/repositories/api_db.dart';
import 'package:eleicao/src/repositories/remote/firestore_db.dart';
import 'package:eleicao/src/repositories/storage/api_storage_base64.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Registra os sons tocados em vez de reproduzi-los.
class FakeSoundPlayer implements SoundPlayer {
  final played = <AudioFiles>[];

  @override
  void play(AudioFiles audio) => played.add(audio);
}

/// [ApiDb] que delega para um [FirestoreDb] trocável, permitindo
/// reiniciar o banco entre testes mesmo com as dependências globais
/// do injector sendo `late final` (atribuíveis uma única vez).
class SwitchableApiDb implements ApiDb {
  ApiDb delegate;
  SwitchableApiDb(this.delegate);

  @override
  Future<String> create(String table, Map<String, dynamic> map) =>
      delegate.create(table, map);
  @override
  Future<void> createAll(String table, List<Map<String, dynamic>> maps) =>
      delegate.createAll(table, maps);
  @override
  Future<bool> delete(String table, String id) => delegate.delete(table, id);
  @override
  Future<List<Map<String, dynamic>>> find(
          String table, Map<String, dynamic> filter) =>
      delegate.find(table, filter);
  @override
  Future<Map<String, dynamic>> findOne(String table, String id) =>
      delegate.findOne(table, id);
  @override
  Future<bool> update(String table, String id, Map<String, dynamic> map) =>
      delegate.update(table, id, map);
}

final fakeSound = FakeSoundPlayer();
late FakeFirebaseFirestore firestore;
final _apiDb = SwitchableApiDb(FirestoreDb(db: FakeFirebaseFirestore()));
bool _injected = false;

/// Evento usado por padrão nos testes: política, presidente (2 dígitos)
/// e vereador (4 dígitos).
EventoEleicao eventoTeste({String sufixo = 'Teste'}) =>
    EventoEleicao.fromSufixo(
      sufixo: sufixo,
      modalidade: TipoEleicaoModalidade.politica,
      cargos: [Cargo.presidente.codigo, Cargo.vereador.codigo],
    );

/// Injeta fakes nas dependências globais (uma vez por arquivo de teste)
/// e reinicia banco, preferências e estado global.
///
/// [liberacaoUrna] substitui o repositório de liberação; só tem efeito na
/// primeira chamada do arquivo, pois as dependências são `late final`.
Future<void> resetAmbiente({
  int zone = 0,
  int terminal = 1,
  LiberacaoUrnaRepository? liberacaoUrna,
}) async {
  SharedPreferences.setMockInitialValues({'zone': zone, 'terminal': terminal});
  if (!_injected) {
    _injected = true;
    prefs = await SharedPreferences.getInstance();
    soundPlayer = fakeSound;
    apiStorage = ApiStorageBase64();
    alunoRepository = AlunoRepositoryImpl(_apiDb, AlunoMapperImpl());
    candidatoRepository =
        CandidatoRepositoryImpl(_apiDb, CandidatoMapperImpl());
    votoRepository = VotoRepositoryImpl(_apiDb, VotoMapperImpl());
    liberacaoUrnaRepository = liberacaoUrna ??
        LiberacaoUrnaRepositoryImpl(_apiDb, LiberacaoUrnaMapperImpl());
    eventoEleicaoRepository = EventoEleicaoRepositoryImpl(_apiDb);
  }
  await prefs.reload();
  await prefs.setInt('zone', zone);
  await prefs.setInt('terminal', terminal);

  firestore = FakeFirebaseFirestore();
  _apiDb.delegate = FirestoreDb(db: firestore);
  fakeSound.played.clear();
  ultimoCargoCadastrado = null;
  aplicarEventoEleicao(eventoTeste());
}
