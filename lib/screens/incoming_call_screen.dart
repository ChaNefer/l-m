import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class IncomingCallScreen extends StatelessWidget {
  final String callerId;
  final String callType;
  final String callerPhotoUrl;
  final String callerUsername;
  final String sessionId;
  final String token;

  const IncomingCallScreen({
    Key? key,
    required this.callerId,
    required this.callType,
    required this.callerPhotoUrl,
    required this.callerUsername,
    required this.sessionId,
    required this.token,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade700, Colors.blue.shade900],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Przychodzące połączenie',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              CircleAvatar(
                radius: 80,
                backgroundImage: CachedNetworkImageProvider(callerPhotoUrl),
              ),
              SizedBox(height: 20),
              Text(
                callerUsername,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
              Text(
                callType == 'audio' ? 'Rozmowa audio' : 'Rozmowa wideo',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CallButton(
                    icon: Icons.call,
                    color: Colors.green,
                    onPressed: () {
                      // Logika odebrania połączenia
                      _handleCallAccept(context);
                    },
                  ),
                  SizedBox(width: 40),
                  _CallButton(
                    icon: Icons.call_end,
                    color: Colors.red,
                    onPressed: () {
                      // Logika odrzucenia połączenia
                      _handleCallReject(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCallAccept(BuildContext context) {
    // TODO: Implementacja logiki akceptacji połączenia
    // Np. przejście do ekranu rozmowy, inicjalizacja WebRTC
    Navigator.of(context).pop();
  }

  void _handleCallReject(BuildContext context) {
    // TODO: Implementacja logiki odrzucenia połączenia
    // Np. wysłanie informacji o odrzuceniu do nadawcy
    Navigator.of(context).pop();
  }
}

class _CallButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _CallButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 3,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 40),
        onPressed: onPressed,
        padding: EdgeInsets.all(15),
      ),
    );
  }
}