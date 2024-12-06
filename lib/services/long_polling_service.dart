import 'dart:convert';
import 'package:http/http.dart' as http;

class LongPollingService {
  final String serverUrl;

  LongPollingService({required this.serverUrl});

  // Funkcja do wysyłania żądań long polling do serwera
  Future<void> startListening() async {
    while (true) {
      try {
        // Wysłanie zapytania do serwera (ustawienie w odpowiedzi długiego oczekiwania)
        final response = await http.get(Uri.parse(serverUrl));

        if (response.statusCode == 200) {
          // Przetwórz odpowiedź
          final data = jsonDecode(response.body);
          handleServerResponse(data);
        } else {
          print('Błąd serwera: ${response.statusCode}');
        }
      } catch (e) {
        print('Błąd połączenia: $e');
      }

      // Możesz dodać pewien interwał, żeby nie wysyłać zapytań za często
      await Future.delayed(Duration(seconds: 5));
    }
  }

  // Przykładowa metoda do obsługi odpowiedzi z serwera
  void handleServerResponse(Map<String, dynamic> data) {
    if (data['type'] == 'message') {
      print('Otrzymano wiadomość: ${data['message']}');
    }
    // Zrób coś z odpowiedzią
  }


  Future<void> startVoiceCall(
      String callerId,
      String receiverId,
      String callerUsername,
      String callerPhotoUrl) async {
    final callData = {
      'caller_id': callerId,
      'receiver_id': receiverId,
      'call_type': 'voice',
      'status': 'initiated', // Połączenie zostało rozpoczęte
      'created_at': DateTime.now().toIso8601String(), // Czas stworzenia połączenia
      'start_time': DateTime.now().toIso8601String(), // Czas rozpoczęcia
      'end_time': '', // Później zostanie wypełnione
      'caller_username': callerUsername,
      'caller_photo_url': callerPhotoUrl,
    };

    // Wydrukowanie danych przed wysłaniem
    print('Dane połączenia: $callData');

    try {
      // Wysłanie danych do API
      final response = await http.post(
        Uri.parse('https://lesmind.com/api/calls/voice_call.php'), // Adres do voice_call.php
        headers: {
          'Content-Type': 'application/json', // Nagłówek wskazujący, że wysyłamy JSON
        },
        body: json.encode(callData), // Konwertujemy dane na JSON
      );

      if (response.statusCode == 200) {
        // Sukces - odprawienie połączenia
        print('Połączenie głosowe rozpoczęte');
        print('Odpowiedź z serwera: ${response.body}');
      } else {
        // Obsługa błędów
        print('Błąd przy rozpoczynaniu połączenia głosowego: ${response.body}');
      }
    } catch (e) {
      // Obsługa wyjątków
      print('Wystąpił błąd podczas wysyłania połączenia: $e');
    }
  }

  Future<void> startVideoCall(
      String callerId,
      String receiverId,
      String callerUsername,
      String callerPhotoUrl
      ) async {
    // Przykład: tworzymy dane do wysłania
    final callData = {
      'caller_id': callerId,
      'receiver_id': receiverId,
      'call_type': 'video',
      'status': 'initiated',  // Połączenie zostało rozpoczęte
      'created_at': DateTime.now().toIso8601String(),  // Czas stworzenia połączenia
      'start_time': DateTime.now().toIso8601String(),  // Czas rozpoczęcia
      'end_time': '',  // Później zostanie wypełnione
      'caller_username': callerUsername,
      'caller_photo_url': callerPhotoUrl,
    };

    // Wysłanie danych do API
    final response = await http.post(
      Uri.parse('https://lesmind.com/api/calls/video_call.php'), // Adres do video_call.php
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: callData,
    );

    if (response.statusCode == 200) {
      // Sukces - odprawienie połączenia
      print('Połączenie wideo rozpoczęte');
    } else {
      // Obsługa błędów
      print('Błąd przy rozpoczynaniu połączenia wideo: ${response.body}');
    }
  }

  // Future<void> listenForCalls(String userId) async {
  //   while (true) {
  //     final response = await http.post(
  //       Uri.parse('https://lesmind.com/api/calls/check_call.php'),
  //       body: {
  //         'user_id': userId,
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       if (data['call_status'] == 'incoming') {
  //         // Odbieranie połączenia głosowego
  //         print('Połączenie przychodzące! Akceptuję połączenie...');
  //         // Inicjalizowanie połączenia głosowego lub video
  //         break; // zakończyć nasłuchiwanie po odebraniu połączenia
  //       }
  //     } else {
  //       print('Błąd podczas nasłuchiwania');
  //     }
  //
  //     await Future.delayed(Duration(seconds: 2)); // Opóźnienie przed ponownym zapytaniem
  //   }
  // }

  Future<void> listenForIncomingCalls(String receiverId) async {
    while (true) {
      final response = await http.post(
        Uri.parse('https://lesmind.com/api/calls/check_call.php'), // Endpoint do sprawdzania połączeń
        body: {
          'user_id': receiverId,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['call_status'] == 'incoming') {
          // Wyświetl powiadomienie lub rozpocznij połączenie
          print('Połączenie przychodzące od: ${data['caller_username']}');
          // Tutaj możesz dodać logikę do rozpoczęcia połączenia, np. wyświetlenie przycisku 'Odbierz połączenie'
        } else if (data['call_status'] == 'no_call') {
          print('Brak połączenia');
        }
      } else {
        print('Błąd podczas sprawdzania połączeń');
      }

      await Future.delayed(Duration(seconds: 3)); // Sprawdzenie co 3 sekundy
    }
  }


  void endCall(String sessionId) async {
    final response = await http.post(
      Uri.parse('https://lesmind.com/api/calls/end_call.php'),
      body: {
        'session_id': sessionId,
      },
    );

    if (response.statusCode == 200) {
      print('Połączenie zakończone');
    } else {
      print('Błąd podczas kończenia połączenia');
    }
  }



}
