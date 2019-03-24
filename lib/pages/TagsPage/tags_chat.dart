import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tags/Models/tags.dart';
import 'package:tags/UI/message_tile.dart';

class TagsChat extends StatefulWidget {
  //Contient le chat associé à un tags
  //TODO: va peut être falloir le transformer en stful

  final Tags tag;

  TagsChat(this.tag,{Key key}):super(key:key);

  @override
  TagsChatState createState() {
    return new TagsChatState();
  }
}

class TagsChatState extends State<TagsChat> {



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("---------[initState tagsChat]-----------");
  }
  
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance.collection("Tags").document(widget.tag.id).collection("TagsMessage").orderBy("id",descending:true).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
        if(!snapshot.hasData){
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.data.documents.length==0) {
            return Center(
              child: Text("ajoute un premier message !"),
            );
          }
        print("******[stb tagsChat] trigered********* "+snapshot.data.documents.length.toString());
        return ListView.builder(
          reverse: true,
          itemCount: snapshot.data.documents.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: <Widget>[
                MessageTile.fromDocumentSnapshot(snapshot.data.documents[index]),
                Divider()
              ],
            );
          });
      }
    );
  }
}
