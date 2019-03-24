


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tags/Models/tags.dart';
import 'package:tags/UI/post_tile.dart';

class TagsGallery extends StatefulWidget {
  
  //TODO:faire un streamSubscription pour pouvoir le cancel dans dispose
  //TODO: trigger la query à chaque fois qu'on retourne sur la page, faire 
  //la query dans le initState si la consommation de read augmente trop

  final Tags _tags;


  TagsGallery(this._tags,{Key key}):super(key:key);

  @override
  TagsGalleryState createState() {
    return new TagsGalleryState();
  }
}

class TagsGalleryState extends State<TagsGallery> {
  //TODO: modifier edit post trop long et doit bloquer les autres options
  Stream<QuerySnapshot> streamPost;

  String timeStamp() => DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("---------[initState TagsGallery]-----------");
    streamPost=Firestore.instance.collection("Tags").document(widget._tags.id).collection("TagsPost").orderBy("id",descending: true).snapshots();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: streamPost,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
        if(!snapshot.hasData){
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.data.documents.length==0) {
            return Center(
              child: Text("ajoute un premier post !"),
            );
          }
        print("******[stb tagsGallery] trigered********* "+snapshot.data.documents.length.toString());
        if(snapshot.connectionState==ConnectionState.active){
          return ListView(
          children: 
            snapshot.data.documents.map((DocumentSnapshot documents){
              final PostTile postTile = PostTile.fromDocumentSnaptshot(documents);
              postTile.setType(GALLERY);
              return postTile;
            }).toList()
      
        );
        }
      }
      
    );
  }
}