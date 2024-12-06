import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:les_social/services/auth_service.dart';

import '../models/user.dart';

class CallScreen extends StatefulWidget {
  final String targetUserId;
  final bool isVideoCall;
  late final AuthService _authService = AuthService();

  final String? receiver_id;


   CallScreen({
    required this.targetUserId,
    required this.isVideoCall,
    this.receiver_id
  });

  Future<UserModel?> currentUserId() async {
    try {
      var currentUser = await _authService.getCurrentUser();
      print(
          "currentUserId: Pobrano ID aktualnie zalogowanego użytkownika - ${currentUser?.id}"); // Debugowanie
      return currentUser;
    } catch (e) {
      //print("currentUserId: Błąd podczas pobierania danych użytkownika - $e"); // Debugowanie
      return null;
    }
  }


  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late RTCPeerConnection _peerConnection;
  late MediaStream _localStream;
  late bool isCallInitiator;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  bool isCallAccepted = false;
  String? remoteSdp; // zmienna do przechowywania zdalnego SDP

  @override
  void initState() {
    super.initState();
    _initializeRenderers();
    isCallInitiator = true; // Pierwsze połączenie inicjuje rozmowę
    _createConnection();
  }

  @override
  void dispose() {
    _localStream.dispose();
    _peerConnection.close();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  Future<void> _initializeRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  // Tworzymy połączenie audio lub wideo
  Future<void> _createConnection() async {
    // Tworzymy lokalny strumień tylko audio lub audio + wideo
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': widget.isVideoCall,  // Jeśli jest połączenie wideo, dodajemy strumień wideo
    });

    // Wyświetlanie lokalnego strumienia
    if (widget.isVideoCall) {
      _localRenderer.srcObject = _localStream;
    }

    // Tworzymy połączenie PeerConnection
    _peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'}, // STUN server
      ]
    });

    // Dodanie lokalnych tracków (audio/wideo) do połączenia
    _localStream.getTracks().forEach((track) {
      _peerConnection.addTrack(track, _localStream);
    });

    // Obsługa zdalnego strumienia
    _peerConnection.onAddTrack = (MediaStream stream, MediaStreamTrack track) {
      setState(() {
        if (widget.isVideoCall) {
          _remoteRenderer.srcObject = stream; // strumień zdalny zawierający audio/wideo
        }
      });
    };

    // Obsługa ICE candidates
    _peerConnection.onIceCandidate = (RTCIceCandidate candidate) {
      print('ICE Candidate: $candidate');
      _sendIceCandidateToServer(candidate);
    };

    // Tworzymy ofertę SDP (tylko dla inicjatora połączenia)
    if (isCallInitiator) {
      RTCSessionDescription offer = await _peerConnection.createOffer();
      await _peerConnection.setLocalDescription(offer);
      _sendSdpToServer(offer.sdp!); // Wyślij ofertę SDP do serwera
    }
  }

  // Obsługa odbioru odpowiedzi SDP
  Future<void> handleAnswer(String answer) async {
    RTCSessionDescription description = RTCSessionDescription(answer, 'answer');
    await _peerConnection.setRemoteDescription(description);
    setState(() {
      remoteSdp = answer; // Ustawienie remoteSdp
    });
  }

  // Obsługa odbioru ICE Candidate
  Future<void> handleIceCandidate(Map<String, dynamic> candidate) async {
    RTCIceCandidate iceCandidate = RTCIceCandidate(
      candidate['candidate'],
      candidate['sdpMid'],
      candidate['sdpMLineIndex'],
    );
    await _peerConnection.addCandidate(iceCandidate);
  }

  // Funkcja odbierania połączenia
  void acceptCall() {
    if (remoteSdp != null) {
      setState(() {
        isCallAccepted = true;
      });

      print('Call accepted');
      _sendSdpToServer(remoteSdp!); // Wysyłamy SDP odpowiedzi do serwera
    } else {
      print("remoteSdp is null!");
    }
  }

  // Funkcja odrzucania połączenia
  void rejectCall() {
    setState(() {
      isCallAccepted = false;
    });

    print('Call rejected');
    // Wyślij informację o odrzuceniu połączenia do serwera
  }

  // Funkcja wysyłania SDP do serwera
  void _sendSdpToServer(String sdp) {
    // Wyślij SDP do serwera sygnalizacyjnego
    print('Sending SDP to server: $sdp');
  }

  // Funkcja wysyłania ICE Candidate do serwera
  void _sendIceCandidateToServer(RTCIceCandidate candidate) {
    // Wyślij ICE Candidate do serwera sygnalizacyjnego
    print('Sending ICE Candidate to server: ${candidate.candidate}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isVideoCall ? 'Wideorozmowa' : 'Połączenie audio'),
      ),
      body: isCallAccepted
          ? Column(
        children: [
          if (widget.isVideoCall) ...[
            // Renderowanie wideo, jeśli połączenie wideo
            Expanded(
              child: RTCVideoView(_localRenderer),
            ),
            Expanded(
              child: RTCVideoView(_remoteRenderer),
            ),
          ] else ...[
            // Renderowanie tylko audio
            Expanded(
              child: Center(
                child: Icon(Icons.headset, size: 100, color: Colors.green),
              ),
            ),
          ]
        ],
      )
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Połączenie przychodzące od użytkownika ${widget.targetUserId}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.call, color: Colors.green),
                  onPressed: acceptCall,
                  iconSize: 50,
                ),
                IconButton(
                  icon: Icon(Icons.call_end, color: Colors.red),
                  onPressed: rejectCall,
                  iconSize: 50,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


