import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';

void main() {
  runApp(MaterialApp(
    home: MainScreen(),
  ));
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _homeloc = "searching...";
  Position _currentPosition;
  String gmaploc = "";
  CameraPosition _userpos;
  double latitude = 6.4676929;
  double longitude = 100.5067673;
  Set<Marker> markers = Set();
  MarkerId markerId1 = MarkerId("12");
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController gmcontroller;
  MapType _currentMapType = MapType.normal;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    var alheight = MediaQuery.of(context).size.height;
    var alwidth = MediaQuery.of(context).size.width;
    try {
      _controller = Completer();
      _userpos = CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 17,
      );
      return SafeArea(
          child: Scaffold(
              backgroundColor: Colors.deepPurple[900],
              resizeToAvoidBottomPadding: false,
              appBar: AppBar(
                centerTitle: true,
                title: Text(
                  "Google Map",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              body: SingleChildScrollView(
                child: Column(
                    children: [
                      Container(
                        child: Align(
                          child: Column(
                            children: <Widget>[
                              SizedBox(height: 15),
                              FloatingActionButton(
                                heroTag: "btn1",
                                onPressed: _onMapTypeButtonPressed,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.padded,
                                backgroundColor: Colors.deepPurpleAccent,
                                child: const Icon(Icons.map,
                                    size: 36.0, color: Colors.black),
                              ),
                              SizedBox(height: 15),
                              Container(
                                height: alheight - 220,
                                width: alwidth - 20,
                                child: GoogleMap(
                                    mapType: _currentMapType,
                                    initialCameraPosition: _userpos,
                                    markers: markers.toSet(),
                                    onMapCreated: (controller) {
                                      _controller.complete(controller);
                                    },
                                    onTap: (newLatLng) {
                                      _loadLoc(newLatLng);
                                    }),
                              ),
                              SizedBox(height: 10),
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(7, 0, 0, 0),
                                  child: Row(
                                    // mainAxisAlignment: MainAxisAlignment.center,
                                    // crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Center(
                                        child: Container(
                                          child: Text("Current Address :",
                                              style: TextStyle(
                                                  color: Colors.yellow,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(7, 0, 0, 0),
                                child: Text(
                                  _homeloc,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                              ),
                              SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(5, 0, 200, 0),
                                child: Container(
                                  child: Text(
                                    "Current Latitude:",
                                    style: TextStyle(
                                        color: Colors.yellow,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(5, 0, 240, 0),
                                child: Container(
                                  child: Text(
                                    latitude.toStringAsFixed(7),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(5, 0, 185, 0),
                                child: Container(
                                  child: Text(
                                    "Current Longitude:",
                                    style: TextStyle(
                                        color: Colors.yellow,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(5, 0, 225, 10),
                                child: Container(
                                  child: Text(
                                    longitude.toStringAsFixed(7),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]),
              )));
    } catch (e) {
      print(e);
    }
  }

  void _loadLoc(LatLng loc) async {
    markers.clear();
    latitude = loc.latitude;
    longitude = loc.longitude;
    _getLocationfromlatlng(latitude, longitude);
    markers.add(Marker(
      markerId: markerId1,
      position: LatLng(latitude, longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    ));
    _userpos = CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: 17,
    );
  }

  _getLocationfromlatlng(double lat, double lng) async {
    final Geolocator geolocator = Geolocator()
      ..placemarkFromCoordinates(lat, lng);
    _currentPosition = await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final coordinates = new Coordinates(lat, lng);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    _homeloc = first.addressLine;
    setState(() {
      _homeloc = first.addressLine;
    });
  }

  Future<void> _getLocation() async {
    try {
      final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
      geolocator
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
          .then((Position position) async {
        print(position);
        markers.add(Marker(
          markerId: markerId1,
          position: LatLng(latitude, longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ));
        _currentPosition = position;
        if (_currentPosition != null) {
          final coordinates = new Coordinates(
              _currentPosition.latitude, _currentPosition.longitude);
          var addresses =
              await Geocoder.local.findAddressesFromCoordinates(coordinates);
          setState(() {
            var first = addresses.first;
            _homeloc = first.addressLine;
            if (_homeloc != null) {
              latitude = _currentPosition.latitude;
              longitude = _currentPosition.longitude;
            }
          });
        }
      });
    } catch (exception) {
      print(exception.toString());
    }
  }

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }
}
