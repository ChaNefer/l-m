// // import 'dart:async';
// // import 'dart:convert';
// // import 'dart:io';
// //
// // class WebSocketService {
// //   WebSocket? _webSocket;
// //   final _streamController = StreamController<dynamic>.broadcast();
// //   String? _currentUserId;
// //
// //   Stream<dynamic> get messageStream => _streamController.stream;
// //
// //   Future<void> connect(String userId) async {
// //     try {
// //       _currentUserId = userId;
// //       _webSocket = await WebSocket.connect('wss://lesmind.com/api/calls/web_socket_server.php')
// //           .timeout(Duration(seconds: 10));
// //
// //       _webSocket?.listen(
// //             (data) {
// //           try {
// //             final parsedData = json.decode(data);
// //             _streamController.add(parsedData);
// //             _processMessage(parsedData);
// //           } catch (e) {
// //             print('Error parsing WebSocket message: $e');
// //           }
// //         },
// //         onDone: () {
// //           print('WebSocket connection closed');
// //           _reconnect();
// //         },
// //         onError: (error) {
// //           print('WebSocket error: $error');
// //           _reconnect();
// //         },
// //       );
// //
// //       _sendRegistration();
// //     } on TimeoutException {
// //       print('Connection timeout');
// //       _reconnect();
// //     } catch (e) {
// //       print('WebSocket connection error: $e');
// //       _reconnect();
// //     }
// //   }
// //
// //   void _sendRegistration() {
// //     if (_currentUserId != null) {
// //       sendMessage({
// //         'type': 'register',
// //         'userId': _currentUserId,
// //       });
// //     }
// //   }
// //
// //   void _processMessage(Map<String, dynamic> message) {
// //     switch (message['type']) {
// //       case 'call':
// //         _handleIncomingCall(message);
// //         break;
// //       case 'offer':
// //         _handleOffer(message);
// //         break;
// //       case 'answer':
// //         _handleAnswer(message);
// //         break;
// //       case 'ice-candidate':
// //         _handleIceCandidate(message);
// //         break;
// //     }
// //   }
// //
// //   void _handleIncomingCall(Map<String, dynamic> message) {
// //     final callerId = message['sender_id'];
// //     final receiverId = message['receiver_id'];
// //
// //     if (receiverId == _currentUserId) {
// //       print('Incoming call from: $callerId');
// //       _streamController.add(message);
// //     } else {
// //       print('Message not for this user.');
// //     }
// //   }
// //
// //
// //   void _handleOffer(Map<String, dynamic> offer) {
// //     // Logika obsługi oferty WebRTC
// //     print('Received WebRTC offer');
// //   }
// //
// //   void _handleAnswer(Map<String, dynamic> answer) {
// //     // Logika obsługi odpowiedzi WebRTC
// //     print('Received WebRTC answer');
// //   }
// //
// //   void _handleIceCandidate(Map<String, dynamic> candidate) {
// //     // Logika obsługi kandydatów ICE
// //     print('Received ICE candidate');
// //   }
// //
// //   void sendMessage(Map<String, dynamic> message) {
// //     if (_webSocket != null && _webSocket!.readyState == WebSocket.open) {
// //       message['sender_id'] = _currentUserId; // Dodanie caller_id
// //       _webSocket!.add(json.encode(message));
// //     } else {
// //       print('WebSocket not connected');
// //     }
// //   }
// //
// //
// //   void _reconnect() {
// //     Future.delayed(Duration(seconds: 5), () {
// //       if (_currentUserId != null) {
// //         connect(_currentUserId!);
// //       }
// //     });
// //   }
// //
// //   void close() {
// //     _webSocket?.close();
// //     _streamController.close();
// //   }
// // }
//
// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
//
// class WebSocketService {
//   WebSocket? _webSocket;
//   final _streamController = StreamController<dynamic>.broadcast();
//   String? _currentUserId;
//   static final Map<String, WebSocket> _activeUsers = {}; // Mapa aktywnych użytkowników
//
//   Stream<dynamic> get messageStream => _streamController.stream;
//
//   Future<void> connect(String userId) async {
//     try {
//       _currentUserId = userId;
//       _webSocket = await WebSocket.connect('wss://lesmind.com/api/calls/web_socket_server.php')
//           .timeout(Duration(seconds: 10));
//
//       _webSocket?.listen(
//             (data) {
//           try {
//             final parsedData = json.decode(data);
//             _streamController.add(parsedData);
//             _processMessage(parsedData);
//           } catch (e) {
//             print('Error parsing WebSocket message: $e');
//           }
//         },
//         onDone: () {
//           print('WebSocket connection closed');
//           _reconnect();
//         },
//         onError: (error) {
//           print('WebSocket error: $error');
//           _reconnect();
//         },
//       );
//
//       _registerUser(); // Rejestracja użytkownika po połączeniu
//     } on TimeoutException {
//       print('Connection timeout');
//       _reconnect();
//     } catch (e) {
//       print('WebSocket connection error: $e');
//       _reconnect();
//     }
//   }
//
//   // Funkcja rejestrująca użytkownika w aktywnych połączeniach
//   void _registerUser() {
//     if (_currentUserId != null && _webSocket != null) {
//       _activeUsers[_currentUserId!] = _webSocket!; // Dodanie użytkownika do mapy
//       print('User $_currentUserId registered');
//     }
//   }
//
//   void _processMessage(Map<String, dynamic> message) {
//     switch (message['type']) {
//       case 'call':
//         _handleIncomingCall(message);
//         break;
//       case 'offer':
//         _handleOffer(message);
//         break;
//       case 'answer':
//         _handleAnswer(message);
//         break;
//       case 'ice-candidate':
//         _handleIceCandidate(message);
//         break;
//     }
//   }
//
//   // Funkcja obsługująca przychodzące połączenie
//   void _handleIncomingCall(Map<String, dynamic> message) {
//     final callerId = message['sender_id'];
//     final receiverId = message['receiver_id'];
//
//     if (_currentUserId == receiverId) {
//       print('Incoming call from: $callerId');
//       _streamController.add(message); // Wysyłanie wiadomości do użytkownika
//     } else {
//       print('Message not for this user.');
//     }
//   }
//
//   // Funkcja wysyłająca wiadomości do konkretnych użytkowników
//   void sendMessage(Map<String, dynamic> message) {
//     final receiverId = message['receiver_id']; // Odbiorca wiadomości
//     if (_activeUsers.containsKey(receiverId)) {
//       final receiverSocket = _activeUsers[receiverId];
//       if (receiverSocket != null && receiverSocket.readyState == WebSocket.open) {
//         receiverSocket.add(json.encode(message)); // Wysłanie wiadomości do odbiorcy
//       } else {
//         print('WebSocket for user $receiverId not connected');
//       }
//     } else {
//       print('Receiver not registered');
//     }
//   }
//
//   // Funkcje obsługujące WebRTC (Oferta, Odpowiedź, ICE)
//   void _handleOffer(Map<String, dynamic> offer) {
//     print('Received WebRTC offer');
//   }
//
//   void _handleAnswer(Map<String, dynamic> answer) {
//     print('Received WebRTC answer');
//   }
//
//   void _handleIceCandidate(Map<String, dynamic> candidate) {
//     print('Received ICE candidate');
//   }
//
//   // Funkcja ponownego połączenia
//   void _reconnect() {
//     Future.delayed(Duration(seconds: 5), () {
//       if (_currentUserId != null) {
//         connect(_currentUserId!);
//       }
//     });
//   }
//
//   // Funkcja zamykająca połączenie WebSocket
//   void close() {
//     _webSocket?.close();
//     _streamController.close();
//     if (_currentUserId != null) {
//       _activeUsers.remove(_currentUserId); // Usunięcie użytkownika z mapy
//     }
//   }
// }
