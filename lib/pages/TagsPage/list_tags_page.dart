import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/main_bloc.dart';
import 'package:tags/Models/tags.dart';
import 'package:tags/Models/user.dart';
import 'package:tags/UI/tags_tile.dart';


class ListTagsPage extends StatefulWidget {


  _ListTagsPageState createState() => _ListTagsPageState();
}

//Page contenant la list des Tags à proximité

class _ListTagsPageState extends State<ListTagsPage> {
  Stream<QuerySnapshot> streamTags;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("---------[initState listTags]-----------");
    streamTags=Firestore.instance.collection("Tags").snapshots();
  }


  bool getFavStatus(User user,String tagsId){
     if(user.favTagsId!=null) return user.favTagsId.contains(tagsId);
     return false;
  } 

  @override
  Widget build(BuildContext context) {
    final MainBloc _mainBloc = BlocProvider.of<MainBloc>(context);
    final User currentUser =_mainBloc.currentUser;
    print(currentUser.id);
    return StreamBuilder(
      stream: streamTags,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
        if(!snapshot.hasData){
          return Center(
            child: CircularProgressIndicator(),
            );
          }
          if(snapshot.data.documents.length==0){    //Il n'y pas de tags à récupérer
          return Center(
            child: Text("Aucun tags à proximité"),
            );
          }
        print("******[stb listTags] trigered********* "+snapshot.data.documents.length.toString());
        return ListView.builder(
          itemCount: snapshot.data.documents.length ,
          itemBuilder: (BuildContext context, int index){
            final Tags tags = Tags.fromDocumentSnapshot(snapshot.data.documents[index]);
            final bool isFav = getFavStatus(currentUser,tags.id);
            print(isFav);
            return TagsTile(tags, "", true,isFav);
          }
        );
      },
    );
  }
}