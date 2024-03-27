import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:les_social/components/chat_bubble.dart';
import 'package:les_social/models/enum/message_type.dart';
import 'package:les_social/models/message.dart';
import 'package:les_social/models/user.dart';
import 'package:les_social/pages/profile.dart';
import 'package:les_social/utils/firebase.dart';
import 'package:les_social/view_models/conversation/conversation_view_model.dart';
import 'package:les_social/view_models/user/user_view_model.dart';
import 'package:les_social/widgets/indicators.dart';
import 'package:timeago/timeago.dart' as timeago;

class Conversation extends StatefulWidget {
  final String userId;
  final String chatId;

  const Conversation({required this.userId, required this.chatId});

  @override
  _ConversationState createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  FocusNode focusNode = FocusNode();
  ScrollController scrollController = ScrollController();
  TextEditingController messageController = TextEditingController();
  bool isFirst = false;
  String? chatId;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      focusNode.unfocus();
    });
    if (widget.chatId == 'newChat') {
      isFirst = true;
    }
    chatId = widget.chatId;

    messageController.addListener(() {
      if (focusNode.hasFocus && messageController.text.isNotEmpty) {
        setTyping(true);
      } else if (!focusNode.hasFocus ||
          (focusNode.hasFocus && messageController.text.isEmpty)) {
        setTyping(false);
      }
    });
    if (widget.chatId == 'newChat') {
      isFirst = true;
    }
    Provider.of<ConversationViewModel>(context, listen: false)
        .createChatIfNotExists(widget.chatId, widget.userId, "rozmowa...");
  }

  setTyping(typing) {
    UserViewModel viewModel =
        Provider.of<UserViewModel>(context, listen: false);
    viewModel.setUser();
    var user = Provider.of<UserViewModel>(context, listen: false).user;
    Provider.of<ConversationViewModel>(context, listen: false)
        .setUserTyping(widget.chatId, user, typing);
  }

  @override
  Widget build(BuildContext context) {
    UserViewModel viewModel = Provider.of<UserViewModel>(context);
    viewModel.setUser();
    var user = Provider.of<UserViewModel>(context, listen: true).user;
    return Consumer<ConversationViewModel>(
        builder: (BuildContext context, viewModel, Widget? child) {
      return Scaffold(
        key: viewModel.scaffoldKey,
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.keyboard_backspace,
            ),
          ),
          elevation: 0.0,
          titleSpacing: 0,
          title: buildUserName(),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Flexible(
                child: StreamBuilder<QuerySnapshot>(
                  stream: messageListStream(widget.chatId),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List messages = snapshot.data!.docs;
                      viewModel.setReadCount(
                          widget.chatId, user, messages.length);
                      return ListView.builder(
                        controller: scrollController,
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        itemCount: messages.length,
                        reverse: true,
                        itemBuilder: (BuildContext context, int index) {
                          Message message = Message.fromJson(
                            messages.reversed.toList()[index].data(),
                          );
                          return ChatBubbleWidget(
                            message: '${message.content}',
                            time: message.time!,
                            isMe: message.senderUid == user!.uid,
                            type: message.type!,
                          );
                        },
                      );
                    } else {
                      return Center(child: circularProgress(context));
                    }
                  },
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: BottomAppBar(
                  elevation: 10.0,
                  child: Container(
                    constraints: BoxConstraints(maxHeight: 100.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(
                            CupertinoIcons.photo_on_rectangle,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          onPressed: () => showPhotoOptions(viewModel, user),
                        ),
                        Flexible(
                          child: TextField(
                            controller: messageController,
                            focusNode: focusNode,
                            style: TextStyle(
                              fontSize: 15.0,
                              color:
                                  Theme.of(context).textTheme.headline6!.color,
                            ),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10.0),
                              enabledBorder: InputBorder.none,
                              border: InputBorder.none,
                              hintText: "Zacznij pisać...",
                              hintStyle: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .color,
                              ),
                            ),
                            maxLines: null,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Ionicons.send,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          onPressed: () {
                            if (messageController.text.isNotEmpty) {
                              sendMessage(viewModel, user);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  _buildOnlineText(
    var user,
    bool typing,
  ) {
    if (user.isOnline) {
      if (typing) {
        return "pisze...";
      } else {
        return "online";
      }
    } else {
      return 'ostatnio widziano ${timeago.format(user.lastSeen.toDate())}';
    }
  }

  Widget buildUserName() {
    return StreamBuilder(
      stream: usersRef.doc('${widget.userId}').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          DocumentSnapshot documentSnapshot =
              snapshot.data as DocumentSnapshot<Object?>;
          UserModel user = UserModel.fromJson(
            documentSnapshot.data() as Map<String, dynamic>,
          );
          return InkWell(
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Hero(
                    tag: user.email!,
                    child: user.photoUrl!.isEmpty
                        ? CircleAvatar(
                            radius: 25.0,
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
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
                            backgroundImage: CachedNetworkImageProvider(
                              '${user.photoUrl}',
                            ),
                          ),
                  ),
                ),
                SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${user.username}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0,
                        ),
                      ),
                      SizedBox(height: 5.0),
                      StreamBuilder(
                        stream: chatRef.doc('${widget.chatId}').snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            DocumentSnapshot? snap =
                                snapshot.data as DocumentSnapshot<Object?>;
                            Map? data = snap.data() as Map<dynamic, dynamic>?;

                            // Sprawdź, czy pole "typing" istnieje w dokumencie
                            if (data != null && data.containsKey('typing')) {
                              Map? usersTyping =
                                  data['typing'] as Map<dynamic, dynamic>?;
                              bool isTyping =
                                  usersTyping![widget.userId] ?? false;

                              return Text(
                                isTyping ? "pisze..." : "online",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 11,
                                ),
                              );
                            } else {
                              // Obsłuż przypadek, gdy pole "typing" nie istnieje w dokumencie
                              return SizedBox();
                            }
                          } else {
                            return SizedBox();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (_) => Profile(profileId: user.id),
                ),
              );
            },
          );
        } else {
          return Center(child: circularProgress(context));
        }
      },
    );
  }

  showPhotoOptions(ConversationViewModel viewModel, var user) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text("Kamera"),
              onTap: () {
                sendMessage(viewModel, user, imageType: 0, isImage: true);
              },
            ),
            ListTile(
              title: Text("Galeria"),
              onTap: () {
                sendMessage(viewModel, user, imageType: 1, isImage: true);
              },
            ),
          ],
        );
      },
    );
  }

  void sendMessage(ConversationViewModel viewModel, var user,
      {bool isImage = false, int? imageType}) async {
    print('Sending message...');

    String msg;
    if (isImage) {
      msg = await viewModel.pickImage(
        source: imageType!,
        context: context,
        chatId: widget.chatId,
      );
    } else {
      msg = messageController.text.trim();
      messageController.clear();
    }

    Message message = Message(
      content: '$msg',
      senderUid: user?.uid,
      type: isImage ? MessageType.IMAGE : MessageType.TEXT,
      time: Timestamp.now(),
    );

    if (msg.isNotEmpty) {
      if (isFirst) {
        print("FIRST");
        String id = await viewModel.sendFirstMessage(widget.userId, message);
        isFirst = false;
        setState(() {
          chatId = id;
          chatIdRef.add({
            "users": getUser(firebaseAuth.currentUser!.uid, widget.userId),
            "chatId": id
          });
        });
      }
      print('Before sending message to Firebase');
      viewModel.sendMessage(widget.chatId, message);
      print('Message sent to Firebase');
    }
  }


  // Tworzenie dokumentu czatu, jeśli nie istnieje
  // Ten fragment kodu znajduje się w klasie Conversation
  Future<String> createChatIfNotExists() async {
    try {
      DocumentReference chatRef = FirebaseFirestore.instance.collection('chats').doc();
      final chatSnapshot = await chatRef.get();
      if (!chatSnapshot.exists) {
        await chatRef.set({});
        print('Created new chat document with ID ${chatRef.id}');
        return chatRef.id;
      } else {
        print('Chat document with ID ${chatRef.id} already exists!');
        return chatRef.id;
      }
    } catch (e) {
      print('Error creating or checking chat document: $e');
      return ''; // lub zwróć null, jeśli chcesz obsłużyć błąd inaczej
    }
  }



  // Dodawanie ID użytkowników do odniesienia do czatu
  void addUsersToChatReference(String user1, String user2, String chatId) {
    try {
      user1 = user1.substring(0, 5);
      user2 = user2.substring(0, 5);
      List<String> list = [user1, user2];
      list.sort();
      var concatenatedUserId = "${list[0]}-${list[1]}";

      chatIdRef.add({"users": concatenatedUserId, "chatId": chatId});
    } catch (e) {
      print('Error adding users to chat reference: $e');
    }
  }

  //this will concatenate the two users involved in the chat
  //and  return a unique id, because firebase doesn't perform
  //some complex queries
  String getUser(String user1, String user2) {
    user1 = user1.substring(0, 5);
    user2 = user2.substring(0, 5);
    List<String> list = [user1, user2];
    list.sort();
    var chatId = "${list[0]}-${list[1]}";
    return chatId;
  }

  Stream<QuerySnapshot> messageListStream(String documentId) {
    print('Getting message list stream for document ID: $documentId');
    return chatRef
        .doc(documentId)
        .collection('messages')
        .orderBy('time')
        .snapshots();
  }

}
