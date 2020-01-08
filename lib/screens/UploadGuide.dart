import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:tourism/util/ResearchesFirebase.dart';

class UploadGuide extends StatefulWidget {
  CameraPosition position;
  UploadGuide(this.position);
  @override
  _UploadGuideState createState() => _UploadGuideState();
}

class _UploadGuideState extends State<UploadGuide> {
  TextEditingController _controllerAudioName = TextEditingController();
  TextEditingController _controllerAudioNotes = TextEditingController();
  FileType _pickingType = FileType.AUDIO;
  bool _loadingAudio = false;
  String _localUser;
  File _audio;
  Widget _widget = Text("");

  Future<String> _checkPositionInDb() async {
    Firestore db = Firestore.instance;
    QuerySnapshot querySnapshot = await db.collection("position").getDocuments();
    for (DocumentSnapshot item in querySnapshot.documents) {
      var data = item.data;
      if (data["latLng"]["latitude"] ==
          widget.position.target.latitude.toStringAsFixed(4) &&
          data["latLng"]["longitude"] ==
              widget.position.target.longitude.toStringAsFixed(4)) {
        return item.documentID;
      }
    }
    return "";
  }

  _localToAddress() async {
    List<Placemark> listAddress = await Geolocator().placemarkFromCoordinates(
        widget.position.target.latitude,
        widget.position.target.longitude);
    String result;
    if (listAddress != null && listAddress.length > 0) {
      Placemark address = listAddress[0];
      result = address.thoroughfare;
      result += " " + address.subThoroughfare;
      setState(() {
        _localUser = result;
      });
    }
  }

  void _openFileExplorer() async {
    File audio;
    _setErrorOrSuccess("", 1);
    try {
      audio = await FilePicker.getFile(type: _pickingType);
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }
    if (!mounted) return;
    setState(() {
      _audio = audio;
      _controllerAudioName.text =
      audio.path != null ? audio.path.split("/").last : "...";
    });
  }

  _sendAudio() {
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference rootFolder = storage.ref();
    StorageReference file = rootFolder.child(_controllerAudioName.text);
    StorageUploadTask task = file.putFile(_audio);
    task.events.listen((StorageTaskEvent storageEvent) {
      if (storageEvent.type == StorageTaskEventType.progress) {
        setState(() {
          _loadingAudio = true;
        });
      } else if (storageEvent.type == StorageTaskEventType.failure) {
        setState(() {
          _loadingAudio = false;
        });
        _setErrorOrSuccess("Error saving file", 1);
      }
    });
    task.onComplete.then((StorageTaskSnapshot snapshot) {
      _saveGuide(snapshot);
    });
  }

  _setErrorOrSuccess(String text, int error) {
    if (error == 1) {
      setState(() {
        _widget = Text(text,
            style: TextStyle(
                color: Colors.red, fontSize: 15,
                fontWeight: FontWeight.bold
            )
        );
      });
    } else {
      setState(() {
        _widget = Text(text,
            style: TextStyle(
                color: Colors.green,
                fontSize: 15,
                fontWeight: FontWeight.bold
            )
        );
      });
    }
  }

  Future _saveGuide(StorageTaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();
    Firestore db = Firestore.instance;
    ResearchesFirebase.getDataFromUser().then((user){
      Map<String, dynamic> map = {
        "latitude": widget.position.target.latitude.toStringAsFixed(4),
        "longitude": widget.position.target.longitude.toStringAsFixed(4),
      };
      Map<String, dynamic> mapPosition = {
        "latLng": map,
        "idMarker": _localUser.replaceAll(new RegExp(r"\s+\b|\b\s"), ""),
        "title": _localUser
      };
      Map<String, dynamic> mapGuide = {
        "approved": false,
        "urlGuide": url,
        "name": _controllerAudioName.text,
        "notes": _controllerAudioNotes.text,
        "responsible": user.name
      };
      Future<String> documentID = _checkPositionInDb();
      documentID.then((documentID) {
        if (documentID == "") {
          Future<DocumentReference> ref =
          db.collection("position").add(mapPosition);
          ref.then((document) {
            Future<DocumentReference> refGuide = db
                .collection("position")
                .document(document.documentID)
                .collection("guides")
                .add(mapGuide);
            refGuide.then((document){
              Map<String, dynamic> mapApproval = {
                "approved": false,
                "urlGuide": url,
                "name": _controllerAudioName.text,
                "notes": _controllerAudioNotes.text,
                "responsible": user.name,
                "latLng": map,
                "idMarker": _localUser.replaceAll(new RegExp(r"\s+\b|\b\s"), ""),
                "title": _localUser,
                "positionID": ref
              };
              db.collection("pendingApprovals").document(document.documentID).setData(mapApproval).then((value){
                setState(() {
                  _controllerAudioName.text = "";
                  _controllerAudioNotes.text = "";
                  _loadingAudio = false;
                });
                _setErrorOrSuccess("File submitted for approval", 2);
              });
            });
          });
        } else {
          Future<DocumentReference> refGuide = db
              .collection("position")
              .document(documentID)
              .collection("guides")
              .add(mapGuide);
          refGuide.then((document){
            Map<String, dynamic> mapApproval = {
              "urlGuide": url,
              "name": _controllerAudioName.text,
              "notes": _controllerAudioNotes.text,
              "responsible": user.name,
              "latLng": map,
              "title": _localUser,
              "positionID": documentID
            };
            db.collection("pendingApprovals").document(document.documentID).setData(mapApproval).then((value){
              setState(() {
                _controllerAudioName.text = "";
                _controllerAudioNotes.text = "";
                _loadingAudio = false;
              });
              _setErrorOrSuccess("File submitted for approval", 2);
            });
          });
        }
      });

    });
  }

  _validateFields() {
    String name = _controllerAudioName.text;
    String notes = _controllerAudioNotes.text;
    if (_audio != null) {
      if (name.isNotEmpty) {
        if (notes.isNotEmpty) {
          _sendAudio();
        } else {
          _setErrorOrSuccess("Fill in the notes", 1);
        }
      } else {
        _setErrorOrSuccess("Fill in the audio name", 1);
      }
    } else {
      _setErrorOrSuccess("Select a file", 1);
    }
  }

  @override
  void initState() {
    super.initState();
    _localToAddress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Guide"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(25),
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: Container(
                width: 45,
                height: 45,
                child: RawMaterialButton(
                  fillColor: Colors.black,
                  shape: CircleBorder(),
                  child: Icon(
                    Icons.music_note,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    _openFileExplorer();
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: TextField(
                controller: _controllerAudioName,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: "Audio Name",
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: TextField(
                controller: _controllerAudioNotes,
                decoration: InputDecoration(
                  hintText: "Notes",
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: RaisedButton(
                color: Colors.black,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Send Audio  ", style: TextStyle(color: Colors.white)),
                    Icon(
                      Icons.file_upload,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
                onPressed: () {
                  _validateFields();
                },
              ),
            ),
            _loadingAudio
                ? Padding(
                padding: EdgeInsets.only(top: 8, bottom: 8),
                child: Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.black,
                    )))
                : Container(),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: Center(child: _widget),
            ),
          ],
        ),
      ),
    );
  }
}
