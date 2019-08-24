import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/main_bloc.dart';
import 'package:tags/Event/events.dart';
import 'package:tags/Models/tags.dart';
import 'package:tags/UI/tags_tile.dart';


//TODO: peut etre passé en stateless


class PersoFavPage extends StatefulWidget {
  _PersoFavPageState createState() => _PersoFavPageState();
}

class _PersoFavPageState extends State<PersoFavPage> {

  MainBloc _mainBloc;
  Future<List<Tags>> futureUserFavMark;
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

  List<Widget> _buildListPost(List<Tags> list, bool isLoading){
    List<Widget> _widgetList =list.map((Tags tag){
      final TagsTile tile = TagsTile(tag,"",true);
      return Padding(
        padding: EdgeInsets.all(0.0),
        child: tile,
      );
    }).toList();
    //_widgetList.add(_buildLoadingIndicator(isLoading));
    return _widgetList;
  }

  String setDistanceLabel(Tags tag){
    int dist = tag.distance.toInt();
    int r = dist%10;
    dist = dist - r +10;
    return dist.toString();
  }
  @override
  void initState() {
    super.initState();
    _mainBloc = BlocProvider.of<MainBloc>(context);
    _mainBloc.newFavContent=false;
    _mainBloc.sendNewEvent();
    //_scrollController = ScrollController();
    //_mainBloc.setFavTagsEdgeReached(false);
    //_scrollController.addListener(_fetchMoreFavTags);
    //_mainBloc.fetchMoreFavTagControllerSink.add(FetchMoreFavTagsEvent(_fetchIndex));
    //_fetchIndex=_fetchIndex+2;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _mainBloc.getUserFavMarks(),
      initialData: _mainBloc.listFavTags,
      builder: (BuildContext context, AsyncSnapshot<List<Tags>> listSnapshot){
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
          children: _buildListPost(listSnapshot.data,null),
        );
          /*return StreamBuilder(
            stream: _mainBloc.loadingFavTagsControllerStream,
            initialData: false,
            builder: (BuildContext context, AsyncSnapshot snapshot){
              return ListView(
                controller: _scrollController,
                children: _buildListPost(listSnapshot.data,snapshot.data),
            
              );
            },
          );*/
        
      }
      
    );
  }
}