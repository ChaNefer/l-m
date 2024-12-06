// import 'package:flutter/material.dart';
// import '../services/websocket_service.dart';
//
// class CallNotificationScreen extends StatefulWidget {
//   final WebSocketService? webSocketService;
//
//   const CallNotificationScreen({
//     Key? key,
//     required this.webSocketService
//   }) : super(key: key);
//
//   @override
//   _CallNotificationScreenState createState() => _CallNotificationScreenState();
// }
//
// class _CallNotificationScreenState extends State<CallNotificationScreen> {
//   String? _callerUsername;
//   String? _callerPhotoUrl;
//   String? _callType; // Typ połączenia (np. 'video' lub 'voice')
//
//   @override
//   void initState() {
//     super.initState();
//     _setupCallListener();
//   }
//
//   void _setupCallListener() {
//     widget.webSocketService?.messageStream.listen((message) {
//       if (message['type'] == 'call') {
//         _handleIncomingCall(message);
//       }
//     });
//   }
//
//   void _handleIncomingCall(Map<String, dynamic> callData) {
//     setState(() {
//       _callerUsername = callData['caller_username']; // Pobrane z serwera
//       _callerPhotoUrl = callData['caller_photo_url']; // Pobrane z serwera
//       _callType = callData['call_type']; // Typ połączenia (np. 'video', 'voice')
//     });
//
//     _showIncomingCallDialog();
//   }
//
//   void _showIncomingCallDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: Text('Incoming Call'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if (_callerPhotoUrl != null)
//               CircleAvatar(
//                 backgroundImage: NetworkImage(_callerPhotoUrl!),
//                 radius: 50,
//               ),
//             SizedBox(height: 16),
//             Text('$_callerUsername wants to call you'),
//             if (_callType != null)
//               Text('Call Type: $_callType'),
//             SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton(
//                   onPressed: _acceptCall,
//                   child: Text('Accept'),
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//                 ),
//                 ElevatedButton(
//                   onPressed: _rejectCall,
//                   child: Text('Reject'),
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                 ),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _acceptCall() {
//     widget.webSocketService?.sendMessage({
//       'type': 'accept_call',
//       'callerUsername': _callerUsername, // Przesyłamy nazwę dzwoniącego
//       'callType': _callType, // Typ połączenia (np. 'video', 'voice')
//     });
//     Navigator.of(context).pop();
//     // Przejdź do ekranu rozmowy
//     // Możesz dodać logikę przejścia do ekranu rozmowy
//   }
//
//   void _rejectCall() {
//     widget.webSocketService?.sendMessage({
//       'type': 'reject_call',
//       'callerUsername': _callerUsername, // Przesyłamy nazwę dzwoniącego
//     });
//     Navigator.of(context).pop();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Text('Waiting for incoming calls...'),
//       ),
//     );
//   }
// }
