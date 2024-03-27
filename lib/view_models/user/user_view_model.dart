import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserViewModel extends ChangeNotifier {
  User? _user;
  FirebaseAuth _auth = FirebaseAuth.instance;

  User? get user => _user;

  Future<void> setUser() async {
    _user = _auth.currentUser;
    // Nie wywołuj notifyListeners() tutaj
  }
}
