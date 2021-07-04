import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/geo.dart';
import '../compass.dart';

class Chart extends StatelessWidget {
  final Location currentLocation;
  final double direction;
  final List<Place> places;
  Chart(this.currentLocation, this.direction, this.places);
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Consumer<Compass>(builder: (ctx, compass, child) {
      return Container(
        child: CustomPaint(
          size: Size(size.width, size.width),
          painter: MyPainter(currentLocation, compass.angle, places, size),
        ),
      );
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
  MyPainter(this.centerLocation, this.direciton, this.places, this.size)
      : center = size.width / 2;
  double displayDistance(double realDistance) {
    const a = 100; // centerの半分となるときのrealDistance
    return (center - 30) * (1 - a / (realDistance + a));
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
      textPainter.paint(canvas, offset);
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
      writeText(place.name, offset * 1.1 + Offset(-30, -10));
    }

    canvas.translate(center, center);
    double halfcenter = center / 2;
    canvas.drawCircle(Offset.zero, halfcenter, myPaint); // 100キロ
    writeText("100km", Offset(halfcenter, 0), color: Colors.grey.shade300);
    writeText("北", rotate(Offset(0, -halfcenter), -direciton) - Offset(10, 10));
    places.forEach(drawPlace);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
