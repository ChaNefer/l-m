// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:ionicons/ionicons.dart';
// import '../models/user.dart';
// import '../utils/firebase.dart';
//
// class Portfolio extends StatelessWidget {
//   final String userId;
//
//   Portfolio({required this.userId});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Portfolio'),
//       ),
//       body: StreamBuilder<DocumentSnapshot>(
//         stream: usersRef.doc(userId).snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data == null) {
//             return Center(child: Text('Brak danych'));
//           }
//           UserModel user = UserModel.fromJson(snapshot.data!.data() as Map<String, dynamic>);
//           return ListView(
//             padding: EdgeInsets.all(20.0),
//             children: [
//               ProfileInfoTile(label: 'Imię...', value: user.username, icon: Icons.person),
//               SizedBox(height: 20),
//               ProfileInfoTile(label: 'Wiek...', value: user.age != null ? user.age!.toString() : '', icon: Ionicons.calendar),
//               SizedBox(height: 20),
//               ProfileInfoTile(label: 'Dzieci...', value: user.children, icon: Icons.child_friendly, checkbox: true, checkboxValue: user.childrenCheckbox),
//               SizedBox(height: 20),
//               ProfileInfoTile(label: 'Moja wymarzona kobieta...', value: user.favWoman, icon: Icons.woman_2),
//               SizedBox(height: 20),
//               ProfileInfoTile(label: 'Jedyna słuszna partia to...', value: user.politics, icon: Icons.policy),
//               SizedBox(height: 20),
//               ProfileInfoTile(label: 'Marzę o...', value: user.dreams, icon: Icons.settings_system_daydream),
//               SizedBox(height: 20),
//               ProfileInfoTile(label: 'Żałuję...', value: user.regrets, icon: Icons.cake),
//               SizedBox(height: 20),
//               ProfileInfoTile(label: 'Palę...', value: user.smoke, icon: Icons.smoke_free_outlined, checkbox: true, checkboxValue: user.smokeCheckbox),
//               SizedBox(height: 20),
//               ProfileInfoTile(label: 'Piję...', value: user.drink, icon: Ionicons.beer_outline, checkbox: true, checkboxValue: user.drinkCheckbox),
//               SizedBox(height: 20),
//               ProfileInfoTile(label: 'W łóżku najbardziej lubię...', value: user.sexPref, icon: Icons.bed_sharp),
//               SizedBox(height: 20),
//               ProfileInfoTile(label: 'W wolnym czasię najchętniej...', value: user.freeTime, icon: Ionicons.american_football_outline),
//               SizedBox(height: 20),
//               ProfileInfoTile(label: 'Lubię, kiedy kobieta...', value: user.favWoman, icon: FontAwesomeIcons.faceGrinTongue),
//               SizedBox(height: 20),
//               ProfileInfoTile(label: 'Jestem orientacji...', value: _getOrientationLabel(user.orientation), icon: FontAwesomeIcons.transgender),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   String _getOrientationLabel(String? orientation) {
//     double value = double.parse(orientation ?? '0.0');
//     if (value < 50) {
//       return 'Biseksualna';
//     } else if (value >= 25 && value < 75) {
//       return 'Biseksualna z większym naciskiem w stronę kobiet';
//     } else {
//       return 'Zdeklarowana lesbijka';
//     }
//   }
// }
//
// class ProfileInfoTile extends StatelessWidget {
//   final String label;
//   final dynamic value;
//   final IconData icon;
//   final bool checkbox;
//   final bool? checkboxValue;
//
//   const ProfileInfoTile({
//     required this.label,
//     required this.value,
//     required this.icon,
//     this.checkbox = false,
//     this.checkboxValue,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       leading: Icon(icon, color: Theme.of(context).colorScheme.secondary),
//       title: Text(
//         label,
//         style: TextStyle(
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       subtitle: _buildSubtitle(context),
//     );
//   }
//
//   Widget _buildSubtitle(BuildContext context) {
//     if (checkbox) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Checkbox(
//                 value: checkboxValue ?? false,
//                 onChanged: null,
//               ),
//               Text('Tak'),
//               SizedBox(width: 10),
//               Checkbox(
//                 value: !(checkboxValue ?? true),
//                 onChanged: null,
//               ),
//               Text('Nie'),
//             ],
//           ),
//           SizedBox(height: 5),
//           if (value != null && value.isNotEmpty) Text(value),
//         ],
//       );
//     } else {
//       if (value == null) {
//         return Text('Unknown');
//       } else if (value is bool) {
//         return Text(value ? 'Tak' : 'Nie');
//       } else {
//         return Text(value.toString());
//       }
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ionicons/ionicons.dart';
import '../models/user.dart';
import '../services/api_service.dart'; // Zaimportuj odpowiedni serwis do obsługi API

