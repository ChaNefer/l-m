// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class UpdateProfile extends StatefulWidget {
//   @override
//   _UpdateProfileState createState() => _UpdateProfileState();
// }
//
// class _UpdateProfileState extends State<UpdateProfile> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   String? gender;
//   String? orientation;
//   int? age;
//   String? beliefs;
//   String? relationship;
//   String? diet;
//   String? job;
//   String? origin;
//   String? education;
//   bool? children;
//
//   bool isLoading = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Update Profile'),
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Update Your Profile',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 20),
//               TextFormField(
//                 onChanged: (value) => gender = value,
//                 decoration: InputDecoration(labelText: 'Płeć'),
//               ),
//               TextFormField(
//                 onChanged: (value) => orientation = value,
//                 decoration: InputDecoration(labelText: 'Orientacja'),
//               ),
//               TextFormField(
//                 onChanged: (value) => age = int.tryParse(value),
//                 decoration: InputDecoration(labelText: 'Wiek'),
//               ),
//               TextFormField(
//                 onChanged: (value) => beliefs = value,
//                 decoration: InputDecoration(labelText: 'Religia'),
//               ),
//               TextFormField(
//                 onChanged: (value) => relationship = value,
//                 decoration: InputDecoration(labelText: 'Związek'),
//               ),
//               TextFormField(
//                 onChanged: (value) => diet = value,
//                 decoration: InputDecoration(labelText: 'Dieta'),
//               ),
//               TextFormField(
//                 onChanged: (value) => job = value,
//                 decoration: InputDecoration(labelText: 'Praca'),
//               ),
//               TextFormField(
//                 onChanged: (value) => origin = value,
//                 decoration: InputDecoration(labelText: 'Pochodzenie'),
//               ),
//               TextFormField(
//                 onChanged: (value) => education = value,
//                 decoration: InputDecoration(labelText: 'Wykształcenie'),
//               ),
//               TextFormField(
//                 onChanged: (value) => children = value.toLowerCase() == 'true',
//                 decoration: InputDecoration(labelText: 'Dzieci (tak/nie)'),
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () async {
//                   setState(() {
//                     isLoading = true;
//                   });
//                   final currentUser = _auth.currentUser;
//                   if (currentUser != null) {
//                     try {
//                       await _firestore.collection('update_profiles').doc(currentUser.uid).set({
//                         'gender': gender,
//                         'orientation': orientation,
//                         'age': age,
//                         'beliefs': beliefs,
//                         'relationship': relationship,
//                         'diet': diet,
//                         'job': job,
//                         'origin': origin,
//                         'education': education,
//                         'children': children,
//                       });
//                       setState(() {
//                         isLoading = false;
//                       });
//                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                         content: Text('Profile updated successfully!'),
//                       ));
//                     } catch (e) {
//                       setState(() {
//                         isLoading = false;
//                       });
//                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                         content: Text('Failed to update profile. Please try again later.'),
//                       ));
//                     }
//                   }
//                 },
//                 child: Text('Update Profile'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
