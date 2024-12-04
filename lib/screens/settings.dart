import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:les_social/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:les_social/view_models/theme/theme_view_model.dart';

import '../auth/login/login.dart';
import 'mainscreen.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0.0,
        title: Text(
          "Ustawienia",
          style: TextStyle(),
        ),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: ListView(
          children: <Widget>[
            ListTile(
                title: Text(
                  "O:",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                subtitle: Text(
                  "Aplikacja dla kobiet nieheteronormatywnych.",
                ),
                trailing: Icon(Icons.error)),
            Divider(),
            ListTile(
              title: Text(
                "Tryb ciemny",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
              subtitle: Text("Użyj trybu ciemnego"),
              trailing: Consumer<ThemeProvider>(
                builder: (context, notifier, child) => CupertinoSwitch(
                  onChanged: (val) {
                    notifier.toggleTheme();
                  },
                  value: notifier.dark,
                  activeColor: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            Divider(),
            ListTile(
                title: Text(
                  "PREMIUM",
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.deepPurpleAccent),
                ),
                subtitle: Text(
                  "Różne opcje premium...",
                ),
                trailing: Icon(
                  Ionicons.star,
                  color: Colors.orangeAccent,
                  size: 41,
                )),
            Divider(),
            ListTile(
                onTap: () async {
                  await _authService.logout();
                  Navigator.of(context).pushAndRemoveUntil(
                      CupertinoPageRoute(builder: (_) => Login()),
                      (Route<dynamic> route) => false);
                },
                title: Text(
                  "Wyloguj się",
                  style: TextStyle(
                      fontWeight: FontWeight.w900, color: Colors.black87),
                ),
                subtitle: Text(
                  "Kliknij, aby się wylogować`",
                ),
                trailing: Icon(
                  Ionicons.power_outline,
                  color: Colors.red,
                  size: 31,
                ))
          ],
        ),
      ),
    );
  }
}
