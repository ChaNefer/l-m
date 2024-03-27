import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:les_social/models/user.dart';
import 'package:les_social/services/services.dart';
import 'package:les_social/utils/firebase.dart';

class UserService extends Service {
  //get the authenticated uis
  String currentUid() {
    return firebaseAuth.currentUser!.uid;
  }

//tells when the user is online or not and updates the last seen for the messages
  setUserStatus(bool isOnline) {
    var user = firebaseAuth.currentUser;
    if (user != null) {
      usersRef
          .doc(user.uid)
          .update({'isOnline': isOnline, 'lastSeen': Timestamp.now()});
    }
  }

//updates user profile in the Edit Profile Screen
  // Metoda updateProfile w klasie UserService
  updateProfile({
    File? image,
    String? username,
    String? bio,
    String? country,
    String? orientation,
    String? sex,
    String? age,
    String? relationship}) async {
    try {
      // Wydrukuj przekazane parametry
      print('Update Profile:');
      print('Image: $image');
      print('Username: $username');
      print('Bio: $bio');
      print('Country: $country');
      print('Orientation: $orientation');
      print('Sex: $sex');
      print('Age: $age');
      print('Relationship: $relationship');

      DocumentSnapshot doc = await usersRef.doc(currentUid()).get();
      var users = UserModel.fromJson(doc.data() as Map<String, dynamic>);
      users.username = username;
      users.bio = bio;
      users.country = country;
      if (image != null) {
        users.photoUrl = await uploadImage(profilePic, image);
      }
      await usersRef.doc(currentUid()).update({
        'username': username,
        'bio': bio,
        'country': country,
        "photoUrl": users.photoUrl ?? '',
      });

      return true;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }
}
