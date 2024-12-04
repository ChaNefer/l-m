import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:les_social/models/notification.dart';
import 'package:les_social/pages/profile.dart';
import 'package:les_social/widgets/view_notification_details.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:les_social/widgets/indicators.dart';
import 'package:http/http.dart' as http;

import '../models/user.dart';

class ActivityItems extends StatefulWidget {
  final ActivityModel? activity;
  final UserModel? user;
  final String profileId;

  ActivityItems({this.activity, this.user, required this.profileId});

  @override
  _ActivityItemsState createState() => _ActivityItemsState();
}

class _ActivityItemsState extends State<ActivityItems> {

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ObjectKey("${widget.activity}"),
      background: stackBehindDismiss(),
      direction: DismissDirection.endToStart,
      onDismissed: (v) {
        deleteNotification(widget.activity!.userId!, widget.activity!.id!);
      },
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
        onTap: () {
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (_) => widget.activity!.type == "follow"
                  ? Profile(profileId: widget.profileId)
                  : ViewActivityDetails(activity: widget.activity!),
            ),
          );
        },
        leading: widget.activity!.userDp!.isEmpty
            ? CircleAvatar(
                radius: 20.0,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: Center(
                  child: Text(
                    '${widget.activity!.username![0].toUpperCase()}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            : CircleAvatar(
                radius: 20.0,
                backgroundImage: CachedNetworkImageProvider(
                  '${widget.activity!.userDp!}',
                ),
              ),
        title: RichText(
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            style: TextStyle(
              color: Colors.black,
              fontSize: 14.0,
            ),
            children: [
              TextSpan(
                text: '${widget.activity!.username!} ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              TextSpan(
                text: buildTextConfiguration(),
                style: TextStyle(
                  fontSize: 12.0,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ],
          ),
        ),
        subtitle: Text(
          timeago.format(widget.activity!.time!),
        ),
        trailing: previewConfiguration(),
      ),
    );
  }

  Widget stackBehindDismiss() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20.0),
      color: Theme.of(context).colorScheme.secondary,
      child: Icon(
        CupertinoIcons.delete,
        color: Colors.white,
      ),
    );
  }

  Future<void> deleteNotification(String userId, String id) async {
    String baseUrl = "https://lesmind.com";
    try {
      final url = Uri.parse('$baseUrl/notifications/delete'); // Endpoint do usunięcia powiadomienia
      final response = await http.post(
        url,
        body: {
          'userId': userId,
          'id': id,
        },
      );

      if (response.statusCode == 200) {
        //print('Notification deleted successfully');
      } else {
        //print('Failed to delete notification');
      }
    } catch (e) {
      //print('Error deleting notification: $e');
    }
  }

  previewConfiguration() {
    if (widget.activity!.type == "like" || widget.activity!.type == "comment") {
      return buildPreviewImage();
    } else {
      return Text('');
    }
  }

  buildTextConfiguration() {
    if (widget.activity!.type == "like") {
      return "${widget.user!.username} polubiła Twój post";
    }
    // else if (widget.activity!.type == "follow") {
    //   return "obserwuje Cię";
    // }
    else if (widget.activity!.type == "comment") {
      return "${widget.user!.username} skomentowała Twój post! ";
    } else {
      return "Error: Unknown type '${widget.activity!.type}'";
    }
  }

  buildPreviewImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5.0),
      child: CachedNetworkImage(
        imageUrl: widget.user!.photoUrl!,
        placeholder: (context, url) {
          return circularProgress(context);
        },
        errorWidget: (context, url, error) {
          return Icon(Icons.error);
        },
        height: 40.0,
        fit: BoxFit.cover,
        width: 40.0,
      ),
    );
  }
}
