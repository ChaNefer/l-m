import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:les_social/models/message.dart';
import 'package:les_social/utils/firebase.dart';

class ChatService {
  FirebaseStorage storage = FirebaseStorage.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(Message message, String chatId) async {
    try {
      // Sprawdź, czy istnieje dokument czatu w kolekcji newChat
      DocumentReference newChatDocRef = _firestore.collection('chats').doc(chatId);
      bool newChatExists = await newChatDocRef.get().then((doc) => doc.exists);

      if (!newChatExists) {
        // Utwórz dokument czatu w kolekcji newChat, jeśli nie istnieje
        await newChatDocRef.set({});
      }

      // Dodaj wiadomość do kolekcji messages wewnątrz kolekcji newChat
      await newChatDocRef.collection('messages').add(message.toJson());
      print('Message sent successfully.');
    } catch (e) {
      print('Error sending message: $e');
    }
  }




  Future<String> sendFirstMessage(User sender, User receiver, Message message) async {
    try {
      String chatId = _generateChatId(sender.uid, receiver.uid);
      DocumentReference chatDocRef = _firestore.collection('chats').doc(chatId);

      // Sprawdź, czy dokument czatu istnieje
      bool chatExists = await chatDocRef.get().then((doc) => doc.exists);

      // Jeśli dokument nie istnieje, utwórz go
      if (!chatExists) {
        await chatDocRef.set({});
      }

      // Dodaj pierwszą wiadomość do podkolekcji 'messages'
      await chatDocRef.collection('messages').add(message.toJson());
      print('First message sent successfully.');

      return chatId;
    } catch (e) {
      print('Error sending first message: $e');
      return '';
    }
  }

  String _generateChatId(String user1, String user2) {
    List<String> users = [user1, user2];
    users.sort();
    return "${users[0]}-${users[1]}";
  }

  Future<String> uploadImage(File image, String chatId) async {
    Reference storageReference =
        storage.ref().child("chats").child(chatId).child(uuid.v4());
    UploadTask uploadTask = storageReference.putFile(image);
    await uploadTask.whenComplete(() => null);
    String imageUrl = await storageReference.getDownloadURL();
    return imageUrl;
  }

//determine if a user has read a chat and updates how many messages are unread
  Future<void> setUserRead(String chatId, User user, int count) async {
    try {
      print('Setting user read for chatId: $chatId');

      // Pobierz dokument czatu
      DocumentSnapshot snap = await _firestore.collection('chats').doc(chatId).get();

      // Sprawdź, czy dokument czatu istnieje
      if (!snap.exists) {
        print('Document $chatId does not exist.');
        return;
      }

      // Aktualizuj informacje o przeczytanych wiadomościach
      Map<String, dynamic>? data = snap.data() as Map<String, dynamic>?; // Rzutujemy na Map<String, dynamic>
      Map<String, dynamic> reads = data?['reads'] as Map<String, dynamic>? ?? {}; // Rzutujemy na Map<String, dynamic> i obsługujemy null
      reads[user.uid!] = count;
      await _firestore.collection('chats').doc(chatId).update({'reads': reads});

      print('User read set successfully.');
    } catch (e) {
      print('Error setting user read: $e');
    }
  }


//determine when a user has start typing a messageFuture<void>
  Future<void> setUserTyping(String chatId, User user, bool typing) async {
    try {
      print('Setting user typing for chatId: $chatId');
      DocumentReference chatDocRef = _firestore.collection('chats').doc(chatId);
      await chatDocRef.update({'typing.${user.uid}': typing});
      print('User typing status updated successfully.');
    } catch (e) {
      print('Error setting user typing: $e');
    }
  }

}
