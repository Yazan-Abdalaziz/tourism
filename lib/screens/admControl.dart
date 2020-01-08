import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class admControl extends StatefulWidget {
  @override
  _admControlState createState() => _admControlState();
}

class _admControlState extends State<admControl> {
  final _controller = StreamController<QuerySnapshot>.broadcast();
  Firestore _db = Firestore.instance;
  bool _allUsers = false;

  _listenerAudios() async {
    final stream = _db.collection("users").orderBy("adm", descending: false).snapshots();
    stream.listen((data) {
      _controller.add(data);
    });
  }

  @override
  void initState() {
    super.initState();
    _listenerAudios();
  }

  _userAdm(String documentID, bool value) async {
    await _db
        .collection("users")
        .document(documentID)
        .updateData({"adm": value});
  }

  Widget _listUsers( DocumentSnapshot user, String documentID){
    return Card(
      child: ListTile(
        title: Text(user["name"]),
        subtitle: Text(user["email"]),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Switch(
              activeColor: Colors.black,
              activeTrackColor: Colors.grey,
              value: user["adm"],
              onChanged: (bool value){
                _userAdm(documentID, value);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                  List<DocumentSnapshot> users = querySnapshot.documents.toList();
                  return Column(
                    children: <Widget>[
                      Expanded(
                        child: ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot user = users[index];
                            String documentID = users[index].documentID;
                            //if(){
                            if(_allUsers){
                              return _listUsers(user, documentID);
                            } else {
                              if(!user["adm"]){
                                return _listUsers(user, documentID);
                              }
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
      ),
      bottomNavigationBar: Container(
        child: SwitchListTile(
          title: Text("Show all users (include adm)"),
          activeColor: Colors.black,
          activeTrackColor: Colors.grey,
          value: _allUsers,
          onChanged: (bool value){
            setState(() {
              _allUsers = value;
            });
          },
        ),
      ),
    );
  }
}
