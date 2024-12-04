// import 'dart:math';
//
// class DistanceCalculator {
//   static double calculateDistance(
//       double lat1, double lon1, double lat2, double lon2) {
//     const double earthRadius = 6371.0; // Średnica Ziemi w kilometrach
//
//     // Konwersja stopni na radiany
//     double lat1Radians = _degreesToRadians(lat1);
//     double lon1Radians = _degreesToRadians(lon1);
//     double lat2Radians = _degreesToRadians(lat2);
//     double lon2Radians = _degreesToRadians(lon2);
//
//     // Różnice szerokości i długości geograficznej
//     double dLat = lat2Radians - lat1Radians;
//     double dLon = lon2Radians - lon1Radians;
//
//     // Obliczenie wartości funkcji haversine
//     double a = pow(sin(dLat / 2), 2) +
//         cos(lat1Radians) * cos(lat2Radians) * pow(sin(dLon / 2), 2);
//     double c = 2 * atan2(sqrt(a), sqrt(1 - a));
//
//     // Obliczenie odległości
//     double distance = earthRadius * c;
//     return distance;
//   }
//
//   static double _degreesToRadians(double degrees) {
//     return degrees * (pi / 180);
//   }
// }


import 'dart:math';

class DistanceCalculator {
  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Promień Ziemi w kilometrach
    var dLat = _toRad(lat2 - lat1);
    var dLon = _toRad(lon2 - lon1);
    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) *
            cos(_toRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var distance = R * c;
    return distance;
  }

  static double _toRad(double input) {
    return input * (pi / 180);
  }
}
