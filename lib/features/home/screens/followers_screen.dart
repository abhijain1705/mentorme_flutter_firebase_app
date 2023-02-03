import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mentor_me/features/auth/controller/auth_controller.dart';
import 'package:mentor_me/features/home/screens/third_user.dart';
import 'package:mentor_me/modals/mentor_user.dart';

import '../chats/single_user_chat_screen.dart';

class FollowerScreen extends ConsumerStatefulWidget {
  final String name;
  final String uid;
  final String type;
  const FollowerScreen(
      {Key? key, required this.type, required this.uid, required this.name})
      : super(key: key);

  @override
  ConsumerState<FollowerScreen> createState() => _FollowerScreen();
}

class _FollowerScreen extends ConsumerState<FollowerScreen> {
  int _page = 1;
  int _pageSize = 20;
  int _pageCount = 1;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      getMoreFollowers();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.addListener(() {
      getMoreFollowers();
    });
  }

  getMoreFollowers() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        _page < _pageCount) {
      setState(() {
        _page++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back)),
          title: Text("${widget.name} ${widget.type}"),
        ),
        body: StreamBuilder<MentorMeUser>(
          stream:
              ref.watch(authControllerProvider.notifier).userData(widget.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            List<dynamic> followers = widget.type == "following"
                ? snapshot.data!.following
                : snapshot.data!.follower;
            int followerCount = followers.length;
            _pageCount = ((snapshot.data!.follower.length) / _pageSize).ceil();
            return ListView.builder(
              controller: _scrollController,
              itemCount: min(followerCount, _pageSize * _page),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFEEEEEE),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      margin: EdgeInsets.only(top: 10),
                      child: ListTile(
                        onTap: () async {
                          final user = await ref
                              .watch(authControllerProvider.notifier)
                              .fetchThirdUserData(
                                  context, followers[index]['id']);
                          Future.delayed(const Duration(milliseconds: 500), () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ThirdUserProfile(user: user)));
                          });
                        },
                        leading: CachedNetworkImage(
                          imageUrl: followers[index]['profile_pic'],
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
                        title: Text(followers[index]['name']),
                        trailing: RawMaterialButton(
                          fillColor: Colors.blue,
                          onPressed: () async {
                            final user = await ref
                                .watch(authControllerProvider.notifier)
                                .fetchThirdUserData(
                                    context, followers[index]['id']);
                            Future.delayed(const Duration(milliseconds: 500),
                                () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          SingleUserChatScreen(user: user)));
                            });
                          },
                          padding: EdgeInsets.all(8.0),
                          shape: CircleBorder(),
                          child: Icon(
                            Icons.chat_bubble_outline_outlined,
                            color: Colors.white,
                          ),
                        ),
                      )),
                );
              },
              physics: AlwaysScrollableScrollPhysics(),
              shrinkWrap: true,
            );
          },
        ));
  }
}
