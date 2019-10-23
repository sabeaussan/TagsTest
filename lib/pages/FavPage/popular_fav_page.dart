import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/main_bloc.dart';
import 'package:tags/Models/publicmark.dart';
import 'package:tags/UI/tags_tile.dart';

class PopularFavPage extends StatefulWidget {

  _PopularFavPageState createState() => _PopularFavPageState();
}

class _PopularFavPageState extends State<PopularFavPage> {
  MainBloc _mainBloc;




  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _mainBloc = BlocProvider.of<MainBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _mainBloc.filterMarksForPopularPage(),
      builder: (BuildContext context, AsyncSnapshot<List<PublicMark>> snapshot){
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
          return RefreshIndicator(
            onRefresh: ()async{
              setState(() {
                
              });
              return;
            },
            child: ListView.builder(
            itemCount: snapshot.data.length ,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index){
              return TagsTile(snapshot.data[index]);
            }
          ),
        ); 
      }
    );
  }
}