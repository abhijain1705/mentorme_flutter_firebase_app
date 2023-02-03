import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mentor_me/constants/default_user.dart';
import 'package:mentor_me/features/home/repository/storage_repository.dart';
import 'package:mentor_me/features/home/screens/home_screen.dart';
import 'package:mentor_me/modals/mentor_user.dart';

import '../../../utils/utils.dart';
import '../repository/auth_repository.dart';

final userProvider = StateProvider<MentorMeUser?>((ref) => null);

final authControllerProvider = StateNotifierProvider<AuthController, bool>(
    (ref) => AuthController(
        authRepository: ref.watch(authRepositoryProvider),
        myStorageRepository: ref.watch(storageRepositoryProvider),
        ref: ref));

final authStateChangeProvider = StreamProvider((ref) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.authStateChange;
});

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  final Ref _ref;
  final MyStorageRepository _myStorageRepository;
  AuthController(
      {required AuthRepository authRepository,
      required Ref ref,
      required MyStorageRepository myStorageRepository})
      : _authRepository = authRepository,
        _ref = ref,
        _myStorageRepository = myStorageRepository,
        super(false);

  Stream<User?> get authStateChange => _authRepository.authStateChange;
  DefaultUser defaultUser = DefaultUser();

  void signInWithGoogle(BuildContext context) async {
    state = true;
    final user = await _authRepository.signInWithGoogle(context);
    state = false;
    user.fold(
        (l) => showSnackBar(context, l.message),
        (userModal) =>
            {_ref.read(userProvider.notifier).update((state) => userModal)});
  }

  getCurrentUserData(
      {required String uid,
      required BuildContext context,
      required VoidCallback callback}) async {
    final res = await _authRepository.getCurrentUserData(uid);

    res.fold(
        (l) => showSnackBar(context, l.message),
        (newUser) =>
            _ref.read(userProvider.notifier).update((state) => newUser));

    callback.call();
  }

  fetchThirdUserData(BuildContext context, String documentId) async {
    return await _authRepository.fetchThirdUserData(context, documentId);
  }

  void editUserProfile(
      {File? profile_picture,
      String? name,
      String? bio,
      String? email,
      String? location,
      String? about,
      Map<String, dynamic>? socials,
      required BuildContext context,
      required MentorMeUser meUser,
      required VoidCallback callback}) async {
    if (profile_picture != null) {
      final res = await _myStorageRepository.storeFile(
          path: "user/profile", id: meUser.docId, file: profile_picture);
      res.fold((l) => showSnackBar(context, l.message),
          (r) => meUser = meUser.copyWith(profile_picture: r));
    }

    if (name != null) {
      meUser = meUser.copyWith(name: name);
    }

    if (bio != null) {
      meUser = meUser.copyWith(bio: bio);
    }

    if (location != null) {
      meUser = meUser.copyWith(location: location);
    }

    if (about != null) {
      meUser = meUser.copyWith(profile_description: about);
    }

    if (email != null) {
      meUser = meUser.copyWith(email: email);
    }

    if (socials != null) {
      meUser = meUser.copyWith(socials: socials);
    }

    final result = await _authRepository.editUserProfile(meUser);
    callback.call();
    result.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, "profile updated successfully");
      _ref.watch(userProvider.notifier).update((state) => meUser);
      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const HomeScreen()));
      });
    });
  }

  logout() {
    _authRepository.logout();
  }

  getInitialUserData() async {
    int currentLimit = 5;
    return await _authRepository.getInitialUserData(currentLimit);
  }

  getMoreUserData(List<DocumentSnapshot<Object?>> docs) async {
    int currentLimit = 5;
    return await _authRepository.getMoreUserData(currentLimit, docs);
  }

  searchUsers(String search) {
    return _authRepository.searchUsers(search);
  }

  isOnlineStatus(bool isOnline, BuildContext context) {
    _authRepository.isOnlineStatus(context, isOnline);
  }

  addFollowersAndFollowing(
      BuildContext context,
      String followingName,
      String followingPic,
      String followerId,
      String followerPic,
      String followerName) {
    _authRepository.addFollowersAndFollowing(context, followingName,
        followingPic, followerId, followerPic, followerName);
  }

  removeFollowersAndFollowing(
      BuildContext context,
      String followingName,
      String followingPic,
      String followerId,
      String followerPic,
      String followerName) {
    _authRepository.removeFollowersAndFollowing(context, followingName,
        followingPic, followerId, followerPic, followerName);
  }

  Stream<MentorMeUser> userData(String docId) {
    return _authRepository.userData(docId);
  }
}
