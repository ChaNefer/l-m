// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// class WebRTCService {
//   final String baseUrl = 'https://lesmind.com/api';
//
//   // Tworzenie połączenia (Audio/Video)
//   RTCPeerConnection? _peerConnection;
//   MediaStream? _localStream;
//   MediaStream? _remoteStream;
//
//   // Ogólna metoda inicjująca połączenie
//   // Future<Map<String, dynamic>> initiateCall(String callerId, String receiverId, String callType, String callerPhotoUrl, String callerUsername) async {
//   //   final endpoint = callType == 'audio' ? 'voice_call.php' : 'video_call.php';
//   //   final response = await http.post(
//   //     Uri.parse('$baseUrl/calls/$endpoint'),
//   //     body: {
//   //       'caller_id': callerId,
//   //       'receiver_id': receiverId,
//   //       'caller_photo_url': callerPhotoUrl,
//   //       'caller_username': callerUsername,
//   //     },
//   //   );
//   //
//   //   if (response.statusCode == 200) {
//   //     return json.decode(response.body); // Dane session_id i token
//   //   } else {
//   //     throw Exception('Failed to initiate $callType call');
//   //   }
//   // }
//
//   Future<Map<String, dynamic>> initiateCall(
//       String callerId,
//       String receiverId,
//       String callType,
//       String callerPhotoUrl,
//       String callerUsername
//       ) async {
//     print('Initiating call...');
//     print('Caller ID: $callerId');
//     print('Receiver ID: $receiverId');
//     print('Caller Username: $callerUsername');
//     print('Caller Photo URL: $callerPhotoUrl');
//     print('Call Type: $callType');
//
//     final endpoint = callType == 'audio' ? 'voice_call.php' : 'video_call.php';
//     final response = await http.post(
//       Uri.parse('$baseUrl/calls/$endpoint'),
//       body: {
//         'caller_id': callerId,
//         'receiver_id': receiverId,
//         'caller_photo_url': callerPhotoUrl,
//         'caller_username': callerUsername,
//       },
//     );
//
//     print('Response status code: ${response.statusCode}');
//     print('Response body: ${response.body}');
//
//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       throw Exception('Failed to initiate $callType call');
//     }
//   }
//
//   Future<void> sendCallNotification({
//     required String receiverId,
//     required String callType,
//     required String sessionId,
//     required String callerId,
//     required String callerUsername,
//     required String callerPhotoUrl,
//   }) async {
//     // Adres URL endpointu PHP
//     final String url = 'https://lesmind.com/api/calls/send_call_notification.php';
//
//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         body: {
//           'receiver_id': receiverId,
//           'call_type': callType,
//           'session_id': sessionId,
//           'caller_id': callerId,
//           'caller_username': callerUsername,
//           'caller_photo_url': callerPhotoUrl,
//         },
//       );
//
//       // Sprawdzanie odpowiedzi z serwera
//       if (response.statusCode == 200) {
//         final responseBody = jsonDecode(response.body);
//         if (responseBody['status'] == 'success') {
//           print('Notification sent successfully');
//         } else {
//           print('Failed to send notification: ${responseBody['message']}');
//         }
//       } else {
//         print('Failed to send request. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error sending call notification: $e');
//     }
//   }
//
//
//
//   // Rozpoczynanie połączenia
//   Future<void> _startCall(String callType, String sessionId, String token) async {
//     // Tworzenie połączenia
//     _peerConnection = await _createPeerConnection();
//
//     // Dodanie strumienia lokalnego (audio/video)
//     _localStream = await _getUserMedia(callType);
//     _localStream?.getTracks().forEach((track) {
//       _peerConnection?.addTrack(track, _localStream!);
//     });
//
//     // Wysyłanie ofert do odbiorcy
//     RTCSessionDescription description = await _peerConnection!.createOffer();
//     await _peerConnection!.setLocalDescription(description);
//
//     // Wysyłanie oferty do backendu
//     await _sendSignal(sessionId, token, description);
//   }
//
//   // Tworzenie PeerConnection
//   Future<RTCPeerConnection> _createPeerConnection() async {
//     final configuration = {
//       'iceServers': [
//         {'urls': 'stun:stun.l.google.com:19302'},
//       ],
//     };
//
//     return await createPeerConnection(configuration);
//   }
//
//   // Pobieranie strumienia lokalnego (audio/video)
//   Future<MediaStream> _getUserMedia(String callType) async {
//     final mediaConstraints = callType == 'audio'
//         ? {'audio': true, 'video': false}
//         : {'audio': true, 'video': true};
//
//     return await navigator.mediaDevices.getUserMedia(mediaConstraints);
//   }
//
//   // Wysyłanie sygnałów do backendu (oferta/odpowiedź)
//   // Future<void> _sendSignal(String sessionId, String token, RTCSessionDescription description) async {
//   //   final signalData = {
//   //     'session_id': sessionId,
//   //     'token': token,
//   //     'description': description.toMap(),
//   //   };
//   //
//   //   final response = await http.post(
//   //     Uri.parse('$baseUrl/calls/handle_signal.php'),
//   //     body: json.encode(signalData),
//   //   );
//   //
//   //   if (response.statusCode == 200) {
//   //     print('Signal sent successfully');
//   //   } else {
//   //     throw Exception('Failed to send signal');
//   //   }
//   // }
//
//   Future<void> _sendSignal(String sessionId, String token, RTCSessionDescription description) async {
//     final signalData = {
//       'session_id': sessionId,
//       'token': token,
//       'description': description.toMap(),
//     };
//
//     print('Sending signal: $signalData');
//
//     final response = await http.post(
//       Uri.parse('$baseUrl/calls/handle_signal.php'),
//       body: json.encode(signalData),
//     );
//
//     print('Response status code: ${response.statusCode}');
//     print('Response body: ${response.body}');
//
//     if (response.statusCode == 200) {
//       print('Signal sent successfully');
//     } else {
//       throw Exception('Failed to send signal');
//     }
//   }
//
//
//   // Odbiór połączenia
//   // Future<void> _receiveCall(String sessionId, String token) async {
//   //   // Odbieranie oferty połączenia
//   //   final response = await http.post(
//   //     Uri.parse('$baseUrl/get_offer.php'),
//   //     body: {'session_id': sessionId, 'token': token},
//   //   );
//   //
//   //   if (response.statusCode == 200) {
//   //     final Map<String, dynamic> offerData = json.decode(response.body);
//   //     RTCSessionDescription offer = RTCSessionDescription(
//   //       offerData['sdp'],
//   //       offerData['type'],
//   //     );
//   //
//   //     await _peerConnection!.setRemoteDescription(offer);
//   //     RTCSessionDescription answer = await _peerConnection!.createAnswer();
//   //     await _peerConnection!.setLocalDescription(answer);
//   //
//   //     await _sendSignal(sessionId, token, answer);
//   //   } else {
//   //     throw Exception('Failed to receive call offer');
//   //   }
//   // }
//
//   Future<void> _receiveCall(String sessionId, String token) async {
//     print('Receiving call for session: $sessionId');
//
//     final response = await http.post(
//       Uri.parse('$baseUrl/calls/get_offer.php'),
//       body: {'session_id': sessionId, 'token': token},
//     );
//
//     print('Response status code: ${response.statusCode}');
//     print('Response body: ${response.body}');
//
//     if (response.statusCode == 200) {
//       final Map<String, dynamic> offerData = json.decode(response.body);
//       print('Offer received: $offerData');
//
//       RTCSessionDescription offer = RTCSessionDescription(
//         offerData['sdp'],
//         offerData['type'],
//       );
//
//       await _peerConnection!.setRemoteDescription(offer);
//       RTCSessionDescription answer = await _peerConnection!.createAnswer();
//       await _peerConnection!.setLocalDescription(answer);
//
//       await _sendSignal(sessionId, token, answer);
//     } else {
//       throw Exception('Failed to receive call offer');
//     }
//   }
//
// }
//
//
//
