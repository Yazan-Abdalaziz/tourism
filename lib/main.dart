import 'package:flutter/material.dart';
import 'package:tourism/screens/SplashScreen.dart';
import 'Routes.dart';

final ThemeData defaultTheme = ThemeData(
    primaryColor: Colors.black,
    accentColor: Colors.white
);

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Tourist Guiges",
      home: SplashScreen(),
      theme: defaultTheme,
      initialRoute: Routes.ROUT_INICIAL,
      onGenerateRoute: Routes.genarateRoute,
    );
  }
}
