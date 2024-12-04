import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:les_social/models/post.dart';
import 'package:les_social/screens/settings.dart';
import '../auth/login/login.dart';
import '../components/fab_container.dart';
import '../models/notification.dart';
import '../models/user.dart';
import '../pages/feeds.dart';
import '../pages/notification.dart';
import '../pages/profile.dart';
import '../pages/search.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/storage_class.dart';

class TabScreen extends StatefulWidget {
  final ActivityModel? activity;


  const TabScreen({Key? key, this.activity}) : super(key: key);

  @override
  _TabScreenState createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  int _page = 0;
  late ApiService apiService;
  late AuthService _authService;
  late StorageClass storage;
  List pages = [];
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    apiService = ApiService(context);
    storage = StorageClass();

    // Pobierz userId z Storage
    _loadUserDataFromStorage();
  }

  void _loadUserDataFromStorage() async {
    currentUserId = await storage.getUserId();
    //print('Pobrane userId z Storage: $currentUserId');
    await initializePages();
  }

  Future<PostModel?> fetchPostById(String postId) async {
    try {
      return await apiService.getPostById(postId);
    } catch (e) {
      //print('Błąd podczas pobierania posta: $e');
      return null;
    }
  }

  Future<void> initializePages() async {
    final userId = await storage.getUserId();
    final token = await storage.getToken();

    if (userId == null || token == null) {
      setState(() {
        pages = [
          {
            'title': 'Error',
            'icon': CupertinoIcons.exclamationmark_circle,
            'page': Center(child: Text('Failed to load user data')),
            'index': 0,
          },
        ];
      });
      return;
    }

    UserModel? currentUser = await _authService.getCurrentUser();

    if (currentUser != null && currentUser.id != null) {
      // Pobierz posty, jeśli istnieje postId

      setState(() {
        currentUserId = currentUser.id.toString();
        pages = [
          {
            'title': 'Profil',
            'icon': CupertinoIcons.person_fill,
            'page': Profile(profileId: currentUserId!),
            'index': 0,
          },
          {
            'title': 'Szukaj',
            'icon': Ionicons.search,
            'page': Search(),
            'index': 1,
          },
          {
            'title': 'Dodaj',
            'icon': Ionicons.add_circle,
            'page': Text('Dodaj nowy post'),
            'index': 2,
          },
          {
            'title': 'Home',
            'icon': Ionicons.home,
            'page': Feeds(profileId: currentUserId!),
            'index': 3,
          },
          {
            'title': 'Ustawienia',
            'icon': Icons.settings_outlined,
            'page': Setting(),
            'index': 4,
          },
        ];
      });
    } else {
      setState(() {
        pages = [
          {
            'title': 'Error',
            'icon': CupertinoIcons.exclamationmark_circle,
            'page': Center(child: Text('Failed to load user data')),
            'index': 0,
          },
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages.isEmpty
          ? Center(child: CircularProgressIndicator())
          : PageTransitionSwitcher(
        transitionBuilder: (
            Widget child,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            ) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        child: pages[_page]['page'],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 5),
            for (Map item in pages)
              item['index'] == 2
                  ? buildFab()
                  : Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: IconButton(
                  icon: Icon(
                    item['icon'],
                    color: item['index'] != _page
                        ? Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black
                        : Theme.of(context).colorScheme.secondary,
                    size: 25.0,
                  ),
                  onPressed: () => navigationTapped(item['index']),
                ),
              ),
            SizedBox(width: 5),
          ],
        ),
      ),
    );
  }

  Widget buildFab() {
    return Container(
      height: 45.0,
      width: 45.0,
      child: FabContainer(
        icon: Ionicons.add_outline,
        mini: true,
      ),
    );
  }

  void navigationTapped(int page) {
    setState(() {
      _page = page;
    });
  }
}





