import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mentor_me/features/home/repository/chat_repository.dart';
import 'package:mentor_me/modals/chat_modal.dart';
import 'package:mentor_me/modals/group_chat.dart';

final chatControllerProvider = StateNotifierProvider<ChatController, bool>(
    (ref) => ChatController(
        chatRepository: ref.watch(chatRepositoryProvider), ref: ref));

class ChatController extends StateNotifier<bool> {
  final Ref _ref;
  final ChatRepository _chatRepository;
  ChatController({required Ref ref, required ChatRepository chatRepository})
      : _ref = ref,
        _chatRepository = chatRepository,
        super(false);

  addMessageToConversation(
      {required BuildContext context,
      required String messageText,
      required String senderId,
      required String receiverId,
      required String senderName,
      required String senderImage,
      required String recieverName,
      required String recieverImage,
      required String senderPic}) {
    return _chatRepository.addMessageToConversation(
        context: context,
        messageText: messageText,
        senderId: senderId,
        receiverId: receiverId,
        recieverName: recieverName,
        recieverImage: recieverImage,
        senderName: senderName,
        senderPic: senderPic);
  }

  addNewGroupChat(
      {required BuildContext context,
      required String postId,
      required String messageText,
      required String senderId,
      required String senderName}) async {
    return await _chatRepository.addNewGroupChat(
        context: context,
        postId: postId,
        messageText: messageText,
        senderId: senderId,
        senderName: senderName);
  }

  getInitialChatsData(int currentLimit, String userId) async {
    return await _chatRepository.getInitialChatsData(currentLimit, userId);
  }

  getMoreChatsData(int currentLimit, List<DocumentSnapshot<Object?>> docs,
      String userId) async {
    return await _chatRepository.getMoreChatsData(currentLimit, docs, userId);
  }

  Stream<GroupChat> renderSinglGroupChatUi(String postId) {
    return _chatRepository.renderSinglGroupChatUi(postId);
  }

  Stream<ChatModel> renderSingleChatUi(
      String chatDocumentId, String currentUserId) {
    return _chatRepository.renderSingleChatUi(chatDocumentId, currentUserId);
  }
}
