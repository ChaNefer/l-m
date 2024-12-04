import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:les_social/auth/register/profile_pic.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/storage_class.dart';

class RegisterViewModel extends ChangeNotifier {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool validate = false;
  bool loading = false;
  String? username, email, country, city, password, cPassword, age;
  FocusNode usernameFN = FocusNode();
  FocusNode emailFN = FocusNode();
  FocusNode countryFN = FocusNode();
  FocusNode cityFN = FocusNode();
  FocusNode passFN = FocusNode();
  FocusNode cPassFN = FocusNode();
  FocusNode ageFN = FocusNode();
  AuthService auth = AuthService();

  RegisterViewModel() {
    //print("Inicjalizacja scaffoldKey z RegisterViewModel: $scaffoldKey");
    //print("Inicjalizacja formKey z RegisterViewModel: $formKey");
  }




  Future<void> register(BuildContext context) async {
    FormState form = formKey.currentState!;
    form.save();
    if (!form.validate()) {
      validate = true;
      notifyListeners();
      showInSnackBar('Popraw błędy, zanim pójdziesz dalej.', context);
    } else {
      if (password == cPassword) {
        loading = true;
        notifyListeners();
        try {
          final response = await auth.createUser(
            username: username!,
            email: email!,
            password: password!,
            country: country!,
            age: age!,
            city: city!,
          );

          bool success = response['success'] as bool? ?? false;
          if (success) {
            String userId = response['user_id'].toString(); // Ensure userId is a string
            String token = response['token'].toString(); // Ensure token is a string

            // Save userId and token to SharedPreferences
            final storage = StorageClass();
            await storage.saveUserId(userId);
            await storage.saveToken(token);

            Navigator.of(context).pushReplacement(
              CupertinoPageRoute(
                builder: (_) => ProfilePicture(userId: userId),
              ),
            );
          } else {
            throw Exception(response['message'] ?? 'Failed to register user');
          }
        } catch (e) {
          loading = false;
          notifyListeners();
          showInSnackBar(e.toString(), context);
        }
        loading = false;
        notifyListeners();
      } else {
        showInSnackBar('Hasła do siebie nie pasują', context);
      }
    }
  }

  setEmail(val) {
    email = val;
    notifyListeners();
  }

  setPassword(val) {
    password = val;
    notifyListeners();
  }

  setName(val) {
    username = val;
    notifyListeners();
  }

  setConfirmPass(val) {
    cPassword = val;
    notifyListeners();
  }

  setCountry(val) {
    country = val;
    notifyListeners();
  }

  setCity(val) {
    city = val;
    notifyListeners();
  }

  setAge(val) {
    age = val;
    notifyListeners();
  }

  void setLoading(bool value) {
    loading = value;
    notifyListeners();
  }

  void showInSnackBar(String value, context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }
}
