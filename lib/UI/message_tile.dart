import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/main_bloc.dart';
import 'package:tags/Models/user.dart';
import 'package:tags/UI/user_circle_avatar.dart';
import 'package:tags/Utils/firebase_db.dart';



class MessageTile extends StatelessWidget {

  final String _id;
  final String _timeStamp;
  final String _content;
  final String _userName;
  final String _userId;
  final String _tagOwnerId;
  final String _userPhotoUrl;     //peut servir




  MessageTile.fromDocumentSnapshot(DocumentSnapshot snapshot):
    _id=snapshot.documentID,
    _content=snapshot.data["content"],
    _timeStamp=snapshot.data["timeStamp"],
    _userName=snapshot.data["userName"],
    _userId=snapshot.data["userId"],
    _tagOwnerId=snapshot.data["tagOwnerId"],
    _userPhotoUrl=snapshot.data["userPhotoUrl"];

 

  void _navigateOtherUserProfilePage(BuildContext context){
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context){
          //return OtherUserProfilePage();
        }
      )
    );
  }

  void deleteTagsMessage(){
    db.deleteTagsMessageFirestore(_tagOwnerId,_id);
  }



  @override
  Widget build(BuildContext context) {
    final MainBloc _mainBloc = BlocProvider.of<MainBloc>(context);
    final User currentUser =_mainBloc.currentUser;
    DateTime date = DateTime.fromMillisecondsSinceEpoch(int.parse(_timeStamp));
    return Container(
      child: ListTile(
        onLongPress: _userId==currentUser.id? (){
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[ 
                  Text("Voulez-vous supprimer ce message ?"),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: (){
                      deleteTagsMessage();
                    },
                  )
                ]
              )
            )
          );
        }:null,
        onTap:null,
        leading: GestureDetector(
          onTap: (){
            _navigateOtherUserProfilePage(context);
            
          },
          child: UserCircleAvatar(_userName,_userId),
        ),
        title: Text(_userName),
        subtitle: Text(_content),
        trailing: Text("${formatDate(date,[dd, '-', mm, '-', yyyy ])}"),
      ),
    );
  }
}