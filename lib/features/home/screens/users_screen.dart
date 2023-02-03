import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mentor_me/features/auth/controller/auth_controller.dart';
import 'package:mentor_me/features/home/chats/single_user_chat_screen.dart';
import 'package:mentor_me/features/home/screens/third_user.dart';

import '../../../utils/utils.dart';
import '../chats/all_current_chats_user.dart';

class UserScreen extends ConsumerStatefulWidget {
  const UserScreen({super.key});

  @override
  ConsumerState<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends ConsumerState<UserScreen> {
  List<DocumentSnapshot> _docs = [];
  bool _isLoading = false;
  TextEditingController searchController = TextEditingController();
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

    try {
      QuerySnapshot initialDocs =
          await ref.watch(authControllerProvider.notifier).getInitialUserData();
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

      try {
        QuerySnapshot newDocs = await ref
            .watch(authControllerProvider.notifier)
            .getMoreUserData(_docs);

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

  searchUser(String search) async {
    Query? query;
    setState(() {
      query = ref
          .watch(authControllerProvider.notifier)
          .searchUsers(searchController.text);
      _docs = [];
      _isLoading = true;
    });
    try {
      QuerySnapshot initialUsers = await query!.get();
      setState(() {
        _docs = initialUsers.docs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showSnackBar(context, "error occured try again later");
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
            "Members",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),
          ),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.calendar_month)),
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AllCurrentChatsUserHas()));
              },
              icon: Icon(Icons.message)),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1.0),
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    searchUser(value);
                  },
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    hintText: "search member",
                    hintStyle: TextStyle(color: Colors.white),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: Colors.white, width: 0.0),
                    ),
                  ),
                ),
              ),
            ),
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
                if (_docs.isNotEmpty) {
                  return userBox(_docs, index);
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  userBox(docs, index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(30.0),
        ),
        margin: EdgeInsets.only(top: 10),
        child: ListTile(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ThirdUserProfile(
                          user: docs[index],
                        )));
          },
          title: Container(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CachedNetworkImage(
                          imageUrl: docs[index]['profile_picture'],
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
                            Text(docs[index]['name'].toUpperCase()),
                            Row(
                              children: [
                                Icon(Icons.location_on),
                                Text(docs[index]['location'])
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                    RawMaterialButton(
                      fillColor: Colors.blue,
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    SingleUserChatScreen(user: docs[index])));
                      },
                      padding: EdgeInsets.all(8.0),
                      shape: CircleBorder(),
                      child: Icon(
                        Icons.chat_bubble_outline_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(docs[index]['profile_description'])
              ],
            ),
          ),
        ),
      ),
    );
  }
}
