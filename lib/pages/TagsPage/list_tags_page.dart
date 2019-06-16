import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/main_bloc.dart';
import 'package:tags/Models/tags.dart';
import 'package:tags/Models/user.dart';
import 'package:tags/UI/tags_tile.dart';



class ListTagsPage extends StatefulWidget {


  _ListTagsPageState createState() => _ListTagsPageState();
}

//Page contenant la list des Tags à proximité

class _ListTagsPageState extends State<ListTagsPage> {
  MainBloc _mainBloc;
  bool _onRange=false; 
  String _distanceLabel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    
    print("---------[initState listTags]-----------");
    _mainBloc = BlocProvider.of<MainBloc>(context);
  }


  


  double _getDistanceFromTagRange(Tags tag){
    double distance;
    LocationData userLocation = _mainBloc.userCurrentPosition;
    GeoFirePoint tagPosition = GeoFirePoint(tag.lat, tag.long);
    distance = tagPosition.distance(lat: userLocation.latitude,lng : userLocation.longitude)*1000- tag.tagRange;
    if(distance<=0) _onRange=true;
    else _onRange=false;
    return distance;
  }

  String setDistanceLabel(Tags tag){
    int dist = _getDistanceFromTagRange(tag).toInt();
    int r = dist%10;
    dist = dist - r +10;
    return dist.toString();
  }

  void debugSetDistanceLabel(){
    int dist = 598;
    int r = dist%10;
    dist = dist - r +10;
    print("-- ---- DISTANCE debugSetDistanceLabel -------- = "+dist.toString());
    dist = 5;
    r = dist%10;
    dist = dist - r +10;
    print("-- ---- DISTANCE debugSetDistanceLabel -------- = "+dist.toString());
    dist = 999;
    r = dist%10;
    dist = dist - r +10;
    print("-- ---- DISTANCE debugSetDistanceLabel -------- = "+dist.toString());
  }

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<List<Tags>>(
      stream: _mainBloc.listTagsControllerStream,
      initialData: _mainBloc.filteredSnapshotTagsList,
      builder: (BuildContext context, AsyncSnapshot<List<Tags>> listSnapshot){
        if(!listSnapshot.hasData){
          return Center(
            child: CircularProgressIndicator(),
            );
          }
          if(listSnapshot.data.length==0){    //Il n'y pas de tags à récupérer
          return Center(
            child: Text("Aucun tags à proximité"),
            );
          }
            return ListView.builder(
              itemCount: listSnapshot.data.length ,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index){
                _distanceLabel=setDistanceLabel(listSnapshot.data[index]);
                return TagsTile(listSnapshot.data[index], _distanceLabel, _onRange,listSnapshot.data[index].favStatus);
              }
            );
      },
    );
  }
}