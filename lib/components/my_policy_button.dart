import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class MyPolicyButton extends StatefulWidget {
  const MyPolicyButton({Key? key}) : super(key: key);

  @override
  State<MyPolicyButton> createState() => _MyPolicyButtonState();
}

class _MyPolicyButtonState extends State<MyPolicyButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      width: 380,
      height: 60,
      child: TextButton(onPressed: () {
        // Uri uri = Uri.parse("https://www.zdrowerasowe.pl/regulamin-i-polityka-prywatnosci");
        // launchUrl(uri);
      },
        child: Text("Regulamin i Polityka Prywatności", style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
        ),
            textAlign: TextAlign.center
        ),
      ),
    );
  }
}