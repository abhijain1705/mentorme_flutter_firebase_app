import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mentor_me/features/home/chats/all_current_chats_user.dart';
import 'package:mentor_me/features/home/chats/post_chat.dart';
import 'package:mentor_me/features/home/controller/post_controller.dart';
import 'package:mentor_me/features/home/posts/make_posts.dart';
import 'package:mentor_me/features/home/screens/third_user.dart';
import 'package:mentor_me/modals/mentor_user.dart';
import '../../../constants/firebase_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/utils.dart';
import '../../auth/controller/auth_controller.dart';

class PostScreen extends ConsumerStatefulWidget {
  final void Function(int index) onTapped;
  const PostScreen({Key? key, required this.onTapped}) : super(key: key);

  @override
  ConsumerState<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends ConsumerState<PostScreen>
    with SingleTickerProviderStateMixin {
  late final TabController tabController;
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
  void initState() {
    tabController = TabController(length: 1, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    tabController.dispose();
    super.dispose();
  }

  void _getInitialDocs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot initialDocs = await ref
          .watch(postControllerProvider.notifier)
          .getInitialPostsData();
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
            .watch(postControllerProvider.notifier)
            .getMorePostsData(_docs);

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

  TextEditingController caption = TextEditingController();

  bool _isExpanded = false;

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    MentorMeUser? meUser = ref.watch(userProvider);
    return Scaffold(
      backgroundColor: Color(0xFFE3F2FD),
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.all(20.0),
          child: CachedNetworkImage(
            imageUrl: ImageConstants.flat_logo,
            fit: BoxFit.cover,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AllCurrentChatsUserHas()));
              },
              icon: Icon(Icons.message)),
        ],
        bottom: TabBar(
          isScrollable: true,
          labelColor: Colors.white,
          indicatorColor: Colors.white,
          labelStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          tabs: [
            Tab(
              text: "Chats",
            ),
          ],
          controller: tabController,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => MakePostScreen()));
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _docs.length,
              itemBuilder: (context, index) {
                if (_docs.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      margin: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        title: Container(
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () async {
                                  if (_docs[index]['makerId'] ==
                                      (meUser?.docId ?? "empty")) {
                                    widget.onTapped(2);
                                  } else {
                                    final user = await ref
                                        .watch(authControllerProvider.notifier)
                                        .fetchThirdUserData(
                                            context, _docs[index]['makerId']);
                                    Future.delayed(
                                        const Duration(milliseconds: 500), () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ThirdUserProfile(
                                                      user: user)));
                                    });
                                  }
                                },
                                child: Row(
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: _docs[index]['makerPic'],
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        width: 30.0,
                                        height: 30.0,
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
                                      width: 10,
                                    ),
                                    Text(_docs[index]['makerName'])
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              _docs[index]['picture'].length > 0
                                  ? CachedNetworkImage(
                                        imageUrl: _docs[index]['picture'],
                                        placeholder: (context, url) =>
                                            const CircularProgressIndicator(),
                                        errorWidget: (context, url, error) {
                                          return Icon(Icons.error);
                                        },
                                      )
                                  : Text(""),
                              const SizedBox(
                                height: 10,
                              ),
                              ExpansionTile(
                                  title: Text(_docs[index]['caption']),
                                  initiallyExpanded: false,
                                  onExpansionChanged: (value) =>
                                      _toggleExpansion(),
                                  children: [
                                    AnimatedContainer(
                                      duration: Duration(milliseconds: 500),
                                      height: _isExpanded ? 100 : 0,
                                      child: _docs[index]['write'].length > 0
                                          ? Text(_docs[index]['write'])
                                          : Text("data"),
                                    ),
                                    TextButton(onPressed: () {
                                      Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => PostChat(
                                                    caption: _docs[index]
                                                        ['caption'],
                                                    postPicture: _docs[index]
                                                        ['picture'],
                                                        postId: _docs[index]['postId'],)));
                                    }, child: Text("view chats"))
                                  ]),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
