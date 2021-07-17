import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/geo.dart';
import '../compass.dart';
import '../data/magnetic_declination.dart';

class Chart extends StatefulWidget {
  final Location currentLocation;
  final double direction;
  final List<Place> places;
  Chart(this.currentLocation, this.direction, this.places);

  @override
  _ChartState createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  double _scale = 100; // 画面の半分に来るような距離
  double _cachedScale = 100;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Consumer<Compass>(builder: (ctx, compass, child) {
      final angle = compass.angle -
          getMagneticDecliniation(
              widget.currentLocation.lat, widget.currentLocation.lng);
      return GestureDetector(
          child: Container(
            child: CustomPaint(
              size: Size(size.width, size.width),
              painter: MyPainter(
                  widget.currentLocation, angle, widget.places, size, _scale),
            ),
          ),
          onScaleStart: (ScaleStartDetails details) {
            _cachedScale = _scale;
          },
          onScaleUpdate: (ScaleUpdateDetails details) {
            setState(() {
              _scale = _cachedScale / details.scale;
            });
          });
    });
  }
}

Offset rotate(Offset offset, double degree) {
  final x = offset.dx * math.cos(degree) - offset.dy * math.sin(degree);
  final y = offset.dx * math.sin(degree) + offset.dy * math.cos(degree);
  return Offset(x, y);
}

class MyPainter extends CustomPainter {
  final Location centerLocation;
  final double direciton;
  final List<Place> places;
  final Size size;
  final double center;
  final double scale;
  MyPainter(
      this.centerLocation, this.direciton, this.places, this.size, this.scale)
      : center = size.width / 2;
  double displayDistance(double realDistance) {
    return (center - 30) * (1 - this.scale / (realDistance + this.scale));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final myPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.grey.shade300;

    void writeText(String text, Offset offset, {Color? color}) {
      final textStyle = TextStyle(
        color: color == null ? Colors.blue : color,
        fontSize: 20,
      );
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout(minWidth: 0, maxWidth: size.width);
      var newOffset =
          offset - Offset(textPainter.width / 2, textPainter.height / 2);
      textPainter.paint(canvas, newOffset);
    }

    void drawPlace(Place place) {
      final myPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.blue.shade300;
      final degree = centerLocation.azimuthTo(place) - math.pi / 2 - direciton;
      final dist = displayDistance(centerLocation.distanceTo(place));
      final offset = Offset(dist * math.cos(degree), dist * math.sin(degree));
      canvas.drawLine(Offset.zero, offset, myPaint);
      writeText(place.name, offset);
    }

    canvas.translate(center, center);
    double halfcenter = center / 2;
    canvas.drawCircle(
        Offset.zero,
        5,
        Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.blue.shade300); // 100キロ
    canvas.drawCircle(Offset.zero, displayDistance(100), myPaint); // 100キロ
    writeText("100km", Offset(displayDistance(100), 0),
        color: Colors.grey.shade300);
    writeText("北", rotate(Offset(0, -halfcenter), -direciton) - Offset(10, 10));
    places.forEach(drawPlace);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
