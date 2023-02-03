import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../../../failure.dart';
import '../../../provider/firebase_provider.dart';
import '../../../typedef.dart';

final storageRepositoryProvider = Provider(
    (ref) => MyStorageRepository(firebaseStorage: ref.watch(storageProvider)));

class MyStorageRepository {
  final FirebaseStorage _firebaseStorage;

  MyStorageRepository({required FirebaseStorage firebaseStorage})
      : _firebaseStorage = firebaseStorage;

  FutureEither<String> storeFile(
      {required String path, required String id, required File? file}) async {
    try {
      final ref = _firebaseStorage.ref().child(path).child(id);

      UploadTask uploadTask = ref.putFile(file!);
      final snapshot = await uploadTask;

      return right(await snapshot.ref.getDownloadURL());
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
