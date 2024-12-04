import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:ionicons/ionicons.dart';
import 'package:les_social/components/like_button.dart';
import 'package:les_social/models/notification.dart';
import 'package:les_social/models/post.dart';
import 'package:les_social/pages/notification.dart';
import 'package:les_social/pages/profile.dart';
import 'package:les_social/screens/mainscreen.dart';
import 'package:les_social/services/api_service.dart';
import 'package:les_social/services/auth_service.dart';
import 'package:les_social/services/post_service.dart';
import 'package:like_button/like_button.dart';
import '../models/comments.dart';
import '../models/user.dart';
import '../screens/comment.dart';

class Feeds extends StatefulWidget {
  final String profileId;
  final UserModel? user;

  Feeds({required this.profileId, this.user});

  @override
  _FeedsState createState() => _FeedsState();
}

class _FeedsState extends State<Feeds> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int page = 5;
  bool loadingMore = false;
  ScrollController scrollController = ScrollController();
  String? likesJsonString;
  String? commentsJsonString;
  late ApiService apiService;
  late AuthService _authService;
  late PostService _postService;
  bool isLiked = false;
  int likeCount = 0;
  late AnimationController _controller;
  String? username;
  String? userDp;
  String? id;
  // String? postId;
  String? ownerId;
  String? mediaUrl;
  String? commentData;
  DateTime? time;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _postService = PostService();
    // Inicjalizuj AnimationController i Tween
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        setState(() {
          page += 5;
          loadingMore = true;
        });
      }
    });
  }

  @override
  void dispose() {
    scrollController
        .dispose(); // Upewnij się, że kontroler przewijania jest zwolniony
    _controller.dispose(); // Upewnij się, że kontroler jest zwolniony
    super.dispose();
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

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (likesJsonString == null) {
      likesJsonString = await rootBundle.loadString('assets/likes_pl.json');
    }
    if (commentsJsonString == null) {
      commentsJsonString =
          await rootBundle.loadString('assets/comments_pl.json');
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
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
      body: RefreshIndicator(
        color: Theme.of(context).colorScheme.secondary,
        onRefresh: fetchAllPosts,
        child: Column(
          children: [
            SizedBox(height: 20), // Odstęp między logo a tekstem
            Text(
              'Posty użytkowników',
              style: TextStyle(
                fontSize: 21, // Rozmiar tekstu
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10), // Odstęp między tekstem a postami
            Expanded(
              child: FutureBuilder<List<PostModel>>(
                future: fetchAllPosts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text('Wystąpił błąd: ${snapshot.error}'));
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: snapshot.data!.length + (loadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == snapshot.data!.length) {
                          return Center(
                              child:
                                  CircularProgressIndicator()); // Loader na końcu listy
                        }
                        final post = snapshot.data![index];
                        return Card(
                          margin: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          elevation: 5,
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.username!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 16,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  post.description!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 14,
                                  ),
                                ),
                                if (post.mediaUrl!.isNotEmpty) ...[
                                  SizedBox(height: 10),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.network(post.mediaUrl!,
                                        fit: BoxFit.cover),
                                  ),
                                ],
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: buildLikeButton(
                                            widget.profileId, post.postId!),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Comments(
                                                post: PostModel(
                                                  isLiked: post.isLiked,
                                                  likeCount: post.likeCount,
                                                  postId: post.postId,
                                                  description: post.description,
                                                  mediaUrl: post.mediaUrl,
                                                  username: post.username,
                                                  createdAt: post.createdAt,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            Icon(Ionicons.chatbubble_outline,
                                                size: 25),
                                            SizedBox(width: 5),
                                            FutureBuilder<int>(
                                              future: fetchCommentCount(
                                                  post.postId!),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return Text('...');
                                                } else if (snapshot.hasError) {
                                                  return Text('0');
                                                } else {
                                                  final commentCount =
                                                      snapshot.data ?? 0;
                                                  return Text(commentCount == 1
                                                      ? '$commentCount '
                                                      : '$commentCount ');
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(child: Text('Brak postów'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<int> fetchCommentCount(String postId) async {
    final response = await http.get(Uri.parse(
        'https://lesmind.com/api/comments/get_comment_count.php?postId=$postId'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['comment_count'];
    } else {
      throw Exception('Failed to load comment count');
    }
  }

  Future<List<CommentModel>> fetchComments(int postId) async {
    try {
      final response = await http.get(Uri.parse(
          'https://lesmind.com/api/comments/get_comments.php?postId=$postId'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<CommentModel> comments =
            data.map((item) => CommentModel.fromJson(item)).toList();
        return comments;
      } else {
        throw Exception('Failed to fetch comments: ${response.body}');
      }
    } catch (e) {
      //print('Error fetching comments: $e');
      throw Exception('Failed to fetch comments');
    }
  }

  Future<int> getLikesCount(String postId) async {
    final response = await http.get(Uri.parse(
        'https://lesmind.com/api/likes/get_likes_count.php?postId=$postId'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return int.parse(data['likesCount']); // Przekonwertuj likesCount na int
    } else {
      throw Exception('Failed to load likes count');
    }
  }

  Future<void> toggleLike(String userId, String postId) async {
    //print("Toggling like for postId: $postId");
    try {
      final response = await http.post(
        Uri.parse('https://lesmind.com/api/likes/toggle_like.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'postId': postId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to toggle like');
      }
    } on Exception catch (e) {
      //print("Failed to save like: $e");
    }
  }

  Future<List<PostModel>> fetchAllPosts() async {
    try {
      final response = await http
          .get(Uri.parse('https://lesmind.com/api/posts/get_all_posts.php'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<PostModel> posts =
            data.map((item) => PostModel.fromJson(item)).toList();
        return posts;
      } else {
        throw Exception('Failed to fetch all posts: ${response.body}');
      }
    } catch (e) {
      //print('Error fetching all posts: $e');
      throw Exception('Failed to fetch all posts');
    }
  }

  Widget buildLikeButton(String userId, String postId) {
    bool _isAnimating = false;
    int _likeCount = likeCount;
    bool isLiked = false;
    // bool isProcessingLike = false;

    Future<bool> onLikeButtonTapped(bool currentIsLiked) async {
      _isAnimating = true;

      await Future.delayed(Duration(milliseconds: 220));

      if (!currentIsLiked) {
        await addLike(postId, userId);

        ActivityModel activity = ActivityModel(
            type: "like",
            postId: postId,
            username: username,
            userId: userId,
            time: time);

        _likeCount++;
        isLiked = true;

        addLikeToNotification(activity);
      } else {
        await removeLike(postId, userId);
        _likeCount--;
        isLiked = false;
      }
      _isAnimating = false;
      return !currentIsLiked;
    }

    return FutureBuilder<bool>(
      future: checkIfLiked(userId, postId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Icon(Icons.error);
        }
        isLiked = snapshot.data ?? false;
        return StatefulBuilder(
          builder: (context, setState) {
            return Row(
              children: [
                AnimatedScale(
                  scale: _isAnimating ? 1.5 : 1.0,
                  duration: Duration(milliseconds: 150),
                  child: AnimatedOpacity(
                    opacity: _isAnimating ? 0.5 : 1.0,
                    duration: Duration(milliseconds: 150),
                    child: LikeButton(
                      isLiked: isLiked,
                      onTap: (liked) async {
                        setState(() {
                          _isAnimating = true;
                        });
                        bool newLikedState = await onLikeButtonTapped(liked);
                        setState(() {
                          _isAnimating = false;
                        });
                        return newLikedState;
                      },
                      size: 25.0,
                      circleColor: CircleColor(
                        start: Color(0xffFFC0CB),
                        end: Color(0xffff0000),
                      ),
                      bubblesColor: BubblesColor(
                        dotPrimaryColor: Color(0xffFFA500),
                        dotSecondaryColor: Color(0xffd8392b),
                        dotThirdColor: Color(0xffFF69B4),
                        dotLastColor: Color(0xffff8c00),
                      ),
                      likeBuilder: (bool isLiked) {
                        return Icon(
                          isLiked ? Ionicons.heart : Ionicons.heart_outline,
                          color: isLiked ? Colors.red : Colors.grey,
                          size: 25,
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: 8),
                FutureBuilder<int>(
                  future: getLikesCount(postId),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('0');
                    } else {
                      _likeCount = snapshot.data ?? 0;
                      return Text(
                        '$_likeCount',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> addCommentToNotification(
      String type,
      String commentData,
      String username,
      String userId,
      String postId,
      String mediaUrl,
      String ownerId,
      String userDp) async {
    final url =
        'https://lesmind.com/api/notifications/add_comment_to_notification.php'; // Zmień na swój URL

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "type": type,
        "commentData": commentData,
        "username": username,
        "userId": userId,
        "userDp": userDp,
        "postId": postId,
        "mediaUrl": mediaUrl,
        "timestamp":
            DateTime.now().toIso8601String(), // Możesz użyć innego formatu
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add comment to notification');
    }
  }

  Future<void> addLikeToNotification(ActivityModel activity) async {
    // Sprawdzenie czy wymagane dane są dostępne
    if (activity.userId == null ||
        activity.type == null ||
        activity.postId == null) {
      //print('Błąd: Brak wymaganych danych w ActivityModel.');
      //print('Dane ActivityModel: ${activity.toJson()}');
      return;
    }

    final url =
        'https://lesmind.com/api/notifications/add_like_to_notification.php';

    //print('Wysyłanie żądania do: $url');
    //print('Dane do wysłania: ${json.encode({
    //       "type": activity.type,
    //       "userId": activity.userId,
    //       "postId": activity.postId,
    //     })}');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "type": activity.type,
          "userId": activity.userId,
          "postId": activity.postId,
        }),
      );

      //print('Status odpowiedzi: ${response.statusCode}');
      //print('Treść odpowiedzi: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          //print('Lajk dodany pomyślnie do powiadomienia.');
        } else {
          //print('Wystąpił problem: ${responseData['error']}');
        }
      } else {
        //print('Błąd HTTP: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      //print('Błąd przy przetwarzaniu odpowiedzi: $e');
    }
  }

  Future<void> addLike(String postId, String userId) async {
    try {
      // Pobierz ID aktualnie zalogowanego użytkownika
      final UserModel? currentUser = await _authService.getCurrentUser();

      // Sprawdzenie, czy użytkownik jest zalogowany
      if (currentUser == null || currentUser.id == null) {
        return; // Możesz również rzucić wyjątek lub obsłużyć to w inny sposób
      }

      // Przygotowanie danych do wysłania
      final Map<String, dynamic> requestData = {
        "postId": postId,
        "userId": currentUser.id,
      };

      // Wykonaj zapytanie POST do API
      var response = await http.post(
        Uri.parse('https://lesmind.com/api/likes/like_post.php'),
        body: jsonEncode(requestData),
        headers: {"Content-Type": "application/json"},
      );

      // Sprawdź, czy odpowiedź jest poprawna (200 lub 201)
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Sukces – odpowiedź wskazuje, że lajk został dodany

        // Tworzenie obiektu ActivityModel
        ActivityModel activity = ActivityModel(
          userId: currentUser.id,
          postId: postId, // ID posta
          type: 'like', // Typ powiadomienia
          time: DateTime.now(), // Opcjonalny timestamp
        );

        // Dodaj powiadomienie
        await addLikeToNotification(activity);
      } else {
        // Obsługa błędu
        throw Exception('Nie udało się dodać lajka: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> checkIfLiked(String userId, String postId) async {
    //print("Check if post: $postId is liked by user: $userId");
    final response = await http.get(Uri.parse(
        'https://lesmind.com/api/likes/check_if_liked.php?userId=$userId&postId=$postId'));
    //print("Odpowiedź serwera: ${response.body}"); // Logowanie odpowiedzi

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['liked'] as bool;
    } else {
      throw Exception('Failed to check if liked');
    }
  }

  Future<void> removeLike(String postId, String userId) async {
    try {
      //print("Removing like for postId: $postId, userId: $userId");
      final response = await http.post(
        Uri.parse('https://lesmind.com/api/likes/unlike_post.php'),
        body: jsonEncode({
          'postId': postId,
          'userId': userId
        }), // Upewnij się, że używasz poprawnych danych
        headers: {"Content-Type": "application/json"},
      );

      //print("Response status: ${response.statusCode}");
      //print("Response body: ${response.body}"); // Wyświetl ciało odpowiedzi

      if (response.statusCode != 200) {
        throw Exception('Failed to remove like');
      }
    } catch (e) {
      //print('Error removing like: $e');
    }
  }
}
