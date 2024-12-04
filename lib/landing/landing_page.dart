// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:les_social/auth/login/login.dart';
// import 'package:les_social/auth/register/register.dart';
//
// import '../components/my_policy_button.dart';
//
// class Landing extends StatefulWidget {
//   @override
//   _LandingState createState() => _LandingState();
// }
//
// class _LandingState extends State<Landing> {
//
//   final CarouselController carouselController = CarouselController();
//   int currentIndex = 0;
//   bool isLoading = false;
//
//   List<Map<String, dynamic>> imageList = [
//     {"id": 1, "image_path": 'assets/images/gay.jpg'},
//     {"id": 2, "image_path": 'assets/images/les.jpg'},
//     {"id": 3, "image_path": 'assets/images/les1.jpg'},
//     {"id": 4, "image_path": 'assets/images/les2.jpg'},
//     {"id": 5, "image_path": 'assets/images/les3.jpg'},
//     {"id": 6, "image_path": 'assets/images/les4.jpg'},
//     {"id": 7, "image_path": 'assets/images/les5.jpg'},
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [Color(0xFF4D1473), Color(0xFF153F59)],
//         ),
//       ),
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         body: Padding(
//           padding: const EdgeInsets.all(4.0),
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 70),
//                 Image.asset("assets/images/lesmind.png", height: 80),
//                 const SizedBox(height: 5),
//                 Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(22),
//                   ),
//                   child: Column(
//                     children: [
//                       const SizedBox(height: 20),
//                       Stack(
//                         alignment: Alignment.topCenter,
//                         children: [
//                           CarouselSlider(
//                             items: imageList
//                                 .map(
//                                   (item) => Image.asset(
//                                 item['image_path']!,
//                                 fit: BoxFit.cover,
//                                 width: double.infinity,
//                               ),
//                             )
//                                 .toList(),
//                             carouselController: carouselController,
//                             options: CarouselOptions(
//                               height: 400,
//                               autoPlayInterval: Duration(seconds: 4),
//                               scrollPhysics: const BouncingScrollPhysics(),
//                               autoPlay: true,
//                               aspectRatio: 0.7,
//                               viewportFraction: 1,
//                               onPageChanged: (index, _) {
//                                 setState(() {
//                                   currentIndex = index;
//                                 });
//                               },
//                             ),
//                           ),
//                           Positioned(
//                             bottom: 10,
//                             left: 0,
//                             right: 0,
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: imageList.asMap().entries.map((entry) {
//                                 return GestureDetector(
//                                   onTap: () => carouselController.animateToPage(entry.key),
//                                   child: Container(
//                                     width: 10,
//                                     height: 7.0,
//                                     margin: const EdgeInsets.symmetric(horizontal: 3.0),
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(10),
//                                       color: currentIndex == entry.key ? Colors.red : Colors.teal,
//                                     ),
//                                   ),
//                                 );
//                               }).toList(),
//                             ),
//                           ),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: ElevatedButton(
//                                   onPressed: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => Login(),
//                                       ),
//                                     );
//                                     setState(() {
//                                       isLoading = true;
//                                     });
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     primary: Colors.transparent,
//                                     onPrimary: Colors.white,
//                                     side: BorderSide(color: Colors.black),
//                                   ),
//                                   child: const Text("Zaloguj się", style: TextStyle(color: Colors.white)),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: ElevatedButton(
//                                   onPressed: () async {
//                                     String? result = await Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => Register(),
//                                       ),
//                                     );
//                                     if (result == null) {
//                                       ScaffoldMessenger.of(context).showSnackBar(
//                                         SnackBar(
//                                           content: Text("Rejestracja zakończona pomyślnie!"),
//                                           backgroundColor: Colors.green,
//                                         ),
//                                       );
//                                     } else {
//                                       ScaffoldMessenger.of(context).showSnackBar(
//                                         SnackBar(
//                                           content: Text("Wystąpił błąd podczas rejestracji: $result"),
//                                           backgroundColor: Colors.red,
//                                         ),
//                                       );
//                                     }
//                                     setState(() {
//                                       isLoading = true;
//                                     });
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     foregroundColor: Colors.white,
//                                     backgroundColor: Colors.transparent,
//                                     side: BorderSide(color: Colors.black),
//                                   ),
//                                   child: const Text("Zarejestruj się", style: TextStyle(color: Colors.white)),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 20),
//                         ],
//                       ),
//                       const SizedBox(height: 20),
//                     ],
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 25.0),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Divider(
//                           thickness: 1,
//                           color: Colors.green.shade700,
//                         ),
//                       ),
//                       const SizedBox(height: 60),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 10.0),
//                         child: Text(
//                           "Lub zaloguj się przez:",
//                           style: TextStyle(
//                             color: Colors.green.shade700,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         child: Divider(
//                           thickness: 1,
//                           color: Colors.green.shade700,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 25),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Image.asset(
//                       "assets/images/google2.png",
//                       height: 40,
//                     ),
//                     const SizedBox(width: 25),
//                     Image.asset(
//                       "assets/images/apple.png",
//                       height: 40,
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 30),
//                 TextButton(
//                   onPressed: () => throw Exception(),
//                   child: const Text("Throw Test Exception"),
//                 ),
//                 MyPolicyButton(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ionicons/ionicons.dart';
import 'package:les_social/auth/register/register.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login/login.dart';
import '../pages/profile.dart';

class Landing extends StatefulWidget {
  @override
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> {

  late bool  _isLoggedIn;
  Map _userObj = {};

  @override
  void initState() {
    super.initState();
    // _checkIfLoggedIn();
  }

  // void _checkIfLoggedIn() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? token = prefs.getString('jwtToken');
  //   String? userId = prefs.getString('userId');
  //
  //   if (token != null && userId != null) {
  //     // Token i userId istnieją, przejdź do ekranu profilu
  //     Navigator.of(context).pushReplacement(
  //       CupertinoPageRoute(builder: (_) => Profile(profileId: userId,)),  // Zastąp `ProfileScreen` odpowiednim ekranem profilu
  //     );
  //   } else {
  //     // Token nie istnieje, pozostań na ekranie startowym
  //     setState(() {
  //       _isLoggedIn = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Image.asset(
                  'assets/images/lesmind.png',
                  height: 100.0,
                  width: 300.0,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 80,),

            // Facebook button
            // GestureDetector(
            //   onTap: () {
            //     FacebookAuth.instance.login(
            //         permissions: ["public_profile", "email"]
            //     ).then((value) {
            //       FacebookAuth.instance.getUserData().then((userData) async {
            //         setState(() {
            //           _isLoggedIn = true;
            //           _userObj = userData;
            //         });
            //       });
            //     });
            //   },
            //   child: Container(
            //     height: 45.0,
            //     width: 150.0,
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(40.0),
            //       border: Border.all(color: Colors.grey),
            //       gradient: LinearGradient(
            //         begin: Alignment.topRight,
            //         end: Alignment.bottomLeft,
            //         colors: [
            //           Theme.of(context).colorScheme.secondary,
            //           Color(0xff597FDB),
            //         ],
            //       ),
            //     ),
            //     child: Center(
            //       child: Text(
            //         'Kontynuuj przez:'.toUpperCase(),
            //         style: TextStyle(
            //           fontWeight: FontWeight.w900,
            //           color: Colors.white,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 25.0),
            //   child: Row(
            //     children: [
            //       Expanded(
            //         child: Divider(
            //           thickness: 0.8,
            //         ),
            //       ),
            //       Padding(
            //         padding: const EdgeInsets.symmetric(horizontal: 10.0),
            //         child:Text("Kontynuuj przez"),
            //       ),
            //       Expanded(
            //         child: Divider(
            //           thickness: 0.8,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            SizedBox(height: 70,),

            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: [
            //     IconButton(
            //       icon: Icon(
            //         Ionicons.logo_google,
            //         size: 50.0,
            //       ),
            //       onPressed: signWithGoogle,
            //     ),
            //     IconButton(
            //       icon: Icon(
            //         Ionicons.logo_apple,
            //         size: 50.0,
            //       ),
            //       onPressed: signWithGoogle,
            //     ),
            //   ],
            // )
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0.0,
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    CupertinoPageRoute(
                      builder: (_) => Register(),
                    ),
                  );
                },
                child: Container(
                  height: 45.0,
                  width: 130.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40.0),
                    border: Border.all(color: Colors.grey),
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Theme.of(context).colorScheme.secondary,
                        Color(0xff597FDB),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'zarejestruj się'.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    CupertinoPageRoute(
                      builder: (_) => Login(),
                    ),
                  );
                },
                child: Container(
                  height: 45.0,
                  width: 130.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40.0),
                    border: Border.all(color: Colors.white),
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Theme.of(context).colorScheme.secondary,
                        Color(0xff597FDB),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'zaloguj się'.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Future<UserCredential?> signWithGoogle() async {
  //   final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //   final GoogleSignInAuthentication? googleAuth = await googleUser!.authentication;
  //   final credential = GoogleAuthProvider.credential(
  //     accessToken: googleAuth?.accessToken,
  //     idToken: googleAuth?.idToken
  //   );
  //
  //   final userCredential = FirebaseAuth.instance.signInWithCredential(credential);
  //   return userCredential;
  // }
}

