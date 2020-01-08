import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddressAndPosition {

  static Future<String> positionToAddress(LatLng latLng) async {
    List<Placemark> listAddress = await Geolocator().placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    String result;
    if (listAddress != null && listAddress.length > 0) {
      Placemark address = listAddress[0];
      result = address.thoroughfare;
      result += " " + address.subThoroughfare;
      result += ", " + address.postalCode;
      if (address.locality.isNotEmpty) {
        result += ", " + address.locality;
      } else {
        result += ", " + address.subAdministrativeArea;
      }
      result += ", " + address.administrativeArea;
      result += ", " + address.country;
      return result;
    }
    return null;
  }

  static Future<LatLng> addressToPosition(String address) async {
    List<Placemark> listAddress = await Geolocator().placemarkFromAddress(address);
    if (listAddress != null && listAddress.length > 0) {
      Placemark address = listAddress[0];
      return LatLng(address.position.latitude, address.position.longitude);
    }
    return null;
  }

  static Future<String> titleMarker(LatLng latLng) async {
    List<Placemark> listAddress = await Geolocator().placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    String result;
    if (listAddress != null && listAddress.length > 0) {
      Placemark address = listAddress[0];
      result = address.thoroughfare;
      result += " " + address.subThoroughfare;
      return result;
    }
    return null;
  }

}