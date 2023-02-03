import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mentor_me/features/auth/controller/auth_controller.dart';
import 'package:mentor_me/features/home/controller/chat_controller.dart';
import 'package:mentor_me/features/home/screens/third_user.dart';
import 'package:mentor_me/modals/mentor_user.dart';

import '../../../utils/utils.dart';

class SingleUserChatScreen extends ConsumerStatefulWidget {
  final dynamic user;
  const SingleUserChatScreen({Key? key, required this.user}) : super(key: key);

  @override
  ConsumerState<SingleUserChatScreen> createState() =>
      _SingleUserChatScreenState();
}

class _SingleUserChatScreenState extends ConsumerState<SingleUserChatScreen> {
  TextEditingController chat = TextEditingController();

  addMessageToConversation(
      {required BuildContext context,
      required String messageText,
      required String senderId,
      required String receiverId,
      required String senderName,
      required String senderImage,
      required String recieverName,
      required String recieverImage}) {
    ref.watch(chatControllerProvider.notifier).addMessageToConversation(
        context: context,
        messageText: messageText,
        senderId: senderId,
        receiverId: receiverId,
        senderImage: senderImage,
        senderName: senderName,
        recieverImage: recieverImage,
        recieverName: recieverName,
        senderPic: senderImage);
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
        title: StreamBuilder<MentorMeUser>(
            stream: ref
                .watch(authControllerProvider.notifier)
                .userData(widget.user['docId']),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              return IntrinsicWidth(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ThirdUserProfile(user: widget.user)));
                  },
                  child: Row(
                    children: [
                      CachedNetworkImage(
                        imageUrl: snapshot.data!.profile_picture,
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
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        children: [
                          Text(snapshot.data!.name),
                          IntrinsicWidth(
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: snapshot.data!.isOnline
                                        ? Colors.green
                                        : Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  snapshot.data!.isOnline
                                      ? "online"
                                      : "offline",
                                  style: TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
      body: Column(
        children: <Widget>[
          // Main chat screen
          Expanded(
              child: StreamBuilder(
            stream: ref
                .watch(chatControllerProvider.notifier)
                .renderSingleChatUi(
                    widget.user['docId'], meUser?.docId ?? "empty"),
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
                        onPressed: () {
                          // Send message
                          addMessageToConversation(
                              context: context,
                              messageText: chat.text,
                              senderId: meUser!.docId,
                              receiverId: widget.user['docId'],
                              senderName: meUser.name,
                              senderImage: meUser.profile_picture,
                              recieverName: widget.user['name'],
                              recieverImage: widget.user['profile_picture']);
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
