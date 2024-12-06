import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:les_social/landing/landing_page.dart';
import 'package:les_social/screens/mainscreen.dart';
import 'package:les_social/services/user_service.dart';
import 'package:les_social/utils/constants.dart';
import 'package:les_social/utils/providers.dart';
import 'package:les_social/view_models/theme/theme_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await initializeOneSignal();

  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize('2db43de7-52bb-45fc-8d06-12b7c07093c5');
  OneSignal.Notifications.requestPermission(true);

  runApp(
    MultiProvider(
      providers: providers,
      child: MyApp(),
    ),
  );
}

// Future<void> initializeOneSignal() async {
//   // Initialize OneSignal without await
//   OneSignal.initialize('2db43de7-52bb-45fc-8d06-12b7c07093c5');
//
//   // Configure notification permissions
//   await OneSignal.Notifications.requestPermission(true);
//
//   // Notification received handler
//   OneSignal.Notifications.addForegroundWillDisplayListener((event) {
//     print("Powiadomienie w tle: ${event.notification.notificationId}");
//     event.preventDefault();
//     event.notification;
//   });
//
//   // Notification opened handler
//   OneSignal.Notifications.addClickListener((event) {
//     print("Powiadomienie otwarte: ${event.notification.notificationId}");
//   });
// }

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn();
  }

  Future<void> _checkIfLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');
    String? userId = prefs.getString('userId');

    setState(() {
      _isLoggedIn = token != null && userId != null;
      _isLoading = false;
    });

    if (_isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final userService = Provider.of<UserService>(context, listen: false);
        userService.setUserStatus(true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: Constants.appName,
            debugShowCheckedModeBanner: false,
            theme: themeData(
              themeProvider.dark ? Constants.darkTheme : Constants.lightTheme,
            ),
            home: _isLoading
                ? Center(child: CircularProgressIndicator())
                : (_isLoggedIn ? TabScreen() : Landing()),
          );
        },
      ),
    );
  }

  ThemeData themeData(ThemeData theme) {
    return theme.copyWith(
      textTheme: GoogleFonts.nunitoTextTheme(
        theme.textTheme,
      ),
    );
  }
}
