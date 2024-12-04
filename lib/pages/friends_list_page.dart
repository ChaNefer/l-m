// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:ionicons/ionicons.dart';
// import '../models/user.dart';
// import '../services/api_service.dart';
// import 'profile.dart';
// import '../chats/conversation.dart';
//
// class FriendsListPage extends StatefulWidget {
//   final String userId;
//
//   FriendsListPage({required this.userId});
//
//   @override
//   State<FriendsListPage> createState() => _FriendsListPageState();
// }
//
// class _FriendsListPageState extends State<FriendsListPage> {
//   List<UserModel> friends = [];
//   List<UserModel> pendingRequests = [];
//   bool loading = true;
//   TextEditingController searchController = TextEditingController();
//   bool searching = false;
//   List<UserModel> searchResults = [];
//   late final ApiService apiService;
//
//   @override
//   void initState() {
//     super.initState();
//     apiService = ApiService(context);
//     getFriends();
//     getPendingRequests();
//   }
//
//   Future<void> getPendingRequests() async {
//     setState(() {
//       loading = true;
//     });
//     try {
//       List<UserModel> requests =
//       await apiService.fetchPendingRequests(widget.userId);
//       setState(() {
//         pendingRequests = requests;
//         loading = false;
//       });
//     } catch (e) {
//       //print('Error fetching pending requests: $e');
//       setState(() {
//         loading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: searching
//             ? TextField(
//           controller: searchController,
//           style: TextStyle(color: Colors.white),
//           decoration: InputDecoration(
//             hintText: 'Szukaj...',
//             hintStyle: TextStyle(color: Colors.white),
//           ),
//           onChanged: (value) {
//             performSearch(value);
//           },
//         )
//             : Text('Znajomi'),
//         actions: [
//           searching
//               ? IconButton(
//             icon: Icon(Icons.cancel),
//             onPressed: () {
//               setState(() {
//                 searching = false;
//                 searchController.clear();
//                 searchResults.clear();
//               });
//             },
//           )
//               : IconButton(
//             icon: Icon(Icons.search),
//             onPressed: () {
//               setState(() {
//                 searching = true;
//               });
//             },
//           ),
//         ],
//       ),
//       body: loading
//           ? Center(child: CircularProgressIndicator())
//           : searching
//           ? buildSearchResults()
//           : buildFriendsList(),
//     );
//   }
//
//   Widget buildPendingRequests() {
//     return pendingRequests.isEmpty
//         ? Center(child: Text('Brak oczekujących zaproszeń.'))
//         : ListView.builder(
//       itemCount: pendingRequests.length,
//       itemBuilder: (context, index) {
//         var request = pendingRequests[index];
//         return ListTile(
//           leading: CircleAvatar(
//             radius: 30.0, backgroundImage: NetworkImage(request.photoUrl!), ),
//           title: Text(request.username!),
//           subtitle: Text(request.city!),
//           trailing: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               IconButton(
//                 icon: Icon(Icons.check),
//                 onPressed: () {
//                   acceptFriendRequest(request.id.toString()); }, ),
//               IconButton( icon: Icon(Icons.close), onPressed: () {
//                 rejectFriendRequest(request.id.toString());
//               },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget buildSearchResults() {
//     return searchResults.isEmpty
//         ? Center(
//       child: Text('Nie znaleziono wyników.'),
//     )
//         : ListView.builder(
//       itemCount: searchResults.length,
//       itemBuilder: (context, index) {
//         UserModel user = searchResults[index];
//         return ListTile(
//           leading: GestureDetector(
//             onTap: () {
//               showProfile(context, profileId: user.id.toString());
//             },
//             child: CircleAvatar(
//               radius: 30.0,
//               backgroundImage: NetworkImage(user.photoUrl!),
//             ),
//           ),
//           title: Text(
//             user.username!,
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//           subtitle: Text(user.city!),
//           trailing: GestureDetector(
//             onTap: () {
//               startConversation(widget.userId, user.id.toString());
//             },
//             child: Container(
//               height: 30.0,
//               width: 80.0,
//               decoration: BoxDecoration(
//                 color: Theme.of(context).colorScheme.secondary,
//                 borderRadius: BorderRadius.circular(3.0),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   GestureDetector(
//                     onTap: () {
//                       startConversation(
//                           widget.userId, user.id.toString());
//                     },
//                     child: Icon(
//                       Ionicons.chatbubble_ellipses,
//                       color: Theme.of(context).colorScheme.secondary,
//                       size: 24.0,
//                     ),
//                   ),
//                   SizedBox(width: 10),
//                   GestureDetector(
//                     onTap: () {
//                       removeFriend(user.id.toString(), widget.userId);
//                     },
//                     child: Icon(
//                       Ionicons.trash,
//                       color: Colors.red,
//                       size: 24.0,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   // Widget buildFriendsList() {
//   //   return friends.isEmpty
//   //       ? Center(
//   //     child: Text('Nie masz żadnych znajomych.'),
//   //   )
//   //       : ListView.builder(
//   //     itemCount: friends.length,
//   //     itemBuilder: (context, index) {
//   //       var friend = friends[index];
//   //       return Column(
//   //         children: [
//   //           ListTile(
//   //             leading: GestureDetector(
//   //               onTap: () {
//   //                 showProfile(context, profileId: friend.id.toString());
//   //               },
//   //               child: CircleAvatar(
//   //                 radius: 30.0,
//   //                 backgroundImage: NetworkImage(friend.photoUrl!),
//   //               ),
//   //             ),
//   //             title: Text(
//   //               friend.username!,
//   //               style: TextStyle(fontWeight: FontWeight.bold),
//   //             ),
//   //             subtitle: Text(friend.city!),
//   //             trailing: Row(
//   //               mainAxisSize: MainAxisSize.min,
//   //               children: [
//   //                 GestureDetector(
//   //                   onTap: () {
//   //                     startConversation(
//   //                         widget.userId, friend.id.toString());
//   //                   },
//   //                   child: Icon(
//   //                     Ionicons.chatbubble_ellipses,
//   //                     color: Theme.of(context).colorScheme.secondary,
//   //                     size: 24.0,
//   //                   ),
//   //                 ),
//   //                 SizedBox(width: 10),
//   //                 GestureDetector(
//   //                   onTap: () {
//   //                     removeFriend(friend.id.toString(), widget.userId);
//   //                   },
//   //                   child: Icon(
//   //                     Ionicons.remove_circle_outline,
//   //                     color: Colors.red,
//   //                     size: 24.0,
//   //                   ),
//   //                 ),
//   //               ],
//   //             ),
//   //           ),
//   //           Divider(
//   //             height: 5,
//   //             thickness: 1.5,
//   //             color: Theme.of(context).colorScheme.secondary,
//   //           )
//   //         ],
//   //       );
//   //     },
//   //   );
//   // }
//
//   Widget buildFriendsList() {
//     return friends.isEmpty
//         ? Center(
//       child: Text('Nie masz żadnych znajomych.'),
//     )
//         : ListView.builder(
//       itemCount: friends.length,
//       itemBuilder: (context, index) {
//         var friend = friends[index];
//         return Column(
//           children: [
//             ListTile(
//               leading: GestureDetector(
//                 onTap: () {
//                   showProfile(context, profileId: friend.id.toString());
//                 },
//                 child: CircleAvatar(
//                   radius: 30.0,
//                   backgroundImage: friend.photoUrl != null
//                       ? NetworkImage(friend.photoUrl!)
//                       : AssetImage('assets/images/profile_avatar.png') as ImageProvider<Object>, // Zastąp domyślnym obrazkiem
//                 ),
//               ),
//               title: Text(
//                 friend.username ?? 'Nieznany użytkownik', // Domyślny tekst
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               subtitle: Text(friend.city ?? 'Nieznane miasto'), // Domyślny tekst
//               trailing: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   GestureDetector(
//                     onTap: () {
//                       startConversation(widget.userId, friend.id.toString());
//                     },
//                     child: Icon(
//                       Ionicons.chatbubble_ellipses,
//                       color: Theme.of(context).colorScheme.secondary,
//                       size: 24.0,
//                     ),
//                   ),
//                   SizedBox(width: 10),
//                   GestureDetector(
//                     onTap: () {
//                       removeFriend(friend.id.toString(), widget.userId);
//                     },
//                     child: Icon(
//                       Ionicons.remove_circle_outline,
//                       color: Colors.red,
//                       size: 24.0,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Divider(
//               height: 5,
//               thickness: 1.5,
//               color: Theme.of(context).colorScheme.secondary,
//             )
//           ],
//         );
//       },
//     );
//   }
//
//   void performSearch(String query) {
//     if (query.isEmpty) {
//       setState(() {
//         searchResults.clear();
//       });
//     } else {
//       var lowercaseQuery = query.toLowerCase();
//       var matchingUsers = friends.where((friend) {
//         return friend.username!.toLowerCase().contains(lowercaseQuery);
//       }).toList();
//       setState(() {
//         searchResults = matchingUsers;
//       });
//     }
//   }
//
//   Future<void> startConversation(String currentUserId, String friendId) async {
//     try {
//       // Call backend API to start conversation
//       // Example: POST request to /api/conversations with currentUserId and friendId
//       final response = await http.post(
//         Uri.parse('http://your-backend-url.com/api/conversations'),
//         body: jsonEncode({
//           'currentUserId': currentUserId,
//           'friendId': friendId,
//         }),
//         headers: {'Content-Type': 'application/json'},
//       );
//
//       if (response.statusCode == 200) {
//         // Conversation started successfully
//         var chatId = jsonDecode(response.body)['chatId'];
//         Navigator.push(
//           context,
//           CupertinoPageRoute(
//             builder: (_) => Conversation(userId: friendId, chatId: chatId),
//           ),
//         );
//       } else {
//         throw Exception('Failed to start conversation');
//       }
//     } catch (e) {
//       //print('Error starting conversation: $e');
//       // Handle errors here, for example show error message to the user
//     }
//   }
//
//   Future<void> removeFriend(String friendId, String userId) async {
//     try {
//       // Call backend API to remove friend
//       // Example: DELETE request to /api/friends/:friendId
//       final response = await http.delete(
//         Uri.parse('http://your-backend-url.com/api/friends/$friendId'),
//       );
//
//       if (response.statusCode == 200) {
//         setState(() {
//           friends.removeWhere((friend) => friend.id == friendId);
//         });
//       } else {
//         throw Exception('Failed to remove friend');
//       }
//     } catch (e) {
//       //print('Error removing friend: $e');
//       // Handle errors here, for example show error message to the user
//     }
//   }
//
//   Future<void> getFriends() async {
//     setState(() {
//       loading = true;
//     });
//     try {
//       List<UserModel> users = await apiService.fetchAcceptedFriends(widget.userId);
//       setState(() {
//         friends = users;
//         loading = false;
//       });
//     } catch (e) {
//       //print('Error fetching friends: $e');
//       setState(() {
//         loading = false;
//       });
//     }
//   }
//
//   void showProfile(BuildContext context, {required String profileId}) {
//     Navigator.push(
//       context,
//       CupertinoPageRoute(
//         builder: (_) => Profile(profileId: profileId),
//       ),
//     );
//   }
//
//   Future<void> acceptFriendRequest(String senderId) async {
//     try {
//       // Przekazanie obu wymaganych argumentów
//       await apiService.acceptFriendRequest(widget.userId, senderId);
//       setState(() {
//         // Dodaj znajomego do listy znajomych
//         var acceptedUser = pendingRequests.firstWhere((user) => user.id == senderId);
//         friends.add(acceptedUser);
//
//         if (acceptedUser != widget.userId) {
//           friends.add(acceptedUser);
//         }
//         pendingRequests.removeWhere((user) => user.id == senderId);
//       });
//     } catch (e) {
//       //print('Error accepting friend request: $e');
//     }
//   }
//
//   Future<void> rejectFriendRequest(String senderId) async {
//     try {
//       // Przekazanie obu wymaganych argumentów
//       await apiService.rejectFriendRequest(widget.userId, senderId);
//       setState(() {
//         // Usuń zaproszenie z listy oczekujących
//         pendingRequests.removeWhere((user) => user.id == senderId);
//       });
//     } catch (e) {
//       //print('Error rejecting friend request: $e');
//     }
//   }
// }
import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:les_social/models/user.dart';
import 'package:les_social/pages/profile.dart';
import 'package:les_social/services/auth_service.dart';

