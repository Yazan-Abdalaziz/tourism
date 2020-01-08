import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tourism/medel/User.dart';

class ResearchesFirebase {
  static Future<FirebaseUser> getCurrentUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    return auth.currentUser();
  }

  static Future<User> getDataFromUser() async {
    FirebaseUser userFirebase = await getCurrentUser();
    String idUser = userFirebase.
    uid;
    Firestore db = Firestore.instance;
    DocumentSnapshot snapshot = await db.collection("users").document(idUser).get();
    Map<String,dynamic> data = snapshot.data;
    String email = data["email"];
    String name = data["name"];
    bool adm = data["adm"];
    User user  = User();
    user.email = email;
    user.name = name;
    user.idUser = idUser;
    user.adm = adm;
    return user;
  }

  static Future<bool> positionExist(LatLng latLng) async{
    bool exist = false;
    Firestore db = Firestore.instance;
    QuerySnapshot querySnapshot = await db.collection("position").getDocuments();
    for (DocumentSnapshot item in querySnapshot.documents) {
      var data = item.data;
      if (data["latLng"]["latitude"] == latLng.latitude.toStringAsFixed(4) &&
          data["latLng"]["longitude"] == latLng.longitude.toStringAsFixed(4)) {
        exist = true;
      }
    }
    return exist;
  }

  static Future<bool> adressExist(String search) async{
    bool exist = false;
    Firestore db = Firestore.instance;
    QuerySnapshot querySnapshot = await db.collection("position").getDocuments();
    for (DocumentSnapshot item in querySnapshot.documents) {
      var data = item.data;
      if (data["title"] == search) {
        exist = true;
      }
    }
    return exist;
  }
}