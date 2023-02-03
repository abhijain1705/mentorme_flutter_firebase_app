import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mentor_me/features/auth/controller/auth_controller.dart';
import 'package:mentor_me/features/home/controller/chat_controller.dart';
import 'package:mentor_me/modals/mentor_user.dart';

import '../../../utils/utils.dart';

class PostChat extends ConsumerStatefulWidget {
  final String caption;
  final String postPicture;
  final String postId;
  const PostChat(
      {Key? key,
      required this.postId,
      required this.caption,
      required this.postPicture})
      : super(key: key);

  @override
  ConsumerState<PostChat> createState() => _PostChatState();
}

class _PostChatState extends ConsumerState<PostChat> {
  TextEditingController chat = TextEditingController();

  addNewMessageToConversation(
      {required BuildContext context,
      required String postId,
      required String messageText,
      required String senderId,
      required String senderName}) {
    ref.watch(chatControllerProvider.notifier).addNewGroupChat(
        context: context,
        postId: postId,
        messageText: messageText,
        senderId: senderId,
        senderName: senderName);
  }

  @override
  Widget build(BuildContext context) {
    MentorMeUser? meUser = ref.watch(userProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back)),
        title: Row(
          children: [
            CachedNetworkImage(
              imageUrl: widget.postPicture,
              imageBuilder: (context, imageProvider) => Container(
                width: 50.0,
                height: 50.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(widget.caption)
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          // Main chat screen
          Expanded(
              child: StreamBuilder(
            stream: ref
                .watch(chatControllerProvider.notifier)
                .renderSinglGroupChatUi(widget.postId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                showSnackBar(context, "error in loading chat history");
                return Text("");
              } else {
                return ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data?.conversation.length ?? 0,
                  itemBuilder: (context, index) {
                    if (snapshot.data?.conversation.reversed.toList()[index]
                            ['senderId'] ==
                        meUser?.docId) {
                      return Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(snapshot.data?.conversation.reversed
                                .toList()[index]['message']),
                          ),
                        ),
                      );
                    } else {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(snapshot.data?.conversation.reversed
                                .toList()[index]['message']),
                          ),
                        ),
                      );
                    }
                  },
                );
              }
            },
          )),
          // TextField positioned at the bottom of the screen
          Container(
            decoration: BoxDecoration(
              color: Colors.grey,
              border: Border(
                top: BorderSide(
                  color: Colors.grey,
                  width: 3.0,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: chat,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Type a message...',
                      ),
                    ),
                  ),
                  Container(
                    child: CircleAvatar(
                      radius: 20.0,
                      backgroundColor: Colors.blue,
                      child: IconButton(
                        padding: EdgeInsets.all(10),
                        icon: Icon(Icons.send),
                        color: Colors.white,
                        onPressed: () async {
                          addNewMessageToConversation(
                              context: context,
                              postId: widget.postId,
                              messageText: chat.text,
                              senderId: meUser?.docId ?? "empty",
                              senderName: meUser?.name ?? "name");
                          chat.text = "";
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
