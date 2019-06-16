import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/main_bloc.dart';
import '../../Utils/geolocalisation.dart';


class MapPage extends StatefulWidget {

  MapPage({Key key}):super(key:key);

  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController gmController;
  MainBloc _mainBloc;


  @override
  void initState() {
    // TODO: en faire une fonction et la mettre dans une classe de Utils
    super.initState();
    _mainBloc = BlocProvider.of<MainBloc>(context);
  }
  
  Set<Marker> _buildMarkers(List<DocumentSnapshot> listTags){
    Set<Marker> listMarker=Set<Marker>();
    listTags.forEach((DocumentSnapshot doc){
      print("BUILDING MARKERS FOR MAPPAGE @@@@@@@@@@@@@@@@@@@ "+doc.data["name"].toString());
      Marker marker = Marker(
        markerId: MarkerId(doc.documentID),
        alpha: 1.0,
        //icon: BitmapDescriptor.(Icon().),
        position: LatLng(doc.data["position"]["geopoint"].latitude,doc.data["position"]["geopoint"].longitude));
      listMarker.add(marker);
    });
    return listMarker;
  }

  Set<Circle> _buildCircles(List<DocumentSnapshot> listTags){
    Set<Circle> listCircles=Set<Circle>();
    listTags.forEach((DocumentSnapshot doc){
      Circle circle = Circle(
        circleId: CircleId(doc.documentID),
        //fillColor: Colors.deepOrange,
        radius: doc.data["tagRange"],
        strokeColor: Colors.deepOrange,
        strokeWidth: 5,
        center: LatLng(doc["position"]["geopoint"].latitude,doc.data["position"]["geopoint"].longitude)
        );
      listCircles.add(circle);
    });
    return listCircles;
  }

  @override
  void dispose() {
    Geolocalisation.gmController=null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
        return StreamBuilder<List<DocumentSnapshot>>(
          stream: _mainBloc.listMarkerTagsControllerStream,
          initialData: _mainBloc.snapshotTagsList,
          builder: (BuildContext context, AsyncSnapshot<List<DocumentSnapshot>> listDocSnapshot){
            print("LIST DE SNAP DE MAPPAGE : "+listDocSnapshot.data.toString());
            return StreamBuilder<LocationData>(
              initialData: _mainBloc.userCurrentPosition,
              stream: _mainBloc.userPositionControllerStream,
              builder: (BuildContext context,AsyncSnapshot<LocationData> userPositionSnapshot){
                  if(userPositionSnapshot.data==null){
                    return Center(child: CircularProgressIndicator(),);
                  }
                  return Center(
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    width: double.infinity,
                    child: GoogleMap(
                      markers: _buildMarkers(listDocSnapshot.data),
                      myLocationButtonEnabled: true,
                      rotateGesturesEnabled: false,
                      circles: _buildCircles(listDocSnapshot.data),
                      compassEnabled: true,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(userPositionSnapshot.data.latitude, userPositionSnapshot.data.longitude),
                        zoom: 14.0,
                      ),
                      
                      onMapCreated: (GoogleMapController controller){
                          setState(() {
                            Geolocalisation.gmController=controller;
                          });
                      },
                    ),
                  )
                );
              },
            );
          },
        );
  }
}