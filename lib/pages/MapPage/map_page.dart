import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class MapPage extends StatefulWidget {


  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController gmController;


  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(40.4167754, -3.7037902),
              zoom: 18.0,
            ),
            onMapCreated: (GoogleMapController controller){
                setState(() {
                   gmController=controller;
                });
            },
          ),
         ) //Text("map page")
      );
  }
}