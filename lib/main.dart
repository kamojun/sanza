import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

import './models/geo.dart';
import './widgets/chart.dart';
import './widgets/search_bar.dart';
import './widgets/show_up.dart';
import './place_search.dart';
import './compass.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // LocationData? _locData;
  Location? _location;
  List<Place> _places = [];
  List<Place> _searchHistory = [];

  Future<void> _getCurrentUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    final pos = await Geolocator.getCurrentPosition();
    setState(() {
      _location = Location(pos.latitude, pos.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Compass>(
      create: (_) => Compass(),
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          border: null,
          middle: Padding(
            padding: const EdgeInsets.all(1.0),
            child: GestureDetector(
              onTap: () async {
                final result = await showSearch<Place?>(
                    context: context, delegate: PlaceSearch(_searchHistory));
                if (result != null)
                  setState(() {
                    _searchHistory
                      ..remove(result)
                      ..add(result);
                    _places
                      ..remove(result)
                      ..add(result);
                  });
              },
              child: SearchBar(),
            ),
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                TextButton(
                  child: Text('?????????????????????????????????'),
                  onPressed: _getCurrentUserLocation,
                ),
                if (_location != null)
                  ShowUp(
                    delay: Duration(milliseconds: 30),
                    child: Text(
                      '??????${_location!.lat.toStringAsFixed(3)}\n??????${_location!.lng.toStringAsFixed(3)}',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    key: ValueKey(DateTime.now()),
                  ),
                if (_location != null)
                  Expanded(
                    child: Chart(
                      _location!,
                      _places,
                      () => setState(() {
                        _places = [];
                      }),
                      (place) => setState(() {
                        _places.remove(place);
                      }),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
