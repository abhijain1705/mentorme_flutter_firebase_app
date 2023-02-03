import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mentor_me/constants/default_user.dart';
import 'package:mentor_me/modals/mentor_user.dart';
import 'package:mentor_me/provider/firebase_provider.dart';
import 'package:mentor_me/typedef.dart';
import 'package:mentor_me/utils/utils.dart';

import '../../../failure.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository(
      firestore: ref.read(firestoreProvider),
      auth: ref.read(authProvider),
      googleSignIn: ref.read(googleSignInProvider),
    ));

class AuthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthRepository(
      {required FirebaseFirestore firestore,
      required FirebaseAuth auth,
      required GoogleSignIn googleSignIn})
      : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  CollectionReference get _user => _firestore.collection("mentorme_users");

  Stream<User?> get authStateChange => _auth.authStateChanges();

  DefaultUser defaultUser = DefaultUser();

  Future<Either<Failure, MentorMeUser>> signInWithGoogle(
      BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      final googleAuth = await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);

      MentorMeUser mentorMeUser;

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      if (userCredential.additionalUserInfo!.isNewUser) {
        mentorMeUser = MentorMeUser(
          name: userCredential.user?.displayName ?? "",
          bio: "bio",
          location: "address",
          isOnline: true,
          createdAt: Timestamp.now(),
          email: userCredential.user?.email ?? "",
          profile_picture: userCredential.user?.photoURL ?? "",
          profile_description: "profile_description",
          follower: [],
          following: [],
          socials: {
            'twitter': "",
            'linkedin': "",
            'github': "",
            'facebook': "",
            'instagram': "",
            'youtube': ""
          },
          docId: userCredential.user?.uid ?? "",
        );

        await _user.doc(mentorMeUser.docId).set(mentorMeUser.toMap());
        await _user
            .doc(mentorMeUser.docId)
            .collection("chats")
            .doc(mentorMeUser.docId)
            .set({
              'conversation': [{
              "message": "hey welcome!",
              "timeStamp": Timestamp.now(),
              "senderId": mentorMeUser.docId
            }],
              'reciverDocId': mentorMeUser.docId,
              'reciverPic': mentorMeUser.profile_picture,
              'reciverName': mentorMeUser.name
            });
      } else {
        final result = await getCurrentUserData(userCredential.user!.uid);
        if (result.isRight()) {
          mentorMeUser = result.getOrElse((l) => defaultUser.getDefaultUser());
        } else {
          showSnackBar(context,
              result.fold((l) => l.message, (r) => 'Unexpected error'));
          return left(
              result.fold((l) => l, (r) => Failure('Unexpected error')));
        }
      }
      return right(mentorMeUser);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, MentorMeUser>> getCurrentUserData(String uid) async {
    try {
      final data = await _user.doc(uid).get();

      if (data.data() != null && data.data() is Map<String, dynamic>) {
        return right(MentorMeUser.fromMap(data.data() as Map<String, dynamic>));
      } else {
        throw Exception('Error: User data is null or in unexpected format');
      }
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future fetchThirdUserData(BuildContext context, String documentId) async {
    try {
      final res = await _user.doc(documentId).get();
      return res.data();
    } catch (e) {
      showSnackBar(context, "error in fetching this user data");
    }
  }

  FutureVoid editUserProfile(MentorMeUser meUser) async {
    try {
      return right(_user.doc(meUser.docId).update(meUser.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  logout() async {
    await _auth.signOut();
  }

  getInitialUserData(int currentLimit) async {
    QuerySnapshot initialDocs = await _user
        .where("docId", isNotEqualTo: _auth.currentUser!.uid)
        .limit(currentLimit)
        .get();
    return initialDocs;
  }

  getMoreUserData(
      int currentLimit, List<DocumentSnapshot<Object?>> docs) async {
    QuerySnapshot newDocs = await _user
        .where("docId", isNotEqualTo: _auth.currentUser!.uid)
        .startAfter([docs[docs.length - 1].get("createdAt")])
        .limit(10)
        .get();
    return newDocs;
  }

  searchUsers(String name) {
    Query docs = _user
        .where("docId", isNotEqualTo: _auth.currentUser!.uid)
        .where("name", isGreaterThanOrEqualTo: name)
        .where("name", isLessThan: '${name}z')
        .limit(10);
    return docs;
  }

  isOnlineStatus(BuildContext context, bool isOnline) async {
    try {
      await _user.doc(_auth.currentUser!.uid).update({'isOnline': isOnline});
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      showSnackBar(context, "error in updating user state");
    }
  }

  addFollowersAndFollowing(
      BuildContext context,
      String followingName,
      String followingPic,
      String followerId,
      String followerPic,
      String followerName) async {
    try {
      await _user.doc(followerId).update({
        'follower': FieldValue.arrayUnion([
          {
            'id': _auth.currentUser!.uid,
            'name': followingName,
            'profile_pic': followingPic,
          }
        ])
      });

      await _user.doc(_auth.currentUser?.uid).update({
        'following': FieldValue.arrayUnion([
          {'id': followerId, 'name': followerName, 'profile_pic': followerPic}
        ])
      });
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      showSnackBar(context, "error in updating user state");
    }
  }

  removeFollowersAndFollowing(
      BuildContext context,
      String followingName,
      String followingPic,
      String followerId,
      String followerPic,
      String followerName) async {
    try {
      await _user.doc(followerId).update({
        'follower': FieldValue.arrayRemove([
          {
            'id': _auth.currentUser!.uid,
            'name': followingName,
            'profile_pic': followingPic,
          }
        ])
      });

      await _user.doc(_auth.currentUser?.uid).update({
        'following': FieldValue.arrayRemove([
          {'id': followerId, 'name': followerName, 'profile_pic': followerPic}
        ])
      });
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      showSnackBar(context, "error in updating user state");
    }
  }

  Stream<MentorMeUser> userData(String docId) {
    return _user.doc(docId).snapshots().map((event) => MentorMeUser.fromMap(
          event.data()! as Map<String, dynamic>,
        ));
  }
}
