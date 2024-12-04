// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:ionicons/ionicons.dart';
// import 'package:les_social/services/api_service.dart'; // Import Twojego API service
// import 'package:les_social/services/auth_service.dart';
// import 'package:loading_overlay/loading_overlay.dart';
// import 'package:provider/provider.dart';
// import 'package:les_social/components/custom_image.dart';
// import 'package:les_social/models/user.dart'; // Model użytkownika
// import 'package:les_social/view_models/auth/posts_view_model.dart'; // ViewModel do zarządzania postami
// import 'package:les_social/widgets/indicators.dart';
//
// class CreatePost extends StatefulWidget {
//   @override
//   _CreatePostState createState() => _CreatePostState();
// }
//
// class _CreatePostState extends State<CreatePost> {
//   late ApiService apiService; // Twój serwis API
//   late AuthService _authService = AuthService();
//
//   @override
//   void initState() {
//     super.initState();
//     apiService = ApiService(context); // Inicjalizacja Twojego serwisu API
//   }
//
//   currentUserId() {
//     return _authService.getCurrentUser;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     PostsViewModel viewModel = Provider.of<PostsViewModel>(context);
//     return WillPopScope(
//       onWillPop: () async {
//         await viewModel.resetPost();
//         return true;
//       },
//       child: LoadingOverlay(
//         progressIndicator: circularProgress(context),
//         isLoading: viewModel.loading,
//         child: Scaffold(
//           key: viewModel.scaffoldKey,
//           appBar: AppBar(
//             leading: IconButton(
//               icon: Icon(Ionicons.close_outline),
//               onPressed: () {
//                 viewModel.resetPost();
//                 Navigator.pop(context);
//               },
//             ),
//             title: Text('LesMind'.toUpperCase()),
//             centerTitle: true,
//             actions: [
//               GestureDetector(
//                 onTap: () async {
//                   await viewModel.uploadPosts(context); // Funkcja do wysyłania postu
//                   Navigator.pop(context);
//                   viewModel.resetPost();
//                 },
//                 child: Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: Text(
//                     'opublikuj'.toUpperCase(),
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 15.0,
//                       color: Theme.of(context).colorScheme.secondary,
//                     ),
//                   ),
//                 ),
//               )
//             ],
//           ),
//           body: ListView(
//             padding: EdgeInsets.symmetric(horizontal: 15.0),
//             children: [
//               SizedBox(height: 15.0),
//               FutureBuilder<UserModel?>(
//                 future: _authService.getCurrentUser(), // Pobranie danych użytkownika z Twojego backendu
//                 builder: (context, snapshot) {
//                   if (snapshot.hasData) {
//                     UserModel user = snapshot.data!;
//                     return ListTile(
//                       leading: CircleAvatar(
//                         radius: 25.0,
//                         backgroundImage: NetworkImage(user.photoUrl!),
//                       ),
//                       title: Text(
//                         user.username!,
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       subtitle: Text(
//                         user.email!,
//                       ),
//                     );
//                   } else if (snapshot.hasError) {
//                     return Text("Błąd: ${snapshot.error}");
//                   }
//                   return CircularProgressIndicator();
//                 },
//               ),
//
//               InkWell(
//                 onTap: () => showImageChoices(context, viewModel),
//                 child: Container(
//                   width: MediaQuery.of(context).size.width,
//                   height: MediaQuery.of(context).size.width - 30,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.all(
//                       Radius.circular(5.0),
//                     ),
//                     border: Border.all(
//                       color: Theme.of(context).colorScheme.secondary,
//                     ),
//                   ),
//                   child: viewModel.imgLink != null
//                       ? CustomImage(
//                     imageUrl: viewModel.imgLink,
//                     width: MediaQuery.of(context).size.width,
//                     height: MediaQuery.of(context).size.width - 30,
//                     fit: BoxFit.cover,
//                   )
//                       : viewModel.mediaUrl == null
//                       ? Center(
//                     child: Text(
//                       'Dodaj zdjęcie',
//                       style: TextStyle(
//                         color:
//                         Theme.of(context).colorScheme.secondary,
//                       ),
//                     ),
//                   )
//                       : Image.file(
//                     viewModel.mediaUrl!,
//                     width: MediaQuery.of(context).size.width,
//                     height: MediaQuery.of(context).size.width - 30,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20.0),
//               Text(
//                 'Opis postu'.toUpperCase(),
//                 style: TextStyle(
//                   fontSize: 15.0,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               TextFormField(
//                 initialValue: viewModel.description,
//                 decoration: InputDecoration(
//                   hintText: 'To jest bardzo ładne miejsce!',
//                   focusedBorder: UnderlineInputBorder(),
//                 ),
//                 maxLines: null,
//                 onChanged: (val) => viewModel.setDescription(val),
//               ),
//               SizedBox(height: 20.0),
//               Text(
//                 'Lokalizacja'.toUpperCase(),
//                 style: TextStyle(
//                   fontSize: 15.0,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               ListTile(
//                 contentPadding: EdgeInsets.all(0.0),
//                 title: Container(
//                   width: 250.0,
//                   child: TextFormField(
//                     controller: viewModel.locationTEC,
//                     decoration: InputDecoration(
//                       contentPadding: EdgeInsets.all(0.0),
//                       hintText: 'Polska, Warszawa',
//                       focusedBorder: UnderlineInputBorder(),
//                     ),
//                     maxLines: null,
//                     onChanged: (val) => viewModel.setLocation(val),
//                   ),
//                 ),
//                 trailing: IconButton(
//                   tooltip: "Użyj mojej aktualnej lokalizacji",
//                   icon: Icon(
//                     CupertinoIcons.map_pin_ellipse,
//                     size: 25.0,
//                   ),
//                   iconSize: 30.0,
//                   color: Theme.of(context).colorScheme.secondary,
//                   onPressed: () => viewModel.getLocation(),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   showImageChoices(BuildContext context, PostsViewModel viewModel) {
//     showModalBottomSheet(
//       context: context,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10.0),
//       ),
//       builder: (BuildContext context) {
//         return FractionallySizedBox(
//           heightFactor: .6,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: 20.0),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10.0),
//                 child: Text(
//                   'Wybierz zdjęcie',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               Divider(),
//               ListTile(
//                 leading: Icon(Ionicons.camera_outline),
//                 title: Text('Kamera'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   viewModel.pickImage(camera: true);
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Ionicons.image),
//                 title: Text('Galeria'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   viewModel.pickImage();
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//
//
//
//
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:les_social/services/api_service.dart'; // Import Twojego API service
import 'package:les_social/services/auth_service.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:les_social/components/custom_image.dart';
import 'package:les_social/models/user.dart'; // Model użytkownika
import 'package:les_social/view_models/auth/posts_view_model.dart'; // ViewModel do zarządzania postami
import 'package:les_social/widgets/indicators.dart';
import 'package:zefyrka/zefyrka.dart';

