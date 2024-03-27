import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> init() async {
    // Ustawia handler dla wiadomości fona
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Ustawia handler dla wiadomości w trakcie działania aplikacji
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Wiadomość otrzymana: ${message.notification!.title}");
      // Wyświetl powiadomienie o nowej wiadomości
    });

    // Ustawia handler dla wiadomości, gdy aplikacja jest w tle, ale nie jest zamknięta
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Aplikacja otwarta z powiadomienia: ${message.notification!.title}");
      // Przejdź do odpowiedniego ekranu lub wykonaj odpowiednie działania w zależności od wiadomości
    });

    // Pobierz token urządzenia
    String? token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");
    // Wyślij token do serwera aplikacji, aby mógł wysyłać powiadomienia push
  }

  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("Handling a background message: ${message.messageId}");
    // Obsługa wiadomości przychodzącej, gdy aplikacja jest w tle lub zamknięta
  }
}
