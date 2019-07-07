import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/main_bloc.dart';
import 'package:tags/Models/tags.dart';
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


  String setDistanceLabel(Tags tag){
    int dist = tag.distance.toInt();
    if(dist<=0) _onRange=true;
    int r = dist%10;
    dist = dist - r +10;
    return dist.toString();
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
                return TagsTile(listSnapshot.data[index], _distanceLabel, false);
              }
            );
      },
    );
  }
}