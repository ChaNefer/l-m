import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:les_social/models/post.dart';
import 'package:les_social/models/user.dart';
import 'package:les_social/screens/mainscreen.dart';
import 'package:les_social/services/api_service.dart';
import 'package:les_social/services/post_service.dart';
import 'package:les_social/services/user_service.dart';
import 'package:les_social/utils/constants.dart';
import 'package:les_social/utils/firebase.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../user/user_provider.dart';

class PostsViewModel extends ChangeNotifier {
  //Services
  late UserService userService;
  PostService postService = PostService();
  late ApiService apiService;
  AuthService auth = AuthService();

  PostsViewModel(BuildContext context) {
    //print('Inicjalizacja PostsViewModel');
    //print('Inicjalizacja scaffoldKey z PostViewModel: $scaffoldKey');
    //print('Inicjalizacja scaffoldKey z PostViewModel: $formKey');
    userService = UserService(context);
    apiService = ApiService(context);
    //print('apiService został zainicjalizowany: $apiService');
  }

  //Keys
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  //Variables
  bool loading = false;
  String? username;
  File? mediaUrl;
  final picker = ImagePicker();
  String? location;
  Position? position;
  Placemark? placemark;
  String? bio;
  String? description;
  String? email;
  String? commentData;
  String? ownerId;
  String? userId;
  String? postId;
  String? type;
  File? userDp;
  String? imgLink;
  bool edit = false;
  String? id;
  AuthService _authService = AuthService();

  //controllers
  TextEditingController locationTEC = TextEditingController();

  Future<UserModel?> currentUserId() async {
    try {
      var currentUser = await _authService.getCurrentUser();
      //print("currentUserId: Pobrano ID aktualnie zalogowanego użytkownika - ${currentUser?.id}"); // Debugowanie
      return currentUser;
    } catch (e) {
      //print("currentUserId: Błąd podczas pobierania danych użytkownika - $e"); // Debugowanie
      return null;
    }
  }


  void setUserId(String id) {
    userId = id;
    Future.microtask(() {
      notifyListeners();
    });
  }

  //Setters
  setEdit(bool val) {
    edit = val;
    notifyListeners();
  }

  setPost(PostModel post) {
    if (post != null) {
      description = post.description;
      imgLink = post.mediaUrl;
      location = post.location;
      edit = true;
      edit = false;
      notifyListeners();
    } else {
      edit = false;
      notifyListeners();
    }
  }

  setUsername(String val) {
    //print('SetName $val');
    username = val;
    notifyListeners();
  }

  setDescription(String val) {
    //print('SetDescription $val');
    description = val;
    notifyListeners();
  }

  setLocation(String val) {
    //print('SetCountry $val');
    location = val;
    notifyListeners();
  }

  setBio(String val) {
    //print('SetBio $val');
    bio = val;
    notifyListeners();
  }

  //Functions
  pickImage({bool camera = false, BuildContext? context}) async {
    loading = true;
    notifyListeners();
    try {
      XFile? pickedFile = (await picker.pickImage(
        source: camera ? ImageSource.camera : ImageSource.gallery,
      ));
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile!.path,
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
      mediaUrl = File(croppedFile!.path);
      loading = false;
      notifyListeners();
    } catch (e) {
      loading = false;
      notifyListeners();
      showInSnackBar('Zmiany cofnięte: $e', scaffoldKey.currentContext);
    }
  }

