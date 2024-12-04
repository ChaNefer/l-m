import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../services/api_service.dart'; // Import ApiService
import '../pages/profile.dart';

class FriendRequestsPage extends StatefulWidget {
  final String userId;

  FriendRequestsPage({required this.userId});

  @override
  _FriendRequestsPageState createState() => _FriendRequestsPageState();
}

class _FriendRequestsPageState extends State<FriendRequestsPage> {
  bool loading = true;
  List<Map<String, dynamic>> friendRequests = []; // Lista zaproszeń do znajomych

  @override
  void initState() {
    super.initState();
    _fetchFriendRequests(); // Pobierz zaproszenia przy inicjalizacji strony
  }

  Future<void> _fetchFriendRequests() async {
    try {
      // Pobierz zaproszenia do znajomych z Twojego API
      var apiService = ApiService(context);
      var fetchedRequests = await apiService.fetchFriendRequests(widget.userId);
      //print("Fetched friend request: $fetchedRequests");

      setState(() {
        friendRequests = fetchedRequests;
        loading = false;
      });
    } catch (e) {
      //print('Error fetching friend requests: $e');
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zaproszenia do znajomych'),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : buildFriendRequestsList(),
    );
  }

  Widget buildFriendRequestsList() {
    if (friendRequests.isEmpty) {
      return Center(
        child: Text('Nie masz żadnych zaproszeń do znajomych.'),
      );
    }

    return ListView.builder(
      itemCount: friendRequests.length,
      itemBuilder: (context, index) {
        var request = friendRequests[index];

        var senderName = request['senderName'] ?? 'Anonim';
        var senderPhotoUrl = request['senderPhotoUrl'] ?? '';
        var senderAge = request['senderAge'] ?? 0;

        return Column(
          children: [
            ListTile(
              leading: GestureDetector(
                onTap: () {
                  // Nawiązanie nawigacji do profilu, jak wcześniej
                  showProfile(context, profileId: request['senderId']);
                },
                child: CircleAvatar(
                  radius: 30.0,
                  backgroundImage: NetworkImage(senderPhotoUrl),
                  child: senderPhotoUrl.isEmpty
                      ? Icon(Icons.person)
                      : null,
                ),
              ),
              title: Text(
                senderName,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Wiek: $senderAge'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      acceptFriendRequest(request['senderId']);
                    },
                    child: Icon(
                      Ionicons.checkmark_circle,
                      color: Colors.green,
                      size: 24.0,
                    ),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      rejectFriendRequest(request['senderId']);
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
            ),
          ],
        );
      },
    );
  }

  void acceptFriendRequest(String senderId) async {
    try {
      // Wywołanie metody w ApiService do akceptacji zaproszenia
      var apiService = ApiService(context);
      await apiService.acceptFriendRequest(widget.userId, senderId);

      // Usuń zaproszenie z listy po zaakceptowaniu
      setState(() {
        friendRequests.removeWhere((request) => request['senderId'] == senderId);
      });

      // Wyświetlenie powiadomienia o sukcesie
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Zaproszenie zaakceptowane.')),
      );
    } catch (e) {
      // Obsłuż błędy
      //print('Error accepting friend request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Wystąpił błąd podczas akceptacji zaproszenia.')),
      );
    }
  }

  void rejectFriendRequest(String senderId) async {
    try {
      // Wywołanie metody w ApiService do odrzucenia zaproszenia
      var apiService = ApiService(context);
      await apiService.rejectFriendRequest(widget.userId, senderId);

      // Usuń zaproszenie z listy po odrzuceniu
      setState(() {
        friendRequests.removeWhere((request) => request['senderId'] == senderId);
      });

      // Wyświetlenie powiadomienia o sukcesie
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Zaproszenie odrzucone.')),
      );
    } catch (e) {
      // Obsłuż błędy
      //print('Error rejecting friend request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Wystąpił błąd podczas odrzucania zaproszenia.')),
      );
    }
  }

  void showProfile(BuildContext context, {required String profileId}) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => Profile(profileId: profileId),
      ),
    );
  }
}
