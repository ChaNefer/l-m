// // import 'dart:convert';
// // import 'dart:io';
// // import 'package:uuid/uuid.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:les_social/models/user.dart';
// // import 'package:les_social/services/services.dart';
// // import 'package:timeago/timeago.dart' as timeago;
// // import 'package:mime/mime.dart';
// // import 'package:http_parser/http_parser.dart';
// // import '../utils/file_utils.dart';
// // import 'auth_service.dart';
// //
// // class PostService extends Service {
// //   String id = Uuid().v4();
// //   late UserModel user; // Deklaracja pola user
// //   static const String baseUrl = 'https://lesmind.com'; // Wstaw tutaj adres Twojego backendu
// //   final AuthService _authService = AuthService();
// //
// //   Stream<http.Response> getComments(String id) {
// //     // Wykonaj zapytanie HTTP do backendu
// //     var url = Uri.parse('https://lesmind.com/api/posts/$id/comments');
// //     return http.get(url).asStream();
// //   }
// //
// //   // Send comments
// //   Future<void> uploadComment(String currentUserId, String comment, String id, String ownerId, String mediaUrl) async {
// //     final response = await http.post(
// //       Uri.parse('$baseUrl/api/comments/add_comment.php'),
// //       body: jsonEncode({
// //         "userId": currentUserId,
// //         "comment": comment,
// //         "timestamp": DateTime.now().toIso8601String(),
// //         // Możesz dodać inne pola zależnie od Twoich potrzeb
// //       }),
// //       headers: {"Content-Type": "application/json"},
// //     );
// //     if (response.statusCode != 200) {
// //       throw Exception("Failed to upload comment");
// //     }
// //     // Dodawanie komentarza do powiadomień możesz zaimplementować analogicznie do Firebase
// //   }
// //
// //   // Metoda do pobierania liczby polubień dla danego posta
// //   Future<int> getLikesCount(String id) async {
// //     final response = await http.get(Uri.parse('$baseUrl/posts/$id/likes'));
// //     if (response.statusCode == 200) {
// //       // Przykład parsowania odpowiedzi - w Twoim backendzie musisz odpowiednio zaimplementować tę logikę
// //       return int.parse(response.body);
// //     } else {
// //       throw Exception('Failed to load likes count');
// //     }
// //   }
// //
// //   // like/unlike
// //   Future<void> toggleLike(String currentUserId, String id) async {
// //     final response = await http.post(
// //       Uri.parse('$baseUrl/posts/$id/likes'),
// //       body: jsonEncode({
// //         "userId": currentUserId,
// //         "timestamp": DateTime.now().toIso8601String(),
// //       }),
// //       headers: {"Content-Type": "application/json"},
// //     );
// //     if (response.statusCode != 200) {
// //       throw Exception("Failed to toggle like");
// //     }
// //   }
// //
// //   Future<void> uploadProfilePicture(File image, String userId) async {
// //     try {
// //       String link = await uploadImage('https://lesmind.com/api/photos/upload_profile_pic.php', image);
// //       //print('Obraz przesłany, link: $link');
// //
// //       var response = await http.post(
// //         Uri.parse('https://lesmind.com/api/photos/update_user_profile.php'),
// //         body: jsonEncode({"userId": userId, "photoUrl": link}),
// //         headers: {"Content-Type": "application/json"},
// //       );
// //
// //       //print('Response status: ${response.statusCode}');
// //       // //print('Response body: ${response.body}');
// //
// //       if (response.statusCode == 200) {
// //         //print('Profilowe zdjęcie zaktualizowane pomyślnie');
// //       } else if (response.statusCode == 401) {
// //         throw Exception('Nieautoryzowany: ${response.statusCode}');
// //       } else {
// //         throw Exception('Nie udało się zaktualizować zdjęcia profilowego: ${response.statusCode}, Body: ${response.body}');
// //       }
// //     } catch (e) {
// //       //print('Błąd w uploadProfilePicture: $e');
// //       throw Exception('Nie udało się zaktualizować zdjęcia profilowego: $e');
// //     }
// //   }
// //
// //   Future<void> uploadPost(File image, String location, String description, String userId) async {
// //     try {
// //       // Get user
// //       user = (await _authService.getCurrentUser())!;
// //
// //       // Upload image and get the link
// //       String link = await uploadImage('posts', image);
// //
// //       // Make sure to send the correct keys as expected by the endpoint
// //       var response = await http.post(
// //         Uri.parse('$baseUrl/api/posts/create_post.php'),
// //         body: jsonEncode({
// //           "userId": userId,   	// Klucz zmieniony na userId
// //           "content": description,  // Klucz zmieniony na content
// //           "photoUrl": link, // Klucz zmieniony na photoUrl
// //         }),
// //         headers: {"Content-Type": "application/json"},
// //       );
// //
// //       // Sprawdzenie odpowiedzi
// //       if (response.statusCode != 201) {
// //         throw Exception("Failed to upload post: ${response.body}");
// //       }
// //
// //       String formattedTimestamp = timeago.format(
// //         DateTime.now().subtract(Duration(seconds: 1)),
// //         locale: 'pl',
// //       );
// //       //print("Post dodany $formattedTimestamp");
// //     } catch (e) {
// //       throw Exception('Failed to upload post: $e');
// //     }
// //   }
// //
// //   // Method to check if the current user liked a post
// //   Future<bool> isUserLiked(String userId, String id) async {
// //     try {
// //       final response = await http.get(
// //         Uri.parse('$baseUrl/posts/$id/likedBy/$userId'),
// //       );
// //
// //       if (response.statusCode == 200) {
// //         // Parse response to determine if user liked the post
// //         final responseData = jsonDecode(response.body);
// //         return responseData['liked'];
// //       } else {
// //         throw Exception('Failed to check if user liked the post');
// //       }
// //     } catch (e) {
// //       throw Exception('Failed to check if user liked the post: $e');
// //     }
// //   }
// //
// //   // add the comment to notification collection
// //   Future<void> addCommentToNotification(String type, String commentData, String username, String userId, String id, String mediaUrl, String ownerId, String userDp) async {
// //     var response = await http.post(
// //       Uri.parse('https://lesmind.com/api/notifications'),
// //       body: jsonEncode({
// //         "type": type,
// //         "commentData": commentData,
// //         "username": username,
// //         "userId": userId,
// //         "userDp": userDp,
// //         "id": id,
// //         "mediaUrl": mediaUrl,
// //         "timestamp": DateTime.now().toIso8601String(),
// //       }),
// //       headers: {"Content-Type": "application/json"},
// //     );
// //     if (response.statusCode != 200) {
// //       throw Exception("Failed to add comment to notification");
// //     }
// //   }
// //
// //   // add likes to the notification collection
// //   Future<void> addLikesToNotification(String type, String username, String userId, String id, String mediaUrl, String ownerId, String userDp) async {
// //     var response = await http.post(
// //       Uri.parse('https://lesmind.com/api/notifications'),
// //       body: jsonEncode({
// //         "type": type,
// //         "username": username,
// //         "userId": userId,
// //         "userDp": userDp,
// //         "id": id,
// //         "mediaUrl": mediaUrl,
// //         "timestamp": DateTime.now().toIso8601String(),
// //       }),
// //       headers: {"Content-Type": "application/json"},
// //     );
// //     if (response.statusCode != 200) {
// //       throw Exception("Failed to add like to notification");
// //     }
// //   }
// //
// //   // remove likes from notification
// //   Future<void> removeLikeFromNotification(String ownerId, String id, String currentUser) async {
// //     if (currentUser != ownerId) {
// //       var response = await http.delete(
// //         Uri.parse('https://lesmind.com/api/notifications/$id'),
// //       );
// //       if (response.statusCode != 200) {
// //         throw Exception("Failed to remove like from notification");
// //       }
// //     }
// //   }
// //
// //   Stream<http.Response> getCommentsStream(String id) async* {
// //     while (true) {
// //       final response = await http.get(Uri.parse('https://lesmind.com/api/comments/get_comments.php'));
// //       yield response;
// //       await Future.delayed(Duration(seconds: 5)); // Polling every 5 seconds
// //     }
// //   }
// //
// //   Future<bool> checkIfLiked(String id) async {
// //     try {
// //       final response = await http.get(Uri.parse('$baseUrl/posts/$id/like'));
// //
// //       if (response.statusCode == 200) {
// //         // Sprawdź, czy użytkownik lajkował post
// //         final data = jsonDecode(response.body);
// //         return data['liked']; // Zakładam, że zwracasz odpowiedź w formacie {"liked": true/false}
// //       } else {
// //         throw Exception('Failed to check if liked');
// //       }
// //     } catch (e) {
// //       //print('Error checking if liked: $e');
// //       rethrow;
// //     }
// //   }
// //
// //   Future<void> likePost(String id) async {
// //     try {
// //       final response = await http.post(Uri.parse('$baseUrl/posts/$id/like'));
// //
// //       if (response.statusCode == 200) {
// //         // Operacja lajkowania udana
// //         //print('Post liked successfully');
// //       } else {
// //         throw Exception('Failed to like post');
// //       }
// //     } catch (e) {
// //       //print('Error liking post: $e');
// //       rethrow;
// //     }
// //   }
// //
// //   Future<void> unlikePost(String id) async {
// //     try {
// //       final response = await http.delete(Uri.parse('$baseUrl/posts/$id/like'));
// //
// //       if (response.statusCode == 200) {
// //         // Operacja unlikowania udana
// //         //print('Post unliked successfully');
// //       } else {
// //         throw Exception('Failed to unlike post');
// //       }
// //     } catch (e) {
// //       //print('Error unliking post: $e');
// //       rethrow;
// //     }
// //   }
// //
// //   // @override
// //   // Future<String> uploadImage(String endpoint, File image) async {
// //   //   String ext = FileUtils.getFileExtension(image);
// //   //   String fileName = "${uuid.v4()}.$ext";
// //   //
// //   //   var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/$endpoint'));
// //   //   request.files.add(await http.MultipartFile.fromPath('file', image.path, filename: fileName));
// //   //
// //   //   var streamedResponse = await request.send();
// //   //   var response = await http.Response.fromStream(streamedResponse);
// //   //
// //   //   if (response.statusCode == 200) {
// //   //     Map<String, dynamic> responseData = jsonDecode(response.body);
// //   //     return responseData['fileUrl'];
// //   //   } else {
// //   //     throw Exception('Failed to upload image: ${response.reasonPhrase}');
// //   //   }
// //   // }
// //
// //   Future<String> uploadImage(String endpoint, File imageFile) async {
// //     var endpoint = "photos/upload_profile_pic.php";
// //     var request = http.MultipartRequest('POST', Uri.parse('https://lesmind.com/api/$endpoint'));
// //     request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
// //     var response = await request.send();
// //     if (response.statusCode == 200) {
// //       var responseBody = await response.stream.bytesToString();
// //       var jsonResponse = jsonDecode(responseBody);
// //       if (jsonResponse['fileUrl'] != null) {
// //         return jsonResponse['fileUrl'];
// //       } else {
// //         throw Exception('Błąd podczas przesyłania pliku: ${jsonResponse['error']}');
// //       }
// //     } else {
// //       throw Exception('Błąd HTTP: ${response.statusCode}');
// //     }
// //   }
// //
// //   // Nowa metoda dla uploadu z userId
// //   Future<String> uploadImageWithUserId(String endpoint, File file, String userId) async {
// //     String ext = FileUtils.getFileExtension(file);
// //     String fileName = "${uuid.v4()}.$ext";
// //
// //     var request = http.MultipartRequest('POST', Uri.parse(endpoint));
// //     request.fields['userId'] = userId; // Dodaj userId do pól formularza
// //     request.files.add(await http.MultipartFile.fromPath('file', file.path, filename: fileName));
// //
// //     var streamedResponse = await request.send();
// //     var response = await http.Response.fromStream(streamedResponse);
// //
// //     if (response.statusCode == 200) {
// //       Map<String, dynamic> responseData = jsonDecode(response.body);
// //       String fileUrl = responseData['fileUrl']; // Przykładowo, odczytaj URL z odpowiedzi
// //       return fileUrl;
// //     } else {
// //       throw Exception('Failed to upload image: ${response.reasonPhrase}');
// //     }
// //   }
// //
// // }
// //
// import 'dart:convert';
// import 'dart:io';
// import 'package:uuid/uuid.dart';
// import 'package:http/http.dart' as http;
// import 'package:les_social/models/user.dart';
// import 'package:les_social/services/services.dart';
// import 'package:timeago/timeago.dart' as timeago;
// import 'package:mime/mime.dart';
// import 'package:http_parser/http_parser.dart';
// import '../utils/file_utils.dart';
// import 'auth_service.dart';
//
// class PostService extends Service {
//   String id = Uuid().v4();
//   late UserModel user; // Deklaracja pola user
//   static const String baseUrl = 'https://lesmind.com'; // Wstaw tutaj adres Twojego backendu
//   final AuthService _authService = AuthService();
//
//   // Pobieranie komentarzy z odpowiedniego endpointu
//   Future<List<dynamic>> getComments(String id) async {
//     try {
//       var url = Uri.parse('$baseUrl/api/comments/get_comments.php');
//       var response = await http.post(
//         url,
//         body: jsonEncode({"id": id}),
//         headers: {"Content-Type": "application/json"},
//       );
//       if (response.statusCode == 200) {
//         return jsonDecode(response.body);
//       } else {
//         throw Exception('Failed to load comments');
//       }
//     } catch (e) {
//       //print('Error fetching comments: $e');
//       rethrow;
//     }
//   }
//
//   // Wysyłanie komentarza do endpointa add_comment.php
//   Future<void> uploadComment(String currentUserId, String comment, String id, String ownerId, String mediaUrl) async {
//     try {
//       var response = await http.post(
//         Uri.parse('$baseUrl/api/comments/add_comment.php'),
//         body: jsonEncode({
//           "userId": currentUserId,
//           "comment": comment,
//           "id": id,
//           "ownerId": ownerId, // Właściciel posta
//           "timestamp": DateTime.now().toIso8601String(),
//           "mediaUrl": mediaUrl // URL powiązany z komentarzem
//         }),
//         headers: {"Content-Type": "application/json"},
//       );
//
//       if (response.statusCode != 200) {
//         throw Exception("Failed to upload comment: ${response.body}");
//       }
//     } catch (e) {
//       //print('Error uploading comment: $e');
//       rethrow;
//     }
//   }
//
//   // Usuwanie komentarza z endpointa delete_comment.php
//   Future<void> deleteComment(String commentId, String userId) async {
//     try {
//       var response = await http.post(
//         Uri.parse('$baseUrl/api/comments/delete_comment.php'),
//         body: jsonEncode({
//           "commentId": commentId,
//           "userId": userId, // ID użytkownika usuwającego komentarz
//         }),
//         headers: {"Content-Type": "application/json"},
//       );
//
//       if (response.statusCode != 200) {
//         throw Exception("Failed to delete comment");
//       }
//     } catch (e) {
//       //print('Error deleting comment: $e');
//       rethrow;
//     }
//   }
//
//   // Pobieranie liczby polubień dla danego posta
//   Future<int> getLikesCount(String id) async {
//     try {
//       var response = await http.get(Uri.parse('$baseUrl/api/likes'));
//       if (response.statusCode == 200) {
//         return int.parse(response.body);
//       } else {
//         throw Exception('Failed to load likes count');
//       }
//     } catch (e) {
//       //print('Error fetching likes count: $e');
//       rethrow;
//     }
//   }
//
//   // Obsługa like/unlike
//   Future<void> toggleLike(String currentUserId, String id) async {
//     try {
//       var response = await http.post(
//         Uri.parse('$baseUrl/posts/$id/likes'),
//         body: jsonEncode({
//           "userId": currentUserId,
//           "timestamp": DateTime.now().toIso8601String(),
//         }),
//         headers: {"Content-Type": "application/json"},
//       );
//
//       if (response.statusCode != 200) {
//         throw Exception("Failed to toggle like");
//       }
//     } catch (e) {
//       //print('Error toggling like: $e');
//       rethrow;
//     }
//   }
//
//   // Metoda do uploadu zdjęcia profilowego
//   Future<void> uploadProfilePicture(File image, String userId) async {
//     try {
//       String link = await uploadImage('https://lesmind.com/api/photos/upload_profile_pic.php', image);
//       //print('Obraz przesłany, link: $link');
//
//       var response = await http.post(
//         Uri.parse('https://lesmind.com/api/photos/update_user_profile.php'),
//         body: jsonEncode({"userId": userId, "photoUrl": link}),
//         headers: {"Content-Type": "application/json"},
//       );
//
//       if (response.statusCode == 200) {
//         //print('Profilowe zdjęcie zaktualizowane pomyślnie');
//       } else {
//         throw Exception('Nie udało się zaktualizować zdjęcia profilowego: ${response.statusCode}, Body: ${response.body}');
//       }
//     } catch (e) {
//       //print('Błąd w uploadProfilePicture: $e');
//       rethrow;
//     }
//   }
//
//   // Metoda do uploadu posta z obrazkiem
//   Future<void> uploadPost(File image, String location, String description, String userId) async {
//     try {
//       user = (await _authService.getCurrentUser())!;
//
//       // Upload obrazu i uzyskanie linku
//       String link = await uploadImage('posts', image);
//
//       var response = await http.post(
//         Uri.parse('$baseUrl/api/posts/create_post.php'),
//         body: jsonEncode({
//           "userId": userId,
//           "content": description,
//           "photoUrl": link,
//         }),
//         headers: {"Content-Type": "application/json"},
//       );
//
//       if (response.statusCode != 201) {
//         throw Exception("Failed to upload post: ${response.body}");
//       }
//
//       //print("Post dodany pomyślnie.");
//     } catch (e) {
//       throw Exception('Failed to upload post: $e');
//     }
//   }
//
//   // Sprawdzenie, czy użytkownik polubił post
//   Future<bool> isUserLiked(String userId, String id) async {
//     try {
//       var response = await http.get(Uri.parse('$baseUrl/posts/$id/likedBy/$userId'));
//
//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         return responseData['liked'];
//       } else {
//         throw Exception('Failed to check if user liked the post');
//       }
//     } catch (e) {
//       //print('Error checking if liked: $e');
//       rethrow;
//     }
//   }
//
//   // Dodanie powiadomienia o komentarzu
//   Future<void> addCommentToNotification(String type, String commentData, String username, String userId, String id, String mediaUrl, String ownerId, String userDp) async {
//     var response = await http.post(
//       Uri.parse('$baseUrl/api/notifications'),
//       body: jsonEncode({
//         "type": type,
//         "commentData": commentData,
//         "username": username,
//         "userId": userId,
//         "userDp": userDp,
//         "id": id,
//         "mediaUrl": mediaUrl,
//         "timestamp": DateTime.now().toIso8601String(),
//       }),
//       headers: {"Content-Type": "application/json"},
//     );
//     if (response.statusCode != 200) {
//       throw Exception("Failed to add comment to notification");
//     }
//   }
//
//   // Metoda do uploadu zdjęcia z userId
//   Future<String> uploadImageWithUserId(String endpoint, File file, String userId) async {
//     String ext = FileUtils.getFileExtension(file);
//     String fileName = "${Uuid().v4()}.$ext";
//
//     var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/$endpoint'));
//     request.fields['userId'] = userId; // Dodanie userId do pól formularza
//     request.files.add(await http.MultipartFile.fromPath('file', file.path, filename: fileName));
//
//     var streamedResponse = await request.send();
//     var response = await http.Response.fromStream(streamedResponse);
//
//     if (response.statusCode == 200) {
//       Map<String, dynamic> responseData = jsonDecode(response.body);
//       return responseData['fileUrl'];
//     } else {
//       throw Exception('Failed to upload image: ${response.reasonPhrase}');
//     }
//   }
//
//   Future<bool> checkIfLiked(String id) async {
//     try {
//       final response = await http.get(Uri.parse('$baseUrl/posts/$id/like'));
//
//       if (response.statusCode == 200) {
//         // Sprawdź, czy użytkownik lajkował post
//         final data = jsonDecode(response.body);
//         return data['liked']; // Zakładam, że zwracasz odpowiedź w formacie {"liked": true/false}
//       } else {
//         throw Exception('Failed to check if liked');
//       }
//     } catch (e) {
//       //print('Error checking if liked: $e');
//       rethrow;
//     }
//   }
//
//   Future<void> likePost(String id) async {
//     try {
//       final response = await http.post(Uri.parse('$baseUrl/posts/$id/like'));
//
//       if (response.statusCode == 200) {
//         // Operacja lajkowania udana
//         //print('Post liked successfully');
//       } else {
//         throw Exception('Failed to like post');
//       }
//     } catch (e) {
//       //print('Error liking post: $e');
//       rethrow;
//     }
//   }
//
//   Future<void> unlikePost(String id) async {
//     try {
//       final response = await http.delete(Uri.parse('$baseUrl/posts/$id/like'));
//
//       if (response.statusCode == 200) {
//         // Operacja unlikowania udana
//         //print('Post unliked successfully');
//       } else {
//         throw Exception('Failed to unlike post');
//       }
//     } catch (e) {
//       //print('Error unliking post: $e');
//       rethrow;
//     }
//   }
// }
//
//
//

