// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
//
// class WebSocketManager {
//   WebSocket? _webSocket;
//   String? _currentUserId;
//   final StreamController _streamController = StreamController();
//
//   WebSocketManager();
//
//   Future<void> connect(String userId) async {
//     try {
//       _currentUserId = userId;
//       _webSocket = await WebSocket.connect('wss://lesmind.com/api/calls/web_socket_server.php')
//           .timeout(Duration(seconds: 10));
//
//       print("WebSocket connected for user $userId");
//
//       _webSocket?.listen(
//             (data) {
//           final parsedData = json.decode(data);
//           _streamController.add(parsedData);  // Przesyłanie odebranej wiadomości do strumienia
//           print("Received data: $parsedData");
//         },
//         onDone: () {
//           print("WebSocket connection closed");
//         },
//         onError: (error) {
//           print("WebSocket error: $error");
//         },
//       );
//
//       _sendRegistration();
//     } catch (e) {
//       print('Error connecting to WebSocket: $e');
//     }
//   }
//
//   // Wysłanie powiadomienia przez WebSocket
//   void sendMessage(Map<String, dynamic> message) {
//     if (_webSocket != null && _webSocket!.readyState == WebSocket.open) {
//       _webSocket!.add(json.encode(message));  // Wysyłanie wiadomości
//       print("Message sent: $message");
//     } else {
//       print("WebSocket is not connected");
//     }
//   }
//
//   // Metoda rejestracji użytkownika na WebSocket (jeśli potrzebujesz)
//   void _sendRegistration() {
//     // Przykład: Wysyłanie ID użytkownika do serwera
//     if (_currentUserId != null) {
//       sendMessage({
//         'action': 'register',
//         'user_id': _currentUserId,
//       });
//     }
//   }
//
//   Stream get stream => _streamController.stream;
// }
