import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:les_social/services/auth_service.dart';
import 'package:les_social/services/storage_class.dart';
import '../models/notification.dart';
import '../models/post.dart';
import '../models/user.dart';
import 'package:http/http.dart' as http;

class ApiService {
  BuildContext context; // Dodano pole przechowujące BuildContext
  ApiService(this.context); // Konstruktor przyjmujący BuildContext
  AuthService _authService = AuthService();
  final String baseUrl = 'https://lesmind.com';

  Future<List<UserModel>> fetchUsers() async {
    var url = '$baseUrl/api/users/get_users.php'; // Zmień na właściwy adres URL
    try {
      var response = await http.get(Uri.parse(url), headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        List<UserModel> users = List<UserModel>.from(responseData.map((model) => UserModel.fromJson(model)));
        return users;
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      //print('Error fetching users: $e');
      return [];
    }
  }

  Future<UserModel> fetchUserData(String userId) async {
    try {
      final storage = StorageClass();
      final token = await storage.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Token JWT is missing');
      }

      final response = await http.get(
        Uri.parse('https://lesmind.com/api/users/get_user.php?userId=$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load user data: ${response.body}');
      }
    } catch (e) {
      //print('Error fetching user data: $e');
      throw Exception('Error fetching user data');
    }
  }

  // Metoda do pobierania danych użytkownika na podstawie profileId
  Future<UserModel> fetchUserProfile(String userId) async {
    var url = '$baseUrl/api/users/get_user.php?userId=$userId'; // Endpoint Twojego API do pobrania danych użytkownika
    try {
      var response = await http.get(Uri.parse(url));
      // //print("Odpowiedź serwera: ${response.body}");
      if (response.statusCode == 200) {
        // //print('Odpowiedź serwera: ${response.body}'); // Logowanie odpowiedzi
        var responseData = jsonDecode(response.body);
        return UserModel.fromJson(responseData); // Twój model danych użytkownika
      } else {
        throw Exception('Failed to load user profile');
      }
    } catch (e) {
      //print("Error fetching user profile: $e");
      throw Exception('Error fetching user profile: $e');
    }
  }

