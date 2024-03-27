import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:les_social/models/post.dart';
import 'package:les_social/screens/view_image.dart';
import 'package:les_social/widgets/cached_image.dart';

class PostTile extends StatefulWidget {
  final PostModel? post;

  PostTile({this.post});

  @override
  _PostTileState createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(CupertinoPageRoute(
          builder: (_) => ViewImage(post: widget.post),
        ));
      },
      child: Container(
        height: 150, // Zwiększyłem wysokość, aby zmieścić opis
        width: 150,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          elevation: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(5.0)),
                  child: cachedNetworkImage(widget.post!.mediaUrl!),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.post!.description ?? '', // Wyświetlenie opisu lub pustego ciągu znaków
                  maxLines: 2, // Ograniczenie opisu do dwóch wierszy
                  overflow: TextOverflow.ellipsis, // Przycinanie, jeśli opis jest za długi
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
