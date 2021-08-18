import 'package:flutter/material.dart';

import '../data/places.dart';
import '../models/geo.dart';

List<String> nearestMountainInfo(Location loc) {
  var currentIndex = Places.indexWhere((p) => p.kind == PlaceKind.Mountain);
  if (currentIndex < 0) return ["なし", ""];
  var currentDistance = Places[currentIndex].distanceTo(loc);
  for (var i = 0; i < Places.length; i++) {
    if (Places[i].kind == PlaceKind.Mountain) {
      final _distance = Places[i].distanceTo(loc);
      if (_distance < currentDistance) {
        currentIndex = i;
        currentDistance = _distance;
      }
    }
  }
  return [
    "最寄りの山 : ${Places[currentIndex].name}",
    "距離 : ${currentDistance.toStringAsFixed(1)}km"
  ];
}

List<String> nearestTownInfo(Location loc) {
  var currentIndex = Places.indexWhere((p) => p.kind == PlaceKind.City);
  if (currentIndex < 0) return ["なし", ""];
  var currentDistance = Places[currentIndex].distanceTo(loc);
  for (var i = 0; i < Places.length; i++) {
    if (Places[i].kind == PlaceKind.City) {
      final _distance = Places[i].distanceTo(loc);
      if (_distance < currentDistance) {
        currentIndex = i;
        currentDistance = _distance;
      }
    }
  }
  return [
    "最寄りの役場 : ${Places[currentIndex].name}",
    "距離 : ${currentDistance.toStringAsFixed(1)}km"
  ];
}

class InfoBox extends StatelessWidget {
  static const double width = 250;
  static const double height = 200;
  final List<String> rows;
  final void Function()? onDelete;
  const InfoBox(this.rows, this.onDelete);
  InfoBox.fromPlace(Place place, double distance, this.onDelete, {Key? key})
      : this.rows = [
          place.name,
          place.name2,
          ...place.info.entries.map((e) => '${e.key} : ${e.value}'),
          '現在地から : ${distance.toStringAsFixed(1)}km'
        ];
  InfoBox.currentLocationInfo(Location currentLocation)
      : this.onDelete = null,
        this.rows = [
          "現在地情報",
          "北緯 : ${currentLocation.lat.toStringAsFixed(5)}",
          "東経 : ${currentLocation.lng.toStringAsFixed(5)}",
          "磁北偏角 : ${currentLocation.magneticDecliniation(asDegree: true)}",
          ...nearestMountainInfo(currentLocation),
          ...nearestTownInfo(currentLocation),
        ];
  Widget row(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: 15,
        decoration: TextDecoration.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: onDelete == null
            ? EdgeInsets.symmetric(vertical: 10)
            : EdgeInsets.only(top: 10),
        color: Colors.grey.shade700,
        width: width,
        child: Column(
          children: [
            ...rows.map(row),
            if (onDelete != null)
              TextButton(
                onPressed: onDelete,
                child: Text(
                  "削除",
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
