// // import 'package:flutter/cupertino.dart';
// // import 'package:flutter/material.dart';
// //
// // import '../models/post.dart';
// // import '../screens/view_image.dart';
// // import 'cached_image.dart';
// //
// // class PostTile extends StatefulWidget {
// //   final PostModel? post;
// //
// //   PostTile({this.post});
// //
// //   @override
// //   _PostTileState createState() => _PostTileState();
// // }
// //
// // class _PostTileState extends State<PostTile> {
// //   @override
// //   Widget build(BuildContext context) {
// //     //print("PostTile - mediaUrl: ${widget.post?.mediaUrl}");
// //     if (widget.post == null) {
// //       return SizedBox(); // Zwróć pusty widget lub jakiś placeholder
// //     }
// //
// //     return GestureDetector(
// //       onTap: () {
// //         Navigator.of(context).push(CupertinoPageRoute(
// //           builder: (_) => ViewImage(post: widget.post),
// //         ));
// //       },
// //       child: Container(
// //         height: 150,
// //         width: 150,
// //         child: Card(
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(5.0),
// //           ),
// //           elevation: 5,
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.stretch,
// //             children: [
// //               Expanded(
// //                 child: ClipRRect(
// //                   borderRadius: BorderRadius.vertical(top: Radius.circular(5.0)),
// //                   child: cachedNetworkImage(widget.post!.mediaUrl!), // Teraz to jest bezpieczne
// //                 ),
// //               ),
// //               Padding(
// //                 padding: const EdgeInsets.all(8.0),
// //                 child: Text(
// //                   widget.post!.description ?? '',
// //                   maxLines: 2,
// //                   overflow: TextOverflow.ellipsis,
// //                   style: TextStyle(
// //                     fontSize: 12.0,
// //                     color: Colors.black54,
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// //
// //
// //
// //
// //
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:les_social/services/auth_service.dart';
//
// import '../models/post.dart';
// import '../models/user.dart';
// import '../screens/view_image.dart';
// import 'cached_image.dart';
//
// class PostTile extends StatefulWidget {
//   final PostModel? post;
//
//   PostTile({this.post});
//
//   @override
//   _PostTileState createState() => _PostTileState();
// }
//
// class _PostTileState extends State<PostTile> {
//
//   AuthService _authService = AuthService();
//
//   Future<UserModel?> currentUserId() async {
//     try {
//       var currentUser = await _authService.getCurrentUser();
//       //print("currentUserId: Pobrano ID aktualnie zalogowanego użytkownika - ${currentUser?.id}"); // Debugowanie
//       return currentUser;
//     } catch (e) {
//       //print("currentUserId: Błąd podczas pobierania danych użytkownika - $e"); // Debugowanie
//       return null;
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     //print("PostTile - mediaUrl: ${widget.post?.mediaUrl}");
//
//     if (widget.post == null) {
//       return SizedBox(); // Zwróć pusty widget lub placeholder, gdy post jest null
//     }
//
//     return GestureDetector(
//       onTap: () {
//         Navigator.of(context).push(CupertinoPageRoute(
//           builder: (_) => ViewImage(post: widget.post, profileId: currentUserId()),
//         ));
//       },
//       child: Container(
//         margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
//         child: AspectRatio(
//           aspectRatio: 4 / 3, // Stosunek szerokości do wysokości (np. 4:3)
//           child: Card(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10.0), // Zaokrąglenie rogów
//             ),
//             elevation: 5,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 Expanded(
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.vertical(
//                       top: Radius.circular(10.0), // Zaokrąglenie górnych rogów obrazka
//                     ),
//                     child: cachedNetworkImage(widget.post!.mediaUrl!),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(
//                     widget.post!.description ?? '',
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       fontSize: 14.0,
//                       color: Colors.black87,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
//
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:les_social/services/auth_service.dart';
import 'package:like_button/like_button.dart';

import '../models/post.dart';
import '../models/user.dart';
import '../screens/comment.dart';
import '../screens/view_image.dart';
import 'cached_image.dart';

class PostTile extends StatefulWidget {
  final PostModel? post;
  final String profileId;

  PostTile({this.post, required this.profileId});

  @override
  _PostTileState createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  AuthService _authService = AuthService();
  String? _currentUserId; // Zmienna do przechowywania ID aktualnie zalogowanego użytkownika
  bool isLiked = false;
  int likeCount = 0;

  Future<void> _getCurrentUserId() async {
    try {
      var currentUser = await _authService.getCurrentUser();
      if (currentUser != null) {
        setState(() {
          _currentUserId = currentUser.id; // Ustaw ID aktualnego użytkownika
        });
        //print("currentUserId: Pobrano ID aktualnie zalogowanego użytkownika - $_currentUserId");
      }
    } catch (e) {
      //print("currentUserId: Błąd podczas pobierania danych użytkownika - $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentUserId(); // Wywołanie metody po zainicjowaniu stanu
  }

  @override
  Widget build(BuildContext context) {
    //print("PostTile - mediaUrl: ${widget.post?.mediaUrl}");

    if (widget.post == null) {
      return SizedBox(); // Zwróć pusty widget lub placeholder, gdy post jest null
    }

    return GestureDetector(
      onTap: () {
        if (_currentUserId != null) { // Sprawdź, czy ID użytkownika zostało pobrane
          Navigator.of(context).push(CupertinoPageRoute(
            builder: (_) => ViewImage(
              post: widget.post,
              profileId: _currentUserId!, // Przekaż ID użytkownika
            ),
          ));
        }
      },
      child: Container(
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
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(10.0),
                    ),
                    child: cachedNetworkImage(widget.post!.mediaUrl!),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.post!.description ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: buildLikeButton(
                            widget.profileId, widget.post!.postId!),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Comments(
                                post: PostModel(
                                  isLiked: widget.post!.isLiked,
                                  likeCount: widget.post!.likeCount,
                                  postId: widget.post!.postId,
                                  description: widget.post!.description,
                                  mediaUrl: widget.post!.mediaUrl,
                                  username: widget.post!.username,
                                  createdAt: widget.post!.createdAt,
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
                              future: fetchCommentCount(widget.post!.postId!),
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
        ),
      ),
    );
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

        // Sprawdź, czy wszystkie dane są dostępne przed utworzeniem ActivityModel
        // //print('Tworzenie ActivityModel:');
        // //print('Post ID: $postId');
        // //print('User ID: $userId');
        // //print('Username: ${widget.user!.username}'); // Upewnij się, że username jest dostępny
        // //print('MediaUrl: ${widget.user!.photoUrl}');
        //
        // ActivityModel activity = ActivityModel(
        //     "like",
        //     postId,
        //     widget.user!.username!,
        //     userId,
        //     ownerId,
        //     userDp,
        //     id,
        //     commentData,
        //     widget.user!.photoUrl,
        //     time as DateTime?
        // );
        //
        // //print('Sprawdzanie ActivityModel przed dodawaniem lajka:');
        // //print('Username: ${activity.username}');
        // //print('MediaUrl: ${widget.user!.photoUrl}');
        // //print('Post ID: ${activity.postId}');
        // //print('Dane ActivityModel: $activity'); // Dodaj ten wiersz
        //
        // await addLikeToNotification(activity);
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

  Future<int> getLikesCount(String postId) async {
    final response = await http.get(
        Uri.parse(
            'https://lesmind.com/api/likes/get_likes_count.php?postId=$postId'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return int.parse(data['likesCount']); // Przekonwertuj likesCount na int
    } else {
      throw Exception('Failed to load likes count');
    }
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

}



