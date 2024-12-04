import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:les_social/models/user.dart';
import 'package:les_social/pages/profile.dart';
import 'package:les_social/services/auth_service.dart';
import 'package:uuid/uuid.dart';

import '../chats/conversation.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> with AutomaticKeepAliveClientMixin {
  TextEditingController searchController = TextEditingController();
  List<UserModel> users = [];
  List<UserModel> filteredUsers = [];
  UserModel? currentUser;
  bool loading = true;
  final Uuid uuid = Uuid();
  late String uniqueChatId = uuid.v4();

  late AuthService _authService;
  late Position _currentPosition;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _getCurrentLocation().then((_) {
      getUsers();
    });
    _fetchCurrentUser();
    currentUserId();
  }

  Future<void> _fetchCurrentUser() async {
    try {
      UserModel? user = await currentUserId();
      setState(() {
        currentUser = user;
        //print('search.dart: Pobrano ID aktualnie zalogowanego użytkownika - ${currentUser?.id}');
        if (currentUser == null) {
          //print('search.dart: currentUser jest null');
        }
      });
    } catch (e) {
      //print('search.dart: Błąd podczas pobierania bieżącego użytkownika - $e');
    }
  }

  Future<UserModel?> currentUserId() async {
    try {
      var currentUser = await _authService.getCurrentUser();
      //print('search.dart: ID aktualnie zalogowanego użytkownika z _authService - ${currentUser?.id}');
      return currentUser;
    } catch (e) {
      //print("search.dart: Błąd podczas pobierania danych użytkownika: $e");
      return null;
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
        //print('Uzyskano lokalizację: $_currentPosition');
      });
    } catch (e) {
      //print('Błąd podczas uzyskiwania lokalizacji: $e');
    }
  }

  Future<void> getUsers() async {
    try {
      final response = await http.get(Uri.parse('https://lesmind.com/api/users/get_users.php'));
      //print('Status odpowiedzi serwera: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Parsowanie odpowiedzi JSON
        List<dynamic> jsonList = jsonDecode(response.body);
        List<UserModel> userList = jsonList.map((json) => UserModel.fromJson(json)).toList();

        // Filtracja użytkowników - usuwamy zalogowanego użytkownika z listy
        setState(() {
          users = userList.where((user) => user.id != currentUser?.id).toList();
          filteredUsers = users;
          loading = false;
          //print('Pobrano użytkowników: ${users.length}');
        });
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      //print('Błąd podczas pobierania użytkowników: $e');
      setState(() {
        loading = false;
      });
    }
  }

  void search(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredUsers = users;
      });
    } else {
      List<UserModel> userSearch = users.where((user) {
        String userName = user.username ?? '';
        return userName.toLowerCase().contains(query.toLowerCase());
      }).toList();
      setState(() {
        filteredUsers = userSearch;
      });
    }
  }

  Widget buildUsers() {
    if (loading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (filteredUsers.isEmpty && searchController.text.isEmpty) {
      return Center(
        child: Text(
          "Nie znaleziono użytkownika",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    } else if (filteredUsers.isEmpty) {
      return Center(
        child: Text(
          "Brak wyników wyszukiwania",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    } else {
      // Usuń zalogowanego użytkownika z wyników wyszukiwania przed ich wyświetleniem
      List<UserModel> filteredWithoutCurrentUser = filteredUsers
          .where((user) => user.id != currentUser?.id)
          .toList();

      return Expanded(
        child: ListView.builder(
          itemCount: filteredWithoutCurrentUser.length,
          itemBuilder: (BuildContext context, int index) {
            UserModel user = filteredWithoutCurrentUser[index];
            return ListTile(
              onTap: () => showProfile(context, profileId: user.id.toString()),
              leading: user.photoUrl == null || user.photoUrl!.isEmpty
                  ? CircleAvatar(
                radius: 20.0,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: Center(
                  child: Text(
                    user.username![0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              )
                  : CircleAvatar(
                radius: 20.0,
                backgroundImage: CachedNetworkImageProvider(
                  user.photoUrl!,
                ),
              ),
              title: Text(
                user.username ?? 'Unknown',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                user.city ?? '*****',
              ),
              trailing: GestureDetector(
                onTap: () async {
                  showDialog(
                    context: context,
                    builder: (context) => Center(child: CircularProgressIndicator()),
                  );
                  try {
                    // Pobranie chatId z backendu
                    String chatId = await getChatId(currentUser!.id.toString(), user.id.toString());
                    Navigator.pop(context); // Zamknięcie dialogu ładowania
                    // Przejście do ekranu rozmowy
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => Conversation(
                          userId: user.id.toString(),
                          chatId: chatId,
                          receiver_id: user.id.toString(),
                        ),
                      ),
                    );
                  } catch (e) {
                    Navigator.pop(context); // Zamknięcie dialogu ładowania w przypadku błędu
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Błąd: $e')),
                    );
                  }
                },
                child: Container(
                  height: 30.0,
                  width: 70.0,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text(
                        'Wiadomość',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure AutomaticKeepAliveClientMixin works correctly
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Image.asset(
          'assets/images/lesmind.png',
          height: 60.0,
          width: 190.0,
          fit: BoxFit.scaleDown,
        ),
        centerTitle: true,
        actions: [
          SizedBox(width: 20.0),
        ],
      ),
      body: currentUser == null
          ? Center(child: Text('Ładowanie użytkownika...'))
          : Column(
        children: [
          Padding(
              padding: EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Szukaj użytkowników...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.grey.shade700)
              ),
              prefixIcon: Icon(Icons.search)
            ),
            onChanged: (query) {
              search(query);
            },
          ),),

          buildUsers(),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

void showProfile(BuildContext context, {required String profileId}) {
  //print("Navigacja do profilu z id: $profileId");
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Profile(profileId: profileId),
    ),
  );
}

Future<String> getChatId(String senderId, String receiverId) async {
  final response = await http.post(
    Uri.parse('https://lesmind.com/api/talks/get_or_create_chat.php'),
    headers: {
      'Content-Type': 'application/json',
      'Cache-Control': 'no-cache'
    },
    body: jsonEncode({
      'sender_id': senderId,
      'receiver_id': receiverId,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['status'] == 'success') {
      return data['chat_id'];
    } else {
      throw Exception(data['message']);
    }
  } else {
    throw Exception('Błąd komunikacji z serwerem');
  }
}






