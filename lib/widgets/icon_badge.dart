// import 'package:flutter/material.dart';
// import 'package:les_social/utils/firebase.dart';
//
// class IconBadge extends StatefulWidget {
//   final IconData icon;
//   final double? size;
//   final Color? color;
//
//   IconBadge({Key? key, required this.icon, this.size, this.color})
//       : super(key: key);
//
//   @override
//   _IconBadgeState createState() => _IconBadgeState();
// }
//
// class _IconBadgeState extends State<IconBadge> {
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: <Widget>[
//         Icon(
//           widget.icon,
//           size: widget.size,
//           color: widget.color ?? null,
//         ),
//         Positioned(
//           right: 0.0,
//           child: Container(
//             padding: EdgeInsets.all(1),
//             decoration: BoxDecoration(
//               color: Colors.red,
//               borderRadius: BorderRadius.circular(6),
//             ),
//             constraints: BoxConstraints(
//               minWidth: 11,
//               minHeight: 11,
//             ),
//             child:
//                 Padding(padding: EdgeInsets.only(top: 1), child: buildCount()),
//           ),
//         ),
//       ],
//     );
//   }
//
//   buildCount() {
//     StreamBuilder(
//       stream: notificationRef
//           .doc(firebaseAuth.currentUser!.uid)
//           .collection('notifications')
//           .snapshots(),
//       builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//         if (snapshot.hasData) {
//           QuerySnapshot snap = snapshot.data!;
//           List<DocumentSnapshot> docs = snap.docs;
//           return buildTextWidget(docs.length.toString());
//         } else {
//           return buildTextWidget(0.toString());
//         }
//       },
//     );
//   }
//
//   buildTextWidget(String counter) {
//     return Text(
//       counter,
//       style: TextStyle(
//         color: Colors.white,
//         fontSize: 9,
//       ),
//       textAlign: TextAlign.center,
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IconBadge extends StatefulWidget {
  final IconData icon;
  final double? size;
  final Color? color;

  IconBadge({Key? key, required this.icon, this.size, this.color})
      : super(key: key);

  @override
  _IconBadgeState createState() => _IconBadgeState();
}

class _IconBadgeState extends State<IconBadge> {
  int notificationCount = 0; // Licznik powiadomień

  @override
  void initState() {
    super.initState();
    fetchNotificationCount(); // Pobranie początkowej liczby powiadomień
  }

  Future<void> fetchNotificationCount() async {
    try {
      // Twój endpoint do pobrania liczby powiadomień
      final url = Uri.parse('https://example.com/api/notifications/count'); // Zastąp odpowiednim adresem URL
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Przetwarzanie odpowiedzi JSON
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          notificationCount = data['count']; // Zakładam, że odpowiedź zwraca liczbę powiadomień
        });
      } else {
        // Obsługa błędów
        throw Exception('Failed to load notification count');
      }
    } catch (e) {
      //print('Error fetching notification count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Icon(
          widget.icon,
          size: widget.size,
          color: widget.color ?? null,
        ),
        Positioned(
          right: 0.0,
          child: Container(
            padding: EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(6),
            ),
            constraints: BoxConstraints(
              minWidth: 11,
              minHeight: 11,
            ),
            child: Padding(
              padding: EdgeInsets.only(top: 1),
              child: buildTextWidget(notificationCount.toString()),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildTextWidget(String counter) {
    return Text(
      counter,
      style: TextStyle(
        color: Colors.white,
        fontSize: 9,
      ),
      textAlign: TextAlign.center,
    );
  }
}