  Future<UserModel> getUser(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/users/get_user.php/$userId'));

      if (response.statusCode == 200) {
        // Parse the JSON response
        Map<String, dynamic> responseData = jsonDecode(response.body);
        UserModel user = UserModel.fromJson(responseData); // Adjust to match your UserModel
        return user;
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> sendFriendRequest(
      int userId,
      int senderId,
      String senderName,
      String senderPhotoUrl,
      int senderAge) async {
    var data = {
      'userId': userId.toString(),
      'senderId': senderId.toString(),
      'senderName': senderName,
      'senderPhotoUrl': senderPhotoUrl,
      'senderAge': senderAge.toString(),
    };
    var url = '$baseUrl/api/friends/send_friend_request.php';
    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['success'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Friend request sent successfully'),
            backgroundColor: Colors.green,
          ));
        } else if (responseData['error'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(responseData['error']),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('HTTP Error ${response.statusCode}: ${response.reasonPhrase}'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  // Future<List<Map<String, dynamic>>> fetchFriendRequests(String userId) async {
  //   var url = '$baseUrl/api/friends/fetch_friend_requests.php'; // Adres Twojego endpointu
  //
  //   try {
  //     var response = await http.post(Uri.parse(url), body: {'userId': userId});
  //
  //     if (response.statusCode == 200) {
  //       var responseData = jsonDecode(response.body);
  //       if (responseData is List) {
  //         return List<Map<String, dynamic>>.from(responseData);
  //       } else {
  //         throw Exception('Invalid response format');
  //       }
  //     } else {
  //       throw Exception('Failed to load friend requests');
  //     }
  //   } catch (e) {
  //     //print('Error fetching friend requests: $e');
  //     return []; // Zwróć pustą listę w przypadku błędu
  //   }
  // }

  Future<List<Map<String, dynamic>>> fetchFriendRequests(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/friends/fetch_friend_requests.php?userId=$userId'), // Upewnij się, że adres jest poprawny
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load friend requests');
    }
  }

  Future<List<UserModel>> fetchAcceptedFriends(String userId) async {
    try {
      //print("Fetching accepted friends for user ID: $userId"); // Logowanie userId
      final response = await http.get(
        Uri.parse("$baseUrl/api/friends/fetch_accepted_friends.php?userId=$userId"),
        headers: {'Content-Type': 'application/json'}, // Poprawiona Content-Type
      );

      //print("Response status: ${response.statusCode}"); // Logowanie statusu odpowiedzi
      //print("Response body: ${response.body}"); // Logowanie ciała odpowiedzi

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body)['friends']; // Upewnij się, że odwołujesz się do klucza 'friends'
        List<UserModel> users = data.map((user) => UserModel.fromJson(user)).toList();
        return users;
      } else {
        throw Exception("Failed to fetch accepted friends.");
      }
    } catch (e) {
      //print("Error fetching accepted friends: $e");
      return [];
    }
  }

  Future<bool> uploadPhoto(String userId, String imagePath) async {
    var url = '$baseUrl/api/photos/upload_photo.php'; // Endpoint do dodawania zdjęć

    var formData = FormData.fromMap({
      'userId': userId,
      'image': await MultipartFile.fromFile(imagePath),
    });

    try {
      var response = await Dio().post(url, data: formData);

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.data);
        return responseData['success'] == true;
      } else {
        throw Exception('Failed to upload photo');
      }
    } catch (e) {
      //print('Error uploading photo: $e');
      return false;
    }
  }

  Future<void> setUserStatus(bool isOnline) async {
    var userId = _authService.getCurrentUser(); // Implementacja tej metody zależy od Twojego kontekstu
    var url = '$baseUrl/api/users/update_user_status.php'; // Zmień na właściwy adres URL swojego endpointu
    var data = {
      'userId': userId,
      'isOnline': isOnline.toString(),
      'lastSeen': DateTime.now()
    };

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['success'] != null) {
          //print('User status updated successfully');
        } else if (responseData['error'] != null) {
          //print('Error: ${responseData['error']}');
        }
      } else {
        //print('HTTP Error ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      //print('Error updating user status: $e');
    }
  }

  Future<bool> checkForFriendRequests(String userId) async {
    try {
      // Wykonaj żądanie HTTP do swojego API
      var response = await http.get(
        Uri.parse('$baseUrl/api/friends/check_friend_request.php?userId=$userId'),
      );

      if (response.statusCode == 200) {
        // Jeśli żądanie zakończyło się sukcesem, parsuj odpowiedź JSON
        var jsonData = jsonDecode(response.body);
        return jsonData['hasFriendRequests'] ?? false;
      } else {
        throw Exception('Failed to check for friend requests');
      }
    } catch (e) {
      //print('Error checking for friend requests: $e');
      throw e; // Rzuć wyjątek dalej do obsługi błędów
    }
  }

  Future<int> getFriendRequestCount(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/friends/get_friend_request_count.php?userId=$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['count'] ?? 0;
      } else {
        throw Exception('Failed to fetch friend request count');
      }
    } catch (e) {
      //print('Error fetching friend request count: $e');
      throw e; // Rzuć wyjątek dalej do obsługi błędów
    }
  }

  Future<Map<String, dynamic>> acceptFriendRequest(String userId, String senderId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/friends/accept_friend_request.php'),
        body: {'userId': userId, 'senderId': senderId},
      );

      // Logowanie odpowiedzi
      //print('Status odpowiedzi serwera: ${response.statusCode}');
      //print('Odpowiedź serwera: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Sprawdź, czy odpowiedź zawiera klucz "success" lub inne klucze potwierdzające sukces
        if (responseData['success'] != null && responseData['success'] == true) {
          return responseData; // Zwróć odpowiedź, jeśli akceptacja powiodła się
        } else {
          // Zgłoś wyjątek z komunikatem zwróconym przez serwer
          throw Exception('Failed to accept friend request: ${responseData['message'] ?? 'Nieznany błąd'}');
        }
      } else {
        throw Exception('Failed to accept friend request: Server returned status ${response.statusCode}');
      }
    } catch (e) {
      // Logowanie błędu
      //print('Błąd podczas akceptacji zaproszenia: $e');
      throw Exception('Błąd podczas akceptacji zaproszenia: $e');
    }
  }

  Future<Map<String, dynamic>> rejectFriendRequest(String userId, String senderId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/friends/reject_friend_request.php'), // Upewnij się, że adres jest poprawny
      body: {'userId': userId, 'senderId': senderId},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to reject friend request');
    }
  }

  Future<List<UserModel>> fetchPendingRequests(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/friends/pending_requests.php?userId=$userId'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((user) => UserModel.fromJson(user)).toList();
    } else {
      throw Exception('Failed to load pending requests');
    }
  }

  Future<List<ActivityModel>> getLikeNotifications(String postId) async {
    try {
      final response = await http.get(Uri.parse('https://lesmind.com/api/notifications/get_likes_notifications.php?postId=$postId'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        //print('Received notifications: $data');  // Logowanie zwróconych danych
        return data.map((e) => ActivityModel.fromJson(e)).toList();
      } else {
        //print('Błąd pobierania powiadomień');
        return [];
      }
    } catch (e) {
      //print('Błąd w metodzie getLikeNotifications: $e');
      return [];
    }
  }

  Future<List<ActivityModel>> getUserNotifications(String recipientId) async {
    try {
      //print('Fetching notifications for recipientId: $recipientId');
      final url = Uri.parse('$baseUrl/api/notifications/get_notifications.php?recipientId=$recipientId');
      final response = await http.get(url);

      //print('Response status: ${response.statusCode}');
      //print('Response body: ${response.body}'); // Logujemy pełną odpowiedź

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Logowanie długości danych
        //print('Number of notifications: ${data.length}');

        if (data.isEmpty) {
          //print('No notifications available.');
          return [];
        }

        //print('Decoded data: $data'); // Dodajemy logowanie przed mapowaniem na model
        return data.map((json) => ActivityModel.fromJson(json)).toList();
      } else {
        //print('Błąd podczas pobierania powiadomień: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      //print('Błąd połączenia: $e');
      return [];
    }
  }

  // Metoda do pobrania liczby powiadomień użytkownika na podstawie userId
  Future<int> getNotificationCount(String userId) async {
    var url = '$baseUrl/api/notifications/get_notification_count.php'; // Endpoint do pobrania liczby powiadomień
    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        return responseData['count'] ?? 0; // Zwraca liczbę powiadomień lub 0, jeśli nie ma powiadomień
      } else {
        throw Exception('Failed to load notification count');
      }
    } catch (e) {
      //print('Error fetching notification count: $e');
      return 0; // Zwraca 0 w przypadku błędu
    }
  }

  Future<void> addNotification(int userId, String type, String message) async {
    var url = '$baseUrl/api/notifications/add_notification.php';
    try {
      var response = await http.post(Uri.parse(url), body: {
        'userId': userId.toString(),
        'type': type,
        'message': message,
      });

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['success']) {
          //print('Notification added successfully');
        } else {
          //print('Failed to add notification: ${responseData['error']}');
        }
      } else {
        throw Exception('Failed to add notification');
      }
    } catch (e) {
      //print('Error adding notification: $e');
    }
  }

  Future<bool> deleteAllNotifications(String userId) async {
    var url = '$baseUrl/api/notifications/delete_all_notifications.php';
    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete notifications');
      }
    } catch (e) {
      //print('Error deleting notifications: $e');
      return false;
    }
  }

  Future<UserModel> getUserById(String userId) async {
    final url = Uri.parse('$baseUrl/api/users/$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON
        return UserModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load user: $e');
    }
  }

  Future<PostModel> getPostById(String postId) async {
    try {
      final url = Uri.parse('$baseUrl/api/posts/get_post_by_id.php?postId=$postId');
      //print('Tworzony URL: $url');  // Debugging URL
      final response = await http.get(url);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);

        if (data.isNotEmpty && data.containsKey('postId')) {
          return PostModel.fromJson(data);  // Mapujemy dane na PostModel
        } else {
          throw Exception('Post not found or invalid response structure');
        }
      } else {
        throw Exception('Failed to load post: ${response.statusCode}');
      }
    } catch (e) {
      //print('Error fetching post: $e');
      throw Exception('Error fetching post: $e');
    }
  }

  Future<List<PostModel>> fetchPosts() async {
    int page = 0; // Definicja zmiennej page w klasie ApiService
    final response = await http.get(Uri.parse('$baseUrl/api/posts/get_user_posts.php')); // Zmień na odpowiedni endpoint swojego backendu
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => PostModel.fromJson(model)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<int> fetchCommentCount(String postId) async {
    var url = '$baseUrl/api/comments/get_comment_count.php?postId=$postId'; // Endpoint do liczenia komentarzy
    try {
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        return responseData['count'] ?? 0; // Zwraca liczbę komentarzy
      } else {
        throw Exception('Failed to fetch comment count');
      }
    } catch (e) {
      //print('Error fetching comment count: $e');
      return 0; // Zwraca 0 w przypadku błędu
    }
  }

  Future<http.Response> post(String endpoint, {Map<String, String>? headers, dynamic body}) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    return await http.post(
      url,
      headers: headers ?? {'Content-Type': 'application/json'},
      body: body,
    );
  }
}
