import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/main_bloc.dart';
import 'package:tags/Models/user.dart';
import 'package:tags/UI/circle_avatar_initiales.dart';
import 'package:tags/pages/UserProfilPages/chat_page.dart';
import 'package:tags/pages/other_user_post_grid.dart';



class OtherUserProfilePage extends StatefulWidget {
  _OtherUserProfilePageState createState() => _OtherUserProfilePageState();

  final User _user;

  OtherUserProfilePage(this._user);

}

class _OtherUserProfilePageState extends State<OtherUserProfilePage> {



  Widget _buildTabs(){
    return OtherUserPostGrid(widget._user);
  }


  String retrieveDicussionId(String id1,String id2){
    return id1.compareTo(id2)<0?  "$id1+$id2" : "$id2+$id1";
  }

  void _navigateChatPage(BuildContext context,User currentUser,User partner){
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:(BuildContext context){
          final String discussionId=retrieveDicussionId(currentUser.id, partner.id);
          return ChatPage(partner,discussionId);
        }
      )
    );

  }

  Widget _buildUserProfileColumn(BuildContext context){
     const IconData chat = const IconData(0xf38d,
          fontFamily: CupertinoIcons.iconFont,
          fontPackage: CupertinoIcons.iconFontPackage); 
    final MainBloc _mainBloc = BlocProvider.of<MainBloc>(context);
    final User currentUser =_mainBloc.currentUser;
    return Expanded(
      flex: 0,
      child: Center(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height*0.28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(bottom: Radius.elliptical(150.0,30.0)),
              color: Colors.red,
              shape: BoxShape.rectangle
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
              SizedBox(
                width: 10.0,
              ),
              Expanded(
                flex: 1,
                child: widget._user.photoUrl!=null ? 
                CircleAvatar(
                  radius: MediaQuery.of(context).size.width*0.16,
                  backgroundImage:  CachedNetworkImageProvider(widget._user.photoUrl),
                )
                :
                CircleAvatarInitiales(widget._user),
              ),
            
            SizedBox(
              width: 12.0,
            ),
              Expanded(
                flex:2,
                child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      textBaseline: TextBaseline.alphabetic,
                      children: <Widget>[
                        Flex(
                          direction: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                          Flexible(
                            flex: 4,
                            child: Text(widget._user.userName,style: TextStyle(fontSize: 25.0,fontWeight: FontWeight.bold,color: Colors.white),),
                           ),
                          Flexible(
                            fit: FlexFit.loose,
                            flex: 0,
                            child: currentUser.id!=widget._user.id?
                              IconButton(
                                icon: Icon(chat,color: Colors.white,),
                                onPressed: (){
                                  _navigateChatPage(context,currentUser,widget._user);
                                },
                              )
                              :Container(),
                         ),
                        ],),
                        Text(widget._user.nom + " "+widget._user.prenom,style: TextStyle(color: Colors.white),),
                      ],
                    ),
              ),  
                ],
              ),
            ),
          ],
        ),
    ),
    );
  }
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
          children: <Widget>[
            _buildUserProfileColumn(context),
            SizedBox(
              height: 10.0,
            ),
            Container(
              child: Text(widget._user.bio),
              margin: EdgeInsets.all(10.0),
            ),
            SizedBox(
              height: 20.0,
            ),
            Expanded(
              flex: 3,
              child: _buildTabs(),
            )
          ],
        )
    );
  }
}