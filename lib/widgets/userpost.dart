// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:ionicons/ionicons.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:like_button/like_button.dart';
// import 'package:les_social/models/post.dart';
// import 'package:les_social/models/user.dart';
// import 'package:les_social/screens/comment.dart';
// import 'package:les_social/screens/view_image.dart';
// import 'package:les_social/services/post_service.dart';
// import 'package:http/http.dart' as http;
// import 'package:timeago/timeago.dart' as timeago;
// import '../components/custom_card.dart';
//
// class UserPost extends StatelessWidget {
//   final PostModel? post;
//   final PostService postService = PostService(); // Service to interact with your backend API
//
//   UserPost({this.post});
//
//   final String baseUrl = 'https://lesmind.com/api'; // Replace with your backend API base URL
//
//   Future<UserModel> fetchUser(String userId) async {
//     final response = await http.get(Uri.parse('$baseUrl/users/$userId'));
//
//     if (response.statusCode == 200) {
//       return UserModel.fromJson(jsonDecode(response.body));
//     } else {
//       throw Exception('Failed to load user');
//     }
//   }
//
//   Future<int> fetchLikesCount(String id) async {
//     final response = await http.get(Uri.parse('$baseUrl/posts/$id/likes'));
//
//     if (response.statusCode == 200) {
//       return jsonDecode(response.body).length;
//     } else {
//       throw Exception('Failed to load likes');
//     }
//   }
//
//   Future<int> fetchCommentsCount(String id) async {
//     final response = await http.get(Uri.parse('$baseUrl/posts/$id/comments'));
//
//     if (response.statusCode == 200) {
//       return jsonDecode(response.body).length;
//     } else {
//       throw Exception('Failed to load comments');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return CustomCard(
//       onTap: () {},
//       borderRadius: BorderRadius.circular(10.0),
//       child: GestureDetector(
//         onTap: () {
//           Navigator.of(context).push(
//             MaterialPageRoute(builder: (_) => ViewImage(post: post)),
//           );
//         },
//         child: Column(
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(10.0),
//                 topRight: Radius.circular(10.0),
//               ),
//               child: CachedNetworkImage(
//                 imageUrl: post?.mediaUrl ?? '',
//                 height: 350.0,
//                 fit: BoxFit.cover,
//                 placeholder: (context, url) => Center(child: CircularProgressIndicator()),
//                 errorWidget: (context, url, error) => Icon(Icons.error),
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 3.0, vertical: 5.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       buildLikeButton(),
//                       SizedBox(width: 5.0),
//                       InkWell(
//                         borderRadius: BorderRadius.circular(10.0),
//                         onTap: () {
//                           Navigator.of(context).push(
//                             MaterialPageRoute(builder: (_) => Comments(post: post)),
//                           );
//                         },
//                         child: Icon(
//                           Icons.chat_bubble_outline,
//                           size: 25.0,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 5.0),
//                   Row(
//                     children: [
//                       FutureBuilder<int>(
//                         future: fetchLikesCount(post!.id!),
//                         builder: (context, snapshot) {
//                           if (snapshot.hasData) {
//                             return buildLikesCount(context, snapshot.data!);
//                           } else if (snapshot.hasError) {
//                             return buildLikesCount(context, 0);
//                           }
//                           return buildLikesCount(context, 0); // Handle loading state if needed
//                         },
//                       ),
//                       SizedBox(width: 5.0),
//                       FutureBuilder<int>(
//                         future: fetchCommentsCount(post!.id!),
//                         builder: (context, snapshot) {
//                           if (snapshot.hasData) {
//                             return buildCommentsCount(context, snapshot.data!);
//                           } else if (snapshot.hasError) {
//                             return buildCommentsCount(context, 0);
//                           }
//                           return buildCommentsCount(context, 0); // Handle loading state if needed
//                         },
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 5.0),
//                   Visibility(
//                     visible: post!.description != null && post!.description!.isNotEmpty,
//                     child: Text(
//                       '${post?.description ?? ""}',
//                       style: TextStyle(
//                         fontSize: 15.0,
//                         color: Colors.black,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   SizedBox(height: 5.0),
//                   Text(
//                     timeago.format(post!.time!, locale: 'pl'),
//                     style: TextStyle(
//                       fontSize: 10.0,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget buildLikeButton() {
//     if (post == null || post!.id == null) {
//       return Container(); // Zwróć pusty kontener, jeśli post lub id jest null
//     }
//
//     return FutureBuilder<bool>(
//       future: postService.checkIfLiked(post!.id!),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return CircularProgressIndicator(); // Obsługa stanu ładowania
//         } else if (snapshot.hasError) {
//           return Text('Error: ${snapshot.error}'); // Obsługa stanu błędu
//         } else if (snapshot.hasData) {
//           bool isLiked = snapshot.data!;
//           return LikeButton(
//             isLiked: isLiked,
//             size: 25.0,
//             circleColor: CircleColor(start: Color(0xffFFC0CB), end: Color(0xffff0000)),
//             bubblesColor: BubblesColor(
//               dotPrimaryColor: Color(0xffFFA500),
//               dotSecondaryColor: Color(0xffd8392b),
//               dotThirdColor: Color(0xffFF69B4),
//               dotLastColor: Color(0xffff8c00),
//             ),
//             likeBuilder: (bool isLiked) {
//               return Icon(
//                 isLiked ? Ionicons.heart : Ionicons.heart_outline,
//                 color: isLiked ? Colors.red : Colors.black,
//                 size: 25,
//               );
//             },
//             onTap: (bool isLiked) async {
//               try {
//                 if (!isLiked) {
//                   await postService.likePost(post!.id!);
//                 } else {
//                   await postService.unlikePost(post!.id!);
//                 }
//                 return !isLiked;
//               } catch (e) {
//                 //print('Error tapping like button: $e');
//                 return isLiked; // Revert like button state on error
//               }
//             },
//           );
//         } else {
//           return Container(); // Obsługa innych przypadków
//         }
//       },
//     );
//   }
//
//
//
//   Widget buildLikesCount(BuildContext context, int count) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 7.0),
//       child: Text(
//         '$count ${count == 1 ? 'like' : 'likes'}',
//         style: TextStyle(
//           fontWeight: FontWeight.bold,
//           fontSize: 10.0,
//         ),
//       ),
//     );
//   }
//
//   Widget buildCommentsCount(BuildContext context, int count) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 7.0),
//       child: Text(
//         '$count ${count == 1 ? 'comment' : 'comments'}',
//         style: TextStyle(
//           fontWeight: FontWeight.bold,
//           fontSize: 10.0,
//         ),
//       ),
//     );
//   }
// }
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:like_button/like_button.dart';
import 'package:les_social/models/post.dart';
import 'package:les_social/models/user.dart';
import 'package:les_social/screens/comment.dart';
import 'package:les_social/screens/view_image.dart';
import 'package:les_social/services/post_service.dart';
import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;
import '../components/custom_card.dart';
import '../services/auth_service.dart';

