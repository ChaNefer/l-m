class ActivityModel {
  String? type;
  String? postId;
  String? username;
  String? userId;
  String? ownerId;
  String? userDp;
  String? id;
  String? mediaUrl;
  String? commentData;
  DateTime? time;

  ActivityModel({
    this.type,
    this.postId,
    this.username,
    this.userId,
    this.ownerId,
    this.userDp,
    this.id,
    this.commentData,
    this.mediaUrl,
    this.time,
  });

  ActivityModel.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    postId = json['postId'];
    username = json['username'];
    userId = json['userId'];
    ownerId = json['ownerId'];
    userDp = json['userDp'];
    id = json['id'];
    mediaUrl = json['mediaUrl'];
    commentData = json['commentData'];

    // Sprawdzamy, czy 'time' jest obecne i ma poprawny format
    if (json['time'] != null) {
      try {
        time = DateTime.parse(json['time']);
      } catch (e) {
        //print('Błąd parsowania daty: $e');
        time = null; // W przypadku błędu, ustawiamy `time` na null
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['postId'] = this.postId;
    data['username'] = this.username;
    data['userId'] = this.userId;
    data['ownerId'] = this.ownerId;
    data['userDp'] = this.userDp;
    data['id'] = this.id;
    data['mediaUrl'] = this.mediaUrl;
    data['commentData'] = this.commentData;

    // Sprawdzamy, czy `time` nie jest null przed próbą konwersji
    data['time'] = this.time?.toIso8601String(); // Przekształcenie daty na ISO 8601 string

    return data;
  }
}