class Portfolio extends StatefulWidget {
  final String userId;

  Portfolio({required this.userId});

  @override
  _PortfolioState createState() => _PortfolioState();
}

class _PortfolioState extends State<Portfolio> {
  late ApiService apiService;
  late UserModel user;

  @override
  void initState() {
    super.initState();
    apiService = ApiService(context); // Inicjalizacja serwisu API
    fetchUserData();
  }

  void fetchUserData() async {
    try {
      user = await apiService.fetchUserData(widget.userId); // Pobierz dane użytkownika z API
      setState(() {}); // Odśwież widok po pobraniu danych
    } catch (e) {
      //print('Error fetching user data: $e');
      // Możesz obsłużyć błędy tutaj
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Portfolio'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Portfolio'),
      ),
      body: ListView(
        padding: EdgeInsets.all(20.0),
        children: [
          ProfileInfoTile(label: 'Imię...', value: user.username, icon: Icons.person),
          SizedBox(height: 20),
          ProfileInfoTile(label: 'Wiek...', value: user.age != null ? user.age!.toString() : '', icon: Ionicons.calendar),
          SizedBox(height: 20),
          ProfileInfoTile(label: 'Dzieci...', value: user.children, icon: Icons.child_friendly, checkbox: true, checkboxValue: user.childrenCheckbox),
          SizedBox(height: 20),
          ProfileInfoTile(label: 'Moja wymarzona kobieta...', value: user.favWoman, icon: Icons.woman_2),
          SizedBox(height: 20),
          ProfileInfoTile(label: 'Jedyna słuszna partia to...', value: user.politics, icon: Icons.policy),
          SizedBox(height: 20),
          ProfileInfoTile(label: 'Marzę o...', value: user.dreams, icon: Icons.settings_system_daydream),
          SizedBox(height: 20),
          ProfileInfoTile(label: 'Żałuję...', value: user.regrets, icon: Icons.cake),
          SizedBox(height: 20),
          ProfileInfoTile(label: 'Palę...', value: user.smoke, icon: Icons.smoke_free_outlined, checkbox: true, checkboxValue: user.smokeCheckbox),
          SizedBox(height: 20),
          ProfileInfoTile(label: 'Piję...', value: user.drink, icon: Ionicons.beer_outline, checkbox: true, checkboxValue: user.drinkCheckbox),
          SizedBox(height: 20),
          ProfileInfoTile(label: 'W łóżku najbardziej lubię...', value: user.sexPref, icon: Icons.bed_sharp),
          SizedBox(height: 20),
          ProfileInfoTile(label: 'W wolnym czasię najchętniej...', value: user.freeTime, icon: Ionicons.american_football_outline),
          SizedBox(height: 20),
          ProfileInfoTile(label: 'Lubię, kiedy kobieta...', value: user.favWoman, icon: FontAwesomeIcons.faceGrinTongue),
          SizedBox(height: 20),
          ProfileInfoTile(label: 'Jestem orientacji...', value: _getOrientationLabel(user.orientation), icon: FontAwesomeIcons.transgender),
        ],
      ),
    );
  }

  String _getOrientationLabel(String? orientation) {
    double value = double.parse(orientation ?? '0.0');
    if (value < 50) {
      return 'Biseksualna';
    } else if (value >= 25 && value < 75) {
      return 'Biseksualna z większym naciskiem w stronę kobiet';
    } else {
      return 'Zdeklarowana lesbijka';
    }
  }
}

class ProfileInfoTile extends StatelessWidget {
  final String label;
  final dynamic value;
  final IconData icon;
  final bool checkbox;
  final bool? checkboxValue;

  const ProfileInfoTile({
    required this.label,
    required this.value,
    required this.icon,
    this.checkbox = false,
    this.checkboxValue,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.secondary),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: _buildSubtitle(context),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    if (checkbox) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: checkboxValue ?? false,
                onChanged: null,
              ),
              Text('Tak'),
              SizedBox(width: 10),
              Checkbox(
                value: !(checkboxValue ?? true),
                onChanged: null,
              ),
              Text('Nie'),
            ],
          ),
          SizedBox(height: 5),
          if (value != null && value.isNotEmpty) Text(value),
        ],
      );
    } else {
      if (value == null) {
        return Text('Unknown');
      } else if (value is bool) {
        return Text(value ? 'Tak' : 'Nie');
      } else {
        return Text(value.toString());
      }
    }
  }
}
