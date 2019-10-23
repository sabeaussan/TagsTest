import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/main_bloc.dart';
import 'package:tags/Event/events.dart';
import 'package:tags/Models/publicmark.dart';
import 'package:tags/UI/tags_tile.dart';


//TODO: peut etre passé en stateless


class PersoFavPage extends StatefulWidget {
  _PersoFavPageState createState() => _PersoFavPageState();
}

class _PersoFavPageState extends State<PersoFavPage> {

  MainBloc _mainBloc;
  Future<List<PublicMark>> futureUserFavMark;
  /*ScrollController _scrollController;
  double lastExtent=0.0;
  int _fetchIndex=0;*/

  /*void _fetchMoreFavTags() async {
    if(_scrollController.position.pixels==_scrollController.position.maxScrollExtent){
      if(lastExtent!=_scrollController.position.maxScrollExtent){
        print("--------------------FetchMoreFavTagsEvent triggered----------------");
        print("position : "+_scrollController.position.pixels.toString());
        print("maxExtent : "+_scrollController.position.pixels.toString());
        print("lastExtent : "+lastExtent.toString());
        lastExtent = _scrollController.position.maxScrollExtent;
        _mainBloc.fetchMoreFavTagControllerSink.add(FetchMoreFavTagsEvent(_fetchIndex));
        _fetchIndex=_fetchIndex+2;
      } 
    }
  }
  

  Widget _buildLoadingIndicator(bool isLoading){
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Center(
        child: Opacity(
          opacity: isLoading ? 1.0 : 0.0,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
  */

  List<Widget> _buildListPost(List<PublicMark> list){
    // Mettre l'icone de newContent à la place du near, fav ou distanceLabel
    List<Widget> _widgetList =list.map((PublicMark mark){
      final TagsTile markTile = TagsTile(mark);
      return markTile;
    }).toList();
    return _widgetList;
  }

  @override
  void initState() {
    super.initState();
    _mainBloc = BlocProvider.of<MainBloc>(context);
  }

  @override
  void dispose() {
    print("########## Disposing FavPage #########");
    _mainBloc.newFavContentNotificationSeenControllerSink.add(NewFavContentSeen());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          
        });
        return;
      },
      child: FutureBuilder(
      future: _mainBloc.getUserFavMarks(),
      initialData: _mainBloc.listFavMarks,
      builder: (BuildContext context, AsyncSnapshot<List<PublicMark>> listSnapshot){
        if(!listSnapshot.hasData){
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (listSnapshot.data.length==0) {
          return Center(
            child: Text("Vous n'avez pas enregistrer de favoris"),
          );
        }
        return ListView(
          children: _buildListPost(listSnapshot.data),
          );
        }
      ),
    );
  }
}