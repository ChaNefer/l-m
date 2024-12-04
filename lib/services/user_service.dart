// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:les_social/services/api_service.dart';
// import 'package:les_social/services/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:les_social/services/storage_class.dart';
// import 'package:provider/provider.dart';
// import '../view_models/user/user_provider.dart';
// import 'auth_service.dart';
//
// class UserService extends Service {
//   final String baseUrl = 'https://lesmind.com';
//   late BuildContext context;
//   late ApiService apiService;
//   late AuthService _authService;
//   late StorageClass storage;
//
//   UserService(BuildContext context) {
//     // //print("Initializing UserService");
//     this.context = context;
//     _authService = AuthService();
//     storage = StorageClass();
//     apiService = ApiService(context);
//
//     // Sprawdź, czy inicjalizacja serwisów powiodła się
//     if (storage == null) {
//       // //print("Error: Storage is not initialized");
//       // throw Exception("Storage initialization failed!");
//     } else {
//       // //print("Storage initialization success!");
//     }
//
//     if (_authService == null) {
//       // //print("Error: AuthService is not initialized");
//       // throw Exception("AuthService initialization failed!");
//     } else {
//       // //print("AuthService initialization success!");
//     }
//
//     if (apiService == null) {
//       // //print("Error: ApiService is not initialized");
//       throw Exception("ApiService initialization failed!");
//     } else {
//       // //print("ApiService initialization success!");
//     }
//   }
//
//   Future<String> currentUid() async {
//     try {
//       var user = await _authService.getCurrentUser();
//       if (user != null) {
//         //print("Current user ID: ${user.id}");
//         return user.id ?? '';
//       } else {
//         //print("No current user found");
//         return '';
//       }
//     } catch (e) {
//       //print("Error getting current user: $e");
//       return '';
//     }
//   }
//
//   Future<void> setUserStatus(bool isOnline) async {
//     try {
//       var user = await _authService.getCurrentUser();
//       if (user != null) {
//         //print("Setting user status to: $isOnline");
//         await apiService.setUserStatus(isOnline);
//       } else {
//         //print("Error: User not authenticated");
//       }
//     } catch (e) {
//       //print("Error setting user status: $e");
//     }
//   }
//
//   Future<bool> updateProfile({
//     required BuildContext context,
//     File? image,
//     String? username,
//     String? bio,
//     String? country,
//     String? age,
//     String? city,
//   }) async {
//     try {
//       final token = await storage.getToken();
//       if (token == null || token.isEmpty) {
//         throw Exception('Token JWT is missing');
//       }
//
//       var data = {
//         'username': username,
//         'bio': bio,
//         'country': country,
//         'age': age,
//         'city': city,
//         if (image != null) 'photoUrl': await uploadImage('$baseUrl/api/photos/upload_image.php', image) ?? '',
//       };
//
//       var response = await http.post(
//         Uri.parse('$baseUrl/api/users/update_profile.php'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode(data),
//       );
//
//       if (response.statusCode == 200) {
//         var responseData = jsonDecode(response.body);
//
//         if (responseData['success'] == true) {
//           final userId = await _authService.getCurrentUser();
//           final user = await apiService.fetchUserData(userId?.id ?? '');
//           Provider.of<UserProvider>(context, listen: false).setUser(user);
//           return true;
//         } else {
//           return false;
//         }
//       } else {
//         return false;
//       }
//     } catch (e) {
//       return false;
//     }
//   }
//
//   Future<bool> updateMoreAbout({
//     String? dreams,
//     String? regrets,
//     String? favWoman,
//     String? children,
//     String? pets,
//     String? husband,
//     String? religion,
//     String? politics,
//     String? diet,
//     String? smoke,
//     String? drink,
//     String? sexPref,
//     String? orientation,
//     String? freeTime,
//     String? livingTogether,
//     String? parties,
//     bool? smokeCheckbox,
//     bool? drinkCheckbox,
//     bool? childrenCheckbox,
//     bool? petsCheckbox,
//     double? profileCompletion,
//   }) async {
//     try {
//       var user = await _authService.getCurrentUser();
//       if (user == null) {
//         //print("Error: User not authenticated");
//         return false;
//       }
//
//       var data = {
//         'userId': user.id,
//         'dreams': dreams,
//         'regrets': regrets,
//         'favWoman': favWoman,
//         'children': children,
//         'pets': pets,
//         'husband': husband,
//         'religion': religion,
//         'politics': politics,
//         'diet': diet,
//         'smoke': smoke,
//         'drink': drink,
//         'sexPref': sexPref,
//         'orientation': orientation,
//         'freeTime': freeTime,
//         'livingTogether': livingTogether,
//         'parties': parties,
//         'smokeCheckbox': smokeCheckbox.toString(),
//         'drinkCheckbox': drinkCheckbox.toString(),
//         'childrenCheckbox': childrenCheckbox.toString(),
//         'petsCheckbox': petsCheckbox.toString(),
//         'profileCompletion': profileCompletion.toString(),
//       };
//
//       //print("Data to send for updateMoreAbout: $data");
//
//       var url = '$baseUrl/update_more_about.php';
//       var response = await http.post(
//         Uri.parse(url),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(data),
//       );
//
//       //print("Response status for updateMoreAbout: ${response.statusCode}");
//       //print("Response body for updateMoreAbout: ${response.body}");
//
//       if (response.statusCode == 200) {
//         var responseData = jsonDecode(response.body);
//         //print("Response data for updateMoreAbout: $responseData");
//
//         if (responseData['success'] != null) {
//           //print('Profile updated successfully with more info');
//           return true;
//         } else {
//           //print('Error: ${responseData['error']}');
//           return false;
//         }
//       } else {
//         //print('HTTP Error ${response.statusCode}: ${response.reasonPhrase}');
//         return false;
//       }
//     } catch (e) {
//       //print('Error updating profile with more info: $e');
//       return false;
//     }
//   }
//
// // Add more methods as needed
// }



