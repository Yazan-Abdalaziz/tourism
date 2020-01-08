import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tourism/CustomSearchDelegate.dart';
import 'package:tourism/Routes.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tourism/medel/User.dart';
import 'package:tourism/util/AddressAndPosition.dart';
import 'package:tourism/util/ResearchesFirebase.dart';
import 'dart:async';
import 'dart:math';
import 'package:vector_math/vector_math.dart' as mt;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> optionsMenu = [];
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _cameraPosition = CameraPosition(target: LatLng(48.265250, 11.671237), zoom: 16);
  String _localUser = "";
  Set<Marker> _markers = {};
  Marker _newMarker = Marker();
  String _markerAddress;
  User _user = User();
  LatLng _latLngSearch;
  bool _buttonAdd = false;
  Firestore _db = Firestore.instance;

  _logoutUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    Navigator.pushReplacementNamed(context, Routes.ROUT_INICIAL,
        arguments: _cameraPosition);
  }

  _menuOptionChosen(String option) {
    switch (option) {
      case "Administrator":
        Navigator.pushNamed(context, Routes.ROUT_ADMINISTRATOR);
        break;

      case "Log Out":
        _logoutUser();
        break;

      case "Settings":
        print("Clicado em configuracoes");
        break;
    }
  }

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  _listenerLocation() async {
    var geolocator = Geolocator();
    var locationOptions =
    LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
    geolocator.getPositionStream(locationOptions).listen((Position position) {
      setState(() {
        _cameraPosition = CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 16);
        _moveCamera(_cameraPosition);
      });
      _showMarkerCurrentLocation();
      Future<String> address = AddressAndPosition.positionToAddress(LatLng(_cameraPosition.target.latitude, _cameraPosition.target.longitude));
      address.then((address){
        setState(() {
          _localUser = address;
        });
        _checkMarker();
      });
    });
  }

  _moveCamera(CameraPosition cameraPosition) async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  _getLastKnownLocation() async {
    Position position = await Geolocator()
        .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      if (position != null) {
        _showMarkerCurrentLocation();
        _cameraPosition = CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 16);
      }
    });
  }

  double _calculateDistance(LatLng destiny) {
    var La1 = mt.radians(_cameraPosition.target.latitude);
    var La2 = mt.radians(destiny.latitude);
    var Lo1 = mt.radians(_cameraPosition.target.longitude);
    var Lo2 = mt.radians(destiny.longitude);
    var cosLa1 = cos(90 - La1);
    var cosLa2 = cos(90 - La2);
    var senLa1 = sin(90 - La1);
    var senLa2 = sin(90 - La2);
    var cosLo1Lo2 = cos(Lo1 - Lo2);
    var distance = 6371 * (acos(cosLa1 * cosLa2 + senLa1 * senLa2 * cosLo1Lo2));
    return distance;
  }

  _showMarkerCurrentLocation() async {
    setState(() {
      _markers = {};
    });
    QuerySnapshot querySnapshot = await _db.collection("position").getDocuments();
    for (var item in querySnapshot.documents) {
      var data = item.data;
      if (data["latLng"]["latitude"] != _cameraPosition.target.latitude.toString() &&
          data["latLng"]["longitude"] != _cameraPosition.target.longitude.toString()) {
        double distance = _calculateDistance(LatLng(double.parse(data["latLng"]["latitude"]), double.parse(data["latLng"]["longitude"])));
        Marker marker = Marker(
          markerId: MarkerId(data["idMarker"]),
          position: LatLng(double.parse(data["latLng"]["latitude"]),
              double.parse(data["latLng"]["longitude"])),
          infoWindow: InfoWindow(
            title: data["title"],
            snippet: (data["latLng"]["latitude"] == _cameraPosition.target.latitude.toStringAsFixed(4) &&
                data["latLng"]["longitude"] == _cameraPosition.target.longitude.toStringAsFixed(4)) ?
            null : distance.toStringAsFixed(2) + " km",
            onTap: () {
              Navigator.pushNamed(context, Routes.ROUT_LISTGUIDES, arguments: LatLng(double.parse(data["latLng"]["latitude"]), double.parse(data["latLng"]["longitude"])));
            },
          ),
          onTap: (){
            AddressAndPosition.positionToAddress(LatLng(double.parse(data["latLng"]["latitude"]), double.parse(data["latLng"]["longitude"]))).then((address){
              setState(() {
                _localUser = address;
              });
            });
            _checkMarker();
          },
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        );
        setState(() {
          _markers.add(marker);
        });
      }
    }
  }

  _addMarkerWithSearch(LatLng latLng, {String address}) async {
    _markers.remove(_newMarker);
    Map<String, dynamic> map = {
      "latitude": latLng.latitude.toStringAsFixed(4),
      "longitude": latLng.longitude.toStringAsFixed(4),
    };
    Map<String, dynamic> mapPosition = {
      "latLng": map,
      "idMarker": _newMarker.markerId.value.replaceAll(new RegExp(r"\s+\b|\b\s"), ""),
      "title": _newMarker.infoWindow.title
    };
    _db.collection("position").add(mapPosition);
    _showMarkerCurrentLocation();
    setState(() {
      _buttonAdd = false;
    });
  }

  _addMarkerWithLongPress(LatLng latLng, String address){
    AddressAndPosition.titleMarker(latLng).then((title){
      Marker marker = Marker(
        markerId: MarkerId(title.replaceAll(new RegExp(r"\s+\b|\b\s"), "")),
        position: LatLng(latLng.latitude, latLng.longitude),
        infoWindow: InfoWindow(
          title: title,
          snippet: (latLng.latitude.toStringAsFixed(4) == _cameraPosition.target.latitude.toStringAsFixed(4) &&
              latLng.longitude.toStringAsFixed(4) == _cameraPosition.target.longitude.toStringAsFixed(4)) ?
          null : _calculateDistance(latLng).toStringAsFixed(2) + " km",
          onTap: () {
            Navigator.pushNamed(context, Routes.ROUT_LISTGUIDES, arguments: LatLng(latLng.latitude, latLng.longitude));
          },
        ),
        onTap: (){
          setState(() {
            _localUser = address;
          });
          _checkMarker();
        },
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      );
      setState(() {
        _markers.add(marker);
        _localUser = address;
      });
      Map<String, dynamic> map = {
        "latitude": latLng.latitude.toStringAsFixed(4),
        "longitude": latLng.longitude.toStringAsFixed(4),
      };
      Map<String, dynamic> mapPosition = {
        "latLng": map,
        "idMarker": marker.markerId.value.replaceAll(new RegExp(r"\s+\b|\b\s"), ""),
        "title": marker.infoWindow.title
      };
      _db.collection("position").add(mapPosition);
      _showMarkerCurrentLocation();
    });
  }

  _validatePositionLongPress (LatLng latLng) async {
    ResearchesFirebase.positionExist(latLng).then((exist){
      if(exist){
        showDialog(
            context: context,
            builder: (BuildContext context){
              return AlertDialog(
                title: Text("Position already exists"),
                content: Text("Unable to create a new marker at the selected place because the position already exists"),
                actions: <Widget>[
                  FlatButton(
                      child: Text("Ok", style: TextStyle(color: Colors.black),),
                      onPressed: (){Navigator.of(context).pop();}
                  ),
                ],
              );
            }
        );
      } else {
        AddressAndPosition.positionToAddress(latLng).then((address){
          showDialog(
              context: context,
              builder: (BuildContext context){
                return AlertDialog(
                  title: Text("Add Marker"),
                  content: Text("Is this the correct place to add a marker? \n"+address),
                  actions: <Widget>[
                    FlatButton(
                        child: Text("Yes", style: TextStyle(color: Colors.black),),
                        onPressed: (){
                          _addMarkerWithLongPress(latLng, address);
                          Navigator.of(context).pop();
                        }
                    ),
                    FlatButton(
                        child: Text("No", style: TextStyle(color: Colors.black),),
                        onPressed: (){Navigator.of(context).pop();}
                    ),
                  ],
                );
              }
          );
        });
      }
    });
  }

  _checkMarker(){
    if((_localUser != _markerAddress) && (_buttonAdd = true)){
      _markers.remove(_newMarker);
      _buttonAdd = false;
    }
  }

  _validatePositionSearch (LatLng latLng, String address) async {
    ResearchesFirebase.positionExist(latLng).then((exist){
      if(!exist) {
        AddressAndPosition.titleMarker(latLng).then((title) {
          setState(() {
            _buttonAdd = true;
          });
          Marker marker = Marker(
            markerId: MarkerId(title.replaceAll(new RegExp(r"\s+\b|\b\s"), "")),
            position: LatLng(latLng.latitude, latLng.longitude),
            infoWindow: InfoWindow(
              title: title,
              snippet: (latLng.latitude.toStringAsFixed(4) == _cameraPosition.target.latitude.toStringAsFixed(4) &&
                  latLng.longitude.toStringAsFixed(4) == _cameraPosition.target.longitude.toStringAsFixed(4)) ?
              null : _calculateDistance(latLng).toStringAsFixed(2) + " km",
              onTap: () {
                Navigator.pushNamed(context, Routes.ROUT_LISTGUIDES, arguments: LatLng(latLng.latitude, latLng.longitude));
              },
            ),
            onTap: () {
              setState(() {
                _localUser = address;
              });
              _checkMarker();
            },
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          );
          setState(() {
            _markers.add(marker);
            _newMarker = marker;
            _markerAddress = address;
          });
        });
      }
    });
  }

  _showFullAddress() {
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text("Full Adress"),
            content: Text(_localUser),
            actions: <Widget>[
              FlatButton(
                  child: Text("Ok", style: TextStyle(color: Colors.black),),
                  onPressed: (){Navigator.of(context).pop();}
              ),
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    _getLastKnownLocation();
    _listenerLocation();
    //new Timer (new Duration(seconds: 3), () { _gerarAudio();});
    ResearchesFirebase.getDataFromUser().then((user) {
      setState(() {
        _user = user;
      });
      if(_user.adm){
        optionsMenu = ["Administrator", "Settings", "Log Out"];
      } else {
        optionsMenu = ["Settings", "Log Out"];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Map"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              String search = await showSearch(context: context, delegate: CustomSearchDelegate());
              print("PESQUISA FEITA: " + search);
              AddressAndPosition.addressToPosition(search).then((latLng){
                if(latLng != null){
                  _moveCamera(CameraPosition(target: latLng, zoom: 16));
                  AddressAndPosition.positionToAddress(latLng).then((address){
                    setState(() {
                      _localUser = address;
                      _latLngSearch = latLng;
                    });
                    _validatePositionSearch(latLng, address);
                  });
                }
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: _menuOptionChosen,
            itemBuilder: (context) {
              return optionsMenu.map((String item) {
                return PopupMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            GoogleMap(
              mapType: MapType.normal,
              //TUM Garching - 48.265250, 11.671237
              initialCameraPosition: _cameraPosition,
              onMapCreated: _onMapCreated,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              markers: _markers,
              onLongPress: _validatePositionLongPress,
              zoomGesturesEnabled: true,
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.white),
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      icon: Container(
                        margin: EdgeInsets.only(left: 15),
                        width: 10,
                        height: 10,
                        child: Icon(
                          Icons.location_on,
                          color: Colors.black,
                        ),
                      ),
                      hintText: _localUser,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(left: 5, top: 15),
                    ),
                    onTap: (){
                      _showFullAddress();
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 25,
              left: 15,
              child: Padding(
                padding: EdgeInsets.only(top: 10),
                child: Container(
                  width: 40,
                  height: 40,
                  child: RawMaterialButton(
                    fillColor: Colors.black,
                    shape: CircleBorder(),
                    child: Icon(
                      Icons.location_searching,
                      color: Colors.white,
                      size: 25,
                    ),
                    onPressed: () {
                      _moveCamera(_cameraPosition);
                      AddressAndPosition.positionToAddress(_cameraPosition.target).then((address){
                        setState(() {
                          _localUser = address;
                        });
                      });
                    },
                  ),
                ),
              ),
            ),
            _buttonAdd ?
            Positioned(
              bottom: 75,
              left: 15,
              child: Padding(
                padding: EdgeInsets.only(top: 10),
                child: Container(
                  width: 40,
                  height: 40,
                  child: RawMaterialButton(
                    fillColor: Colors.black,
                    shape: CircleBorder(),
                    child: Icon(
                      Icons.add_location,
                      color: Colors.white,
                      size: 25,
                    ),
                    onPressed: () {
                      _addMarkerWithSearch(_latLngSearch);
                    },
                  ),
                ),
              ),
            ) :
            Container(),
          ],
        ),
      ),
    );
  }
}
