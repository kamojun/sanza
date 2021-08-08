import 'package:flutter/material.dart';

import '../models/geo.dart';

class InfoBox extends StatelessWidget {
  static const double width = 200;
  static const double height = 200;
  final Place place;
  final double distance;
  final void Function()? onDelete;
  const InfoBox(this.place, this.distance, this.onDelete, {Key? key})
      : super(key: key);
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
        color: Colors.grey.shade700,
        width: width,
        height: height,
        child: Column(
          children: [
            row(place.name),
            row(place.name2),
            ...place.info.entries.map((e) => row('${e.key} : ${e.value}')),
            row('現在地から : ${distance.toStringAsFixed(1)}km'),
            Spacer(),
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
