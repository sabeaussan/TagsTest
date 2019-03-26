
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tags/Models/user.dart';
import 'package:tags/Utils/firebase_db.dart';
import 'dart:async';
import 'package:tags/pages/other_user_profile_page.dart';


class UserCircleAvatar extends StatefulWidget {
  final _userName;
  final String _uid;

  UserCircleAvatar(this._userName,this._uid,/*{Key key}*/)/*:super(key:key)*/;

  @override
  _UserCircleAvatarState createState() => _UserCircleAvatarState();
}

class _UserCircleAvatarState extends State<UserCircleAvatar> {
  Future<String> futureUserPhoto;     //TODO:A utiliser partout sans moderation !!!!

  String getInitiales(){
    String initiales = widget._userName[0];
    return initiales;
  }

  void _navigateOtherUserProfilePage(BuildContext context) async{
    final User user = await db.getUser(widget._uid);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context){
          return OtherUserProfilePage(user);
        }
      )
    );
  }

  @override
  void initState()  {
    // TODO: consomme une lecture même si url=null
    super.initState();
    print("[initState userCircleAvatar]");
    futureUserPhoto= db.getUserPhototUrl(widget._uid);
  }

  @override
  Widget build(BuildContext context) {
    print("[build userCircleAvatat]");
    return FutureBuilder(
      future: futureUserPhoto,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if(snapshot.connectionState==ConnectionState.done){
          return GestureDetector(
            onTap:(){
              _navigateOtherUserProfilePage(context);
            },
            child :snapshot.data!=null? 
             CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(snapshot.data),
            )
            :
            CircleAvatar(
              backgroundColor: Colors.deepOrange[300],
              child: 
                Text(getInitiales(),style: TextStyle(fontSize: 25.0,color: Colors.white),),
              
            )
          );
        }
        else{
          return Container(width: 0.0,height: 0.0,);
        }
      },
    );
  }
}