class UserPost extends StatefulWidget {
  final PostModel? post;

  UserPost({this.post});

  @override
  State<UserPost> createState() => _UserPostState();
}

class _UserPostState extends State<UserPost> {
  final PostService postService = PostService();
  final String baseUrl = 'https://lesmind.com/api';
 // Twój backend API base URL
  AuthService _authService = AuthService();

  String? _currentUserId;
 // Zmienna do przechowywania ID aktualnie zalogowanego użytkownika
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

  Future<UserModel> fetchUser(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$userId'));

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<int> fetchLikesCount(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/posts/$id/likes'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body).length;
    } else {
      throw Exception('Failed to load likes');
    }
  }

  Future<int> fetchCommentsCount(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/posts/$id/comments'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body).length;
    } else {
      throw Exception('Failed to load comments');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: () {},
      borderRadius: BorderRadius.circular(10.0),
      child: GestureDetector(
        onTap: () {
          if (widget.post != null && widget.post!.mediaUrl != null) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ViewImage(post: widget.post, profileId: '',)),
            );
          } else {
            //print("Error: Post or mediaUrl is null");
          }
        },
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
              child: CachedNetworkImage(
                imageUrl: widget.post?.mediaUrl ?? '',
                height: 350.0,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.0, vertical: 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      buildLikeButton(),
                      SizedBox(width: 5.0),
                      InkWell(
                        borderRadius: BorderRadius.circular(10.0),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => Comments(post: widget.post)),
                          );
                        },
                        child: Icon(
                          Icons.chat_bubble_outline,
                          size: 25.0,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.0),
                  Row(
                    children: [
                      FutureBuilder<int>(
                        future: fetchLikesCount(widget.post!.id! as String),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return buildLikesCount(context, snapshot.data!);
                          } else if (snapshot.hasError) {
                            return buildLikesCount(context, 0);
                          }
                          return buildLikesCount(context, 0); // Handle loading state if needed
                        },
                      ),
                      SizedBox(width: 5.0),
                      FutureBuilder<int>(
                        future: fetchCommentsCount(widget.post!.id! as String),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return buildCommentsCount(context, snapshot.data!);
                          } else if (snapshot.hasError) {
                            return buildCommentsCount(context, 0);
                          }
                          return buildCommentsCount(context, 0); // Handle loading state if needed
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 5.0),
                  Visibility(
                    visible: widget.post!.description != null && widget.post!.description!.isNotEmpty,
                    child: Text(
                      '${widget.post?.description ?? ""}',
                      style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    timeago.format(widget.post!.createdAt!, locale: 'pl'),
                    style: TextStyle(
                      fontSize: 10.0,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLikeButton() {
    if (widget.post == null || widget.post!.id == null) {
      return Container(); // Zwróć pusty kontener, jeśli post lub id jest null
    }

    return FutureBuilder<bool>(
      future: postService.checkIfLiked(widget.post!.id! as String),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Obsługa stanu ładowania
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // Obsługa stanu błędu
        } else if (snapshot.hasData) {
          bool isLiked = snapshot.data!;
          return LikeButton(
            isLiked: isLiked,
            size: 25.0,
            circleColor: CircleColor(start: Color(0xffFFC0CB), end: Color(0xffff0000)),
            bubblesColor: BubblesColor(
              dotPrimaryColor: Color(0xffFFA500),
              dotSecondaryColor: Color(0xffd8392b),
              dotThirdColor: Color(0xffFF69B4),
              dotLastColor: Color(0xffff8c00),
            ),
            likeBuilder: (bool isLiked) {
              return Icon(
                isLiked ? Ionicons.heart : Ionicons.heart_outline,
                color: isLiked ? Colors.red : Colors.black,
                size: 25,
              );
            },
            onTap: (bool isLiked) async {
              try {
                if (!isLiked) {
                  await postService.likePost(widget.post!.id! as String);
                } else {
                  await postService.unlikePost(widget.post!.id! as String);
                }
                return !isLiked;
              } catch (e) {
                //print('Error tapping like button: $e');
                return isLiked; // Revert like button state on error
              }
            },
          );
        } else {
          return Container(); // Obsługa innych przypadków
        }
      },
    );
  }

  Widget buildLikesCount(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.only(left: 7.0),
      child: Text(
        '$count ${count == 1 ? 'like' : 'likes'}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 10.0,
        ),
      ),
    );
  }

  Widget buildCommentsCount(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.only(left: 7.0),
      child: Text(
        '$count ${count == 1 ? 'comment' : 'comments'}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 10.0,
        ),
      ),
    );
  }
}



