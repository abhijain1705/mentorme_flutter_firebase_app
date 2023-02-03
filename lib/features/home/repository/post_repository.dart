import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mentor_me/modals/post_modal.dart';
import 'package:mentor_me/provider/firebase_provider.dart';

import '../../../failure.dart';
import '../../../utils/utils.dart';

final postRepository = Provider((ref) => PostRepository(
    firestore: ref.read(firestoreProvider),
    storage: ref.read(storageProvider)));

class PostRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  PostRepository(
      {required FirebaseFirestore firestore, required FirebaseStorage storage})
      : _firestore = firestore,
        _storage = storage;

  CollectionReference get _posts => _firestore.collection("posts");

  Future<Either<Failure, String>> addNewPosts(
      {required BuildContext context,
      required File? image,
      required String makerPic,
      required String makerName,
      required String makerId,
      required String write,
      required String caption,
      required VoidCallback callback}) async {
    try {
      PostModel? postModel;

      String downloadUrlsOfImages = "";
      if (image != null) {
        var imageRef =
            _storage.ref().child("posts/images/${makerId}${DateTime.now()}");
        UploadTask uploadTask = imageRef.putFile(image);
        var snapshot = await uploadTask;
        downloadUrlsOfImages = await snapshot.ref.getDownloadURL();
      }

      postModel = PostModel(
          makerPic: makerPic,
          makerName: makerName,
          makerId: makerId,
          write: write,
          postId: "${makerId}${DateTime.now()}",
          createdAt: Timestamp.now(),
          caption: caption,
          picture: downloadUrlsOfImages);

      await _posts.doc("${makerId}${DateTime.now()}").set(postModel.toMap());
      await _posts
          .doc("${makerId}${DateTime.now()}")
          .collection("group_chat")
          .doc("${makerId}${DateTime.now()}")
          .set({
        'conversation': [
          {
            "message": "hello world",
            "timeStamp": Timestamp.now(),
            "senderId": makerId,
            "senderName": makerName
          }
        ]
      });
      callback.call();
      return right("successfully uploaded");
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  getInitialPostsData(int currentLimit) async {
    QuerySnapshot initialDocs = await _posts
        .orderBy('createdAt', descending: true)
        .limit(currentLimit)
        .get();
    return initialDocs;
  }

  getMorePostsData(
      int currentLimit, List<DocumentSnapshot<Object?>> docs) async {
    QuerySnapshot newDocs = await _posts
        .orderBy("createdAt", descending: true)
        .startAfter([docs[docs.length - 1].get('createdAt')])
        .limit(currentLimit)
        .get();
    return newDocs;
  }
}
