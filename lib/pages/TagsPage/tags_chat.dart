import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/bloc_tags_page.dart';
import 'package:tags/Event/events.dart';
import 'package:tags/Models/tags.dart';
import 'package:tags/UI/message_tile.dart';

class TagsChat extends StatefulWidget {
  //Contient le chat associé à un tags
  //TODO: va peut être falloir le transformer en stful

  final Tags tag;
  final BlocTagsPage _blocTagPage;

  TagsChat(this.tag,this._blocTagPage,{Key key}):super(key:key);

  @override
  TagsChatState createState() {
    return new TagsChatState();
  }
}

class TagsChatState extends State<TagsChat>{

  ScrollController _scrollController;
  
  
  
  

  //TODO: faire un cache pour ne pas recharger les info déja afficher 

  void _fetchMoreMessage() async {
    if(_scrollController.position.pixels==_scrollController.position.maxScrollExtent){
        widget._blocTagPage.fetchMoreContentControllerSink.add(FetchMoreEvent());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("---------[initState tagsChat]-----------");
    _scrollController = ScrollController();
    _scrollController.addListener(_fetchMoreMessage);
  }
  
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: widget._blocTagPage.snapshotTagMessageList,
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
        print("******[stb tagsChat] trigered********* "+listSnapshot.data.length.toString());
        return StreamBuilder(
          stream: widget._blocTagPage.loadindControllerStream ,
          initialData: false ,
          builder: (BuildContext context, AsyncSnapshot snapshot){
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                snapshot.data?  CircularProgressIndicator() : Container(width: 0.0,height: 0.0,),
                Expanded(
                  child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.only(top: 70.0),
                  reverse: true,
                  itemCount: listSnapshot.data.length,
                  addAutomaticKeepAlives: true,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: <Widget>[
                        MessageTile.fromDocumentSnapshot(listSnapshot.data[index]),
                        Divider()
                      ],
                    );
                  }
                ),
                )
              ],
            );
          },
        );
      }
    );
  }

 
}
