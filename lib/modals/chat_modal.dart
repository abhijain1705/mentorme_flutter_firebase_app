// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class ChatModel {
  final String reciverName;
  final String reciverPic;
  final String reciverDocId;
  final List<Map<String, dynamic>> conversation;
  ChatModel({
    required this.reciverName,
    required this.reciverPic,
    required this.conversation,
    required this.reciverDocId,
  });

  ChatModel copyWith({
    String? reciverName,
    String? reciverPic,
    String? reciverDocId,
    List<Map<String, dynamic>>? conversation,
  }) {
    return ChatModel(
      reciverName: reciverName ?? this.reciverName,
      reciverPic: reciverPic ?? this.reciverPic,
      reciverDocId: reciverDocId ?? this.reciverDocId,
      conversation: conversation ?? this.conversation,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'reciverName': reciverName,
      'reciverPic': reciverPic,
      'reciverDocId': reciverDocId,
      'conversation': conversation,
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
        conversation: List<Map<String, dynamic>>.from(
            map['conversation'].map((e) => e as Map<String, dynamic>)),
        reciverName: map['reciverName'] as String,
        reciverDocId: map['reciverDocId'] as String,
        reciverPic: map['reciverPic'] as String);
  }

  String toJson() => json.encode(toMap());

  factory ChatModel.fromJson(String source) =>
      ChatModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'ChatModel(reciverName: $reciverName, reciverPic: $reciverPic, reciverDocId: $reciverDocId, conversation: $conversation)';

  @override
  bool operator ==(covariant ChatModel other) {
    if (identical(this, other)) return true;

    return other.reciverName == reciverName &&
        other.reciverPic == reciverPic &&
        other.reciverDocId == reciverDocId &&
        listEquals(other.conversation, conversation);
  }

  @override
  int get hashCode =>
      reciverName.hashCode ^ reciverPic.hashCode ^ reciverDocId.hashCode ^ conversation.hashCode;
}
