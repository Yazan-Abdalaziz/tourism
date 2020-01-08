import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Guide {
  String _url;
  String _name;
  String _idAudio;
  String _notes;
  String _responsible;
  bool _approved;

  Guide();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> mapGuide = {
      "url": this.url,
      "name": this.name,
      "idAudio": this._idAudio,
      "notes": this.notes,
      "responsible": this.responsible,
      "approved": this.approved
    };
    return mapGuide;
  }

  bool get approved => _approved;

  set approved(bool value) {
    _approved = value;
  }

  String get responsible => _responsible;

  set responsible(String value) {
    _responsible = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  String get url => _url;

  set url(String value) {
    _url = value;
  }

  String get idAudio => _idAudio;

  set idAudio(String value) {
    _idAudio = value;
  }

  String get notes => _notes;

  set notes(String value) {
    _notes = value;
  }


}

class Place {
  String _idMarker;
  String _titleMarker;
  String _idGuide;
  LatLng _latLng;
  List<Guide> _listGuides;

  Place();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> mapLatLng = {
      "latitude": this.latLng.latitude,
      "longitude": this.latLng.longitude
    };
    Map<String, dynamic> mapPosition = {
      "idMarker": this.idMarker,
      "titleMarker": this.titleMarker,
      "position": mapLatLng,
      "idGuide": this.idGuide
    };
    return mapPosition;
  }


  List<Guide> get listGuides => _listGuides;

  set listGuides(List<Guide> value) {
    _listGuides = value;
  }

  String get idGuide => _idGuide;

  set idGuide(String value) {
    _idGuide = value;
  }

  LatLng get latLng => _latLng;

  set latLng(LatLng value) {
    _latLng = value;
  }

  String get titleMarker => _titleMarker;

  set titleMarker(String value) {
    _titleMarker = value;
  }

  String get idMarker => _idMarker;

  set idMarker(String value) {
    _idMarker = value;
  }


}