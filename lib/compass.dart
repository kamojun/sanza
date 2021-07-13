import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

class Compass with ChangeNotifier {
  double _angle = 0;
  double get angle => _angle;
  Compass() {
    FlutterCompass.events?.listen((value) {
      if (value.heading != null) _angle = value.heading! / 180 * pi;
      notifyListeners();
    });
  }
}
