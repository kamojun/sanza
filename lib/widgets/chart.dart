import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/geo.dart';
import '../compass.dart';
import '../data/magnetic_declination.dart';
import '../widgets/info_box.dart';

class Chart extends StatefulWidget {
  final Location currentLocation;
  final double direction;
  final List<Place> places;
  final bool drawNESW;
  Chart(this.currentLocation, this.direction, this.places, this.drawNESW);

  @override
  _ChartState createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  double _scale = 100; // 画面の半分に来るような距離
  double _cachedScale = 100;
  get infoShowing => selectedPlace != null;
  Place? selectedPlace;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double center = size.width / 2;
    return Consumer<Compass>(builder: (ctx, compass, child) {
      final angle = compass.angle -
          getMagneticDecliniation(
              widget.currentLocation.lat, widget.currentLocation.lng);
      CustomPaint customPaint = CustomPaint(
        size: Size(size.width, size.width),
        painter: MyPainter(
          widget.currentLocation,
          angle,
          widget.places,
          size,
          _scale,
          widget.drawNESW,
        ),
      );
      if (infoShowing) {
        return Stack(
          children: [
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: GestureDetector(
                onTap: () => setState(() {
                  selectedPlace = null;
                }),
                child: customPaint,
              ),
            ),
            Positioned(
              left: center - InfoBox.width / 2,
              top: center - InfoBox.height / 2,
              child: InfoBox(selectedPlace!,
                  widget.currentLocation.distanceTo(selectedPlace!), () {
                setState(() {
                  widget.places.remove(selectedPlace);
                  selectedPlace = null;
                });
              }),
            ),
          ],
        );
      } else {
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
                final dist = (center - 30) *
                    (1 - _scale / (loc.distanceTo(place) + _scale));
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
                setState(() {
                  selectedPlace = widget.places[currentIndex];
                });
            }
          },
        );
      }
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
  final bool drawNEWS;
  MyPainter(
    this.centerLocation,
    this.direciton,
    this.places,
    this.size,
    this.scale,
    this.drawNEWS,
  ) : center = size.width / 2;
  double displayDistance(double realDistance) {
    // center-30(画面からはみ出ない半径)に収まるような関数
    return (center - 30) * (1 - this.scale / (realDistance + this.scale));
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

    canvas.translate(center, center); // 座標の原点を画面の中心に

    canvas.drawCircle(Offset.zero, displayDistance(100), myPaint); // 100キロ
    writeText(
      "100km",
      Offset(displayDistance(100), 0),
      color: Colors.grey.shade300,
    );
    if (drawNEWS) {
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.grey.shade300;
      final ns = rotate(Offset(0, -center), -direciton);
      final ew = rotate(Offset(0, -center), -direciton + math.pi / 2);
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
        ..color = Colors.blue.shade300,
    ); // 100キロ
    places.forEach(drawPlace);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

void Balloon(Canvas canvas, Offset ofs) {
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(ofs.dx - 30, ofs.dy - 60, 100, 30),
      Radius.circular(10),
    ),
    Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black12,
  );
  canvas.drawLine(
      Offset.zero,
      Offset.zero,
      Paint()
        ..style = PaintingStyle.fill
        ..strokeWidth = 1
        ..color = Colors.white);
  final textStyle = TextStyle(
    color: Colors.white,
    fontSize: 20,
  );
  TextPainter(
    text: TextSpan(
      text: "情報",
      style: textStyle,
    ),
    textDirection: TextDirection.ltr,
  ).paint(canvas, ofs + Offset(-10, -10));
  TextPainter(
    text: TextSpan(
      text: "削除",
      style: textStyle,
    ),
    textDirection: TextDirection.ltr,
  ).paint(canvas, ofs + Offset(10, -10));
}
