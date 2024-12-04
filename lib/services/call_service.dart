import 'dart:convert';
import 'package:http/http.dart' as http;

class CallService {
  final String baseUrl = 'https://lesmind.com/api';

  // Metoda do inicjowania połączenia głosowego
  Future<Map<String, dynamic>> initiateAudioCall(String callerId, String receiverId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/calls/voice_call.php'),
      body: {
        'caller_id': callerId,
        'receiver_id': receiverId,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Zwróć dane z backendu (session_id i token)
    } else {
      throw Exception('Failed to start audio call');
    }
  }

  // Metoda do inicjowania połączenia wideo
  Future<Map<String, dynamic>> initiateVideoCall(String callerId, String receiverId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/calls/video_call.php'),
      body: {
        'caller_id': callerId,
        'receiver_id': receiverId,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Zwróć dane z backendu (session_id i token)
    } else {
      throw Exception('Failed to start video call');
    }
  }
}



