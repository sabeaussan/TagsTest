
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/main_bloc.dart';
import 'package:tags/Models/user.dart';
import 'package:tags/Utils/firebase_db.dart';
import 'package:tags/Utils/url_cache.dart';
import 'dart:async';
import 'package:tags/pages/other_user_profile_page.dart';


class UserCircleAvatar extends StatefulWidget {
  
  //TODO : utiliser un cache pour sauvegarder une liste de Map<uid;url>
  //pour ne pas avoir à refetch à chaque fois l'url
  final String _userName;
  final String _uid;
  

  UserCircleAvatar(this._userName,this._uid,{Key key}):super(key:key);

  @override
  _UserCircleAvatarState createState() => _UserCircleAvatarState();
}

class _UserCircleAvatarState extends State<UserCircleAvatar> {
  Future<String> futureUserPhoto;     //TODO:A utiliser partout sans moderation !!!!
  User _currentUser;
  MainBloc _mainBloc;

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
    _mainBloc = BlocProvider.of<MainBloc>(context);
    _currentUser =_mainBloc.currentUser;
    if(_currentUser.id==widget._uid){
      futureUserPhoto= Future((){
        return _currentUser.photoUrl;
      });
    }
    else{
      futureUserPhoto = UrlCache.getUrl(widget._uid);
    }
    
  }

  @override
  Widget build(BuildContext context) {
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
              backgroundColor: Colors.red[300],
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