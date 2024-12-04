// import 'dart:convert';
// import 'dart:io';
//
// class WebSocketService {
//   late WebSocket _webSocket;
//
//   // Połączenie z serwerem WebSocket
//   void connect() async {
//     _webSocket = await WebSocket.connect('ws://lesmind.com:8080');
//     _webSocket.listen((data) {
//       _onMessageReceived(data);
//     });
//   }
//
//   // Odbiór wiadomości
//   void _onMessageReceived(String message) {
//     var decodedMessage = jsonDecode(message);
//     if (decodedMessage['type'] == 'call') {
//       String callerId = decodedMessage['callerId'];
//       String callType = decodedMessage['callType'];
//
//       // Wyświetlanie powiadomienia o połączeniu przychodzącym
//       showIncomingCallNotification(callerId, callType);
//     }
//   }
//
//   // Funkcja do wyświetlenia powiadomienia o połączeniu
//   void showIncomingCallNotification(String callerId, String callType) {
//     // Możesz dodać tutaj logikę do pokazania powiadomienia
//     print('Połączenie przychodzące od $callerId ($callType)');
//   }
// }
//
//
//
import 'dart:convert';
import 'dart:io';

class WebSocketService {
  late WebSocket _webSocket;

  // Funkcja do inicjalizacji WebSocket
  Future<void> connect(String userId) async {
    _webSocket = await WebSocket.connect('ws://lesmind.com:8080');
    _webSocket.listen((data) {
      _onMessageReceived(data);
    });

    // Wyślij wiadomość rejestracji
    _sendMessage({
      'type': 'register',
      'userId': userId,
    });
  }

  // Funkcja do obsługi odebranych wiadomości
  void _onMessageReceived(String message) {
    var decodedMessage = jsonDecode(message);
    switch (decodedMessage['type']) {
      case 'call':
        showIncomingCallNotification(
          decodedMessage['callerId'],
          decodedMessage['callType'],
        );
        break;

      case 'offer':
      // Obsługa oferty SDP
        handleOffer(decodedMessage);
        break;

      case 'answer':
      // Obsługa odpowiedzi SDP
        handleAnswer(decodedMessage);
        break;

      case 'ice-candidate':
      // Obsługa kandydata ICE
        handleIceCandidate(decodedMessage);
        break;

      default:
        print('Nieznany typ wiadomości: ${decodedMessage['type']}');
    }
  }

  // Wysyłanie wiadomości do serwera WebSocket
  void _sendMessage(Map<String, dynamic> message) {
    _webSocket.add(jsonEncode(message));
  }

  // Wyświetlanie powiadomienia o połączeniu przychodzącym
  void showIncomingCallNotification(String callerId, String callType) {
    print('Połączenie przychodzące od $callerId ($callType)');
    // Możesz tutaj dodać kod do pokazania UI z informacją o połączeniu
  }

  // Wysyłanie oferty SDP
  void sendOffer(String targetUserId, String sdp) {
    _sendMessage({
      'type': 'offer',
      'targetUserId': targetUserId,
      'sdp': sdp,
    });
  }

  // Wysyłanie odpowiedzi SDP
  void sendAnswer(String targetUserId, String sdp) {
    _sendMessage({
      'type': 'answer',
      'targetUserId': targetUserId,
      'sdp': sdp,
    });
  }

  // Wysyłanie kandydata ICE
  void sendIceCandidate(String targetUserId, Map<String, dynamic> candidate) {
    _sendMessage({
      'type': 'ice-candidate',
      'targetUserId': targetUserId,
      'candidate': candidate,
    });
  }

  // Obsługa oferty SDP
  void handleOffer(Map<String, dynamic> offer) {
    String sdp = offer['sdp'];
    String callerId = offer['from'];

    print('Otrzymano ofertę SDP od $callerId');
    // Tutaj dodasz kod do ustawienia SDP w WebRTC
  }

  // Obsługa odpowiedzi SDP
  void handleAnswer(Map<String, dynamic> answer) {
    String sdp = answer['sdp'];
    String responderId = answer['from'];

    print('Otrzymano odpowiedź SDP od $responderId');
    // Tutaj dodasz kod do ustawienia SDP w WebRTC
  }

  // Obsługa kandydata ICE
  void handleIceCandidate(Map<String, dynamic> candidateMessage) {
    Map<String, dynamic> candidate = candidateMessage['candidate'];
    String userId = candidateMessage['from'];

    print('Otrzymano kandydata ICE od $userId');
    // Dodaj kandydata ICE do WebRTC
  }
}



