// import 'package:flutter_test/flutter_test.dart';
// import 'package:les_social/pages/friends_list_page.dart';
// import 'package:http/http.dart' as http;
// import 'package:les_social/services/auth_service.dart';
// import 'package:mockito/mockito.dart';
// import 'package:les_social/models/user.dart';
//
// class MockHttpClient extends Mock implements http.Client {}
//
// void main() {
//   group('FriendsListPage', () {
//     test('should fetch friends successfully', () async {
//       final client = MockHttpClient();
//       final friendsListPage = _FriendsListPageState();
//       friendsListPage._authService = AuthService(client: client); // Assuming you pass client to AuthService
//
//       when(client.get(any))
//           .thenAnswer((_) async => http.Response('[{"id":1,"name":"Friend 1"}]', 200));
//
//       await friendsListPage._fetchCurrentUser();
//       await friendsListPage._getFriends();
//
//       expect(friendsListPage.friends.length, 1);
//       expect(friendsListPage.friends[0].name, 'Friend 1');
//     });
//   });
// }
//
// }
//
//
//