// class FriendsListPage extends StatefulWidget {
//   final String userId;
//
//   FriendsListPage({required this.userId});
//
//   @override
//   _FriendsListPageState createState() => _FriendsListPageState();
// }
//
// class _FriendsListPageState extends State<FriendsListPage> with AutomaticKeepAliveClientMixin {
//   List<UserModel> friends = [];
//   UserModel? currentUser;
//   bool loading = true;
//
//   late AuthService _authService;
//
//   @override
//   void initState() {
//     super.initState();
//     _authService = AuthService();
//     _fetchCurrentUser();
//     _getFriends();
//   }
//
//   Future<void> _fetchCurrentUserAndFriends() async {
//     try {
//       await _fetchCurrentUser();
//
//       if (currentUser?.id != null) {
//         await _getFriends();
//       } else {
//         //print('Nie udało się pobrać ID użytkownika. Nie można pobrać znajomych.');
//       }
//     } catch (e) {
//       //print('Błąd podczas pobierania użytkownika lub znajomych: $e');
//     }
//   }
//
//   Future<void> _fetchCurrentUser() async {
//     try {
//       UserModel? user = await _authService.getCurrentUser();
//       if (user == null) {
//         //print('Nie udało się pobrać bieżącego użytkownika. Użytkownik może być niezalogowany.');
//         return; // Wychodzimy, jeśli użytkownik jest niezalogowany
//       }
//       setState(() {
//         currentUser = user;
//         //print('friends_list_page.dart: Pobrano ID aktualnie zalogowanego użytkownika - ${currentUser?.id}');
//       });
//     } catch (e) {
//       //print('friends_list_page.dart: Błąd podczas pobierania bieżącego użytkownika - $e');
//     }
//   }
//
//
//
//
//
//   Future<void> _getFriends() async {
//     try {
//       //print('Wysłanie zapytania dla userId: ${currentUser?.id}');
//       final response = await http.get(Uri.parse('https://lesmind.com/api/friends/fetch_accepted_friends.php?userId=${currentUser?.id}'));
//
//       //print('Status odpowiedzi serwera: ${response.statusCode}');
//       //print('Odpowiedź serwera: ${response.body}');
//
//       if (response.statusCode == 200) {
//         final jsonResponse = jsonDecode(response.body);
//         //print('Zdekodowana odpowiedź JSON: $jsonResponse');
//
//         // Sprawdzamy, czy odpowiedź to lista przyjaciół (czyli oczekiwany format)
//         if (jsonResponse is Map<String, dynamic> && jsonResponse['friends'] is List) {
//           List<dynamic> jsonList = jsonResponse['friends'];
//           List<UserModel> friendList = jsonList.map((json) => UserModel.fromJson(json)).toList();
//
//           setState(() {
//             friends = friendList;
//             loading = false;
//             //print('Pobrano przyjaciół: ${friends.length}');
//           });
//         } else if (jsonResponse is Map<String, dynamic> && jsonResponse.containsKey('message')) {
//           // Sprawdzamy, czy odpowiedź zawiera wiadomość (np. "Brak znajomych")
//           //print('Odpowiedź serwera zawiera wiadomość: ${jsonResponse['message']}');
//           setState(() {
//             friends = [];
//             loading = false;
//           });
//         } else {
//           // Nieoczekiwany format odpowiedzi
//           //print('Otrzymano nieoczekiwany format odpowiedzi: $jsonResponse');
//           setState(() {
//             friends = [];
//             loading = false;
//           });
//         }
//       } else {
//         //print('Błąd odpowiedzi serwera: ${response.statusCode}');
//         throw Exception('Failed to load friends');
//       }
//     } catch (e) {
//       //print('Błąd podczas pobierania przyjaciół: $e');
//       setState(() {
//         loading = false;
//       });
//     }
//   }
//
//   Widget buildFriends() {
//     if (loading) {
//       return Center(child: CircularProgressIndicator());
//     }
//
//     if (friends.isEmpty) {
//       return Center(
//         child: Text(
//           "Brak przyjaciół",
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//       );
//     }
//
//     return Expanded(
//       child: ListView.builder(
//         itemCount: friends.length,
//         itemBuilder: (BuildContext context, int index) {
//           UserModel friend = friends[index];
//           return ListTile(
//             onTap: () => showProfile(context, profileId: friend.id.toString()),
//             leading: friend.photoUrl == null || friend.photoUrl!.isEmpty
//                 ? CircleAvatar(
//               radius: 20.0,
//               backgroundColor: Theme.of(context).colorScheme.secondary,
//               child: Center(
//                 child: Text(
//                   friend.username![0].toUpperCase(),
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 15.0,
//                     fontWeight: FontWeight.w900,
//                   ),
//                 ),
//               ),
//             )
//                 : CircleAvatar(
//               radius: 20.0,
//               backgroundImage: CachedNetworkImageProvider(friend.photoUrl!),
//             ),
//             title: Text(
//               friend.username ?? 'Unknown',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             subtitle: Text(
//               friend.city ?? '*****',
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     super.build(context); // Ensure AutomaticKeepAliveClientMixin works correctly
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Lista Przyjaciół'),
//       ),
//       body: currentUser == null
//           ? Center(child: Text('Ładowanie użytkownika...'))
//           : Column(
//         children: [
//           buildFriends(),
//         ],
//       ),
//     );
//   }
//
//   @override
//   bool get wantKeepAlive => true;
// }
//
// void showProfile(BuildContext context, {required String profileId}) {
//   //print("Navigacja do profilu z id: $profileId");
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (context) => Profile(profileId: profileId),
//     ),
//   );
// }
//


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ionicons/ionicons.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'profile.dart';
import '../chats/conversation.dart';

