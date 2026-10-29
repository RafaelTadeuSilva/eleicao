import 'package:eleicao/firebase_options.dart';
import 'package:eleicao/src/features/cadastro/mapper/aluno_mapper_impl.dart';
import 'package:eleicao/src/features/cadastro/mapper/candidato_mapper_impl.dart';
import 'package:eleicao/src/features/cadastro/mapper/liberacao_urna_mapper_impl.dart';
import 'package:eleicao/src/features/cadastro/mapper/voto_mapper_impl.dart';
import 'package:eleicao/src/features/cadastro/repositories/aluno/aluno_repository.dart';
import 'package:eleicao/src/features/cadastro/repositories/aluno/aluno_repository_impl.dart';
import 'package:eleicao/src/features/cadastro/repositories/candidato/candidato_repository.dart';
import 'package:eleicao/src/features/cadastro/repositories/candidato/candidato_repository_impl.dart';
import 'package:eleicao/src/features/cadastro/repositories/evento_eleicao/evento_eleicao_repository.dart';
import 'package:eleicao/src/features/cadastro/repositories/evento_eleicao/evento_eleicao_repository_impl.dart';
import 'package:eleicao/src/features/cadastro/repositories/liberacao_urna/liberacao_urna_repository.dart';
import 'package:eleicao/src/features/cadastro/repositories/liberacao_urna/liberacao_urna_repository_impl.dart';
import 'package:eleicao/src/features/cadastro/repositories/voto/voto_repository.dart';
import 'package:eleicao/src/features/cadastro/repositories/voto/voto_repository_impl.dart';
import 'package:eleicao/src/features/urna/enums/cargo.dart';
import 'package:eleicao/src/features/urna/state/votacao_state.dart';
import 'package:eleicao/src/functions/audio_player.dart';
import 'package:eleicao/src/models/evento_eleicao.dart';
import 'package:eleicao/src/repositories/api_db.dart';
import 'package:eleicao/src/repositories/api_storage.dart';
import 'package:eleicao/src/repositories/local/sqflite_db.dart';
import 'package:eleicao/src/repositories/remote/firestore_db.dart';
import 'package:eleicao/src/repositories/storage/api_storage_base64.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

late final AlunoRepository alunoRepository;
late final CandidatoRepository candidatoRepository;
late final LiberacaoUrnaRepository liberacaoUrnaRepository;
late final VotoRepository votoRepository;
late final EventoEleicaoRepository eventoEleicaoRepository;
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

Future<void> salvarEventoEleicaoLocal(EventoEleicao evento) async {
  await prefs.setString('evento_id', evento.id);
  await prefs.setString('evento_nome', evento.nome);
  await prefs.setString('colecao_alunos', evento.colecaoAlunos);
  await prefs.setString('colecao_candidatos', evento.colecaoCandidatos);
  await prefs.setString('colecao_votos', evento.colecaoVotos);
  await prefs.setString('colecao_liberacao', evento.colecaoLiberacao);
  await prefs.setInt('modalidade_eleicao', evento.modalidade.codigo);
  await prefs.setStringList(
    'digitos_por_cargo',
    evento.digitosPorCargo.entries.map((e) => '${e.key}:${e.value}').toList(),
  );
  await prefs.setStringList(
    'cargos_ativos',
    evento.cargos.map((e) => e.toString()).toList(),
  );
  aplicarEventoEleicao(evento);
}

Future<void> setTipoEleicao() async {
  final idSalvo = prefs.getString('evento_id') ?? '2026';
  final nomeSalvo = prefs.getString('evento_nome') ?? 'Eleição $idSalvo';
  final colAlunos = prefs.getString('colecao_alunos') ?? 'Alunos$idSalvo';
  final colCandidatos =
      prefs.getString('colecao_candidatos') ?? 'Candidatos$idSalvo';
  final colVotos = prefs.getString('colecao_votos') ?? 'Votos$idSalvo';
  final colLiberacao =
      prefs.getString('colecao_liberacao') ?? 'LiberacaoUrna$idSalvo';

  final modCodigo = prefs.getInt('modalidade_eleicao');
  final digitosList = prefs.getStringList('digitos_por_cargo') ?? [];
  final mapaDigitos = <int, int>{};
  for (final item in digitosList) {
    final parts = item.split(':');
    if (parts.length == 2) {
      final k = int.tryParse(parts[0]);
      final v = int.tryParse(parts[1]);
      if (k != null && v != null) {
        mapaDigitos[k] = v;
      }
    }
  }
  final cargosSalvos = prefs.getStringList('cargos_ativos');

  if (modCodigo != null && cargosSalvos != null && cargosSalvos.isNotEmpty) {
    final modalidade = TipoEleicaoModalidade.getByCodigo(modCodigo);
    final codigos =
        cargosSalvos.map((e) => int.tryParse(e)).whereType<int>().toList();
    aplicarEventoEleicao(
      EventoEleicao(
        id: idSalvo,
        nome: nomeSalvo,
        colecaoAlunos: colAlunos,
        colecaoCandidatos: colCandidatos,
        colecaoVotos: colVotos,
        colecaoLiberacao: colLiberacao,
        modalidade: modalidade,
        cargos: codigos,
        digitosPorCargo: mapaDigitos,
      ),
    );
    return;
  }

  // Fallback para configuração legada
  final legacyTipo = prefs.getInt('tipoeleicao') ?? 1;
  final codigosIniciais = legacyTipo == 1 ? <int>[1, 2] : <int>[4];
  final eventoInicial = EventoEleicao(
    id: idSalvo,
    nome: nomeSalvo,
    colecaoAlunos: colAlunos,
    colecaoCandidatos: colCandidatos,
    colecaoVotos: colVotos,
    colecaoLiberacao: colLiberacao,
    modalidade: TipoEleicaoModalidade.politica,
    cargos: codigosIniciais,
  );
  await salvarEventoEleicaoLocal(eventoInicial);
}

Future<void> inject() async {
  await setTerminal();
  await setZone();
  await setTipoEleicao();

  final apidb = await configFirebase();

  soundPlayer = SoundPlayerImpl();

  apiStorage = ApiStorageBase64();
  alunoRepository = AlunoRepositoryImpl(apidb, AlunoMapperImpl());
  candidatoRepository = CandidatoRepositoryImpl(apidb, CandidatoMapperImpl());
  votoRepository = VotoRepositoryImpl(apidb, VotoMapperImpl());
  liberacaoUrnaRepository =
      LiberacaoUrnaRepositoryImpl(apidb, LiberacaoUrnaMapperImpl());
  eventoEleicaoRepository = EventoEleicaoRepositoryImpl(apidb);
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
