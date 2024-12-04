// import 'package:les_social/services/services.dart';
// import 'package:les_social/utils/firebase.dart';
//
// class UpdateProfileService extends Service {
//   String currentUid() {
//     return firebaseAuth.currentUser!.uid;
//   }
//
//   // Updates user profile in the More About Screen
//   Future<bool> updateMoreInfo(
//       {String? orientation,
//       String? sex,
//       String? age,
//       String? relationship,
//       String? diet,
//       String? job,
//       String? origin,
//       String? education,
//       bool? children}) async {
//     try {
//       await usersRef.doc(currentUid()).update({
//         'orientation': orientation,
//         'sex': sex,
//         'relationship': relationship,
//         'age': age,
//         "diet": diet,
//         "job": job,
//         "origin": origin,
//         "education": education,
//         "children": children
//       });
//       return true;
//     } catch (e) {
//       //print('Error updating more about info: $e');
//       return false;
//     }
//   }
// }
