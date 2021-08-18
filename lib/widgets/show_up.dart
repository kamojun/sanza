import 'package:flutter/material.dart';
import 'dart:async';

class ShowUp extends StatefulWidget {
  final Widget child;
  final Duration delay;

  ShowUp({required this.child, required this.delay, Key? key})
      : super(key: key);

  @override
  _ShowUpState createState() => _ShowUpState();
}

class _ShowUpState extends State<ShowUp> with TickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 100),
      lowerBound: 0.2,
    );
    Timer(widget.delay, () {
      _animController.forward();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _animController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      child: widget.child,
      opacity: _animController,
    );
  }
}
