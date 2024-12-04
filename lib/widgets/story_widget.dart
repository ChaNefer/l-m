import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:les_social/models/status.dart';
import 'package:les_social/models/user.dart';
import 'package:les_social/posts/story/status_view.dart';
import 'package:les_social/services/api_service.dart';
import 'package:les_social/widgets/indicators.dart';

class StoryWidget extends StatelessWidget {
  const StoryWidget({Key? key, required this.apiService}) : super(key: key);

  final ApiService apiService;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.0,
      child: Padding(
        padding: const EdgeInsets.only(left: 5.0),
        child: FutureBuilder<List<StatusModel>>(
          future: getStatusList(), // Pobieranie listy statusów z Twojego API
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return circularProgress(context);
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              List<StatusModel> statuses = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                itemCount: statuses.length,
                scrollDirection: Axis.horizontal,
                physics: AlwaysScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  StatusModel status = statuses[index];
                  return _buildStatusAvatar(status as String, status.status!, status.caption!, status.url! as int);
                },
              );
            } else {
              return Center(
                child: Text('No statuses available'),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildStatusAvatar(
      String userId,
      String chatId,
      String messageId,
      int index,
      ) {
    return FutureBuilder<UserModel>(
      future: apiService.getUserById(userId), // Przykładowa metoda do pobrania danych użytkownika
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(); // Obsługa stanu oczekiwania
        } else if (snapshot.hasError) {
          return const SizedBox(); // Obsługa błędów
        } else if (snapshot.hasData) {
          UserModel user = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => StatusScreen(
                          statusId: chatId,
                          storyId: messageId,
                          initPage: index,
                          userId: userId,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.transparent,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          offset: const Offset(0.0, 0.0),
                          blurRadius: 2.0,
                          spreadRadius: 0.0,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: CircleAvatar(
                        radius: 35.0,
                        backgroundColor: Colors.grey,
                        backgroundImage: CachedNetworkImageProvider(
                          user.photoUrl!,
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  user.username!,
                  style: const TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          );
        } else {
          return const SizedBox(); // Obsługa braku danych
        }
      },
    );
  }


  Future<List<StatusModel>> getStatusList() async {
    final url = Uri.parse('https://example.com/api/statuses'); // Zastąp swoim adresem URL API
    final response = await http.get(url);

    if (response.statusCode == 200) {
      Iterable jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((status) => StatusModel.fromJson(status)).toList();
    } else {
      throw Exception('Failed to load statuses');
    }
  }

  Future<UserModel> getUser(String userId) async {
    final url = Uri.parse('https://example.com/api/users/$userId'); // Zastąp swoim adresem URL API
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user');
    }
  }
}
