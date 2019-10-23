import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/main_bloc.dart';
import 'package:tags/Models/comment.dart';
import 'package:tags/Models/user.dart';
import 'package:tags/UI/clickable_text.dart';
import 'package:tags/UI/user_circle_avatar.dart';
import 'package:tags/Utils/firebase_db.dart';

import 'notif_icon.dart';

// La key sert a l'ordenancement quand on ajoute un élèment
// Keep alive sert à ne pas refetch a chaque qu'un item sort de l'écran


class CommentTile extends StatefulWidget {
  final String _id;
  final String _postId;
  final String _tagsOwnerId; 
  final String _userName;
  final bool _needToBeNotify;
  final String _content;
  final String _userId;
  

  CommentTile.fromDocumentSnapshot(DocumentSnapshot snapshot,bool needToBeNotify):
    _id=snapshot.documentID,
    _userName=snapshot.data["userName"],
    _postId=snapshot.data["postId"],
    _content=snapshot.data["content"],
    _userId=snapshot.data["userId"],
    _tagsOwnerId=snapshot.data["tagsOwnerId"],
    _needToBeNotify = needToBeNotify;

  CommentTile.fromComment(Comment comment):
    _id = comment.id,
    _postId = comment.postId,
    _tagsOwnerId = comment.tagOwnerId,
    _userName = comment.username,
    _content = comment.content,
    _userId = comment.userId,
    _needToBeNotify = false;

  @override
  _CommentTileState createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> with AutomaticKeepAliveClientMixin{

  void deleteComment(){
    db.deleteCommentFirestore(widget._tagsOwnerId,widget._postId,widget._id);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final MainBloc _mainBloc = BlocProvider.of<MainBloc>(context);
    final User currentUser =_mainBloc.currentUser;
    return Container(
      child: ListTile(
        trailing: widget._needToBeNotify? NotifIcon(18.0,9.0):Container(width: 0,height: 0,),
        onLongPress: widget._userId==currentUser.id? (){
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[ 
                  Text("Voulez-vous supprimer ce commentaire ?"),
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
        leading: UserCircleAvatar(widget._userName,widget._userId,key: ValueKey(widget._id),),
        title: ClickableWidget(
          Text(widget._userName,style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold)),
          widget._userId
          ),
        subtitle: Text(widget._content),
      ),
    );
  }


  @override
  //TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}