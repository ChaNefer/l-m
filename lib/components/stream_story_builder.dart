import 'package:flutter/material.dart';
import 'package:les_social/widgets/indicators.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

typedef ItemBuilder<T> = Widget Function(BuildContext context, dynamic data);

class StreamStoriesWrapper extends StatelessWidget {
  final Stream<http.Response>? stream;
  final ItemBuilder<dynamic> itemBuilder;
  final Axis scrollDirection;
  final bool shrinkWrap;
  final bool? reverse;
  final ScrollPhysics physics;
  final EdgeInsets padding;

  const StreamStoriesWrapper({
    Key? key,
    required this.stream,
    required this.itemBuilder,
    this.scrollDirection = Axis.vertical,
    this.shrinkWrap = false,
    this.reverse,
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
                  ? SizedBox()
                  : ListView.builder(
                padding: padding,
                scrollDirection: scrollDirection,
                itemCount: data.length + 1,
                shrinkWrap: shrinkWrap,
                reverse: reverse!,
                physics: physics,
                itemBuilder: (BuildContext context, int index) {
                  if (index == data.length) {
                    return buildUploadButton();
                  }
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

  Widget buildUploadButton() {
    return Padding(
      padding: EdgeInsets.all(7.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.transparent,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              offset: new Offset(0.0, 0.0),
              blurRadius: 2.0,
              spreadRadius: 0.0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(0.5),
          child: CircleAvatar(
            radius: 25.0,
            backgroundColor: Colors.grey[300],
            child: Center(
              child: Icon(Icons.add, color: Colors.blue),
            ),
          ),
        ),
      ),
    );
  }
}
