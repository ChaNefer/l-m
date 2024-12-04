import 'dart:convert';
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:les_social/services/auth_service.dart';
import 'package:like_button/like_button.dart';
import 'package:les_social/models/post.dart'; // Przykładowy model PostModel
import 'package:les_social/models/user.dart'; // Przykładowy model UserModel
import '../auth/login/login.dart';
import '../widgets/cached_image.dart';
import 'comment.dart'; // Biblioteka do formatowania czasu

class ViewImage extends StatefulWidget {
  final PostModel? post;
  final String profileId;

  ViewImage({this.post, required this.profileId});

  @override
  _ViewImageState createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> {
  final DateTime timestamp = DateTime.now();
  final _authService = AuthService();
  bool isLiked = false;
  int likeCount = 0;
  bool isExpanded = false;

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

  UserModel? user;

  // @override
  // Widget build(BuildContext context) {
  //   // Sprawdzamy, czy post istnieje
  //   if (widget.post == null) {
  //     return Scaffold(
  //       appBar: AppBar(),
  //       body: Center(
  //         child: Text('Post not available'),
  //       ),
  //     );
  //   }
  //   return Scaffold(
  //       appBar: AppBar(
  //         title: Image.asset(
  //           'assets/images/lesmind.png',
  //           height: 60.0,
  //           width: 170.0,
  //           fit: BoxFit.scaleDown,
  //         ),
  //         actions: [
  //           IconButton(
  //             onPressed: () async {
  //               // Najpierw wykonaj logout
  //               await _authService.logout();
  //               Navigator.of(context).pushAndRemoveUntil(
  //                 CupertinoPageRoute(builder: (_) => Login()),
  //                 (Route<dynamic> route) => false,
  //               );
  //             },
  //             icon: Icon(Ionicons.power_outline),
  //           )
  //         ],
  //       ),
  //       body: Column(children: [
  //         // Username nad zdjęciem
  //         Padding(
  //           padding: const EdgeInsets.all(10.0),
  //           child: Row(
  //             children: [
  //               Text(
  //                 widget.post!.username ?? 'Unknown',
  //                 style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
  //               ),
  //             ],
  //           ),
  //         ),
  //
  //         // Zdjęcie postu
  //         // Expanded(
  //         //   child: buildImage(context),
  //         // ),
  //         Container(
  //           margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
  //           child: AspectRatio(
  //             aspectRatio: 4 / 3, // Stosunek szerokości do wysokości (np. 4:3)
  //             child: Card(
  //               shape: RoundedRectangleBorder(
  //                 borderRadius:
  //                     BorderRadius.circular(10.0), // Zaokrąglenie rogów
  //               ),
  //               elevation: 5,
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.stretch,
  //                 children: [
  //                   Expanded(
  //                     child: ClipRRect(
  //                       borderRadius: BorderRadius.vertical(
  //                         top: Radius.circular(
  //                             10.0), // Zaokrąglenie górnych rogów obrazka
  //                       ),
  //                       child: cachedNetworkImage(widget.post!.mediaUrl!),
  //                     ),
  //                   ),
  //                   Padding(
  //                     padding: const EdgeInsets.all(8.0),
  //                     child: Text.rich(
  //                       TextSpan(
  //                         text: isExpanded
  //                             ? widget.post!.description // Pełny tekst
  //                             : (widget.post!.description != null &&
  //                             widget.post!.description!.length > 100
  //                             ? widget.post!.description!.substring(0, 100) + '...'
  //                             : widget.post!.description ?? 'No description'),
  //                         children: [
  //                           if (widget.post!.description != null &&
  //                               widget.post!.description!.length > 100)
  //                             TextSpan(
  //                               text: isExpanded ? ' Zwiń' : ' Czytaj dalej...',
  //                               style: TextStyle(color: Colors.blue),
  //                               recognizer: TapGestureRecognizer()
  //                                 ..onTap = () {
  //                                   setState(() {
  //                                     isExpanded = !isExpanded;
  //                                   });
  //                                 },
  //                             ),
  //                         ],
  //                       ),
  //                       style: TextStyle(
  //                         fontSize: 14.0,
  //                         color: Colors.black87,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                       softWrap: true,
  //                       overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis, // Ustawienie overflow na visible, gdy rozwinięte
  //                       maxLines: isExpanded ? null : 4, // Wyświetl pełen tekst, gdy rozwinięte
  //                     ),
  //                   ),
  //
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //         // Lajki i komentarze pod zdjęciem
  //         Padding(
  //           padding: const EdgeInsets.all(10.0),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               // Lajki
  //               buildLikeButton(widget.profileId, widget.post!.postId!),
  //               // Komentarze
  //               GestureDetector(
  //                 onTap: () {
  //                   // Przenieś do ekranu komentarzy
  //                   Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                       builder: (context) => Comments(
  //                         post: PostModel(
  //                             postId: widget.post!.postId,
  //                             description: widget.post!.description,
  //                             mediaUrl: widget.post!.mediaUrl,
  //                             username: widget.post!.username,
  //                             createdAt: widget.post!.createdAt),
  //                       ),
  //                     ),
  //                   );
  //                 },
  //                 child: Row(
  //                   children: [
  //                     Icon(Ionicons.chatbubble_outline, size: 25),
  //                     SizedBox(width: 5),
  //                     FutureBuilder<int>(
  //                       future: fetchCommentCount(
  //                           widget.post!.postId!), // Fetch comment count
  //                       builder: (context, snapshot) {
  //                         if (snapshot.connectionState ==
  //                             ConnectionState.waiting) {
  //                           return Text(
  //                               '...'); // Może być jakiś wskaźnik ładowania
  //                         } else if (snapshot.hasError) {
  //                           return Text('0'); // W przypadku błędu
  //                         } else {
  //                           final commentCount = snapshot.data ?? 0;
  //                           return Text(
  //                             commentCount == 1
  //                                 ? '$commentCount '
  //                                 : '$commentCount ',
  //                           );
  //                         }
  //                       },
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ]));
  // }

  @override
  Widget build(BuildContext context) {
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
              Navigator.of(context).pushAndRemoveUntil(
                CupertinoPageRoute(builder: (_) => Login()),
                (Route<dynamic> route) => false,
              );
            },
            icon: Icon(Ionicons.power_outline),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Padding(
          //   padding: const EdgeInsets.all(10.0),
          //   child: Row(
          //     children: [
          //       Text(
          //         widget.post!.username ?? 'Unknown',
          //         style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          //       ),
          //     ],
          //   ),
          // ),
          // // Sekcja ze zdjęciem
          // Container(
          //   margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          //   child: AspectRatio(
          //     aspectRatio: 4 / 3,
          //     child: Card(
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(10.0),
          //       ),
          //       elevation: 5,
          //       child: ClipRRect(
          //         borderRadius: BorderRadius.vertical(
          //           top: Radius.circular(10.0),
          //         ),
          //         child: Image.network(
          //           widget.post!.mediaUrl!,
          //           fit: BoxFit.cover,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          //
          // // Sekcja z tekstem
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: AnimatedSize(
          //     duration: Duration(milliseconds: 300),
          //     curve: Curves.easeInOut,
          //     child: Text.rich(
          //       TextSpan(
          //         text: isExpanded
          //             ? widget.post!.description
          //             : (widget.post!.description!.length > 100
          //                 ? widget.post!.description!.substring(0, 100) + '...'
          //                 : widget.post!.description),
          //         children: [
          //           if (widget.post!.description!.length > 100)
          //             TextSpan(
          //               text: isExpanded ? ' Zwiń' : ' Czytaj dalej...',
          //               style: TextStyle(color: Colors.blue),
          //               recognizer: TapGestureRecognizer()
          //                 ..onTap = () {
          //                   setState(() {
          //                     isExpanded = !isExpanded;
          //                   });
          //                 },
          //             ),
          //         ],
          //       ),
          //       style: TextStyle(
          //         fontSize: 14.0,
          //         color: Colors.black87,
          //         fontWeight: FontWeight.bold,
          //       ),
          //       softWrap: true,
          //       overflow:
          //           isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          //       maxLines: isExpanded ? null : 4,
          //     ),
          //   ),
          // ),
      Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.post!.username!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                fontSize: 16,
                color: Colors.blueGrey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              widget.post!.description!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                fontSize: 14,
              ),
            ),
            if (widget.post!.mediaUrl!.isNotEmpty) ...[
              SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(widget.post!.mediaUrl!,
                    fit: BoxFit.cover),
              ),
            ],
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
    )
        ],
      ),
    );
  }

  // Widget buildImage(BuildContext context) {
  //   // Sprawdzamy, czy mediaUrl nie jest null
  //   if (widget.post!.mediaUrl == null) {
  //     return Icon(Icons.error); // Wyświetlamy ikonę błędu, jeśli brak zdjęcia
  //   }
  //   return Card(
  //     margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  //     elevation: 5,
  //     child: Padding(
  //       padding: EdgeInsets.all(12),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             widget.post!.username!,
  //             style: TextStyle(
  //               fontWeight: FontWeight.bold,
  //               fontStyle: FontStyle.italic,
  //               fontSize: 16,
  //               color: Colors.blueGrey,
  //             ),
  //           ),
  //           SizedBox(height: 8),
  //           Text(
  //             widget.post!.description!,
  //             style: TextStyle(
  //               fontWeight: FontWeight.bold,
  //               fontStyle: FontStyle.italic,
  //               fontSize: 14,
  //             ),
  //           ),
  //           if (widget.post!.mediaUrl!.isNotEmpty) ...[
  //             SizedBox(height: 10),
  //             ClipRRect(
  //               borderRadius: BorderRadius.circular(15),
  //               child: Image.network(widget.post!.mediaUrl!, fit: BoxFit.cover),
  //             ),
  //           ],
  //           Padding(
  //             padding: const EdgeInsets.all(10.0),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Expanded(
  //                   child:
  //                       buildLikeButton(widget.profileId, widget.post!.postId!),
  //                 ),
  //                 GestureDetector(
  //                   onTap: () {
  //                     Navigator.push(
  //                       context,
  //                       MaterialPageRoute(
  //                         builder: (context) => Comments(
  //                           post: PostModel(
  //                             isLiked: widget.post!.isLiked,
  //                             likeCount: widget.post!.likeCount,
  //                             postId: widget.post!.postId,
  //                             description: widget.post!.description,
  //                             mediaUrl: widget.post!.mediaUrl,
  //                             username: widget.post!.username,
  //                             createdAt: widget.post!.createdAt,
  //                           ),
  //                         ),
  //                       ),
  //                     );
  //                   },
  //                   child: Row(
  //                     children: [
  //                       Icon(Ionicons.chatbubble_outline, size: 25),
  //                       SizedBox(width: 5),
  //                       FutureBuilder<int>(
  //                         future: fetchCommentCount(widget.post!.postId!),
  //                         builder: (context, snapshot) {
  //                           if (snapshot.connectionState ==
  //                               ConnectionState.waiting) {
  //                             return Text('...');
  //                           } else if (snapshot.hasError) {
  //                             return Text('0');
  //                           } else {
  //                             final commentCount = snapshot.data ?? 0;
  //                             return Text(commentCount == 1
  //                                 ? '$commentCount '
  //                                 : '$commentCount ');
  //                           }
  //                         },
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Future<void> addLikesToNotification() async {
    bool isNotMe = currentUserId() != widget.post!.ownerId;

    if (isNotMe) {
      // Zastąp operacje na powiadomieniach odpowiednimi zapytaniami do Twojego backendu
    }
  }

  Future<void> removeLikeFromNotification() async {
    bool isNotMe = currentUserId() != widget.post!.ownerId;

    if (isNotMe) {
      // Zastąp operacje na powiadomieniach odpowiednimi zapytaniami do Twojego backendu
    }
  }

  Widget buildLikeButton(String userId, String postId) {
    bool _isAnimating = false;
    int _likeCount = likeCount;
    bool isLiked = false;

    Future<bool> onLikeButtonTapped(bool currentIsLiked) async {
      _isAnimating = true; // Rozpocznij animację
      await Future.delayed(
          Duration(milliseconds: 150)); // Opcjonalne opóźnienie dla efektu
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
                  scale: _isAnimating
                      ? 1.5
                      : 1.0, // Zwiększ skalę podczas animacji
                  duration:
                      Duration(milliseconds: 150), // Czas trwania animacji
                  child: AnimatedOpacity(
                    opacity:
                        _isAnimating ? 0.5 : 1.0, // Zmiana przezroczystości
                    duration: Duration(
                        milliseconds:
                            150), // Czas trwania animacji przezroczystości
                    child: LikeButton(
                      isLiked: isLiked,
                      onTap: (liked) async {
                        setState(() {
                          _isAnimating =
                              true; // Rozpocznij animację przed przyciskiem
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

  Future<bool> onLikeButtonTapped(bool isLiked) async {
    if (isLiked) {
      // Usuń like
      await removeLikeFromNotification();
    } else {
      // Dodaj like
      await addLikesToNotification();
    }
    return !isLiked;
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
}