import 'dart:convert';
import 'dart:io';
import 'package:les_social/models/comments.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:les_social/models/user.dart';
import 'package:les_social/services/services.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../utils/file_utils.dart';
import 'auth_service.dart';

class PostService extends Service {
  String id = Uuid().v4();
  late UserModel user; // Deklaracja pola user
  static const String baseUrl = 'https://lesmind.com'; // Wstaw tutaj adres Twojego backendu
  final AuthService _authService = AuthService();

  // Pobieranie komentarzy z odpowiedniego endpointu
  Future<List<CommentModel>> getComments(String postId) async {
    //print("Requesting comments for postId: $postId");
    try {
      var url = Uri.parse('$baseUrl/api/comments/get_comments.php?postId=$postId');
      var response = await http.post(
        url,
        body: jsonEncode({"postId": postId}), // Użyj postId zamiast id
        headers: {"Content-Type": "application/json"},
      );

      //print("Response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        var commentsJson = jsonDecode(response.body);
        //print("Comments fetched: $commentsJson");

        // Sprawdź, czy commentsJson jest listą
        if (commentsJson is List) {
          // Mapuj JSON na instancje CommentModel
          return commentsJson.map((comment) => CommentModel.fromJson(comment)).toList();
        } else {
          throw Exception('Invalid response structure: $commentsJson');
        }
      } else {
        throw Exception('Failed to load comments: ${response.body}');
      }
    } catch (e) {
      //print('Error fetching comments: $e');
      rethrow;
    }
  }

  // Pobieranie odpowiedzi na komentarz
  Future<List<CommentModel>> getReplies(String commentId) async {
    //print("Requesting replies for commentId: $commentId");
    try {
      var url = Uri.parse('$baseUrl/api/comments/get_replies_to_comment.php?commentId=$commentId');
      var response = await http.get(url, headers: {"Content-Type": "application/json"});

      //print("Response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        var repliesJson = jsonDecode(response.body);
        //print("Replies fetched: $repliesJson");

        // Sprawdź, czy repliesJson jest listą
        if (repliesJson is List) {
          return repliesJson.map((reply) => CommentModel.fromJson(reply)).toList();
        } else {
          throw Exception('Invalid response structure: $repliesJson');
        }
      } else {
        throw Exception('Failed to load replies: ${response.body}');
      }
    } catch (e) {
      //print('Error fetching replies: $e');
      rethrow;
    }
  }

  // Wysyłanie komentarza do endpointa add_comment.php
  Future<void> uploadComment(String currentUserId, String comment, String postId, String ownerId, String mediaUrl, {String? parentId}) async {
    try {
      // Przygotowanie danych do wysłania
      final Map<String, dynamic> requestData = {
        "userId": currentUserId,
        "comment": comment,
        "postId": postId, // Zmiana 'id' na 'postId'
        "ownerId": ownerId,
        "timestamp": DateTime.now().toIso8601String(),
        "mediaUrl": mediaUrl,
        "parentId": parentId
      };

      var response = await http.post(
        Uri.parse('$baseUrl/api/comments/add_comment.php'),
        body: jsonEncode(requestData),
        headers: {"Content-Type": "application/json"},
      );

      // Logowanie statusu odpowiedzi
      //print('Response status: ${response.statusCode}');
      //print('Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception("Failed to upload comment: ${response.body}");
      }

      //print('Comment uploaded successfully!');
    } catch (e) {
      //print('Error uploading comment: $e');
      rethrow;
    }
  }

  Future<void> uploadReply(String currentUserId, String reply, String commentId, String username, String mediaUrl, {String? parentReplyId}) async {
    try {
      // Przygotowanie danych do wysłania
      final Map<String, dynamic> requestData = {
        "userId": currentUserId,
        "reply": reply,
        "commentId": commentId, // Prawidłowy ID komentarza
        "createdAt": DateTime.now().toIso8601String(),
        "username": username, // Prawidłowa nazwa użytkownika
        "userDp": mediaUrl, // URL do zdjęcia profilowego
      };

      // Dodanie parentReplyId, jeśli jest dostępne
      if (parentReplyId != null) {
        requestData["parentReplyId"] = parentReplyId;
      }

      print("Czy to jest blad z metody uploadReply?");
      print('Uploading reply with the following data:');
      print('User ID: $currentUserId');
      print('Reply: $reply');
      print('Comment ID: $commentId');
      print('Username: $username');
      print('Created At: ${requestData['createdAt']}');
      print('UserDp (Media URL): $mediaUrl');
      if (parentReplyId != null)
        print('Parent Reply ID: $parentReplyId');

      var response = await http.post(
        Uri.parse('$baseUrl/api/comments/reply_to_comment.php'),
        body: jsonEncode(requestData),
        headers: {"Content-Type": "application/json"},
      );

      // Logowanie statusu odpowiedzi
      //print('Response status: ${response.statusCode}');
      //print('Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception("Failed to upload reply: ${response.body}");
      }

      //print('Reply uploaded successfully!');
    } catch (e) {
      //print('Error uploading reply: $e');
      rethrow;
    }
  }

  Future<void> uploadReplyToReply(String currentUserId, String reply, String replyToId, String username, String mediaUrl) async {
    try {
      // Przygotowanie danych do wysłania
      final Map<String, dynamic> requestData = {
        "userId": currentUserId,
        "reply": reply,
        "replyToId": replyToId, // ID odpowiedzi, na którą odpowiadasz
        "username": username, // Prawidłowa nazwa użytkownika
        "userDp": mediaUrl, // URL do zdjęcia profilowego
      };

      //print('Uploading reply to reply with the following data:');
      //print('User ID: $currentUserId');
      //print('Reply: $reply');
      //print('Reply To ID: $replyToId');
      //print('Username: $username');
      //print('UserDp (Media URL): $mediaUrl');

      var response = await http.post(
        Uri.parse('$baseUrl/api/comments/reply_to_reply.php'), // Zakładam, że masz odpowiedni endpoint
        body: jsonEncode(requestData),
        headers: {"Content-Type": "application/json"},
      );

      // Logowanie statusu odpowiedzi
      //print('Response status: ${response.statusCode}');
      //print('Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception("Failed to upload reply to reply: ${response.body}");
      }

      // //print('Reply to reply uploaded successfully!');
    } catch (e) {
      // //print('Error uploading reply to reply: $e');
      rethrow;
    }
  }

  // Usuwanie komentarza z endpointa delete_comment.php
  Future<void> deleteComment(String commentId, String userId) async {
    try {
      var response = await http.post(
        Uri.parse('$baseUrl/api/comments/delete_comment.php'),
        body: jsonEncode({
          "commentId": commentId,
          "userId": userId, // ID użytkownika usuwającego komentarz
        }),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to delete comment");
      }
    } catch (e) {
      //print('Error deleting comment: $e');
      rethrow;
    }
  }

  // Pobieranie liczby polubień dla danego posta
  Future<int> getLikesCount(int id) async {
    try {
      // Upewnij się, że id jest częścią URL
      var response = await http.get(Uri.parse('$baseUrl/api/likes/$id')); // Przykładowy endpoint
      if (response.statusCode == 200) {
        // Zakładając, że odpowiedź jest typu JSON i zawiera liczbę polubień
        final data = jsonDecode(response.body);
        return data['likesCount'] ?? 0; // Oczekujemy, że likesCount będzie w odpowiedzi
      } else {
        throw Exception('Failed to load likes count');
      }
    } catch (e) {
      //print('Error fetching likes count: $e');
      rethrow;
    }
  }

  // Obsługa like/unlike
  Future<void> toggleLike(String currentUserId, String id) async {
    try {
      var response = await http.post(
        Uri.parse('$baseUrl/posts/$id/likes'),
        body: jsonEncode({
          "userId": currentUserId,
          "timestamp": DateTime.now().toIso8601String(),
        }),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to toggle like");
      }
    } catch (e) {
      //print('Error toggling like: $e');
      rethrow;
    }
  }

  // Metoda do uploadu zdjęcia profilowego
  Future<void> uploadProfilePicture(File image, String userId) async {
    try {
      String link = await uploadImage('https://lesmind.com/api/photos/upload_profile_pic.php', image);
      //print('Obraz przesłany, link: $link');

      var response = await http.post(
        Uri.parse('https://lesmind.com/api/photos/update_user_profile.php'),
        body: jsonEncode({"userId": userId, "photoUrl": link}),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        //print('Profilowe zdjęcie zaktualizowane pomyślnie');
      } else {
        throw Exception('Nie udało się zaktualizować zdjęcia profilowego: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      //print('Błąd w uploadProfilePicture: $e');
      rethrow;
    }
  }

  // Metoda do uploadu posta z obrazkiem
  Future<String> uploadPost(File image, String location, String description, String userId) async {
    try {
      // Logowanie informacji o użytkowniku
      user = (await _authService.getCurrentUser())!;
      //print('Zalogowany użytkownik: ${user.id}');

      // Generowanie unikalnego ID dla posta
      String postId = Uuid().v4();
      //print('Generowane ID posta: $postId');

      // Upload obrazu i uzyskanie linku
      //print('Rozpoczynam przesyłanie obrazu...');
      String link = await uploadImage('posts', image);
      //print('Link do przesłanego obrazu: $link');

      // Przygotowanie danych do wysłania
      final Map<String, dynamic> postData = {
        "postId": postId,
        "userId": userId,
        "content": description,
        "photoUrl": link,
        "location": location,
      };

      // Logowanie danych przed wysłaniem
      //print('Wysyłane dane: $postData');

      // Wysłanie danych do backendu
      //print('Wysyłanie danych do $baseUrl/api/posts/create_post.php...');
      var response = await http.post(
        Uri.parse('$baseUrl/api/posts/create_post.php'),
        body: jsonEncode(postData),
        headers: {"Content-Type": "application/json"},
      );

      // Logowanie statusu odpowiedzi
      //print('Odpowiedź serwera: ${response.statusCode}');
      //print('Treść odpowiedzi: ${response.body}');

      // Sprawdzanie odpowiedzi
      if (response.statusCode != 200) {
        //print('Błąd w odpowiedzi: ${response.body}');
        throw Exception("Failed to upload post: ${response.body}");
      }

      // Zakładam, że twój backend zwraca post w formacie JSON, w tym ID posta
      final Map<String, dynamic> postResponseData = jsonDecode(response.body);
      if (!postResponseData['success']) {
        throw Exception('Failed to upload post: ${postResponseData}');
      }

      //print("Post dodany pomyślnie. ID posta: ${postResponseData['postId']}");
      return postId; // Zwróć postId
    } catch (e) {
      //print('Błąd podczas przesyłania posta: $e'); // Logowanie błędów
      throw Exception('Failed to upload post: $e');
    }
  }

  // Sprawdzenie, czy użytkownik polubił post
  Future<bool> isUserLiked(String userId, String id) async {
    try {
      var response = await http.get(Uri.parse('$baseUrl/posts/$id/likedBy/$userId'));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['liked'];
      } else {
        throw Exception('Failed to check if user liked the post');
      }
    } catch (e) {
      //print('Error checking if liked: $e');
      rethrow;
    }
  }

  // Dodanie powiadomienia o komentarzu
  Future<void> addCommentToNotification(String type, String commentData, String username, String userId, String id, String mediaUrl, String ownerId, String userDp) async {
    var response = await http.post(
      Uri.parse('$baseUrl/api/notifications'),
      body: jsonEncode({
        "type": type,
        "commentData": commentData,
        "username": username,
        "userId": userId,
        "userDp": userDp,
        "id": id,
        "mediaUrl": mediaUrl,
        "timestamp": DateTime.now().toIso8601String(),
      }),
      headers: {"Content-Type": "application/json"},
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to add comment to notification");
    }
  }

  // Metoda do uploadu zdjęcia z userId
  Future<String> uploadImageWithUserId(String endpoint, File file, String userId) async {
    String ext = FileUtils.getFileExtension(file);
    String fileName = "${Uuid().v4()}.$ext";

    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/$endpoint'));
    request.fields['userId'] = userId; // Dodanie userId do pól formularza
    request.files.add(await http.MultipartFile.fromPath('file', file.path, filename: fileName));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData['fileUrl'];
    } else {
      throw Exception('Failed to upload image: ${response.reasonPhrase}');
    }
  }

  Future<bool> checkIfLiked(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/posts/$id/like'));

      if (response.statusCode == 200) {
        // Sprawdź, czy użytkownik lajkował post
        final data = jsonDecode(response.body);
        return data['liked']; // Zakładam, że zwracasz odpowiedź w formacie {"liked": true/false}
      } else {
        throw Exception('Failed to check if liked');
      }
    } catch (e) {
      //print('Error checking if liked: $e');
      rethrow;
    }
  }

  Future<void> likePost(String id) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/posts/$id/like'));

      if (response.statusCode != 200) {
        throw Exception('Failed to like post');
      }
    } catch (e) {
      //print('Error liking post: $e');
      rethrow;
    }
  }

  Future<void> unlikePost(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/posts/$id/like'));

      if (response.statusCode == 200) {
        // Operacja unlikowania udana
        //print('Post unliked successfully');
      } else {
        throw Exception('Failed to unlike post');
      }
    } catch (e) {
      //print('Error unliking post: $e');
      rethrow;
    }
  }
}



