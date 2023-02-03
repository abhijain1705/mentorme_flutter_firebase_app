import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mentor_me/features/auth/controller/auth_controller.dart';
import 'package:mentor_me/features/home/chats/single_user_chat_screen.dart';
import 'package:mentor_me/modals/mentor_user.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/utils.dart';
import '../component/image_view.dart';
import 'followers_screen.dart';

class ThirdUserProfile extends ConsumerWidget {
  final dynamic user;
  const ThirdUserProfile({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    MentorMeUser? meUser = ref.watch(userProvider);

    return StreamBuilder(
        stream:
            ref.watch(authControllerProvider.notifier).userData(user['docId']),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          final followers = snapshot.data!.follower;
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.black,
              leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back)),
              title: Text(snapshot.data!.name),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ImageView(
                                  img: snapshot.data!.profile_picture)));
                    },
                    child: Center(
                      child: CachedNetworkImage(
                        imageUrl: snapshot.data!.profile_picture,
                        imageBuilder: (context, imageProvider) => Container(
                          width: 100.0,
                          height: 100.0,
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
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Text(
                      (snapshot.data!.name).toUpperCase(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Text(
                      (snapshot.data!.bio).toUpperCase(),
                      style: TextStyle(
                          fontWeight: FontWeight.w500, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 150,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.grey),
                                child: MaterialButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                FollowerScreen(
                                                    uid: snapshot.data!.docId,
                                                    type: "followers",
                                                    name:
                                                        snapshot.data!.name)));
                                  },
                                  child: Text(
                                      "${snapshot.data!.follower.length} followers"),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Container(
                                width: 150,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.grey),
                                child: MaterialButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                FollowerScreen(
                                                    uid: snapshot.data!.docId,
                                                    type: "following",
                                                    name:
                                                        snapshot.data!.name)));
                                  },
                                  child: Text(
                                      "${snapshot.data!.following.length} following"),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            decoration: new BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.blue),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                splashColor: Colors.white,
                                onTap: () {
                                  // Your code here
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SingleUserChatScreen(
                                                  user: snapshot.data)));
                                },
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                        'chat',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      SizedBox(width: 10),
                                      Icon(
                                        Icons.chat_bubble_outline,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          InkWell(
                            child: Container(
                              width: 250,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.black),
                              child: MaterialButton(
                                onPressed: () {
                                  if (followers.any((element) =>
                                      element['id'] == meUser?.docId)) {
                                    ref
                                        .watch(authControllerProvider.notifier)
                                        .removeFollowersAndFollowing(
                                            context,
                                            meUser?.name ?? "",
                                            meUser?.profile_picture ?? "",
                                            snapshot.data!.docId,
                                            snapshot.data!.profile_picture,
                                            snapshot.data!.name);
                                  } else {
                                    ref
                                        .watch(authControllerProvider.notifier)
                                        .addFollowersAndFollowing(
                                            context,
                                            meUser?.name ?? "",
                                            meUser?.profile_picture ?? "",
                                            snapshot.data!.docId,
                                            snapshot.data!.profile_picture,
                                            snapshot.data!.name);
                                  }
                                },
                                child: followers.any((element) =>
                                        element['id'] == meUser?.docId)
                                    ? Text(
                                        "unfollow",
                                        style: TextStyle(color: Colors.white),
                                      )
                                    : Text(
                                        "follow",
                                        style: TextStyle(color: Colors.white),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(snapshot.data!.profile_description),
                          const SizedBox(
                            height: 20,
                          ),
                          Wrap(
                            children: [
                              user["socials"]['twitter'].isNotEmpty
                                  ? RawMaterialButton(
                                      onPressed: () async {
                                        final Uri _url = Uri.parse(
                                            user["socials"]['twitter']);
                                        if (!await launchUrl(_url)) {
                                          showSnackBar(
                                              context, "url is not valid");
                                          return;
                                        } else {
                                          await launchUrl(_url);
                                        }
                                      },
                                      shape: CircleBorder(
                                        side: BorderSide(
                                          color: Colors.blue,
                                          width: 2.0,
                                        ),
                                      ),
                                      child: FaIcon(
                                        FontAwesomeIcons.twitter,
                                        color: Colors.blue,
                                      ),
                                    )
                                  : Text(""),
                              user["socials"]['facebook'].isNotEmpty
                                  ? RawMaterialButton(
                                      onPressed: () async {
                                        final Uri _url = Uri.parse(
                                            user["socials"]['facebook']);
                                        if (!await launchUrl(_url)) {
                                          showSnackBar(
                                              context, "url is not valid");
                                          return;
                                        } else {
                                          await launchUrl(_url);
                                        }
                                      },
                                      shape: CircleBorder(
                                        side: BorderSide(
                                          color: Colors.blue,
                                          width: 2.0,
                                        ),
                                      ),
                                      child: FaIcon(
                                        FontAwesomeIcons.facebook,
                                        color: Colors.blue,
                                      ),
                                    )
                                  : Text(""),
                              user["socials"]['youtube'].isNotEmpty
                                  ? RawMaterialButton(
                                      onPressed: () async {
                                        final Uri _url = Uri.parse(
                                            user["socials"]['youtube']);
                                        if (!await launchUrl(_url)) {
                                          showSnackBar(
                                              context, "url is not valid");
                                          return;
                                        } else {
                                          await launchUrl(_url);
                                        }
                                      },
                                      shape: CircleBorder(
                                        side: BorderSide(
                                          color: Colors.red,
                                          width: 2.0,
                                        ),
                                      ),
                                      child: FaIcon(
                                        FontAwesomeIcons.youtube,
                                        color: Colors.red,
                                      ),
                                    )
                                  : Text(""),
                              user["socials"]['instagram'].isNotEmpty
                                  ? RawMaterialButton(
                                      onPressed: () async {
                                        final Uri _url = Uri.parse(
                                            user["socials"]['instagram']);
                                        if (!await launchUrl(_url)) {
                                          showSnackBar(
                                              context, "url is not valid");
                                          return;
                                        } else {
                                          await launchUrl(_url);
                                        }
                                      },
                                      shape: CircleBorder(
                                        side: BorderSide(
                                          color: Colors.pink,
                                          width: 2.0,
                                        ),
                                      ),
                                      child: FaIcon(
                                        FontAwesomeIcons.instagram,
                                        color: Colors.pink,
                                      ),
                                    )
                                  : Text(""),
                              user["socials"]['github'].isNotEmpty
                                  ? RawMaterialButton(
                                      onPressed: () async {
                                        final Uri _url = Uri.parse(
                                            user["socials"]['github']);
                                        if (!await launchUrl(_url)) {
                                          showSnackBar(
                                              context, "url is not valid");
                                          return;
                                        } else {
                                          await launchUrl(_url);
                                        }
                                      },
                                      shape: CircleBorder(
                                        side: BorderSide(
                                          color: Colors.black,
                                          width: 2.0,
                                        ),
                                      ),
                                      child: FaIcon(
                                        FontAwesomeIcons.github,
                                        color: Colors.black,
                                      ),
                                    )
                                  : Text(""),
                              user["socials"]['linkedin'].isNotEmpty
                                  ? RawMaterialButton(
                                      onPressed: () async {
                                        final Uri _url = Uri.parse(
                                            user["socials"]['linkedin']);
                                        if (!await launchUrl(_url)) {
                                          showSnackBar(
                                              context, "url is not valid");
                                          return;
                                        } else {
                                          await launchUrl(_url);
                                        }
                                      },
                                      shape: CircleBorder(
                                        side: BorderSide(
                                          color: Colors.blue,
                                          width: 2.0,
                                        ),
                                      ),
                                      child: FaIcon(
                                        FontAwesomeIcons.linkedin,
                                        color: Colors.blue,
                                      ),
                                    )
                                  : Text("")
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
