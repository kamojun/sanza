import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/geo.dart';
import '../widgets/info_box.dart';
import '../widgets/map.dart';

class Chart extends StatefulWidget {
  final Location currentLocation;
  final List<Place> places;
  final Function() clearAllPlaces;
  final Function(Place?) removePlace;
  Chart(
      this.currentLocation, this.places, this.clearAllPlaces, this.removePlace);

  @override
  _ChartState createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  bool _drawNESW = false;
  Place? selectedPlace;
  get infoShowing => selectedPlace != null;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double center = size.width / 2;

    Widget compassMap = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Center(
            child: CompassMap(
              widget.currentLocation,
              widget.places,
              _drawNESW,
              size,
              (place) => setState(() {
                selectedPlace = place;
              }),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                child: _drawNESW ? Text('方角を非表示') : Text('方角を表示'),
                onPressed: () => setState(() {
                  _drawNESW = !_drawNESW;
                }),
              ),
              TextButton(
                child: Text('全て消去'),
                onPressed:
                    widget.places.length == 0 ? null : widget.clearAllPlaces,
              ),
            ],
          ),
        ),
      ],
    );
    if (infoShowing) {
      return Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() {
              selectedPlace = null;
            }),
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: AbsorbPointer(child: compassMap),
            ),
          ),
          Positioned(
            left: center - InfoBox.width / 2,
            top: center - InfoBox.height / 2,
            child: InfoBox(selectedPlace!,
                widget.currentLocation.distanceTo(selectedPlace!), () {
              widget.removePlace(selectedPlace);
              setState(() {
                selectedPlace = null;
              });
            }),
          ),
        ],
      );
    } else {
      return compassMap;
    }
  }
}
