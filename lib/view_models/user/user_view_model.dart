import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:les_social/models/user.dart';
import 'package:les_social/services/auth_service.dart';

class UserViewModel extends ChangeNotifier {
  UserModel? _user;
  AuthService _authService = AuthService();

  UserModel? get user => _user;

  // Future<void> setUser() async {
  //   // Tutaj wykonaj zapytanie HTTP do Twojego backendu
  //   try {
  //     final response = await http.get(Uri.parse('https://lesmind.com/api/users/get_user.php')); // Tutaj ustaw URL do zapytania do Twojego backendu
  //
  //     if (response.statusCode == 200) {
  //       // Przetwórz odpowiedź
  //       Map<String, dynamic> userData = json.decode(response.body);
  //
  //       // Przyjmując, że model User ma konstruktor z odpowiednich pól
  //       _user = UserModel.fromJson(userData);
  //
  //       // Poinformuj odbiorców o zmianach w modelu użytkownika
  //       notifyListeners();
  //     } else {
  //       // Obsłuż błąd zapytania
  //       throw Exception('Failed to load user data');
  //     }
  //   } catch (e) {
  //     //print('Error fetching user data: $e');
  //     throw e; // Możesz obsłużyć błąd w sposób specyficzny dla Twojej aplikacji
  //   }
  // }

  Future<UserModel?> currentUserId() async {
    try {
      var currentUser = await _authService.getCurrentUser();
      if (currentUser != null) {
        _user = currentUser; // Ustawienie użytkownika
        notifyListeners();   // Powiadomienie widoku o zmianie
      }
      return currentUser;
    } catch (e) {
      print("currentUserId: Błąd podczas pobierania danych użytkownika - $e");
      return null;
    }
  }

}

