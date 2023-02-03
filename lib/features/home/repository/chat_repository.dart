import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mentor_me/modals/chat_modal.dart';
import 'package:mentor_me/modals/group_chat.dart';
import 'package:mentor_me/provider/firebase_provider.dart';
import '../../../utils/utils.dart';

final chatRepositoryProvider =
    Provider((ref) => ChatRepository(firestore: ref.read(firestoreProvider)));

class ChatRepository {
  final FirebaseFirestore _firestore;
  ChatRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _user => _firestore.collection("mentorme_users");
  CollectionReference get _post => _firestore.collection("posts");

  addMessageToConversation(
      {required BuildContext context,
      required String messageText,
      required String senderId,
      required String receiverId,
      required String recieverName,
      required String recieverImage,
      required String senderName,
      required String senderPic}) async {
    try {
      // create a reference of document wheren the conversation wll be stored in doc of sender
      final senderChatCollectionRef =
          _user.doc(senderId).collection("chats").doc(receiverId);

      // create a reference of document wheren the conversation wll be stored in doc of reciever
      final reciverChatCollectionRef =
          _user.doc(receiverId).collection("chats").doc(senderId);

      // Retrieve the existing conversation from the Firestore document in sender docs
      final isOldConversationInSender = await senderChatCollectionRef.get();

      // Retrieve the existing conversation from the Firestore document in sender docs
      final isOldConversationInReciever = await reciverChatCollectionRef.get();

// sender handling
      ChatModel senderChatModel;
      if (isOldConversationInSender.exists) {
        await senderChatCollectionRef.update({
          'conversation': FieldValue.arrayUnion([
            {
              "message": messageText,
              "timeStamp": Timestamp.now(),
              "senderId": senderId
            }
          ])
        });
      } else {
        senderChatModel = ChatModel(
            reciverName: recieverName,
            reciverPic: recieverImage,
            reciverDocId: receiverId,
            conversation: [
              {
                "message": messageText,
                "timeStamp": Timestamp.now(),
                "senderId": senderId
              }
            ]);
        await senderChatCollectionRef.set(senderChatModel.toMap());
      }

      // reciver handling
      ChatModel reciverChatModel;
      if (isOldConversationInReciever.exists) {
        await reciverChatCollectionRef.update({
          'conversation': FieldValue.arrayUnion([
            {
              "message": messageText,
              "timeStamp": Timestamp.now(),
              "senderId": senderId
            }
          ])
        });
      } else {
        reciverChatModel = ChatModel(
            reciverName: senderName,
            reciverPic: senderPic,
            reciverDocId: senderId,
            conversation: [
              {
                "message": messageText,
                "timeStamp": Timestamp.now(),
                "senderId": senderId
              }
            ]);
        await reciverChatCollectionRef.set(reciverChatModel.toMap());
      }

      print('message sent successfully');
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      showSnackBar(context, "error in sending message");
    }
  }

  getInitialChatsData(int currentLimit, String userId) async {
    QuerySnapshot initialDocs =
        await _user.doc(userId).collection("chats").limit(currentLimit).get();
    return initialDocs;
  }

  getMoreChatsData(int currentLimit, List<DocumentSnapshot<Object?>> docs,
      String userId) async {
    QuerySnapshot newDocs = await _user
        .doc(userId)
        .collection("chats")
        .startAfter([docs[docs.length - 1].get("reciverName")])
        .limit(10)
        .get();
    return newDocs;
  }

  addNewGroupChat(
      {required BuildContext context,
      required String postId,
      required String messageText,
      required String senderId,
      required String senderName}) async {
    try {
      final chatDocRef = _post.doc(postId).collection("group_chat").doc(postId);

      final isOldConversation = await chatDocRef.get();

      GroupChat groupChat;
      if (isOldConversation.exists) {
        await chatDocRef.update({
          'conversation': FieldValue.arrayUnion([
            {
              "message": messageText,
              "timeStamp": Timestamp.now(),
              "senderId": senderId,
              "senderName": senderName
            }
          ])
        });
      } else {
        groupChat = GroupChat(conversation: [
          {
            "message": messageText,
            "timeStamp": Timestamp.now(),
            "senderId": senderId,
            "senderName": senderName
          }
        ]);
        await chatDocRef.set(groupChat.toMap());
      }
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      showSnackBar(context, "error in sending message");
    }
  }

  Stream<GroupChat> renderSinglGroupChatUi(String postId) {
    final currentPostChatDocumentRef =
        _post.doc(postId).collection("group_chat").doc(postId);
    return currentPostChatDocumentRef.snapshots().map((event) {
      if (event.exists) {
        return GroupChat.fromMap(event.data()!);
      } else {
        return GroupChat(conversation: [
          {
            "message": "hello world",
            "timeStamp": Timestamp.now(),
            "senderId": "mentorme doc id",
            "senderName": "mentorme user"
          }
        ]);
      }
    });
  }

  Stream<ChatModel> renderSingleChatUi(
      String chatDocumentId, String currentUserId) {
    final currentUserChatDocumentRef =
        _user.doc(currentUserId).collection("chats").doc(chatDocumentId);
    return currentUserChatDocumentRef.snapshots().map((event) {
      if (event.exists) {
        return ChatModel.fromMap(event.data()!);
      } else {
        return ChatModel(
            reciverName: "",
            reciverPic: "",
            conversation: [],
            reciverDocId: "");
      }
    });
  }
}
