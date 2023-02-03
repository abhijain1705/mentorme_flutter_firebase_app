import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mentor_me/features/auth/controller/auth_controller.dart';
import 'package:mentor_me/features/home/chats/single_user_chat_screen.dart';
import 'package:mentor_me/features/home/controller/chat_controller.dart';
import 'package:mentor_me/modals/mentor_user.dart';

import '../../../utils/utils.dart';
import '../component/custom_function.dart';

class AllCurrentChatsUserHas extends ConsumerStatefulWidget {
  const AllCurrentChatsUserHas({super.key});

  @override
  ConsumerState<AllCurrentChatsUserHas> createState() =>
      _AllCurrentChatsUserHas();
}

class _AllCurrentChatsUserHas extends ConsumerState<AllCurrentChatsUserHas> {
  List<DocumentSnapshot> _docs = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getInitialDocs();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _getInitialDocs() async {
    setState(() {
      _isLoading = true;
    });
    MentorMeUser? meUser = ref.watch(userProvider);

    try {
      QuerySnapshot initialDocs = await ref
          .watch(chatControllerProvider.notifier)
          .getInitialChatsData(20, meUser?.docId ?? 'empty');
      setState(() {
        _docs = initialDocs.docs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      showSnackBar(context, "error occured try again later");
    }
  }

  void _getMoreDocs() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
      MentorMeUser? meUser = ref.watch(userProvider);

      try {
        QuerySnapshot newDocs = await ref
            .watch(chatControllerProvider.notifier)
            .getMoreChatsData(20, _docs, meUser?.docId ?? "");

        setState(() {
          _docs.addAll(newDocs.docs);
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        showSnackBar(context, "error occured try again later");
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _getMoreDocs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 100,
          backgroundColor: Colors.black,
          centerTitle: false,
          title: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "Messages",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _docs.length,
                itemBuilder: (BuildContext context, int index) {
                  if (_docs.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    String finalMessage = _docs[index]['conversation']
                        [_docs[index]['conversation'].length - 1]['message'];

                    if (finalMessage.length > 10) {
                      finalMessage = finalMessage.substring(0, 10) + "...";
                    }
                    Timestamp lastMsgTime = _docs[index]['conversation']
                        [_docs[index]['conversation'].length - 1]['timeStamp'];
                    String timeToLastMsg =
                        getDate(lastMsgTime.millisecondsSinceEpoch);
                    return Container(
                      margin: EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: Colors.black, width: 1)),
                      ),
                      child: ListTile(
                        onTap: () async {
                          final user = await ref
                              .watch(authControllerProvider.notifier)
                              .fetchThirdUserData(
                                  context, _docs[index]['reciverDocId']);
                          Future.delayed(const Duration(milliseconds: 500), () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        SingleUserChatScreen(user: user)));
                          });
                        },
                        title: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: _docs[index]['reciverPic'],
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        width: 50.0,
                                        height: 50.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.black, width: 2),
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
                                      width: 20,
                                    ),
                                    Text(_docs[index]['reciverName']),
                                  ],
                                ),
                                Text(timeToLastMsg)
                              ],
                            ),
                            Text(
                              finalMessage,
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            )
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ));
  }
}
