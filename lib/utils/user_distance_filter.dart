import '../models/user.dart';
import 'distance_calculator.dart';

class UserDistanceFilter {
  static List<UserModel> filterUsersByDistance(
      List<UserModel> users, UserModel currentUser, double maxDistance) {
    List<UserModel> filteredUsers = [];

    // Pobranie współrzędnych aktualnego użytkownika
    double userLat = currentUser.latitude ?? 0.0;
    double userLon = currentUser.longitude ?? 0.0;

    for (var user in users) {
      double userDistance = DistanceCalculator.calculateDistance(
          user.latitude ?? 0.0, user.longitude ?? 0.0, userLat, userLon);

      // Sprawdzenie, czy odległość jest mniejsza niż maksymalna odległość
      if (userDistance <= maxDistance) {
        filteredUsers.add(user);
      }
    }

    return filteredUsers;
  }
}
