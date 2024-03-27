import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:les_social/models/enum/message_type.dart';

class Message {
  String? content;
  String? senderUid;
  String? messageId;
  String? chatId; // Dodane pole chatId
  MessageType? type;
  String? imageUrl; // Dodane pole imageUrl lub imagePath
  Timestamp? time;

  Message({
    this.content,
    this.senderUid,
    this.messageId,
    this.chatId,
    this.type,
    this.imageUrl,
    this.time,
  });

  Message.fromJson(Map<String, dynamic> json) {
    content = json['content'];
    senderUid = json['senderUid'];
    messageId = json['messageId'];
    chatId = json['chatId']; // Dodane pole chatId
    if (json['type'] == 'text') {
      type = MessageType.TEXT;
    } else if (json['type'] == 'image') {
      type = MessageType.IMAGE;
      imageUrl = json['imageUrl']; // Dodane pole imageUrl lub imagePath
    }
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['content'] = this.content;
    data['senderUid'] = this.senderUid;
    data['messageId'] = this.messageId;
    data['chatId'] = this.chatId; // Dodane pole chatId
    if (this.type == MessageType.TEXT) {
      data['type'] = 'text';
    } else if (this.type == MessageType.IMAGE) {
      data['type'] = 'image';
      data['imageUrl'] = this.imageUrl; // Dodane pole imageUrl lub imagePath
    }
    data['time'] = this.time;
    return data;
  }
}
