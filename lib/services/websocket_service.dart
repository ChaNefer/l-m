import 'dart:async';
import 'dart:convert';
import 'dart:io';

class WebSocketService {
  WebSocket? _webSocket;
  final _streamController = StreamController<dynamic>.broadcast();
  String? _currentUserId;

  Stream<dynamic> get messageStream => _streamController.stream;

  Future<void> connect(String userId) async {
    try {
      _currentUserId = userId;
      _webSocket = await WebSocket.connect('wss://lesmind.com/api/calls/web_socket_server.php')
          .timeout(Duration(seconds: 10));

      _webSocket?.listen(
            (data) {
          try {
            final parsedData = json.decode(data);
            _streamController.add(parsedData);
            _processMessage(parsedData);
          } catch (e) {
            print('Error parsing WebSocket message: $e');
          }
        },
        onDone: () {
          print('WebSocket connection closed');
          _reconnect();
        },
        onError: (error) {
          print('WebSocket error: $error');
          _reconnect();
        },
      );

      _sendRegistration();
    } on TimeoutException {
      print('Connection timeout');
      _reconnect();
    } catch (e) {
      print('WebSocket connection error: $e');
      _reconnect();
    }
  }

  void _sendRegistration() {
    if (_currentUserId != null) {
      sendMessage({
        'type': 'register',
        'userId': _currentUserId,
      });
    }
  }

  void _processMessage(Map<String, dynamic> message) {
    switch (message['type']) {
      case 'call':
        _handleIncomingCall(message);
        break;
      case 'offer':
        _handleOffer(message);
        break;
      case 'answer':
        _handleAnswer(message);
        break;
      case 'ice-candidate':
        _handleIceCandidate(message);
        break;
    }
  }

  void _handleIncomingCall(Map<String, dynamic> message) {
    // Logika obsługi połączenia przychodzącego
    print('Incoming call from: ${message['callerId']}');
  }

  void _handleOffer(Map<String, dynamic> offer) {
    // Logika obsługi oferty WebRTC
    print('Received WebRTC offer');
  }

  void _handleAnswer(Map<String, dynamic> answer) {
    // Logika obsługi odpowiedzi WebRTC
    print('Received WebRTC answer');
  }

  void _handleIceCandidate(Map<String, dynamic> candidate) {
    // Logika obsługi kandydatów ICE
    print('Received ICE candidate');
  }

  void sendMessage(Map<String, dynamic> message) {
    try {
      if (_webSocket != null && _webSocket!.readyState == WebSocket.open) {
        _webSocket!.add(json.encode(message));
      } else {
        print('WebSocket not connected');
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  void _reconnect() {
    Future.delayed(Duration(seconds: 5), () {
      if (_currentUserId != null) {
        connect(_currentUserId!);
      }
    });
  }

  void close() {
    _webSocket?.close();
    _streamController.close();
  }
}