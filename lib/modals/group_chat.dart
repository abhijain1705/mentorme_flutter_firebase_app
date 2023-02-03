// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class GroupChat {
  final List<Map<String, dynamic>> conversation;
  GroupChat({
    required this.conversation,
  });

  GroupChat copyWith({
    List<Map<String, dynamic>>? conversation,
  }) {
    return GroupChat(
      conversation: conversation ?? this.conversation,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'conversation': conversation,
    };
  }

  factory GroupChat.fromMap(Map<String, dynamic> map) {
    return GroupChat(
      conversation: List<Map<String, dynamic>>.from(
          map['conversation'].map((e) => e as Map<String, dynamic>)),
    );
  }

  String toJson() => json.encode(toMap());

  factory GroupChat.fromJson(String source) =>
      GroupChat.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'GroupChat(conversation: $conversation)';

  @override
  bool operator ==(covariant GroupChat other) {
    if (identical(this, other)) return true;

    return listEquals(other.conversation, conversation);
  }

  @override
  int get hashCode => conversation.hashCode;
}
