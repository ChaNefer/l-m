import 'package:flutter/material.dart';
import 'package:les_social/widgets/indicators.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

typedef ItemBuilder<T> = Widget Function(BuildContext context, dynamic data);

class StreamGridWrapper extends StatelessWidget {
  final Stream<http.Response>? stream;
  final ItemBuilder<dynamic> itemBuilder;
  final Axis scrollDirection;
  final bool shrinkWrap;
  final ScrollPhysics physics;
  final EdgeInsets padding;

  const StreamGridWrapper({
    Key? key,
    required this.stream,
    required this.itemBuilder,
    this.scrollDirection = Axis.vertical,
    this.shrinkWrap = false,
    this.physics = const ClampingScrollPhysics(),
    this.padding = const EdgeInsets.only(bottom: 2.0, left: 2.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<http.Response>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var response = snapshot.data!;
          if (response.statusCode == 200) {
            var data = jsonDecode(response.body);
            if (data is List) {
              return data.isEmpty
                  ? Container(
                child: Center(
                  child: Text('Brak postów do wyświetlenia'),
                ),
              )
                  : GridView.builder(
                padding: padding,
                scrollDirection: scrollDirection,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 3 / 3,
                ),
                itemCount: data.length,
                shrinkWrap: shrinkWrap,
                physics: physics,
                itemBuilder: (BuildContext context, int index) {
                  return itemBuilder(context, data[index]);
                },
              );
            } else {
              return Center(
                child: Text('Błąd: Oczekiwano listy danych'),
              );
            }
          } else {
            return Center(
              child: Text('Błąd: ${response.statusCode} - ${response.reasonPhrase}'),
            );
          }
        } else {
          return circularProgress(context);
        }
      },
    );
  }
}
