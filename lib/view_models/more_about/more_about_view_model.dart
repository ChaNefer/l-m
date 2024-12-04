import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';
import '../../utils/constants.dart';

class MoreAboutViewModel extends ChangeNotifier {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool validate = false;
  bool loading = false;
  late UserService userService;
  final picker = ImagePicker();
  UserModel? user;
  double _orientationValue = 0.0;
  File? image;
  String? imgLink;
  String? dreams;
  String? regrets;
  String? favWoman;
  String? children;
  String? pets;
  String? husband;
  String? religion;
  String? politics;
  String? diet;
  String? smoke;
  String? drink;
  String? sexPref;
  String? freeTime;
  String? livingTogether;
  String? parties;
  bool? smokeCheckbox;
  bool? drinkCheckbox;
  bool? childrenCheckbox;
  bool? petsCheckbox;
  double? profileCompletion;

  MoreAboutViewModel(BuildContext context) {
    userService = UserService(context);
    //print("Inicjalizacja scaffoldKey z MoreAboutViewModel: $scaffoldKey");
    //print("Inicjalizacja formKey z MoreAboutViewModel: $formKey");

  }

  double calculateFilledPercent() {
    int totalFields = 16;
    int filledFields = 0;
    if (dreams != null && dreams!.isNotEmpty) filledFields++;
    if (regrets != null && regrets!.isNotEmpty) filledFields++;
    if (favWoman != null && favWoman!.isNotEmpty) filledFields++;
    if (children != null && children!.isNotEmpty) filledFields++;
    if (pets != null && pets!.isNotEmpty) filledFields++;
    if (husband != null && husband!.isNotEmpty) filledFields++;
    // if (religion != null && religion!.isNotEmpty) filledFields++;
    if (politics != null && politics!.isNotEmpty) filledFields++;
    if (diet != null && diet!.isNotEmpty) filledFields++;
    if (smoke != null && smoke!.isNotEmpty) filledFields++;
    if (drink != null && drink!.isNotEmpty) filledFields++;
    if (sexPref != null && sexPref!.isNotEmpty) filledFields++;
    if (freeTime != null && freeTime!.isNotEmpty) filledFields++;
    // if (livingTogether != null && livingTogether!.isNotEmpty) filledFields++;
    // if (parties != null && parties!.isNotEmpty) filledFields++;
    if (smokeCheckbox != null) filledFields++;
    if (drinkCheckbox != null) filledFields++;
    if (childrenCheckbox != null) filledFields++;
    if (petsCheckbox != null) filledFields++;

    double filledPercent = (filledFields / totalFields) * 100;
    return filledPercent;
  }

  setUser(UserModel val) {
    user = val;
    notifyListeners();
  }

  setImage(UserModel user) {
    imgLink = user.photoUrl;
  }

  String setOrientation(double val) {
    _orientationValue = val;
    notifyListeners();
    return val.toString();
  }

  String setDreams(String val) {
    dreams = val;
    notifyListeners();
    return val;
  }

  String setRegrets(String val) {
    regrets = val;
    notifyListeners();
    return val;
  }

  String setFavWoman(String val) {
    favWoman = val;
    notifyListeners();
    return val;
  }

  String setChildren(String val) {
    children = val;
    notifyListeners();
    return val;
  }

  String setPets(String val) {
    pets = val;
    notifyListeners();
    return val;
  }

  String setHusband(String val) {
    husband = val;
    notifyListeners();
    return val;
  }

  String setReligion(String val) {
    religion = val;
    notifyListeners();
    return val;
  }

  String setPolitics(String val) {
    politics = val;
    notifyListeners();
    return val;
  }

  String setDiet(String val) {
    diet = val;
    notifyListeners();
    return val;
  }

  String setSmoke(String val) {
    smoke = val;
    notifyListeners();
    return val;
  }

  String setDrink(String val) {
    drink = val;
    notifyListeners();
    return val;
  }

  String setSexPref(String val) {
    sexPref = val;
    notifyListeners();
    return val;
  }

  String setFreeTime(String val) {
    freeTime = val;
    notifyListeners();
    return val;
  }

  String setLivingTogether(String val) {
    livingTogether = val;
    notifyListeners();
    return val;
  }

  String setParties(String val) {
    parties = val;
    notifyListeners();
    return val;
  }

  bool setSmokeCheckbox(bool val) {
    smokeCheckbox = val;
    notifyListeners();
    return val;
  }

  bool setDrinkCheckbox(bool val) {
    drinkCheckbox = val;
    notifyListeners();
    return val;
  }

  bool setPetsCheckbox(bool val) {
    petsCheckbox = val;
    notifyListeners();
    return val;
  }

  bool setChildrenCheckbox(bool val) {
    childrenCheckbox = val;
    notifyListeners();
    return val;
  }

  double setProfileCompletion(double val) {
    profileCompletion = val;
    notifyListeners();
    return val;
  }


  moreAbout(BuildContext context) async {
    FormState form = formKey.currentState!;
    form.save();
    if (!form.validate()) {
      validate = true;
      notifyListeners();
      showInSnackBar('Popraw błędy, zanim przejdziesz dalej.', context);
    } else {
      try {
        loading = true;
        notifyListeners();
        // Oblicz procent wypełnienia
        double filledPercent = calculateFilledPercent();
        setProfileCompletion(filledPercent);

        bool success = await userService.updateMoreAbout(
            dreams: dreams,
            regrets: regrets,
            favWoman: favWoman,
            children: children,
            pets: pets,
            husband: husband,
            religion: religion,
            politics: politics,
            diet: diet,
            smoke: smoke,
            drink: drink,
            sexPref: sexPref,
            orientation: _orientationValue.toString(),
            freeTime: freeTime,
            livingTogether: livingTogether,
            parties: parties,
            smokeCheckbox: smokeCheckbox ?? false,
            drinkCheckbox: drinkCheckbox ?? false,
            childrenCheckbox: childrenCheckbox ?? false,
            petsCheckbox: petsCheckbox ?? false,
            profileCompletion: filledPercent,  // Zapisz do Firebase
        );
        if (success) {
          Navigator.pop(context);
        }
      } catch (e) {
        loading = false;
        notifyListeners();
        //print(e);
      }
      loading = false;
      notifyListeners();
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
              toolbarTitle: 'Przytnij zdj',
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
      showInSnackBar('Cancelled', context);
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
