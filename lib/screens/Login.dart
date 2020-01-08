import 'package:flutter/material.dart';
import 'package:tourism/medel/User.dart';
import 'package:tourism/Routes.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _controllerEmail =
  TextEditingController(text: "heloisa@gmail.com");
  TextEditingController _controllerPassword =
  TextEditingController(text: "123456");
  String _errorMessage = "";
  bool _loading = false;

  _loginUser(User user) {
    setState(() {
      _loading = true;
    });
    FirebaseAuth auth = FirebaseAuth.instance;
    auth
        .signInWithEmailAndPassword(email: user.email, password: user.password)
        .then((firebaseUser) {
      setState(() {
        _loading = false;
      });
      Navigator.pushReplacementNamed(context, Routes.ROUT_HOME);
    }).catchError((error) {
      _errorMessage = "Error authenticating user, check e-mail and password";
    });
  }

  _validateFields() {
    //retrieve filled data
    String email = _controllerEmail.text;
    String password = _controllerPassword.text;
    if (email.isNotEmpty && email.contains("@")) {
      if (password.isNotEmpty && password.length >= 6) {
        User user = User();
        user.email = email;
        user.password = password;
        _loginUser(user);
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        //se quiser colocar uma imagem de fundo
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("images/fundo.png"), fit: BoxFit.cover),
        ),
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 32),
                  child: Image.asset(
                    "images/touristGuides5.png",
                    width: 150,
                    height: 150,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: TextField(
                    controller: _controllerEmail,
                    autofocus: true,
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
                        borderRadius: BorderRadius.circular(6)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: RaisedButton(
                    onPressed: () {
                      _validateFields();
                    },
                    child: Text(
                      "Sign in",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    color: Colors.black,
                    padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                  ),
                ),
                Center(
                  child: GestureDetector(
                    child: Text(
                      "New to Tourist Guide? Register now!",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, Routes.ROUT_REGISTER);
                    },
                  ),
                ),
                _loading
                    ? Padding(
                    padding: EdgeInsets.only(top: 8, bottom: 8),
                    child: Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.black,
                        )))
                    : Container(),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Center(
                    child: Text(
                      _errorMessage,
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
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
