import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:les_social/services/api_service.dart';
import 'package:les_social/services/auth_service.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:les_social/components/text_form_builder.dart';
import 'package:les_social/models/user.dart';
import 'package:les_social/utils/validation.dart';
import 'package:les_social/view_models/profile/edit_profile_view_model.dart';
import 'package:les_social/widgets/indicators.dart';

class EditProfile extends StatefulWidget {
  final UserModel? user;

  const EditProfile({this.user});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  UserModel? user;
  late ApiService apiService;
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
  }

  Future<UserModel?> currentUid() async {
    return await _authService.getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user == null) {
      return Scaffold(
        body: Center(
          child: Text('Brak danych użytkownika'),
        ),
      );
    }

    EditProfileViewModel viewModel = Provider.of<EditProfileViewModel>(context);
    return LoadingOverlay(
      progressIndicator: circularProgress(context),
      isLoading: viewModel.loading,
      child: Scaffold(
        key: viewModel.scaffoldKey,
        appBar: AppBar(
          centerTitle: true,
          title: Text("Edytuj profil"),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 25.0),
                child: GestureDetector(
                  onTap: () => viewModel.editProfile(context),
                  child: Text(
                    'ZAPISZ',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15.0,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: ListView(
          children: [
            Center(
              child: GestureDetector(
                onTap: () => viewModel.pickImage(context: context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.transparent,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        offset: Offset(0.0, 0.0),
                        blurRadius: 2.0,
                        spreadRadius: 0.0,
                      ),
                    ],
                  ),
                  child: viewModel.imgLink != null
                      ? Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: CircleAvatar(
                      radius: 65.0,
                      backgroundImage: NetworkImage(viewModel.imgLink!),
                    ),
                  )
                      : viewModel.image == null
                      ? Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: CircleAvatar(
                      radius: 65.0,
                      backgroundImage:
                      NetworkImage(widget.user!.photoUrl ?? ''),
                    ),
                  )
                      : Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: CircleAvatar(
                      radius: 65.0,
                      backgroundImage: FileImage(viewModel.image!),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.0),
            buildForm(viewModel, context)
          ],
        ),
      ),
    );
  }

  Widget buildForm(EditProfileViewModel viewModel, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Form(
        key: viewModel.formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextFormBuilder(
              enabled: !viewModel.loading,
              initialValue: widget.user!.username,
              prefix: Ionicons.person_outline,
              hintText: "Nazwa użytkownika",
              textInputAction: TextInputAction.next,
              validateFunction: Validations.validateName,
              onSaved: (String val) {
                viewModel.setUsername(val);
              },
            ),
            SizedBox(height: 10.0),
            TextFormBuilder(
              initialValue: widget.user!.country,
              enabled: !viewModel.loading,
              prefix: Ionicons.pin_outline,
              hintText: "Kraj",
              textInputAction: TextInputAction.next,
              validateFunction: Validations.validateName,
              onSaved: (String val) {
                viewModel.setCountry(val);
              },
            ),
            SizedBox(height: 10.0),
            TextFormBuilder(
              initialValue: widget.user!.city,
              enabled: !viewModel.loading,
              prefix: Ionicons.locate_outline,
              hintText: "Miasto",
              textInputAction: TextInputAction.next,
              validateFunction: Validations.validateName,
              onSaved: (String val) {
                viewModel.setCity(val);
              },
            ),
            SizedBox(height: 10.0),
            TextFormBuilder(
              initialValue: widget.user!.age,
              enabled: !viewModel.loading,
              prefix: Ionicons.calendar,
              hintText: "Wiek",
              textInputAction: TextInputAction.next,
              validateFunction: Validations.validateAge,
              onSaved: (String val) {
                viewModel.setAge(val);
              },
            ),
            // Inne pola formularza
            Text(
              "Bio",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextFormField(
              maxLines: null,
              initialValue: widget.user!.bio,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (String? value) {
                if (value!.length > 1000) {
                  return 'Bio musi być krótkie';
                }
                return null;
              },
              onSaved: (String? val) {
                viewModel.setBio(val!);
              },
              onChanged: (String val) {
                viewModel.setBio(val);
              },
            ),
          ],
        ),
      ),
    );
  }
}



