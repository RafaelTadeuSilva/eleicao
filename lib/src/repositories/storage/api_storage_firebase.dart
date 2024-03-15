import 'dart:io';

import 'package:eleicao/src/repositories/api_storage.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ApiStorageFirebase implements ApiStorage {
  @override
  Future<String> uploadFile(String origem, String destino) async {
    final storageRef = FirebaseStorage.instance.ref();

    final ref = storageRef.child('imagens/$destino');

    // Directory appDocDir = await getApplicationDocumentsDirectory();
    // String filePath = '${appDocDir.absolute}/$origem';
    String filePath = origem;
    File file = File(filePath);

    try {
      await ref.putFile(file);
    } catch (e) {
      print(e.toString());
      return '';
    }
    return await ref.getDownloadURL();
  }
}
