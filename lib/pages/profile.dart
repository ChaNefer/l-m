import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:ionicons/ionicons.dart';
import 'package:les_social/chats/recent_chats.dart';
import 'package:les_social/components/stream_grid_wrapper.dart';
import 'package:les_social/models/post.dart';
import 'package:les_social/models/user.dart';
import 'package:les_social/pages/more_about.dart';
import 'package:les_social/pages/notification.dart';
import 'package:les_social/pages/portfolio.dart';
import 'package:les_social/screens/edit_profile.dart';
import 'package:les_social/screens/list_posts.dart';
import 'package:les_social/screens/settings.dart';
import 'package:les_social/services/auth_service.dart';
import 'package:les_social/services/storage_class.dart';
import 'package:les_social/view_models/more_about/more_about_view_model.dart';
import 'package:les_social/widgets/post_tiles.dart';
import 'package:provider/provider.dart';
import '../auth/login/login.dart';
import '../models/notification.dart';
import '../screens/comment.dart';
import '../services/api_service.dart';
import '../utils/friend_requests_page.dart';
import 'friends_list_page.dart';

class Profile extends StatefulWidget {
  final String profileId;
  final ActivityModel? activity;

  Profile({required this.profileId, this.activity}) {
    // //print("Inicjalizowanie powiadomien  z postId: ${post!.postId}");
  }

  get currentUserId => null;

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  UserModel? user;
  bool isLoading = false;
  int postCount = 0;
  int followersCount = 0;
  int followingCount = 0;
  bool isFollowing = false;
  bool isExpanded = false;
  bool addFriend = false;
  bool isFriend = false; // eksperymentalne
  bool isRequestPending = false;
  bool isAccepted = false;
  String? friendRequestStatus;
  UserModel? users;
  final DateTime timestamp = DateTime.now();
  ScrollController controller = ScrollController();
  late MoreAboutViewModel viewModel;
  bool _dialogShown = false; // Flaga do śledzenia stanu dialogu
  int notificationCount = 0;
  int friendRequestCount = 0;
  List<dynamic> activitiesList = [];
  late ApiService apiService;
  late AuthService _authService;
  late StorageClass storage;
  late Future<UserModel> _userProfile;

  void fetchCurrentUser() async {
    try {
      user = await currentUserId();
      //print("fetchCurrentUser: użytkownik załadowany - ${user!.id}");
    } catch (e) {
      //print("fetchCurrentUser: Bład w ładowaniu użytkownika - $e");
    }
  }

  Future<UserModel?> currentUserId() async {
    try {
      var currentUser = await _authService.getCurrentUser();
      //print("currentUserId: Pobrano ID aktualnie zalogowanego użytkownika - ${currentUser?.id}"); // Debugowanie
      return currentUser;
    } catch (e) {
      //print("currentUserId: Błąd podczas pobierania danych użytkownika - $e"); // Debugowanie
      return null;
    }
  }

  // Future<void> loadPost() async {
  //   final post = await apiService.getPostById(widget.profileId);
  //   setState(() {
  //     widget.post = post;
  //   });
  // }

  // Future<List<ActivityModel>> fetchNotifications() async {
  //   try {
  //     // Upewniamy się, że przekazujemy cały obiekt PostModel
  //     //print('Fetching notifications for post ID: ${widget.post}');
  //     List<ActivityModel> notifications = await apiService.getLikeNotifications(widget.post!);  // Przekazujemy cały obiekt
  //     //print('Fetched ${notifications.length} notifications for post ID: ${widget.post}');
  //     return notifications;
  //   } catch (e) {
  //     //print('Błąd podczas pobierania powiadomień: $e');
  //     return [];
  //   }
  // }

  @override
  void initState() {
    super.initState();
    //print('initState: Rozpoczęto inicjalizację'); // Debugowanie
    try {
      apiService = ApiService(context);
      user = UserModel();
      viewModel = MoreAboutViewModel(context);
      storage = StorageClass();
      _authService = AuthService();
      //print('initState: Usługi zainicjalizowane'); // Debugowanie
      _userProfile = apiService.fetchUserProfile(widget.profileId);
      //print('initState: Przypisano Future do _userProfile'); // Debugowanie
      fetchCurrentUser();
      fetchUserPosts(widget.profileId);
      checkIfFollowing();
      _loadNotificationCount();
      _loadFriendRequestCount('');
      checkIfFriend();
      checkIfRequestPending();
      //print('initState: Metody setupu wywołane'); // Debugowanie
    } catch (e) {
      //print('initState: Wystąpił wyjątek - $e'); // Debugowanie
    }
    // loadPost();
  }

  void resetFriendRequestCount() {
    setState(() {
      friendRequestCount = 0;
      //print('Resetting friendRequestCount to 0');
    });
  }

