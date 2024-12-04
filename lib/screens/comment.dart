import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/comments.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/post_service.dart';
import '../widgets/cached_image.dart';

class Comments extends StatefulWidget {
  final PostModel? post;

  Comments({this.post}) {
    //print("Inicjalizowanie komentarzy z postId: ${post!.postId}");
  }

  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  UserModel? user;
  final PostService services = PostService();
  TextEditingController commentsTEC = TextEditingController();
  final AuthService _authService = AuthService();
  List<dynamic> commentsList = [];
  String? likesJsonString;
  String? commentsJsonString;
  String? replyToCommentId;
  bool showReplyField = false;
  Map<String, bool> replyVisibility = {};
  Map<String, TextEditingController> replyControllers = {};
  Map<int, List<CommentModel>> repliesMap = {};
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    //print('Initializing Comments with id: ${widget.post?.postId}');
    loadLocalizations();
    fetchComments(); // Pobieranie komentarzy podczas inicjalizacji
    _scrollController.addListener(() {});
  }

  Future<void> fetchComments() async {
    //print("PostId z klasy Comments: ${widget.post!.postId}");
        try {
      List<CommentModel> comments =
          await services.getComments(widget.post!.postId!);
          setState(() {
        commentsList = comments; // Zaktualizuj stan
      });
    } catch (error) {
      //print("Error fetching comments: $error");
    }
  }

  Future<void> fetchRepliesToComment(int commentId) async {
    try {
      List<CommentModel> replies =
          await services.getReplies(commentId.toString());
      // //print("Fetched replies for comment $commentId: $replies"); // Logowanie
      setState(() {
        repliesMap[commentId] = replies;
      });
    } catch (error) {
      //print("Error fetching replies: $error");
    }
  }

  Future<String?> currentUserId() async {
    try {
      var currentUser = await _authService.getCurrentUser();
      //print("currentUserId: Pobrano ID aktualnie zalogowanego użytkownika - ${currentUser?.id}");
      return currentUser?.id;
    } catch (e) {
      //print("currentUserId: Błąd podczas pobierania danych użytkownika - $e");
      return null;
    }
  }

  void loadLocalizations() async {
    //print('Loading localizations');
    if (likesJsonString == null) {
      likesJsonString = await rootBundle.loadString('assets/likes_pl.json');
      //print('Loaded likes localization');
    }
    if (commentsJsonString == null) {
      commentsJsonString =
          await rootBundle.loadString('assets/comments_pl.json');
      //print('Loaded comments localization');
    }
  }

  @override
  Widget build(BuildContext context) {
    // //print('Building Comments widget with post: ${widget.post?.postId ?? 'Post is null'}');
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            //print('Back button pressed');
            Navigator.pop(context);
          },
          child: Icon(CupertinoIcons.xmark_circle_fill),
        ),
        centerTitle: true,
        title: Text('Komentarze'),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Flexible(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: buildFullPost(),
                  ),
                  Divider(thickness: 1.5),
                  buildComments(),
                ],
              ),
            ),
            buildCommentInput(),
          ],
        ),
      ),
    );
  }

  Widget buildCommentInput() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
          ),
          constraints: BoxConstraints(maxHeight: 190.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        textCapitalization: TextCapitalization.sentences,
                        controller: commentsTEC,
                        style: TextStyle(
                          fontSize: 15.0,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(10.0),
                          focusedBorder: buildInputBorder(context),
                          focusedErrorBorder: buildInputBorder(context),
                          border: buildInputBorder(context),
                          enabledBorder: buildInputBorder(context),
                          hintText: "Napisz komentarz...",
                          hintStyle: TextStyle(
                            fontSize: 15.0,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                        ),
                        maxLines: null,
                      ),
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: () async {
                        String? userId = await currentUserId();
                        if (userId != null) {
                          //print('Sending comment: ${commentsTEC.text}');
                          await services.uploadComment(
                              userId,
                              commentsTEC.text,
                              widget.post!.postId!,
                              widget.post!.username!,
                              widget.post!.mediaUrl!,
                              parentId: replyToCommentId);
                          commentsTEC.clear();
                          //print('Comment sent and text field cleared');
                          fetchComments();
                        } else {
                          //print('User is not logged in. Comment not sent.');
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.send,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFullPost() {
    //print('Building full post: ${widget.post!.postId}');
    if (widget.post == null) {
      return Center(child: Text('Post not found.'));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            widget.post!.username ?? 'Użytkownik',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
        ),
        Container(
          height: 350.0,
          width: MediaQuery.of(context).size.width - 20.0,
          child: widget.post?.mediaUrl != null
              ? cachedNetworkImage(widget.post!.mediaUrl!)
              : const SizedBox.shrink(),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.post!.description ?? 'No description available.',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.0),
                  Row(
                    children: [
                      Text(timeago.format(widget.post!.createdAt!,
                          locale: 'pl' ?? 'Unknown time')),
                      SizedBox(width: 8.0),
                      FutureBuilder<int>(
                        future: widget.post?.id != null
                            ? services.getLikesCount(widget.post!.id!)
                            : Future.value(0),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return buildLikesCount(context, 0);
                          } else if (snapshot.hasError) {
                            // //print('Error fetching likes count: ${snapshot.error}');
                            return buildLikesCount(context, 0);
                          } else {
                            // //print('Likes count fetched: ${snapshot.data}');
                            return buildLikesCount(context, snapshot.data ?? 0);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              Spacer(),
              buildLikeButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildLikesCount(BuildContext context, int count) {
    return Text(
      '$count polubień',
      style: TextStyle(fontWeight: FontWeight.bold),
    );
  }

  Widget buildLikeButton() {
    return IconButton(
      icon: Icon(Icons.favorite_border),
      onPressed: () async {
        String? userId = await currentUserId();
        if (userId != null) {
          //print('Liking post as $userId');
          services.likePost(widget.post!.postId!);
        } else {
          //print('User is not logged in. Cannot like post.');
        }
      },
    );
  }

  OutlineInputBorder buildInputBorder(BuildContext context) {
    return OutlineInputBorder(
      borderSide: BorderSide(
        color: Theme.of(context).dividerColor,
      ),
      borderRadius: BorderRadius.circular(10),
    );
  }

  Widget buildCommentsList(List<CommentModel> comments) {
    return ListView.builder(
      itemCount: comments.length,
      itemBuilder: (context, index) {
        return buildCommentItem(comments[index]);
      },
    );
  }

  Widget buildCommentItem(CommentModel comment, {int indentLevel = 0}) {
    replyVisibility[comment.id.toString()] ??= false;

    // //print("Building comment item for comment ID: ${comment.id}");

    return Padding(
      padding: EdgeInsets.only(left: 10.0 + (indentLevel * 20.0)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 20.0,
                backgroundImage: CachedNetworkImageProvider(comment.userDp),
              ),
              SizedBox(width: 10.0),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                    ),
                  ),
                  Text(
                    timeago.format(comment.createdAt, locale: 'pl'),
                    style: TextStyle(
                      fontSize: 10.0,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
            child: Text(comment.comment),
          ),
          GestureDetector(
            onTap: () async {
              setState(() {
                replyVisibility[comment.id.toString()] = !(replyVisibility[comment.id.toString()] ?? false);
              });
              if (replyVisibility[comment.id.toString()] == true) {
                await fetchRepliesToComment(comment.id);
              }
            },
            child: Text(
              'Odpowiedz',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
          if (replyVisibility[comment.id.toString()] == true)
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Column(
                children: [
                  if (repliesMap[comment.id] != null && repliesMap[comment.id]!.isNotEmpty)
                    ...repliesMap[comment.id]!.map((reply) {
                      return Column(
                        children: [
                          buildReplyItem(reply), // Użyj buildReplyItem do renderowania odpowiedzi
                          SizedBox(height: 10.0),
                        ],
                      );
                    }).toList(),
                  buildReplyField(comment.id.toString()), // Pole do pisania odpowiedzi na ten komentarz
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget buildReplyItem(CommentModel reply) {
    return Padding(
      padding: const EdgeInsets.only(left: 30.0), // Wcięcie dla odpowiedzi
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 15.0,
                backgroundImage: CachedNetworkImageProvider(reply.userDp),
              ),
              SizedBox(width: 8.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reply.username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.0,
                    ),
                  ),
                  Text(
                    timeago.format(reply.createdAt, locale: 'pl'),
                    style: TextStyle(
                      fontSize: 10.0,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Text(
                    reply.reply ?? "Brak treści odpowiedzi",
                    style: TextStyle(fontSize: 12.0),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        replyVisibility[reply.id.toString()] = !(replyVisibility[reply.id.toString()] ?? false);
                      });
                    },
                    child: Text(
                      'Odpowiedz',
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Renderowanie odpowiedzi na tę odpowiedź, jeśli widoczność jest włączona
          if (replyVisibility[reply.id.toString()] == true)
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Column(
                children: [
                  if (repliesMap[reply.id] != null && repliesMap[reply.id]!.isNotEmpty)
                    ...repliesMap[reply.id]!.map((nestedReply) {
                      return Column(
                        children: [
                          buildReplyItem(nestedReply),
                          SizedBox(height: 10.0),
                        ],
                      );
                    }).toList(),
                  // Dodanie pola do pisania odpowiedzi na tę odpowiedź
                  buildReplyToReplyField(reply.id.toString()), // Nowe pole do odpowiedzi na odpowiedź
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget buildReplyField(String parentId) { // Zmieniono argument na parentId
    TextEditingController replyTEC = TextEditingController();
    // //print("Building reply field for parentId: $parentId");
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: replyTEC,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10.0),
                focusedBorder: buildInputBorder(context),
                enabledBorder: buildInputBorder(context),
                hintText: "Napisz odpowiedź...",
                hintStyle: TextStyle(
                  fontSize: 15.0,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          GestureDetector(
            onTap: () async {
              String? userId = await currentUserId();
              if (userId != null) {
                //print('Sending reply: ${replyTEC.text}');
                await services.uploadReply(
                  userId,
                  replyTEC.text,
                  parentId, // użyj parentId jako parentId
                  widget.post!.username!,
                  widget.post!.mediaUrl!,
                );
                replyTEC.clear();
                //print('Reply sent and text field cleared');
                fetchRepliesToComment(int.parse(parentId)); // opcjonalne: odśwież odpowiedzi
              } else {
                //print('User is not logged in. Reply not sent.');
              }
            },
            child: Container(
              padding: EdgeInsets.all(10),
              child: Icon(
                Icons.send,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildReplyToReplyField(String replyToId) {
    TextEditingController nestedReplyTEC = TextEditingController();
    // Logika budowania pola do odpowiedzi na odpowiedź
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: nestedReplyTEC,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10.0),
                focusedBorder: buildInputBorder(context),
                enabledBorder: buildInputBorder(context),
                hintText: "Napisz odpowiedź na odpowiedź...",
                hintStyle: TextStyle(
                  fontSize: 15.0,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          GestureDetector(
            onTap: () async {
              String? userId = await currentUserId();
              if (userId != null) {
                await services.uploadReplyToReply(
                  userId,
                  nestedReplyTEC.text,
                  replyToId, // ID odpowiedzi, na którą odpowiadasz
                  widget.post!.username!,
                  widget.post!.mediaUrl!,
                );
                nestedReplyTEC.clear();
                fetchRepliesToComment(int.parse(replyToId)); // opcjonalne: odśwież odpowiedzi
              } else {
                // Logika w przypadku braku zalogowanego użytkownika
              }
            },
            child: Container(
              padding: EdgeInsets.all(10),
              child: Icon(
                Icons.send,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildReplies(String commentId) {
    // Sprawdzenie, czy odpowiedzi są już załadowane
    if (repliesMap[commentId] == null) {
      fetchRepliesToComment(int.parse(commentId)); // załaduj odpowiedzi
      return CircularProgressIndicator(); // lub inny wskaźnik ładowania
    }

    // Renderowanie odpowiedzi
    return Column(
      children: repliesMap[commentId]!.map((reply) {
        return buildReplyItem(reply);
      }).toList(),
    );
  }

  Widget buildComments() {
    // //print('Building comments stream');
    return FutureBuilder<List<CommentModel>>(
      future: services.getComments(widget.post!.postId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Wystąpił błąd: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
              child: Text('Brak komentarzy. Dodaj pierwszy komentarz.'));
        } else {
          return ListView.builder(
            controller: _scrollController,
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final comment = snapshot.data![index];
              return buildCommentItem(comment);
            },
          );
        }
      },
    );
  }
}
