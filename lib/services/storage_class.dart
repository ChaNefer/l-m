import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StorageClass {
  Future<void> saveUserId(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId);
      //print('userId saved: $userId');
    } catch (e) {
      //print('Error saving userId: $e');
    }
  }

  Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('userId');
    } catch (e) {
      //print('Error getting userId: $e');
      return null;
    }
  }

  Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
      //print('Token saved: $token');
    } catch (e) {
      //print('Error saving token: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('jwt_token');
    } catch (e) {
      //print('Error getting token: $e');
      return null;
    }
  }

  Future<void> removeToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_token');
      //print('Token removed');
    } catch (e) {
      //print('Error removing token: $e');
    }
  }

  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      await prefs.remove('jwt_token');
      //print('SharedPreferences cleared');
    } catch (e) {
      //print('Error clearing SharedPreferences: $e');
    }
  }

  Future<bool> hasUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey('userId');
    } catch (e) {
      //print('Error checking for userId: $e');
      return false;
    }
  }

  Future<bool> hasToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey('jwt_token');
    } catch (e) {
      //print('Error checking for token: $e');
      return false;
    }
  }

  // Zapisuje URL zdjęcia profilowego w SharedPreferences
  Future<void> savePhotoUrl(String photoUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('photoUrl', photoUrl);
      //print('Photo URL saved: $photoUrl');
    } catch (e) {
      //print('Error saving photo URL: $e');
    }
  }

  // Pobiera URL zdjęcia profilowego z SharedPreferences
  Future<String?> getPhotoUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('photoUrl');
    } catch (e) {
      //print('Error getting photo URL: $e');
      return null;
    }
  }

// Zapisuje postId w SharedPreferences
  Future<void> savePostId(String postId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('postId', postId);
      //print('Post ID saved: $postId');
    } catch (e) {
      //print('Error saving postId: $e');
    }
  }

// Pobiera postId z SharedPreferences
  Future<String?> getPostId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('postId');
    } catch (e) {
      //print('Error getting postId: $e');
      return null;
    }
  }

  void saveOneSignalToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('onesignal_token', token);

    // Jeśli chcesz wysłać token do backendu
    sendTokenToBackend(token);
  }

  Future<void> sendTokenToBackend(String token) async {
    String? userId = await StorageClass().getUserId(); // Sprawdzenie userId
    if (userId == null) {
      print('Nie znaleziono userId!');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://lesmind.com/api/call/save_onesignal_token.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userId': userId,  // Użycie userId
          'onesignal_token': token,
        }),
      );

      if (response.statusCode == 200) {
        print('Token zapisany w backendzie');
      } else {
        print('Błąd podczas zapisywania tokenu w backendzie');
      }
    } catch (e) {
      print('Błąd: $e');
    }
  }

}
