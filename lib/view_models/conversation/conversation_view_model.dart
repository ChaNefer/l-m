import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:les_social/models/message.dart';
import 'package:les_social/services/chat_service.dart';

import '../../utils/firebase.dart';

class ConversationViewModel extends ChangeNotifier {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  ChatService chatService = ChatService();
  bool uploadingImage = false;
  final picker = ImagePicker();
  File? image;

  sendMessage(String chatId, Message message) {
    chatService.sendMessage(
      message,
      chatId,
    );
  }

  // Metoda do tworzenia czatu, jeśli nie istnieje
  Future<void> createChatIfNotExists(String chatId, String userId, String conversationContent) async {
    try {
      print('Creating chat document with ID: $chatId');

      // Sprawdzamy, czy dokument czatu istnieje w bazie danych
      final chatSnapshot = await chatRef.doc(chatId).get();
      if (!chatSnapshot.exists) {
        print('Chat document with ID $chatId does not exist, creating...');
        await chatRef.doc(chatId).set({
          'userId': userId,
          'conversation': conversationContent,
          'nazwa': 'wartość', // Przykładowe dodanie pola 'nazwa'
        });
        print('Chat document created successfully!');
      } else {
        print('Chat document with ID $chatId already exists!');
      }
    } catch (e) {
      // Obsługujemy ewentualny błąd
      print('Error creating chat document: $e');
    }
  }

  // Metoda do wysyłania pierwszej wiadomości w czacie
  Future<String> sendFirstMessage(String userId, Message message) async {
    // Utwórz identyfikator czatu na podstawie danych użytkowników
    String chatId = getUser(firebaseAuth.currentUser!.uid, userId);
    // Logika wysyłania pierwszej wiadomości
    await createChatIfNotExists(chatId, userId, "rozmowa...");
    await sendMessage(chatId, message); // Wyślij pierwszą wiadomość
    return chatId; // Zwróć identyfikator nowego czatu
  }

  // Metoda do tworzenia identyfikatora czatu na podstawie danych użytkowników
  String getUser(String user1, String user2) {
    user1 = user1.substring(0, 5);
    user2 = user2.substring(0, 5);
    List<String> list = [user1, user2];
    list.sort();
    return "${list[0]}-${list[1]}";
  }

  setReadCount(String chatId, var user, int count) {
    chatService.setUserRead(chatId, user, count);
  }

  setUserTyping(String chatId, var user, bool typing) {
    chatService.setUserTyping(chatId, user, typing);
  }

  pickImage({int? source, BuildContext? context, String? chatId}) async {
    XFile? pickedFile = await (source == 0
        ? picker.pickImage(
      source: ImageSource.camera,
    ) // 2208 x 1242px
        : picker.pickImage(
      source: ImageSource.gallery,
    ));

    if (pickedFile != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Przytnij zdjęcie ',
            toolbarColor: Theme.of(context!).appBarTheme.backgroundColor,
            toolbarWidgetColor: Theme.of(context).iconTheme.color,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            minimumAspectRatio: 1.0,
          ),
        ],
      );

      Navigator.of(context).pop();

      if (croppedFile != null) {
        uploadingImage = true;
        image = File(croppedFile.path);
        notifyListeners();
        showInSnackBar("Uploading image...", context);
        String imageUrl = await chatService.uploadImage(image!, chatId!);
        return imageUrl;
      }
    }
  }

  void showInSnackBar(String value, context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value),
      ),
    );
  }
}
