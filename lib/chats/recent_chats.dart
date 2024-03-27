import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:les_social/components/chat_item.dart';
import 'package:les_social/utils/firebase.dart';
import 'package:les_social/view_models/user/user_view_model.dart';
import '../models/enum/message_type.dart';
import '../models/message.dart';

class Chats extends StatefulWidget {
  @override
  _ChatsState createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  late UserViewModel _userViewModel;
  bool _isUserSet = false;
  String? _userId;


  @override
  void initState() {
    super.initState();
    print('Initializing Chats screen...');
    _userViewModel = Provider.of<UserViewModel>(context, listen: false);
    _setUser();
  }

  Future<void> _setUser() async {
    print('Setting user...');
    await _userViewModel.setUser();
    setState(() {
      _userId = _userViewModel.user!.uid;
      _isUserSet = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.keyboard_backspace),
        ),
        title: Text("Rozmowy"),
      ),
      body: _isUserSet
          ? _buildChatList()
          : Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildChatList() {
    if (_userViewModel.user != null) {
      return StreamBuilder<QuerySnapshot>(
        stream: userChatsStream(_userId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            print('Number of chats retrieved: ${snapshot.data!.docs.length}');

            snapshot.data!.docs.forEach((doc) {
              print(doc.data());
            });

            return _buildChatListView(snapshot.data!);
          } else {
            return Center(child: Text('Brak rozmów'));
          }
        },
      );
    } else {
      return Container();
    }
  }

  Stream<QuerySnapshot> userChatsStream(String userId) {
    final currentUserUid = _userViewModel.user!.uid;
    print('User ID: $currentUserUid');
    return chatRef
        .where('users', arrayContains: [currentUserUid, userId]) // Combine conditions
        .orderBy('lastTextTime', descending: true)
        .snapshots();
  }



  Stream<QuerySnapshot> messageListStream(String documentId) {
    return chatRef
        .doc(documentId)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots();
  }

  Widget _buildChatListView(QuerySnapshot data) {
    final chatList = data.docs;
    if (chatList.isNotEmpty) {
      return ListView.separated(
        itemCount: chatList.length,
        itemBuilder: (BuildContext context, int index) {
          DocumentSnapshot chatListSnapshot = chatList[index];
          Map<String, dynamic> chatData =
          chatListSnapshot.data() as Map<String, dynamic>;

          List users = chatData['users'];
          users.remove(_userViewModel.user!.uid);
          String recipient = users[0];

          return StreamBuilder<QuerySnapshot>(
            stream: chatListSnapshot.reference
                .collection('messages') // Zmieniono na kolekcję Messages
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              QuerySnapshot messagesSnapshot = snapshot.data!;
              int messageCount = messagesSnapshot.docs.length;

              Message? message;
              if (messagesSnapshot.docs.isNotEmpty) {
                Map<String, dynamic> messageData =
                messagesSnapshot.docs.first.data() as Map<String, dynamic>;
                message = Message.fromJson(messageData);
              }

              int numberOfReadMessages = 0;
              if (chatData.containsKey('reads')) {
                Map<String, dynamic>? reads =
                chatData['reads'] as Map<String, dynamic>?;
                numberOfReadMessages = reads?[_userViewModel.user!.uid] ?? 0;
              }

              return ChatItem(
                userId: recipient,
                messageCount: messageCount,
                msg: message?.content ?? '',
                time: message?.time != null
                    ? Timestamp.fromDate(
                    DateTime.parse(message?.time! as String))
                    : null,
                chatId: chatListSnapshot.id,
                type: MessageType.TEXT,
                currentUserId: _userViewModel.user!.uid,
              );
            },
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Align(
            alignment: Alignment.centerRight,
            child: Container(
              height: 0.5,
              width: MediaQuery.of(context).size.width / 1.3,
              child: Divider(),
            ),
          );
        },
      );
    } else {
      return Center(child: Text('Brak rozmów'));
    }
  }

}
