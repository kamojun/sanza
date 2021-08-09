import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';

import '../data/magnetic_declination.dart' as md;

const EARTH_DIAMETER = 6371;

class Location {
  final double lat;
  final double lng;
  final double theta;
  final double phi;
  const Location(this.lat, this.lng)
      : theta = lat * pi / 180,
        phi = lng * pi / 180;
  List<double> get coord =>
      [cos(theta) * cos(phi), cos(theta) * sin(phi), sin(theta)];
  double distanceTo(Location loc) => distance(this, loc);

  /// 北が0、ラジアン
  double azimuthTo(Location loc) => azimuth(this, loc) / 180 * pi;

  /// 磁北偏角を取得
  double magneticDecliniation({bool asDegree: false}) => !asDegree
      ? md.getMagneticDecliniation(lat, lng)
      : this.magneticDecliniation() / pi * 180;
}

enum PlaceKind {
  Mountain,
  City,
}

String genId(double x, double y, String name) {
  var bdata = new ByteData(16);
  bdata.setFloat64(0, x);
  bdata.setFloat64(8, y);
  return base64Encode(bdata.buffer.asUint8List().toList()) + name;
}

class Place extends Location {
  final String id;
  final PlaceKind kind;
  final String name;
  final String name2;
  final Map<String, String> info;
  const Place(double lat, double lng, this.id, this.kind, this.name, this.name2,
      this.info)
      : super(lat, lng);
}

double distance(Location loc1, Location loc2) {
  double innerProduct = Iterable<int>.generate(3)
      .fold(0, (value, i) => value + loc1.coord[i] * loc2.coord[i]);
  return EARTH_DIAMETER * acos(innerProduct);
}

double logDistanceScaled(Location loc1, Location loc2, double scaleOf100km) {
  return log(distance(loc1, loc2)) / log(100) * scaleOf100km;
}

double azimuth(Location loc1, Location loc2) {
  if (loc1.lng == loc2.lng) {
    return loc1.lat >= loc2.lat ? 0 : 180;
  }
  final dphi = loc2.phi - loc1.phi;
  final theta1 = loc1.theta;
  final theta2 = loc2.theta;
  final deg =
      atan((cos(theta1) * tan(theta2) - sin(theta1) * cos(dphi)) / sin(dphi)) /
          pi *
          180;
  return loc1.lng < loc2.lng ? 90 - deg : 270 - deg;
}
