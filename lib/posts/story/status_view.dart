import 'dart:io';

import 'package:flutter/material.dart';
import 'package:les_social/models/status.dart';
import 'package:les_social/models/user.dart';
import 'package:les_social/services/api_service.dart';
import 'package:les_social/services/auth_service.dart';
import 'package:les_social/view_models/status/status_view_model.dart';
import 'package:les_social/widgets/indicators.dart';
import 'package:story/story.dart';
import 'package:timeago/timeago.dart' as timeago;

class StatusScreen extends StatefulWidget {
  final initPage;
  final statusId;
  final storyId;
  final userId;

  const StatusScreen({
    Key? key,
    required this.initPage,
    required this.storyId,
    required this.statusId,
    required this.userId,
  }) : super(key: key);

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  late ApiService apiService;
  late AuthService _authService = AuthService();
  List<StatusModel> statuses = []; // Lista statusów

  currentUserId() {
    return _authService.getCurrentUser;
  }

  @override
  void initState() {
    super.initState();
    // Tutaj możesz umieścić logikę pobierania statusów z Twojego backendu
    fetchStatuses(); // Przykładowa funkcja pobierająca statusy
  }

  void fetchStatuses() {
    // Symulacja pobierania statusów z backendu
    // Tutaj zastąp tę logikę rzeczywistym wywołaniem API
    // Na przykład:
    List<StatusModel> fetchedStatuses = [
      StatusModel(
        url: 'https://example.com/image1.jpg',
        caption: 'Caption 1',
        time: DateTime.now(),
        statusId: '1',
        viewers: [],
      ),
      StatusModel(
        url: 'https://example.com/image2.jpg',
        caption: 'Caption 2',
        time: DateTime.now(),
        statusId: '2',
        viewers: [],
      ),
    ];

    setState(() {
      statuses = fetchedStatuses;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onVerticalDragUpdate: (value) {
          Navigator.pop(context);
        },
        child: StoryPageView(
          indicatorPadding: EdgeInsets.symmetric(vertical: 50.0, horizontal: 20.0),
          indicatorHeight: 15.0,
          initialPage: 0,
          onPageLimitReached: () {
            Navigator.pop(context);
          },
          indicatorVisitedColor: Theme.of(context).colorScheme.secondary,
          indicatorDuration: Duration(seconds: 30),
          itemBuilder: (context, pageIndex, storyIndex) {
            StatusModel stats = statuses[storyIndex];

            // Tutaj możesz dodać logikę śledzenia wyświetleń, ale pomiń aktualizację na backendzie
            // Poniżej jest przykład dodawania bieżącego użytkownika do listy wyświetleń
            // List<dynamic> allViewers = stats.viewers ?? [];
            // if (!allViewers.contains(currentUser.id)) {
            //   allViewers.add(currentUser.id);
            // }

            return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 50.0),
                    child: getImage(stats.url),
                  ),
                  Positioned(
                    top: 65.0,
                    left: 10.0,
                    child: FutureBuilder<UserModel>(
                      future: fetchUserData(widget.userId),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          UserModel user = snapshot.data!;

                          return Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.secondary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.transparent,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        offset: new Offset(0.0, 0.0),
                                        blurRadius: 2.0,
                                        spreadRadius: 0.0,
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: CircleAvatar(
                                      radius: 15.0,
                                      backgroundColor: Colors.grey,
                                      // Użyj CachedNetworkImageProvider lub innej metody ładowania obrazu z twojego backendu
                                      backgroundImage: NetworkImage(user.photoUrl ?? ''),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10.0),
                                Column(
                                  children: [
                                    Text(
                                      user.username ?? '',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "${timeago.format(stats.time!)}",
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        } else {
                          return const SizedBox();
                        }
                      },
                    ),
                  ),
                  Positioned(
                    bottom: widget.userId == _authService.getCurrentUser ? 10.0 : 30.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          color: Colors.grey.withOpacity(0.2),
                          width: MediaQuery.of(context).size.width,
                          constraints: BoxConstraints(maxHeight: 50.0),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0,
                                  ),
                                  child: Text(
                                    stats.caption ?? '',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (widget.userId == _authService.getCurrentUser)
                          TextButton.icon(
                            onPressed: () {},
                            icon: Icon(
                              Icons.remove_red_eye_outlined,
                              size: 20.0,
                              color: Theme.of(context).iconTheme.color,
                            ),
                            label: Text(
                              stats.viewers!.length.toString(),
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Theme.of(context).iconTheme.color,
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
          storyLength: (int pageIndex) {
            return statuses.length;
          },
          pageLength: 1,
        ),
      ),
    );
  }

  Widget getImage(String? url) {
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: Image.network(url!),
    );
  }

  Future<UserModel> fetchUserData(String userId) async {
    // Implementuj logikę pobierania danych użytkownika z twojego backendu
    // Na przykład:
    // UserModel user = await userService.getUserData(userId);
    // return user;
    return UserModel(
      username: 'Example User',
      photoUrl: 'https://example.com/avatar.jpg',
    );
  }
}
