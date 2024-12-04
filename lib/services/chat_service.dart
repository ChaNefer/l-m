import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:les_social/models/message.dart';
import 'package:http/http.dart' as http;

class ChatService {
  static const String baseUrl = 'https://lesmind.com/api';

  StreamController<List<Message>> _messageStreamController = StreamController<List<Message>>();
  StreamController<Map<String, dynamic>> _chatStreamController = StreamController<Map<String, dynamic>>();

  Stream<List<Message>> getMessageStream(String chatId) async* {
    final response = await http.get(Uri.parse('$baseUrl/chats/get_messages.php?chatId=$chatId'));
    if (response.statusCode == 200) {
      List<dynamic> messagesJson = json.decode(response.body)['messages'];
      List<Message> messages = messagesJson.map((msg) => Message.fromJson(msg)).toList();
      yield messages;
    } else {
      throw Exception('Nie udało się załadować wiadomości');
    }
  }

  // Future<List<Message>> fetchMessages(String chatId) async {
  //   final response = await http.post(
  //     Uri.parse('https://lesmind.com/api/talks/get_messages.php'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({'chat_id': chatId}),
  //   );
  //
  //   // if (response.statusCode == 200) {
  //   //   final data = jsonDecode(response.body);
  //   //   // print("Odpowiedz z serwera: $data" );
  //   //   if (data['status'] == 'success') {
  //   //     return List<Map<String, dynamic>>.from(data['messages']);
  //   //   } else {
  //   //     throw Exception(data['message']);
  //   //   }
  //   // } else {
  //   //   throw Exception('Błąd połączenia z serwerem');
  //   // }
  //
  //   if (response.statusCode == 200) {
  //     var messagesJson = jsonDecode(response.body);
  //     //print("Comments fetched: $messagesJson");
  //
  //     // Sprawdź, czy messagesJson jest listą
  //     if (messagesJson is List) {
  //       // Mapuj JSON na instancje CommentModel
  //       return messagesJson.map((comment) => Message.fromJson(comment)).toList();
  //     } else {
  //       throw Exception('Invalid response structure: $messagesJson');
  //     }
  //   } else {
  //     throw Exception('Failed to load comments: ${response.body}');
  //   }
  //
  // }

  Stream<List<dynamic>> getUserChatsStream(String userId) async* {
    final response = await http.get(Uri.parse('$baseUrl/chats/get_chats.php?userId=$userId'));
    if (response.statusCode == 200) {
      yield json.decode(response.body)['chats'];
    } else {
      throw Exception('Nie udało się załadować czatów');
    }
  }

  // Future<void> sendMessage(Message message, String chatId) async {
  //   final response = await http.post(
  //     Uri.parse('$baseUrl/send_message.php'),
  //     body: {
  //       'chat_id': chatId,
  //       'content': message.content,
  //       'sender_id': message.senderUid,
  //       'time': message.time?.toIso8601String() ?? '',
  //       // Add other fields required by your API
  //     },
  //   );
  //
  //   if (response.statusCode == 200) {
  //     //print('Message sent successfully');
  //   } else {
  //     throw Exception('Failed to send message');
  //   }
  // }

  // Future<String> sendFirstMessage(String recipient, Message message) async {
  //   final response = await http.post(
  //     Uri.parse('$baseUrl/send_first_message.php'),
  //     body: {
  //       'recipient_id': recipient,
  //       'content': message.content,
  //       'sender_id': message.senderUid,
  //       'time': message.time?.toIso8601String() ?? '',
  //       // Add other fields required by your API
  //     },
  //   );
  //
  //   if (response.statusCode == 200) {
  //     return response.body;
  //   } else {
  //     throw Exception('Failed to send first message');
  //   }
  // }

  Future<String> uploadImage(File image, String chatId) async {
    // Implementacja wysyłania obrazu do backendu
    throw UnimplementedError('Upload image not implemented');
  }

  Future<void> setUserRead(String chatId, String userId, int count) async {
    final response = await http.post(
      Uri.parse('$baseUrl/set_user_read.php'),
      body: {
        'chat_id': chatId,
        'user_id': userId,
        'count': count.toString(),
      },
    );

    if (response.statusCode == 200) {
      //print('User read status updated');
    } else {
      throw Exception('Failed to update user read status');
    }
  }

  Future<void> setUserTyping(String chatId, String userId, bool userTyping) async {
    final response = await http.post(
      Uri.parse('$baseUrl/set_user_typing.php'),
      body: {
        'chat_id': chatId,
        'user_id': userId,
        'typing': userTyping.toString(),
      },
    );

    if (response.statusCode == 200) {
      //print('User typing status updated');
    } else {
      throw Exception('Failed to update user typing status');
    }
  }
}
