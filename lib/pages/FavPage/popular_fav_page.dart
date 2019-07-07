import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/main_bloc.dart';
import 'package:tags/Models/tags.dart';
import 'package:tags/UI/tags_tile.dart';

class PopularFavPage extends StatefulWidget {

  _PopularFavPageState createState() => _PopularFavPageState();
}

class _PopularFavPageState extends State<PopularFavPage> {
  MainBloc _mainBloc;
  String _distanceLabel;
    //ajouter un model post

  String setDistanceLabel(Tags tag){
    int dist = tag.distance.toInt();
    int r = dist%10;
    dist = dist - r +10;
    return dist.toString();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _mainBloc = BlocProvider.of<MainBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: _mainBloc.mostPopularTags,
      stream: _mainBloc.listPopularTagsControllerStream,
      builder: (BuildContext context, AsyncSnapshot<List<Tags>> snapshot){
        if(!snapshot.hasData){
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.data.length==0) {
            return Center(
              child: Text("Rien a afficher"),
            );
          }
          return ListView.builder(
              itemCount: snapshot.data.length ,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index){
                _distanceLabel=setDistanceLabel(snapshot.data[index]);
                return TagsTile(snapshot.data[index], _distanceLabel,true);
              }
          ); 
      }
    );
  }
}