// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:ionicons/ionicons.dart';
// import 'package:les_social/screens/mainscreen.dart';
// import 'package:loading_overlay/loading_overlay.dart';
// import 'package:provider/provider.dart';
// import 'package:les_social/components/password_text_field.dart';
// import 'package:les_social/components/text_form_builder.dart';
// import 'package:les_social/utils/validation.dart';
// import 'package:les_social/widgets/indicators.dart';
// import '../view_models/update_profile/update_profile_view_model.dart';
//
// class MoreAbout extends StatefulWidget {
//   @override
//   _MoreAboutState createState() => _MoreAboutState();
// }
//
// class _MoreAboutState extends State<MoreAbout> {
//
//   @override
//   Widget build(BuildContext context) {
//     UpdateProfileViewModel viewModel = Provider.of<UpdateProfileViewModel>(context);
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [Color(0xFF4D1473), Color(0xFF153F59)],
//         ),
//       ),
//       child: LoadingOverlay(
//         progressIndicator: circularProgress(context),
//         isLoading: viewModel.loading,
//         child: Scaffold(
//           key: viewModel.scaffoldKey,
//           body: ListView(
//             padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
//             children: [
//               SizedBox(height: MediaQuery.of(context).size.height / 10),
//               Text(
//                 'Więcej o mnie',
//                 style: GoogleFonts.nunitoSans(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 25.0,
//                 ),
//               ),
//               SizedBox(height: 30.0),
//               buildForm(viewModel, context),
//               SizedBox(height: 30.0),
//
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   buildForm(UpdateProfileViewModel viewModel, BuildContext context) {
//     return Form(
//       key: viewModel.formKey,
//       autovalidateMode: AutovalidateMode.onUserInteraction,
//       child: Column(
//         children: [
//           TextFormBuilder(
//             enabled: !viewModel.loading,
//             prefix: Ionicons.person_outline,
//             hintText: "Orientacja",
//             textInputAction: TextInputAction.next,
//             validateFunction: Validations.validateName,
//             onSaved: (String val) {
//               viewModel.setOrientation(val);
//             },
//             focusNode: viewModel.orientationFN,
//             nextFocusNode: viewModel.sexFN,
//           ),
//           SizedBox(height: 20.0),
//           TextFormBuilder(
//             enabled: !viewModel.loading,
//             prefix: Ionicons.mail_outline,
//             hintText: "Płeć",
//             textInputAction: TextInputAction.next,
//             validateFunction: Validations.validateEmail,
//             onSaved: (String val) {
//               viewModel.setSex(val);
//             },
//             focusNode: viewModel.sexFN,
//             nextFocusNode: viewModel.ageFN,
//           ),
//           SizedBox(height: 20.0),
//           TextFormBuilder(
//             enabled: !viewModel.loading,
//             prefix: Ionicons.pin_outline,
//             hintText: "Wiek",
//             textInputAction: TextInputAction.next,
//             validateFunction: Validations.validateName,
//             onSaved: (String val) {
//               viewModel.setAge(val);
//             },
//             focusNode: viewModel.ageFN,
//             nextFocusNode: viewModel.relationshipFN,
//           ),
//           SizedBox(height: 20.0),
//           PasswordFormBuilder(
//             enabled: !viewModel.loading,
//             prefix: Ionicons.lock_closed_outline,
//             hintText: "Czy jesteś w związku?",
//             textInputAction: TextInputAction.next,
//             validateFunction: Validations.validatePassword,
//             onSaved: (String val) {
//               viewModel.setRelationship(val);
//             },
//             focusNode: viewModel.relationshipFN,
//           ),
//           // SizedBox(height: 20.0),
//           // PasswordFormBuilder(
//           //   enabled: !viewModel.loading,
//           //   prefix: Ionicons.lock_open_outline,
//           //   hintText: "Powtórz hasło ",
//           //   textInputAction: TextInputAction.done,
//           //   validateFunction: Validations.validatePassword,
//           //   submitAction: () => viewModel.register(context),
//           //   obscureText: true,
//           //   onSaved: (String val) {
//           //     viewModel.setConfirmPass(val);
//           //   },
//           //   focusNode: viewModel.cPassFN,
//           // ),
//           SizedBox(height: 25.0),
//           Container(
//             height: 45.0,
//             width: 180.0,
//             child: ElevatedButton(
//               style: ButtonStyle(
//                 shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                   RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(40.0),
//                   ),
//                 ),
//                 backgroundColor: MaterialStateProperty.all<Color>(
//                     Theme.of(context).colorScheme.secondary),
//               ),
//               child: Text(
//                 'zapisz'.toUpperCase(),
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 12.0,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TabScreen()))
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
//
