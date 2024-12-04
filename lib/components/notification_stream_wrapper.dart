// import 'package:flutter/material.dart';
// import 'package:les_social/widgets/indicators.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// typedef ItemBuilder<T> = Widget Function(BuildContext context, dynamic data);
//
// class ActivityStreamWrapper extends StatelessWidget {
//   final Stream<http.Response>? stream; // Stream dla odpowiedzi z API
//   final ItemBuilder<dynamic> itemBuilder; // Funkcja budująca elementy listy
//   final Axis scrollDirection;
//   final bool shrinkWrap;
//   final ScrollPhysics physics;
//   final EdgeInsets padding;
//
//   const ActivityStreamWrapper({
//     Key? key,
//     required this.stream,
//     required this.itemBuilder,
//     this.scrollDirection = Axis.vertical,
//     this.shrinkWrap = false,
//     this.physics = const ClampingScrollPhysics(),
//     this.padding = const EdgeInsets.only(bottom: 2.0, left: 2.0),
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<http.Response>(
//       stream: stream,
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           var response = snapshot.data!;
//           if (response.statusCode == 200) {
//             var data = jsonDecode(response.body);
//             if (data is List) {
//               return data.isEmpty
//                   ? Container(
//                 child: Center(
//                   child: Padding(
//                     padding: const EdgeInsets.only(top: 250.0),
//                     child: Text('Brak aktywności'),
//                   ),
//                 ),
//               )
//                   : ListView.separated(
//                 separatorBuilder: (BuildContext context, int index) {
//                   return Align(
//                     alignment: Alignment.centerRight,
//                     child: Container(
//                       height: 0.5,
//                       width: MediaQuery.of(context).size.width / 1.3,
//                       child: const Divider(),
//                     ),
//                   );
//                 },
//                 padding: padding,
//                 scrollDirection: scrollDirection,
//                 itemCount: data.length,
//                 shrinkWrap: shrinkWrap,
//                 physics: physics,
//                 itemBuilder: (BuildContext context, int index) {
//                   return itemBuilder(context, data[index]);
//                 },
//               );
//             } else {
//               return Center(
//                 child: Text('Błąd: Oczekiwano listy danych'),
//               );
//             }
//           } else {
//             return Center(
//               child: Text('Błąd: ${response.statusCode} - ${response.reasonPhrase}'),
//             );
//           }
//         } else {
//           return circularProgress(context);
//         }
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:les_social/widgets/indicators.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

typedef ItemBuilder<T> = Widget Function(BuildContext context, dynamic data);

class ActivityStreamWrapper extends StatelessWidget {
  final String userId; // Dodany identyfikator użytkownika do API
  final ItemBuilder<dynamic> itemBuilder; // Funkcja budująca elementy listy
  final Axis scrollDirection;
  final bool shrinkWrap;
  final ScrollPhysics physics;
  final EdgeInsets padding;

  const ActivityStreamWrapper({
    Key? key,
    required this.userId,
    required this.itemBuilder,
    this.scrollDirection = Axis.vertical,
    this.shrinkWrap = false,
    this.physics = const ClampingScrollPhysics(),
    this.padding = const EdgeInsets.only(bottom: 2.0, left: 2.0),
  }) : super(key: key);

  // Funkcja tworząca strumień odpowiedzi dla powiadomień użytkownika
  Stream<http.Response> _fetchActivitiesStream() async* {
    while (true) {
      final response = await http.get(Uri.parse('https://lesmind.com/api/notifications/$userId'));
      yield response;
      await Future.delayed(Duration(seconds: 5)); // Odświeżanie co 5 sekund
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<http.Response>(
      stream: _fetchActivitiesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData && snapshot.data?.statusCode == 200) {
          var data = jsonDecode(snapshot.data!.body);
          if (data is List) {
            return data.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 250.0),
                child: Text('Brak aktywności'),
              ),
            )
                : ListView.separated(
              separatorBuilder: (BuildContext context, int index) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    height: 0.5,
                    width: MediaQuery.of(context).size.width / 1.3,
                    child: const Divider(),
                  ),
                );
              },
              padding: padding,
              scrollDirection: scrollDirection,
              itemCount: data.length,
              shrinkWrap: shrinkWrap,
              physics: physics,
              itemBuilder: (BuildContext context, int index) {
                return itemBuilder(context, data[index]);
              },
            );
          } else {
            return Center(child: Text('Błąd: Oczekiwano listy danych'));
          }
        } else {
          return Center(
            child: Text('Błąd: ${snapshot.error ?? 'Nie udało się pobrać danych'}'),
          );
        }
      },
    );
  }
}



