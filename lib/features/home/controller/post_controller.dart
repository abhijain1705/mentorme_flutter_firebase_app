import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mentor_me/features/home/repository/post_repository.dart';
import 'package:mentor_me/features/home/screens/home_screen.dart';
import 'package:mentor_me/utils/utils.dart';

final postControllerProvider = StateNotifierProvider<PostController, bool>(
    (ref) =>
        PostController(postRepository: ref.watch(postRepository), ref: ref));

class PostController extends StateNotifier<bool> {
  final PostRepository _postRepository;
  final Ref _ref;
  PostController({required PostRepository postRepository, required Ref ref})
      : _ref = ref,
        _postRepository = postRepository,
        super(false);

  addPostToApp(
      {required BuildContext context,
      required File? image,
      required String makerPic,
      required String makerName,
      required String makerId,
      required String write,
      required String caption,
      required VoidCallback callback}) async {
    final res = await _postRepository.addNewPosts(
        context: context,
        image: image,
        makerPic: makerPic,
        makerName: makerName,
        makerId: makerId,
        write: write,
        caption: caption,
        callback: callback);

    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, r);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    });
  }

  getInitialPostsData() async {
    int currentLimit = 10;
    return await _postRepository.getInitialPostsData(currentLimit);
  }

  getMorePostsData(List<DocumentSnapshot<Object?>> docs) async {
    int currentLimit = 10;
    return await _postRepository.getMorePostsData(currentLimit, docs);
  }

}
