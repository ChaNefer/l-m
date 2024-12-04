import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:les_social/pages/profile.dart';
import '../models/notification.dart';
import '../models/post.dart';
import '../screens/list_posts.dart';
import '../services/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;

class Activities extends StatefulWidget {
  final String userId;
  final PostModel? post;

  const Activities({Key? key, required this.userId, this.post})
      : super(key: key);

  @override
  _ActivitiesState createState() => _ActivitiesState();
}

class _ActivitiesState extends State<Activities> {
  late ApiService apiService;
  late Future<List<ActivityModel>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    apiService = ApiService(context);
    _notificationsFuture = fetchNotifications();
  }

  // Pobieranie powiadomień z API
  Future<List<ActivityModel>> fetchNotifications() async {
    try {
      if (widget.post != null && widget.post!.postId != null) {
        // Pobieramy powiadomienia dla konkretnego posta
        //print('Fetching notifications for postId: ${widget.post!.postId}');
        final notifications =
            await apiService.getLikeNotifications(widget.post!.postId!);

        // Jeżeli zwrócone powiadomienia są puste, to również spróbuj pobrać ogólne powiadomienia
        if (notifications.isEmpty) {
          //print('Brak powiadomień dla tego posta. Próba pobrania ogólnych powiadomień...');
          return await apiService.getUserNotifications(widget.userId);
        }

        return notifications;
      } else {
        // Pobieramy ogólne powiadomienia dla użytkownika, jeżeli nie ma postId
        //print('Fetching notifications for userId: ${widget.userId}');
        return await apiService.getUserNotifications(widget.userId);
      }
    } catch (e) {
      //print('Błąd podczas pobierania powiadomień: $e');
      return [];
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    final String url =
        'https://lesmind.com/api/notifications/delete_notification.php';
    final response = await http.delete(
      Uri.parse(url),
      body: {'id': notificationId.toString()},
    );
    if (response.statusCode == 200) {
      //print("Powiadomienie zostało usunięte");
    } else {
      //print("Błąd: ${response.statusCode}");
    }
  }

  Future<void> deleteAllNotifications() async {
    try {
      //print('Deleting all notifications for user ID: ${widget.userId}');
      await apiService.deleteAllNotifications(widget.userId);
      setState(() {
        _notificationsFuture =
            fetchNotifications(); // Odśwież listę po usunięciu
      });
      //print('All notifications deleted for user ID: ${widget.userId}');
    } catch (e) {
      //print('Błąd podczas usuwania powiadomień: $e');
    }
  }

  String buildTextConfiguration(ActivityModel activity) {
    if (activity.type == "like") {
      return "${activity.username} polubiła Twój post";
    } else if (activity.type == "comment") {
      return "${activity.username} skomentowała Twój post!";
    } else {
      return "Error: Unknown type '${activity.type}'";
    }
  }

  Widget buildPreviewImage(ActivityModel activity) {
    return GestureDetector(
      onTap: () {
        // Wywołanie metody do pokazania profilu
        showProfile(context, profileId: activity.userId!);
      },
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: activity.userDp ?? '', // Jeśli jest dostępne zdjęcie
          placeholder: (context, url) {
            return CircularProgressIndicator();
          },
          errorWidget: (context, url, error) {
            return Icon(Icons.error);
          },
          height: 50.0, // Zwiększamy wielkość zdjęcia
          width: 50.0,
          fit:
              BoxFit.cover, // Używamy BoxFit.cover, aby zdjęcie wypełniło okrąg
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.keyboard_backspace),
        ),
        automaticallyImplyLeading: false,
        title: const Text('Powiadomienia'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: GestureDetector(
              onTap: () async => await deleteAllNotifications(),
              child: Text(
                'WYCZYŚĆ',
                style: TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<ActivityModel>>(
          future: _notificationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Błąd: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Brak powiadomień'));
            } else {
              final activities = snapshot.data!;

              return ListView.builder(
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  final activity = activities[index];

                  return Dismissible(
                    key: Key(activity.id
                        .toString()), // Użyj unikalnego klucza, np. ID powiadomienia
                    direction: DismissDirection
                        .endToStart, // Przesuwanie tylko w prawo
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) async {
                      // Usuń powiadomienie po przesunięciu
                      await deleteNotification(int.parse(activity.id!));

                      // Odśwież listę powiadomień
                      setState(() {
                        activities.removeAt(index);
                      });

                      // Wyświetl komunikat o powodzeniu
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Powiadomienie usunięte')),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: Colors.grey.shade300,
                      elevation: 4,
                      child: ListTile(
                        leading: buildPreviewImage(activity),
                        title: Text(
                          buildTextConfiguration(activity),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          if (activity.postId != null) {
                            navigateToPost(PostModel(postId: activity.postId));
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            }
          }),
    );
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

  // Funkcja nawigująca po kliknięciu powiadomienia
  void navigateToPost(PostModel postId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListPosts(
          postId: postId,
          userId: widget.userId,
          username: '',
        ),
      ),
    );
  }
}
