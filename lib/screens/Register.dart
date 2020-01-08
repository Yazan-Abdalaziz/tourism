import 'package:flutter/material.dart';
import 'package:tourism/medel/User.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Routes.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerName = TextEditingController();
  TextEditingController _controllerPassword = TextEditingController();
  String _errorMessage = "";

  _registerUser(User user) {
    FirebaseAuth auth = FirebaseAuth.instance;
    Firestore db = Firestore.instance;
    auth
        .createUserWithEmailAndPassword(
        email: user.email, password: user.password)
        .then((firebaseUser) {
      db
          .collection("users")
          .document(firebaseUser.user.uid)
          .setData(user.toMap());
      //redirect to home page
      Navigator.pushNamedAndRemoveUntil(context, Routes.ROUT_HOME, (_) => false);
    }).catchError((error){
      _errorMessage = "Error registering user, check fields and try again";
    });
  }

  _validateFields() {
    //retrieve filled data
    String name = _controllerName.text;
    String email = _controllerEmail.text;
    String password = _controllerPassword.text;
    if (name.isNotEmpty) {
      if (email.isNotEmpty && email.contains("@")) {
        if (password.isNotEmpty && password.length >= 6) {
          User user = User();
          user.name = name;
          user.email = email;
          user.password = password;
          user.adm = false;
          _registerUser(user);
        } else {
          setState(() {
            _errorMessage = "Password most be longer than 5 characters";
          });
        }
      } else {
        setState(() {
          _errorMessage = "Fill in a valid E-mail";
        });
      }
    } else {
      setState(() {
        _errorMessage = "Fill in Name field";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Registry"),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("images/fundo.png"),
              fit: BoxFit.cover
          ),
        ),
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: TextField(
                    controller: _controllerName,
                    autofocus: true,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "Name",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: TextField(
                    controller: _controllerEmail,
                    autofocus: false,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "E-mail",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                ),
                TextField(
                  controller: _controllerPassword,
                  obscureText: true,
                  autofocus: false,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    hintText: "Password",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6)
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: RaisedButton(
                    onPressed: () {
                      _validateFields();
                    },
                    child: Text(
                      "Register",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    color: Colors.black,
                    padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    shape: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6)
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Center(
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red, fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
