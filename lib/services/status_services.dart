import 'dart:io';
import 'package:flutter/material.dart';
import 'package:les_social/models/status.dart';
import 'package:les_social/services/user_service.dart';
import 'package:uuid/uuid.dart';

class StatusService {
  final Uuid uuid = Uuid();
  late UserService userService; // Przykładowa klasa UserService

  StatusService(BuildContext context) {
    userService = UserService(context);
  }

  void showSnackBar(String value, context) {
    // Implementacja snackbara w zależności od Twojej aplikacji
  }

  Future<void> sendStatus(StatusModel status, String chatId) async {
    // Przykładowe wysłanie statusu do Twojego backendu
    // Implementacja zależy od Twojego backendu
  }

  Future<String> sendFirstStatus(StatusModel status) async {
    // Przykładowe wysłanie pierwszego statusu do Twojego backendu
    // Implementacja zależy od Twojego backendu
    return 'null';
  }

  Future<String> uploadImage(File image) async {
    // Przykładowe przesyłanie obrazu do Twojego backendu
    // Implementacja zależy od Twojego backendu
    return 'null';
  }
}
