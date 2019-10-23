import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_tags_page.dart';
import 'package:tags/Event/events.dart';
import 'package:tags/Models/publicmark.dart';
import 'package:tags/UI/message_tile.dart';

class TagsChat extends StatefulWidget {
  //Contient le chat associé à un tags
  //TODO: va peut être falloir le transformer en stful

  final PublicMark tag;
  final BlocTagsPage _blocTagPage;

  TagsChat(this.tag,this._blocTagPage,{Key key}):super(key:key);

  @override
  TagsChatState createState() {
    return new TagsChatState();
  }
}

class TagsChatState extends State<TagsChat>{

  ScrollController _scrollController;
  double lastExtent=0.0;
  
  
  

  //TODO: faire un cache pour ne pas recharger les info déja afficher 

  void _fetchMoreMessage() async {
    if(_scrollController.position.pixels==_scrollController.position.maxScrollExtent){
      if(lastExtent!=_scrollController.position.maxScrollExtent){
        lastExtent = _scrollController.position.maxScrollExtent;
        widget._blocTagPage.fetchMoreMessageControllerSink.add(FetchMoreTagMessageEvent());
      }
        
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // print("---------[initState tagsChat]-----------");
    _scrollController = ScrollController();
    _scrollController.addListener(_fetchMoreMessage);
    
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController.removeListener(_fetchMoreMessage);
    _scrollController.dispose();
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
  
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: widget._blocTagPage.markMessagesList,
      stream: widget._blocTagPage.listTagMessageControllerStream ,
      builder: (BuildContext context, AsyncSnapshot<List<DocumentSnapshot>> listSnapshot){
        if(!listSnapshot.hasData){
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (listSnapshot.data.length==0) {
            return Center(
              child: Text("ajoute un premier message !"),
            );
          }
        // print("******[stb tagsChat] trigered********* "+listSnapshot.data.length.toString());
        return StreamBuilder(
          stream: widget._blocTagPage.loadingMessageControllerStream ,
          initialData: false ,
          builder: (BuildContext context, AsyncSnapshot snapshot){
            return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: listSnapshot.data.length+1,
                  addAutomaticKeepAlives: true,
                  itemBuilder: (BuildContext context, int index) {
                    if(index==listSnapshot.data.length) return  _buildLoadingIndicator(snapshot.data);
                    return Column(
                      children: <Widget>[
                        MessageTile.fromDocumentSnapshot(listSnapshot.data[index]),
                        Divider()
                      ],
                    );
                  }
                );
          },
        );
      }
    );
  }

 
}