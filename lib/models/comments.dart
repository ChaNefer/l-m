class CommentModel {
  final int id;
  final String postId;
  final int userId;
  final String comment;
  final DateTime createdAt;
  final String username;
  final String userDp;
  final String? reply;
  final int? parentId;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.comment,
    required this.createdAt,
    required this.username,
    required this.userDp,
    required this.reply,
    this.parentId,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] is String ? int.tryParse(json['id']) ?? 0 : json['id'],
      postId: json['postId'] ?? '', // Upewnij się, że to nie jest null
      userId: json['userId'] is String ? int.tryParse(json['userId']) ?? 0 : json['userId'],
      comment: json['comment'] ?? '', // Upewnij się, że to nie jest null
      createdAt: DateTime.parse(json['createdAt']),
      username: json['username'] ?? '', // Upewnij się, że to nie jest null
      userDp: json['userDp'] ?? '', // Upewnij się, że to nie jest null
      parentId: json['parentId'], // To może być null
      reply: json['reply'] ?? '', // Upewnij się, że to nie jest null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'username': username,
      'userDp': userDp,
      'parentId': parentId,
      'reply': reply ?? ''
    };
  }
}



