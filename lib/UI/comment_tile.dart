import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/main_bloc.dart';
import 'package:tags/Models/user.dart';
import 'package:tags/UI/user_circle_avatar.dart';
import 'package:tags/Utils/firebase_db.dart';



class CommentTile extends StatefulWidget {
  final String _id;
  final String _postId;
  final String _tagsOwnerId; 
  final String _userName;
  final String _userPhotoUrl; //inutile
  final String _content;
  final String _userId;
  

  CommentTile.fromDocumentSnapshot(DocumentSnapshot snapshot):
    _id=snapshot.documentID,
    _userName=snapshot.data["userName"],
    _postId=snapshot.data["postId"],
    _userPhotoUrl=snapshot.data["userPhotoUrl"],
    _content=snapshot.data["content"],
    _userId=snapshot.data["userId"],
    _tagsOwnerId=snapshot.data["tagsOwnerId"];

  @override
  _CommentTileState createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> with AutomaticKeepAliveClientMixin{

  void deleteComment(){
    db.deleteCommentFirestore(widget._tagsOwnerId,widget._postId,widget._id);
  }

  @override
  Widget build(BuildContext context) {
    print("[build Comment_Tile]");
    final MainBloc _mainBloc = BlocProvider.of<MainBloc>(context);
    final User currentUser =_mainBloc.currentUser;
    return Container(
      child: ListTile(
        //dense: true,
        //isThreeLine: true,
        onLongPress: widget._userId==currentUser.id? (){
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[ 
                  Text("Voulez-vous supprimer ce commantaire ?"),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: (){
                      deleteComment();
                    },
                  )
                ]
              )
            )
          );
        }:null,
        leading: UserCircleAvatar(widget._userName,widget._userId),
        title: Text(widget._userName),
        subtitle: Text(widget._content),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}