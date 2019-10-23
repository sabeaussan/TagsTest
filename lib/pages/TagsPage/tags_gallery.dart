import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_tags_page.dart';
import 'package:tags/Event/events.dart';
import 'package:tags/UI/post_tile.dart';

class TagsGallery extends StatefulWidget {
  
  //TODO:faire un streamSubscription pour pouvoir le cancel dans dispose
  //TODO: trigger la query à chaque fois qu'on retourne sur la page, faire 
  //la query dans le initState si la consommation de read augmente trop


  final BlocTagsPage _blocTagPage;

  TagsGallery(this._blocTagPage,{Key key}):super(key:key);

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

  List<Widget> _buildListPost(List<PostTile> list, bool isLoading){
    List<Widget> _widgetList =list.map((PostTile postTile){
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
      initialData: widget._blocTagPage.markPostsList,
      stream: widget._blocTagPage.listMarkPostControllerStream,
      builder: (BuildContext context, AsyncSnapshot<List<PostTile>> listSnapshot){
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