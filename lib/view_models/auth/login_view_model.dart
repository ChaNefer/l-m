import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:les_social/services/api_service.dart';

import '../../screens/mainscreen.dart';
import '../../services/auth_service.dart';
import '../../utils/validation.dart';

class LoginViewModel extends ChangeNotifier {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool validate = false;
  bool loading = false;
  String? email, password;
  FocusNode emailFN = FocusNode();
  FocusNode passFN = FocusNode();
  final ApiService apiService;
  late AuthService _authService = AuthService();

  LoginViewModel(this.apiService) {
    //print("Inicjalizacja scaffoldKey z LoginViewModel: $scaffoldKey");
    //print("Inicjalizacja formKey z LoginViewModel: $formKey");
  } // Constructor takes ApiService

  login(BuildContext context) async {
    FormState form = formKey.currentState!;
    form.save();
    if (!form.validate()) {
      validate = true;
      notifyListeners();
      showInSnackBar('Popraw błędy, zanim przejdziesz dalej.', context);
    } else {
      loading = true;
      notifyListeners();
      try {
        await _authService.loginUser(
          email: email!,
          password: password!,
          context: context,
        );
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(builder: (_) => TabScreen()),
        );
      } catch (e) {
        loading = false;
        notifyListeners();
        //print(e);
        showInSnackBar('Wystąpił błąd podczas logowania. Spróbuj ponownie.', context);
      }
      loading = false;
      notifyListeners();
    }
  }

  forgotPassword(BuildContext context) async {
    loading = true;
    notifyListeners();
    FormState form = formKey.currentState!;
    form.save();
    if (Validations.validateEmail(email) != null) {
      showInSnackBar('Podaj email, aby zresetować hasło.', context);
    } else {
      try {
        await _authService.forgotPassword(email!);
        showInSnackBar('Sprawdź swój email, aby zresetować hasło', context);
      } catch (e) {
        showInSnackBar('${e.toString()}', context);
      }
    }
    loading = false;
    notifyListeners();
  }

  setEmail(val) {
    email = val;
    notifyListeners();
  }

  setPassword(val) {
    password = val;
    notifyListeners();
  }

  void showInSnackBar(String value, BuildContext context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }
}



