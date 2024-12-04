import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:les_social/services/api_service.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http; // Import the http library
import 'package:les_social/components/password_text_field.dart';
import 'package:les_social/components/text_form_builder.dart';
import 'package:les_social/utils/validation.dart';
import 'package:les_social/view_models/auth/register_view_model.dart';
import 'package:les_social/widgets/indicators.dart';

import '../../services/auth_service.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  // Method to send registration data to your PHP backend
  late ApiService apiService;
  AuthService auth = AuthService();


  @override
  void initState() {
    super.initState();
    apiService = ApiService(context);
  }

  @override
  Widget build(BuildContext context) {
    RegisterViewModel viewModel = Provider.of<RegisterViewModel>(context);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4D1473), Color(0xFF153F59)],
        ),
      ),
      child: LoadingOverlay(
        progressIndicator: circularProgress(context),
        isLoading: viewModel.loading,
        child: Scaffold(
          key: viewModel.scaffoldKey,
          body: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
            children: [
              SizedBox(height: MediaQuery.of(context).size.height / 10),
              Text(
                'Witaj w LesMind!',
                style: GoogleFonts.nunitoSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0,
                ),
              ),
              SizedBox(height: 30.0),
              buildForm(viewModel, context),
              SizedBox(height: 30.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Jesteś już z nami?  '),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Zaloguj się',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildForm(RegisterViewModel viewModel, BuildContext context) {
    return Form(
      key: viewModel.formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          TextFormBuilder(
            enabled: !viewModel.loading,
            prefix: Ionicons.person_outline,
            hintText: "Nazwa użytkownika",
            textInputAction: TextInputAction.next,
            validateFunction: Validations.validateName,
            onSaved: (String val) {
              viewModel.setName(val);
            },
            focusNode: viewModel.usernameFN,
            nextFocusNode: viewModel.emailFN,
          ),
          SizedBox(height: 20.0),
          TextFormBuilder(
            enabled: !viewModel.loading,
            prefix: Ionicons.mail_outline,
            hintText: "Email",
            textInputAction: TextInputAction.next,
            validateFunction: Validations.validateEmail,
            onSaved: (String val) {
              viewModel.setEmail(val);
            },
            focusNode: viewModel.emailFN,
            nextFocusNode: viewModel.countryFN,
          ),
          SizedBox(height: 20.0),
          TextFormBuilder(
            enabled: !viewModel.loading,
            prefix: Ionicons.pin_outline,
            hintText: "Kraj",
            textInputAction: TextInputAction.next,
            validateFunction: Validations.validateName,
            onSaved: (String val) {
              viewModel.setCountry(val);
            },
            focusNode: viewModel.countryFN,
            nextFocusNode: viewModel.cityFN,
          ),
          SizedBox(height: 20.0),
          TextFormBuilder(
            enabled: !viewModel.loading,
            prefix: Ionicons.locate_outline,
            hintText: "Miasto",
            textInputAction: TextInputAction.next,
            validateFunction: Validations.validateName,
            onSaved: (String val) {
              viewModel.setCity(val);
            },
            focusNode: viewModel.cityFN,
            nextFocusNode: viewModel.passFN,
          ),
          SizedBox(height: 20.0),
          PasswordFormBuilder(
            enabled: !viewModel.loading,
            prefix: Ionicons.lock_closed_outline,
            suffix: Ionicons.eye_outline,
            hintText: "Hasło",
            textInputAction: TextInputAction.next,
            validateFunction: Validations.validatePassword,
            obscureText: true,
            onSaved: (String val) {
              viewModel.setPassword(val);
            },
            focusNode: viewModel.passFN,
            nextFocusNode: viewModel.cPassFN,
          ),
          SizedBox(height: 20.0),
          PasswordFormBuilder(
            enabled: !viewModel.loading,
            prefix: Ionicons.lock_open_outline,
            hintText: "Powtórz hasło ",
            textInputAction: TextInputAction.done,
            validateFunction: Validations.validatePassword,
            obscureText: true,
            onSaved: (String val) {
              viewModel.setConfirmPass(val);
            },
            focusNode: viewModel.cPassFN,
            nextFocusNode: viewModel.ageFN,
          ),
          SizedBox(height: 20.0),
          TextFormBuilder(
            enabled: !viewModel.loading,
            prefix: Ionicons.calendar,
            hintText: "Wiek",
            textInputAction: TextInputAction.done,
            validateFunction: Validations.validateAge,
            submitAction: () => viewModel.register(context),
            onSaved: (String val) {
              viewModel.setAge(val);
            },
            focusNode: viewModel.ageFN,
          ),
          SizedBox(height: 25.0),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Ionicons.lock_closed_outline),
              SizedBox(width: 10),
              Text(
                "Musisz mieć 18 lat lub więcej, aby się zarejestrować",
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ],
          ),
          SizedBox(height: 25.0),
          Container(
            height: 45.0,
            width: 180.0,
            child: ElevatedButton(
              style: ButtonStyle(
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                ),
                backgroundColor: WidgetStateProperty.all<Color>(
                    Theme.of(context).colorScheme.secondary),
              ),
              child: Text(
                'Zarejestruj się'.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => viewModel.register(context),
            ),
          ),
        ],
      ),
    );
  }
}
