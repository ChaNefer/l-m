import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:les_social/services/storage_class.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  final String baseUrl = 'https://lesmind.com';
  String? _accessToken; // Przechowuje aktualny token JWT
  final cookieJar = CookieJar();
  StorageClass storage = StorageClass();

  // Pobieranie klucza sekretnego
  Future<String> fetchSecretKey() async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/secret_config.php'));
    if (response.statusCode == 200) {
      return response.body; // Klucz jest zwracany jako ciąg znaków
    } else {
      throw Exception('Failed to fetch secret key');
    }
  }

  // Pobieranie danych bieżącego użytkownika
  Future<UserModel?> getCurrentUser() async {
    try {
      // Pobranie ID użytkownika z lokalnego magazynu
      final userId = await storage.getUserId();
      if (userId == null) throw Exception('No userId stored');
      // Pobranie ciasteczek z cookieJar
      final cookies = await cookieJar.loadForRequest(Uri.parse(baseUrl));
      // Tworzenie nagłówka z ciasteczkami
      final cookiesHeader =
          cookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');
      // Wykonanie żądania HTTP GET z nagłówkiem cookies
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/get_user.php?userId=$userId'),
        headers: {
          'Cookie': cookiesHeader,
        },
      );

      // //print('Odpowiedź serwera: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        // Parsowanie odpowiedzi JSON do obiektu UserModel
        return UserModel.fromJson(jsonDecode(response.body));
      } else {
        //print('Failed to fetch user: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      //print('Error fetching user: $e');
      return null;
    }
  }

  // Generowanie tokenu JWT
  String generateAndSaveToken(int userId) {
    String secretKey = "https://lesmind.com/api/secret_key.php";
    final jwt = JWT({
      'userId': userId,
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    });
    String accessToken = jwt.sign(SecretKey(secretKey));

    // Zapisanie tokenu do SharedPreferences
    storage.saveToken(accessToken); // Używając twojej klasy StorageClass
    //print("Wygenerowany i zapisany token: $accessToken");
    return accessToken;
  }

  // Rejestracja użytkownika
  Future<Map<String, dynamic>> createUser({
    String? username,
    String? email,
    String? password,
    String? country,
    String? age,
    String? city,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users/register.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
          'country': country,
          'age': age,
          'city': city,
        }),
      );

      //print('Response status: ${response.statusCode}');
      // //print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final success = data['success'] as bool? ?? false;

        if (success) {
          final userId = data['user_id'].toString();
          final token = data['token'] as String?;

          // Save userId and token in SharedPreferences
          final storage = StorageClass();
          await storage.saveUserId(userId);
          if (token != null) {
            await storage.saveToken(token);
          }

          return data;
        } else {
          throw Exception(data['message'] ?? 'Failed to register user');
        }
      } else {
        throw Exception('Failed to register user');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<bool> loginUser({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      // //print('Odpowiedź serwera: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Debugowanie: Sprawdź, co jest w danych
        // //print('Odpowiedź serwera (zdekodowane): $data');

        // Sprawdź, czy odpowiedź zawiera dane użytkownika i token JWT
        final userId = data['user']?['id'] as String?;
        final jwtToken = data['token'] as String?;

        // Debugowanie: Zapisz wartości userId i tokenu
        //print('userId: $userId');
        //print('jwtToken: $jwtToken');

        if (userId != null && jwtToken != null && jwtToken.isNotEmpty) {
          await storage.saveToken(jwtToken);
          await storage.saveUserId(userId);

          //print('User ID zapisany: $userId');
          //print('Token JWT zapisany: $jwtToken');

          return true;
        } else {
          //print('Nie udało się pobrać userId lub tokenu JWT z odpowiedzi');
          return false;
        }
      } else {
        //print('Logowanie nieudane: ${response.statusCode}, Powód: ${response.reasonPhrase}');
        return false;
      }
    } catch (e) {
      if (e is SocketException) {
        //print('Błąd: Brak połączenia z internetem');
      } else if (e is FormatException) {
        //print('Błąd: Niewłaściwy format odpowiedzi serwera');
      } else {
        //print('Błąd: $e');
      }
      return false;
    }
  }

  Future<http.Response> makeAuthenticatedRequest(String endpoint, {Map<String, String>? additionalHeaders}) async {
    final storage = StorageClass();
    final token = await storage.getToken();
    //print("Token JWT pobrany: $token");

    if (token == null) {
      throw Exception('Brak tokenu JWT');
    }

    // Bazowe nagłówki
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // Dodanie opcjonalnych nagłówków, jeśli zostały przekazane
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/users/login.php'),
      headers: headers,
    );

    return response;
  }

  // Resetowanie hasła
  Future<void> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users/forgot_password.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send password reset email');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

// Wylogowanie użytkownika
  Future<void> logout() async {
    try {
      // Pobranie ciasteczek z cookieJar
      final uri = Uri.parse('$baseUrl/api/users/logout.php');
      final cookies = await cookieJar.loadForRequest(uri);

      //print('Ciasteczka przed wysłaniem żądania logout: ${cookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ')}');

      if (cookies.isEmpty) {
        //print('Brak ciasteczek do wysłania. Upewnij się, że sesja jest aktywna.');
      }

      // Wysłanie żądania wylogowania do serwera z ciasteczkami
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Cookie': cookies
              .map((cookie) => '${cookie.name}=${cookie.value}')
              .join('; '),
        },
      );

      //print('Odpowiedź serwera podczas wylogowania: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Nie udało się wylogować');
      }

      // Usunięcie danych użytkownika z lokalnego magazynu za pomocą StorageClass
      final storage = StorageClass();
      await storage.clear();
      //print('Użytkownik wylogowany, a dane lokalne usunięte.');

      // Wyczyść ciasteczka z cookieJar
      await cookieJar.deleteAll();
      //print('Wszystkie ciasteczka usunięte z cookieJar.');
    } catch (e) {
      //print('Błąd podczas wylogowania: $e');
      throw Exception('Błąd: $e');
    }
  }

  Future<String> _getCookiesHeader() async {
    // Await the future to get the list of cookies
    final cookies = await cookieJar.loadForRequest(Uri.parse(baseUrl));

    // Map the list of cookies to a string in the format 'name=value'
    return cookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');
  }

  // Obsługa błędów autoryzacji
  String handleAuthError(String e) {
    if (e.contains("weak_password")) {
      return "Hasło jest zbyt słabe";
    } else if (e.contains("invalid_email")) {
      return "Niepoprawny Email";
    } else if (e.contains("email_already_in_use")) {
      return "Adres jest już w użyciu.";
    } else if (e.contains("network_error")) {
      return "Sprawdź połączenie z siecią.";
    } else if (e.contains("user_not_found")) {
      return "Niepoprawne dane logowania. Użytkownik nie znaleziony.";
    } else if (e.contains("wrong_password")) {
      return "Niepoprawne hasło.";
    } else if (e.contains("requires_recent_login")) {
      return 'Ta operacja wymaga ponownego logowania. Zaloguj się ponownie i spróbuj ponownie.';
    } else {
      return e;
    }
  }
}
