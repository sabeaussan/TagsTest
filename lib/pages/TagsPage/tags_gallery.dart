


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_tags_page.dart';
import 'package:tags/Event/events.dart';
import 'package:tags/Models/tags.dart';
import 'package:tags/UI/post_tile.dart';

class TagsGallery extends StatefulWidget {
  
  //TODO:faire un streamSubscription pour pouvoir le cancel dans dispose
  //TODO: trigger la query à chaque fois qu'on retourne sur la page, faire 
  //la query dans le initState si la consommation de read augmente trop

  final Tags _tags;
  final BlocTagsPage _blocTagPage;

  TagsGallery(this._tags,this._blocTagPage,{Key key}):super(key:key);

  @override
  TagsGalleryState createState() {
    return new TagsGalleryState();
  }
}

class TagsGalleryState extends State<TagsGallery> {
  //TODO: modifier edit post trop long et doit bloquer les autres options
  ScrollController _scrollController;
  double lastExtent=0.0;

  void _fetchMorePost() async {
    if(_scrollController.position.pixels==_scrollController.position.maxScrollExtent){
      if(lastExtent!=_scrollController.position.maxScrollExtent){
        print("--------------------FetchMorePostEvent triggered----------------");
        print("position : "+_scrollController.position.pixels.toString());
        print("maxExtent : "+_scrollController.position.pixels.toString());
        print("lastExtent : "+lastExtent.toString());
        lastExtent = _scrollController.position.maxScrollExtent;
        widget._blocTagPage.fetchMorePostControllerSink.add(FetchMorePostEvent());
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

  List<Widget> _buildListPost(List<DocumentSnapshot> list, bool isLoading){
    List<Widget> _widgetList =list.map((DocumentSnapshot documents){
      //print(documents.documentID);
      //print("height : " + documents.data["imageHeight"].toString());
      final PostTile postTile = PostTile.fromDocumentSnaptshot(documents,key: ValueKey(documents.documentID),);
      postTile.setType(GALLERY);
      return Padding(
        padding: EdgeInsets.all(0.0),
        child: postTile,
      );
    }).toList();
    _widgetList.add(_buildLoadingIndicator(isLoading));
    return _widgetList;
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("---------[initState TagsGallery]-----------");
    _scrollController = ScrollController();
    _scrollController.addListener(_fetchMorePost);
    
  }

  @override
  void dispose() {
    _scrollController.removeListener(_fetchMorePost);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: widget._blocTagPage.snapshotTagPostList,
      stream: widget._blocTagPage.listTagPostControllerStream,
      builder: (BuildContext context, AsyncSnapshot<List<DocumentSnapshot>> listSnapshot){
        if(!listSnapshot.hasData){
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (listSnapshot.data.length==0) {
            return Center(
              child: Text("ajoute un premier post !"),
            );
          }
        print("******[stb tagsGallery] trigered********* "+listSnapshot.data.length.toString());
          return StreamBuilder(
            stream: widget._blocTagPage.loadingPostControllerStream ,
            initialData: false ,
            builder: (BuildContext context, AsyncSnapshot snapshot){
              return ListView(
                controller: _scrollController,
                children: _buildListPost(listSnapshot.data,snapshot.data),
            
              );
            },
          );
        
      }
      
    );
  }
}