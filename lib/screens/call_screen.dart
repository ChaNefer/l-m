// import 'package:flutter/material.dart';
//
// class CallScreen extends StatefulWidget {
//   final String targetUserId;
//   final bool isVideoCall;
//
//   const CallScreen({
//     required this.targetUserId,
//     required this.isVideoCall,
//   });
//
//   @override
//   _CallScreenState createState() => _CallScreenState();
// }
//
// class _CallScreenState extends State<CallScreen> {
//   bool isCallAccepted = false;
//
//   // Funkcja odbierania połączenia
//   void acceptCall() {
//     setState(() {
//       isCallAccepted = true;
//     });
//
//     // Tutaj możesz dodać logikę, która rozpoczyna rozmowę
//     // np. nawiązywanie połączenia WebRTC
//     print('Call accepted');
//   }
//
//   // Funkcja odrzucania połączenia
//   void rejectCall() {
//     setState(() {
//       isCallAccepted = false;
//     });
//
//     // Dodać logikę, która kończy połączenie
//     print('Call rejected');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.isVideoCall ? 'Wideorozmowa' : 'Połączenie audio'),
//       ),
//       body: Center(
//         child: isCallAccepted
//             ? Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Rozmowa z użytkownikiem ${widget.targetUserId}',
//               style: TextStyle(fontSize: 18),
//             ),
//             // Możesz dodać podgląd kamery/video w tym miejscu, jeśli to połączenie wideo
//           ],
//         )
//             : Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Połączenie przychodzące od użytkownika ${widget.targetUserId}',
//               style: TextStyle(fontSize: 18),
//             ),
//             SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 IconButton(
//                   icon: Icon(Icons.call, color: Colors.green),
//                   onPressed: acceptCall,
//                   iconSize: 50,
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.call_end, color: Colors.red),
//                   onPressed: rejectCall,
//                   iconSize: 50,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
//


import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CallScreen extends StatefulWidget {
  final String targetUserId;
  final bool isVideoCall;

  const CallScreen({
    required this.targetUserId,
    required this.isVideoCall,
  });

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

  @override
  void initState() {
    super.initState();
    _initializeRenderers();
    _createConnection();
    isCallInitiator = false;
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

  Future<void> _createConnection() async {
    // Tworzenie lokalnego strumienia
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': widget.isVideoCall,
    });

    // Wyświetlanie lokalnego strumienia
    _localRenderer.srcObject = _localStream;

    // Tworzenie połączenia
    _peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'}, // STUN server
      ]
    });

    // Dodanie lokalnego strumienia do połączenia
    _peerConnection.addStream(_localStream);

    // Obsługa zdalnego strumienia
    _peerConnection.onAddStream = (MediaStream stream) {
      setState(() {
        _remoteRenderer.srcObject = stream;
      });
    };

    // Obsługa ICE candidates
    _peerConnection.onIceCandidate = (RTCIceCandidate candidate) {
      print('ICE Candidate: $candidate');
      // Wyślij kandydata ICE do serwera sygnalizacyjnego
    };

    // Inicjalizacja SDP
    if (isCallInitiator) {
      RTCSessionDescription offer = await _peerConnection.createOffer();
      await _peerConnection.setLocalDescription(offer);

      // Wyślij ofertę SDP do serwera sygnalizacyjnego
      print('Offer SDP: ${offer.sdp}');
    }
  }

  // Obsługa odbioru SDP (np. odpowiedź)
  Future<void> handleAnswer(String answer) async {
    RTCSessionDescription description = RTCSessionDescription(answer, 'answer');
    await _peerConnection.setRemoteDescription(description);
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
    setState(() {
      isCallAccepted = true;
    });

    print('Call accepted');
  }

  // Funkcja odrzucania połączenia
  void rejectCall() {
    setState(() {
      isCallAccepted = false;
    });

    print('Call rejected');
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
          Expanded(
            child: RTCVideoView(_localRenderer),
          ),
          Expanded(
            child: RTCVideoView(_remoteRenderer),
          ),
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



