import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendFriendRequest(String senderId, String receiverId) async {
    try {
      await _firestore.collection('friend_requests').add({
        'senderId': senderId,
        'receiverId': receiverId,
        'status': 'pending',
      });
    } catch (error) {
      print('Error sending friend request: $error');
    }
  }

  Future<void> acceptFriendRequest(String requestId) async {
    try {
      final DocumentSnapshot requestSnapshot =
      await _firestore.collection('friend_requests').doc(requestId).get();

      final Map<String, dynamic>? requestData =
      requestSnapshot.data() as Map<String, dynamic>?;

      if (requestData != null) {
        final senderId = requestData['senderId'] ?? '';
        final receiverId = requestData['receiverId'] ?? '';

        // Remove friend request
        await _firestore.collection('friend_requests').doc(requestId).delete();

        // Add both users as friends
        await _firestore.collection('friends').add({
          'userId1': senderId,
          'userId2': receiverId,
        });
        await _firestore.collection('friends').add({
          'userId1': receiverId,
          'userId2': senderId,
        });
      }
    } catch (error) {
      print('Error accepting friend request: $error');
    }
  }


  Stream<List<String>> getFriends(String userId) {
    return _firestore
        .collection('friends')
        .where('userId1', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc['userId2'].toString()).toList());
  }

}
