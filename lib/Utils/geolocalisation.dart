import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'dart:async';

class Geolocalisation {

  static final Location location = new Location();
  

  static Future<LocationData> getUserPosition() async {
    final LocationData pos = await location.getLocation();
    return pos;
  }

  static Future<GeoFirePoint> getUserGeoFirePoint() async {
    final LocationData pos = await location.getLocation();
    return GeoFirePoint(pos.latitude, pos.longitude);
  }

}