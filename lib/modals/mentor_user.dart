import 'package:flutter/foundation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class MentorMeUser {
  final String name;
  final String bio;
  final String email;
  final String profile_picture;
  final String profile_description;
  final Map<String, dynamic> socials;
  final String docId;
  final String location;
  final List<dynamic> following;
  final List<dynamic> follower;
  final Timestamp createdAt;
  final bool isOnline;
  MentorMeUser(
      {required this.name,
      required this.bio,
      required this.email,
      required this.profile_picture,
      required this.profile_description,
      required this.socials,
      required this.docId,
      required this.location,
      required this.isOnline,
      required this.follower,
      required this.createdAt,
      required this.following});

  MentorMeUser copyWith({
    String? name,
    String? bio,
    String? email,
    String? profile_picture,
    String? profile_description,
    Map<String, dynamic>? socials,
    String? docId,
    Timestamp? createdAt,
    String? location,
    bool? isOnline,
    List<dynamic>? follower,
    List<dynamic>? following,
  }) {
    return MentorMeUser(
        name: name ?? this.name,
        bio: bio ?? this.bio,
        email: email ?? this.email,
        profile_picture: profile_picture ?? this.profile_picture,
        profile_description: profile_description ?? this.profile_description,
        socials: socials ?? this.socials,
        docId: docId ?? this.docId,
        createdAt: createdAt ?? this.createdAt,
        location: location ?? this.location,
        isOnline: isOnline ?? this.isOnline,
        follower: follower ?? this.follower,
        following: following ?? this.following);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'bio': bio,
      'email': email,
      'profile_picture': profile_picture,
      'profile_description': profile_description,
      'socials': socials,
      'docId': docId,
      'createdAt': createdAt,
      'location': location,
      'isOnline': isOnline,
      'following': following,
      'follower': follower
    };
  }

  factory MentorMeUser.fromMap(Map<String, dynamic> map) {
    return MentorMeUser(
      name: map['name'] as String,
      bio: map['bio'] as String,
      email: map['email'] as String,
      createdAt: map['createdAt'] as Timestamp,
      profile_picture: map['profile_picture'] as String,
      profile_description: map['profile_description'] as String,
      socials:
          Map<String, dynamic>.from((map['socials'] as Map<String, dynamic>)),
      docId: map['docId'] as String,
      location: map['location'] as String,
      isOnline: map['isOnline'] as bool,
      following: List<dynamic>.from((map['following'] as List<dynamic>)),
      follower: List<dynamic>.from((map['follower'] as List<dynamic>)),
    );
  }

  @override
  String toString() {
    return 'MentorMeUser(name: $name, bio: $bio, createdAt: $createdAt, email: $email, profile_picture: $profile_picture, profile_description: $profile_description, socials: $socials, docId: $docId, location: $location, isOnline: $isOnline, follower: $follower, following: $following)';
  }

  @override
  bool operator ==(covariant MentorMeUser other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.bio == bio &&
        other.email == email &&
        other.profile_picture == profile_picture &&
        other.profile_description == profile_description &&
        other.createdAt == createdAt &&
        mapEquals(other.socials, socials) &&
        other.docId == docId &&
        other.location == location &&
        other.isOnline == isOnline &&
        listEquals(other.follower, follower) &&
        listEquals(other.following, following);
  }

  @override
  int get hashCode {
    return name.hashCode ^
        bio.hashCode ^
        email.hashCode ^
        profile_picture.hashCode ^
        profile_description.hashCode ^
        socials.hashCode ^
        docId.hashCode ^
        location.hashCode ^
        createdAt.hashCode ^
        isOnline.hashCode ^
        following.hashCode ^
        follower.hashCode;
  }
}
