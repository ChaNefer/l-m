class DistanceSlider {
  double _currentDistance = 100; // Domyślna wartość odległości

  double get currentDistance => _currentDistance;

  set currentDistance(double value) {
    _currentDistance = value;
  }
}
