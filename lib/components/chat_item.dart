import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:les_social/chats/conversation.dart';
import 'package:les_social/components/text_time.dart';
import 'package:les_social/models/enum/message_type.dart';
import 'package:les_social/models/user.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatItem extends StatelessWidget {
  final String? userId;
  final DateTime? time;
  final String? msg;
  final int? messageCount;
  final String? chatId;
  final MessageType? type;
  final String? currentUserId;

  ChatItem({
    Key? key,
    @required this.userId,
    @required this.time,
    @required this.msg,
    @required this.messageCount,
    @required this.chatId,
    @required this.type,
    @required this.currentUserId,
  }) : super(key: key);

  Future<UserModel> fetchUser(String userId) async {
    final response = await http.get(Uri.parse('https://yourapi.com/users/$userId'));
    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<int> fetchUnreadMessagesCount(String chatId, String currentUserId) async {
    final response = await http.get(Uri.parse('https://yourapi.com/chats/$chatId/unread-count?userId=$currentUserId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['unreadCount'];
    } else {
      throw Exception('Failed to load unread count');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        fetchUser(userId!), // Pobierz dane użytkownika
        fetchUnreadMessagesCount(chatId!, currentUserId!), // Pobierz liczbę nieprzeczytanych wiadomości
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Możesz wyświetlić wskaźnik ładowania
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          UserModel user = snapshot.data![0] as UserModel;
          int unreadCount = snapshot.data![1] as int;

          return ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
            leading: Stack(
              children: <Widget>[
                user.photoUrl == null || user.photoUrl!.isEmpty
                    ? CircleAvatar(
                  radius: 25.0,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  child: Center(
                    child: Text(
                      '${user.username![0].toUpperCase()}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                )
                    : CircleAvatar(
                  radius: 25.0,
                  backgroundImage: CachedNetworkImageProvider('${user.photoUrl}'),
                ),
                Positioned(
                  bottom: 0.0,
                  right: 0.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    height: 15,
                    width: 15,
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: user.isOnline ?? false ? Color(0xff00d72f) : Colors.grey,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        height: 11,
                        width: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            title: Text(
              '${user.username}',
              maxLines: 1,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              type == MessageType.IMAGE ? "IMAGE" : "$msg",
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                SizedBox(height: 10),
                Text(
                  "${timeago.format(time!, locale: 'pl')}",
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 11,
                  ),
                ),
                SizedBox(height: 5),
                buildCounter(context, unreadCount),
              ],
            ),
            onTap: () {
              Navigator.of(context, rootNavigator: true).push(
                CupertinoPageRoute(
                  builder: (BuildContext context) {
                    return Conversation(
                      userId: userId!,
                      chatId: chatId!,
                    );
                  },
                ),
              );
            },
          );
        } else {
          return SizedBox();
        }
      },
    );
  }

  Widget buildCounter(BuildContext context, int unreadCount) {
    if (unreadCount == 0) {
      return SizedBox();
    } else {
      return Container(
        padding: EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(6),
        ),
        constraints: BoxConstraints(
          minWidth: 11,
          minHeight: 11,
        ),
        child: Padding(
          padding: EdgeInsets.only(top: 1, left: 5, right: 5),
          child: Text(
            "$unreadCount",
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }
}
