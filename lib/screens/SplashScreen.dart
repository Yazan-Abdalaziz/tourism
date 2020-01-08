import 'dart:async';
import 'package:tourism/Routes.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void didChangeDependencies() async{
    super.didChangeDependencies();
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser loggedUser = await auth.currentUser();
    Timer(Duration(seconds: 2), (){
      if(loggedUser != null) { //if user is logged in
        //String idUser = loggedUser.uid;
        Navigator.pushReplacementNamed(context, Routes.ROUT_HOME);
      } else { //if user is not logged in
        Navigator.pushReplacementNamed(context, Routes.ROUT_LOGIN);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("images/fundo.png"),
              fit: BoxFit.cover
          ),
        ),
        //color: Color(0xff50A059),
        padding: EdgeInsets.all(60),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                "images/touristGuides5.png",
                width: 150,
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  "Tourist Guides",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
