import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/geo.dart';
import '../compass.dart';
import '../data/magnetic_declination.dart';

Offset rotate(Offset offset, double degree) {
  final x = offset.dx * math.cos(degree) - offset.dy * math.sin(degree);
  final y = offset.dx * math.sin(degree) + offset.dy * math.cos(degree);
  return Offset(x, y);
}

double displayDistance(double realDistance, double scale, double width) {
  // center-30(画面からはみ出ない半径)に収まるような関数
  return (width - 30) * (1 - scale / (realDistance + scale));
}

class CompassMapPainter extends CustomPainter {
  final Location currentLocation;
  final double angle;
  final List<Place> places;
  final Size size;
  final double center;
  final double scale;
  final bool drawNESW;
  CompassMapPainter(
    this.currentLocation,
    this.places,
    this.scale,
    this.angle,
    this.size,
    this.drawNESW,
  ) : center = size.width / 2;

  double displayDistance2(double realDistance) {
    // center-30(画面からはみ出ない半径)に収まるような関数
    return displayDistance(realDistance, scale, center);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(
        Rect.fromLTRB(0, 0, size.width, size.height)); // canvasの外への描画を防ぐ
    final myPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.grey.shade300;

    void writeText(String text, Offset offset, {Color? color}) {
      final textStyle = TextStyle(
        color: color == null ? Colors.green : color,
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
      final degree = currentLocation.azimuthTo(place) - math.pi / 2 - angle;
      final dist = displayDistance2(currentLocation.distanceTo(place));
      final offset = Offset(dist * math.cos(degree), dist * math.sin(degree));
      canvas.drawLine(Offset.zero, offset, myPaint);
      writeText(place.name, offset);
    }

    canvas.translate(center, center); // 座標の原点を画面の中心に

    canvas.drawCircle(Offset.zero, displayDistance2(100), myPaint); // 100キロ
    writeText(
      "100km",
      Offset(displayDistance2(100), 0),
      color: Colors.grey.shade300,
    );
    if (drawNESW) {
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.grey.shade300;
      final ns = rotate(Offset(0, -center), -angle);
      final ew = rotate(Offset(0, -center), -angle + math.pi / 2);
      canvas.drawLine(ns, -ns, p);
      canvas.drawLine(ew, -ew, p);
      writeText("N", ns, color: Colors.grey);
      writeText("E", ew, color: Colors.grey);
      writeText("S", -ns, color: Colors.grey);
      writeText("W", -ew, color: Colors.grey);
    }
    canvas.drawCircle(
      Offset.zero,
      5,
      Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.green.shade300,
    ); // 100キロ
    places.forEach(drawPlace);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class CompassMap extends StatefulWidget {
  final Location currentLocation;
  final List<Place> places;
  final bool drawNESW;
  final Size size;
  final Function(Place) setSelectedPlace;
  CompassMap(
    this.currentLocation,
    this.places,
    this.drawNESW,
    this.size,
    this.setSelectedPlace,
  );

  @override
  _CompassMapState createState() => _CompassMapState();
}

class _CompassMapState extends State<CompassMap> {
  double _scale = 100; // 画面の半分に来るような距離
  double _cachedScale = 100;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double center = size.width / 2;
    return Consumer<Compass>(builder: (ctx, compass, child) {
      final angle = compass.angle -
          getMagneticDecliniation(
              widget.currentLocation.lat, widget.currentLocation.lng);
      final customPaint = CustomPaint(
        size: Size(widget.size.width, widget.size.width),
        painter: CompassMapPainter(
          widget.currentLocation,
          widget.places,
          _scale,
          angle,
          widget.size,
          widget.drawNESW,
        ),
      );
      return GestureDetector(
        child: customPaint,
        onScaleStart: (ScaleStartDetails details) {
          _cachedScale = _scale;
        },
        onScaleUpdate: (ScaleUpdateDetails details) {
          setState(() {
            _scale = _cachedScale / details.scale;
            _scale = math.min(1000, math.max(0.1, _scale));
          });
        },
        onLongPressStart: (LongPressStartDetails details) {
          if (widget.places.length > 0) {
            final poss = widget.places.map((place) {
              final loc = widget.currentLocation;
              final degree = loc.azimuthTo(place) - math.pi / 2 - angle;
              final dist =
                  displayDistance(loc.distanceTo(place), _scale, center);
              final ofs = Offset(center + dist * math.cos(degree),
                  center + dist * math.sin(degree));
              final dx = ofs.dx - details.localPosition.dx;
              final dy = ofs.dy - details.localPosition.dy;
              return dx * dx + dy * dy;
            }).toList();
            var currentIndex = 0;
            for (var index = 1; index < poss.length; index++) {
              if (poss[index] < poss[currentIndex]) currentIndex = index;
            }
            print(poss[currentIndex]);
            if (poss[currentIndex] < 500)
              widget.setSelectedPlace(widget.places[currentIndex]);
          }
        },
      );
    });
  }
}
