import 'package:cloud_firestore/cloud_firestore.dart';

import '../modals/mentor_user.dart';

class DefaultUser {
  getDefaultUser() {
    return MentorMeUser(
        name: "",
        isOnline: false,
        bio: "bio",
        email: "",
        createdAt: Timestamp.now(),
        profile_picture: "",
        profile_description: "profile_description",
        socials: {
          'twitter': "",
          'linkedin': "",
          'github': "",
          'facebook': "",
          'instagram': "",
          'youtube': ""
        },
        location: "address",
        docId: "",
        follower: [],
        following: []);
  }
}
