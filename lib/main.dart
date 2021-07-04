import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

import './models/geo.dart';
import './widgets/chart.dart';
import './place_search.dart';
import './compass.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'あの山を探せ！',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
  double _direction = 0;
  List<Place> _places = [];

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
    print(pos);
    setState(() {
      _location = Location(pos.latitude, pos.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Compass>(
      create: (_) => Compass(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('あの山を探せ!'),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              tooltip: "場所を追加",
              onPressed: () async {
                final result =
                    await showSearch(context: context, delegate: PlaceSearch());
                if (result != null)
                  setState(() {
                    _places.add(result);
                  });
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              TextButton(
                child: Text('現在地取得'),
                onPressed: _getCurrentUserLocation,
              ),
              _location == null
                  ? Text("location unknown")
                  : Text(
                      'lat: ${_location!.lat.toStringAsFixed(3)}\nlng: ${_location!.lng.toStringAsFixed(3)}',
                      style: Theme.of(context).textTheme.headline6,
                    ),
              if (_location != null)
                Expanded(
                  child: Center(
                    child: Chart(_location!, _direction, _places),
                  ),
                ),
              if (_location != null)
                Container(
                  margin: EdgeInsets.all(20),
                  child: TextButton(
                    child: Text('全て消去'),
                    onPressed: () => setState(() {
                      _places = [];
                    }),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
