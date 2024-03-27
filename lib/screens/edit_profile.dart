import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:les_social/components/text_form_builder.dart';
import 'package:les_social/models/user.dart';
import 'package:les_social/utils/firebase.dart';
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

  String currentUid() {
    return firebaseAuth.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
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
                        offset: new Offset(0.0, 0.0),
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

  buildForm(EditProfileViewModel viewModel, BuildContext context) {
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
            // TextFormBuilder(
            //   initialValue: widget.user!.sex,
            //   enabled: !viewModel.loading,
            //   prefix: Ionicons.transgender,
            //   hintText: "Płeć",
            //   textInputAction: TextInputAction.next,
            //   validateFunction: Validations.validateName,
            //   onSaved: (String val) {
            //     viewModel.setSex(val);
            //   },
            // ),
            // TextFormBuilder(
            //   initialValue: widget.user!.orientation,
            //   enabled: !viewModel.loading,
            //   prefix: Ionicons.male_female,
            //   hintText: "Orientacja seksualna",
            //   textInputAction: TextInputAction.next,
            //   validateFunction: Validations.validateName,
            //   onSaved: (String val) {
            //     viewModel.setOrientation(val);
            //   },
            // ),
            // TextFormBuilder(
            //   initialValue: widget.user!.age,
            //   enabled: !viewModel.loading,
            //   prefix: Ionicons.calendar,
            //   hintText: "Wiek",
            //   textInputAction: TextInputAction.next,
            //   validateFunction: Validations.validateName,
            //   onSaved: (String val) {
            //     viewModel.setAge(val);
            //   },
            // ),
            // TextFormBuilder(
            //   initialValue: widget.user!.relationship,
            //   enabled: !viewModel.loading,
            //   prefix: Ionicons.heart,
            //   hintText: "Czy jesteś w związku?",
            //   textInputAction: TextInputAction.next,
            //   validateFunction: Validations.validateName,
            //   onSaved: (String val) {
            //     viewModel.setRelationship(val);
            //   },
            // ),
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
