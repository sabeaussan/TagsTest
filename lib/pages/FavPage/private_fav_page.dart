import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tags/UI/post_tile.dart';

class PrivateFavPage extends StatefulWidget {

  _PrivateFavPageState createState() => _PrivateFavPageState();
}

class _PrivateFavPageState extends State<PrivateFavPage> {

    //ajouter un model post

  
  Future<void> _fetchFav() async {
    //QuerySnapshot snap = await Firestore.instance.collection("Tags").getDocuments();
    return;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      //future: ,
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