class FriendsListPage extends StatefulWidget {
  final String userId;

  FriendsListPage({required this.userId});

  @override
  State<FriendsListPage> createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  List<UserModel> friends = [];
  List<UserModel> pendingRequests = [];
  bool loading = true;
  TextEditingController searchController = TextEditingController();
  bool searching = false;
  List<UserModel> searchResults = [];
  late final ApiService apiService;

  @override
  void initState() {
    super.initState();
    apiService = ApiService(context);
    getFriends();
    getPendingRequests();
  }

  Future<void> getPendingRequests() async {
    setState(() {
      loading = true;
    });
    try {
      List<UserModel> requests = await apiService.fetchPendingRequests(widget.userId);
      setState(() {
        pendingRequests = requests;
        loading = false;
      });
    } catch (e) {
      //print('Error fetching pending requests: $e');
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> getFriends() async {
    setState(() {
      loading = true;
    });
    try {
      List<UserModel> users = await apiService.fetchAcceptedFriends(widget.userId);
      setState(() {
        friends = users;
        loading = false;
      });
    } catch (e) {
      //print('Error fetching friends: $e');
      setState(() {
        loading = false;
      });
    }
  }

  void performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        searchResults.clear();
      });
    } else {
      var lowercaseQuery = query.toLowerCase();
      var matchingUsers = friends.where((friend) {
        return friend.username!.toLowerCase().contains(lowercaseQuery);
      }).toList();
      setState(() {
        searchResults = matchingUsers;
      });
    }
  }

  Future<void> startConversation(String currentUserId, String friendId) async {
    try {
      final response = await http.post(
        Uri.parse('https://lesmind.com/api/talks'),
        body: jsonEncode({
          'currentUserId': currentUserId,
          'friendId': friendId,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var chatId = jsonDecode(response.body)['chatId'];
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (_) => Conversation(userId: friendId, chatId: chatId),
          ),
        );
      } else {
        throw Exception('Failed to start conversation');
      }
    } catch (e) {
      //print('Error starting conversation: $e');
    }
  }

  Future<void> removeFriend(String friendId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://your-backend-url.com/api/friends/$friendId'),
      );

      if (response.statusCode == 200) {
        setState(() {
          friends.removeWhere((friend) => friend.id.toString() == friendId);
        });
      } else {
        throw Exception('Failed to remove friend');
      }
    } catch (e) {
      //print('Error removing friend: $e');
    }
  }

  Widget buildPendingRequests() {
    return pendingRequests.isEmpty
        ? Center(child: Text('Brak oczekujących zaproszeń.'))
        : ListView.builder(
      itemCount: pendingRequests.length,
      itemBuilder: (context, index) {
        var request = pendingRequests[index];
        return ListTile(
          leading: CircleAvatar(
            radius: 30.0,
            backgroundImage: NetworkImage(request.photoUrl!),
          ),
          title: Text(request.username!),
          subtitle: Text(request.city!),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.check),
                onPressed: () {
                  acceptFriendRequest(request.id.toString());
                },
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  rejectFriendRequest(request.id.toString());
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildSearchResults() {
    return searchResults.isEmpty
        ? Center(child: Text('Nie znaleziono wyników.'))
        : ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        UserModel user = searchResults[index];
        return ListTile(
          leading: GestureDetector(
            onTap: () {
              showProfile(context, profileId: user.id.toString());
            },
            child: CircleAvatar(
              radius: 30.0,
              backgroundImage: NetworkImage(user.photoUrl!),
            ),
          ),
          title: Text(
            user.username!,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(user.city!),
          trailing: GestureDetector(
            onTap: () {
              startConversation(widget.userId, user.id.toString());
            },
            child: Container(
              height: 30.0,
              width: 80.0,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(3.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      startConversation(widget.userId, user.id.toString());
                    },
                    child: Icon(
                      Ionicons.chatbubble_ellipses,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 24.0,
                    ),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      removeFriend(user.id.toString());
                    },
                    child: Icon(
                      Ionicons.trash,
                      color: Colors.red,
                      size: 24.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildFriendsList() {
    return friends.isEmpty
        ? Center(child: Text('Nie masz żadnych znajomych.'))
        : ListView.builder(
      itemCount: friends.length,
      itemBuilder: (context, index) {
        var friend = friends[index];
        return Column(
          children: [
            ListTile(
              leading: GestureDetector(
                onTap: () {
                  showProfile(context, profileId: friend.id.toString());
                },
                child: CircleAvatar(
                  radius: 30.0,
                  backgroundImage: friend.photoUrl != null
                      ? NetworkImage(friend.photoUrl!)
                      : AssetImage('assets/images/profile_avatar.png') as ImageProvider<Object>, // Zastąp domyślnym obrazkiem
                ),
              ),
              title: Text(
                friend.username ?? 'Nieznany użytkownik',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(friend.city ?? 'Nieznane miasto'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      startConversation(widget.userId, friend.id.toString());
                    },
                    child: Icon(
                      Ionicons.chatbubble_ellipses,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 24.0,
                    ),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      removeFriend(friend.id.toString());
                    },
                    child: Icon(
                      Ionicons.remove_circle_outline,
                      color: Colors.red,
                      size: 24.0,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 5,
              thickness: 1.5,
              color: Theme.of(context).colorScheme.secondary,
            )
          ],
        );
      },
    );
  }

  void showProfile(BuildContext context, {required String profileId}) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => Profile(profileId: profileId),
      ),
    );
  }

  Future<void> acceptFriendRequest(String senderId) async {
    try {
      await apiService.acceptFriendRequest(widget.userId, senderId);
      // Refresh pending requests and friends list after accepting the request
      await getPendingRequests();
      await getFriends();
    } catch (e) {
      //print('Error accepting friend request: $e');
    }
  }

  Future<void> rejectFriendRequest(String senderId) async {
    try {
      await apiService.rejectFriendRequest(widget.userId, senderId);
      // Refresh pending requests after rejecting the request
      await getPendingRequests();
    } catch (e) {
      //print('Error rejecting friend request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: searching
            ? TextField(
          controller: searchController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Szukaj...',
            hintStyle: TextStyle(color: Colors.white54),
          ),
          onChanged: performSearch,
        )
            : Text('Znajomi'),
        actions: [
          IconButton(
            icon: Icon(searching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                searching = !searching;
                if (!searching) {
                  searchResults.clear();
                  searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : searching
          ? buildSearchResults()
          : buildFriendsList(),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.person_add),
              onPressed: () {
                // Add your logic to navigate to Add Friends page
              },
            ),
          ],
        ),
      ),
    );
  }
}