class CreatePost extends StatefulWidget {
  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  late ApiService apiService; // Twój serwis API
  late AuthService _authService = AuthService();
  ZefyrController? _controller; // Kontroler Zefyrka

  @override
  void initState() {
    super.initState();
    apiService = ApiService(context); // Inicjalizacja Twojego serwisu API
    _controller = ZefyrController(NotusDocument()); // Inicjalizacja kontrolera Zefyrka
  }

  currentUserId() {
    return _authService.getCurrentUser;
  }

  // void changeTextColor(Color color) {
  //   final style = NotusStyle().copyWith(color: color);  // Ustawienie koloru tekstu
  //   _controller!.formatText(0, _controller!.document.length, style);  // Zastosowanie stylu do całego tekstu
  // }

  @override
  Widget build(BuildContext context) {
    PostsViewModel viewModel = Provider.of<PostsViewModel>(context);
    return WillPopScope(
      onWillPop: () async {
        await viewModel.resetPost();
        return true;
      },
      child: LoadingOverlay(
        progressIndicator: circularProgress(context),
        isLoading: viewModel.loading,
        child: Scaffold(
          key: viewModel.scaffoldKey,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Ionicons.close_outline),
              onPressed: () {
                viewModel.resetPost();
                Navigator.pop(context);
              },
            ),
            title: Text('LesMind'.toUpperCase()),
            centerTitle: true,
            actions: [
              GestureDetector(
                onTap: () async {
                  await viewModel.uploadPosts(context); // Funkcja do wysyłania postu
                  Navigator.pop(context);
                  viewModel.resetPost();
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'opublikuj'.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              )
            ],
          ),
          body: ListView(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            children: [
              SizedBox(height: 15.0),
              FutureBuilder<UserModel?>(
                future: _authService.getCurrentUser(), // Pobranie danych użytkownika z Twojego backendu
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    UserModel user = snapshot.data!;
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 25.0,
                        backgroundImage: NetworkImage(user.photoUrl!),
                      ),
                      title: Text(
                        user.username!,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        user.email!,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text("Błąd: ${snapshot.error}");
                  }
                  return CircularProgressIndicator();
                },
              ),

              InkWell(
                onTap: () => showImageChoices(context, viewModel),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width - 30,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.all(
                      Radius.circular(5.0),
                    ),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  child: viewModel.imgLink != null
                      ? CustomImage(
                    imageUrl: viewModel.imgLink,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width - 30,
                    fit: BoxFit.cover,
                  )
                      : viewModel.mediaUrl == null
                      ? Center(
                    child: Text(
                      'Dodaj zdjęcie',
                      style: TextStyle(
                        color:
                        Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  )
                      : Image.file(
                    viewModel.mediaUrl!,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width - 30,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                'Opis postu'.toUpperCase(),
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Zefyrka - edytor tekstu
              ZefyrEditor(
                controller: _controller!,
                focusNode: FocusNode(),
                padding: EdgeInsets.all(10),
                autofocus: false,
                // toolbar: ZefyrToolbar.basic(controller: _controller!),
              ),
              SizedBox(height: 20.0),
              Text(
                'Lokalizacja'.toUpperCase(),
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.all(0.0),
                title: Container(
                  width: 250.0,
                  child: TextFormField(
                    controller: viewModel.locationTEC,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(0.0),
                      hintText: 'Polska, Warszawa',
                      focusedBorder: UnderlineInputBorder(),
                    ),
                    maxLines: null,
                    onChanged: (val) => viewModel.setLocation(val),
                  ),
                ),
                trailing: IconButton(
                  tooltip: "Użyj mojej aktualnej lokalizacji",
                  icon: Icon(
                    CupertinoIcons.map_pin_ellipse,
                    size: 25.0,
                  ),
                  iconSize: 30.0,
                  color: Theme.of(context).colorScheme.secondary,
                  onPressed: () => viewModel.getLocation(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  showImageChoices(BuildContext context, PostsViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: .6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  'Wybierz zdjęcie',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(),
              ListTile(
                leading: Icon(Ionicons.camera_outline),
                title: Text('Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  viewModel.pickImage(camera: true);
                },
              ),
              ListTile(
                leading: Icon(Ionicons.image),
                title: Text('Galeria'),
                onTap: () {
                  Navigator.pop(context);
                  viewModel.pickImage();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}












