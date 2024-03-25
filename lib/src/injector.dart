import 'package:eleicao/firebase_options.dart';
import 'package:eleicao/src/features/cadastro/mapper/aluno_mapper_impl.dart';
import 'package:eleicao/src/features/cadastro/mapper/candidato_mapper_impl.dart';
import 'package:eleicao/src/features/cadastro/mapper/liberacao_urna_mapper_impl.dart';
import 'package:eleicao/src/features/cadastro/mapper/voto_mapper_impl.dart';
import 'package:eleicao/src/features/cadastro/repositories/aluno/aluno_repository.dart';
import 'package:eleicao/src/features/cadastro/repositories/aluno/aluno_repository_impl.dart';
import 'package:eleicao/src/features/cadastro/repositories/candidato/candidato_repository.dart';
import 'package:eleicao/src/features/cadastro/repositories/candidato/candidato_repository_impl.dart';
import 'package:eleicao/src/features/cadastro/repositories/liberacao_urna/liberacao_urna_repository.dart';
import 'package:eleicao/src/features/cadastro/repositories/liberacao_urna/liberacao_urna_repository_impl.dart';
import 'package:eleicao/src/features/cadastro/repositories/voto/voto_repository.dart';
import 'package:eleicao/src/features/cadastro/repositories/voto/voto_repository_impl.dart';
import 'package:eleicao/src/functions/audio_player.dart';
import 'package:eleicao/src/repositories/api_db.dart';
import 'package:eleicao/src/repositories/api_storage.dart';
import 'package:eleicao/src/repositories/local/sqflite_db.dart';
import 'package:eleicao/src/repositories/remote/firestore_db.dart';
import 'package:eleicao/src/repositories/storage/api_storage_firebase.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

late final AlunoRepository alunoRepository;
late final CandidatoRepository candidatoRepository;
late final LiberacaoUrnaRepository liberacaoUrnaRepository;
late final VotoRepository votoRepository;
late final SharedPreferences prefs;
late final ApiStorage apiStorage;
late final SoundPlayer soundPlayer;

Future<void> setTerminal() async {
  prefs = await SharedPreferences.getInstance();
  final terminal = prefs.getInt('terminal');
  if (terminal == null) {
    prefs.setInt('terminal', 0);
  }
}

Future<void> setZone() async {
  final terminal = prefs.getInt('zone');
  if (terminal == null) {
    prefs.setInt('zone', 0);
  }
}

Future<void> setTipoEleicao() async {
  final terminal = prefs.getInt('tipoeleicao');
  if (terminal == null) {
    prefs.setInt('tipoeleicao', 1);
  }
}

Future<void> inject() async {
  await setTerminal();
  await setZone();
  await setTipoEleicao();

  final apidb = await configFirebase();

  soundPlayer = SoundPlayerImpl();

  apiStorage = ApiStorageFirebase();
  alunoRepository = AlunoRepositoryImpl(apidb, AlunoMapperImpl());
  candidatoRepository = CandidatoRepositoryImpl(apidb, CandidatoMapperImpl());
  votoRepository = VotoRepositoryImpl(apidb, VotoMapperImpl());
  liberacaoUrnaRepository =
      LiberacaoUrnaRepositoryImpl(apidb, LiberacaoUrnaMapperImpl());
}

Future<ApiDb> configFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  return FirestoreDb();
}

Future<ApiDb> configSQFlite() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  final db = await SqfliteDb.createDatabase();
  return SqfliteDb(db: db);
}
