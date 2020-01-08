import 'package:flutter/material.dart';
import 'package:tourism/screens/Administrator.dart';
import 'package:tourism/screens/Home.dart';
import 'package:tourism/screens/ListGuides.dart';
import 'package:tourism/screens/Login.dart';
import 'package:tourism/screens/Register.dart';
import 'package:tourism/screens/SplashScreen.dart';
import 'package:tourism/screens/UploadGuide.dart';

class Routes {
  static const String ROUT_INICIAL = "/";
  static const String ROUT_LOGIN = "/login";
  static const String ROUT_REGISTER = "/register";
  static const String ROUT_HOME = "/home";
  static const String ROUT_LISTGUIDES = "/listguides";
  static const String ROUT_UPLOADGUIDE = "/uploadguide";
  static const String ROUT_ADMINISTRATOR = "/administrator";

  static Route<dynamic> genarateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case ROUT_INICIAL:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case ROUT_REGISTER:
        return MaterialPageRoute(builder: (_) => Register());
      case ROUT_LOGIN:
        return MaterialPageRoute(builder: (_) => Login());
      case ROUT_HOME:
        return MaterialPageRoute(builder: (_) => Home());
      case ROUT_LISTGUIDES:
        return MaterialPageRoute(builder: (_) => ListGuides(args));
      case ROUT_UPLOADGUIDE:
        return MaterialPageRoute(builder: (_) => UploadGuide(args));
      case ROUT_ADMINISTRATOR:
        return MaterialPageRoute(builder: (_) => Administrator());
      default:
        _erroRota();
    }
  }

  static Route<dynamic> _erroRota() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Screen not found!"),
        ),
        body: Center(
          child: Text("Screen not found!"),
        ),
      );
    });
  }
}