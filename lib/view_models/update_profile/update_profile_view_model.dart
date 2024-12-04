// import 'package:flutter/material.dart';
// import 'package:les_social/models/more_about_model.dart';
// import 'package:les_social/services/update_profile_service.dart';
//
// class UpdateProfileViewModel extends ChangeNotifier {
//   GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
//   GlobalKey<FormState> formKey = GlobalKey<FormState>();
//   bool loading = false;
//   UpdateProfileService moreAboutService = UpdateProfileService();
//   MoreAboutModel moreAboutModel = MoreAboutModel();
//   late String? orientation = '';
//   late String? sex = '';
//   late String? relationship = '';
//   late String? age = '';
//   late String? diet = '';
//   late String? job = '';
//   late String? origin = '';
//   late String? education = '';
//   bool? children;
//
//   late FocusNode orientationFN;
//   late FocusNode sexFN;
//   late FocusNode ageFN;
//   late FocusNode relationshipFN;
//   late FocusNode dietFN;
//   late FocusNode jobFN;
//   late FocusNode originFN;
//   late FocusNode educationFN;
//   late FocusNode childernFN;
//
//   UpdateProfileViewModel() {
//     orientationFN = FocusNode();
//     sexFN = FocusNode();
//     ageFN = FocusNode();
//     relationshipFN = FocusNode();
//     dietFN = FocusNode();
//     jobFN = FocusNode();
//     originFN = FocusNode();
//     educationFN = FocusNode();
//     childernFN = FocusNode();
//   }
//
//   @override
//   void dispose() {
//     orientationFN.dispose();
//     sexFN.dispose();
//     ageFN.dispose();
//     relationshipFN.dispose();
//     dietFN.dispose();
//     jobFN.dispose();
//     originFN.dispose();
//     educationFN.dispose();
//     childernFN.dispose();
//     super.dispose();
//   }
//
//   void initFields() {
//     //print('Initializing fields');
//     if (orientation == null) {
//       orientation = moreAboutModel.orientation ?? '';
//     }
//     if (sex == null) {
//       sex = moreAboutModel.sex ?? '';
//     }
//     if (relationship == null) {
//       relationship = moreAboutModel.relationship ?? '';
//     }
//     if (age == null) {
//       age = moreAboutModel.age ?? '';
//     }
//   }
//
//   void updateAbout(BuildContext context) async {
//     FormState form = formKey.currentState!;
//
//     if (!form.validate()) {
//       showInSnackBar('Please fix the errors in red before submitting.', context);
//       return;
//     }
//     loading = true;
//     notifyListeners();
//     try {
//       form.save();
//       bool success = await moreAboutService.updateMoreInfo(
//         orientation: orientation,
//         sex: sex,
//         age: age,
//         relationship: relationship,
//         diet: diet,
//         job: relationship,
//         origin: origin,
//         education: education,
//         children: children,
//       );
//
//       if (success) {
//         Navigator.pop(context);
//       } else {
//         showInSnackBar('Failed to update profile.', context);
//       }
//     } catch (e) {
//       showInSnackBar('An error occurred: $e', context);
//     } finally {
//       loading = false;
//       notifyListeners();
//     }
//   }
//
//   void saveChanges(BuildContext context) {
//     final currentState = formKey.currentState;
//     if (currentState != null && currentState.validate()) {
//       currentState.save();
//
//       // Check if fields are initialized before updating moreAboutModel
//       if (orientation != null && sex != null && age != null && relationship != null) {
//         // Update moreAboutModel with new data
//         moreAboutModel.orientation = orientation;
//         moreAboutModel.sex = sex;
//         moreAboutModel.relationship = relationship;
//         moreAboutModel.age = age;
//
//         // Initialize fields from moreAboutModel if they are empty
//         initFields();
//         notifyListeners();
//
//         // Call the method to update the data
//         updateAbout(context);
//       }
//     }
//   }
//
//   void showInSnackBar(String value, BuildContext context) {
//     ScaffoldMessenger.of(context).removeCurrentSnackBar();
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
//   }
//
//   void setOrientation(String val) {
//     //print('Orientation set to: $val');
//     orientation = val;
//     notifyListeners();
//   }
//
//   void setSex(String val) {
//     //print('Sex set to: $val');
//     sex = val;
//     notifyListeners();
//   }
//
//   void setRelationship(String val) {
//     //print('Relation set to: $val');
//     relationship = val;
//     notifyListeners();
//   }
//
//   void setAge(String val) {
//     //print('Age value received: $val');
//     age = val;
//     notifyListeners();
//   }
// }
