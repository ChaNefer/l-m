import 'dart:convert';

class Chat {
  final String chatId;
  final List<String> userIds;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageSender;

  Chat({
    required this.chatId,
    required this.userIds,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSender,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      chatId: json['chat_id'],
      userIds: List<String>.from(jsonDecode(json['user_ids'])),
      lastMessage: json['last_message'],
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'])
          : null,
      lastMessageSender: json['last_message_sender'],
    );
  }
}



