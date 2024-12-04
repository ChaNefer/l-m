import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:les_social/models/message.dart';
import 'package:les_social/services/auth_service.dart';
import 'package:les_social/services/chat_service.dart';

import '../../chats/recent_chats.dart';
import '../../models/user.dart';

class ConversationViewModel extends ChangeNotifier {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  ChatService chatService = ChatService();
  AuthService _authService = AuthService();
  bool uploadingImage = false;
  final picker = ImagePicker();
  File? image;
  String? _userId;
  String? get userId => _userId;

  ConversationViewModel() {
  }

  void setUserId(String userId) {
    _userId = userId;
    notifyListeners();
  }

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


  // Future<void> sendMessage(String chatId, Message message) async {
  //   try {
  //     await chatService.sendMessage(message, chatId);
  //   } catch (e) {
  //     //print('Error sending message: $e');
  //     // Handle error accordingly
  //   }
  // }

  // Future<String> sendFirstMessage(String recipient, Message message) async {
  //   try {
  //     String newChatId = await chatService.sendFirstMessage(message as String, recipient as Message);
  //     return newChatId;
  //   } catch (e) {
  //     //print('Error sending first message: $e');
  //     // Handle error accordingly
  //     return '';
  //   }
  // }

  void setReadCount(String chatId, var user, int count) {
    chatService.setUserRead(chatId, user, count);
  }

  void setUserTyping(String chatId, var user, bool typing) {
    chatService.setUserTyping(chatId, user, typing);
  }

  Future<String> pickImage({int? source, BuildContext? context, String? chatId}) async {
    try {
      XFile? pickedFile = await (source == 0
          ? picker.pickImage(
        source: ImageSource.camera,
      )
          : picker.pickImage(
        source: ImageSource.gallery,
      ));

      if (pickedFile == null) return '';

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
            toolbarTitle: 'Przytnij zdjęcie',
            toolbarColor: Theme.of(context!).appBarTheme.backgroundColor!,
            toolbarWidgetColor: Theme.of(context).iconTheme.color!,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            minimumAspectRatio: 1.0,
          ),
        ],
      );

      if (croppedFile == null) return '';

      Navigator.of(context!).pop();

      uploadingImage = true;
      image = File(croppedFile.path);
      notifyListeners();
      showInSnackBar("Uploading image...", context);

      String imageUrl = await chatService.uploadImage(image!, chatId!);

      uploadingImage = false;
      notifyListeners();

      return imageUrl;
    } catch (e) {
      //print('Error picking image: $e');
      // Handle error accordingly
      return '';
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

  Stream<List<Message>> getMessagesStream(String chatId) {
    return chatService.getMessageStream(chatId);
  }

  Stream<List> getChatStream(String chatId) {
    return chatService.getUserChatsStream(chatId);
  }

  Stream<List<Message>> messageListStream(String chatId) {
    // Implementacja pobierania strumienia wiadomości
    // Może to być np. strumień z Firebase, zależnie od Twojego backendu
    return chatService.getMessageStream(chatId);
  }
}
