import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:ionicons/ionicons.dart';
import 'package:les_social/pages/call_notification_screen.dart';
import 'package:les_social/services/auth_service.dart';
import 'package:les_social/services/call_service.dart';
import 'package:les_social/services/chat_service.dart';
import 'package:les_social/services/websocket_service.dart';
import 'package:provider/provider.dart';
import '../models/chat.dart';
import '../models/enum/message_type.dart';
import '../models/message.dart';
import '../models/user.dart';
import '../pages/profile.dart';
import '../screens/call_screen.dart';
import '../services/webrtc_service.dart';
import '../view_models/conversation/conversation_view_model.dart';
import 'package:intl/intl.dart';

class Conversation extends StatefulWidget {
  final String userId;
  final String chatId;
  final String? receiver_id;

  const Conversation(
      {required this.userId, required this.chatId, this.receiver_id});

  @override
  _ConversationState createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  FocusNode focusNode = FocusNode();
  ScrollController scrollController = ScrollController();
  TextEditingController messageController = TextEditingController();
  late Message message;
  List<Message> messages = [];
  late AuthService _authService;
  late ChatService chatService;
  late CallService callService;
  bool _isExpanded = false;
  final int maxCharacterLimit = 100;
  final WebSocketService webSocketService = WebSocketService();

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    _authService = AuthService();
    callService = CallService();
    currentUserId();
    scrollController.addListener(() {
      focusNode.unfocus();
    });

