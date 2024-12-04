// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// import 'package:les_social/models/message.dart';
// import 'package:les_social/view_models/user/user_view_model.dart';
//
// class Chats extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     UserViewModel viewModel = Provider.of<UserViewModel>(context, listen: false);
//
//     return FutureBuilder(
//       future: viewModel.currentUserId(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError) {
//           return Center(child: Text("Wystąpił błąd: ${snapshot.error}"));
//         } else if (!snapshot.hasData || viewModel.user == null) {
//           return Center(child: Text("Nie udało się załadować danych użytkownika."));
//         }
//
//         return Scaffold(
//           appBar: AppBar(
//             leading: GestureDetector(
//               onTap: () => Navigator.pop(context),
//               child: Icon(Icons.keyboard_backspace),
//             ),
//             title: Text("Rozmowy"),
//           ),
//           body: StreamBuilder<List<dynamic>>(
//             stream: getUserChatsStream(viewModel.user!.id!),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return Center(child: CircularProgressIndicator());
//               } else if (snapshot.hasError) {
//                 return Center(child: Text("Wystąpił błąd: ${snapshot.error}"));
//               } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
//                 List<dynamic> chatList = snapshot.data!;
//                 return ListView.separated(
//                   itemCount: chatList.length,
//                   separatorBuilder: (context, index) => Divider(),
//                   itemBuilder: (context, index) {
//                     Map<String, dynamic> chat = chatList[index];
//                     return ListTile(
//                       leading: CircleAvatar(
//                         backgroundImage: NetworkImage(chat['photoUrl']),
//                       ),
//                       title: Text(chat['username'], style: TextStyle(fontWeight: FontWeight.bold)),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(chat['last_message'], maxLines: 1, overflow: TextOverflow.ellipsis),
//                           Text(
//                             chat['last_message_time'],
//                             style: TextStyle(fontSize: 12, color: Colors.grey),
//                           ),
//                         ],
//                       ),
//                       onTap: () {
//                         // Akcja po kliknięciu w rozmowę
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => ChatScreen(chatId: chat['chat_id']),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 );
//               } else {
//                 return Center(child: Text("Brak rozmów"));
//               }
//             },
//           ),
//         );
//       },
//     );
//   }
//
//   Stream<List<dynamic>> getUserChatsStream(String userId) async* {
//     final response = await http.post(
//       Uri.parse('https://lesmind.com/api/talks/get_chats.php'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({'user_id': userId}),
//     );
//
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       if (data['status'] == 'success') {
//         yield data['chats'];
//       } else {
//         throw Exception('Błąd serwera: ${data['message']}');
//       }
//     } else {
//       throw Exception('Nie udało się załadować czatów. Kod: ${response.statusCode}');
//     }
//   }
// }
//
// class ChatScreen extends StatelessWidget {
//   final String chatId;
//
//   const ChatScreen({required this.chatId});
//
//   @override
//   Widget build(BuildContext context) {
//     // Przykładowy ekran czatu
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Rozmowa"),
//       ),
//       body: Center(
//         child: Text("Czat ID: $chatId"),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:les_social/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:les_social/view_models/user/user_view_model.dart';
import '../models/user.dart';
import 'package:intl/intl.dart';

class Chats extends StatelessWidget {
  final AuthService _authService = AuthService();

  Future<UserModel?> currentUserId() async {
    try {
      var currentUser = await _authService.getCurrentUser();
      return currentUser;
    } catch (e) {
      return null;
    }
  }

  /// Pobiera listę rozmów użytkownika
  Future<List<dynamic>> fetchUserChats(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('https://lesmind.com/api/talks/get_chats.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return data['chats'];
        } else {
          throw Exception('Błąd serwera: ${data['message']}');
        }
      } else {
        throw Exception(
            'Nie udało się załadować czatów. Kod: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Błąd sieci: $e');
    }
  }

  String formatTime(String dateTimeString) {
    try {
      DateTime parsedData = DateTime.parse(dateTimeString);
      return DateFormat.Hm().format(parsedData);
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    UserViewModel viewModel = Provider.of<UserViewModel>(context, listen: false);

    return FutureBuilder<String?>(
      future: viewModel.currentUserId().then((user) => user?.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Rozmowy"),
            ),
            body: Center(
              child: Text("Wystąpił błąd: ${snapshot.error}"),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text("Nie udało się załadować danych użytkownika.")),
          );
        }

        final String userId = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.keyboard_backspace),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text("Rozmowy"),
          ),
          body: FutureBuilder<List<dynamic>>(
            future: fetchUserChats(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text("Wystąpił błąd: ${snapshot.error}"),
                );
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                List<dynamic> chatList = snapshot.data!;
                return ListView.separated(
                  itemCount: chatList.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    Map<String, dynamic> chat = chatList[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          chat['contact_photo'] ??
                              'https://via.placeholder.com/150',
                        ),
                      ),
                      title: Text(
                        chat['contact_username'] ?? 'Nieznajomy',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chat['last_message'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            formatTime(chat['last_message_time']),
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ChatScreen(chatId: chat['chat_id']),
                          ),
                        );
                      },
                    );
                  },
                );
              } else {
                return const Center(child: Text("Brak rozmów"));
              }
            },
          ),
        );
      },
    );
  }
}

class ChatScreen extends StatelessWidget {
  final String chatId;

  const ChatScreen({required this.chatId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rozmowa"),
      ),
      body: Center(
        child: Text("Czat ID: $chatId"),
      ),
    );
  }
}