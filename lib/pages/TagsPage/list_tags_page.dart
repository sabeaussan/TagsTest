import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/main_bloc.dart';
import 'package:tags/Models/publicmark.dart';
import 'package:tags/UI/tags_tile.dart';



class ListTagsPage extends StatefulWidget {


  _ListTagsPageState createState() => _ListTagsPageState();
}

//Page contenant la list des Tags à proximité

class _ListTagsPageState extends State<ListTagsPage> {
  MainBloc _mainBloc;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _mainBloc = BlocProvider.of<MainBloc>(context);
  }
  
  @override
  Widget build(BuildContext context) {

    return FutureBuilder<List<PublicMark>>(
      future: _mainBloc.filterMarksForListMarkPage(),
      builder: (BuildContext context, AsyncSnapshot<List<PublicMark>> listSnapshot){
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
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  
                });
                return;
              },
              child: ListView.builder(
              itemCount: listSnapshot.data.length ,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index){
                return TagsTile(listSnapshot.data[index]);
              }
            ),
          );
      },
    );
  }
}