import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'dart:async';



class MapPage extends StatefulWidget {


  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController gmController;
  //Geolocator geolocator = Geolocator();

  //var currentLocation = LocationData;

  Location location = new Location();
  LocationData pos;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    location.getLocation().then((LocationData loc){
      setState(() {
        pos=loc;
      });
    });
  }


  Future<void> checkPermBis() async {
    
  }


  

  @override
  Widget build(BuildContext context) {
    print(pos);
         print("******** POSITION NON NULL ********");
        return pos==null? 
        Center(child: CircularProgressIndicator(),) 
        : 
        Center(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(pos.latitude, pos.longitude),
              zoom: 14.0,
            ),
            onMapCreated: (GoogleMapController controller){
                setState(() {
                   gmController=controller;
                });
            },
          ),
         )
      );
  }
}