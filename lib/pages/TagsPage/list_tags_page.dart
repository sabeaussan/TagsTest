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


  bool getFavStatus(User user,String tagsId){
     if(user.favTagsId!=null) return user.favTagsId.contains(tagsId);
     return false;
  } 


  double _getDistanceFromTagRange(Tags tag){
    double distance;
    LocationData userLocation = _mainBloc.userCurrentPosition;
    GeoFirePoint tagPosition = GeoFirePoint(tag.lat, tag.long);
    distance = tagPosition.distance(lat: userLocation.latitude,lng : userLocation.longitude)*1000- tag.tagRange;
    if(distance<=0) _onRange=true;
    else _onRange=false;
    print("-------------  DEBUG GETDISTANCEFROMTAGRANGE : "+tag.name+" ----------- "+distance.toString()+_onRange.toString());
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
    final User currentUser =_mainBloc.currentUser;
    print(currentUser.id);
    return StreamBuilder<List<DocumentSnapshot>>(
      stream: _mainBloc.listTagsControllerStream,
      initialData: _mainBloc.snapshotTagsList,
      builder: (BuildContext context, AsyncSnapshot<List<DocumentSnapshot>> listSnapshot){
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
        print("****** [stb listTags] trigered ********* "+listSnapshot.data.length.toString());
            return ListView.builder(
              itemCount: listSnapshot.data.length ,
              itemBuilder: (BuildContext context, int index){
                final Tags tags = Tags.fromDocumentSnapshot(listSnapshot.data[index]);
                final bool isFav = getFavStatus(currentUser,tags.id);
                _distanceLabel=setDistanceLabel(tags);
                print("-- ---- DISTANCE ENTRE USER ET TAG "+tags.name+" -------- = "+_distanceLabel);
                //debugSetDistanceLabel();
                return TagsTile(tags, _distanceLabel, _onRange,isFav);
              }
            );
      },
    );
  }
}