    messageController.addListener(() {
      if (focusNode.hasFocus && messageController.text.isNotEmpty) {
        setTyping(true);
      } else if (!focusNode.hasFocus ||
          (focusNode.hasFocus && messageController.text.isEmpty)) {
        setTyping(false);
      }
    });
  }

  Future<UserModel?> currentUserId() async {
    try {
      var currentUser = await _authService.getCurrentUser();
      print(
          "currentUserId: Pobrano ID aktualnie zalogowanego użytkownika - ${currentUser?.id}"); // Debugowanie
      return currentUser;
    } catch (e) {
      //print("currentUserId: Błąd podczas pobierania danych użytkownika - $e"); // Debugowanie
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConversationViewModel>(
      builder: (BuildContext context, viewModel, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.keyboard_backspace),
            ),
            elevation: 0.0,
            titleSpacing: 0,
            title: Row(
              children: [
                // Wyświetlanie nazwy użytkownika
                Expanded(
                  child: buildUserName(context),
                ),
                // Ikony dzwonienia (telefon i kamera) po prawej stronie
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.phone, color: Colors.black87),
                      onPressed: () async {
                        try {
                          final callData = await WebRTCService().initiateCall('caller_id', 'receiver_id', 'voice');
                          print('Audio call initiated: $callData');
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CallNotificationScreen(webSocketService: webSocketService)),
                          );

                        } catch (e) {
                          print('Error initiating audio call: $e');
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.videocam, color: Colors.black87),
                      onPressed: () async {
                        try {
                          final callData = await WebRTCService().initiateCall('caller_id', 'receiver_id', 'video');
                          print('Video call initiated: $callData');
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CallNotificationScreen(webSocketService: webSocketService,)),
                          );
                        } catch (e) {
                          print('Error initiating video call: $e');
                        }
                      },
                    ),
                  ],
                ),

              ],
            ),
          ),
          body: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                Flexible(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: fetchMessages(widget.chatId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                              'Błąd podczas ładowania wiadomości: ${snapshot.error}'),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text('Brak wiadomości.'),
                        );
                      }

                      final messages = snapshot.data!;

                      return ListView.builder(
                        controller: scrollController,
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        itemCount: messages.length,
                        itemBuilder: (BuildContext context, int index) {
                          final message = messages[index];
                          return buildMessageItem(message, widget.userId);
                        },
                      );
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: BottomAppBar(
                    elevation: 10.0,
                    child: Container(
                      constraints: BoxConstraints(maxHeight: 100.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(
                              CupertinoIcons.photo_on_rectangle,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            onPressed: () => showPhotoOptions(
                                viewModel, viewModel.userId as UserModel),
                          ),
                          Flexible(
                            child: TextField(
                              controller: messageController,
                              focusNode: focusNode,
                              style: TextStyle(
                                fontSize: 15.0,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color,
                              ),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(10.0),
                                enabledBorder: InputBorder.none,
                                border: InputBorder.none,
                                hintText: "Zacznij pisać...",
                                hintStyle: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .color,
                                ),
                              ),
                              maxLines: null,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Ionicons.send,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            onPressed: () async {
                              if (messageController.text.isNotEmpty) {
                                try {
                                  // Pobierz użytkownika na podstawie widget.userId
                                  UserModel user =
                                  await getUserById(widget.userId);

                                  // Wywołaj funkcję sendMessage z użytkownikiem
                                  sendMessage(
                                      viewModel, user, widget.receiver_id!);
                                  fetchMessages(widget.chatId);
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    if (scrollController.hasClients) {
                                      scrollController.animateTo(
                                          scrollController
                                              .position.maxScrollExtent,
                                          duration: Duration(milliseconds: 300),
                                          curve: Curves.easeOut);
                                    }
                                  });
                                } catch (e) {
                                  // Obsługa błędów, np. brak użytkownika
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildUserName(BuildContext context) {
    return FutureBuilder<UserModel>(
      future: fetchUserData(widget.userId),
      builder: (context, AsyncSnapshot<UserModel> snapshot) {
        //print("FutureBuilder state: ${snapshot.connectionState}");
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          //print("Error in FutureBuilder: ${snapshot.error}");
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          UserModel user = snapshot.data!;
          //print("Fetched user data: ${user.username}, ${user.photoUrl}");
          return InkWell(
            onTap: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (_) => Profile(profileId: user.id.toString()),
                ),
              );
            },
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Hero(
                    tag: user.email!,
                    child: user.photoUrl!.isEmpty
                        ? CircleAvatar(
                            radius: 25.0,
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            child: Center(
                              child: Text(
                                '${user.username![0].toUpperCase()}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          )
                        : CircleAvatar(
                            radius: 25.0,
                            backgroundImage:
                                CachedNetworkImageProvider(user.photoUrl!),
                          ),
                  ),
                ),
                SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        user.username!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          //print("Snapshot has no data");
          return SizedBox();
        }
      },
    );
  }

  // Widget buildMessageItem(Map<String, dynamic> message, String userId) {
  //   return FutureBuilder<UserModel?>(
  //     future: currentUserId(), // Pobierz ID aktualnie zalogowanego użytkownika
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return Center(child: CircularProgressIndicator());
  //       }
  //
  //       if (!snapshot.hasData || snapshot.data == null) {
  //         return Center(child: Text('Nie udało się pobrać danych użytkownika.'));
  //       }
  //
  //       final currentUserId = snapshot.data!.id;
  //       final senderId = message['sender_id'];  // ID nadawcy wiadomości
  //
  //       // Sprawdzamy, czy wiadomość jest wysłana przez zalogowanego użytkownika
  //       final isSentByMe = senderId == currentUserId;
  //
  //       // Zmieniamy photoUrl w zależności od tego, kto wysłał wiadomość
  //       final photoUrl = isSentByMe
  //           ? message['sender_photo_url'] ?? 'https://example.com/default_avatar.jpg' // Jeśli wysłał zalogowany użytkownik, używamy jego zdjęcia
  //           : message['sender_photo_url'] ?? 'https://example.com/default_avatar.jpg'; // Jeśli otrzymaliśmy wiadomość, używamy zdjęcia nadawcy
  //
  //       // Dla zalogowanego użytkownika zmieniamy 'username' na "Ty"
  //       final username = isSentByMe
  //           ? 'Ty' // Zamiast username wyświetlamy 'Ty', jeśli wiadomość wysłał zalogowany użytkownik
  //           : message['sender_username'] ?? 'Nieznany użytkownik';
  //
  //       return Align(
  //         alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
  //         child: Container(
  //           constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
  //           margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
  //           padding: EdgeInsets.all(10),
  //           decoration: BoxDecoration(
  //             color: isSentByMe ? Colors.blue[200] : Colors.grey[300],
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //           child: StatefulBuilder(
  //             builder: (context, setState) {
  //               // bool isExpanded = false; // Zmienna stanu do zarządzania rozwinięciem
  //
  //               return Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Row(
  //                     mainAxisAlignment: isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
  //                     children: [
  //                       CircleAvatar(
  //                         radius: 20.0,
  //                         backgroundImage: CachedNetworkImageProvider(photoUrl),
  //                       ),
  //                       SizedBox(width: 8),
  //                       Text(
  //                         isSentByMe ? 'Ty' : username,
  //                         style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
  //                       ),
  //                     ],
  //                   ),
  //                   SizedBox(height: 5),
  //                   Text(
  //                     message['content'] ?? '',
  //                     maxLines: _isExpanded ? null : 5,
  //                     // overflow: TextOverflow.ellipsis,
  //                     style: TextStyle(fontSize: 14),
  //                   ),
  //                   if ((message['content'] as String).length >= 100)
  //                   GestureDetector(
  //                     onTap: () {
  //                       print("Klikam obiekt gesture detector.");
  //                       setState(() {
  //                         _isExpanded = !_isExpanded; // Przełączanie rozwinięcia
  //                       });
  //                     },
  //                     child: Text(
  //                       _isExpanded ? 'Zwiń' : 'Czytaj więcej',
  //                       style: TextStyle(fontSize: 12, color: Colors.blue),
  //                     ),
  //                   ),
  //                   SizedBox(height: 5),
  //                   Align(
  //                     alignment: Alignment.centerLeft,
  //                     child: Text(
  //                       DateFormat('HH:mm').format(DateTime.parse(message['created_at'] ?? '')),
  //                       style: TextStyle(fontSize: 12, color: Colors.grey),
  //                     ),
  //                   ),
  //                 ],
  //               );
  //             },
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget buildMessageItem(Map<String, dynamic> message, String userId) {
    return FutureBuilder<UserModel?>(
      future: currentUserId(), // Pobierz ID aktualnie zalogowanego użytkownika
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('Nie udało się pobrać danych użytkownika.'));
        }

        final currentUserId = snapshot.data!.id;
        final senderId = message['sender_id']; // ID nadawcy wiadomości

        // Sprawdzamy, czy wiadomość jest wysłana przez zalogowanego użytkownika
        final isSentByMe = senderId == currentUserId;
        final receiver = widget.receiver_id;

        // Zmieniamy photoUrl w zależności od tego, kto wysłał wiadomość
        final photoUrl = message['sender_photo_url'] ?? 'https://example.com/default_avatar.jpg';

        // Dla zalogowanego użytkownika zmieniamy 'username' na "Ty"
        final username = isSentByMe ? 'Ty' : message['sender_username'] ?? 'Nieznany użytkownik';

        // Dodajemy Future, aby pobrać status użytkownika
        return FutureBuilder<Map<String, dynamic>>(
          future: fetchUserStatus(receiver!), // Funkcja do pobrania statusu użytkownika
          builder: (context, statusSnapshot) {
            String statusText = 'Ładowanie statusu...';
            if (statusSnapshot.connectionState == ConnectionState.done &&
                statusSnapshot.hasData) {
              final isOnline = statusSnapshot.data!['is_online'];
              final lastSeen = statusSnapshot.data!['last_seen'];

              // Wyświetlamy status jako „Aktywny” lub „Ostatnio widziano...”
              if (isOnline) {
                statusText = 'Aktywny';
              } else if (lastSeen != null) {
                final lastSeenTime = DateTime.parse(lastSeen);
                statusText = 'Ostatnio widziano: ${DateFormat('HH:mm, dd.MM').format(lastSeenTime)}';
              } else {
                statusText = 'Nieznany status';
              }
            }

            return Align(
              alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.6,
                ),
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSentByMe ? Colors.blue[200] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                      isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 20.0,
                          backgroundImage: CachedNetworkImageProvider(photoUrl),
                        ),
                        SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isSentByMe ? 'Ty' : username,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              statusText,
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Text(
                      message['content'] ?? '',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 5),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        DateFormat('HH:mm').format(
                          DateTime.parse(message['created_at'] ?? ''),
                        ),
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>> fetchUserStatus(String userId) async {
    final url = 'https://lesmind.com/api/users/get_user_status.php'; // Endpoint do pobrania statusu użytkownika
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Nie udało się pobrać statusu użytkownika');
    }
  }

  Future<List<Map<String, dynamic>>> fetchMessages(String chatId) async {
    final response = await http.post(
      Uri.parse('https://lesmind.com/api/talks/get_messages.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'chat_id': chatId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // print("Odpowiedz z serwera: $data" );
      if (data['status'] == 'success') {
        return List<Map<String, dynamic>>.from(data['messages']);
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Błąd połączenia z serwerem');
    }
  }

  Future<UserModel> fetchUserData(String userId) async {
    //print("Fetching user data for userId: $userId");
    final response = await http.get(
      Uri.parse('https://lesmind.com/api/users/get_user.php?userId=$userId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      //print("User data fetched successfully: $data");

      // Sprawdź, czy odpowiedź zawiera poprawne dane
      if (data != null && data['id'] != null) {
        return UserModel.fromJson(data);
      } else {
        throw Exception('Invalid user data');
      }
    } else {
      //print("Failed to load user data, status code: ${response.statusCode}");
      throw Exception('Failed to load user data');
    }
  }

  // Future<Map<String, dynamic>> fetchChatInfo(String chatId) async {
  //   final response =
  //       await http.get(Uri.parse('https://example.com/api/chat/$chatId/info'));
  //
  //   if (response.statusCode == 200) {
  //     return jsonDecode(response.body);
  //   } else {
  //     throw Exception('Failed to load chat info');
  //   }
  // }

  void setTyping(bool typing) async {
    var response = await http.post(
      Uri.parse('https://example.com/api/set_typing.php'),
      body: {
        'chat_id': widget.chatId,
        'user_id': widget.userId,
        'typing': typing.toString(),
      },
    );

    if (response.statusCode == 200) {
      //print('Typing status set successfully');
    } else {
      //print('Failed to set typing status. Error ${response.statusCode}');
      // Handle errors
    }
  }

  Future<String?> createChat(String user1Id, String user2Id) async {
    var body = jsonEncode({
      'user1_id': user1Id,
      'user2_id': user2Id,
    });

    try {
      var response = await http.post(
        Uri.parse('https://lesmind.com/api/chats/create_chat.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      //print('Odpowiedź serwera (createChat): ${response.body}');

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var responseData = jsonDecode(response.body);
        if (responseData['status'] == 'chat_created') {
          return responseData['chatId'];
        }
      } else {
        //print('Błąd: Otrzymano kod ${response.statusCode} lub pustą odpowiedź');
      }
    } catch (e) {
      //print('Błąd podczas tworzenia czatu: $e');
    }
    return null;
  }

  void sendMessage(ConversationViewModel viewModel, UserModel? user,
      String receiverId) async {
    String msg = messageController.text.trim();
    messageController.clear();

    if (user == null) {
      return;
    }

    String? chatId = widget.chatId ?? await createChat(user.id!, widget.userId);

    // Uzyskujemy currentUserId po otrzymaniu obiektu currentUser
    UserModel? currentUser = await currentUserId();
    String? suid = currentUser?.id; // Bezpiecznie wyciągamy ID użytkownika

    if (chatId == null) {
      return;
    }

    if (suid == null) {
      return;
    }

    // Tworzymy lokalną wiadomość
    Message message = Message(
      content: msg,
      senderUid: suid,
      senderPhotoUrl: currentUser!.photoUrl,
      receiverPhotoUrl: user.photoUrl,
      receiverUid: user.id,
      senderUsername: currentUser.username,
      type: MessageType.TEXT,
      time: DateTime.now(),
    );

    // Dodajemy wiadomość lokalnie do listy messages
    setState(() {
      messages.add(message);
    });
    //
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (scrollController.hasClients) {
    //     scrollController.jumpTo(scrollController.position.maxScrollExtent);
    //   }
    // });

    final Map<String, dynamic> requestData = {
      'chat_id': chatId,
      'sender_id': suid,
      'senderPhotoUrl': currentUser.photoUrl,
      'receiver_id': user.id,
      'receiver_photoUrl': user.photoUrl,
      'senderUsername': currentUser.username,
      'message_content': message.content,
      'message_type': 'text',
      'time': message.time?.toIso8601String(),
    };

    try {
      var response = await http.post(
        Uri.parse('https://lesmind.com/api/talks/send_message.php'),
        body: jsonEncode(requestData),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return;
        }

        try {
          var responseData = jsonDecode(response.body);

          if (responseData['status'] == 'sent') {
            // Wiadomość została wysłana, ale już została dodana lokalnie do listy,
            // więc nie musimy nic zmieniać w tej liście.
          } else {
            // Jeśli wystąpił problem podczas zapisywania wiadomości na serwerze,
            // możemy dodać jakiś komunikat informujący użytkownika
          }
        } catch (jsonError) {
          // Obsługa błędu JSON
        }
       } else {
        // Obsługa błędu odpowiedzi HTTP
      }
    } catch (e) {
      // Obsługa ogólnych błędów
    }
  }

  Future<UserModel> getUserById(String userId) async {
    // Załóżmy, że masz metodę, która zwraca obiekt UserModel na podstawie userId
    // To może być zapytanie do bazy danych lub API, które zwraca szczegóły użytkownika.

    final response = await http.get(
        Uri.parse('https://lesmind.com/api/users/get_user.php?userId=$userId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UserModel.fromJson(data);
    } else {
      throw Exception('Błąd podczas pobierania użytkownika');
    }
  }

  void showPhotoOptions(ConversationViewModel viewModel, UserModel user) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text("Kamera"),
              onTap: () {
                sendMessage(viewModel, user, widget.receiver_id!);
              },
            ),
            ListTile(
              title: Text("Galeria"),
              onTap: () {
                sendMessage(viewModel, user, widget.receiver_id!);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    focusNode.dispose();
    scrollController.dispose();
    messageController.dispose();
    super.dispose();
  }

  // Future<List<Chat>> fetchUserChats(String userId) async {
  //   final response = await http.post(
  //     Uri.parse('https://lesmind.com/api/talks/get_chats.php'),
  //     body: jsonEncode({'user_id': userId}),
  //     headers: {'Content-Type': 'application/json'},
  //   );
  //
  //   if (response.statusCode == 200) {
  //     List data = jsonDecode(response.body);
  //     return data.map((chat) => Chat.fromJson(chat)).toList();
  //   } else {
  //     throw Exception('Błąd pobierania rozmów');
  //   }
  // }
}
