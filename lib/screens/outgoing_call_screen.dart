import 'package:flutter/material.dart';

class OutgoingCallScreen extends StatelessWidget {
  final String targetUserId;
  final String callType;
  final String sessionId;
  final String token;

  OutgoingCallScreen({
    required this.targetUserId,
    required this.callType,
    required this.sessionId,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dzwonienie...')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Dzwonię do użytkownika: $targetUserId'),
            Text('Typ połączenia: $callType'),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Przerwij połączenie'),
            ),
          ],
        ),
      ),
    );
  }
}
