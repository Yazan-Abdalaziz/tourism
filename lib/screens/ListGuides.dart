import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tourism/Routes.dart';
import 'dart:async';

class ListGuides extends StatefulWidget {
  LatLng position;
  ListGuides(this.position);
  @override
  _ListGuidesState createState() => _ListGuidesState();
}

class _ListGuidesState extends State<ListGuides> {
  final _controller = StreamController<QuerySnapshot>.broadcast();
  Firestore _db = Firestore.instance;
  AudioPlayer audioPlayer = AudioPlayer();
  int _currentIndex = 2;
  bool _firstExecution = true;
  String _localUser = "List of Guides";

  _play(String url) async {
    if (_firstExecution) {
      await audioPlayer.play(url);
      _firstExecution = false;
    } else {
      await audioPlayer.resume();
    }
  }

  _pause() async {
    await audioPlayer.pause();
  }

  _stop() async {
    await audioPlayer.stop();
  }

  _listenerAudios() async {
    QuerySnapshot querySnapshot = await _db.collection("position").getDocuments();
    for (DocumentSnapshot item in querySnapshot.documents) {
      var data = item.data;

      if (data["latLng"]["latitude"] == widget.position.latitude.toStringAsFixed(4) &&
          data["latLng"]["longitude"] == widget.position.longitude.toStringAsFixed(4)) {
        final stream = _db.collection("position").document(item.documentID).collection("guides").orderBy("approved", descending: true).snapshots();
        stream.listen((data) {
          _controller.add(data);
        });
        setState(() {
          _localUser = data["title"];
        });

      }
    }
  }

  @override
  void initState() {
    super.initState();
    _listenerAudios();
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_localUser),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: GestureDetector(
              child: Icon(Icons.add),
              onTap: () {
                CameraPosition cameraPosition = CameraPosition(target: LatLng(widget.position.latitude, widget.position.longitude), zoom: 16);
                Navigator.pushNamed(context, Routes.ROUT_UPLOADGUIDE, arguments: cameraPosition);
              },
            ),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: _controller.stream,
          builder: (context, snapshot){
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Container();
              case ConnectionState.done:
              case ConnectionState.active:
                QuerySnapshot querySnapshot = snapshot.data;
                List<DocumentSnapshot> audios = querySnapshot.documents.toList();
                return Column(
                  children: <Widget>[
                    Expanded(
                      child: ListView.builder(
                        itemCount: audios.length,
                        itemBuilder: (context, index){
                          DocumentSnapshot audio = audios[index];
                          if(audio["approved"]){
                            return Card(
                              child: ListTile(
                                title: Text(audio["name"]),
                                subtitle: Text(audio["notes"]),
                                onTap: (){
                                  setState(() {
                                    _firstExecution = true;
                                    _currentIndex = 1;
                                  });
                                  _play(audio["urlGuide"]);
                                },
                              ),
                            );
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                );
            }
            return null;
          }),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (indice) {
          setState(() {
            _currentIndex = indice;
          });
          print("indice : " + _currentIndex.toString());
          switch (indice) {
            case 0:
              _pause();
              break;

            case 1:
              _play("");
              break;

            case 2:
              _stop();
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        fixedColor: Colors.red,
        items: [
          BottomNavigationBarItem(title: Text("Pause"), icon: Icon(Icons.pause)),
          BottomNavigationBarItem(title: Text("Play"), icon: Icon(Icons.play_arrow)),
          BottomNavigationBarItem(title: Text("Stop"), icon: Icon(Icons.stop)),
        ],
      ),
    );
  }
}
