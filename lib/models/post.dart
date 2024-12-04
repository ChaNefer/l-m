class PostModel {
  int? id;
  int? userId;
  String? postId;
  String? ownerId;
  String? username;
  String? age;
  String? location;
  String? description;
  String? mediaUrl;
  DateTime? createdAt;
  int? likeCount;
  bool? isLiked;
  String? parentId;

  PostModel({
    this.id,
    this.userId,
    this.postId,
    this.ownerId,
    this.location,
    this.description,
    this.mediaUrl,
    this.username,
    this.age,
    this.createdAt,
    this.likeCount,
    this.isLiked,
    this.parentId
  });

  PostModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] != null ? int.tryParse(json['id'].toString()) : null;
    userId = json['userId'] != null ? int.tryParse(json['userId'].toString()) : null;
    postId = json['postId'];
    ownerId = json['ownerId'];
    location = json['location'];
    username = json['username'];
    age = json['age'];
    description = json['content'];
    mediaUrl = json['photoUrl'];
    createdAt = json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null;
    likeCount = json['likeCount'];
    isLiked = json['isLiked'];
    parentId = json['parentId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id?.toString();
    data['userId'] = userId?.toString();
    data['postId'] = this.postId;
    data['ownerId'] = this.ownerId;
    data['location'] = this.location;
    data['content'] = this.description;
    data['photoUrl'] = this.mediaUrl;
    data['createdAt'] = this.createdAt?.toIso8601String(); // Użyj createdAt
    data['username'] = this.username;
    data['age'] = this.age;
    data['likeCount'] = this.likeCount;
    data['isLiked'] = this.isLiked;
    data['parentId'] = this.parentId;
    return data;
  }
}