// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String makerPic;
  final String makerName;
  final String makerId;
  final String write;
  final String postId;
  final String caption;
  final Timestamp createdAt;
  final String picture;
  PostModel({
    required this.makerPic,
    required this.makerName,
    required this.makerId,
    required this.write,
    required this.postId,
    required this.caption,
    required this.createdAt,
    required this.picture,
  });

  PostModel copyWith({
    String? makerPic,
    String? makerName,
    String? makerId,
    String? write,
    String? caption,
    String? postId,
    Timestamp? createdAt,
    String? picture,
  }) {
    return PostModel(
      makerPic: makerPic ?? this.makerPic,
      makerName: makerName ?? this.makerName,
      makerId: makerId ?? this.makerId,
      write: write ?? this.write,
      postId: postId ?? this.postId,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
      picture: picture ?? this.picture,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'makerPic': makerPic,
      'makerName': makerName,
      'makerId': makerId,
      'write': write,
      'postId': postId,
      'createdAt': createdAt,
      'caption': caption,
      'picture': picture,
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
        makerPic: map['makerPic'] as String,
        makerName: map['makerName'] as String,
        makerId: map['makerId'] as String,
        write: map['write'] as String,
        postId: map['postId'] as String,
        createdAt: map['createdAt'] as Timestamp,
        caption: map['caption'] as String,
        picture: map['picture'] as String);
  }

  String toJson() => json.encode(toMap());

  factory PostModel.fromJson(String source) =>
      PostModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'PostModel(makerPic: $makerPic, postId: $postId, createdAt: $createdAt, makerName: $makerName, makerId: $makerId, write: $write, caption: $caption, picture: $picture)';
  }

  @override
  bool operator ==(covariant PostModel other) {
    if (identical(this, other)) return true;

    return other.makerPic == makerPic &&
        other.makerName == makerName &&
        other.makerId == makerId &&
        other.write == write &&
        other.postId == postId &&
        other.caption == caption &&
        other.createdAt == createdAt &&
        other.picture == picture;
  }

  @override
  int get hashCode {
    return makerPic.hashCode ^
        makerName.hashCode ^
        makerId.hashCode ^
        write.hashCode ^
        postId.hashCode ^
        caption.hashCode ^
        createdAt.hashCode ^
        picture.hashCode;
  }
}
