class FriendModel {
  String? userId;
  String? username;
  String? photoUrl;
  String? bio;

  FriendModel({
    this.userId,
    this.username,
    this.photoUrl,
    this.bio,
  });

  FriendModel.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    username = json['username'];
    photoUrl = json['photoUrl'];
    bio = json['bio'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['username'] = this.username;
    data['photoUrl'] = this.photoUrl;
    data['bio'] = this.bio;
    return data;
  }
}
