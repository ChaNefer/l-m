import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:les_social/translations/date_mesaage_pl.dart';
import 'package:provider/provider.dart';
import 'package:les_social/components/life_cycle_event_handler.dart';
import 'package:les_social/landing/landing_page.dart';
import 'package:les_social/screens/mainscreen.dart';
import 'package:les_social/services/user_service.dart';
import 'package:les_social/utils/config.dart';
import 'package:les_social/utils/constants.dart';
import 'package:les_social/utils/providers.dart';
import 'package:les_social/view_models/theme/theme_view_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DateMessagesPl.registerLocale();

  Future<String> fetchSecretKey() async {
    final String baseUrl = 'https://lesmind.com/api/secret_config.php';

    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        // Pobranie zawartości odpowiedzi
        Map<String, dynamic> data = jsonDecode(response.body);
        // Sprawdzenie czy klucz został poprawnie pobrany
        if (data.containsKey('secret_config')) {
          return data['secret_config'];
        } else {
          throw Exception('Nie udało się pobrać klucza.');
        }
      } else {
        throw Exception('Błąd podczas pobierania klucza: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Błąd podczas pobierania klucza: $e');
    }
  }

  try {
    String secretKey = await fetchSecretKey();
    //print('Pobrany klucz: $secretKey');
    // Tutaj możesz wykorzystać pobrany klucz do dalszych operacji
  } catch (e) {
    //print('Wystąpił błąd: $e');
  }

  runApp(
    MultiProvider(
      providers: providers,
      child: MyApp(),
    ),
  );
}

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
    String? userId = prefs.getString('userId'); // Pobranie ID użytkownika

    setState(() {
      _isLoggedIn = token != null && userId != null;
      _isLoading = false;
    });

    // Initialize UserService and set user status after the login status is checked
    if (_isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final userService = Provider.of<UserService>(context, listen: false);
        userService.setUserStatus(true); // Ustaw status użytkownika
        WidgetsBinding.instance.addObserver(
          LifecycleEventHandler(
            detachedCallBack: () async =>
            await userService.setUserStatus(false),
            resumeCallBack: () async => await userService.setUserStatus(true),
          ),
        );
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