  getLocation() async {
    loading = true;
    notifyListeners();
    LocationPermission permission = await Geolocator.checkPermission();
    //print(permission);
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      LocationPermission rPermission = await Geolocator.requestPermission();
      //print(rPermission);
      await getLocation();
    } else {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position!.latitude, position!.longitude);
      placemark = placemarks[0];
      location = " ${placemarks[0].locality}, ${placemarks[0].country}";
      locationTEC.text = location!;
      //print(location);
    }
    loading = false;
    notifyListeners();
  }

  uploadPosts(BuildContext context) async {
    try {
      // Dodajmy drukowanie wartości
      //print('uploadPosts called');

      // Wyświetlanie wartości przed wysłaniem
      //print('mediaUrl: $mediaUrl');
      //print('location: $location');
      //print('description: $description');

      // Uzyskiwanie ID aktualnie zalogowanego użytkownika
      UserModel? currentUser = await currentUserId();
      userId = currentUser?.id; // Ustaw ID użytkownika
      //print('userId: $userId');

      // Sprawdzanie, czy wartości nie są null
      if (mediaUrl == null) {
        //print('mediaUrl is null');
      }
      if (location == null) {
        //print('location is null');
      }
      if (description == null) {
        //print('description is null');
      }
      if (userId == null) {
        //print('userId is null');
      }

      // Warunkowe sprawdzenie, czy dane są gotowe do przesłania
      if (mediaUrl == null || location == null || description == null || userId == null) {
        showInSnackBar('Brakuje wymaganych danych', context);
        //print('Missing required data, aborting upload.');
        return; // Zatrzymaj dalsze wykonywanie
      }

      //print('Wszystkie dane są dostępne, kontynuujemy przesyłanie...');

      loading = true;
      notifyListeners();

      // Wywołanie uploadPost
      //print('Preparing to call postService.uploadPost');
      await postService.uploadPost(mediaUrl!, location!, description!, userId!);
      //print('Post uploaded successfully');

      loading = false;
      resetPost();
      notifyListeners();
      showInSnackBar('Wszystko się udało!', context);
    } catch (e) {
      // Drukowanie błędu
      //print('Błąd podczas przesyłania: $e');

      loading = false;
      resetPost();
      showInSnackBar('Nie udało się dodać zdjęcia', context);
      notifyListeners();
      //print('Finished with error');
    }
  }

  // uploadProfilePicture(BuildContext context, String userId) async {
  //   //print('uploadProfilePicture called with userId: $userId'); // Debug print
  //   try {
  //     if (mediaUrl == null) {
  //       showInSnackBar('Wybierz zdjęcie', context);
  //       return; // Dodaj return, aby zakończyć metodę, jeśli mediaUrl jest null
  //     }
  //     loading = true;
  //     notifyListeners();
  //     // Prześlij zdjęcie profilowe za pomocą postService
  //     await postService.uploadProfilePicture(mediaUrl!, userId);
  //
  //     loading = false;
  //     // Po pomyślnym przesłaniu przejdź do kolejnego ekranu
  //     Navigator.of(context).pushReplacement(CupertinoPageRoute(builder: (_) => TabScreen()));
  //     notifyListeners();
  //   } catch (e) {
  //     // Obsłuż błędy, które mogą wystąpić podczas procesu przesyłania
  //     //print('Błąd przesyłania zdjęcia: $e');
  //     loading = false;
  //     showInSnackBar('Nie udało się dodać zdjęcia', context);
  //   } finally {
  //     notifyListeners();
  //   }
  // }

  uploadProfilePicture(BuildContext context, String userId) async {
    //print('uploadProfilePicture called with userId: $userId'); // Debug print
    try {
      if (mediaUrl == null) {
        showInSnackBar('Wybierz zdjęcie', context);
        return; // Dodaj return, aby zakończyć metodę, jeśli mediaUrl jest null
      }
      loading = true;
      notifyListeners();

      // Prześlij zdjęcie profilowe za pomocą postService
      await postService.uploadProfilePicture(mediaUrl!, userId);

      // Pobierz szczegóły użytkownika i ustaw w UserProvider
      UserModel? user = await _authService.getCurrentUser(); // Zakładając, że metoda getCurrentUser zwraca UserModel
      if (user != null) {
        Provider.of<UserProvider>(context, listen: false).setUser(user);
        //print('User updated in UserProvider: $user'); // Debug print
      } else {
        //print('User not found after upload'); // Debug print
      }

      loading = false;

      // Po pomyślnym przesłaniu przejdź do kolejnego ekranu
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(
          builder: (_) => TabScreen(),
        ),
      );
      notifyListeners();
    } catch (e) {
      // Obsłuż błędy, które mogą wystąpić podczas procesu przesyłania
      //print('Błąd przesyłania zdjęcia: $e');
      loading = false;
      showInSnackBar('Nie udało się dodać zdjęcia', context);
    } finally {
      notifyListeners();
    }
  }

  resetPost() {
    mediaUrl = null;
    description = null;
    location = null;
    edit = false;
    notifyListeners();
  }

  void showInSnackBar(String value, context) {
    if (context != null) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
    } else {
      //print("Context is null, cannot show snackbar");
    }
  }
}
