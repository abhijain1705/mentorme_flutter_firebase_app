import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mentor_me/features/auth/controller/auth_controller.dart';
import 'package:mentor_me/modals/mentor_user.dart';

import '../../../utils/utils.dart';

class EditScreen extends ConsumerStatefulWidget {
  final MentorMeUser meUser;
  const EditScreen({Key? key, required this.meUser}) : super(key: key);

  @override
  ConsumerState<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends ConsumerState<EditScreen> {
  late TextEditingController name;
  late TextEditingController bio;
  late TextEditingController email;
  late TextEditingController location;
  late TextEditingController about;
  late TextEditingController twitter;
  late TextEditingController facebook;
  late TextEditingController instagram;
  late TextEditingController youtube;
  late TextEditingController linkedin;
  late TextEditingController github;
  File? profile_image;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.meUser.name);
    bio = TextEditingController(text: widget.meUser.bio);
    email = TextEditingController(text: widget.meUser.email);
    location = TextEditingController(text: widget.meUser.location);
    about = TextEditingController(text: widget.meUser.profile_description);
    twitter = TextEditingController(text: widget.meUser.socials['twitter']);
    facebook = TextEditingController(text: widget.meUser.socials['facebook']);
    instagram = TextEditingController(text: widget.meUser.socials['instagram']);
    youtube = TextEditingController(text: widget.meUser.socials['youtube']);
    linkedin = TextEditingController(text: widget.meUser.socials['linkedin']);
    github = TextEditingController(text: widget.meUser.socials['github']);
  }

  Future pickProfile() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        File? img = File(image.path);
        setState(() {
          profile_image = img;
        });
      }
    } on PlatformException catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  bool isValidEmail(String email) {
    final RegExp regex = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    return regex.hasMatch(email);
  }

  bool isValidLink(String link) {
    final RegExp regex = RegExp(r"^(http|https):\/\/[^\s]+");
    return regex.hasMatch(link);
  }

  bool isLoading = false;

  editProfile(WidgetRef ref, BuildContext context) {
    setState(() {
      isLoading = true;
    });
    if (name.text == widget.meUser.name &&
        bio.text == widget.meUser.bio &&
        email.text == widget.meUser.email &&
        location.text == widget.meUser.location &&
        about.text == widget.meUser.profile_description &&
        twitter.text == widget.meUser.socials['twitter'] &&
        facebook.text == widget.meUser.socials['facebook'] &&
        instagram.text == widget.meUser.socials['instagram'] &&
        youtube.text == widget.meUser.socials['youtube'] &&
        linkedin.text == widget.meUser.socials['linkedin'] &&
        github.text == widget.meUser.socials['github'] &&
        profile_image == null) {
      return;
    }

    if (!isValidEmail(email.text)) {
      showSnackBar(context, "email has to be vaild");
      return;
    }

    if ((!isValidLink(twitter.text) && twitter.text.isNotEmpty) ||
        (!isValidLink(facebook.text) && facebook.text.isNotEmpty) ||
        (!isValidLink(linkedin.text) && linkedin.text.isNotEmpty) ||
        (!isValidLink(instagram.text) && instagram.text.isNotEmpty) ||
        (!isValidLink(youtube.text) && youtube.text.isNotEmpty) ||
        (!isValidLink(github.text) && github.text.isNotEmpty)) {
      showSnackBar(context, "social media handle link has to be valid");
      return;
    }

    Map<String, dynamic> updatedSocials = {
      'twitter': twitter.text,
      'linkedin': linkedin.text,
      'github': github.text,
      'facebook': facebook.text,
      'instagram': instagram.text,
      'youtube': youtube.text
    };

    ref.watch(authControllerProvider.notifier).editUserProfile(
        name: name.text,
        bio: bio.text,
        email: email.text,
        location: location.text,
        about: about.text,
        socials: updatedSocials,
        context: context,
        meUser: widget.meUser,
        profile_picture: profile_image,
        callback: () {
          setState(() {
            isLoading = false;
          });
        });
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
        title: Text("Edit Profile"),
        actions: [
          Container(
              width: 100,
              margin: EdgeInsets.all(10),
              height: 50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20), color: Colors.blue),
              child: MaterialButton(
                  onPressed: () => editProfile(ref, context),
                  child: isLoading
                      ? CircularProgressIndicator()
                      : Text(
                          "save",
                          style: TextStyle(color: Colors.white),
                        ))),
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
              child: Column(
            children: [
              Center(
                child: profile_image == null
                    ? CachedNetworkImage(
                        imageUrl: widget.meUser.profile_picture,
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
                      )
                    : Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: FileImage(profile_image!.absolute),
                        ),
                      ),
              ),
              const SizedBox(
                height: 10,
              ),
              OutlinedButton(
                child: Text("upload"),
                onPressed: () {
                  // Perform some action here
                  pickProfile();
                },
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: name,
                maxLength: 25,
                decoration: InputDecoration(
                  hintText: "write your name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              TextField(
                controller: bio,
                maxLength: 100,
                decoration: InputDecoration(
                  hintText: "write your current working status",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              TextField(
                controller: email,
                maxLength: 25,
                decoration: InputDecoration(
                  hintText: "write your email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              TextField(
                controller: location,
                maxLength: 25,
                decoration: InputDecoration(
                  hintText: "Enter your location,for eg. jaipur, rajasthan",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              TextField(
                controller: about,
                maxLength: 500,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "write about yourself,",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: twitter,
                decoration: InputDecoration(
                  icon: FaIcon(FontAwesomeIcons.twitter),
                  hintText: "twitter handle",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: facebook,
                decoration: InputDecoration(
                  icon: FaIcon(FontAwesomeIcons.facebook),
                  hintText: "facebook handle",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: instagram,
                decoration: InputDecoration(
                  icon: FaIcon(FontAwesomeIcons.instagram),
                  hintText: "instagram handle",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: youtube,
                decoration: InputDecoration(
                  icon: FaIcon(FontAwesomeIcons.youtube),
                  hintText: "youtube handle",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: linkedin,
                decoration: InputDecoration(
                  icon: FaIcon(FontAwesomeIcons.linkedin),
                  hintText: "linkedin handle",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: github,
                decoration: InputDecoration(
                  icon: FaIcon(FontAwesomeIcons.github),
                  hintText: "github handle",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ],
          ))),
    );
  }
}
