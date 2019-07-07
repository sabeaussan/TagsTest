import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
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
  String _focusedMarkerId="";


  @override
  void initState() {
    // TODO: en faire une fonction et la mettre dans une classe de Utils
    super.initState();
    _mainBloc = BlocProvider.of<MainBloc>(context);
  }
  
  void _setMarkerCircleOpacity(String docId){
    setState(() {
      _focusedMarkerId=docId;
    });
  }

  Future<void> _buildModalBottomSheet(DocumentSnapshot doc){
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context){
        return Column(
          children: <Widget>[
            Container(
                width: MediaQuery.of(context).size.width-10,
                height: MediaQuery.of(context).size.height*0.3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                    fit: doc.data["lastPostImageWidth"]/doc.data["lastPostImageHeight"]>=1.0 ? BoxFit.fitHeight:BoxFit.fitWidth,
                    image: CachedNetworkImageProvider(doc.data["lastPostImageUrl"])
                  )
                ),
              ),
          ],
        );
      }
    );
  }

  Set<Marker> _buildMarkers(List<DocumentSnapshot> listTags,BuildContext context){
    //TODO: opacité du marker doit être proportioonel a sa popularité
    Set<Marker> listMarker=Set<Marker>();
    listTags.forEach((DocumentSnapshot doc) {
      Marker marker = Marker(
        onTap: ()async {
          _setMarkerCircleOpacity(doc.documentID);
          await _buildModalBottomSheet(doc);
        },
        markerId: MarkerId(doc.documentID),
        alpha: 1.0,
        //anchor: Offset(0, 1),
        position: LatLng(doc.data["position"]["geopoint"].latitude,doc.data["position"]["geopoint"].longitude));
      listMarker.add(marker);
    });
    return listMarker;
  }

  Set<Circle> _buildCircles(List<DocumentSnapshot> listMarks){
    Set<Circle> listCircles=Set<Circle>();
    listMarks.forEach((DocumentSnapshot doc){
      Circle circle = Circle(
        visible: doc.documentID==_focusedMarkerId?true:false,
        circleId: CircleId(doc.documentID),
        radius: doc.data["tagRange"],
        strokeColor: Colors.red.withOpacity(0.8),
        strokeWidth: 5,
        fillColor: Colors.red[200].withOpacity(0.5),
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
    //TODO: peut être en faire un FutureBuilder pour éviter 
    //de reconstruire la map à chaque fois que quelqu'un ajoute une mark
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
                    return Center(child: CircularProgressIndicator());
                  }
                  return Center(
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    width: double.infinity,
                    child: GoogleMap(
                      markers: _buildMarkers(listDocSnapshot.data,context),
                      myLocationButtonEnabled: true,
                      rotateGesturesEnabled: false,
                      circles:_buildCircles(listDocSnapshot.data),
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