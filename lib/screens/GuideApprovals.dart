import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class GuideApprovals extends StatefulWidget {
  @override
  _GuideApprovalsState createState() => _GuideApprovalsState();
}

class _GuideApprovalsState extends State<GuideApprovals> {
  final _controller = StreamController<QuerySnapshot>.broadcast();
  Firestore _db = Firestore.instance;
  AudioPlayer audioPlayer = AudioPlayer();
  bool _firstExecution = true;

  _play(String url) async {
    _stop();
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
    final stream = _db.collection("pendingApprovals").snapshots();
    stream.listen((data) {
      _controller.add(data);
    });
  }

  _disapprove(String documentID, DocumentSnapshot audio) async {
    await _db.collection("position").document(audio["positionID"]).collection("guides").document(documentID).delete();
    await _db.collection("pendingApprovals").document(documentID).delete();
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference rootFolder = storage.ref();
    rootFolder.child(audio["name"]).delete();
  }

  _approve(String documentID, DocumentSnapshot audio) async {
    await _db.collection("position").document(audio["positionID"]).collection("guides").document(documentID).updateData({"approved": true});
    await _db.collection("pendingApprovals").document(documentID).delete();
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
    return Container(
      child: StreamBuilder<QuerySnapshot>(
          stream: _controller.stream,
          builder: (context, snapshot) {
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
                        itemBuilder: (context, index) {
                          DocumentSnapshot audio = audios[index];
                          String documentID = audios[index].documentID;
                          return Card(
                            child: ListTile(
                              title: Text(audio["name"]),
                              subtitle: Text(audio["notes"] + "\n" + audio["title"]),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: (){
                                      setState(() {
                                        _firstExecution = true;
                                      });
                                      _play(audio["urlGuide"]);
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 8),
                                      child: Icon(
                                        Icons.play_arrow,
                                        color: Colors.black,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: (){_pause();},
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 8),
                                      child: Icon(
                                        Icons.pause,
                                        color: Colors.black,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: (){_stop();},
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 8),
                                      child: Icon(
                                        Icons.stop,
                                        color: Colors.black,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context){
                                      return AlertDialog(
                                        title: Text(audio["name"]),
                                        content: Container(
                                          width: MediaQuery.of(context).size.width*0.8,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text("Address: ", style: TextStyle(fontWeight: FontWeight.bold),),
                                              Text(audio["title"]),
                                              Text("\nNotes: ", style: TextStyle(fontWeight: FontWeight.bold),),
                                              Text(audio["notes"]),
                                              Text("\nResponsible: ", style: TextStyle(fontWeight: FontWeight.bold),),
                                              Text(audio["responsible"]),
                                            ],
                                          ),
                                        ),
                                        /*
                                          Text("Address: " + audio["title"] + "\nNotes: " + audio["notes"])
                                          */
                                        actions: <Widget>[
                                          FlatButton(
                                              child: Text("Approve", style: TextStyle(color: Colors.black),),
                                              onPressed: (){
                                                _approve(documentID, audio);
                                                Navigator.of(context).pop();
                                              }
                                          ),
                                          FlatButton(
                                              child: Text("Disapprove", style: TextStyle(color: Colors.black),),
                                              onPressed: (){
                                                _disapprove(documentID, audio);
                                                Navigator.of(context).pop();
                                              }
                                          ),
                                          FlatButton(
                                              child: Text("Cancel", style: TextStyle(color: Colors.black),),
                                              onPressed: (){Navigator.of(context).pop();}
                                          ),
                                        ],
                                      );
                                    }
                                );
                              },
                            ),
                          );
                          //return null;
                        },
                      ),
                    ),
                  ],
                );
            }
            return null;
          }),
    );
  }
}
