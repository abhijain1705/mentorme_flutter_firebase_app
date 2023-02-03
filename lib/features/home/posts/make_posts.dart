import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:mentor_me/features/auth/controller/auth_controller.dart';
import 'package:mentor_me/features/home/component/text_component.dart';
import 'package:mentor_me/features/home/controller/post_controller.dart';
import 'package:mentor_me/modals/mentor_user.dart';
import 'package:mentor_me/utils/utils.dart';

class MakePostScreen extends ConsumerStatefulWidget {
  const MakePostScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MakePostScreen> createState() => _MakePostScreenState();
}

class _MakePostScreenState extends ConsumerState<MakePostScreen> {
  File? _image;

  _pickImages() async {
    final XFile? images =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    File _imagesFile;
    if (images != null) {
      _imagesFile = File(images.path);
      setState(() {
        _image = _imagesFile;
      });
    } else {
      showSnackBar(context, "you can only select images from 1-10");
    }
  }

  bool isLoading = false;
  addNewPost(
      {required BuildContext context,
      required File? images,
      required String makerPic,
      required String makerName,
      required String makerId,
      required String write,
      required String caption}) async {
    setState(() {
      isLoading = true;
    });
    return await ref.watch(postControllerProvider.notifier).addPostToApp(
        context: context,
        image: _image,
        makerPic: makerPic,
        makerName: makerName,
        makerId: makerId,
        write: write,
        caption: caption,
        callback: () {
          setState(() {
            isLoading = false;
          });
        });
  }

  TextEditingController caption = TextEditingController();
  TextEditingController describe = TextEditingController();

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
          title: Text("write experience"),
          actions: [
            Container(
                width: 100,
                margin: EdgeInsets.all(10),
                height: 50,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.blue),
                child: MaterialButton(
                    onPressed: () async {
                      return await addNewPost(
                          context: context,
                          images: _image,
                          makerPic: meUser?.profile_picture ?? "",
                          makerName: meUser?.name ?? "",
                          makerId: meUser?.docId ?? "",
                          write: describe.text,
                          caption: caption.text);
                    },
                    child: isLoading
                        ? CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            "post",
                            style: TextStyle(color: Colors.white),
                          ))),
          ],
        ),
        body: TextComponent(
          describe: describe,
          image: _image,
          caption: caption,
        ),
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
                border: Border(top: BorderSide(width: 1, color: Colors.black))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                OutlinedButton.icon(
                    onPressed: () => _pickImages(),
                    icon: Icon(
                      Icons.browse_gallery_outlined,
                      color: Colors.black,
                    ),
                    label: Text(
                      "Gallery",
                      style: TextStyle(color: Colors.black),
                    )),
              ],
            ),
          ),
        ));
  }
}
