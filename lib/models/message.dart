
import 'package:les_social/models/enum/message_type.dart';
import 'package:les_social/services/chat_service.dart';

class Message {
  String? receiverUid;
  String? receiverPhotoUrl;
  String? content;
  String? chatId;
  String? senderUid;
  String? senderUsername;
  String? senderPhotoUrl;
  String? messageId;
  MessageType? type;
  DateTime? time;

  Message({
    this.content,
    this.senderUid,
    this.senderUsername,
    this.senderPhotoUrl,
    this.receiverUid,
    this.receiverPhotoUrl,
    this.messageId,
    this.type,
    this.time,
    this.chatId
  });

  // Konstruktor deserializujący z JSON-a
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      content: json['content'],
      senderUid: json['senderUid'],
      senderUsername: json['senderUsername'],
      senderPhotoUrl: json['senderPhotoUrl'],
      receiverUid: json['receiverUid'],
      receiverPhotoUrl: json['receiverPhotoUrl'],
      messageId: json['messageId'],
      chatId: json['chatId'],
      type: _parseMessageType(json['type']),
      time: _parseDateTime(json['time']),
    );
  }

  // Metoda pomocnicza do parsowania MessageType
  static MessageType? _parseMessageType(String? typeString) {
    if (typeString == 'text') {
      return MessageType.TEXT;
    } else if (typeString == 'image') {
      return MessageType.IMAGE;
    }
    return null;
  }

  // Metoda pomocnicza do parsowania DateTime
  static DateTime? _parseDateTime(dynamic timeValue) {
    if (timeValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(timeValue);
    } else if (timeValue is String) {
      return DateTime.parse(timeValue);
    } else if (timeValue is DateTime) {
      return timeValue;
    }
    return null;
  }

  // Metoda serializująca do JSON-a
  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'senderUid': senderUid,
      'senderUsername': senderUsername,
      'senderPhotoUrl': senderPhotoUrl,
      'receiverUid': receiverUid,
      'receiverPhotoUrl': receiverPhotoUrl,
      'messageId': messageId,
      'chatId': chatId,
      'type': type == MessageType.TEXT ? 'text' : 'image',
      'time': time?.millisecondsSinceEpoch,
    };
  }

  // Statyczna metoda zwracająca strumień wiadomości dla danego chatId
  static Stream<List<Message>> messageListStream(String chatId) {
    return ChatService().getMessageStream(chatId);
  }
}
