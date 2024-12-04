import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:les_social/models/user.dart';
import 'package:les_social/services/user_service.dart';
import 'package:les_social/utils/constants.dart';

class EditProfileViewModel extends ChangeNotifier {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool validate = false;
  bool loading = false;
  late UserService userService; // Używamy `late`, aby później przypisać wartość
  final picker = ImagePicker();
  UserModel? user;
  String? country;
  String? city;
  String? username;
  String? bio;
  String? age;
  File? image;
  String? imgLink;

  EditProfileViewModel({required this.userService}) {
    //print("Inicjalizacja scaffoldKey z EditProfileViewModel: $scaffoldKey");
    //print("Inicjalizacja formKey z EditProfileViewModel: $formKey");
  }

  setUser(UserModel val) {
    user = val;
    notifyListeners();
  }

  setImage(UserModel user) {
    imgLink = user.photoUrl;
  }

  String setCountry(String val) {
    country = val;
    notifyListeners();
    return val;
  }

  String setBio(String val) {
    bio = val;
    notifyListeners();
    return val;
  }

  String setUsername(String val) {
    username = val;
    notifyListeners();
    return val;
  }

  String setAge(String val) {
    age = val;
    notifyListeners();
    return val;
  }

  String setCity(String val) {
    city = val;
    notifyListeners();
    return val;
  }

  Future<void> editProfile(BuildContext context) async {
    final form = formKey.currentState!;
    if (form.validate()) {
      form.save();
      try {
        loading = true;
        notifyListeners();

        if (userService == null) {
          //print("Error: UserService is not initialized");
          loading = false;
          notifyListeners();
          return;
        }

        bool success = await userService.updateProfile(
          image: image,
          username: username,
          bio: bio,
          country: country,
          age: age,
          city: city,
        );

        if (success) {
          clear();
          Navigator.pop(context);
        } else {
          showInSnackBar('Nie udało się zaktualizować profilu.', context);
        }
      } catch (e) {
        //print('Error po kliknięciu przycisku: $e');
        showInSnackBar('Wystąpił błąd. Spróbuj ponownie.', context);
      } finally {
        loading = false;
        notifyListeners();
      }
    } else {
      showInSnackBar('Popraw błędy, zanim przejdziesz dalej.', context);
    }
  }

  pickImage({bool camera = false, required BuildContext context}) async {
    loading = true;
    notifyListeners();
    try {
      XFile? pickedFile = await picker.pickImage(
        source: camera ? ImageSource.camera : ImageSource.gallery,
      );
      if (pickedFile != null) {
        CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ],
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Przytnij zdjęcie',
              toolbarColor: Constants.lightAccent,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
            ),
            IOSUiSettings(
              minimumAspectRatio: 1.0,
            ),
          ],
        );
        if (croppedFile != null) {
          image = File(croppedFile.path);
        }
      }
      loading = false;
      notifyListeners();
    } catch (e) {
      loading = false;
      notifyListeners();
      showInSnackBar('Anulowano', context);
    }
  }

  clear() {
    image = null;
    notifyListeners();
  }

  void showInSnackBar(String value, context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }
}



