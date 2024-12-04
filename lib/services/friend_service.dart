
class FriendRequest {
  final String id;
  final String senderId;
  final String receiverId;
  final String status;

  FriendRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'status': status,
    };
  }
}
