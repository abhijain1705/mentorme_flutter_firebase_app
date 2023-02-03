import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mentor_me/constants/default_user.dart';
import 'package:mentor_me/features/auth/controller/auth_controller.dart';
import 'package:mentor_me/features/home/component/image_view.dart';
import 'package:mentor_me/features/home/screens/edit_screen.dart';
import 'package:mentor_me/features/home/screens/followers_screen.dart';
import 'package:mentor_me/modals/mentor_user.dart';
import 'package:mentor_me/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class UserProfile extends ConsumerStatefulWidget {
  const UserProfile({super.key});

  @override
  ConsumerState<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends ConsumerState<UserProfile> {

  @override
  Widget build(BuildContext context) {
    MentorMeUser? meUser = ref.watch(userProvider);
    DefaultUser defaultUser = DefaultUser();
    int profileCompletion = 0;

    return StreamBuilder(
        stream: ref
            .watch(authControllerProvider.notifier)
            .userData(meUser?.docId ?? ""),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.data!.bio != "bio") {
            profileCompletion += 25;
          }

          if (snapshot.data!.location != "address") {
            profileCompletion += 25;
          }

          if (snapshot.data!.profile_description != "profile_description") {
            profileCompletion += 25;
          }

          if (snapshot.data!.socials.isNotEmpty) {
            profileCompletion += 25;
          }
          

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              centerTitle: false,
              title: Text(
                "Profile",
                style:
                    TextStyle(fontWeight: FontWeight.w800, color: Colors.black),
              ),
              actions: [
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.share,
                      color: Colors.black,
                    )),
                IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (context) => Container(
                                height: 100,
                                child: TextButton(
                                    onPressed: () {
                                      ref
                                          .watch(
                                              authControllerProvider.notifier)
                                          .logout();
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      "log out",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 20),
                                    )),
                              ));
                    },
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.black,
                    ))
              ],
              toolbarHeight: 100,
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
                      snapshot.data!.name.toUpperCase(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Text(
                      snapshot.data!.bio.toUpperCase(),
                      style: TextStyle(
                          fontWeight: FontWeight.w500, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Container(
                        width: profileCompletion == 100 ? 150 : 200,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: profileCompletion == 100
                                ? Colors.blue
                                : Color.fromARGB(255, 88, 94, 147)),
                        child: MaterialButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditScreen(
                                            meUser: meUser ??
                                                defaultUser.getDefaultUser(),
                                          )));
                            },
                            child: Row(
                              children: [
                                Text(
                                  profileCompletion == 100
                                      ? 'edit profile'
                                      : 'complete profile',
                                  style: TextStyle(color: Colors.white),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                )
                              ],
                            ))),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  profileCompletion != 100
                      ? Center(
                          child: Container(
                            height: 200,
                            width: 200,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.grey),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "complete your profile to make clearly visible for others.",
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "your profile is $profileCompletion % completed.",
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : Center(
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
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Colors.grey),
                                      child: MaterialButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      FollowerScreen(
                                                          uid: snapshot
                                                              .data!.docId,
                                                          type: "followers",
                                                          name: snapshot
                                                              .data!.name)));
                                        },
                                        child: Text("${snapshot.data!.follower.length} followers"),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Container(
                                      width: 150,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Colors.grey),
                                      child: MaterialButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      FollowerScreen(
                                                          uid: snapshot
                                                              .data!.docId,
                                                          type: "following",
                                                          name: snapshot
                                                              .data!.name)));
                                        },
                                        child: Text("${snapshot.data!.following.length} followers"),
                                      ),
                                    )
                                  ],
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
                                    meUser?.socials['twitter'].isNotEmpty
                                        ? RawMaterialButton(
                                            onPressed: () async {
                                              final Uri _url = Uri.parse(
                                                  meUser?.socials['twitter']);
                                              if (!await launchUrl(_url)) {
                                                showSnackBar(context,
                                                    "url is not valid");
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
                                    meUser?.socials['facebook'].isNotEmpty
                                        ? RawMaterialButton(
                                            onPressed: () async {
                                              final Uri _url = Uri.parse(
                                                  meUser?.socials['facebook']);
                                              if (!await launchUrl(_url)) {
                                                showSnackBar(context,
                                                    "url is not valid");
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
                                    meUser?.socials['github'].isNotEmpty
                                        ? RawMaterialButton(
                                            onPressed: () async {
                                              final Uri _url = Uri.parse(
                                                  meUser?.socials['github']);
                                              if (!await launchUrl(_url)) {
                                                showSnackBar(context,
                                                    "url is not valid");
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
                                    meUser?.socials['youtube'].isNotEmpty
                                        ? RawMaterialButton(
                                            onPressed: () async {
                                              final Uri _url = Uri.parse(
                                                  meUser?.socials['youtube']);
                                              if (!await launchUrl(_url)) {
                                                showSnackBar(context,
                                                    "url is not valid");
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
                                    meUser?.socials['instagram'].isNotEmpty
                                        ? RawMaterialButton(
                                            onPressed: () async {
                                              final Uri _url = Uri.parse(
                                                  meUser?.socials['instagram']);
                                              if (!await launchUrl(_url)) {
                                                showSnackBar(context,
                                                    "url is not valid");
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
                                    meUser?.socials['linkedin'].isNotEmpty
                                        ? RawMaterialButton(
                                            onPressed: () async {
                                              final Uri _url = Uri.parse(
                                                  meUser?.socials['linkedin']);
                                              if (!await launchUrl(_url)) {
                                                showSnackBar(context,
                                                    "url is not valid");
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
