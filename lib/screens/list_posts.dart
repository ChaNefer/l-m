import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:les_social/models/post.dart';
import 'package:les_social/models/comments.dart';
import 'package:les_social/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:like_button/like_button.dart';
import 'dart:convert';
import '../models/user.dart';
import 'comment.dart'; // Upewnij się, że masz klasę do obsługi komentarzy

class ListPosts extends StatefulWidget {
  final String userId;
  final String username;
  final PostModel? postId;

  const ListPosts({Key? key, required this.userId, required this.username, this.postId})
      : super(key: key);

  @override
  State<ListPosts> createState() => _ListPostsState();
}

class _ListPostsState extends State<ListPosts> {
  final _authService = AuthService();
  late PostModel? post;
  bool isLiked = false;
  int likeCount = 0;

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

  Future<int> fetchCommentCount(String postId) async {
    final response = await http.get(
      Uri.parse(
          'https://lesmind.com/api/comments/get_comment_count.php?postId=$postId'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['comment_count'];
    } else {
      throw Exception('Failed to load comment count');
    }
  }

  Future<int> getLikesCount(String postId) async {
    final response = await http.get(
      Uri.parse(
          'https://lesmind.com/api/likes/get_likes_count.php?postId=$postId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return int.parse(data['likesCount']); // Przekonwertuj likesCount na int
    } else {
      throw Exception('Failed to load likes count');
    }
  }


  @override
  void initState() {
    super.initState();
    post = PostModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(Ionicons.chevron_back),
        ),
        title: Column(
          children: [
            Text(widget.username.toUpperCase(),
                style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey)),
            Text('Posty',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: FutureBuilder<List<PostModel>>(
          future: fetchUserPosts(widget.userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Wystąpił błąd: ${snapshot.error}'));
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final post = snapshot.data![index];
                  return buildPostCard(post);
                },
              );
            } else {
              return Center(child: Text('Brak postów'));
            }
          },
        ),
      ),
    );
  }

  // Widget buildPostCard(PostModel post) {
  //   return Container(
  //     margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
  //     child: AspectRatio(
  //       aspectRatio: 4 / 3,
  //       child: Card(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(10.0),
  //         ),
  //         elevation: 5,
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.stretch,
  //           children: [
  //             Expanded(
  //               child: ClipRRect(
  //                 borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
  //                 child: post.mediaUrl!.isNotEmpty
  //                     ? Image.network(post.mediaUrl!, fit: BoxFit.cover)
  //                     : Container(color: Colors.grey),
  //               ),
  //             ),
  //             Padding(
  //               padding: const EdgeInsets.all(8.0),
  //               child: Text(post.description ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
  //                   style: TextStyle(fontSize: 14.0, color: Colors.black87, fontWeight: FontWeight.bold)),
  //             ),
  //             Padding(
  //               padding: const EdgeInsets.all(10.0),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   // Lajki
  //                   buildLikeButton(post.postId!), // Drukowanie ID posta
  //                   GestureDetector(
  //                     onTap: () {
  //                       // Drukowanie wartości przed nawigacją
  //                       //print("Kliknięto w komentarze dla postId: ${post.postId}");
  //                       //print("Opis posta: ${post.description}");
  //                       //print("Media URL: ${post.mediaUrl}");
  //                       //print("Username: ${post.username}");
  //                       //print("CreatedAt: ${post.createdAt}");
  //
  //                       // Sprawdzenie, czy nie ma nulli
  //                       if (post.postId != null && post.username != null) {
  //                         Navigator.push(
  //                           context,
  //                           MaterialPageRoute(
  //                             builder: (context) => Comments(
  //                               post: PostModel(
  //                                 postId: post.postId ?? '',  // Domyślna wartość jeśli null
  //                                 description: post.description ?? '',  // Domyślna wartość jeśli null
  //                                 mediaUrl: post.mediaUrl ?? '',  // Domyślna wartość jeśli null
  //                                 username: post.username ?? '',  // Domyślna wartość jeśli null
  //                                 createdAt: post.createdAt ?? DateTime.now(),  // Domyślna wartość dla createdAt
  //                               ),
  //                             ),
  //                           ),
  //                         );
  //                       } else {
  //                         // Jeśli wartości są null, drukujemy odpowiednią informację
  //                         //print("Błąd: postId lub username jest null.");
  //                       }
  //                     },
  //                     child: Row(
  //                       children: [
  //                         Icon(Ionicons.chatbubble_outline, size: 25),
  //                         SizedBox(width: 5),
  //                         Text('Komentarze'),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget buildPostCard(PostModel post) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(10.0)),
                  child: post.mediaUrl!.isNotEmpty
                      ? Image.network(post.mediaUrl!, fit: BoxFit.cover)
                      : Container(color: Colors.grey),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  post.description ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Lajki
                    buildLikeButton(widget.userId, post.postId!), // Drukowanie ID posta
                    GestureDetector(
                      onTap: () {
                        //print("Kliknięto w komentarze dla postId: ${post.postId}");
                        //print("Opis posta: ${post.description}");
                        //print("Media URL: ${post.mediaUrl}");
                        //print("Username: ${post.username}");
                        //print("CreatedAt: ${post.createdAt}");
                        if (post.postId != null && post.username != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Comments(
                                post: PostModel(
                                  postId: post.postId ?? '',
                                  description: post.description ?? '',
                                  mediaUrl: post.mediaUrl ?? '',
                                  username: post.username ?? '',
                                  createdAt: post.createdAt ?? DateTime.now(),
                                ),
                              ),
                            ),
                          );
                        } else {
                          //print("Błąd: postId lub username jest null.");
                        }
                      },
                      child: Row(
                        children: [
                          Icon(Ionicons.chatbubble_outline, size: 25),
                          SizedBox(width: 5),
                          FutureBuilder<int>(
                            future: fetchCommentCount(
                                post.postId!), // Fetch comment count
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Text(
                                    '...'); // Może być jakiś wskaźnik ładowania
                              } else if (snapshot.hasError) {
                                return Text('0'); // W przypadku błędu
                              } else {
                                final commentCount = snapshot.data ?? 0;
                                return Text(
                                  commentCount == 1
                                      ? '$commentCount '
                                      : '$commentCount ',
                                );
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
      ),
    );
  }

  Future<List<PostModel>> fetchUserPosts(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('https://lesmind.com/api/posts/get_user_posts.php'),
        body: jsonEncode({'userId': userId}),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
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
      throw Exception('Failed to fetch user posts');
    }
  }

  Widget buildLikeButton(String userId, String postId) {
    bool _isAnimating = false;
    int _likeCount = likeCount;
    bool isLiked = false;

    Future<bool> onLikeButtonTapped(bool currentIsLiked) async {
      _isAnimating = true; // Rozpocznij animację
      await Future.delayed(Duration(milliseconds: 150)); // Opcjonalne opóźnienie dla efektu
      if (!currentIsLiked) {
        await addLike(postId, userId);
        _likeCount++;
        isLiked = true;
      } else {
        await removeLike(postId, userId);
        _likeCount--;
        isLiked = false;
      }
      _isAnimating = false; // Zakończ animację
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
                  scale: _isAnimating ? 1.5 : 1.0, // Zwiększ skalę podczas animacji
                  duration: Duration(milliseconds: 150), // Czas trwania animacji
                  child: AnimatedOpacity(
                    opacity: _isAnimating ? 0.5 : 1.0, // Zmiana przezroczystości
                    duration: Duration(milliseconds: 150), // Czas trwania animacji przezroczystości
                    child: LikeButton(
                      isLiked: isLiked,
                      onTap: (liked) async {
                        setState(() {
                          _isAnimating = true; // Rozpocznij animację przed przyciskiem
                        });
                        bool newLikedState = await onLikeButtonTapped(liked);
                        setState(() {
                          _isAnimating = false; // Zakończ animację po akcji
                        }); // Odświeżanie tylko tego widgetu
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

  Future<void> addLike(String postId, String userId) async {
    try {
      // Pobierz ID aktualnie zalogowanego użytkownika
      final UserModel? currentUser = await _authService.getCurrentUser();

      // Sprawdzenie, czy użytkownik jest zalogowany
      if (currentUser == null || currentUser.id == null) {
        //print('Błąd: Użytkownik nie jest zalogowany lub ID użytkownika jest puste.');
        return; // Możesz również rzucić wyjątek lub obsłużyć to w inny sposób
      }

      // Użycie ID użytkownika z modelu
      final String? currentUserId = currentUser.id;

      // Przygotowanie danych do wysłania
      final Map<String, dynamic> requestData = {
        "postId": postId,
        "userId": currentUserId,
        // "timestamp": DateTime.now().toIso8601String(), // Opcjonalnie dodaj timestamp, jeśli potrzebujesz
      };

      //print('Dodawanie lajka z następującymi danymi:');
      //print('ID posta: $postId');
      //print('ID użytkownika: $currentUserId');

      // Wykonaj zapytanie POST do API
      var response = await http.post(
        Uri.parse('https://lesmind.com/api/likes/like_post.php'),
        body: jsonEncode(requestData),
        headers: {"Content-Type": "application/json"},
      );

      // Logowanie statusu odpowiedzi
      //print('Status odpowiedzi: ${response.statusCode}');
      //print('Treść odpowiedzi: ${response.body}');

      // Sprawdź, czy odpowiedź jest poprawna (200 lub 201)
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Sukces – odpowiedź wskazuje, że lajk został dodany
        //print('Lajk dodany pomyślnie!');
      } else {
        // Obsługa błędu – logowanie i rzucanie wyjątku
        //print('Nie udało się dodać lajka. Kod statusu: ${response.statusCode}');
        //print('Treść odpowiedzi: ${response.body}');

        // Dodatkowe sprawdzenia kodu odpowiedzi
        if (response.statusCode == 404) {
          //print('Błąd 404: Post nie został znaleziony. Proszę zweryfikować ID posta: $postId.');
        } else if (response.statusCode == 400) {
          //print('Błąd 400: Zły wniosek. Sprawdź format i dane wniosku.');
        } else if (response.statusCode == 500) {
          //print('Błąd 500: Błąd serwera. Może być problem z serwerem.');
        }

        throw Exception('Nie udało się dodać lajka: ${response.body}');
      }
    } catch (e) {
      //print('Błąd podczas dodawania lajka: $e');
      rethrow;
    }
  }

  Future<void> removeLike(String postId, String userId) async {
    try {
      //print("Removing like for postId: $postId, userId: $userId");
      final response = await http.post(
        Uri.parse('https://lesmind.com/api/likes/unlike_post.php'),
        body: jsonEncode({'postId': postId, 'userId': userId}), // Upewnij się, że używasz poprawnych danych
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
