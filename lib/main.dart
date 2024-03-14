import 'package:eleicao/firebase_options.dart';
import 'package:eleicao/src/features/cadastro/mapper/aluno_mapper_impl.dart';
import 'package:eleicao/src/features/cadastro/repositories/aluno_repository.dart';
import 'package:eleicao/src/features/cadastro/repositories/aluno_repository_impl.dart';
import 'package:eleicao/src/features/home/home_page.dart';
import 'package:eleicao/src/repositories/api_db.dart';
import 'package:eleicao/src/repositories/local/sqflite_db.dart';
import 'package:eleicao/src/repositories/remote/firestore_db.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

late final ApiDb apidb;
late final AlunoRepository alunoRepository;
late final SharedPreferences prefs;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setTerminal();
  await inject();
  runApp(const MyApp());
}

Future<void> setTerminal() async {
  prefs = await SharedPreferences.getInstance();
  final terminal = prefs.getInt('terminal');
  if (terminal == null) {
    prefs.setInt('terminal', 0);
  }
}

Future<void> inject() async {
  // apidb = await configSQFlite();
  apidb = await configFirebase();
  alunoRepository = AlunoRepositoryImpl(apidb, AlunoMapperImpl());
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eleição',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}
