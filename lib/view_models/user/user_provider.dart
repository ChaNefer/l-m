import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:les_social/services/user_service.dart';
import '../../models/user.dart';


class UserProvider with ChangeNotifier {
  UserModel? _user;
  late UserService userService; // To musi być inicjalizowane przed użyciem

  UserModel? get user => _user;

  // Konstruktor, który przyjmuje userService jako parametr
  UserProvider({required this.userService});

  // Metoda do ustawiania użytkownika
  void setUser(UserModel user) {
    _user = user;
    notifyListeners(); // Powiadomienie słuchaczy o zmianie
  }

  // Metoda do czyszczenia danych użytkownika
  void clearUser() {
    _user = null;
    notifyListeners(); // Powiadomienie słuchaczy o zmianie
  }

  // Metoda do sprawdzenia, czy użytkownik jest zalogowany
  bool get isLoggedIn => _user != null;
}