import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:les_social/services/api_service.dart';
import 'package:les_social/services/storage_class.dart';
import 'auth_service.dart';

class UserService extends ChangeNotifier {
  final String baseUrl = 'https://lesmind.com';
  late ApiService apiService;
  late AuthService _authService;
  late StorageClass storage;

  UserService(BuildContext context) {
    _authService = AuthService();
    storage = StorageClass();
    apiService = ApiService(context);
  }

  Future<String> currentUid() async {
    try {
      var user = await _authService.getCurrentUser();
      if (user != null) {
        return user.id ?? '';
      } else {
        return '';
      }
    } catch (e) {
      return '';
    }
  }

  Future<void> setUserStatus(bool isOnline) async {
    try {
      var user = await _authService.getCurrentUser();
      if (user != null) {
        await apiService.setUserStatus(isOnline);
      } else {
        // Handle user not authenticated
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<bool> updateProfile({
    File? image,
    String? username,
    String? bio,
    String? country,
    String? age,
    String? city,
  }) async {
    try {
      final token = await storage.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token JWT is missing');
      }

      var data = {
        'username': username,
        'bio': bio,
        'country': country,
        'age': age,
        'city': city,
        if (image != null) 'photoUrl': await uploadImage('$baseUrl/api/photos/upload_photo.php', image) ?? '',
      };

      var response = await http.post(
        Uri.parse('$baseUrl/api/users/update_profile.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          final userId = await _authService.getCurrentUser();
          final user = await apiService.fetchUserData(userId?.id ?? '');
          notifyListeners(); // Notify listeners about the update
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateMoreAbout({
    String? dreams,
    String? regrets,
    String? favWoman,
    String? children,
    String? pets,
    String? husband,
    String? religion,
    String? politics,
    String? diet,
    String? smoke,
    String? drink,
    String? sexPref,
    String? orientation,
    String? freeTime,
    String? livingTogether,
    String? parties,
    bool? smokeCheckbox,
    bool? drinkCheckbox,
    bool? childrenCheckbox,
    bool? petsCheckbox,
    double? profileCompletion,
  }) async {
    try {
      var user = await _authService.getCurrentUser();
      if (user == null) {
        return false;
      }

      var data = {
        'userId': user.id,
        'dreams': dreams,
        'regrets': regrets,
        'favWoman': favWoman,
        'children': children,
        'pets': pets,
        'husband': husband,
        'religion': religion,
        'politics': politics,
        'diet': diet,
        'smoke': smoke,
        'drink': drink,
        'sexPref': sexPref,
        'orientation': orientation,
        'freeTime': freeTime,
        'livingTogether': livingTogether,
        'parties': parties,
        'smokeCheckbox': smokeCheckbox.toString(),
        'drinkCheckbox': drinkCheckbox.toString(),
        'childrenCheckbox': childrenCheckbox.toString(),
        'petsCheckbox': petsCheckbox.toString(),
        'profileCompletion': profileCompletion.toString(),
      };

      var url = '$baseUrl/update_more_about.php';
      var response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['success'] != null) {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Add more methods as needed

  // Helper method to upload image
  Future<String?> uploadImage(String url, File image) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url))
        ..files.add(await http.MultipartFile.fromPath('file', image.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseString = await response.stream.bytesToString();
        var responseData = jsonDecode(responseString);
        return responseData['photoUrl'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}



