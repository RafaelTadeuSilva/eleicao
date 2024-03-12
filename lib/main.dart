import 'package:eleicao/src/features/urna/pages/proximo_eleitor_page.dart';
import 'package:eleicao/src/repositories/local/api_db.dart';
import 'package:eleicao/src/repositories/local/sqflite_db.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

late final ApiDb apidb;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await connectToDb();
  runApp(const MyApp());
}

Future<void> connectToDb() async {
  sqfliteFfiInit();
  final db = await SqfliteDb.createDatabase();
  apidb = SqfliteDb(db: db);
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
      home: const ProximoEleitorPage(),
    );
  }
}