  @override
  void dispose() {
    // Zatrzymaj nasłuchiwanie przy wychodzeniu z widoku
    // invitationsSubscription?.cancel();
    //print('Dispose: Listener cancelled');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("build: Profil ID - ${widget.profileId}"); // Debugowanie
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/lesmind.png',
          height: 60.0,
          width: 170.0,
          fit: BoxFit.scaleDown,
        ),
        actions: [
          IconButton(
            onPressed: () async {
              // Najpierw wykonaj logout
              await _authService.logout();

              // Następnie przejdź do ekranu logowania, usuwając wszystkie poprzednie trasy
              Navigator.of(context).pushAndRemoveUntil(
                CupertinoPageRoute(builder: (_) => Login()),
                (Route<dynamic> route) => false,
              );
            },
            icon: Icon(Ionicons.power_outline),
          )
        ],
      ),
      body: FutureBuilder<UserModel>(
          future: _userProfile,
          builder: (context, userSnapshot) {
            //print('Connection state: ${userSnapshot.connectionState}');
            //print('Snapshot data: ${userSnapshot.data}');
            //print('Snapshot error: ${userSnapshot.error}');
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (userSnapshot.hasError) {
              return Center(
                  child: Text('Wystąpił błąd: ${userSnapshot.error}'));
            }
            if (!userSnapshot.hasData || userSnapshot.data == null) {
              return Center(child: Text('Brak danych o użytkowniku'));
            }

            return FutureBuilder<UserModel?>(
              future: currentUserId(),
              builder: (context, currentUserSnapshot) {
                if (currentUserSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (currentUserSnapshot.hasError) {
                  return Center(
                      child:
                          Text('Wystąpił błąd: ${currentUserSnapshot.error}'));
                }
                if (!currentUserSnapshot.hasData ||
                    currentUserSnapshot.data == null) {
                  return Center(
                      child: Text('Brak danych o aktualnym użytkowniku'));
                }

                UserModel currentUser = currentUserSnapshot.data!;
                bool isCurrentUser = widget.profileId == currentUser.id;

                return CustomScrollView(
                  slivers: <Widget>[
                    SliverAppBar(
                      automaticallyImplyLeading: false,
                      pinned: true,
                      floating: false,
                      toolbarHeight: 5.0,
                      collapsedHeight: 6.0,
                      expandedHeight: 225.0,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 5.0),
                                  child: userSnapshot.data!.photoUrl != null &&
                                          userSnapshot
                                              .data!.photoUrl!.isNotEmpty
                                      ? CircleAvatar(
                                          radius: 40.0,
                                          backgroundImage:
                                              CachedNetworkImageProvider(
                                                  userSnapshot.data!.photoUrl!),
                                        )
                                      : CircleAvatar(
                                          radius: 40.0,
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          child: Center(
                                            child: Text(
                                              '${userSnapshot.data!.username![0].toUpperCase()}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ),
                                        ),
                                ),
                                SizedBox(width: 10.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 32.0),
                                    Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              // width: 130.0,
                                              child: Text(
                                                userSnapshot.data!.username !=
                                                        null
                                                    ? userSnapshot
                                                        .data!.username!
                                                    : 'Unknown',
                                                style: TextStyle(
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                                maxLines: null,
                                              ),
                                            ),
                                            Container(
                                              // width: 130.0,
                                              child: Text(
                                                userSnapshot.data!.city ??
                                                    'Unknown',
                                                style: TextStyle(
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            SizedBox(width: 10.0),
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  userSnapshot.data!.age != null
                                                      ? userSnapshot.data!.age!
                                                          .toString()
                                                      : 'Unknown',
                                                  style: TextStyle(
                                                    fontSize: 10.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: 25),
                                        if (isCurrentUser)
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 1.0, right: 1.0),
                                                child: InkWell(
                                                  onTap: () async {
                                                    await handleSentInvitation(
                                                        widget.profileId);
                                                    Navigator.of(context).push(
                                                      CupertinoPageRoute(
                                                        builder: (_) =>
                                                            FriendRequestsPage(
                                                                userId: widget
                                                                    .profileId),
                                                      ),
                                                    );
                                                  },
                                                  child: Stack(
                                                    children: [
                                                      IconButton(
                                                        icon: Icon(
                                                          Icons.people_outlined,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .secondary,
                                                        ),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .push(
                                                                  CupertinoPageRoute(
                                                            builder: (_) =>
                                                                FriendRequestsPage(
                                                                    userId: widget
                                                                        .profileId),
                                                          ));
                                                        },
                                                      ),
                                                      if (friendRequestCount >
                                                          0)
                                                        Positioned(
                                                          right: 11,
                                                          top: 11,
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    1),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors.red,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6),
                                                            ),
                                                            constraints:
                                                                BoxConstraints(
                                                              minWidth: 12,
                                                              minHeight: 12,
                                                            ),
                                                            child: Text(
                                                              '$friendRequestCount',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 8,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 6),
                                              InkWell(
                                                onTap: () async {
                                                  Navigator.of(context)
                                                      .push(
                                                    CupertinoPageRoute(
                                                      builder: (_) =>
                                                          Activities(
                                                        userId:
                                                            widget.profileId,
                                                      ),
                                                    ),
                                                  )
                                                      .then((_) {
                                                    resetFriendRequestCount();
                                                  });
                                                },
                                                child: Column(
                                                  /*

                                                   */

                                                  children: [
                                                    Icon(
                                                      CupertinoIcons.bell_solid,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondary,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(width: 15),
                                              IconButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              Chats()),
                                                    );
                                                  },
                                                  icon: Icon(
                                                    Ionicons
                                                        .chatbubble_ellipses,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                  )),
                                              InkWell(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    CupertinoPageRoute(
                                                      builder: (_) => MoreAbout(
                                                          user: userSnapshot
                                                              .data!),
                                                    ),
                                                  );
                                                },
                                                child: Consumer<
                                                    MoreAboutViewModel>(
                                                  builder: (context, viewModel,
                                                      child) {
                                                    double filledPercent = viewModel
                                                            .profileCompletion ??
                                                        0.0;
                                                    if (!_dialogShown) {
                                                      WidgetsBinding.instance
                                                          .addPostFrameCallback(
                                                              (_) {
                                                        if (filledPercent <
                                                            100) {
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (context) =>
                                                                    AlertDialog(
                                                              title: Text(
                                                                  'Uzupełnij profil'),
                                                              content: Text(
                                                                  'Twój profil jest w $filledPercent% uzupełniony. Czy chcesz uzupełnić brakujące informacje?'),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  child: Text(
                                                                      'Nie'),
                                                                ),
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                    Navigator.of(
                                                                            context)
                                                                        .push(
                                                                      CupertinoPageRoute(
                                                                        builder:
                                                                            (_) =>
                                                                                MoreAbout(user: userSnapshot.data!),
                                                                      ),
                                                                    );
                                                                  },
                                                                  child: Text(
                                                                      'Tak'),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                          _dialogShown = true;
                                                        }
                                                      });
                                                    }
                                                    return Stack(
                                                      children: [
                                                        Container(
                                                          height: 30,
                                                          width: 30,
                                                          child:
                                                              CircularProgressIndicator(
                                                            value:
                                                                filledPercent /
                                                                    100,
                                                            strokeWidth: 3.5,
                                                            backgroundColor:
                                                                Colors.grey,
                                                            valueColor:
                                                                AlwaysStoppedAnimation<
                                                                    Color>(
                                                              _calculateBorderColor(
                                                                  filledPercent),
                                                            ),
                                                          ),
                                                        ),
                                                        Positioned.fill(
                                                          child: Center(
                                                            child:
                                                                filledPercent ==
                                                                        100
                                                                    ? Icon(
                                                                        Icons
                                                                            .done,
                                                                        color: Theme.of(context)
                                                                            .colorScheme
                                                                            .secondary,
                                                                        size:
                                                                            16,
                                                                      )
                                                                    : Text(
                                                                        '${filledPercent.toStringAsFixed(0)}%',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              10,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                      ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          )
                                        else
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                CupertinoPageRoute(
                                                  builder: (_) => Portfolio(
                                                      userId: widget.profileId),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.transparent,
                                              elevation: 0,
                                            ),
                                            child: Text(
                                              'Portfolio',
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                              ),
                                            ),
                                          ),
                                        SizedBox(height: 10),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10.0, left: 20.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Etykieta „Bio:”
                                      Text(
                                        'Bio:',
                                        style: TextStyle(
                                          fontSize: 12.0,
                                        ),
                                      ),
                                      // Kontener z tekstem bio lub pusty kontener
                                      userSnapshot.data!.bio == null ||
                                              userSnapshot.data!.bio!.isEmpty
                                          ? SizedBox()
                                          : Container(
                                              width: 200,
                                              child: Text(
                                                userSnapshot.data!.bio!,
                                                style: TextStyle(
                                                  fontSize: 10.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: null,
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                buildProfileButton(user),
                                SizedBox(width: 10),
                                FutureBuilder<UserModel?>(
                                  future:
                                      currentUserId(), // Pobieranie aktualnie zalogowanego użytkownika
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator(); // Wyświetlanie wskaźnika ładowania, jeśli dane są wczytywane
                                    }
                                    if (snapshot.hasError) {
                                      return Text(
                                          'Wystąpił błąd: ${snapshot.error}');
                                    }
                                    if (!snapshot.hasData ||
                                        snapshot.data == null) {
                                      return SizedBox
                                          .shrink(); // Jeśli brak danych, zwróć pusty widget
                                    }

                                    // Sprawdzenie, czy przeglądany profil to aktualnie zalogowany użytkownik
                                    bool isMe =
                                        widget.profileId == snapshot.data!.id;

                                    if (isMe) {
                                      return buildFriendsListButton(
                                        text: "Lista znajomych",
                                        function:
                                            handleDisplayFriendsListInvitations,
                                      );
                                    } else {
                                      return buildAddFriendButton(
                                        text: isFriend
                                            ? "Znajomi"
                                            : isRequestPending
                                                ? "Cierpliwości..."
                                                // warunek, jesli zaproszenie jest zaakceptowane. isAccepted
                                                : "Dodaj znajomego",
                                        function: () {
                                          if (!isFriend && !isRequestPending) {
                                            handleSentInvitation(
                                                widget.profileId);
                                            setState(() {
                                              isRequestPending = true;
                                            });
                                          }
                                        },
                                        friendRequestStatus:
                                            friendRequestStatus,
                                      );
                                    }
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          if (index > 0) return null;
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Row(
                                  children: [
                                    Text(
                                      'Moje posty',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      onPressed: () async {
                                        // Pobierz dane użytkownika z Future
                                        UserModel currentUser =
                                            await _userProfile;

                                        Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                            builder: (_) => ListPosts(
                                                userId: widget.profileId,
                                                username:
                                                    currentUser.username!),
                                          ),
                                        );
                                      },
                                      icon: Icon(Icons.grid_on),
                                    )
                                  ],
                                ),
                              ),
                              buildPostView(),
                              // Padding(
                              //   padding: const EdgeInsets.all(10.0),
                              //   child: Row(
                              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //     children: [
                              //       // Lajki
                              //       buildLikeButton(widget.profileId),
                              //       // Komentarze
                              //       GestureDetector(
                              //         onTap: () {
                              //           // Przenieś do ekranu komentarzy
                              //           Navigator.push(
                              //             context,
                              //             MaterialPageRoute(
                              //               builder: (context) => Comments(
                              //                 post: PostModel(
                              //                   userId: widget.profileId
                              //                   // Inne parametry postu, które masz w profilu
                              //                 ),
                              //               ),
                              //             ),
                              //           );
                              //         },
                              //         child: Row(
                              //           children: [
                              //             Icon(Ionicons.chatbubble_outline, size: 25),
                              //             SizedBox(width: 5),
                              //             Text('Komentarze'),
                              //           ],
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),

                              SizedBox(height: 50),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          }),
    );
  }

  Future<void> checkIfFollowing() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://lesmind.com/api/users/${widget.profileId}/checkFollowing'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          // Dodaj tutaj nagłówki autoryzacyjne lub inne potrzebne
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          isFollowing = jsonDecode(response.body)['isFollowing'];
        });
      } else {
        throw Exception('Failed to check if following');
      }
    } catch (e) {
      //print('Error checking if following: $e');
    }
  }

  Future<void> checkIfFriend() async {
    try {
      final response = await http.post(
        Uri.parse('https://lesmind.com/api/friends/invitations.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'action': 'check_status',
          'userId': widget.profileId,
          'senderId': widget.currentUserId,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          isFriend = jsonDecode(response.body)['hasFriendRequests'];
        });
      } else {
        throw Exception('Failed to check if friend request exists');
      }
    } catch (e) {
      //print('Error checking if friend request: $e');
    }
  }

  Future<void> checkIfRequestPending() async {
    try {
      final response = await http.post(
        Uri.parse('https://lesmind.com/api/friends/invitations.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'action': 'check_pending',
          'userId': widget.currentUserId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          isRequestPending = data['requestPending'];
        });
      } else {
        throw Exception('Failed to check if request pending');
      }
    } catch (e) {
      //print('Error checking request pending: $e');
    }
  }

  void updateUserData(UserModel updatedUser) async {
    try {
      final response = await http.put(
        Uri.parse('https://lesmind.com/api/users/${updatedUser.id}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          // Dodaj tutaj nagłówki autoryzacyjne lub inne potrzebne
        },
        body: jsonEncode(updatedUser.toJson()),
      );

      if (response.statusCode == 200) {
        setState(() {
          users = updatedUser;
        });
        //print('Dane użytkownika zaktualizowane pomyślnie');
      } else {
        //print('Błąd podczas aktualizacji danych użytkownika: ${response.statusCode}');
      }
    } catch (e) {
      //print('Błąd podczas aktualizacji danych użytkownika: $e');
    }
  }

  // metoda obliczajaca procenty wypelnienia profilu
  double calculateProfileCompletion(UserModel user) {
    double completion = 0.0;
    int totalFields = 4; // Total number of fields in the profile
    int filledFields = 0; // Number of filled fields

    if (user.username != null && user.username!.isNotEmpty) filledFields++;
    if (user.bio != null && user.bio!.isNotEmpty) filledFields++;
    if (user.age != null) filledFields++;
    if (user.country != null && user.country!.isNotEmpty) filledFields++;
    if (user.orientation != null && user.orientation!.isNotEmpty)
      filledFields++;

    completion = filledFields / totalFields;
    return completion;
  }

  buildCount(String label, int count) {
    return Column(
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w900,
            fontFamily: 'Ubuntu-Regular',
          ),
        ),
        SizedBox(height: 3.0),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            fontFamily: 'Ubuntu-Regular',
          ),
        )
      ],
    );
  }

  Widget buildProfileButton(UserModel? user) {
    // Pobierz aktualnie zalogowanego użytkownika
    return FutureBuilder<UserModel?>(
      future: currentUserId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Wystąpił błąd: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('Brak danych o zalogowanym użytkowniku'));
        }

        // Sprawdź, czy aktualnie zalogowany użytkownik jest tym samym, który jest wyświetlany
        bool isMe = widget.profileId == snapshot.data!.id;

        // Na podstawie warunku renderuj odpowiedni przycisk
        if (isMe) {
          return Row(
            children: [
              buildButton(
                text: "Edytuj profil",
                function: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => EditProfile(user: user),
                    ),
                  );
                },
              ),
            ],
          );
        } else if (isFollowing) {
          return buildButton(
            text: "Przestań obserwować",
            function: handleUnfollow,
          );
        } else if (!isFollowing) {
          return buildButton(
            text: "Obserwuj",
            function: handleFollow,
          );
        }

        return SizedBox.shrink(); // Default case to return an empty widget
      },
    );
  }

  buildButton({String? text, Function()? function}) {
    return Center(
      child: GestureDetector(
        onTap: function!,
        child: Container(
          height: 40.0,
          width: 150.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Theme.of(context).colorScheme.secondary,
                Color(0xff597FDB),
              ],
            ),
          ),
          child: Center(
            child: Text(
              text!,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  buildButtonMore({String? text, Function()? function}) {
    return Center(
      child: GestureDetector(
        onTap: function!,
        child: Container(
          height: 40.0,
          width: 200.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Theme.of(context).colorScheme.secondary,
                Color(0xff597FDB),
              ],
            ),
          ),
          child: Center(
            child: Text(
              text!,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAddFriendButton({
    required String text,
    required Function() function,
    required String? friendRequestStatus,
  }) {
    return FutureBuilder<UserModel?>(
      future: currentUserId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Wystąpił błąd: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('Brak danych o zalogowanym użytkowniku'));
        }

        bool isMe = widget.profileId == snapshot.data!.id;

        if (isMe) {
          return SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () async {
            await function(); // Funkcja przekazywana jako parametr
            // Opcjonalnie: Po wysłaniu zaproszenia sprawdź status
          },
          child: Container(
            height: 40.0,
            width: 150.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Theme.of(context).colorScheme.secondary,
                  Color(0xff597FDB),
                ],
              ),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    friendRequestStatus == null
                        ? text
                        : friendRequestStatus == 'pending'
                            ? 'Cierpliwości...'
                            : 'Znajomi',
                    style: TextStyle(color: Colors.white),
                  ),
                  if (friendRequestStatus == 'accepted') SizedBox(width: 5),
                  if (friendRequestStatus == 'accepted')
                    Icon(
                      Icons.done,
                      color: Colors.white,
                      size: 16.0,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void handleUnfollow() async {
    try {
      final response = await http.post(
        Uri.parse('https://example.com/api/users/${widget.profileId}/unfollow'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          // Dodaj tutaj nagłówki autoryzacyjne lub inne potrzebne
        },
        body: jsonEncode(<String, dynamic>{
          'userId': widget.profileId,
          // Możesz przesłać więcej danych, jeśli potrzebujesz
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          isFollowing = false;
        });
        //print('Unfollow successful');
      } else {
        throw Exception('Failed to unfollow user');
      }
    } catch (e) {
      //print('Error unfollowing user: $e');
    }
  }

  void handleFollow() async {
    try {
      final response = await http.post(
        Uri.parse('https://example.com/api/users/${widget.profileId}/follow'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          // Dodaj tutaj nagłówki autoryzacyjne lub inne potrzebne
        },
        body: jsonEncode(<String, dynamic>{
          'userId': widget.profileId,
          // Możesz przesłać więcej danych, jeśli potrzebujesz
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          isFollowing = true;
        });
        //print('Follow successful');
      } else {
        throw Exception('Failed to follow user');
      }
    } catch (e) {
      //print('Error following user: $e');
    }
  }

  // Future<void> handleAddFriend(String userId) async {
  //   try {
  //     //print('Dodawanie znajomego...');
  //
  //     // do zrobienia!!!
  //     // Pobierz dane aktualnego użytkownika
  //     final responseUser = await http.get(
  //       Uri.parse('https://lesmind.com/api/friends/$currentUserId'),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //         // Dodaj tutaj nagłówki autoryzacyjne lub inne potrzebne
  //       },
  //     );
  //
  //     if (responseUser.statusCode == 200) {
  //       Map<String, dynamic> userData = jsonDecode(responseUser.body);
  //       String username = userData['username'];
  //       String userPhotoUrl = userData['photoUrl'];
  //
  //       // Dodaj żądanie znajomych do podkolekcji 'friend_request'
  //       final responseFriendRequest = await http.post(
  //         Uri.parse(
  //             'https://lesmind.com/api/friends/${widget.profileId}/friendRequests'),
  //         headers: <String, String>{
  //           'Content-Type': 'application/json; charset=UTF-8',
  //           // Dodaj tutaj nagłówki autoryzacyjne lub inne potrzebne
  //         },
  //         body: jsonEncode({
  //           'userId': currentUserId(),
  //           'username': username,
  //           'timestamp': DateTime.now().millisecondsSinceEpoch,
  //           'status': 'pending',
  //         }),
  //       );
  //
  //       if (responseFriendRequest.statusCode == 200) {
  //         //print('Żądanie znajomego dodane pomyślnie.');
  //
  //         // Dodaj powiadomienie do kolekcji 'notifications'
  //         final responseNotification = await http.post(
  //           Uri.parse('https://lesmind.com/api/users/${widget.profileId}/notifications'),
  //           headers: <String, String>{
  //             'Content-Type': 'application/json; charset=UTF-8',
  //             // Dodaj tutaj nagłówki autoryzacyjne lub inne potrzebne
  //           },
  //           body: jsonEncode({
  //             'type': 'friend',
  //             'ownerId': widget.profileId,
  //             'username': username,
  //             'userId': currentUserId(),
  //             'userDp': userPhotoUrl,
  //             'timestamp': DateTime.now().millisecondsSinceEpoch,
  //           }),
  //         );
  //
  //         if (responseNotification.statusCode == 200) {
  //           //print('Powiadomienie dodane pomyślnie.');
  //         } else {
  //           //print(
  //               'Błąd podczas dodawania powiadomienia: ${responseNotification.statusCode}');
  //         }
  //       } else {
  //         //print(
  //             'Błąd podczas dodawania żądania znajomego: ${responseFriendRequest.statusCode}');
  //       }
  //     } else {
  //       //print(
  //           'Błąd podczas pobierania danych użytkownika: ${responseUser.statusCode}');
  //     }
  //   } catch (e) {
  //     //print("Błąd podczas dodawania znajomego: $e");
  //   }
  // }

  Future<String> _getUserName(String profileId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://lesmind.com/api/users/get_user.php?userId=$profileId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['username'] ??
            'Brak nazwy użytkownika';
      } else {
        //print('Error response: ${response.body}'); // Zaloguj treść odpowiedzi w celu debugowania
        throw Exception('Failed to fetch username');
      }
    } catch (e) {
      //print('Error fetching username: ${e.toString()}'); // Zaloguj szczegóły błędu
      return 'Brak nazwy użytkownika';
    }
  }

  Future<String> _getUserPhotoUrl(String profileId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://lesmind.com/api/users/get_user.php?userId=$profileId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['photoUrl'] ?? '';
      } else {
        throw Exception('Failed to fetch user photoUrl');
      }
    } catch (e) {
      //print('Error fetching user photoUrl: $e');
      return '';
    }
  }

  Future<String> _getUserCity(String profileId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://lesmind.com/api/users/get_user.php?userId=$profileId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['city'] ?? '';
      } else {
        throw Exception('Failed to fetch user city');
      }
    } catch (e) {
      //print('Error fetching user city: $e');
      return '';
    }
  }

  Future<int> _getUserAge(String profileId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://lesmind.com/api/users/get_user.php?userId=$profileId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        return int.tryParse(jsonDecode(response.body)['age'] ?? '0') ?? 0;
      } else {
        throw Exception('Failed to fetch user age');
      }
    } catch (e) {
      //print('Error fetching user age: $e');
      return 0;
    }
  }

  // Future<void> handleSentInvitation(String userId) async {
  //   //print('Sending friend invitation to user with ID: $userId');
  //
  //   if (userId == currentUserId) {
  //     //print('Cannot send an invitation to yourself');
  //     return;
  //   }
  //
  //   try {
  //     // Sprawdź, czy użytkownik jest już Twoim znajomym
  //     final responseCheckFriend = await http.get(
  //       Uri.parse('https://lesmind.com/api/friends/$userId/check_friend_request.php?userId=$currentUserId'),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //     );
  //
  //     //print('Response status for check friend: ${responseCheckFriend.statusCode}');
  //     //print('Response body for check friend: ${responseCheckFriend.body}');
  //
  //     if (responseCheckFriend.statusCode == 200) {
  //       bool isFriend = jsonDecode(responseCheckFriend.body)['hasFriendRequests'];
  //
  //       if (isFriend) {
  //         //print('User is already your friend.');
  //         return;
  //       }
  //     } else {
  //       throw Exception('Failed to check if user is friend');
  //     }
  //
  //     // Sprawdź, czy istnieje już wysłane zaproszenie
  //     final responseSentInvitation = await http.get(
  //       Uri.parse('https://lesmind.com/api/friends/$currentUserId/sentInvitations/$userId'),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //     );
  //
  //     //print('Response status for sent invitation: ${responseSentInvitation.statusCode}');
  //     //print('Response body for sent invitation: ${responseSentInvitation.body}');
  //
  //     if (responseSentInvitation.statusCode == 200) {
  //       // Usuń istniejące zaproszenie
  //       final responseDeleteInvitation = await http.delete(
  //         Uri.parse('https://lesmind.com/api/friends/$currentUserId/sentInvitations/$userId'),
  //         headers: <String, String>{
  //           'Content-Type': 'application/json; charset=UTF-8',
  //         },
  //       );
  //
  //       final responseDeleteFriendRequest = await http.delete(
  //         Uri.parse('http://lemsind.com/api/friends/$userId/friend_requests.php/$currentUserId'),
  //         headers: <String, String>{
  //           'Content-Type': 'application/json; charset=UTF-8',
  //         },
  //       );
  //
  //       if (responseDeleteInvitation.statusCode == 200 && responseDeleteFriendRequest.statusCode == 200) {
  //         //print('Invitation deleted successfully');
  //         setState(() {
  //           isRequestPending = false;
  //           friendRequestStatus = null;
  //         });
  //       } else {
  //         throw Exception('Failed to delete existing invitation');
  //       }
  //     } else if (responseSentInvitation.statusCode == 404) {
  //       // Zapisz nowe zaproszenie
  //       String senderName = await _getUserName();
  //       String receiverName = await _getUserName();
  //       String senderPhotoUrl = await _getUserPhotoUrl(userId);
  //       String senderCity = await _getUserCity(userId);
  //       int senderAge = await _getUserAge(userId);
  //
  //       final responseSendInvitation = await http.post(
  //         Uri.parse('https://lesmind.com/api/friends/$currentUserId/sentInvitations'),
  //         headers: <String, String>{
  //           'Content-Type': 'application/json; charset=UTF-8',
  //         },
  //         body: jsonEncode(<String, dynamic>{
  //           'profileId': userId,
  //           'senderName': senderName,
  //           'receiverName': receiverName,
  //           'senderPhotoUrl': senderPhotoUrl,
  //           'senderAge': senderAge,
  //           'senderCity': senderCity,
  //         }),
  //       );
  //
  //       final responseStoreFriendRequest = await http.post(
  //         Uri.parse('https://lesmind.com/api/friends/$userId/friend_request.php'),
  //         headers: <String, String>{
  //           'Content-Type': 'application/json; charset=UTF-8',
  //         },
  //         body: jsonEncode(<String, dynamic>{
  //           'senderName': senderName,
  //           'senderPhotoUrl': senderPhotoUrl,
  //           'senderAge': senderAge,
  //           'senderCity': senderCity,
  //         }),
  //       );
  //
  //       if (responseSendInvitation.statusCode == 200 && responseStoreFriendRequest.statusCode == 200) {
  //         //print('Invitation sent and stored successfully');
  //         setState(() {
  //           isRequestPending = true;
  //           friendRequestStatus = 'pending';
  //         });
  //       } else {
  //         throw Exception('Failed to send or store invitation');
  //       }
  //     } else {
  //       throw Exception('Failed to check existing invitation');
  //     }
  //
  //     // Aktualizacja licznika zaproszeń
  //     final responseCountInvitations = await http.get(
  //       Uri.parse('https://lesmind.com/api/users/$currentUserId/sentInvitations'),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //     );
  //
  //     if (responseCountInvitations.statusCode == 200) {
  //       setState(() {
  //         friendRequestCount = jsonDecode(responseCountInvitations.body)['count'];
  //       });
  //     } else {
  //       throw Exception('Failed to count invitations');
  //     }
  //   } catch (e) {
  //     //print('Error handling invitation: $e');
  //     // Obsłuż błędy w razie wystąpienia
  //   }
  // }

  Future<void> handleSentInvitation(String recipientUserId) async {
    //print('Sending friend invitation to user with ID: $recipientUserId');

    UserModel? currentUser = await currentUserId();
    if (currentUser == null) {
      //print('Error: Brak aktualnie zalogowanego użytkownika');
      return;
    }

    String? currentUserIdValue = currentUser.id;

    // Sprawdzenie, czy nie próbujesz wysłać zaproszenia do siebie
    if (recipientUserId == currentUserIdValue) {
      //print('Cannot send an invitation to yourself');
      return;
    }

    try {
      // Przygotowanie danych do zaproszenia
      final invitationData = await _prepareInvitationData(currentUserIdValue!);

      // Wysyłanie zaproszenia
      final responseSendInvitation = await _sendInvitation(
          invitationData, recipientUserId, currentUserIdValue);

      // Sprawdzanie odpowiedzi
      if (responseSendInvitation.statusCode == 200) {
        final responseBody = jsonDecode(responseSendInvitation.body);
        //print('Invitation sent successfully: ${responseBody['success']}');

        if (responseBody['success'] == true) {
          setState(() {
            isRequestPending = true;
            friendRequestStatus = 'pending';
          });
        } else {
          //print('Failed to send invitation: ${responseBody['message']}');
        }
      } else {
        //print("Failed to send invitation. Status code: ${responseSendInvitation.statusCode}");
      }

      // Aktualizacja licznika zaproszeń
      await updateFriendRequestCount(currentUserIdValue);
    } catch (e) {
      //print('Error handling invitation: $e');
    }
  }

  Future<Map<String, String>> _prepareInvitationData(
      String currentUserId) async {
    String senderName = await _getUserName(currentUserId);
    String senderPhotoUrl = await _getUserPhotoUrl(currentUserId);
    String senderCity = await _getUserCity(currentUserId);
    int senderAge = await _getUserAge(currentUserId);

    return {
      'senderName': senderName,
      'senderPhotoUrl': senderPhotoUrl,
      'senderAge': senderAge.toString(),
      'senderCity': senderCity,
    };
  }

  Future<http.Response> _sendInvitation(Map<String, String> invitationData,
      String recipientUserId, String currentUserId) {
    return http.post(
      Uri.parse('https://lesmind.com/api/friends/invitations.php'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'action': 'send_invitation',
        'userId': recipientUserId,
        'senderId': currentUserId,
        ...invitationData, // Rozpakowuje mapę z danymi zaproszenia
      },
    );
  }

  Future<void> updateFriendRequestCount(String currentUserId) async {
    final responseCountInvitations = await http.get(
      Uri.parse(
          'https://lesmind.com/api/users/$currentUserId/send_invitation.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (responseCountInvitations.statusCode == 200) {
      setState(() {
        friendRequestCount = jsonDecode(responseCountInvitations.body)['count'];
      });
    } else {
      throw Exception('Failed to count invitations');
    }
  }

  buildPostView() {
    return buildGridPost();
  }

  Widget buildGridPost() {
    return FutureBuilder<List<PostModel>>(
      future: fetchUserPosts(widget.profileId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Możesz dodać własny widget ładowania
        } else if (snapshot.hasError) {
          //print('Error in FutureBuilder: ${snapshot.error}'); // Dodano
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          //print('No posts available'); // Dodano
          return Text(
              'No posts available'); // Możesz dodać odpowiedni widget, jeśli brak postów
        } else {
          //print('Displaying ${snapshot.data!.length} posts'); // Dodano
          return ListView.builder(
            // Zmienione na ListView
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            physics: NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              PostModel post = snapshot.data![index];
              return PostTile(post: post, profileId: widget.profileId);
            },
          );
        }
      },
    );
  }

  Future<List<PostModel>> fetchUserPosts(String userId) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://lesmind.com/api/posts/get_user_posts.php'), // Poprawiony URL
        body: jsonEncode({'userId': userId}), // Użyj POST z userId w ciele
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          // Dodaj tutaj nagłówki autoryzacyjne lub inne potrzebne
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<PostModel> posts =
            data.map((item) => PostModel.fromJson(item)).toList();
        return posts;
      } else {
        throw Exception('Failed to fetch user posts: ${response.body}');
      }
    } catch (e) {
      //print('Error fetching user posts: $e');
      throw Exception('Failed to fetch user posts');
    }
  }

  Widget buildLikeButton(String userId) {
    return FutureBuilder<bool>(
      future: checkIfLiked(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Możesz dodać własny widget ładowania
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          bool isLiked = snapshot.data ?? false;
          return GestureDetector(
            onTap: () {
              if (!isLiked) {
                addLike();
              } else {
                removeLike();
              }
            },
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 3.0,
                    blurRadius: 5.0,
                  )
                ],
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: EdgeInsets.all(3.0),
                child: Icon(
                  isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                  color: Colors.red,
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Future<bool> checkIfLiked(String userId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://lesmind.com/api/${widget.profileId}/posts/${currentUserId()}/liked'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          // Dodaj tutaj nagłówki autoryzacyjne lub inne potrzebne
        },
      );

      if (response.statusCode == 200) {
        bool isLiked = jsonDecode(response.body)['isLiked'];
        return isLiked;
      } else {
        throw Exception('Failed to check if post is liked');
      }
    } catch (e) {
      //print('?: $e');
      throw Exception('0 <3');
    }
  }

  Future<void> addLike() async {
    try {
      final response = await http.post(
        Uri.parse('https://lesmind.com/api/likes/like_post.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          // Dodaj tutaj nagłówki autoryzacyjne lub inne potrzebne
        },
        body: jsonEncode(<String, dynamic>{
          'dateCreated': DateTime.now(),
        }),
      );

      if (response.statusCode == 200) {
        //print('Post liked successfully');
        setState(() {
          // Możesz dodać odpowiednie zmiany stanu aplikacji po udanej operacji polubienia
        });
      } else {
        throw Exception('Failed to like post');
      }
    } catch (e) {
      //print('Error liking post: $e');
      // Obsłuż błąd w razie wystąpienia
    }
  }

  Future<void> removeLike() async {
    try {
      final response = await http.delete(
        Uri.parse('https://your-backend-url.com/api/users/liked'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          // Dodaj tutaj nagłówki autoryzacyjne lub inne potrzebne
        },
      );

      if (response.statusCode == 200) {
        //print('Post unliked successfully');
        setState(() {
          // Możesz dodać odpowiednie zmiany stanu aplikacji po udanej operacji usunięcia polubienia
        });
      } else {
        throw Exception('Failed to unlike post');
      }
    } catch (e) {
      //print('Error unliking post: $e');
      // Obsłuż błąd w razie wystąpienia
    }
  }

  Color _calculateBorderColor(double filledPercent) {
    if (filledPercent <= 25) {
      return Colors.red;
    } else if (filledPercent <= 50) {
      return Colors.orange;
    } else if (filledPercent <= 75) {
      return Colors.yellow;
    } else {
      return Colors.green;
    }
  }

  void _showIncompleteProfileDialog(
      BuildContext context, UserModel user, double percent) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          // Kolor tła alert dialogu
          shape: RoundedRectangleBorder(
            // Zaokrąglone kontury
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Row(
            // Wiersz zawierający ikonę i tekst tytułu
            children: [
              Icon(
                Icons.star, // Ikona gwiazdy
                color: Colors.yellow, // Kolor ikony
              ),
              SizedBox(width: 8), // Odstęp między ikoną a tekstem
              Text(
                'Wypełnij swój profil',
                style: TextStyle(color: Colors.white), // Kolor tytułu
              ),
            ],
          ),
          content: Text(
            'Masz wypełnione ${percent.toStringAsFixed(0)}% profilu. Wypełnij swój profil, aby łatwiej było Ci znaleźć wymarzoną kobietę.',
            style: TextStyle(color: Colors.white), // Kolor treści
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Zamknij dialog
              },
              child: Text(
                'Zamknij',
                style: TextStyle(color: Colors.white), // Kolor tekstu przycisku
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Zamknij dialog
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (_) =>
                        MoreAbout(user: user), // Przejdź do strony MoreAbout
                  ),
                );
              },
              child: Text(
                'Pokaż mi',
                style: TextStyle(color: Colors.white), // Kolor tekstu przycisku
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildFriendsListButton({
    required String? text,
    required Function()? function,
  }) {
    return FutureBuilder<UserModel?>(
      future: currentUserId(), // Pobieranie aktualnie zalogowanego użytkownika
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Wystąpił błąd: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('Brak danych o zalogowanym użytkowniku'));
        }

        bool isMe = widget.profileId == snapshot.data!.id;

        // Jeśli przeglądasz inny profil, nie wyświetlaj przycisku listy znajomych
        if (!isMe) {
          return SizedBox
              .shrink(); // Zwrócenie pustego widgetu, aby nie wyświetlać przycisku
        }

        return GestureDetector(
          onTap: function!,
          child: Container(
            height: 40,
            width: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Theme.of(context).colorScheme.secondary,
                  Color(0xff597FDB),
                ],
              ),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    text!,
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  handleDisplayFriendsListInvitations() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FriendsListPage(userId: widget.profileId),
      ),
    );
  }

  void _loadNotificationCount() async {
    int count = await _getNotificationCount();
    setState(() {
      notificationCount = count;
    });
  }

  void _loadFriendRequestCount(String userId) async {
    int count = await apiService.getFriendRequestCount(userId);
    setState(() {
      friendRequestCount = count;
    });
  }

  Future<int> _getNotificationCount() async {
    String baseUrl = 'https://lesmind.com';
    var url = '$baseUrl/get_notification_count.php';
    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': ''}),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        return responseData['count'] ?? 0;
      } else {
        throw Exception('Failed to load notification count');
      }
    } catch (e) {
      //print('Error fetching notification count: $e');
      return 0;
    }
  }

  void checkForFriendRequests(String userId) async {
    try {
      // Sprawdź, czy użytkownik ma oczekujące zaproszenia do znajomych
      bool hasFriendRequests = await apiService.checkForFriendRequests(userId);

      if (hasFriendRequests) {
        // Jeśli użytkownik ma oczekujące zaproszenia, nawiguj do FriendRequestsPage
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  FriendRequestsPage(userId: widget.profileId),
            ));
      }
    } catch (e) {
      //print("Error checking for friend requests: $e");
    }
  }

  Future<void> getFriendRequestsCount(String userId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://your-backend-url.com/api/users/$userId/friendRequests'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        // Przyjmujemy, że backend zwraca listę zaproszeń do znajomych
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          friendRequestCount = data.length;
        });
      } else {
        throw Exception('Failed to get friend requests count');
      }
    } catch (e) {
      //print('Error fetching friend requests: $e');
      // Obsłuż błąd w razie wystąpienia
    }
  }

  showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
