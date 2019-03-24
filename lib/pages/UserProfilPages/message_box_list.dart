import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/main_bloc.dart';
import 'dart:async';
import 'package:tags/UI/discussion_tile.dart';



class MessageBoxList extends StatefulWidget {

  const MessageBoxList();

  @override
  _MessageBoxListState createState() => _MessageBoxListState();
}

class _MessageBoxListState extends State<MessageBoxList> {
  MainBloc _mainBloc; 
  Stream<QuerySnapshot> stream;

  Widget _buildListView(QuerySnapshot snapshot){
    return ListView.builder(
          itemCount: snapshot.documents.length,
          itemBuilder: ((BuildContext context,int index){
          return Column(
            children: <Widget>[
                Divider(height: 0.0,color: Colors.black38,),
                GestureDetector(
                  child: DiscussionTile.fromDocumentSnapshot(snapshot.documents[index],key: ValueKey(snapshot.documents[index].documentID),), 
                ),
                index==snapshot.documents.length-1? SizedBox(height: 50.0,):Container()
              ],
            );
          }),
        );
  }

  @override
  void initState() {
    print("[initState mailBox]");
    super.initState();
    _mainBloc = BlocProvider.of<MainBloc>(context);
    stream = _mainBloc.listConvControllerStream;
  }

  @override
  Widget build(BuildContext context) {
    
    return StreamBuilder<QuerySnapshot>(
      //TODO: essayer avec collection("discussion") et utiliser where id containes userId pour récup les bons
      //TODO: il y a un problème avec la requête orderBy car elle actualise les conversations bizarement
      stream: _mainBloc.listConvControllerStream,
      initialData: _mainBloc.userDiscussionSnapshot, 
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
        if(!snapshot.hasData){
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.data.documents.length==0) {
            return Center(
              child: Text("Aucun message"),
            );
          }
        return _buildListView(snapshot.data);
      },
    );
  }
}